/****************************************************************************************
  * @filename      : IF_XP_SFDC_001_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-02 오후 1:38
  * @group         : 
  * @group-content : 
  * @description   : IF_XP_SFDC_001: CVS 쿠폰 사용에 관한 더미 레코드 레코드 등록 후, Coupon으로 변경시키는 배치
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-06-02 오후 1:38     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class IF_XP_SFDC_001_ba implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        query += ' SELECT   Id                      ';
        query += '  ,       BurnoutChannel__c       ';
        query += '  ,       CouponAmount__c         ';
        query += '  ,       CouponExpiryDate__c     ';
        query += '  ,       CouponId__c             ';
        query += '  ,       Couponissuedate__c      ';
        query += '  ,       Couponmoddate__c        ';
        query += '  ,       CouponName__c           ';
        query += '  ,       CouponOltName__c        ';
        query += '  ,       CouponOltCode__c        ';
        query += '  ,       CouponProductCode__c    ';
        query += '  ,       CouponProductName__c    ';
        query += '  ,       CouponStatus__c         ';
        query += '  ,       CouponStatusDate__c     ';
        query += '  ,       CouponStatusDatetime__c ';
        query += '  ,       CVSChainCode__c         ';
        query += '  ,       CVSChainName__c         ';
        query += '  ,       ErrorContent__c         ';
        query += '  ,       IsError__c              ';
        query += '  ,       IsProcess__c            ';
        query += ' FROM     IF_XP_SFDC_001__c       ';
        query += ' WHERE    IsProcess__c = false    ';
        query += ' ORDER BY CouponId__c, CouponStatusDatetime__c ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {

        // Coupon별 Status값 저장 // TODO 기존에 있던 데이터가 사용인데, 취소 사용 데이터가 들어온 경우는 어떻게?..
        List<KDCE_CouponHistory__c> couponHistoryList = new List<KDCE_CouponHistory__c>();
        Set<String> couponCodeSet = new Set<String>();
        for (IF_XP_SFDC_001__c xp : (List<IF_XP_SFDC_001__c>) scope) {
            couponCodeSet.add(xp.CouponId__c);
        }
        Map<String, KDCE_Coupon__c> couponMap = new Map<String, KDCE_Coupon__c>();
        for (KDCE_Coupon__c coupon : [SELECT Id, CouponCode__c, Contact__c FROM KDCE_Coupon__c WHERE CouponCode__c IN :couponCodeSet]) {
            couponMap.put(coupon.CouponCode__c, coupon);
        }
        System.debug('=== couponMap : ' + couponMap);

        Map<Id, KDCE_Coupon__c> updateCouponMap = new Map<Id, KDCE_Coupon__c>();
        KDCE_Coupon__c coupon;
        KDCE_CouponHistory__c history;
        String couponHistoryStatus;

        for (IF_XP_SFDC_001__c xp : (List<IF_XP_SFDC_001__c>) scope) {
            System.debug('=== xp : ' + xp);
            xp.IsProcess__c = true;

            // Coupon 생성
            if (couponMap.containsKey(xp.CouponId__c)) {
                coupon = new KDCE_Coupon__c();
                coupon.Id = couponMap.get(xp.CouponId__c).Id;

                if (xp.CouponStatus__c == '1') {
                    coupon.Status__c    = KDCE_GlobalValue.COUPON_STATUS_USE;
                    coupon.UsedDate__c  = xp.CouponStatusDatetime__c;
                    couponHistoryStatus = KDCE_GlobalValue.COUPON_HISTORY_TYPE_USE;
                }
                else if (xp.CouponStatus__c == '-1') {
                    coupon.Status__c    = KDCE_GlobalValue.COUPON_STATUS_ISSUE;
                    coupon.UsedDate__c  = null;
                    couponHistoryStatus = KDCE_GlobalValue.COUPON_HISTORY_TYPE_CANCEL;
                }
//                couponList.add(coupon);
                updateCouponMap.put(coupon.Id, coupon);

                // History 생성
                history                     = KDCE_CouponService.createCouponHistory(coupon.Id, couponHistoryStatus);
                history.Contact__c          = couponMap.get(xp.CouponId__c).Contact__c;
                history.ActionDate__c       = xp.CouponStatusDatetime__c;
                history.ActionChannel__c    = KDCE_GlobalValue.COUPON_HISTORY_CHANNEL_OFFLINE;
                history.StoreCode__c        = xp.CouponOltCode__c;
                history.StoreName__c        = xp.CouponOltName__c;
                couponHistoryList.add(history);
            }

            // 일치하는 쿠폰이 없으면 에러처리
            else {
                xp.IsError__c = true;
                xp.ErrorContent__c = 'Coupon Id does not exist.';
            }

        }

        update scope;
        List<Database.SaveResult> updateCoupon = Database.update(updateCouponMap.values(), true);
        List<Database.SaveResult> insertCouponHistory = Database.insert(couponHistoryList);
    }

    @SuppressWarnings('PMD')
    public void finish(Database.BatchableContext BC) {

    }
}