/****************************************************************************************
  * @filename      : KDCE_DropOutOrderLineItemSoftDeletion_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-11 오전 10:29
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
    0.1     2021-06-11 오전 10:29     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_DropOutOrderLineItemSoftDeletion_ba implements Database.Batchable<sObject>, Database.Stateful {
    //public Set<Id> batchContactIds;

    String objectName = 'KDCE_OrderLineItem__c';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> orderFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();


    public Database.QueryLocator start(Database.BatchableContext BC) {

        for (String fieldName : orderFieldMap.keySet()) {
            if (query != 'SELECT ') query += ' ,';      // 첫번째 필드가 아닐 경우 , 붙이기
            query += fieldName;
        }
        query += ' FROM ';
        query += objectName;
        if (!Test.isRunningTest()) query += ' WHERE Order__r.Contact__r.KDCE_IsDropOut__c = true AND Order__r.Contact__r.KDCE_DropOutDate__c = TODAY ';
        //query += ' WHERE KDCE_fm_OrderContactId__c IN :batchContactIds';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.KDCE_OrderLineItem__c.fields.getMap();
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid'
        };
        KDCE_ContactSeparateService.separateObject('DropOut', 'KDCE_OrderLineItem__c', 'KDCE_DropOutOrderLineItem__c', scope);

    }

    public void finish(Database.BatchableContext BC) {

        KDCE_DropOutOrderSoftDeletion_ba nextBatch = new KDCE_DropOutOrderSoftDeletion_ba();
        Database.executeBatch(nextBatch, 200);

        /*
        if(!batchContactIds.isEmpty()) {
            KDCE_DropOutOrderSoftDeletion_ba nextBatch = new KDCE_DropOutOrderSoftDeletion_ba();
            nextBatch.batchContactIds = batchContactIds;
            Database.executeBatch(nextBatch, 2000);
        }
        */
    }
}