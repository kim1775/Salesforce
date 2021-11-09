/****************************************************************************************
  * @filename      : KDCE_CouponIssueQuickController_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-14 오후 2:52
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
    0.1     2021-06-14 오후 2:52     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_CouponIssueQuickController_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        Contact contact = KDCE_TestUtil.contactMember;
        KDCE_CouponIssueQuickController.getInvalidContact(contact.Id);
        KDCE_CouponIssueQuickController.getPickListValuesList();
        KDCE_CouponIssueQuickController.checkValidChannelCVS('CVS trade in Purchase coupon');
        KDCE_CouponIssueQuickController.getCouponList(contact.Id, 'CVS', 'GS');

        List<KDCE_Coupon__c> coupons = new List<KDCE_Coupon__c>();
        KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
        coupons.add(coupon);
        System.debug('=== coupons : ' + coupons);
        KDCE_CouponIssueQuickController.saveCouponList(contact.Id, coupons);
    }
}