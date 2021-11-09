/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-03-16 오후 3:37
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-03-16 오후 3:37     i2max_Junseok.Kwon        Create
****************************************************************************************/

global without sharing class KDCE_RecordBulkDelete_ba implements Database.Batchable<SObject>, Database.Stateful {

    global String query = '';

    global Database.QueryLocator start(Database.BatchableContext BC) {

        /*if(conditionDate == null) conditionDate = Date.today();
        String objName = 'Case';
        String recordType = 'CCR_AdverseEvent';
        Integer lastMonth = -3;
        String day = String.valueOf(conditionDate.addMonths(Integer.valueOf(lastMonth))) + 'T23:59:59.000Z'; // 3달이 지나면 삭제
        this.query += 'SELECT Id, CreatedDate, RecordType.DeveloperName ';
        this.query += ' FROM';
        this.query += ' ' + objName;
        this.query += ' WHERE CreatedDate <= ' + day;
        this.query += ' AND RecordType.DeveloperName = :recordType';

        System.debug('query => ' + this.query);*/
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        if(scope.size() > 0) Database.delete(scope, false);           //delete scope;
    }

    @SuppressWarnings('PMD')
    global void finish(Database.BatchableContext BC) {

    }
}