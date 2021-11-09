/****************************************************************************************
  * @filename      : KDCE_LiveOrderNull_ba
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-13
  * @group         :
  * @group-content :
  * @description   : 5년 이상 된 Prospect 고객의 Order 레코드 중 개인정보 관련 데이터 Null 처리
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-06-13             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_LiveOrderNull_ba implements Database.Batchable<SObject>{

    public Set<Id> batchContactIds;

    String objectName = 'KDCE_Order__c';
    String query = 'SELECT ';
    Map<String, Schema.SObjectField> orderFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();


    public Database.QueryLocator start(Database.BatchableContext BC) {

        Integer lastYear = -5;
        Datetime deleteTargetDt = (Datetime.now().addYears(lastYear)).dateGMT();
        //Date targetDate = Date.today().addYears(-5);

        for (String fieldName : orderFieldMap.keySet()) {
            if (query != 'SELECT ') query += ' ,';      // 첫번째 필드가 아닐 경우 , 붙이기
            query += fieldName;
        }
        query += ' FROM ';
        query += objectName;
        if (!Test.isRunningTest()) query += ' WHERE Contact__r.RecordType.DeveloperName = \'Contact_Prospect\' ';// AND Id =\'a1R1m000000hNgOEAU\'';
        if (!Test.isRunningTest()) query += ' AND CreatedDate < :deleteTargetDt AND Contact__c != null ';

        System.debug('query : ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('KDCE_LiveOrderNull_ba : ' + scope);

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

        KDCE_ContactSeparateService.setNullField('RoekDropOut', 'KDCE_Order__c', scope, objectSchema, notNullField, orderPersonalField);

    }

    @SuppressWarnings('PMD')
    public void finish(Database.BatchableContext BC) {

    }
}