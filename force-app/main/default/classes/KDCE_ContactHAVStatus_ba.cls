/****************************************************************************************
  * @filename      : KDCE_ContactHAVStatus_ba
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-22 오후 2:18
  * @group         : 
  * @group-content : 
  * @description   : HAV 재인증 대상별, Age Verification (CCR_AgeVerificationStatus__c) 업데이트
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-04-22 오후 2:18     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_ContactHAVStatus_ba implements Database.Batchable<sObject>, Database.Stateful {

    private final static Id RT_Contact_MemberId         = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Member').getRecordTypeId();       // 고객 : iqos.com 회원 멤버

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        query += ' SELECT Id, CCR_AgeVerificationStatus__c, KDCE_fm_AgeVerificationExpiryDate__c, CCR_AVStatusDateChange__c       ';
        query += ' FROM Contact                                 ';
        if (!Test.isRunningTest()) query += ' WHERE KDCE_fm_IsAgeReVerification__c = TRUE       ';
        if (!Test.isRunningTest()) query += ' AND CCR_AgeVerificationStatus__c = \'Verified\'   ';
        if (!Test.isRunningTest()) query += ' AND RecordTypeId = :RT_Contact_MemberId           ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        for (Contact con : (List<Contact>) scope) {
            con.CCR_AgeVerificationStatus__c = 'Expired';
            con.CCR_AVStatusDateChange__c = System.now();
        }

        update scope;
    }

    @SuppressWarnings('PMD')
    public void finish(Database.BatchableContext BC) {

    }
}