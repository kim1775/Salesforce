/****************************************************************************************
  * @filename      : IF_XP_SFDC_001_ba_Test
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-15 오후 2:15
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
    0.1     2021-06-15 오후 2:15     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class IF_XP_SFDC_001_ba_Test {

    @IsTest
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;


        IF_XP_SFDC_001__c xp01 = new IF_XP_SFDC_001__c(
                BurnoutChannel__c = 'CVS',
                CouponAmount__c = '10000',
                CouponExpiryDate__c = '20190630',
                CouponId__c = coupon.CouponCode__c,
                Couponissuedate__c = '20190329',
                CouponName__c = '아이코스상품권 1만원권',
                CouponOltName__c = '1111',
                CouponOltCode__c = '1111',
                CouponStatus__c = '1',
                CouponStatusDate__c = '20190300000000',
                CVSChainCode__c = '2',
                CVSChainName__c = 'k7'
        );
        insert xp01;

        Test.startTest();
        IF_XP_SFDC_001_ba batch = new IF_XP_SFDC_001_ba();
        Database.executeBatch(batch, 2000);
        Test.stopTest();

    }
}