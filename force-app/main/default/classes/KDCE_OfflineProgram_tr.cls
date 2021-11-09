/****************************************************************************************
  * @filename      : KDCE_OfflineProgram_tr
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-12 오후 1:45
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-04-12 오후 1:45     i2max_Jihyun.Lee        Create
****************************************************************************************/

public without sharing class KDCE_OfflineProgram_tr extends TriggerHandler {
    // 재귀 호출 방지 Flag
    public static Boolean isAlreadyExecuted = false;

    private static Map<String, Id> rtMap_OP = KDCE_Util.getRecordTypeBySObject('KDCE_OfflineProgram__c');


    public override void beforeInsert() {
        setRecordType();                        // OP 생성시, OP Record Type 설정
    }

    public override void beforeUpdate() {
        updateFieldWhenUpdate();                // Status 렌탈 후 구매로 변경시, Offline Program Purchase Date 수정
        checkValidation();                      // Offline Program Status 변경시, 필수값 체크
    }

    public override void afterInsert() {
        updateRelatedByInsert();                // Offline Program 생성 시, 관련 오브젝트 필드 업데이트
    }


    public override void afterUpdate() {

        if (isAlreadyExecuted == false) {
            updateAssetByUpdate();              // Offline Program 업데이트 시, 관련 오브젝트 필드 업데이트
            updateContactWhenRefund();          // Offline Program 취소시, Contact필드 업데이트
            insertCouponHistoryWhenRefund();    // MGM이 있는 Offline Program 취소시, 쿠폰 필드 업데이트
            isAlreadyExecuted = true;
        }
//        insertCouponHistoryWhenReturn();    // Coupon이 존재하는 Offline Program 취소시, Coupon History 생성
    }

    /**
     * OP 생성시, OP Record Type 설정
     */
    private void setRecordType() {
        System.debug('@@@@@@ setRecordType @@@@@@');
        for (KDCE_OfflineProgram__c newOP : (List<KDCE_OfflineProgram__c>) Trigger.new) {
            // OP 생성시, Record Type Id 처리
            if (newOP.ProgramType__c != null) {
                if (newOP.ProgramType__c == KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
                    newOP.RecordTypeId = rtMap_OP.get('OfflineProgram_' + newOP.ProgramType__c);
                }
            else newOP.RecordTypeId = rtMap_OP.get('OfflineProgram_ZTA');
            }
        }
    }

    /**
     * Status Rental 후 구매로 변경시, Offline Program Purchase Date 자동 입력
     */
    private void updateFieldWhenUpdate() {
        System.debug('@@@@@@ updateFieldWhenUpdate @@@@@@');
        KDCE_OfflineProgram__c oldOP;
        for (KDCE_OfflineProgram__c newOP : (List<KDCE_OfflineProgram__c>) Trigger.new) {
            oldOP = (KDCE_OfflineProgram__c) Trigger.oldMap.get(newOP.Id);
            if (oldOP.Status__c != KDCE_GlobalValue.OFF_PG_STATUS_RTNPURCHASE && newOP.Status__c == KDCE_GlobalValue.OFF_PG_STATUS_RTNPURCHASE) newOP.PurchaseDate__c = System.today();
        }
    }

    /**
     * OP Status 변경시, Validation 체크
     */
    private void checkValidation() {
        System.debug('@@@@@@ checkValidation @@@@@@');
        List<KDCE_OfflineProgram__c> offlineProgramList = new List<KDCE_OfflineProgram__c>();
        for (KDCE_OfflineProgram__c newOP : (List<KDCE_OfflineProgram__c>) Trigger.new) {
            KDCE_OfflineProgram__c oldOP = (KDCE_OfflineProgram__c) Trigger.oldMap.get(newOP.Id);
            if (oldOP.Status__c <> newOP.Status__c) {
                offlineProgramList.add(newOP);
            }
        }

        Set<String> cancelStatus = new Set<String>{
                KDCE_GlobalValue.OFF_PG_STATUS_CANCEL, KDCE_GlobalValue.OFF_PG_STATUS_RTNCANCEL, KDCE_GlobalValue.OFF_PG_STATUS_RTNREFUND
        };
        for (KDCE_OfflineProgram__c newOP : offlineProgramList) {
            KDCE_OfflineProgram__c oldOP = (KDCE_OfflineProgram__c) Trigger.oldMap.get(newOP.Id);

            // 취소로 업데이트할 때, 취소일자 필수값
            if (!cancelStatus.contains(oldOP.Status__c) && cancelStatus.contains(newOP.Status__c)) {
                if (newOP.CancelDate__c == null) newOP.addError(System.Label.KDCE_PleaseEnterCancelDate);
            }
        }
    }

    /**
     * OP Status 변경시, 관련 Asset 필드 업데이트
     */
    private void updateAssetByUpdate() {
        System.debug('@@@@@@ updateAssetByUpdate @@@@@@');

        Set<Id> storeIdSet = new Set<Id>();
        Map<Id, Asset> assetMap = new Map<Id, Asset>();
        Map<Id, Id> contactByStoreMap = new Map<Id, Id>();
        Map<Id, Contact> updateContact = new Map<Id, Contact>();

        Set<String> rentalRefundStatus = new Set<String>{
                KDCE_GlobalValue.OFF_PG_STATUS_RTNREFUND, KDCE_GlobalValue.OFF_PG_STATUS_RTNCANCEL, KDCE_GlobalValue.OFF_PG_STATUS_RTNCLOSED
        };

        // Dummy Contact을 찾기 위한 Store Set 저장
        List<KDCE_OfflineProgram__c> offlineProgramList = new List<KDCE_OfflineProgram__c>();
        for (KDCE_OfflineProgram__c newOP : (List<KDCE_OfflineProgram__c>) Trigger.new) {
            KDCE_OfflineProgram__c oldOP = (KDCE_OfflineProgram__c) Trigger.oldMap.get(newOP.Id);
            if (oldOP.Status__c <> newOP.Status__c) {
                storeIdSet.add(newOP.Store__c);
                offlineProgramList.add(newOP);
            }
        }

        // Store Id별 Contact Id Map 저장  // TODO 고치기
//        for (Contact con : [
//                SELECT Id, KDCE_Store__c FROM Contact WHERE KDCE_IsStoreContact__c = TRUE AND KDCE_Store__c IN :storeIdSet]) {
//            contactByStoreMap.put(con.KDCE_Store__c, con.Id);
//        }

        for (KDCE_Store__c store : [SELECT Id, RentalContactId__c  FROM KDCE_Store__c WHERE Id IN :storeIdSet]) {
            contactByStoreMap.put(store.Id, store.RentalContactId__c);
        }


        for (KDCE_OfflineProgram__c newOP : offlineProgramList) {

            // Cancel로 변경
            if (newOP.Status__c == KDCE_GlobalValue.OFF_PG_STATUS_CANCEL) {

                Asset updateAsset;

                // New Charger 필드 업데이트
                if (newOP.NewCharger__c != null) {
                    updateAsset = new Asset();
                    updateAsset.Id     = newOP.NewCharger__c;
                    updateAsset.Status = KDCE_GlobalValue.ASSET_STATUS_PRODUCED;    // Asset Status가 변경될시, 공장초기화 (나머지값 다 null처리)
                    assetMap.put(newOP.NewCharger__c, updateAsset);
                }

                // New Holder 필드 업데이트
                if (newOP.NewHolder__c != null) {
                    updateAsset = new Asset();
                    updateAsset.Id      = newOP.NewHolder__c;
                    updateAsset.Status  = KDCE_GlobalValue.ASSET_STATUS_PRODUCED;    // Asset Status가 변경될시, 공장초기화 (나머지값 다 null처리)
                    assetMap.put(newOP.NewHolder__c, updateAsset);
                }

            }

            /*
             * Rental Refund: 렌탈 종료후, 사용하던 기기 반납
             * Rental Cancel: 렌탈 기간내, 기기 반납
             * Rental Closed: 렌탈 종료후, 기기 반납
             */
            else if (rentalRefundStatus.contains(newOP.Status__c)) {

                Asset updateAsset;

                if (newOP.NewCharger__c != null) {
                    updateAsset = setAssetRentalReturn(newOP.NewCharger__c, contactByStoreMap?.get(newOP.Store__c));
                    assetMap.put(newOP.NewCharger__c, updateAsset);
                }

                if (newOP.NewHolder__c != null) {
                    updateAsset = setAssetRentalReturn(newOP.NewHolder__c, contactByStoreMap?.get(newOP.Store__c));
                    assetMap.put(newOP.NewHolder__c, updateAsset);
                }

                // 관련 Contact Rental Consumer 해제
                updateContact.put(newOP.Contact__c, new Contact(Id = newOP.Contact__c, KDCE_RentalConsumer__c = false));

            }

            // 렌탈 종료후 사용하던 기기 구매
            else if (newOP.Status__c == KDCE_GlobalValue.OFF_PG_STATUS_RTNPURCHASE) {

                Asset updateAsset;

                if (newOP.NewCharger__c != null) {
                    updateAsset = setAssetRentalPurchase(newOP.NewCharger__c);
                    updateAsset.PurchaseDate = newOP.PurchaseDate__c;
                    updateAsset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_RENTALPURCHASED;
                    assetMap.put(newOP.NewCharger__c, updateAsset);
                }

                if (newOP.NewHolder__c != null) {
                    updateAsset = setAssetRentalPurchase(newOP.NewHolder__c);
                    updateAsset.PurchaseDate = newOP.PurchaseDate__c;
                    updateAsset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_RENTALPURCHASED;
                    assetMap.put(newOP.NewHolder__c, updateAsset);
                }

                // 관련 Contact Rental Consumer 해제
                updateContact.put(newOP.Contact__c, new Contact(Id = newOP.Contact__c, KDCE_RentalConsumer__c = false));
            }


        }
        if (assetMap.size() > 0) update assetMap.values();
        if (updateContact.size() > 0) update updateContact.values();

    }


    /**
     * OP 생성시, Contact Purchase Date 업데이트
     */
    private void updateRelatedByInsert() {
        System.debug('@@@@@@ updateRelatedByInsert @@@@@@');

        // Customer Purchase Date를 업데이트하는 Offline Program Type 종류별, Contact Purchase Channel명
        Map<Id, List<KDCE_OfflineProgram__c>> OPListByContactMap = new Map<Id, List<KDCE_OfflineProgram__c>>();    // Contact별 Offline Program List
        Map<String, String> contactChannelByOPType = new Map<String, String>{
                KDCE_GlobalValue.ORDER_TYPE_NORMAL      =>  KDCE_GlobalValue.CONTACT_CHANNEL_MANNED,
                KDCE_GlobalValue.OFF_PG_TYPE_UPGRADE    =>  KDCE_GlobalValue.CONTACT_CHANNEL_MANNED,
                KDCE_GlobalValue.OFF_PG_TYPE_RTLBUY     =>  KDCE_GlobalValue.CONTACT_CHANNEL_RENTAL,
                KDCE_GlobalValue.ORDER_TYPE_TRADEIN     =>  KDCE_GlobalValue.CONTACT_CHANNEL_TRADEIN
        };

        Set<Id> contacts = new Set<Id>();
        List<KDCE_OfflineProgram__c> OPList = new List<KDCE_OfflineProgram__c>();
        for (KDCE_OfflineProgram__c newOP : (List<KDCE_OfflineProgram__c>) Trigger.new) {
            if (newOP.Contact__c != null) {
                OPList.add(newOP);
                contacts.add(newOP.Contact__c);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        System.debug('=== contacts : ' + contacts);
        for (Contact contact : [
                SELECT Id, KDCE_LASLAU__c, KDCE_FirstPurchaseChannel__c, KDCE_FirstPurchaseDate__c, KDCE_LastPurchaseDate__c, KDCE_LastOfflineProgramDate__c
                FROM Contact
                WHERE Id IN :contacts
        ]) {
            contactMap.put(contact.Id, contact);
        }

        Contact updateContact;
        for (KDCE_OfflineProgram__c newOP : OPList) {
            updateContact = contactMap.get(newOP.Contact__c);
            // Op가 렌탈, 렌탈 후 구매가 아닐경우에만 해당 purchase 업데이트
            if (newOP.ProgramType__c != KDCE_GlobalValue.ORDER_TYPE_RENTAL && newOP.ProgramType__c	!= KDCE_GlobalValue.OFF_PG_TYPE_RTLBUY) {
                updateContact.KDCE_LastOfflineProgramDate__c = System.now();
            }

            // Contact First Purchase Date / Last Purchase Date 값 비교
            if (contactChannelByOPType.keySet().contains(newOP.ProgramType__c)) {
                // 업데이트 하려는 값과 비교
                if (contactMap?.get(updateContact.Id).KDCE_FirstPurchaseDate__c == null || newOP.PurchaseDate__c < contactMap.get(updateContact.Id).KDCE_FirstPurchaseDate__c) {
                    updateContact.KDCE_FirstPurchaseDate__c       = newOP.PurchaseDate__c;
                    updateContact.KDCE_FirstPurchaseChannel__c    = contactChannelByOPType.get(newOP.ProgramType__c);
                    updateContact.KDCE_FirstPurchaseId__c         = String.valueOf(newOP.Id);
                }
                if (contactMap?.get(updateContact.Id).KDCE_LastPurchaseDate__c == null || newOP.PurchaseDate__c > contactMap.get(updateContact.Id).KDCE_LastPurchaseDate__c) {
                    updateContact.KDCE_LastPurchaseDate__c      = newOP.PurchaseDate__c;
                    updateContact.KDCE_LastPurchaseChannel__c   = contactChannelByOPType.get(newOP.ProgramType__c);
                    updateContact.KDCE_LastPurchaseId__c        = String.valueOf(newOP.Id);
                }

            }
            contactMap.put(updateContact.Id, updateContact);
        }

        if (contactMap.size() > 0) update contactMap.values();
    }



    /**
     * Offline Program 캔슬이 될 경우, Contact 필드 업데이트 - 2021.04.21 이지현
     * - Contact에 있던 First Purchase Date/Last Purchase Date에 해당하는 주문이 사라질 경우, 그 이전 주문의 Purchase Date 넣어줌
     */
    private void updateContactWhenRefund() {
        System.debug('@@@@@@ updateContactWhenRefund @@@@@@');

        Map<Id, List<KDCE_OfflineProgram__c>> contactByProgram = new Map<Id, List<KDCE_OfflineProgram__c>>();   // Contact별 취소된 주문일자

        List<KDCE_OfflineProgram__c> programList;
        for (KDCE_OfflineProgram__c op : (List<KDCE_OfflineProgram__c>) Trigger.new) {
            KDCE_OfflineProgram__c oldOp = (KDCE_OfflineProgram__c) Trigger.oldMap.get(op.Id);
            if (oldOp?.Status__c != KDCE_GlobalValue.OFF_PG_STATUS_CANCEL && op.Status__c == KDCE_GlobalValue.OFF_PG_STATUS_CANCEL) {

                if (contactByProgram.containsKey(op.Contact__c)) {
                    programList = contactByProgram.get(op.Contact__c);
                } else {
                    programList = new List<KDCE_OfflineProgram__c>();
                }
                programList.add(op);
                contactByProgram.put(op.Contact__c, programList);
            }
        }
        System.debug('=== contactByProgram : ' + contactByProgram);

        Map<Id, Map<String, Object>> purchaseByContact = new Map<Id, Map<String, Object>>();
        Map<String, Object> purchaseMap = new Map<String, Object>();

        List<Contact> contactList = [
                SELECT Id, KDCE_FirstPurchaseDate__c, KDCE_FirstPurchaseChannel__c, KDCE_FirstPurchaseId__c,
                        KDCE_LastPurchaseDate__c, KDCE_LastPurchaseChannel__c, KDCE_LastPurchaseId__c
                FROM Contact
                WHERE Id IN :contactByProgram.keySet()
        ];
        System.debug('=== contactList : ' + contactList);

        // 새로 들어온 취소 주문중에, Contact의 Purchase Date와 일치하는 값이 있는지 확인
        for (Contact contact : contactList) {
            for (KDCE_OfflineProgram__c program : contactByProgram.get(contact.Id)) {
                System.debug('=== program.Id : ' + program.Id);
                System.debug('=== contact.KDCE_FirstPurchaseId__c : ' + contact.KDCE_FirstPurchaseId__c);
                System.debug('=== contact.KDCE_LastPurchaseId__c : ' + contact.KDCE_LastPurchaseId__c);
                if (String.valueOf(program.Id) == contact.KDCE_FirstPurchaseId__c || String.valueOf(program.Id) == contact.KDCE_LastPurchaseId__c) {
                    purchaseByContact.put(contact.Id, null);
                }
            }
        }
        System.debug('=== purchaseByContact : ' + purchaseByContact);
        // Contact과 관련된 연결된 Order, Offline Program, Coupon 가져오기 (Order 주문 취소의 경우니까, Order의 경우만 제외할 Id set 넣어줌)
        // TODO Contact별 가장 나중값 넣는게 나을듯
        Set<Id> contactIds = purchaseByContact.keySet();
        Map<Id, List<KDCE_Order__c>> orderListByCon             = KDCE_ContactService.getOrderByContactMap(contactIds, null);
        Map<Id, List<KDCE_OfflineProgram__c>> programListByCon  = KDCE_ContactService.getProgramByContactMap(contactIds);
        Map<Id, List<KDCE_Coupon__c>> couponListByCon           = KDCE_ContactService.getCouponByContactMap(contactIds);

        System.debug('=== orderListByCon : ' + orderListByCon);
        System.debug('=== programListByCon : ' + programListByCon);
        System.debug('=== couponListByCon : ' + couponListByCon);

        for (Id contactId : purchaseByContact.keySet()) {

            System.debug('=== contactId : ' + contactId);
            purchaseMap = new Map<String, Object>();

            // Order 값 비교
            purchaseByContact = KDCE_ContactService.purchaseOrderMap(purchaseByContact, orderListByCon, contactId);
            System.debug('=== purchaseByContact1 : ' + purchaseByContact);
            purchaseByContact = KDCE_ContactService.purchaseProgramMap(purchaseByContact, programListByCon, contactId);
            System.debug('=== purchaseByContact2 : ' + purchaseByContact);
            purchaseByContact = KDCE_ContactService.purchaseCouponMap(purchaseByContact, couponListByCon, contactId);
            System.debug('=== purchaseByContact3 : ' + purchaseByContact);


        }

        // Contact과 연결되어 있는 값 비교
        Map<Id, Contact> updateContactMap = KDCE_ContactService.getPurchaseResult(purchaseByContact);

        System.debug('=== updateContactMap : ' + updateContactMap);
        if (updateContactMap.size() > 0) update updateContactMap.values();
    }


    /**
     * 쿠폰이 있는 Offline Program 취소시, Coupon History 생성
     * MGM Coupon을 사용한 Offline Program인 경우, MGM Coupon 값도 같이 취소 + Contact God Father 정보도 취소
     */
    private void insertCouponHistoryWhenRefund() {
        System.debug('@@@@@@ updateMGMWhenRefund @@@@@@');
        Set<Id> mgmContacts = new Set<Id>();
        Set<Id> coupons = new Set<Id>();
        Set<Id> contacts = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        List<KDCE_OfflineProgram__c> programList = new List<KDCE_OfflineProgram__c>();

        for (KDCE_OfflineProgram__c program : (List<KDCE_OfflineProgram__c>) Trigger.new) {
            KDCE_OfflineProgram__c oldProgram = (KDCE_OfflineProgram__c) Trigger.oldMap.get(program.Id);
            if (oldProgram.Status__c == KDCE_GlobalValue.OFF_PG_STATUS_COMPLETE && program.Status__c == KDCE_GlobalValue.OFF_PG_STATUS_CANCEL && program.Coupon__c != null) {
                contacts.add(program.Contact__c);
                coupons.add(program.Coupon__c);
                programList.add(program);
            }
        }
        System.debug('=== coupons : ' + coupons);
        System.debug('=== programList : ' + programList);

        // Coupon History 생성
        List<KDCE_CouponHistory__c> historyList = new List<KDCE_CouponHistory__c>();
        KDCE_CouponHistory__c history;
        System.debug('=== programList : ' + programList);
        for (KDCE_OfflineProgram__c program : programList) {
            history = KDCE_CouponService.createCouponHistory(program.Coupon__c, KDCE_GlobalValue.COUPON_HISTORY_TYPE_CANCEL);
            history.ActionChannel__c    = KDCE_GlobalValue.COUPON_HISTORY_CHANNEL_OFFLINE;
            history.Contact__c          = program.Contact__c;
//            history.Order__c            = order.Id;   // TODO Offline Program__c는 필요 없나
            System.debug('=== history : ' + history);
            historyList.add(history);
        }
        System.debug('=== historyList : ' + historyList);

        // Coupon이 MGM Coupon인 경우 Contact God Father null
        for (KDCE_Coupon__c coupon : [SELECT Id, Contact__c FROM KDCE_Coupon__c WHERE Id IN :coupons AND RecordType.Name = 'MGM']) {
            mgmContacts.add(coupon.Contact__c);
        }
        System.debug('=== contacts : ' + mgmContacts);

        for (Contact contact : [SELECT Id, KDCE_GodFather__c FROM Contact WHERE KDCE_GodFather__c IN :mgmContacts AND Id IN :contacts]) {
            contactMap.put(contact.Id, new Contact(Id = contact.Id, KDCE_GodFather__c = null));
        }

        System.debug('=== contactMap : ' + contactMap);
        if (!historyList.isEmpty()) insert historyList;
        if (!contactMap.isEmpty()) update contactMap.values();

    }


    // 렌탈 반품 기준 Asset 필드 변경값
    private Asset setAssetRentalReturn(Id assetId, Id storeDummyId) {
        Asset asset = new Asset();
        asset.Id                         = assetId;
        asset.Status                     = KDCE_GlobalValue.ASSET_STATUS_LOCKED;
        asset.KDCE_DeviceLabelling__c    = null;
        asset.ContactId                  = storeDummyId;
        asset.AccountId                  = null;
        asset.PurchaseDate               = null;
        // 에러나지않기위한 처리
        if (storeDummyId == null) asset.AccountId = System.Label.KDCE_DefaultAccount;

        return asset;
    }

    // 렌탈 후 구매 기준 Asset 필드 변경값
    private Asset setAssetRentalPurchase(Id assetId) {
        Asset asset = new Asset();
        asset.Id                         = assetId;
        asset.Status                     = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
        asset.KDCE_DeviceLabelling__c    = KDCE_GlobalValue.ASSET_LABEL_RENTALPURCHASED;
        asset.PurchaseDate               = System.today();
        asset.CCR_PurchaseChannel__c     = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_DIRECT;

        return asset;

    }
 }