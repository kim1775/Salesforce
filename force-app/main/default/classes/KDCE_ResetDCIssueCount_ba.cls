/****************************************************************************************
  * @filename      : KDCE_ResetDCIssueCount_ba
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-31
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-31          i2max_JE Yoon             Create
****************************************************************************************/
public class KDCE_ResetDCIssueCount_ba implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        query += 'SELECT KDCE_DCIssueCount__c';
        query += '  FROM Contact';
        query += '  WHERE KDCE_DCIssueCount__c > 0';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        if (!scope.isEmpty()) {
            for (Contact contact : scope) {
                contact.KDCE_DCIssueCount__c = 0;
            }
            update scope;
            scope.clear();
        }
    }

    public void finish(Database.BatchableContext BC) {

    }
}