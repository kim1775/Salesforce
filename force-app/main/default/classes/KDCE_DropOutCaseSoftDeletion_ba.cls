/****************************************************************************************
  * @filename      : KDCE_DropOutCaseSoftDeletion_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-11 오전 10:28
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
    0.1     2021-06-11 오전 10:28     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_DropOutCaseSoftDeletion_ba implements Database.Batchable<sObject>, Database.Stateful {

    //public Set<Id> batchContactIds;

    String objectName = 'Case';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> caseFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('===== START :: Dropout Case SoftDel ===== ');

        for (String fieldName : caseFieldMap.keySet()) {
            if (query != 'SELECT ') query += ' ,';      // 첫번째 필드가 아닐 경우 , 붙이기
            query += fieldName;
        }
        query += ' FROM ';
        query += objectName;
        if (!Test.isRunningTest()) query += ' WHERE Contact.KDCE_IsDropOut__c = true AND Contact.KDCE_DropOutDate__c = TODAY ';
        //query += ' WHERE ContactId IN :batchContactIds ';

        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('===== EXECUTE :: Dropout Case SoftDel ===== ');

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.Case.fields.getMap();
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid'
        };

        Set<String> nullField = new Set<String>{
                'contactid', 'kdce_ani__c', 'suppliedname', 'suppliedemail', 'suppliedphone', 'description', 'kdce_qurecontactphone__c'
        };

        // 3년 이내의 Case만 분리보관하기
        /*
        List<Case> within3YearsList = new List<Case>();
        Datetime targetDate = System.now().addYears(-3);
        System.debug(targetDate);
        for(Case item : (List<Case>) scope){
            //targetDate = Date.newInstance(item.CreatedDate.year(), item.CreatedDate.month(), item.CreatedDate.day());
            if(item.CreatedDate  >  targetDate){
                within3YearsList.add(item);
            }
        }
        */
        KDCE_ContactSeparateService.separateObject('DropOut', 'Case', 'KDCE_DropOutCase__c', scope);
        //KDCE_ContactSeparateService.separateObject('DropOut', 'Case', 'KDCE_DropOutCase__c', within3YearsList);
        KDCE_ContactSeparateService.setNullField('DropOut', 'Case', scope, objectSchema, notNullField, nullField);
    }

    public void finish(Database.BatchableContext BC) {

        KDCE_DropOutOrderLineItemSoftDeletion_ba nextBatch = new KDCE_DropOutOrderLineItemSoftDeletion_ba();
        Database.executeBatch(nextBatch, 200);

        /*
        if (!batchContactIds.isEmpty()) {
            KDCE_DropOutOrderLineItemSoftDeletion_ba nextBatch = new KDCE_DropOutOrderLineItemSoftDeletion_ba();
            nextBatch.batchContactIds = batchContactIds;
            Database.executeBatch(nextBatch, 2000);
        }
        */
    }
}