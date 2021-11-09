/****************************************************************************************
  * @filename      : KDCE_DropOutOfflineSoftDeletion_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-11 오전 10:33
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : KDCE_DropOutContactSoftDeletion_ba_ts
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-06-11 오전 10:33     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_DropOutOfflineSoftDeletion_ba implements Database.Batchable<sObject>, Database.Stateful {

    //public Set<Id> batchContactIds;

    String objectName = 'KDCE_OfflineProgram__c';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> offlineProgramFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();


    public Database.QueryLocator start(Database.BatchableContext BC) {

        for (String fieldName : offlineProgramFieldMap.keySet()) {
            if (query != 'SELECT ') query += ' ,';      // 첫번째 필드가 아닐 경우 , 붙이기
            query += fieldName;
        }
        query += ' FROM ';
        query += objectName;
        if (!Test.isRunningTest()) query += ' WHERE Contact__r.KDCE_IsDropOut__c = true AND Contact__r.KDCE_DropOutDate__c = TODAY ';
        //query += ' WHERE Contact__c IN :batchContactIds';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.KDCE_OfflineProgram__c.fields.getMap();
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid'
        };
        KDCE_ContactSeparateService.separateObject('DropOut', 'KDCE_OfflineProgram__c', 'KDCE_DropOutOfflineProgram__c', scope);
        for (KDCE_OfflineProgram__c op : (List<KDCE_OfflineProgram__c>) scope) {
            op.Contact__c = null;
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {

        // TODO 처리방안 필요
        // 해당 컨택들이 하드딜리션 대상인지 체크하는 배치
        KDCE_DropoutDailyCheckHardDelContact_ba nextBatch = new KDCE_DropoutDailyCheckHardDelContact_ba();
        nextBatch.whereClause = ' WHERE ContactId__r.KDCE_IsDropOut__c = true AND ContactId__r.KDCE_DropOutDate__c = TODAY ';
        //nextBatch.delTargetContIds = batchContactIds;
        Database.executeBatch(nextBatch, 200);
        /*
        if (!batchContactIds.isEmpty()) {
            // 해당 컨택들이 하드딜리션 대상인지 체크하는 배치
            KDCE_DropoutDailyCheckHardDelContact_ba nextBatch = new KDCE_DropoutDailyCheckHardDelContact_ba();
            //nextBatch.delTargetContIds = batchContactIds;
            //Database.executeBatch(nextBatch, 2000);
        }
        */
    }
}