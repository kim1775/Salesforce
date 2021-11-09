/****************************************************************************************
  * @filename      : KDCE_Coupon_tr_Test
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
private class KDCE_Coupon_tr_Test {

    static KDCE_Coupon__c coupon;
    static KDCE_CouponHistory__c couponHistory;
    static Contact contact;
    static String developerName_Coupon_MGM = 'Coupon_MGM';
    static String developerName_Coupon_CVS = 'Coupon_CVS';
    static String developerName_Coupon_GetInfo = 'Coupon_GetInfo';
    static String couponStatus_Produce = 'Produce';
    static String couponStatus_Issue = 'Issue';
    static Decimal amount_Coupon_MGM = 25000;
    static Decimal amount_Coupon_CVS = 31000;
    static Decimal amount_Coupon_GetInfo = 10000;
    static Map<String, Id> rtMap_Coupon = KDCE_Util.getRecordTypeBySObject('KDCE_Coupon__c');


    @IsTest
    static void testCase01() {
        Contact contact = KDCE_TestUtil.contactMember;
        String recordTypeId_Coupon_CVS = rtMap_Coupon.get('Coupon_CVS');

        // Coupon 생성
        KDCE_Coupon__c newCoupon = new KDCE_Coupon__c(
                Name = 'coupon Name',
                Contact__c = contact.Id,
                Status__c = 'Issue',
                Type__c = 'CVS',
                RecordTypeId = recordTypeId_Coupon_CVS,
                ChannelDetails__c = 'CU',
                ExpiryDate__c = Date.today().addMonths(6),
                IssuableDate__c = Date.today().addMonths(5)
        );
        insert newCoupon;
        System.debug('=== 1 newCoupon : ' + newCoupon);

        newCoupon.Status__c = 'Use';
        update newCoupon;
        System.debug('=== 2 newCoupon : ' + newCoupon);

        newCoupon.Status__c = 'Issue';
        System.debug('=== 3 newCoupon : ' + newCoupon);
        update newCoupon;
    }

    @IsTest
    static void testCase02() {
        KDCE_Coupon__c newCoupon = new KDCE_Coupon__c(
                Name = 'coupon Name',
                Contact__c = null,
                Status__c = 'Produce',
                Type__c = 'CVS',
                ChannelDetails__c = 'CU',
                ExpiryDate__c = Date.today().addMonths(6),
                IssuableDate__c = Date.today().addMonths(5)
        );
        insert newCoupon;

        newCoupon.Contact__c = KDCE_TestUtil.contactMember.Id;
        newCoupon.Status__c = 'Issue';
        update newCoupon;
    }


}