/****************************************************************************************
  * @filename      : IF_XP_SFDC_001_tr_Test
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-31
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-31          i2max_JE Yoon             Create
****************************************************************************************/
@IsTest
private class IF_XP_SFDC_001_tr_Test {

    static String couponStatus_Use = 'Use';
    static String couponStatus_Cancel = 'Cancel';
    static String couponStatus_Issue = 'Issue';
    static String actionChannel_Offline = 'Offline';
    static String date_converted;
    static String ifxp_date;
    static Datetime dt;
    static IF_XP_SFDC_001__c ifxp;
    static List<IF_XP_SFDC_001__c> ifXpSfdc001s;
    static List<KDCE_Coupon__c> coupons;
    static List<KDCE_CouponHistory__c> couponHistories;
    static String errorContent = 'Coupon Id does not exist.';


    static void getData(Integer IFXP_CouponStatus, Boolean couponExists) {
        ifxp = CouponTestDataUtil.getIfXpSfdc001();
        if (IFXP_CouponStatus == -1 && couponExists == true) {
            ifxp.CouponStatus__c = '-1';
        } else if (couponExists == false) {
            ifxp.CouponId__c = 'Fake Coupon';
        }

        insert ifxp;

        ifXpSfdc001s = [SELECT CouponId__c, IsProcess__c, IsError__c, ErrorContent__c, CouponStatusDate__c FROM IF_XP_SFDC_001__c LIMIT 1];
        coupons = [SELECT Status__c, Contact__c FROM KDCE_Coupon__c WHERE CouponCode__c = :ifxp.CouponId__c LIMIT 1];
        couponHistories = [SELECT Coupon__c, Contact__c, ActionDate__c, ActionChannel__c, ActionType__c, StoreCode__c, StoreName__c FROM KDCE_CouponHistory__c WHERE Coupon__r.CouponCode__c = :ifxp.CouponId__c AND ActionChannel__c = :actionChannel_Offline LIMIT 1];

        ifxp_date = ifXpSfdc001s[0].CouponStatusDate__c;
        if (ifxp_date.length() == 14) {
            date_converted = ifxp_date.substring(0,4) + '-' + ifxp_date.substring(4,6) + '-' + ifxp_date.substring(6,8) + ' ';
            date_converted += ifxp_date.substring(8,10) + ':' + ifxp_date.substring(10,12) + ':' + ifxp_date.substring(12,14);
            dt = Datetime.valueOf(date_converted);
        }
    }

    /**
     * @description IF_XP_SFDC_001에 CouponStatus__c = 1이고 쿠폰이 시스템에 존재할 때 시나리오
     * @author JE Yoon
     **/
    @IsTest
    static void testCase01() {

        Test.startTest();
        if (ifxp == null) getData(1, true);

//        System.assertNotEquals(true, ifXpSfdc001s[0].IsProcess__c);
//        System.assertEquals(false, ifXpSfdc001s[0].IsError__c);
//        System.assertEquals(couponStatus_Use, coupons[0].Status__c);
//        System.assertEquals(coupons[0].Id, couponHistories[0].Coupon__c);
//        System.assertEquals(coupons[0].Contact__c, couponHistories[0].Contact__c);
//        System.assertEquals(dt, couponHistories[0].ActionDate__c);
//        System.assertEquals(actionChannel_Offline, couponHistories[0].ActionChannel__c);
//        System.assertEquals(couponStatus_Use, couponHistories[0].ActionType__c);
//        System.assertEquals('1234', couponHistories[0].StoreCode__c);
//        System.assertEquals('공덕점', couponHistories[0].StoreName__c);
        Test.stopTest();

    }

    /**
     * @description IF_XP_SFDC_001에 CouponStatus__c = -1이고 쿠폰 Id가 시스템에 존재할 때 시나리오
     * @author JE Yoon
     **/
    @IsTest
    static void testCase02() {

        Test.startTest();
        if (ifxp == null) getData(-1, true);

//        System.assertEquals(true, ifXpSfdc001s[0].IsProcess__c);
//        System.assertEquals(false, ifXpSfdc001s[0].IsError__c);
//        System.assertEquals(couponStatus_Issue, coupons[0].Status__c);
//        System.assertEquals(coupons[0].Id, couponHistories[0].Coupon__c);
//        System.assertEquals(coupons[0].Contact__c, couponHistories[0].Contact__c);
//        System.assertEquals(dt, couponHistories[0].ActionDate__c);
//        System.assertEquals(actionChannel_Offline, couponHistories[0].ActionChannel__c);
//        System.assertEquals(couponStatus_Cancel, couponHistories[0].ActionType__c);
//        System.assertEquals('1234', couponHistories[0].StoreCode__c);
//        System.assertEquals('공덕점', couponHistories[0].StoreName__c);
        Test.stopTest();

    }

    /**
 * @description IF_XP_SFDC_001에 CouponStatus__c = 1이고 쿠폰 Id가 시스템에 존재하지 않을 때 시나리오
 * @author JE Yoon
 **/
    @IsTest
    static void testCase03() {

        Test.startTest();
        if (ifxp == null) getData(1, false);

//        System.assertEquals('Fake Coupon', ifXpSfdc001s[0].CouponId__c);
//        System.assertEquals(false, ifXpSfdc001s[0].IsProcess__c);
//        System.assertEquals(0, coupons.size());
//        System.assertEquals(0, couponHistories.size());
//        System.assertEquals(errorContent, ifXpSfdc001s[0].ErrorContent__c);
//        System.assertEquals(true, ifXpSfdc001s[0].IsError__c);
        Test.stopTest();

    }
}