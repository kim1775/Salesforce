/****************************************************************************************
  * @filename      : KDCE_DropOutOrderSoftDeletion_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-11 오전 10:31
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
    0.1     2021-06-11 오전 10:31     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_DropOutOrderSoftDeletion_ba implements Database.Batchable<sObject>, Database.Stateful {

    //public Set<Id> batchContactIds;

    String objectName = 'KDCE_Order__c';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> orderFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();


    public Database.QueryLocator start(Database.BatchableContext BC) {

        for (String fieldName : orderFieldMap.keySet()) {
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

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.KDCE_Order__c.fields.getMap();
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid'
        };

        Set<String> orderPersonalField = new Set<String>{
                'contact__c', 'customerid__c', 'customername__c', 'customeremail__c',
                'shippingaddressname__c', 'shippingaddress1__c', 'shippingaddress2__c',
                'shippingphone__c', 'shippingstreet__c', 'shippingpostalcode__c',
                'shippingstate__c', 'shippingcity__c'
        };

        /*
        List<KDCE_Order__c> within5YearsList = new List<KDCE_Order__c>();
        Datetime createdDt;
        for(KDCE_Order__c item : (List<KDCE_Order__c>) scope){
            createdDt = Date.newInstance(item.CreatedDate.year(), item.CreatedDate.month(), item.CreatedDate.day());
            System.debug(createdDt);
            if(item.CreatedDate  >  createdDt){
                within5YearsList.add(item);
            }
        }
        */

        //KDCE_ContactSeparateService.separateObject('DropOut', 'KDCE_Order__c', 'KDCE_DropOutOrder__c', within5YearsList);
        KDCE_ContactSeparateService.separateObject('DropOut', 'KDCE_Order__c', 'KDCE_DropOutOrder__c', scope);
        KDCE_ContactSeparateService.setNullField('DropOut', 'KDCE_Order__c', scope, objectSchema, notNullField, orderPersonalField);



    }

    public void finish(Database.BatchableContext BC) {

        KDCE_DropOutOfflineSoftDeletion_ba nextBatch = new KDCE_DropOutOfflineSoftDeletion_ba();
        Database.executeBatch(nextBatch, 200);

        /*
        if(!batchContactIds.isEmpty()) {
            KDCE_DropOutOfflineSoftDeletion_ba nextBatch = new KDCE_DropOutOfflineSoftDeletion_ba();
            nextBatch.batchContactIds = batchContactIds;
            Database.executeBatch(nextBatch, 2000);
        }
        */
    }
}