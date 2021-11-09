/****************************************************************************************
  * @filename      : KDCE_DormantCase_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-04 오후 1:17
  * @group         : 
  * @group-content : 
  * @description   : Contact 휴면 전환시, Contact과 관련된 Case 분리보관 및 개인정보 Null처리
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-06-04 오후 1:17     i2max_Jihyun.Lee        Create
****************************************************************************************/
/*******************************************************************************************
 * Serial Batch Order
 * 1. KDCE_DormantContact_ba:        Contact 휴면 처리 (Contact 정보 Null처리). Member일 경우는 분리보관 및 개인정보 Null처리
 * 2. KDCE_DormantCase_ba:           Contact 휴면 전환시, Contact과 관련된 Case 분리보관 및 개인정보 Null처리
 * 3. KDCE_DormantOrderLineItem_ba:  Contact 휴면 전환시, Contact과 관련된 Order Line Item 분리보관 및 개인정보 Null처리
 * 4. KDCE_DormantOrder_ba:          Contact 휴면 전환시, Contact과 관련된 Order 분리보관 및 개인정보 Null처리
 * 5. KDCE_DormantOfflineProgram_ba: Contact 휴면 전환시, Contact과 관련된 Offline Program 분리보관 및 개인정보 Null처리
 *******************************************************************************************/

public with sharing class KDCE_DormantCase_ba implements Database.Batchable<sObject>, Database.Stateful {

    //public Set<Id> batchContactIds;

    String objectName = 'Case';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> caseFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();


    public Database.QueryLocator start(Database.BatchableContext BC) {

        //System.debug('=== batchContactIds : ' + batchContactIds);
        for (String fieldName : caseFieldMap.keySet()) {
            if (query != 'SELECT ') query += ' ,';      // 첫번째 필드가 아닐 경우 , 붙이기
            query += fieldName;
        }
        query += ' FROM ';
        query += objectName;
        query += ' WHERE Contact.KDCE_IsDormant__c = TRUE AND Contact.KDCE_ConvertDormantDate__c = TODAY ';
        //query += ' WHERE ContactId IN :batchContactIds';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.Case.fields.getMap();
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid'
        };
        Set<String> nullField = new Set<String>{
                'contactid', 'kdce_ani__c', 'suppliedname', 'suppliedemail', 'suppliedphone', 'description', 'kdce_qurecontactphone__c'
        };
        KDCE_ContactSeparateService.separateObject('Dormant', 'Case', 'KDCE_DormantCase__c', scope);
        KDCE_ContactSeparateService.setNullField('Dormant', 'Case', scope, objectSchema, notNullField, nullField);

    }

    public void finish(Database.BatchableContext BC) {
        KDCE_DormantOrderLineItem_ba nextBatch = new KDCE_DormantOrderLineItem_ba();
        //nextBatch.batchContactIds = batchContactIds;
        Database.executeBatch(nextBatch, 200);
    }
}