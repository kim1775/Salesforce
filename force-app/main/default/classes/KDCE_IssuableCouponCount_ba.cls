/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-08-10 오후 10:18
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
    0.1     2021-08-10 오후 10:18     i2max_Junseok.Kwon        Create
****************************************************************************************/

global without sharing class KDCE_IssuableCouponCount_ba implements Database.Batchable<SObject>, Database.Stateful {

    global Integer issuableCoupon;
    global String couponType;
    global String cvsChannel;

    public Database.QueryLocator start(Database.BatchableContext BC) {

        System.debug('=== KDCE_IssuableCouponCount_ba start ===');

        issuableCoupon = 0;

        String query = '';
        query += ' SELECT Id FROM KDCE_Coupon__c ';
        query += ' WHERE Status__c = \'Produce\' ';
        query += ' AND Type__c = :couponType ';
        query += ' AND ExternalType__c = :couponType ';
        // CVS 쿠폰은 채널별로 처리
        if(cvsChannel != null && cvsChannel != '') {
            query += ' AND ChannelDetails__c = :cvsChannel ';
            query += ' AND IssuableDate__c > TODAY ORDER BY IssuableDate__c DESC ';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<KDCE_Coupon__c> scope) {

        System.debug('=== KDCE_IssuableCouponCount_ba execute ===');
        issuableCoupon += scope.size();
        System.debug('=== issuableCoupon : ' + issuableCoupon);
    }

    public void finish(Database.BatchableContext BC) {

        System.debug('=== KDCE_IssuableCouponCount_ba finish ===');

        // 발급 가능한 쿠폰 최대 4만개 유지
        Integer maxCount = 40000;
        if(issuableCoupon < maxCount){

            Integer changeCount = maxCount - issuableCoupon;
            KDCE_IssuableCouponSet_ba batch = new KDCE_IssuableCouponSet_ba();
            batch.changeCount = changeCount;
            batch.couponType = couponType;
            batch.cvsChannel = cvsChannel;
            Database.executeBatch(batch, 2000);
        }
    }

}