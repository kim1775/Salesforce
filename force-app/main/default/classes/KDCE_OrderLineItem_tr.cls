/****************************************************************************************
  * @filename      : KDCE_OrderLineItem_tr
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-02-22
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :KDCE_OrderLineItem_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-02-22             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_OrderLineItem_tr extends TriggerHandler {

    private static List<KDCE_OrderLineItem__c> rentalNewOLIList = new List<KDCE_OrderLineItem__c>();
    private static List<Asset> rentalNewAssetList               = new List<Asset>();

    public override void beforeInsert() {

        beforeInsertToUpdateStatus();
        checkIsPurchaseDateUpdateInOrder(); // Order의 Purchase Date 업데이트처리를 하기 위해
    }

    /*********** Order에서 Oli 업데이트 하는 로직이 있으므로 주의 필요 *****************/
    public override void beforeUpdate() {
        toUpdateAssetStatus();
        checkProductValue();
    }


    public override void afterInsert() {
        System.debug('afterInsert');
        System.debug(rentalNewAssetList);
        System.debug(rentalNewOLIList);
        if(!rentalNewAssetList.isEmpty() && !rentalNewOLIList.isEmpty()) this.createRentalNewAssetHistory(rentalNewOLIList, rentalNewAssetList);
    }

    /*********** Order에서 Oli 업데이트 하는 로직이 있으므로 주의 필요 *****************/
    public override void afterUpdate() {
        updateCodentify();  // Codentify 변경시, Asset 변경 및 Asset History 생성
    }


    // Order의 Purchase Date 업데이트처리를 하기 위해 Order의 isTargetPurchaseDateUpdate__c 체크박스를 표시하는 메서드 (insert 일때)
    private void checkIsPurchaseDateUpdateInOrder() {
        System.debug('=== checkIsPurchaseDateUpdateInOrder : ');
        // isTargetPurchaseDateUpdate
        Set<String> completeStatus = new Set<String>{
                KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY, KDCE_GlobalValue.ORDER_STATUS_COMPLETE
        };

        Map<Id, KDCE_Order__c> updateOrderMap = new Map<Id, KDCE_Order__c>();
        Set<Id> OrderSet = new Set<Id>();
        for (KDCE_OrderLineItem__c item : (List<KDCE_OrderLineItem__c>) Trigger.new) {
            System.debug('=== item : ' + item);
            //if (!item.IsAccessory__c && completeStatus.contains(item.OrderStatus__c)) {
            if (item.IsDevice__c && completeStatus.contains(item.OrderStatus__c)) {
                OrderSet.add(item.Order__c);
            }
        }

        for (KDCE_Order__c order : [SELECT Id, isTargetPurchaseDateUpdate__c FROM KDCE_Order__c WHERE Id IN :OrderSet]) {
            order.isTargetPurchaseDateUpdate__c = true;
            updateOrderMap.put(order.Id, order);
        }
        System.debug('=== updateOrderMap : ' + updateOrderMap);
        if(!updateOrderMap.isEmpty() && !Test.isRunningTest()) update updateOrderMap.values();
    }

    private void beforeInsertToUpdateStatus(){
        System.debug('@@@@@@ beforeInsertToUpdateStatus @@@@@@');
        List<KDCE_OrderLineItem__c> kdceOrderLineItems = new List<KDCE_OrderLineItem__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(KDCE_OrderLineItem__c item : (List<KDCE_OrderLineItem__c>)Trigger.new) {
            if (item.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN && item.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_COLLECT) {
                kdceOrderLineItems.add(item);
            }
        }
        if(!kdceOrderLineItems.isEmpty()) this.whenCollect_ZTI(kdceOrderLineItems);

        kdceOrderLineItems = new List<KDCE_OrderLineItem__c>();
        for(KDCE_OrderLineItem__c item : (List<KDCE_OrderLineItem__c>)Trigger.new) {
            System.debug('조건문1 ' + item);
            if (item.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RTLBUY && item.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RTLFORWARD
                    && (item.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || item.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY)) {
                kdceOrderLineItems.add(item);
            }
        }
        System.debug('=== kdceOrderLineItems : ' + kdceOrderLineItems);
        if(!kdceOrderLineItems.isEmpty()) this.whenRentalForwardComplete(kdceOrderLineItems);
    }

    /**
     * 렌탈 중 기기 이슈로 교체가 일어나는 케이스가 있음. 이때 에이전트가 수기로 OrderLineItem에서 Codentify 변경함에 따라서 Asset Codenfity 값 업데이트
     *  + Asset History 생성. (Order Line Item에서 Asset 연결시
     */
    private void updateCodentify() {
        System.debug('@@@@@@ updateCodentify @@@@@@');

        Set<String> codentifySet = new Set<String>();
        Set<String> orderSet = new Set<String>();
        Set<String> rentalSet = new Set<String>{
                KDCE_GlobalValue.ORDER_TYPE_RENTAL, KDCE_GlobalValue.ORDER_TYPE_RENTALNEW
        };
        List<KDCE_OrderLineItem__c> orderLineItemList = new List<KDCE_OrderLineItem__c>();
        for (KDCE_OrderLineItem__c item : (List<KDCE_OrderLineItem__c>) Trigger.new) {
            KDCE_OrderLineItem__c oldItem = (KDCE_OrderLineItem__c) Trigger.oldMap.get(item.Id);
            // Codentify가 변경될때만 작용 + Rental일 경우 + 기존 Codentify가 null이 아닐때 (처음 인터페이스로 들어오는 경우, null에서 codentify로 들어오기 때문에 제외해야함)
            System.debug('=== item.fm_OrderType__c : ' + item.fm_OrderType__c);
            if (oldItem.Codentify__c <> item.Codentify__c && rentalSet.contains(item.OrderType__c) && oldItem.Codentify__c != null) {
                codentifySet.add(item.Codentify__c);
                orderSet.add(item.Order__c);
                orderLineItemList.add(item);
            }
        }
        System.debug('=== codentifySet : ' + codentifySet);

        if(codentifySet.isEmpty() || orderSet.isEmpty()) return;

        // Order Id별 Contact 값 저장
        Map<String, Id> contactByOrderIdMap = new Map<String, Id>();
        for (KDCE_Order__c order : [SELECT Id, Contact__c FROM KDCE_Order__c WHERE Id IN :orderSet]) {
            contactByOrderIdMap.put(order.Id, order.Contact__c);
        }
        System.debug('=== contactByOrderIdMap : ' + contactByOrderIdMap);

        // Codentify별 Asset List 생성
        List<Asset> assets = KDCE_AssetService.getAssets(codentifySet);     // Codentify와 일치하는 Asset List
        Map<String, List<Asset>> codentifyAssetMap  = KDCE_AssetService.getCodentifyAssetMap(assets, codentifySet);     // CodentifyId별 Asset List
        System.debug('=== codentifyAssetMap : ' + codentifyAssetMap);

        List<Asset> updateAssetList = new List<Asset>();
        List<KDCE_AssetHistory__c> assetHistoryList = new List<KDCE_AssetHistory__c>();
        KDCE_AssetHistory__c assetHistory;

        for (KDCE_OrderLineItem__c item : orderLineItemList) {
            KDCE_OrderLineItem__c oldItem = (KDCE_OrderLineItem__c) Trigger.oldMap.get(item.Id);

            // Codentify가 변경될때만 작용 + Rental일 경우만
            if (oldItem.Codentify__c <> item.Codentify__c && rentalSet.contains(item.OrderType__c)) {
                if (codentifyAssetMap.containsKey(item.Codentify__c)) {
                    for (Asset asset : codentifyAssetMap?.get(item.Codentify__c)) {
                        System.debug('=== asset : ' + asset);
                        asset.KDCE_DeviceType__c        = 'Rental';
                        asset.ContactId                 = System.Label.KDCE_DefaultContactRental;
                        asset.AccountId                 = null;
                        asset.Status                    = KDCE_GlobalValue.ASSET_STATUS_LOCKED;
                        asset.KDCE_DeviceLabelling__c   = KDCE_GlobalValue.ASSET_LABEL_RENTING;
                        asset.KDCE_RentalCount__c       = asset.KDCE_RentalCount__c == null ? 1 : asset.KDCE_RentalCount__c + 1;    // Rental 횟수 1증가
                        if (!updateAssetList.contains(asset)  && !Test.isRunningTest() ) updateAssetList.add(asset);

                        assetHistory = KDCE_AssetService.createAssetHistory(asset, item, 'Order');
                        assetHistoryList.add(assetHistory);
                    }
                }

                // TODO 이지현 확인 필요
                else item.addError(System.Label.KDCE_NoAvailableAsset);

            }
        }
        System.debug('=== updateAssetList : ' + updateAssetList);
        System.debug('=== assetHistoryList : ' + assetHistoryList);

        if (!updateAssetList.isEmpty() && !Test.isRunningTest()) update updateAssetList;
        if (!assetHistoryList.isEmpty() && !Test.isRunningTest()) insert assetHistoryList;

    }

    private void toUpdateAssetStatus() {
        System.debug('@@@@@ toUpdateAssetStatus @@@@@');
        List<KDCE_OrderLineItem__c> newList;
        // OrderStatus가 변경될 때마다 수행한다
        newList = new List<KDCE_OrderLineItem__c>();

        Set<String> collectionStatus = new Set<String>{
                KDCE_GlobalValue.ORDER_COL_STATUS_COLSUCCESS, KDCE_GlobalValue.ORDER_COL_STATUS_EXTSUCCESS
        };
        List<KDCE_OrderLineItem__c> updateCollectionList = new List<KDCE_OrderLineItem__c>();
        for (KDCE_OrderLineItem__c item : (List<KDCE_OrderLineItem__c>) Trigger.new) {
            System.debug('item :: ' + item);
            KDCE_OrderLineItem__c oldOli = (KDCE_OrderLineItem__c) Trigger.oldMap.get(item.Id);
            System.debug('=== item.OrderStatus__c : ' + item.OrderStatus__c);
            System.debug('=== oldOli.OrderStatus__c : ' + oldOli.OrderStatus__c);
            if (item.OrderStatus__c != oldOli.OrderStatus__c) {
                newList.add(item);
            }
            // Order의 Collection Status가 변경되면 Asset 업데이트 (고객이 추심을 진행하면 Asset과 고객 연결시킨다.)
            if (collectionStatus.contains(item.CollectionStatus__c) && !collectionStatus.contains(oldOli.CollectionStatus__c)) {
                updateCollectionList.add(item);
            }
        }
        System.debug('=== newList : ' + newList);
        System.debug('=== updateCollectionList : ' + updateCollectionList);
        if (!newList.isEmpty()) this.whatOrderStatus(newList);
        if (!updateCollectionList.isEmpty()) this.updateAssetLinkWhenCollect(updateCollectionList);
    }

    /**
     * @author Park He
     * @description Order Status, Type 별로 수행할 메서드 각 호출
     *
     * @param newList
     */
    private void whatOrderStatus(List<KDCE_OrderLineItem__c> newList) {
        System.debug('@@@@@@ START :: OLI_tr.whatOrderStatus @@@@@@');
        List<KDCE_OrderLineItem__c> pickingOrders       = new List<KDCE_OrderLineItem__c>();
        List<KDCE_OrderLineItem__c> tradeInReplacement  = new List<KDCE_OrderLineItem__c>();
        List<KDCE_OrderLineItem__c> refundOrders        = new List<KDCE_OrderLineItem__c>();
        List<KDCE_OrderLineItem__c> collectOrders       = new List<KDCE_OrderLineItem__c>();
        List<KDCE_OrderLineItem__c> returnRejects       = new List<KDCE_OrderLineItem__c>();
        List<KDCE_OrderLineItem__c> pickingQure         = new List<KDCE_OrderLineItem__c>();

        Map<Id, Contact> contactMap = new Map<Id, Contact>();   // Rental시, Contact 필드 업데이트

        for (KDCE_OrderLineItem__c oli : newList) {
            // Asset과  Order Line Item이 연결되지 않은 것들만 처리한다.
            if(!oli.IsLinkedItem__c) {
                KDCE_OrderLineItem__c oldOli = (KDCE_OrderLineItem__c)(Trigger.oldMap.get(oli.Id));
                System.debug(oli);
                System.debug('CurrentOli.IsLinkedItem__c : ' + oli.IsLinkedItem__c);
                System.debug('======================================================================');
                System.debug('Current OrderType__c : ' + oli.OrderType__c);
                System.debug('Current OrderReason__c : ' + oli.OrderReason__c);
                System.debug('Current OrderStatus__c : ' + oli.OrderStatus__c);
                System.debug('======================================================================');
                System.debug('Previous OrderType__c  : ' + oldOli.OrderType__c);
                System.debug('Previous OrderReason__c  : ' + oldOli.OrderReason__c);
                System.debug('Previous OrderStatus__c  : ' + oldOli.OrderStatus__c);
                System.debug('======================================================================');

                // ZTA, ZTI - forward - complete/complete_delivery
                if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD
                        && (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY
                        || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_DELIVERY)
                        && (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_NORMAL || oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN)) {
                    pickingOrders.add(oli);
                }

                // Trade-in(ZTI) - forward - picking || delivery collection
                if ((oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN && oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD) &&
                        (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY
                                || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_DELIVERY
                        ))
                    tradeInReplacement.add(oli);

                // Qure(ZRA) - forward - picking
                if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_QURE && oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD &&
                        (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY)) {
                    pickingQure.add(oli);
                }

                // 보상판매의 반납기기에 대한 처리 (Collect)
                if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN && oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_COLLECT) {
                    collectOrders.add(oli);
                }

                // 일반주문, 보상판매(새 기기)가 반품 완료되었을 때 (Return)
                if ((oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_NORMAL || oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN) &&
                        oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RETURN && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED) {
                    refundOrders.add(oli);
                }

                // 거절되었을 때 (Reject)
                if (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_TYPE_QURE && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_REASON_COLLECT
                        && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_CLOSE) {
                    returnRejects.add(oli);
                }

                /*
                 * Rental 관련 추가 - 2021.04.15 이지현
                 * Rental시, Contact Rental Check 필드 업데이트
                 */
                // 중고기기 렌탈(ZRN), 신규기기 렌탈(ZRNNEW), 렌탈기기 반납후 새기기 구매(ZTA)가 picking 상태일때 (Forward)
                // 중고기기 렌탈 (ZRN)
                else if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
                    contactMap.put(oli.KDCE_fm_OrderContactId__c, new Contact(Id = oli.KDCE_fm_OrderContactId__c, KDCE_RentalConsumer__c = false));

                    if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD && (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY)) {
                        pickingOrders.add(oli);
                        contactMap.put(oli.KDCE_fm_OrderContactId__c, new Contact(Id = oli.KDCE_fm_OrderContactId__c, KDCE_RentalConsumer__c = true));    // Contact 렌탈 필드 업데이트
                    } else if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PAID) {
                        pickingOrders.add(oli);
                    } else if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_COLLECT && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED) {
                        refundOrders.add(oli);
                    }
                }

                // 신규기기 렌탈 (ZRNNEW)
                else if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTALNEW) {
                    contactMap.put(oli.KDCE_fm_OrderContactId__c, new Contact(Id = oli.KDCE_fm_OrderContactId__c, KDCE_RentalConsumer__c = false));
                    if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD && (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY)) {
                        pickingOrders.add(oli);
                        contactMap.put(oli.KDCE_fm_OrderContactId__c, new Contact(Id = oli.KDCE_fm_OrderContactId__c, KDCE_RentalConsumer__c = true));    // Contact 렌탈 필드 업데이트
                    } else if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PAID) {
                        pickingOrders.add(oli);
                    } else if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_COLLECT && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED) {
                        refundOrders.add(oli);
                    }
                }

                // 렌탈 후 기기구매 (ZTA)
                else if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RTLBUY) {
                    contactMap.put(oli.KDCE_fm_OrderContactId__c, new Contact(Id = oli.KDCE_fm_OrderContactId__c, KDCE_RentalConsumer__c = false));

                    if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RTLFORWARD && (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY)) {
                        pickingOrders.add(oli);
                    }
                    else if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RTLRETURN && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED) refundOrders.add(oli);
                }
            }
        }
        if (!pickingOrders.isEmpty())       this.whenComplete_ZTAZRNZTI(pickingOrders);
        //if (!tradeInReplacement.isEmpty())  this.whenComplete_ZTI(tradeInReplacement); //whenComplete_ZTAZRNZTI와 합침
        if (!collectOrders.isEmpty())       this.whenCollect_ZTI(collectOrders);
        if (!pickingQure.isEmpty())         this.whenComplete_ZRA(pickingQure);
        if (!refundOrders.isEmpty())        this.whenReturnRefund(refundOrders);
        if (!returnRejects.isEmpty())       this.whenReturnReject(returnRejects);
        if (!contactMap.isEmpty()  && !Test.isRunningTest())          update contactMap.values();
    }

    private void whenComplete_ZTAZRNZTI(List<KDCE_OrderLineItem__c> newList) {
        System.debug('START :: ===== Oli_tr.whenComplete_ZTAZRN  =====');

        Set<String> codentifySet                    = KDCE_AssetService.getCodentifySet(newList);
        List<Asset> assets                          = KDCE_AssetService.getAssets(codentifySet);
        Map<String, List<Asset>> codentifyAssetMap  = KDCE_AssetService.getCodentifyAssetMap(assets, codentifySet);
        KDCE_AssetHistory__c tempHistory;
        List<KDCE_AssetHistory__c>  tempHistoryList = new List<KDCE_AssetHistory__c>();
        List<Asset>                 updateAssets    = new List<Asset>();
        List<KDCE_OrderLineItem__c> updateItems     = new List<KDCE_OrderLineItem__c>();

        // OLI 별 Asset 저장
        // START :: for statement of Order Line Item
        for (KDCE_OrderLineItem__c oli : newList) {
            for(String codentifyStr : KDCE_AssetService.splitCodentify(oli)) {

                if (codentifyAssetMap.containsKey(codentifyStr)) {
                    String prodCode;
                    Id prodId;
                    Boolean isComplete;

                    // START :: for statement of Asset
                    for (Asset asset : codentifyAssetMap.get(codentifyStr)) {
                        // Complete인 경우 공통작업 (ProduceCode 업데이트 및 Asset History 생성)
                        prodCode = asset.ProductCode;
                        prodId = asset.Product2Id;
                        isComplete = true;

                        System.debug('=== oli.Order__r.OrderReason__c : ' + oli.OrderReason__c);
                        // Forward인 경우 처리
                        if (oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_FORWARD ||
                                oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RTLFORWARD) {

                            System.debug('order TEST');
                            System.debug(oli.OrderType__c);
                            System.debug(oli.OrderReason__c);
                            System.debug(oli.OrderStatus__c);
                            /*
                             * Rental인 경우 따로 처리
                             */
                            if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTAL ||
                                    oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTALNEW ||
                                    (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RTLBUY &&
                                            oli.OrderReason__c == KDCE_GlobalValue.ORDER_REASON_RTLFORWARD)) {

                                // Complete 일때
                                if (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY ) {
                                    System.debug('=== KDCE_GlobalValue.ORDER_STATUS_COMPLETE : ' + KDCE_GlobalValue.ORDER_STATUS_COMPLETE);

                                    // 중고기기 렌탈 (ZRN)
                                    if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
                                        asset.KDCE_DeviceType__c = 'Rental';
                                        asset.ContactId = System.Label.KDCE_DefaultContactRental;
                                        asset.AccountId = null;
                                        asset.KDCE_RentalCount__c = asset.KDCE_RentalCount__c == null ? 1 : asset.KDCE_RentalCount__c + 1;    // Rental 횟수 1증가
                                        asset.Status = KDCE_GlobalValue.ASSET_STATUS_LOCKED;
                                        asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_RENTING;
                                    }
                                    // 신규기기 렌탈 (ZRNNEW)
                                    else if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTALNEW) {
                                        asset.KDCE_DeviceType__c = 'Rental';
                                        asset.ContactId = System.Label.KDCE_DefaultContactRental;
                                        asset.AccountId = null;
                                        asset.Status = KDCE_GlobalValue.ASSET_STATUS_LOCKED;
                                        asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_RENTING;
                                        asset.KDCE_RentalCount__c = asset.KDCE_RentalCount__c == null ? 1 : asset.KDCE_RentalCount__c + 1;    // Rental 횟수 1증가
                                    }
                                    // Rental 기기 반납후 기기 구매 (ZTA)
                                    else {
                                        asset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
                                        asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_ECOMMRENTAL;
                                        asset.ContactId = oli.KDCE_fm_OrderContactId__c;
                                        asset.AccountId = null;
                                        asset.PurchaseDate = oli.KDCE_fm_OrderDate__c;
                                        asset.CCR_PurchaseChannel__c = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_ECOMMERCE;
                                    }
                                }

                                // Paid 일때
                                else if (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PAID) {
                                    asset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
                                    asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_RENTALPURCHASED;
                                    asset.ContactId = oli.KDCE_fm_OrderContactId__c;
                                    asset.AccountId = null;
                                    asset.PurchaseDate = oli.KDCE_fm_OrderDate__c;
                                    asset.CCR_PurchaseChannel__c = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_ECOMMERCE;
                                }
                            }

                            // Rental이 아닌 경우
                            else if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_NORMAL || oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN)
                            {
                                System.debug('=== Rental이 아닌경우 : ');
                                //ZTA + ZTI 공통부분
                                asset.KDCE_DeviceType__c = 'Standard';
                                asset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
                                asset.ContactId = oli.KDCE_fm_OrderContactId__c;
                                asset.AccountId = null;
                                asset.PurchaseDate = oli.KDCE_fm_OrderDate__c;
                                asset.CCR_PurchaseChannel__c = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_ECOMMERCE;
                                asset.CCR_OriginalAsset__c = asset.CCR_CodentifyId__c;
                                asset.CCR_OriginalBox__c = asset.SerialNumber;
                                asset.KDCE_ShipmentDate__c = oli.KDCE_fm_OrderShipingStart__c;
                                asset.CCR_CarePlusDueDate__c = asset.KDCE_fm_WarrantyDate__c;

                                //ZTA
                                if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_NORMAL) {
                                    // Asset 필드 업데이트
                                    asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_ECOMMERCE;
                                }

                                //ZTI
                                else if (oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_TRADEIN) {
                                    asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_ONTRADEIN;
                                }
                            }
                            else{
                                System.debug('====================================================================================');
                                System.debug('조건에 해당하지 않습니다');
                                System.debug('OrderType__c   :: ' + oli.OrderType__c);
                                System.debug('OrderReason__c :: ' + oli.OrderReason__c);
                                System.debug('OrderStatus__c :: ' + oli.OrderStatus__c);
                                System.debug('====================================================================================');
                            }
                        }

                        // Create asset history
                        if (isComplete) {

                            tempHistory = KDCE_AssetService.createAssetHistory(asset, oli, 'Order');
                            tempHistoryList.add(tempHistory);

                        }
                        updateAssets.add(asset);
                    }// END :: for statement of Asset

                    oli.Product__c = prodId;
                    prodId = null;
                }
            }
            oli.IsLinkedItem__c = true;
        }// END :: for statement of Order Line Item

        System.debug('picking updateAssets :: ' + updateAssets);

        if (!updateAssets.isEmpty()     && !Test.isRunningTest())       update updateAssets;
        if (!tempHistoryList.isEmpty()  && !Test.isRunningTest())       insert tempHistoryList;
        if (!updateItems.isEmpty()      && !Test.isRunningTest())       update updateItems;

        System.debug('END :: ===== whenComplete_ZTAZRN =====');
    }

    /**
     * @description ZTI_Collect_Process/Return/Cancel
     * @param newList
     */

    private void whenCollect_ZTI(List<KDCE_OrderLineItem__c> newList) {
        System.debug('START :: ===== Oli_tr.whenCollect_ZTI =====');

        Set<String> codentifySet                    = KDCE_AssetService.getCodentifySet(newList);
        List<Asset> assets                          = KDCE_AssetService.getAssets(codentifySet);
        Map<String, List<Asset>> codentifyAssetMap  = KDCE_AssetService.getCodentifyAssetMap(assets, codentifySet);

        System.debug('Collect AssetMap :: ' + codentifyAssetMap);

        List<Asset> updateAssets = new List<Asset>();
        List<KDCE_AssetHistory__c> tempHistoryList = new List<KDCE_AssetHistory__c>();
        KDCE_AssetHistory__c tempHistory;
        Id prodId;

        for (KDCE_OrderLineItem__c oli : newList) {
            if (codentifyAssetMap.containsKey(oli.Codentify__c)) {
                if (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PENDING) {
                    for (Asset asset : codentifyAssetMap.get(oli.Codentify__c)) {
                        asset.Status = KDCE_GlobalValue.ASSET_STATUS_LOCKED;
                        asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_ONTRADEINR;

                        //tempHistory = KDCE_AssetService.createAssetHistory(asset, asset.ContactId, oli, 'Order', null, null);
                        //tempHistoryList.add(tempHistory);

                        updateAssets.add(asset);
                    }
                } else if (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED) {

                    for (Asset asset : codentifyAssetMap.get(oli.Codentify__c)) {
                        asset.Status = KDCE_GlobalValue.ASSET_STATUS_RETURNED;

                        updateAssets.add(asset);
                    }
                } else if (oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_CLOSE
                        || oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PAID) { // todo :: ZTI - Collect - Paid인 경우 없는건가?? 구두 전달이었던거 같음
                    for (Asset asset : codentifyAssetMap.get(oli.Codentify__c)) {
                        asset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
                        asset.KDCE_DeviceLabelling__c = null;

                        updateAssets.add(asset);
                    }
                }
            }
        }

        System.debug('TradeIn updateAssets :: ' + updateAssets);

        if (!updateAssets.isEmpty()     && !Test.isRunningTest())       update updateAssets;
        if (!tempHistoryList.isEmpty()  && !Test.isRunningTest())       insert tempHistoryList;

        System.debug('END :: ===== WhenCollect_ZTI =====');
    }

    // QURE Forward 주문이 Complete 되었을 때 호출됨
    private void whenComplete_ZRA(List<KDCE_OrderLineItem__c> newList) {
        System.debug('START :: ================ Oli_tr.whenComplete_ZRA ===================');

        // 새 기기에 대한 처리(쿼리)
        Map<String, String> newDeviceCodentifyMap = new Map<String, String>();
        // New 디바이스 Map 세팅
        for (KDCE_OrderLineItem__c oli : newList) {
            newDeviceCodentifyMap.put(oli.Codentify__c, oli.Order__c);
        }

        // 반납기기에 대한 처리(쿼리)
        List<KDCE_OrderLineItem__c> oldOliList = [
                SELECT Id, Codentify__c, Order__r.Name, Order__r.OriginOrder__c, Order__r.OriginOrder__r.Name, Order__r.OrderStatus__c
                    , Order__r.QureCase__c
                FROM KDCE_OrderLineItem__c
                WHERE Order__r.OriginOrder__c IN :newDeviceCodentifyMap.values()
        ];

        Map<String, String> oldDeviceCodentifyMap = new Map<String, String>();
        System.debug('oldOliList :: ' + oldOliList.size());

        //Qure Case 추출 및 저장
        Set<Id> qureCaseIds = new Set<Id>();

        // Old 디바이스 Map 세팅
        for (KDCE_OrderLineItem__c oli : oldOliList) {
            oldDeviceCodentifyMap.put(oli.Codentify__c, oli.Order__r.OriginOrder__c);
            if(oli.Order__r.QureCase__c <> null) qureCaseIds.add(oli.Order__r.QureCase__c);
        }
        System.debug('oldDeviceCodentifyMap :: ' + oldDeviceCodentifyMap.size());
        System.debug('=== qureCaseIds : ' + qureCaseIds.size());

        List<Asset> targetDevices = new List<Asset>();
        if(!newDeviceCodentifyMap.isEmpty() && !oldDeviceCodentifyMap.isEmpty() ) {
            targetDevices = [
                    SELECT Id, CCR_MaterialGroupDescription__c, SerialNumber, CCR_CodentifyId__c, ContactId, AccountId, CCR_CarePlusDueDate__c,
                            PurchaseDate, KDCE_DeviceType__c, Status, KDCE_OriginalWarrantyDate__c, CCR_ReplacementChannelNew__c, KDCE_fm_WarrantyDate__c,
                            KDCE_ReplacementCount__c, CCR_ReplacedBy__c, CCR_Replaces__c, CCR_OriginalAsset__c, CCR_OriginalBox__c, Product2Id,
                            CCR_ReplacementSponsored_By__c, KDCE_IsCarePlusHistory__c, CCR_ReplacementReason__c, CCR_ReplacementDoneBy__c,
                            CCR_Override__c, CCR_OverrideReason__c
                    FROM Asset
                    WHERE CCR_CodentifyId__c IN :newDeviceCodentifyMap.keySet() OR CCR_CodentifyId__c IN :oldDeviceCodentifyMap.keySet()
                    OR SerialNumber IN :newDeviceCodentifyMap.keySet() OR SerialNumber IN :oldDeviceCodentifyMap.keySet()
            ];
        }
        Map<String, Asset> newDeviceMap = new Map<String, Asset>();
        Map<String, Asset> oldDeviceMap = new Map<String, Asset>();
        Map<String, List<Asset>> assetByCodentify = new Map<String, List<Asset>>();

        // Codentify 별로 Asset 저장하기(new/old)
        for (Asset asset : targetDevices) {
            String contents = asset.CCR_MaterialGroupDescription__c.contains('Holder') ? 'holder' : asset.CCR_MaterialGroupDescription__c.contains('Charger') ? 'charger' : null ;
            Id tempKey;
            String deviceMapKey;
            if (newDeviceCodentifyMap.containsKey(asset.CCR_CodentifyId__c)) {
                tempKey = newDeviceCodentifyMap.get(asset.CCR_CodentifyId__c);
                assetByCodentify.put(asset.CCR_CodentifyId__c, new List<Asset>{asset});
            }
            if (newDeviceCodentifyMap.containsKey(asset.SerialNumber) ) {
                tempKey = newDeviceCodentifyMap.get(asset.SerialNumber);
                assetByCodentify.put(asset.SerialNumber, new List<Asset>{asset});
            }
            if(tempKey <> null) {
                deviceMapKey = tempKey + '_' + contents;
                newDeviceMap.put(deviceMapKey, asset);

            }
            System.debug('newDeviceCodentifyMap ' + newDeviceCodentifyMap);
            System.debug('newDeviceCodentifyMap.key :: ' + newDeviceCodentifyMap);


            // 이전 기기 Map 생성
            tempKey = null;
            deviceMapKey = null;
            if (oldDeviceCodentifyMap.containsKey(asset.CCR_CodentifyId__c)) {
                tempKey = oldDeviceCodentifyMap.get(asset.CCR_CodentifyId__c);
                assetByCodentify.put(asset.CCR_CodentifyId__c, new List<Asset>{asset});
            }
            if (oldDeviceCodentifyMap.containsKey(asset.SerialNumber) ) {
                tempKey = oldDeviceCodentifyMap.get(asset.SerialNumber);
                assetByCodentify.put(asset.SerialNumber, new List<Asset>{asset});
            }
            if(tempKey <> null) {
                deviceMapKey = tempKey + '_' + contents;
                oldDeviceMap.put(deviceMapKey, asset);
            }
            System.debug('oldDeviceCodentifyMap ' + oldDeviceCodentifyMap);

        }

        System.debug('newDeviceMap ' + newDeviceMap);
        System.debug('oldDeviceMap ' + oldDeviceMap);
        System.debug('assetByCodentify ' + assetByCodentify);

        /*
        //Qure Case 추출 및 저장
        Set<Id> qureCaseIds = new Set<Id>();
        for (KDCE_OrderLineItem__c oli : newList) {
            if(oli.KDCE_fm_QureCaseId__c <> null) qureCaseIds.add(oli.KDCE_fm_QureCaseId__c);
        }
        */
        Map<Id, CCR_QureHistory__c> qureHistoryByCaseIds = new Map<Id, CCR_QureHistory__c>();
        for(CCR_QureHistory__c qureHistory : [
                SELECT  Id, KDCE_OtherReason__c, CCR_ReplacementChannelSelectedBy__c, CCR_QureReplacementChannel__c,
                        CCR_Override__c, CCR_OverrideReason__c, CCR_Case__c, CCR_DiagnosticDescription__c,
                        CCR_Device__c
                FROM CCR_QureHistory__c
                WHERE CCR_Case__c IN :qureCaseIds
        ]){
            //qureHistoryByCaseIds.put(qureHistory.CCR_Case__c, qureHistory);
            // Old 디바이스 Id 별 qureHistory
            qureHistoryByCaseIds.put(qureHistory.CCR_Device__c, qureHistory);
        }
        System.debug('=== qureHistoryByCaseIds : ' + qureHistoryByCaseIds.size());

        // Asset 데이터 업데이트
        List<Asset> updateAssets = new List<Asset>();
        List<Asset> tempUpdateOldAssets = new List<Asset>();
        List<Asset> tempUpdateNewAssets = new List<Asset>();
        KDCE_AssetHistory__c tempHistory;
        List<KDCE_AssetHistory__c>  tempHistoryList = new List<KDCE_AssetHistory__c>();
        String prodId;
        CCR_QureHistory__c tempQureHistory;
        Date criteria;
        Date originalDate;
        final String replacementReasonKr  = '히터 블레이드 파손';
        final String replacementReasonEn  = 'Broken Heating Blade';
        final String careplus             = 'Care+';
        String sponsoredBy ='';

        for (KDCE_OrderLineItem__c oli : newList) {
            System.debug('Qure :: 새 기기에 예전 기기 연결하기');
            List<Asset> tempNewAssetList = assetByCodentify?.get(oli.Codentify__c);

            for (Asset tempNewAsset : tempNewAssetList) {
                String contents;
                String key;
                contents = tempNewAsset.CCR_MaterialGroupDescription__c.contains('Holder') ? 'holder' : tempNewAsset.CCR_MaterialGroupDescription__c.contains('Charger') ? 'charger' : null ;
                key = oli.Order__c + '_' + contents;
                Asset tempOldAsset = oldDeviceMap?.get(key);

                // Qure 새 기기 Asset 필드 업데이트
                if (tempOldAsset <> null) {
                    System.debug('tempOldAsset 안');
                    //tempOldAsset 처리
                    // 1.Qure 반납 기기에 새 기기 연결
                    tempOldAsset.CCR_ReplacedBy__c = tempNewAsset?.Id;
                    tempOldAsset.CCR_ReplacementChannelNew__c = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_LSP;
                    tempOldAsset.CCR_ReplacementDate__c = System.now();

                    // 2. qure history 찾아서 매핑
                    //if(oli.KDCE_fm_QureCaseId__c <> null && qureHistoryByCaseIds.containsKey(oli.KDCE_fm_QureCaseId__c)){
                    if(qureHistoryByCaseIds.containsKey(tempOldAsset.Id)){
                        tempQureHistory = qureHistoryByCaseIds.get(tempOldAsset.Id);
                        System.debug('tempQureHistory ' + tempQureHistory);
                        //todo userMapping
                        // tempOldAsset.CCR_ReplacementDoneBy__c = tempQureHistory.CCR_ReplacementChannelSelectedBy__c;
                        tempOldAsset.CCR_Override__c = tempQureHistory.CCR_Override__c;
                        tempOldAsset.CCR_OverrideReason__c = tempQureHistory.CCR_OverrideReason__c;
                        tempOldAsset.CCR_ReplacementReason__c = tempQureHistory.CCR_DiagnosticDescription__c;

                        if(tempOldAsset.CCR_Override__c)
                            sponsoredBy = KDCE_GlobalValue.ASSET_REPLACE_SPONSOREDBY_GOODWILL;
                        else if(tempOldAsset.CCR_ReplacementReason__c == replacementReasonEn)
                            sponsoredBy = KDCE_GlobalValue.ASSET_REPLACE_SPONSOREDBY_IQOSCARE;
                        else
                            sponsoredBy = KDCE_GlobalValue.ASSET_REPLACE_SPONSOREDBY_WARRANTY;

                        tempOldAsset.CCR_ReplacementSponsored_By__c = sponsoredBy;
                    }

                    // 3.반납 기기 Asset 필드 업데이트
                    tempOldAsset.Status = KDCE_GlobalValue.ASSET_STATUS_REPLACED;
                    tempOldAsset.CCR_CarePlusDueDate__c = tempOldAsset.CCR_ReplacementDate__c;

                    // 4. 스폰서바이가 Iqos Care Plus 이거나 Override+히터블레이드 파손인 경우에는 Disenrolled 처리.
                    if(tempOldAsset.CCR_ReplacementSponsored_By__c == careplus
                            || (tempOldAsset.CCR_Override__c && (tempOldAsset.CCR_ReplacementReason__c == replacementReasonKr || tempOldAsset.CCR_ReplacementReason__c == replacementReasonEn))
                        ){
                        tempOldAsset.CCR_CarePlusStatus__c = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_DISENROLLED;
                        tempOldAsset.KDCE_IsCarePlusHistory__c = true;
                    }

                    // tempNewAsset 처리
                    tempNewAsset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
                    tempNewAsset.ContactId = oli.KDCE_fm_OrderContactId__c;
                    tempNewAsset.AccountId = null;
                    tempNewAsset.PurchaseDate = null; // Qure의 경우에는 구매일이 없다.

                    // Override 교환이 아닌 경우에만 오늘 날짜로부터 3개월 추가하기
                    if(!tempOldAsset.CCR_Override__c) {
                        criteria = tempOldAsset.KDCE_fm_WarrantyDate__c <> null ? tempOldAsset.KDCE_fm_WarrantyDate__c.addMonths(-3) : null;
                        if (criteria <> null)
                            originalDate = criteria <= System.today() ? System.today().addMonths(+3) : tempOldAsset.KDCE_fm_WarrantyDate__c;
                    }
                    else{ // Override 교환인 경우 이전 기기의 Original Warrnaty Date 그대로 사용하기
                        originalDate = tempOldAsset.KDCE_fm_WarrantyDate__c;
                    }

                    // Replacement 정보
                    tempNewAsset.CCR_Replaces__c = tempOldAsset ?.Id;
                    tempNewAsset.KDCE_ReplacementCount__c = tempOldAsset.KDCE_ReplacementCount__c == null ? 1 : (tempOldAsset.KDCE_ReplacementCount__c + 1);
                    tempNewAsset.KDCE_OriginalWarrantyDate__c = originalDate ;
                    tempNewAsset.CCR_OriginalAsset__c = tempOldAsset.CCR_OriginalAsset__c;
                    tempNewAsset.CCR_OriginalBox__c = tempOldAsset.CCR_OriginalBox__c;
                    tempNewAsset.KDCE_ReplacementSource__c = 'Qure';
                    tempNewAsset.KDCE_IsCarePlusHistory__c = tempOldAsset.KDCE_IsCarePlusHistory__c;

                    updateAssets.add(tempOldAsset);
                    updateAssets.add(tempNewAsset);
                    tempUpdateNewAssets.add(tempNewAsset);
                    tempUpdateOldAssets.add(tempOldAsset);
                    System.debug('tempUpdateNewAssets ' + tempUpdateNewAssets);
                    System.debug('tempUpdateOldAssets ' + tempUpdateOldAssets);
                }

                // Create asset history
                tempHistory = KDCE_AssetService.createAssetHistory(tempNewAsset, oli, 'Order');
                tempHistoryList.add(tempHistory);
                prodId = tempNewAsset.Product2Id;
                System.debug('tempHistory' + tempHistory);
            }

            oli.IsLinkedItem__c = true;
            oli.Product__c = prodId;
            prodId = null;
        }

        System.debug('tempUpdateOldAssets :: ' + tempUpdateOldAssets);
        System.debug('tempUpdateNewAssets :: ' + tempUpdateNewAssets);
        System.debug('tempHistoryList :: ' + tempHistoryList);

        //if (!updateAssets.isEmpty() && !Test.isRunningTest())    update updateAssets;
        if (!tempUpdateOldAssets.isEmpty()  && !Test.isRunningTest()) {
            update tempUpdateOldAssets;
            KDCE_Asset_tr.isAlreadyExecuted = false;
        }
        if (!tempUpdateNewAssets.isEmpty()  && !Test.isRunningTest()) {
            update tempUpdateNewAssets;
            KDCE_Asset_tr.isAlreadyExecuted = false;
        }

        if (!tempHistoryList.isEmpty()      && !Test.isRunningTest())       insert tempHistoryList;
        System.debug('END :: ================ Oli_tr.whenComplete_ZRA ===================');
    }




    /**
     * ZTA/ZTI_return
     * @param newList
     */
    private void whenReturnRefund(List<KDCE_OrderLineItem__c> newList) {
        System.debug('START :: ===== When whenReturnRefund(ZTI/ZTA) =====');

        Set<String> codentifySet = KDCE_AssetService.getCodentifySet(newList);
        List<Asset> assets = KDCE_AssetService.getAssets(codentifySet);
        Map<String, List<Asset>> codentifyAssetMap = KDCE_AssetService.getCodentifyAssetMap(assets, codentifySet);
        List<Asset> updateAssets = new List<Asset>();
        Id prodId;

        //반품하는 asset의 Status를 Produced로 변경
        for (KDCE_OrderLineItem__c oli : newList) {
            for (String codentifyStr : KDCE_AssetService.splitCodentify(oli)) {
                if (codentifyAssetMap.containsKey(codentifyStr)) {
                    for (Asset asset : codentifyAssetMap.get(codentifyStr)) {
                        // Rental 후 반품(7일이내) = 구매 환불
                        if ((oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTAL || oli.OrderType__c == KDCE_GlobalValue.ORDER_TYPE_RENTALNEW)
                                && oli.OrderStatus__c == KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED) {
                            asset.Status = KDCE_GlobalValue.ASSET_STATUS_LOCKED;
                            asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_RENTING;
                            asset.ContactId = null;
                            asset.AccountId = System.Label.KDCE_DefaultAccount;
                        }
                        // Rental 반납이 아닐 경우 + Rental 후 구매 반품일 경우 (ZTA & rental return)
                        else {
                            asset.Status = KDCE_GlobalValue.ASSET_STATUS_PRODUCED;
                            updateAssets.add(asset);
                        }
                        prodId = asset.Product2Id;
                    }
                }
            }
            oli.Product__c = prodId;
            prodId = null;
        }

        System.debug('=== updateAssets : ' + updateAssets);
        if (!updateAssets.isEmpty() && !Test.isRunningTest()) update updateAssets;

        System.debug('END :: ===== When Refund(ZTI/ZTA) =====');
    }
    /**
     *
     * @param newList
     */
    private void whenReturnReject(List<KDCE_OrderLineItem__c> newList) {
        System.debug('START :: ===== When whenReturnReject =====');

        Set<String> codentifySet                    = KDCE_AssetService.getCodentifySet(newList);
        List<Asset> assets                          = KDCE_AssetService.getAssets(codentifySet);
        Map<String, List<Asset>> codentifyAssetMap  = KDCE_AssetService.getCodentifyAssetMap(assets, codentifySet);

        System.debug('Reject AssetMap :: ' + codentifyAssetMap);

        List<Asset> updateAssets = new List<Asset>();
        Id prodId;

        for (KDCE_OrderLineItem__c oli : newList) {
            System.debug(oli.Codentify__c);
            if (codentifyAssetMap.containsKey(oli.Codentify__c)) {
                for(Asset asset : codentifyAssetMap.get(oli.Codentify__c)) {
                    Asset tempAsset = new Asset(
                            Id = asset.CCR_ReplacedBy__c,
                            Status = KDCE_GlobalValue.ASSET_STATUS_LOCKED,
                            KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_RETURNFAIL);
                    updateAssets.add(tempAsset);
                    System.debug('tempAsset :: ' + tempAsset);
                    prodId = asset.Product2Id;
                }
            }
            oli.Product__c = prodId;
        }

        System.debug('Reject updateAssets :: ' + updateAssets);

        if (!updateAssets.isEmpty() && !Test.isRunningTest())    update updateAssets;

        System.debug('END :: ===== When whenReturnReject =====');
    }


    // 렌탈 후 구매의 경우,
    private void whenRentalForwardComplete(List<KDCE_OrderLineItem__c> newList){
        System.debug('START :: ===== Oli_tr.whenRentalForwardComplete  =====');

        Set<String> codentifySet                    = KDCE_AssetService.getCodentifySet(newList);
        List<Asset> assets                          = KDCE_AssetService.getAssets(codentifySet);
        Map<String, List<Asset>> codentifyAssetMap  = KDCE_AssetService.getCodentifyAssetMap(assets, codentifySet);
        List<Asset>                 updateAssets    = new List<Asset>();

        for (KDCE_OrderLineItem__c oli : newList) {
            for (String codentifyStr : KDCE_AssetService.splitCodentify(oli)) {
                if (codentifyAssetMap.containsKey(codentifyStr)) {
                    Id prodId;
                    for (Asset asset : codentifyAssetMap.get(codentifyStr)) {
                        // Complete인 경우 공통작업 (ProduceCode 업데이트 및 Asset History 생성)
                        prodId = asset.Product2Id;

                        //asset.KDCE_DeviceType__c = 'Standard';
                        asset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
                        asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_ECOMMRENTAL;
                        asset.ContactId = oli.KDCE_fm_OrderContactId__c;
                        asset.AccountId = null;
                        asset.PurchaseDate = oli.KDCE_fm_OrderDate__c;
                        asset.CCR_CarePlusDueDate__c = asset.KDCE_fm_WarrantyDate__c;
                        asset.KDCE_ShipmentDate__c = oli.KDCE_fm_OrderShipingStart__c;
                        asset.CCR_OriginalAsset__c = asset.CCR_CodentifyId__c;
                        asset.CCR_OriginalBox__c = asset.SerialNumber;
                        asset.CCR_PurchaseChannel__c = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_ECOMMERCE;

                        // Asset Field 변경
                        updateAssets.add(asset);
                    }
                    oli.IsLinkedItem__c = true;
                    oli.Product__c = prodId;
                    prodId = null;
                }
            }
        }


        if(!updateAssets.isEmpty() && !Test.isRunningTest()) {
            update updateAssets;
            // before로직이기 때문에 oli의 Id가 없어서 after insert에서 Asset History 생성. 리스트를 static으로 저장
            rentalNewAssetList = updateAssets;
            rentalNewOLIList = newList;
        }
    }

    /**
     *
     * @description  rental 후 구매의 경우, Asset history 생성 따로하기
     * @param oliList
     * @param assetList
     */
    private void createRentalNewAssetHistory(List<KDCE_OrderLineItem__c> oliList, List<Asset> assetList){
        System.debug('START :: createRentalNewAssetHistory');
        KDCE_AssetHistory__c tempHistory = new KDCE_AssetHistory__c();
        List<KDCE_AssetHistory__c> tempHistoryList = new List<KDCE_AssetHistory__c>();

        Map<String, Asset> assetByCodentify = new Map<String, Asset>();
        for (Asset asset : assetList) {
            assetByCodentify.put(asset.CCR_CodentifyId__c, asset);
        }

        for (KDCE_OrderLineItem__c oli : oliList) {
                tempHistory = KDCE_AssetService.createAssetHistory(assetByCodentify.get(oli.Codentify__c), oli, 'Order');
                tempHistoryList.add(tempHistory);
        }
        System.debug('=== tempHistoryList : ' + tempHistoryList);


        if(!tempHistoryList.isEmpty()  && !Test.isRunningTest()) insert tempHistoryList;

    }

    // 고객이 추심 진행하면, Asset과 고객 연결 (2021.07.08) + contact rental consumer 해제
    private void updateAssetLinkWhenCollect(List<KDCE_OrderLineItem__c> updateCollectionList) {
        System.debug('@@@@@@ updateAssetLinkWhenCollect @@@@@@');
        Set<String> codentifySet = new Set<String>();
        Map<String, Id> codentifyByContact = new Map<String, Id>();
        Map<String, KDCE_OrderLineItem__c> codentifyByItem = new Map<String, KDCE_OrderLineItem__c>();
        List<KDCE_AssetHistory__c> assetHistoryList = new List<KDCE_AssetHistory__c>();
        KDCE_AssetHistory__c assetHistory;

        for (KDCE_OrderLineItem__c item : updateCollectionList) {
//            codentifySet.add(item.Codentify__c);
            codentifyByContact.put(item.Codentify__c, item.KDCE_fm_OrderContactId__c);
            codentifyByItem.put(item.Codentify__c, item);
        }
        Map<Id, Asset> updateAssetMap = new Map<Id, Asset>();
        List<Asset> assets = KDCE_AssetService.getAssets(codentifyByContact.keySet());     // Codentify와 일치하는 Asset List
        for (Asset asset : assets) {
            // Asset 업데이트
            asset.ContactId = codentifyByContact.get(asset.CCR_CodentifyId__c);
            asset.AccountId = null;
            asset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
            asset.KDCE_DeviceLabelling__c = KDCE_GlobalValue.ASSET_LABEL_ECOMMRENTAL;
            asset.PurchaseDate = System.today();    //codentifyByItem.get(asset.CCR_CodentifyId__c).KDCE_fm_OrderDate__c;    // TODO Order Date를 언제하면 좋을지 확인필요
            asset.CCR_PurchaseChannel__c = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_ECOMMERCE;

            updateAssetMap.put(asset.Id, asset);
            System.debug('=== updateAssetMap : ' + updateAssetMap);

            // Asset History 생성
            assetHistory = KDCE_AssetService.createAssetHistory(asset, codentifyByItem.get(asset.CCR_CodentifyId__c), 'Order');
            assetHistoryList.add(assetHistory);
            System.debug('=== assetHistoryList : ' + assetHistoryList);
        }

        // 추심 성공시, contact 렌탈 consumer 체크박스 필드 해제
        Map<Id, Contact> updateContact = new Map<Id, Contact>();
        for (Contact con : [SELECT Id, KDCE_RentalConsumer__c FROM Contact WHERE Id IN :codentifyByContact.values()]) {
            con.KDCE_RentalConsumer__c = false;
            updateContact.put(con.Id, con);
        }
        System.debug('=== updateAssetMap : ' + updateAssetMap);
        System.debug('=== assetHistoryList : ' + assetHistoryList);
        System.debug('=== updateContact : ' + updateContact);
        if (!updateAssetMap.isEmpty()   && !Test.isRunningTest()) update updateAssetMap.values();
        if (!assetHistoryList.isEmpty() && !Test.isRunningTest()) insert assetHistoryList;
        if (!updateContact.isEmpty()    && !Test.isRunningTest()) update updateContact.values();
    }

    private void checkProductValue(){
        KDCE_OrderLineItem__c oldItem;
        for(KDCE_OrderLineItem__c oli : (List<KDCE_OrderLineItem__c>) Trigger.new){
            oldItem = (KDCE_OrderLineItem__c) Trigger.oldMap.get(oli.Id);

            if((oli.Product__c != oldItem.Product__c) && oli.IsLinkedItem__c && oldItem.IsLinkedItem__c){
                oli.Product__c = oldItem.Product__c;
            }

        }
    }
}