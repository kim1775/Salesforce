/****************************************************************************************
  * @filename      : KDCE_CouponService_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-17 오후 6:34
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
    0.1     2021-06-17 오후 6:34     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_CouponService_ts {

    static Map<String, Id> rtMap_Coupon = KDCE_Util.getRecordTypeBySObject('KDCE_Coupon__c');
    static String mgmCouponRecordTypeId    = rtMap_Coupon.get('Coupon_MGM');

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior01() {

        List<Contact> contacts = new List<Contact>();
        Contact contact = KDCE_TestUtil.contactMember;

        contacts.add(contact);

        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupon.RecordTypeId = mgmCouponRecordTypeId;
        update coupon;

        Map<Id, KDCE_Coupon__c> couponMap = new Map<Id, KDCE_Coupon__c>();
        couponMap.put(coupon.Id, coupon);

        KDCE_CouponService.createCouponHistory(coupon.Id, 'Produce');
        KDCE_CouponService.createCouponHistories(couponMap);

//        KDCE_CouponService.CouponWrapper cw = new KDCE_CouponService.CouponWrapper();
//        List<KDCE_CouponService.CouponWrapper> CouponWrappers = new List<KDCE_CouponService.CouponWrapper>();
//        cw.couponId = coupon.Id;
//        cw.contactId = KDCE_TestUtil.contactMember.Id;
//        cw.actionType = 'Produce';
//        cw.actionDate = System.now();
//        cw.gifticon = null;
//        CouponWrappers.add(cw);
//
//        KDCE_CouponService.createCouponUseHistory(CouponWrappers, 'Online');

//        List<KDCE_CouponHistory__c> kdceCouponHistories = new List<KDCE_CouponHistory__c>();
//        KDCE_CouponHistory__c history = new KDCE_CouponHistory__c();
//        history.Contact__c = KDCE_TestUtil.contactMember.Id;
//        history.Coupon__c = KDCE_TestBizUtil.coupon.Id;
//        history.ActionType__c = 'Produce';
//        history.ActionDate__c = System.now();
//        insert history;
//        kdceCouponHistories.add(history);
//        KDCE_CouponService.createMGMCouponTask(kdceCouponHistories, couponMap);
//        KDCE_CouponService.issueCoupon(contacts, 'Coupon_MGM');

//        List<KDCE_Order__c> orders = new List<KDCE_Order__c>();
//        KDCE_Order__c order = KDCE_TestBizUtil.order;
//        orders.add(order);
//
//        KDCE_CouponService.createOnlineCouponUseHistory(orders);
//        KDCE_CouponService.createOfflineCouponUseHistory(coupon.Id, contact.Id, null);
    }

    @IsTest
    static void testBehavior02() {
        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupon.RecordTypeId = mgmCouponRecordTypeId;
        update coupon;

        Map<Id, KDCE_Coupon__c> couponMap = new Map<Id, KDCE_Coupon__c>();

        KDCE_CouponService.CouponWrapper cw = new KDCE_CouponService.CouponWrapper();
        List<KDCE_CouponService.CouponWrapper> CouponWrappers = new List<KDCE_CouponService.CouponWrapper>();
        cw.couponId = coupon.Id;
        cw.contactId = KDCE_TestUtil.contactMember.Id;
        cw.actionType = 'Produce';
        cw.actionDate = System.now();
        cw.gifticon = null;
        CouponWrappers.add(cw);

        KDCE_CouponService.createCouponUseHistory(CouponWrappers, 'Online');
    }

    @IsTest
    static void testBehavior03() {

        List<Contact> contacts = new List<Contact>();
        Contact contact = KDCE_TestUtil.contactMember;
        contacts.add(contact);

        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupon.RecordTypeId = mgmCouponRecordTypeId;
        update coupon;

        Map<Id, KDCE_Coupon__c> couponMap;

        List<KDCE_CouponHistory__c> kdceCouponHistories = new List<KDCE_CouponHistory__c>();
        KDCE_CouponHistory__c history = new KDCE_CouponHistory__c();
        history.Contact__c = KDCE_TestUtil.contactMember.Id;
        history.Coupon__c = KDCE_TestBizUtil.coupon.Id;
        history.ActionType__c = 'Produce';
        history.ActionDate__c = System.now();
        KDCE_CouponHistory__c history2 = history.clone(true);
        history2.ActionType__c = 'Use';

        kdceCouponHistories.add(history);
        kdceCouponHistories.add(history2);
        insert kdceCouponHistories;

        couponMap = new Map<Id, KDCE_Coupon__c>([
                SELECT Name, Contact__r.Name, ru_GifticonReceivedHistoryCount__c, RecordTypeId
                FROM KDCE_Coupon__c
                WHERE Id = :coupon.Id
        ]);
        KDCE_CouponService.createMGMCouponTask(kdceCouponHistories, couponMap);
        KDCE_CouponService.updateContactMGMUseCount(kdceCouponHistories);
        KDCE_CouponService.issueCoupon(contacts, 'Coupon_MGM');
    }

    @IsTest
    static void testBehavior04() {


        List<Contact> contacts = new List<Contact>();
        Contact contact = KDCE_TestUtil.contactMember;
        contacts.add(contact);

        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupon.RecordTypeId = mgmCouponRecordTypeId;
        update coupon;

        List<KDCE_Order__c> orders = new List<KDCE_Order__c>();
        KDCE_Order__c order = KDCE_TestBizUtil.order;
        orders.add(order);

        KDCE_CouponService.createOnlineCouponUseHistory(orders);
        KDCE_CouponService.createOfflineCouponUseHistory(coupon.Id, contact.Id, null);
    }

    @IsTest
    static void testBehavior05() {


        List<Contact> contacts = new List<Contact>();
        Contact contact = KDCE_TestUtil.contactMember;
        contacts.add(contact);

        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupon.RecordTypeId = mgmCouponRecordTypeId;
        update coupon;

        List<KDCE_Order__c> orders = new List<KDCE_Order__c>();
        KDCE_Order__c order = KDCE_TestBizUtil.order;
        orders.add(order);

        KDCE_CouponService.createOfflineCouponUseHistory(coupon.Id, contact.Id, null);
    }
}