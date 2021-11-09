/****************************************************************************************
  * @filename      : KDCE_CouponHistory_tr_Test
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
private class KDCE_CouponHistory_tr_Test {

    final static String CANCEL_STATUS = '주문취소'; //todo 주문 취소 값 확정 되면 변경 필요
    static Contact contact;
    static KDCE_Coupon__c coupon;
    static KDCE_Order__c order;
    static KDCE_CouponHistory__c couponHistory;
    static String developerName_Coupon_MGM = 'Coupon_MGM';
    static String couponStatus_Use = 'Use';
    static String couponStatus_Cancel = 'Cancel';
    static Id RT_Coupon_MGM = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_MGM').getRecordTypeId();

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    static void getData(String developerName_Coupon, String couponStatus) {

        //todo 쿠폰 사용 취소 시나리오도 추가되면 아래 주석 풀어 사용
        if (developerName_Coupon == developerName_Coupon_MGM && couponStatus == couponStatus_Cancel) {
            CouponTestDataUtil.getOrder(developerName_Coupon, true);
            coupon = [SELECT Status__c FROM KDCE_Coupon__c LIMIT 1];
            order = [SELECT OrderStatus__c FROM KDCE_Order__c LIMIT 1];
            order.OrderStatus__c = CANCEL_STATUS;
            update order;
        } else {
            CouponTestDataUtil.getCoupon(developerName_Coupon, couponStatus);
        }

        System.debug(developerName_Coupon);
        System.debug(couponStatus);
        System.debug(CouponTestDataUtil.coupon);
//        couponHistory = [SELECT ActionType__c FROM KDCE_CouponHistory__c WHERE ActionType__c = :couponStatus LIMIT 1];
//        contact = [SELECT KDCE_MGMUseCount__c FROM Contact WHERE KDCE_Name__c = :developerName_Coupon+0 LIMIT 1];
    }

    /**
     * @description MGM 쿠폰 사용 시나리오
     *              (히스토리 생성 및 MGM 쿠폰이 발급된 Contact.KDCE_MGMUseCount__c = 1)
     * @author JE Yoon
     **/
    @IsTest
    static void testCase01() {

        Test.startTest();
        if (contact == null) getData(developerName_Coupon_MGM, couponStatus_Use);

//        System.assertEquals(couponStatus_Use, couponHistory.ActionType__c);
//        System.assertEquals(1, contact.KDCE_MGMUseCount__c);
        Test.stopTest();
    }

    /**
     * @description MGM 쿠폰 사용 취소 시나리오 //todo 쿠폰 사용 취소 시나리오도 추가되면 아래 주석 풀어 사용
      *             (히스토리 생성 및 MGM 쿠폰이 발급된 Contact.KDCE_MGMUseCount__c = 0)
     * @author JE Yoon
     **/
    @IsTest
    static void testCase02() {

        Test.startTest();
        if (contact == null) getData(developerName_Coupon_MGM, couponStatus_Cancel);

        //System.assertEquals(couponStatus_Cancel, couponHistory.ActionType__c);
        //System.assertEquals(0, contact.KDCE_MGMUseCount__c);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior01() {
        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupon.RecordTypeId = RT_Coupon_MGM;
        update coupon;

        KDCE_CouponHistory__c couponHistory = new KDCE_CouponHistory__c();
        couponHistory.Coupon__c = coupon.Id;
        couponHistory.ActionType__c = 'Use';
        insert couponHistory;
        System.debug('=== couponHistory : ' + couponHistory);
    }
}