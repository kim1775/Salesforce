/****************************************************************************************
  * @filename      : KDCE_DormantOrderLineItem_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-10 오후 6:21
  * @group         : 
  * @group-content : 
  * @description   : Contact 휴면 전환시, Contact과 관련된 Order Line Item 분리보관 및 개인정보 Null처리
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-06-10 오후 6:21     i2max_Jihyun.Lee        Create
****************************************************************************************/
/*******************************************************************************************
 * Serial Batch Order
 * 1. KDCE_DormantContact_ba:        Contact 휴면 처리 (Contact 정보 Null처리). Member일 경우는 분리보관 및 개인정보 Null처리
 * 2. KDCE_DormantCase_ba:           Contact 휴면 전환시, Contact과 관련된 Case 분리보관 및 개인정보 Null처리
 * 3. KDCE_DormantOrderLineItem_ba:  Contact 휴면 전환시, Contact과 관련된 Order Line Item 분리보관 및 개인정보 Null처리
 * 4. KDCE_DormantOrder_ba:          Contact 휴면 전환시, Contact과 관련된 Order 분리보관 및 개인정보 Null처리
 * 5. KDCE_DormantOfflineProgram_ba: Contact 휴면 전환시, Contact과 관련된 Offline Program 분리보관 및 개인정보 Null처리
 *******************************************************************************************/

public with sharing class KDCE_DormantOrderLineItem_ba implements Database.Batchable<sObject>, Database.Stateful {

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
        query += ' WHERE Order__r.Contact__r.KDCE_IsDormant__c = TRUE AND Order__r.Contact__r.KDCE_ConvertDormantDate__c = TODAY ';
        //query += ' WHERE KDCE_fm_OrderContactId__c IN :batchContactIds';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.KDCE_OrderLineItem__c.fields.getMap();
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid'
        };
        KDCE_ContactSeparateService.separateObject('Dormant', 'KDCE_OrderLineItem__c', 'KDCE_DormantOrderLineItem__c', scope);
    }

    public void finish(Database.BatchableContext BC) {
        KDCE_DormantOrder_ba nextBatch = new KDCE_DormantOrder_ba();
        //nextBatch.batchContactIds = batchContactIds;
        Database.executeBatch(nextBatch, 200);
    }
}