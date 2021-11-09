/****************************************************************************************
  * @filename      : KDCE_Order_tr_Test
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-04-01
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-04-01          i2max_JE Yoon             Create
****************************************************************************************/
@IsTest
private class KDCE_Order_tr_Test {

    //final static String CANCEL_STATUS = '주문취소'; //todo OrderStatus__c 주문 취소 값 정해지면 수정 필요
    final static String CANCEL_STATUS = KDCE_GlobalValue.ORDER_STATUS_CLOSE; //todo OrderStatus__c 주문 취소 값 정해지면 수정 필요
    static KDCE_Order__c order;
    static List<KDCE_CouponHistory__c> couponHistories;
    static KDCE_CouponHistory__c couponHistory;
    static List<Task> tasks;
    static String actionType_Cancel = 'Cancel';

    static void getData(String coupon_DeveloperName, Boolean couponExists) {
        CouponTestDataUtil.getOrder(coupon_DeveloperName, couponExists);
        KDCE_Coupon__c coupon = CouponTestDataUtil.coupon.clone(true);
        order = [SELECT OrderStatus__c FROM KDCE_Order__c LIMIT 1];
        order.OrderStatus__c = CANCEL_STATUS;
        order.Coupon__c = coupon.Id;

        update order;
        System.debug('Order : ' + order);

        order = [SELECT OrderStatus__c, Coupon__c FROM KDCE_Order__c LIMIT 1];
        couponHistories = [SELECT ActionType__c, Order__c FROM KDCE_CouponHistory__c WHERE Coupon__c = :order.Coupon__c AND ActionType__c = :actionType_Cancel LIMIT 1];
//        if (couponExists == true) couponHistory = couponHistories[0];
        tasks = [SELECT Id FROM Task];

    }


    static private void createOrderSet(String orderStatus, String orderReason, String orderType, String couponType) {
        KDCE_Order__c tempOrder = new KDCE_Order__c(
                OrderStatus__c = KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY,
                Contact__c = KDCE_TestUtil.contactMember.Id
        );
        KDCE_Coupon__c coupon = new KDCE_Coupon__c( Type__c = couponType);
        List<SObject> sObjects = new List<SObject>{coupon, tempOrder};
        insert sObjects;

        tempOrder.OrderStatus__c = orderStatus;
        tempOrder.OrderReason__c = orderReason;
        tempOrder.OrderType__c = orderType;
        tempOrder.Coupon__c = coupon.Id;
        tempOrder.ActionChannel__c = 'POS';
        tempOrder.isTargetPurchaseDateUpdate__c = true;
        update tempOrder;
    }

    static private void createOrderSet1(String orderStatus, String orderReason, String orderType, String couponType) {
        KDCE_Order__c tempOrder = new KDCE_Order__c(
                OrderStatus__c = KDCE_GlobalValue.ORDER_STATUS_CLOSE,
                Contact__c = KDCE_TestUtil.contactMember.Id
        );
        insert tempOrder;

        tempOrder.OrderStatus__c = 'complete';
        tempOrder.OrderReason__c = 'forward';
        tempOrder.OrderType__c = 'ZTA';
        tempOrder.ActionChannel__c = 'iqos.com';
        tempOrder.isTargetPurchaseDateUpdate__c = true;
        update tempOrder;
    }

    @IsTest
    static void testCase07() {
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_CLOSE, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_NORMAL, KDCE_GlobalValue.COUPON_TYPE_MGM);
        Test.stopTest();
    }

    @IsTest
    static void testCase08() {
        Test.startTest();
        createOrderSet(KDCE_GlobalValue.ORDER_STATUS_CLOSE, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_NORMAL, KDCE_GlobalValue.COUPON_TYPE_GETINFO);
        createOrderSet1(KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY, KDCE_GlobalValue.ORDER_REASON_FORWARD, KDCE_GlobalValue.ORDER_TYPE_NORMAL, KDCE_GlobalValue.COUPON_TYPE_GETINFO);

        Test.stopTest();
    }

    @IsTest
    static void testUpdateToRefundOrder() {
        KDCE_Order__c order = KDCE_TestBizUtil.order;
        KDCE_Order__c order2 = KDCE_TestBizUtil.order.clone(false);
        order2.OrderReason__c = 'return';
        order2.OriginOrder__c = order.Id;
        insert order2;

        Test.startTest();


        Test.stopTest();
    }
}