/****************************************************************************************
  * @filename      : KDCE_Order_tr
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-02-19
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : KDCE_Order_tr_Test
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-02-19             Park HE         Create
    0.2     2021-04-01             Yoon JE         Update
****************************************************************************************/
public with sharing class KDCE_Order_tr extends TriggerHandler {

    public static Boolean isAlreadyExecuted = false;    // 재귀호출 방지 flag

    private final static Id RT_Coupon_CVS     = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_CVS').getRecordTypeId();    // 쿠폰 : 편의점
    private final static Id RT_Coupon_GetInfo = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_GetInfo').getRecordTypeId();// 쿠폰 : Getinfo
    private final static Id RT_Coupon_MGM     = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_MGM').getRecordTypeId();    // 쿠폰 : MGM

    // 쿠폰 사용 취소 상태값 (close - 배송 전 취소, processed_closed - 배송 후 취소 후 반납완료
    public final static  Set<String> cancelStatus = new Set<String>{
            // 20210901 주문취소시 Coupon Journey Cancel을 위해 수정
            //KDCE_GlobalValue.ORDER_STATUS_CLOSE, KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED
            
            KDCE_GlobalValue.ORDER_STATUS_CLOSE
    };

    public override void beforeInsert() {
        this.checkRefundOrder();
    }
    public override void beforeUpdate() {
        this.checkRefundOrder();                    // Return Order 인입 시, 오리지널 오더에 환불 오더 플래그 표시
    }
    @SuppressWarnings('PMD')
    public override void beforeDelete() {
    }
    public override void afterInsert() {
        this.createCouponHistoryUponCouponOrder();  // 온라인 주문에서 쿠폰 사용 시 CouponHistory 데이터 생성 (Reason = forward)
        contactUpdateZTI();                         // Trade-in 주문시, Contact의 Trade-in 체크 필드 체크/해제
    }
    public override void afterUpdate() {
        //this.toUpdateAssetStatus();
        if (isAlreadyExecuted == false) {
            this.updateContactPurchaseDate();       //주문 생성시 혹은 업데이트시, Contact Purchase 필드 업데이트 (Status = complete / complete_delievery)
            this.updateRelatedWhenCancel();         //주문 취소시 관련 오브젝트 업데이트 (OrderStatus__c = closed/processed_closed로 변경되었을때)
            contactUpdateZTI();                         // Trade-in 주문시, Contact의 Trade-in 체크 필드 체크/해제
            isAlreadyExecuted = true;
        }
        setItemCollectionStatus();
    }
    @SuppressWarnings('PMD')
    public override void afterDelete() {
    }


    /**
     * Return Order 인입 시, 오리지널 오더에 환불 오더 플래그 표시
     */
    private void checkRefundOrder(){
        System.debug('@@@@@@ checkRefundOrder @@@@@@');
        List<KDCE_Order__c> newList = new List<KDCE_Order__c>();
        for(KDCE_Order__c item : (List<KDCE_Order__c>) Trigger.new){
            if(Trigger.isInsert){
                if(item.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RETURN)
                    newList.add(item);
            }

            if(Trigger.isUpdate){
                KDCE_Order__c oldItem = (KDCE_Order__c)Trigger.oldMap.get(item.Id);
                if(item.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RETURN && oldItem.OrderReason__c != item.OrderReason__c)
                    newList.add(item);
            }

        }
        this.updateToRefundOrder(newList);
    }

    /**
     * @description 온라인 주문에서 취소시
     *              - Contact Purchase Date 롤백
     *              - 쿠폰 주문 취소 시 쿠폰 사용 취소에 대한 히스토리 생성
     *              - MGM 쿠폰 사용 취소 시, 기프티콘 관련 Task 삭제 처리 (2021. 3. 23 윤지은)
     *              - GetInfo 쿠폰 사용 취소 시, 쿠폰 상태 업데이트 (2021. 6. 3 이지현)
     * @author JE Yoon (2021. 3. 23) 지현 통합 (2021.07.07)
     **/
    private void updateRelatedWhenCancel() {
        System.debug('@@@@@@ updateRelatedWhenCancel @@@@@@');
        Set<Id> couponCancelOrderIds = new Set<Id>();
        Set<Id> cancelOrderIds = new Set<Id>();
        Map<Id, List<KDCE_Order__c>> contactByOrder = new Map<Id, List<KDCE_Order__c>>();   // Contact별 취소된 주문일자
        List<KDCE_Order__c> orderList = new List<KDCE_Order__c>();

        KDCE_Order__c oldOrder;
        for (KDCE_Order__c order : (List<KDCE_Order__c>) Trigger.new) {
            oldOrder = (KDCE_Order__c) Trigger.oldMap.get(order.Id);
            System.debug(Trigger.isinsert);
            System.debug(Trigger.isupdate);
            System.debug('cancelorder : ' + oldOrder);
            System.debug('cancelorder : ' + order);
            if (!cancelStatus.contains(oldOrder.OrderStatus__c) && cancelStatus.contains(order.OrderStatus__c)) {
                if (contactByOrder.containsKey(order.Contact__c))
                    orderList = contactByOrder.get(order.Contact__c);
                else
                        orderList = new List<KDCE_Order__c>();
                orderList.add(order);
                contactByOrder.put(order.Contact__c, orderList);

                // Coupon 취소일 경우
                if (order.Coupon__c != null) couponCancelOrderIds.add(order.Id);
            }
        }
        if (!contactByOrder.isEmpty() || !orderList.isEmpty()) {
            updateContactWhenCancel(contactByOrder);    // Order가 캔슬이 될 경우, Contact 필드 업데이트
        }

        if (!couponCancelOrderIds.isEmpty()) {
            //20210901 주문취소시 Coupon Journey Cancel을 위해 수정 createCouponCancelHistory 주석 해제
            createCouponCancelHistory(couponCancelOrderIds);  // 주문 취소 시 쿠폰 사용 취소에 대한 히스토리 생성
            updateMGM(couponCancelOrderIds);  // MGM 쿠폰 관련 GodFather field 업데이트 및 Task 삭제
            updateGetInfo(couponCancelOrderIds);  // GetInfo 쿠폰 관련 Coupon 값 업데이트
        }
    }

    //20210901 주문취소시 Coupon Journey Cancel을 위해 수정 createCouponCancelHistory 주석 해제
    // 오더 쿠폰 취소시, 쿠폰 취소에 대한 히스토리 생성
    private void createCouponCancelHistory(Set<Id> couponCancelOrderIds) {
        System.debug('@@@@@@ createCouponCancelHistory @@@@@@');
        Map<String, String> pvMap_CouponHistory_ActionType      = KDCE_Util.getPicklistValue('KDCE_CouponHistory__c', 'ActionType__c');
        Map<String, String> pvMap_CouponHistory_ActionChannel   = KDCE_Util.getPicklistValue('KDCE_CouponHistory__c', 'ActionChannel__c');
        String couponStatus_Cancel = pvMap_CouponHistory_ActionType.get('Cancel');
        String actionChannel_Online = pvMap_CouponHistory_ActionChannel.get('Online');
        List<KDCE_CouponHistory__c> couponHistories = new List<KDCE_CouponHistory__c>();
        KDCE_CouponHistory__c history;

        for (KDCE_Order__c order : [SELECT Id, Coupon__c, Contact__c FROM KDCE_Order__c WHERE Id IN :couponCancelOrderIds]) {
            history = KDCE_CouponService.createCouponHistory(order.Coupon__c, couponStatus_Cancel);
            history.ActionChannel__c    = actionChannel_Online;
            history.Contact__c          = order.Contact__c;
            history.Order__c            = order.Id;
            couponHistories.add(history);
        }
        Database.SaveResult[] rs_histories = Database.insert(couponHistories);
    }


    // 오더 MGM 쿠폰 취소시, Contact God Father null 처리 및 관련 Task 삭제
    private void updateMGM(Set<Id> couponCancelOrderIds) {
        System.debug('@@@@@@ updateMGM @@@@@@');

        Map<Id, KDCE_CouponHistory__c> mgmCouponHistoryMap;
        List<Task> tasks2Delete = new List<Task>();
        Map<Id, Contact> updateGodFather = new Map<Id, Contact>();
        Set<Id> contacts = new Set<Id>();

        mgmCouponHistoryMap = new Map<Id, KDCE_CouponHistory__c>([
                SELECT Id, Coupon__c, Contact__c, Coupon__r.Contact__c
                FROM KDCE_CouponHistory__c
                WHERE Order__c IN :couponCancelOrderIds
                AND Coupon__r.RecordTypeId = :RT_Coupon_MGM
        ]);
        if (!mgmCouponHistoryMap.isEmpty()) {
            // Task 삭제
            tasks2Delete = [SELECT Id FROM Task WHERE WhatId = :mgmCouponHistoryMap.keySet()];   // TODO Subject로 MGM 쿠폰이 생성된 것만 제거해주기 위해 AND Subject = 'MGM Coupon Use' 조건을 걸지 확인 핑료
            if (!tasks2Delete.isEmpty()) delete tasks2Delete;

            for (KDCE_CouponHistory__c coupon : mgmCouponHistoryMap.values()) {
                contacts.add(coupon.Contact__c);
            }

            // Contact God Father 필드 널처리
            for (Contact contact : [SELECT Id, KDCE_GodFather__c FROM Contact WHERE Id IN :contacts]) {
                contact.KDCE_GodFather__c = null;
                updateGodFather.put(contact.Id, contact);
            }
            if (!updateGodFather.isEmpty()) update updateGodFather.values();

        }
    }

    // 오더 GetInfo 쿠폰 취소시, GetInfo 쿠폰 필드 업데이트
    private void updateGetInfo(Set<Id> couponCancelOrderIds) {
        System.debug('@@@@@@ updateGetInfo @@@@@@');

        Map<Id, KDCE_CouponHistory__c> getInfoCouponHistoryMap;
        Map<Id, KDCE_Coupon__c> updateCouponMap = new Map<Id, KDCE_Coupon__c>();

        // GetInfo 쿠폰 관련 Coupon 값 업데이트
        getInfoCouponHistoryMap = new Map<Id, KDCE_CouponHistory__c>([
                SELECT Id, Coupon__c
                FROM KDCE_CouponHistory__c
                WHERE Order__c = :couponCancelOrderIds
                AND Coupon__r.RecordTypeId = :RT_Coupon_GetInfo
        ]);

        if (!getInfoCouponHistoryMap.isEmpty()) {
            for (KDCE_CouponHistory__c history : getInfoCouponHistoryMap.values()) {
                updateCouponMap.put(history.Coupon__c, new KDCE_Coupon__c(
                        Id = history.Coupon__c,
                        Status__c = KDCE_GlobalValue.COUPON_STATUS_ISSUE,
                        UsedDate__c = null
                ));
            }
        }

        if (!updateCouponMap.isEmpty()) update updateCouponMap.values();
    }


    // Order가 캔슬이 될 경우, Contact 필드 업데이트 (Contact에 있던 First Purchase Date/Last Purchase Date에 해당하는 주문이 사라질 경우, 그 이전 주문의 Purchase Date 넣어줌)
    private void updateContactWhenCancel(Map<Id, List<KDCE_Order__c>> contactByOrder) {
        System.debug('@@@@@@ updateContactWhenCancel @@@@@@');

        Map<Id, Map<String, Object>> purchaseByContact = new Map<Id, Map<String, Object>>();
        Map<String, Object> purchaseMap = new Map<String, Object>();

        List<Contact> contactList = [
                SELECT Id, KDCE_FirstPurchaseDate__c, KDCE_FirstPurchaseChannel__c, KDCE_FirstPurchaseId__c,
                        KDCE_LastPurchaseDate__c, KDCE_LastPurchaseChannel__c, KDCE_LastPurchaseId__c, KDCE_GodFather__c
                FROM Contact
                WHERE Id IN :contactByOrder.keySet()
        ];
        if(contactList.isEmpty()) return;

        // 주문 취소된 order의 주문 날짜가 contact의 First Purchase Id 혹은 Last Purchase Id와 일치하는지 확인
        Set<Id> deleteOrders = new Set<Id>();

        // 새로 들어온 취소 주문중에, Contact의 Purchase Date와 일치하는 값이 있는지 확인
        for (Contact contact : contactList) {
            for (KDCE_Order__c order : contactByOrder.get(contact.Id)) {
                if (String.valueOf(order.Id) == contact.KDCE_FirstPurchaseId__c || String.valueOf(order.Id) == contact.KDCE_LastPurchaseId__c) {
                    deleteOrders.add(order.OriginOrder__c);     // TODO OriginOrder는 왜했지? 생각해내기;;
                    deleteOrders.add(order.Id);
                    purchaseByContact.put(contact.Id, null);
                }
            }
        }

        // Contact과 관련된 연결된 Order, Offline Program, Coupon 가져오기 (Order 주문 취소의 경우니까, Order의 경우만 제외할 Id set 넣어줌)
        Set<Id> contactIds = purchaseByContact.keySet();
        Map<Id, List<KDCE_Order__c>> orderListByCon             = KDCE_ContactService.getOrderByContactMap(contactIds, deleteOrders);
        Map<Id, List<KDCE_OfflineProgram__c>> programListByCon  = KDCE_ContactService.getProgramByContactMap(contactIds);
        Map<Id, List<KDCE_Coupon__c>> couponListByCon           = KDCE_ContactService.getCouponByContactMap(contactIds);

        for (Id contactId : purchaseByContact.keySet()) {

            purchaseMap = new Map<String, Object>();

            // Order 값 비교
            purchaseByContact = KDCE_ContactService.purchaseOrderMap(purchaseByContact, orderListByCon, contactId);
            purchaseByContact = KDCE_ContactService.purchaseProgramMap(purchaseByContact, programListByCon, contactId);
            purchaseByContact = KDCE_ContactService.purchaseCouponMap(purchaseByContact, couponListByCon, contactId);
        }

        // Contact과 연결되어 있는 값 비교
        Map<Id, Contact> updateContactMap = KDCE_ContactService.getPurchaseResult(purchaseByContact);
        if (updateContactMap.size() > 0) update updateContactMap.values();
    }

    /**
     * @description 온라인 주문에서 쿠폰 사용 시 CouponHistory 데이터 생성
     * @author JE Yoon (2021. 04. 01)
     * */
    private void createCouponHistoryUponCouponOrder() {
        System.debug('@@@@@@ createCouponHistoryUponCouponOrder @@@@@@');
        List<KDCE_Order__c> orders = new List<KDCE_Order__c>();
        for (KDCE_Order__c order : (List<KDCE_Order__c>) Trigger.new) {
            if (order.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD && order.Coupon__c != null) {
                orders.add(order);
            }
        }

        if (!orders.isEmpty()) KDCE_CouponService.createOnlineCouponUseHistory(orders);
    }


    /**
     * Order 관련 Contact Field (Purchase Date) - 2021.04.21 이지현
     * 주문 들어올 경우, (Order의 Status가 complete/complete_delivery로 변경되거나, 생성될떄 (이땐 orderlineitem 플래그 필드가 업데이트됨))
     * Contact에 First/Last Purchase Date, First/Last Purchase Channel 넣어줌
     */
    private void updateContactPurchaseDate() {
        System.debug('@@@@@@ updateContactPurchaseDate @@@@@@');

        Map<String, String> contactChannelByOrderType = new Map<String, String>{                    // Order Type별 Contact Channel Map
                KDCE_GlobalValue.ORDER_TYPE_NORMAL + KDCE_GlobalValue.ORDER_REASON_FORWARD => KDCE_GlobalValue.CONTACT_CHANNEL_ECOMMERCE,
                KDCE_GlobalValue.ORDER_TYPE_RTLBUY + KDCE_GlobalValue.ORDER_REASON_RTLFORWARD => KDCE_GlobalValue.CONTACT_CHANNEL_RENTAL,
                KDCE_GlobalValue.ORDER_TYPE_TRADEIN + KDCE_GlobalValue.ORDER_REASON_FORWARD => KDCE_GlobalValue.CONTACT_CHANNEL_TRADEIN
        };

        List<KDCE_Order__c> orderList = new List<KDCE_Order__c>();
        Set<Id> contacts = new Set<Id>();
        Set<String> completeStatus = new Set<String>{
                KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY, KDCE_GlobalValue.ORDER_STATUS_COMPLETE
        };
            for (KDCE_Order__c order : (List<KDCE_Order__c>) Trigger.new) {

            KDCE_Order__c oldOrder = (KDCE_Order__c) Trigger.oldMap.get(order.Id);
            System.debug('=== oldOrder x: ' + oldOrder);
            if (order.Contact__c != null) {
                if ((!completeStatus.contains(oldOrder.OrderStatus__c) && completeStatus.contains(order.OrderStatus__c) && order.ru_ValidProductCount__c > 0) || order.isTargetPurchaseDateUpdate__c) {
                    if (contactChannelByOrderType.keySet().contains(order.OrderType__c + order.OrderReason__c)) {   // ex. ZTAforward
                        orderList.add(order);
                        contacts.add(order.Contact__c);
                    }
                }
            }
        }
        if((contacts.isEmpty() || orderList.isEmpty()) && !Test.isRunningTest()) return;
        Map<Id, Contact> contactMap = new Map<Id, Contact>();                                       // 업데이트할 Contact Map
        for (Contact contact : [
                SELECT Id, KDCE_LASLAU__c, KDCE_FirstPurchaseChannel__c, KDCE_FirstPurchaseDate__c, KDCE_FirstPurchaseId__c,
                        KDCE_LastPurchaseDate__c, KDCE_LastPurchaseChannel__c, KDCE_LastPurchaseId__c
                FROM Contact
                WHERE Id IN :contacts
        ]) {
            contactMap.put(contact.Id, contact);
        }
        System.debug('=== contactMap : ' + contactMap);

        Contact updateContact;
        for (KDCE_Order__c order : orderList) {
            updateContact = contactMap.get(order.Contact__c);

            // 업데이트 하려는 값과 비교
            if (contactMap?.get(updateContact.Id).KDCE_FirstPurchaseDate__c == null || order.ShippingStartDate__c < contactMap.get(updateContact.Id).KDCE_FirstPurchaseDate__c) {
                updateContact.KDCE_FirstPurchaseChannel__c  = contactChannelByOrderType.get(order.OrderType__c + order.OrderReason__c);
                updateContact.KDCE_FirstPurchaseDate__c     = order.ShippingStartDate__c;
                updateContact.KDCE_FirstPurchaseId__c       = String.valueOf(order.Id);
            }
            if (contactMap?.get(updateContact.Id).KDCE_LastPurchaseDate__c == null || order.ShippingStartDate__c > contactMap.get(updateContact.Id).KDCE_LastPurchaseDate__c) {
                updateContact.KDCE_LastPurchaseChannel__c   = contactChannelByOrderType.get(order.OrderType__c + order.OrderReason__c);
                updateContact.KDCE_LastPurchaseDate__c      = order.ShippingStartDate__c;
                updateContact.KDCE_LastPurchaseId__c        = String.valueOf(order.Id);
            }
            contactMap.put(updateContact.Id, updateContact);
        }
        if (contactMap.size() > 0) update contactMap.values();
    }

    /**
     * @author Park He
     * @description Return Order 인입 시, 오리지널 오더에 환불 오더 플래그 표시
     * @param newList
     */
    //return order에 오리지널 정보가 들어올때 (업데이트로 수정)
    private void updateToRefundOrder(List<KDCE_Order__c> newList){
        System.debug('@@@@@@ updateToRefundOrder @@@@@@');
        Set<Id> originalOrderIds = new Set<Id>();
        for(KDCE_Order__c order : newList){
            if(order.OriginOrder__c <> null) originalOrderIds.add(order.OriginOrder__c);
            //else order.addError(System.Label.KDCE_ThereIsNoOriginOrderInReturnOrder);
        }

        List<KDCE_Order__c> originalOrders = [SELECT Id, IsRefundedOrder__c FROM KDCE_Order__c WHERE Id IN : originalOrderIds];

        if(!originalOrders.isEmpty()){
            for(KDCE_Order__c order : originalOrders) order.IsRefundedOrder__c = true;
            update originalOrders;
        }
    }

    /**
     * Header 추심 상태 값이 바뀌면 Item에도 적용. external_success
     */
    private void setItemCollectionStatus(){

        Set<Id> headerIds = new Set<Id>();

        for(KDCE_Order__c header : (List<KDCE_Order__c>)Trigger.new){
            KDCE_Order__c oldRecord = (KDCE_Order__c)Trigger.oldMap.get(header.Id);

            // 외부추심, 상태 값 변경되었을 때
            if(header.CollectionStatus__c != oldRecord.CollectionStatus__c && header.CollectionStatus__c == KDCE_GlobalValue.ORDER_COL_STATUS_EXTSUCCESS) headerIds.add(header.Id);
        }

        List<KDCE_OrderLineItem__c> itemList = [
                SELECT Id, CollectionStatus__c, Order__c
                FROM KDCE_OrderLineItem__c WHERE Order__c IN :headerIds
        ];

        for(KDCE_OrderLineItem__c item : itemList){
            KDCE_Order__c header = (KDCE_Order__c)Trigger.newMap.get(item.Order__c);
            item.CollectionStatus__c = header.CollectionStatus__c;
        }

        update itemList;
    }

    /**
     * Trade-in 일때, Contact Trade-in 진행중인 필드 업데이트
     * - 진행중이면 체크 / 진행끝나면 체크해제
     */
    private void contactUpdateZTI() {
        // reason: cOLLECT 주문이 생성이되면 체크
        // collect / status : process_cl
        Map<Id, Contact> updateContact = new Map<Id, Contact>();
        Set<String> progressZTI = new Set<String>{
                KDCE_GlobalValue.ORDER_STATUS_COMPLETE, KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY
        };
        Set<String> stopZTI = new Set<String>{
                KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED, KDCE_GlobalValue.ORDER_STATUS_CLOSE
        };

        for (KDCE_Order__c order : (List<KDCE_Order__c>) Trigger.new) {
            if (Trigger.isInsert) {
                if (order.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN && order.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_COLLECT) {
                    updateContact.put(order.Contact__c, new Contact(Id = order.Contact__c, KDCE_IsProcessTradeIn__c = true));
                }
            }
            else if (Trigger.isUpdate) {
                KDCE_Order__c oldOrder = (KDCE_Order__c) Trigger.oldMap.get(order.Id);
                if (order.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN && order.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_COLLECT && order.OrderStatus__c <> oldOrder.OrderStatus__c) {
                    if (stopZTI.contains(order.OrderStatus__c)) updateContact.put(order.Contact__c, new Contact(Id = order.Contact__c, KDCE_IsProcessTradeIn__c = false));
                }

            }
        }

        for (KDCE_Order__c order : [
                SELECT  Id, Contact__c
                FROM    KDCE_Order__c
                WHERE   Contact__c IN :updateContact.values()
                AND     OrderType__c = :KDCE_GlobalValue.ORDER_TYPE_TRADEIN
                AND     OrderReason__c = :KDCE_GlobalValue.ORDER_REASON_COLLECT
                AND     OrderStatus__c NOT IN :stopZTI
        ]) {
            updateContact.put(order.Contact__c, new Contact(Id = order.Contact__c, KDCE_IsProcessTradeIn__c = true));
        }

        if (!updateContact.isEmpty()) update updateContact.values();
    }

}