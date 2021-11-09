/****************************************************************************************
  * @filename      : KDCE_ContactService_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-14 오후 2:31
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
    0.1     2021-06-14 오후 2:31     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_ContactService_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> orders = new Set<Id>();
        Set<Id> offlinePrograms = new Set<Id>();
        Set<Id> coupons = new Set<Id>();

        List<KDCE_Order__c> kdceOrders = new List<KDCE_Order__c>();
        List<KDCE_OfflineProgram__c> kdceOfflinePrograms = new List<KDCE_OfflineProgram__c>();
        List<KDCE_Coupon__c> kdceCoupons = new List<KDCE_Coupon__c>();

        Contact contact = KDCE_TestUtil.contactMember;
        KDCE_Order__c order = KDCE_TestBizUtil.order;
        KDCE_OfflineProgram__c program = KDCE_TestBizUtil.offlineProgram;
        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;

        order.OrderDate__c = System.now();
        program.PurchaseDate__c = System.today();
        coupon.UsedDate__c = System.now();

        update order;
        update program;
        update coupon;

        // Set
        contactIds.add(contact.Id);
        orders.add(order.Id);
        offlinePrograms.add(program.Id);
        coupons.add(coupon.Id);

        // List
        kdceOrders.add(order);
        kdceOfflinePrograms.add(program);
        kdceCoupons.add(coupon);

        Map<Id, Map<String, Object>> purchaseByContact = new Map<Id, Map<String, Object>>();
        Map<String, Object> purchaseBy = new Map<String, Object>();
        purchaseByContact.put(contact.Id, null);

        Map<Id, List<KDCE_Order__c>> orderListByCon = new Map<Id, List<KDCE_Order__c>>();
        Map<Id, List<KDCE_OfflineProgram__c>> programByCon = new Map<Id, List<KDCE_OfflineProgram__c>>();
        Map<Id, List<KDCE_Coupon__c>> couponByCon = new Map<Id, List<KDCE_Coupon__c>>();
        orderListByCon.put(contact.Id, kdceOrders);
        programByCon.put(contact.Id, kdceOfflinePrograms);
        couponByCon.put(contact.Id, kdceCoupons);

        System.debug('=== purchaseByContact : ' + purchaseByContact);
        KDCE_ContactService.getOrderByContactMap(contactIds, orders);
        KDCE_ContactService.getProgramByContactMap(contactIds);
        KDCE_ContactService.getCouponByContactMap(contactIds);
        KDCE_ContactService.purchaseOrderMap(purchaseByContact, orderListByCon, contact.Id);
        KDCE_ContactService.purchaseProgramMap(purchaseByContact, programByCon, contact.Id);
        KDCE_ContactService.purchaseCouponMap(purchaseByContact, couponByCon, contact.Id);

        purchaseBy.put('FirstPurchaseDate', null);
        purchaseBy.put('LastPurchaseDate', null);
        purchaseByContact.put(contact.Id, purchaseBy);
        KDCE_ContactService.getPurchaseResult(purchaseByContact);

    }

    @IsTest
    static void testBehavior2() {
        List<KDCE_Order__c> kdceOrders = new List<KDCE_Order__c>();
        List<KDCE_OfflineProgram__c> kdceOfflinePrograms = new List<KDCE_OfflineProgram__c>();
        List<KDCE_Coupon__c> kdceCoupons = new List<KDCE_Coupon__c>();

        Contact contact = KDCE_TestUtil.contactMember;
        KDCE_Order__c order = KDCE_TestBizUtil.order;
        KDCE_OfflineProgram__c program = KDCE_TestBizUtil.offlineProgram;
        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;

        order.OrderDate__c = System.now();
        program.PurchaseDate__c = System.today();
        coupon.UsedDate__c = System.now();

        update order;
        update program;
        update coupon;

        // List
        kdceOrders.add(order);
        kdceOfflinePrograms.add(program);
        kdceCoupons.add(coupon);

        Map<Id, List<KDCE_Order__c>> orderListByCon = new Map<Id, List<KDCE_Order__c>>();
        Map<Id, List<KDCE_OfflineProgram__c>> programByCon = new Map<Id, List<KDCE_OfflineProgram__c>>();
        Map<Id, List<KDCE_Coupon__c>> couponByCon = new Map<Id, List<KDCE_Coupon__c>>();
        orderListByCon.put(contact.Id, kdceOrders);
        programByCon.put(contact.Id, kdceOfflinePrograms);
        couponByCon.put(contact.Id, kdceCoupons);

        Map<Id, Map<String, Object>> purchaseByContact2 = new Map<Id, Map<String, Object>>();
        Map<String, Object> purchaseBy2 = new Map<String, Object>();
        purchaseByContact2.put(contact.Id, null);
        purchaseBy2.put('FirstPurchaseDate', System.now().addMonths(1));
        purchaseBy2.put('LastPurchaseDate', System.now().addMonths(-1));
        purchaseByContact2.put(contact.Id, purchaseBy2);
        System.debug('=== purchaseByContact2 : ' + purchaseByContact2);

        KDCE_ContactService.purchaseOrderMap(purchaseByContact2, orderListByCon, contact.Id);
        KDCE_ContactService.purchaseProgramMap(purchaseByContact2, programByCon, contact.Id);
        KDCE_ContactService.getPurchaseResult(purchaseByContact2);
    }


    @IsTest
    static void testBehavior3() {
        List<KDCE_Coupon__c> kdceCoupons = new List<KDCE_Coupon__c>();
        Contact contact = KDCE_TestUtil.contactMember;
        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupon.UsedDate__c = System.now();
        update coupon;
        kdceCoupons.add(coupon);

        Map<Id, List<KDCE_Coupon__c>> couponByCon = new Map<Id, List<KDCE_Coupon__c>>();
        couponByCon.put(contact.Id, kdceCoupons);

        Map<Id, Map<String, Object>> purchaseByContact2 = new Map<Id, Map<String, Object>>();
        Map<String, Object> purchaseBy2 = new Map<String, Object>();
        purchaseByContact2.put(contact.Id, null);
        purchaseBy2.put('FirstPurchaseDate', System.now().addMonths(1));
        purchaseBy2.put('LastPurchaseDate', System.now().addMonths(-1));
        purchaseByContact2.put(contact.Id, purchaseBy2);

        KDCE_ContactService.purchaseCouponMap(purchaseByContact2, couponByCon, contact.Id);
    }
}