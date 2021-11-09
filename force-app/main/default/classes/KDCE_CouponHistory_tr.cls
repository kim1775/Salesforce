/****************************************************************************************
  * @filename      : KDCE_CouponHistory_tr
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-05
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-05          i2max_JE Yoon             Create
****************************************************************************************/
public without sharing class KDCE_CouponHistory_tr extends TriggerHandler {

    private final static Id RT_Coupon_CVSId             = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_CVS').getRecordTypeId();    // 쿠폰 : 편의점
    private final static Id RT_Coupon_GetInfo           = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_GetInfo').getRecordTypeId();// 쿠폰 : Getinfo
    private final static Id RT_Coupon_MGM               = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_MGM').getRecordTypeId();    // 쿠폰 : MGM

    public override void afterInsert() {
        this.updateContactMGMUseCount();
    }

    public override void afterUpdate(){
    }


    /**
     * @description MGM 쿠폰 사용/사용취소 히스토리 생성 시 MGM 쿠폰이 발급된 Contact의 KDCE_MGMUseCount__c 값 업데이트
     * @author JE Yoon
     **/
    private void updateContactMGMUseCount() {
        System.debug('@@@@@@ updateContactMGMUseCount @@@@@@');
        List<KDCE_CouponHistory__c> couponHistories = new List<KDCE_CouponHistory__c>();
        Map<KDCE_CouponHistory__c, Id> historyByCouponMap = new Map<KDCE_CouponHistory__c, Id>();
        for (KDCE_CouponHistory__c history : (List<KDCE_CouponHistory__c>) Trigger.new) {
            historyByCouponMap.put(history, history.Coupon__c);
        }
        Set<Id> mgmCoupons = new Set<Id>();
        for (KDCE_Coupon__c coupon : [SELECT Id FROM KDCE_Coupon__c WHERE Id IN :historyByCouponMap.values() AND Type__c = 'MGM']) {
            mgmCoupons.add(coupon.Id);
        }
        for (KDCE_CouponHistory__c history : (List<KDCE_CouponHistory__c>) Trigger.new) {
            if (mgmCoupons.contains(history.Coupon__c)) couponHistories.add(history);
        }
        KDCE_CouponService.updateContactMGMUseCount(couponHistories);
    }

}