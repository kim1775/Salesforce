/****************************************************************************************
  * @filename      : KDCE_DormantContact_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-04 오후 1:15
  * @group         : 
  * @group-content : 
  * @description   : Contact이 휴면 Contact으로 전환될경우, Dormant Contact 생성 후 해당 Contact 필드 null 처리하는 배치
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-06-04 오후 1:15     i2max_Jihyun.Lee        Create
****************************************************************************************/
/*******************************************************************************************
 * Serial Batch Order
 * 1. KDCE_DormantContact_ba:        Contact 휴면 처리 (Contact 정보 Null처리). Member일 경우는 분리보관 및 개인정보 Null처리
 * 2. KDCE_DormantCase_ba:           Contact 휴면 전환시, Contact과 관련된 Case 분리보관 및 개인정보 Null처리
 * 3. KDCE_DormantOrderLineItem_ba:  Contact 휴면 전환시, Contact과 관련된 Order Line Item 분리보관 및 개인정보 Null처리
 * 4. KDCE_DormantOrder_ba:          Contact 휴면 전환시, Contact과 관련된 Order 분리보관 및 개인정보 Null처리
 * 5. KDCE_DormantOfflineProgram_ba: Contact 휴면 전환시, Contact과 관련된 Offline Program 분리보관 및 개인정보 Null처리
 *******************************************************************************************/


public with sharing class KDCE_DormantContact_ba implements Database.Batchable<sObject>, Database.Stateful {

    private final static Id RT_Contact_AnonymousId      = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Anonymous').getRecordTypeId();    // 고객 : Anonymous
    private final static Id RT_Contact_ProspectId       = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Prospect').getRecordTypeId();     // 고객 : Prospect
    private final static Id RT_Contact_MemberId         = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Member').getRecordTypeId();       // 고객 : iqos.com 회원 멤버

    String objectName = 'CONTACT';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> conFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

    //Set<Id> batchContactIds = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        // 오브젝트에 해당하는 전체 필드 가져오기
        for (String fieldName : conFieldMap.keySet()) {
            if (query != 'SELECT ') query += ' , ';     // 첫번째 필드가 아닐 경우 , 붙이기
            query += fieldName;
        }
        query += ' FROM ';
        query += objectName;
        if (!Test.isRunningTest()) query += ' WHERE KDCE_fm_IsTargetDormant__c = TRUE ';
        if (!Test.isRunningTest()) query += ' AND (RecordType.DeveloperName = \'Contact_Member\' ) ';
        if (!Test.isRunningTest()) query += ' AND CCR_DatabaseOptin__c = TRUE AND KDCE_IsDormant__c = FALSE ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.Contact.fields.getMap();

        // Null처리하면 안되는 필드 저장
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid', 'accountid', 'kdce_externalid__c', 'kdce_registrationchannel__c', 'kdce_registrationdate__c', 'kdce_registrationobject__c',
                'kdce_isdropout__c', 'kdce_dropoutdate__c', 'kdce_isrequestdropout__c', 'kdce_dropoutrequestdate__c',
                'kdce_isdormant__c', 'kdce_convertdormantdate__c', 'kdce_reactivatedormantdate__c'
        };


        /*
        for (Contact con : (List<Contact>) scope) {
            batchContactIds.add(con.Id);    // 다음 배치에서 Order, Case NULL처리할 배치
        }
        System.debug('=== batchContactIds : ' + batchContactIds);
        */

        // Member인 경우만 분리보관
        // Contact 휴면처리인 경우 null처리
        KDCE_ContactSeparateService.separateObject('Dormant', 'Contact', 'KDCE_DormantContact__c', scope);
        KDCE_ContactSeparateService.setNullField('Dormant','Contact', scope, objectSchema, notNullField, null);

    }

    public void finish(Database.BatchableContext BC) {
        /*
        if(!batchContactIds.isEmpty()) {
            KDCE_DormantCase_ba nextBatch = new KDCE_DormantCase_ba();
            nextBatch.batchContactIds = batchContactIds;
            Database.executeBatch(nextBatch, 2000);
        }
        */
        KDCE_DormantCase_ba nextBatch = new KDCE_DormantCase_ba();
        Database.executeBatch(nextBatch, 200);
    }

}