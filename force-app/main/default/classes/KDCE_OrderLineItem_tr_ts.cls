/****************************************************************************************
  * @filename      : KDCE_OrderLineItem_tr_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-18
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-06-18             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_OrderLineItem_tr_ts {


    static KDCE_Order__c tempOrder;
    static  KDCE_OrderLineItem__c tempOli ;
    static  Asset tempAsset ;
    static  KDCE_Order__c collectOrder ;
    static  KDCE_OrderLineItem__c collectOli ;
    static  Asset collectAsset ;
    static Id orderId;
    static private void createOrderSet(String orderStatus, String orderReason, String orderType){
        if(orderReason != KDCE_GlobalValue.ORDER_REASON_COLLECT) {
            System.debug('if 안쪽');
            if(tempOrder == null) tempOrder = KDCE_TestBizUtil.getOrder();
            if(tempOli == null) tempOli = KDCE_TestBizUtil.getOrderLineItem(tempOrder.Id);
            //tempOli = KDCE_TestBizUtil.getOrder();

            String tempCodentify = String.valueOf(Integer.valueOf((Math.random() * 1000000)));
            tempOli.OrderStatus__c = orderStatus;
            tempOli.OrderReason__c = orderReason;
            tempOli.OrderType__c = orderType;
            orderId = tempOrder.Id;

            // Asset 생성
            tempAsset = KDCE_TestUtil.assetHolder.clone(false);
            tempAsset.CCR_CodentifyId__c = tempCodentify;
            tempAsset.SerialNumber = tempCodentify;
            tempAsset.ContactId = KDCE_TestUtil.contactMember.Id;


            tempOli.Codentify__c = tempCodentify;
            insert tempAsset;

            tempOrder.Contact__c =  KDCE_TestUtil.contactMember.Id;
            List<SObject> sObjects = new List<SObject>{tempOli, tempOrder};
            update sObjects;

            System.debug('tempAsset :: ' + tempAsset);
            System.debug('tempOli :: ' + tempOli);

        }
        if(orderReason == KDCE_GlobalValue.ORDER_REASON_COLLECT) {
            if(collectOrder == null)    collectOrder = KDCE_TestBizUtil.getOrder();
            if(collectOli == null)      collectOli = KDCE_TestBizUtil.getOrderLineItem(collectOrder.Id);
            //tempOli = KDCE_TestBizUtil.getOrder();


            String tempCodentify = String.valueOf(Integer.valueOf((Math.random() * 1000000)));
            collectOli.OrderStatus__c = orderStatus;
            collectOli.OrderReason__c = orderReason;
            collectOli.OrderType__c = orderType;
            collectOrder.OriginOrder__c = orderId;
            //orderId = collectOrder.Id;

            // Asset 생성
            collectAsset = KDCE_TestUtil.assetHolder.clone(false);
            collectAsset.CCR_CodentifyId__c = tempCodentify;
            collectAsset.ContactId = KDCE_TestUtil.contactMember.Id;

            collectOli.Codentify__c = tempCodentify;
            insert collectAsset;

            List<SObject> sObjects = new List<SObject>{collectOli, collectOrder};
            update sObjects;

            System.debug('collectOli :: ' + collectOli);
            System.debug('tempAsset :: ' + collectAsset);
        }
    }

    static private void updateOrderSet(String orderStatus, String orderReason, String orderType) {
        System.debug('updateOrderSet');
        if(tempOli == null)     createOrderSet('process','forward', orderType);
        if(collectOli == null)  createOrderSet('process','collect', orderType);

        System.debug(tempOli);
        System.debug(collectOli);

        if(orderReason == 'forward') {
            tempOli.OrderStatus__c = orderStatus;
            System.debug(tempOli.Order__c);
        }
        else if(orderReason == 'collect') {
            collectOli.OrderStatus__c = orderStatus;
        }
        collectOrder.OriginOrder__c = orderId;

        List<SObject> sObjects = new List<SObject>{tempOli, collectOli, collectOrder};
        System.debug('tempOrder : ' + tempOrder);
        System.debug('collectOrder : ' + collectOrder);
        System.debug('sObjects :: ' + sObjects);
        update sObjects;

    }
    @IsTest
    static void testWhenPickingZTA1() {
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_NORMAL);
        Test.stopTest();
    }
    @IsTest
    static void testWhenPickingZTA2() {
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_NORMAL);
        Test.stopTest();
    }
   /* @IsTest
    static void testWhenPickingZRN1() {
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_COMPLETE, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_RENTAL);
        String changeTest = KDCE_TestUtil.assetHolder.CCR_CodentifyId__c;
        tempOli.OrderType__c =KDCE_GlobalValue.ORDER_TYPE_RENTAL;
        tempOli.Codentify__c = changeTest;
        update tempOli;

        Test.stopTest();
    }*/

    @IsTest
    static void testWhenPickingZRNNEW1() {
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_COMPLETE, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_RENTALNEW);

        Test.stopTest();
    }

    @IsTest
    static void testWhenPickingRTLBUY() {
        Test.startTest();
        System.debug('tempOli :: ' + tempOli);
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_COMPLETE, KDCE_GlobalValue.ORDER_REASON_RTLFORWARD, KDCE_GlobalValue.ORDER_TYPE_RTLBUY);
        System.debug('tempOli :: ' + tempOli);
        Test.stopTest();
    }

    @IsTest
    static void testWhenPickingZRNPaid() {
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_PAID, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_RENTAL);
        Test.stopTest();
    }

    @IsTest
    static void testWhenPickingTradeIn1() {
        tempOli = null;
        Test.startTest();
        updateOrderSet(KDCE_GlobalValue.ORDER_STATUS_COMPLETE, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_TRADEIN);


        Test.stopTest();
    }

    @IsTest
    static void testWhenPickingTradeIn2() {
        tempOli = null;
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_PENDING, KDCE_GlobalValue.ORDER_REASON_COLLECT, KDCE_GlobalValue.ORDER_TYPE_TRADEIN);
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED, KDCE_GlobalValue.ORDER_REASON_COLLECT, KDCE_GlobalValue.ORDER_TYPE_TRADEIN);
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_CLOSE, KDCE_GlobalValue.ORDER_REASON_COLLECT, KDCE_GlobalValue.ORDER_TYPE_TRADEIN);
        Test.stopTest();
    }

    @IsTest
    static void testWhenPickingQure() {
        tempOli = null;
        Test.startTest();
        updateOrderSet(KDCE_GlobalValue.ORDER_STATUS_COMPLETE, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_QURE);


        Test.stopTest();
    }

    @IsTest
    static void testWhenPickingQure2() {
        tempOli = null;
        Test.startTest();
//        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_PENDING, KDCE_GlobalValue.ORDER_REASON_COLLECT, KDCE_GlobalValue.ORDER_TYPE_QURE);
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED, KDCE_GlobalValue.ORDER_REASON_COLLECT, KDCE_GlobalValue.ORDER_TYPE_QURE);
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_CLOSE, KDCE_GlobalValue.ORDER_REASON_COLLECT, KDCE_GlobalValue.ORDER_TYPE_QURE);
        Test.stopTest();
    }

    @IsTest
    static void testwhenRentalForwardComplete() {
        Test.startTest();
        tempOli = null;
        returnOLIValue(KDCE_GlobalValue.ORDER_STATUS_COMPLETE, KDCE_GlobalValue.ORDER_REASON_RTLFORWARD, KDCE_GlobalValue.ORDER_TYPE_RTLBUY);
        Test.stopTest();
    }



    @IsTest
    static void testWhenReturnReject() {
        tempOli = null;
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_CLOSE, KDCE_GlobalValue.ORDER_REASON_COLLECT, KDCE_GlobalValue.ORDER_TYPE_QURE);

        Test.stopTest();
    }


    @IsTest
    static void testWhenReturnRefund1() {
        tempOli = null;
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED, KDCE_GlobalValue.ORDER_REASON_RETURN, KDCE_GlobalValue.ORDER_TYPE_NORMAL);

        Test.stopTest();
    }
    static private void returnOLIValue(String status, String reason, String type){
        String tempCodentify = String.valueOf(Integer.valueOf((Math.random() * 1000000)));
        tempAsset = new Asset(
                CCR_CodentifyId__c = tempCodentify,
                AccountId = KDCE_TestUtil.account.Id,
                Name = tempCodentify);
        tempOrder=KDCE_TestBizUtil.order;
        tempOrder.Contact__c = KDCE_TestUtil.contactMember.Id;
        update tempOrder;

        KDCE_OrderLineItem__c tempItem = new KDCE_OrderLineItem__c(
                Order__c = tempOrder.Id,
                OrderStatus__c = status,
                OrderReason__c = reason,
                OrderType__c = type,
                Codentify__c = tempCodentify
        );

        List<SObject> sObjects = new List<SObject>{tempAsset, tempItem};
        insert sObjects;
    }
}