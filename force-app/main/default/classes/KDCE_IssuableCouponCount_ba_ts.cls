/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-08-12 오후 7:17
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
    0.1     2021-08-12 오후 7:17     i2max_Junseok.Kwon        Create
****************************************************************************************/

@IsTest
private class KDCE_IssuableCouponCount_ba_ts {

    @TestSetup
    static void setDate(){

        List<KDCE_Coupon__c> couponList = new List<KDCE_Coupon__c>();

        KDCE_Coupon__c issuable = new KDCE_Coupon__c();
        issuable.CouponCode__c = 'Issuable_Coupon';
        issuable.Type__c = 'MGM';
        issuable.ExternalType__c = 'MGM';
        issuable.Status__c = 'Produce';
        couponList.add(issuable);

        KDCE_Coupon__c pending = new KDCE_Coupon__c();
        pending.CouponCode__c = 'Pending_Coupon';
        pending.Type__c = 'MGM';
        pending.Status__c = 'Produce';
        couponList.add(pending);

        insert couponList;
    }

    @IsTest
    static void testBehavior() {
        KDCE_IssuableCouponCount_ba batch = new KDCE_IssuableCouponCount_ba();
        batch.couponType = 'MGM';
        Database.executeBatch(batch, 2000);
    }

}