/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-08-10 오후 10:24
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
    0.1     2021-08-10 오후 10:24     i2max_Junseok.Kwon        Create
****************************************************************************************/

global without sharing class KDCE_IssuableCouponSet_ba implements Database.Batchable<SObject>, Database.Stateful {

    global Integer changeCount;
    global String couponType;
    global String cvsChannel;

    public Database.QueryLocator start(Database.BatchableContext BC) {

        System.debug('=== KDCE_IssuableCouponSet_ba start ===');

        String query = '';
        query += ' SELECT Id FROM KDCE_Coupon__c ';
        query += ' WHERE Status__c = \'Produce\' ';
        query += ' AND Type__c = :couponType ';
        query += ' AND ExternalType__c != :couponType ';
        // CVS 쿠폰은 채널별로 처리
        if(cvsChannel != null && cvsChannel != ''){
            query += ' AND ChannelDetails__c = :cvsChannel ';
            query += ' AND IssuableDate__c > TODAY ORDER BY IssuableDate__c DESC ';
        }
        if(!Test.isRunningTest()) query += ' LIMIT :changeCount ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<KDCE_Coupon__c> scope) {

        System.debug('=== KDCE_IssuableCouponSet_ba execute ===');

        for(KDCE_Coupon__c row : scope){
            row.ExternalType__c = couponType;
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {

        System.debug('=== KDCE_IssuableCouponSet_ba finish ===');

    }

}