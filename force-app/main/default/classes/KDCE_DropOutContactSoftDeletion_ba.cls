/****************************************************************************************
  * @filename      : KDCE_DropOutContactSoftDeletion_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-11 오전 10:14
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
    0.1     2021-06-11 오전 10:14     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_DropOutContactSoftDeletion_ba implements Database.Batchable<sObject>, Database.Stateful {
    private final static Id RT_Contact_ProspectId  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Prospect').getRecordTypeId();     // 고객 : Prospect
    String objectName = 'CONTACT';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> conFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
    //Set<Id> batchContactIds = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('===== START :: Dropout CONTACT SoftDel ===== ');

        Datetime d = System.today().addYears(-1);
        Datetime dt = (Datetime)Date.newInstance(d.year(), d.month(), d.day());
        String deleteTargetDt = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');

        // 오브젝트에 해당하는 전체 필드 가져오기
        for (String fieldName : conFieldMap.keySet()) {
            if (query != 'SELECT ') query += ' , ';     // 첫번째 필드가 아닐 경우 , 붙이기
            query += fieldName;
        }
        query += ' FROM ';
        query += objectName;
        //if (!Test.isRunningTest()) query += ' WHERE (KDCE_IsRequestDropout__c = TRUE AND KDCE_IsDropout__c = FALSE AND KDCE_DropoutRequestDate__c = TODAY) '; //
        //if (!Test.isRunningTest()) query += ' OR (KDCE_fm_LastActivityDate__c < ' + deleteTargetDt + ' AND RecordTypeId =\''+ RT_Contact_ProspectId+'\' ) ';
        if (!Test.isRunningTest()) query += ' WHERE (KDCE_IsRequestDropout__c = TRUE AND KDCE_IsDropout__c = FALSE AND KDCE_DropoutRequestDate__c < LAST_N_DAYS:30 ) '; // Member Contact이 탈퇴요청을 한 경우 todo :: 날짜조건 나중에 확인필요(현0629. lastNDays:30이면,0529날짜가 분리저장 타겟 )
        if (!Test.isRunningTest()) query += ' OR (KDCE_fm_LastActivityDate__c < ' + deleteTargetDt + ' AND RecordTypeId = \'' + RT_Contact_ProspectId + '\' ) ';        // Prospect Contact의 마지막 활동이 1년이 경과한 경우

        //if (!Test.isRunningTest()) query += ' WHERE KDCE_Mig_Delete__c = True AND CCR_DatabaseOptin__c = False AND KDCE_IsDropout__c = FALSE AND KDCE_ConvertedConsumer__c = false ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('===== EXECUTE :: Dropout CONTACT SoftDel ===== ');

        Map<String, Schema.SObjectField> objectSchema = Schema.SObjectType.Contact.fields.getMap();

        // Null처리하면 안되는 필드 저장
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid', 'accountid', 'kdce_externalid__c', 'kdce_registrationchannel__c', 'kdce_registrationdate__c', 'kdce_registrationobject__c',
                'kdce_isdropout__c', 'kdce_dropoutdate__c', 'kdce_isrequestdropout__c', 'kdce_dropoutrequestdate__c',
                'kdce_isdormant__c', 'kdce_convertdormantdate__c', 'kdce_reactivatedormantdate__c'
        };

        Set<String> kakaoIds = new Set<String>();

        for (Contact con : (List<Contact>) scope) {
            if(con.KDCE_KakaoId__c != null) kakaoIds.add(con.KDCE_KakaoId__c);
        }

        List<Kakao_User_Mapping__c> kumList = [SELECT Id FROM Kakao_User_Mapping__c WHERE App_User_Id__c IN :kakaoIds];
        /*
        for (Contact con : (List<Contact>) scope) {
            batchContactIds.add(con.Id);    // 다음 배치에서 Order, Case NULL처리할 배치
        }
        */

        // Member인 경우만 분리보관
        // Contact 휴면처리인 경우 null처리
        KDCE_ContactSeparateService.separateObject('DropOut', 'Contact', 'KDCE_DropOutContact__c', scope);
        KDCE_ContactSeparateService.setNullField('DropOut','Contact', scope, objectSchema, notNullField, null);

        if(kumList.size() > 0) Database.delete(kumList, false);
    }

    public void finish(Database.BatchableContext BC) {

        KDCE_DropOutCaseSoftDeletion_ba nextBatch = new KDCE_DropOutCaseSoftDeletion_ba();
        Database.executeBatch(nextBatch, 200);

        /*
        if(!batchContactIds.isEmpty()) {
            KDCE_DropOutCaseSoftDeletion_ba nextBatch = new KDCE_DropOutCaseSoftDeletion_ba();
            nextBatch.batchContactIds = batchContactIds;
            Database.executeBatch(nextBatch, 500);
        }
        */
    }
}