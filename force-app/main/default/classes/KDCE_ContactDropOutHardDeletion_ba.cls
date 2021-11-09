/****************************************************************************************
  * @filename      : KDCE_ContactDropOutHardDeletion_ba
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-02-10
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-02-10             Park HE         Create
    0.1     2021-04-30             Park HE         Edit
****************************************************************************************/
public with sharing class KDCE_ContactDropOutHardDeletion_ba implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext param1) {

        String query = '';
        Datetime targetDT = System.now().addDays(-14);
        //String deleteTargetDt = dt.formatGmt('yyyy-MM-dd\'T\'00:mm:ssZ');
        query += ' SELECT Id ';
        query += ' FROM KDCE_DropOutContact__c ';
        query += ' WHERE CreatedDate < :targetDT';
        query += ' AND KDCE_HardDeletionTarget__c = TRUE ';
        System.debug('query => ' + query);

        return Database.getQueryLocator(query);


        /*
        return Database.getQueryLocator([
                SELECT Id
                FROM KDCE_DropOutContact__c
                WHERE CreatedDate < LAST_N_DAYS:14 AND KDCE_HardDeletionTarget__c = TRUE
        ]);
        */
    }
    public void execute(Database.BatchableContext param1, List<SObject> scope) {
        List<KDCE_DropOutContact__c> dummyContacts = (List<KDCE_DropOutContact__c>) scope;

        delete dummyContacts;
    }

    @SuppressWarnings('PMD')
    public void finish(Database.BatchableContext param1) {
        
    }

}