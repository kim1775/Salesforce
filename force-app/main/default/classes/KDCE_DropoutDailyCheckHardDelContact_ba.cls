/****************************************************************************************
  * @filename      : KDCE_DropoutDailyCheckHardDelContact_ba
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-11
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : KDCE_DormantDropoutDailyDelOLI_ba_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-06-11             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_DropoutDailyCheckHardDelContact_ba implements Database.Batchable<SObject>, Database.Stateful {

    public Set<Id> delTargetContIds ;

    public String whereClause;

    public Database.QueryLocator start(Database.BatchableContext param1) {

        String query = '';
        String sObjectStr = 'KDCE_DropoutContact__c';
        query += ' SELECT ';
        query += ' Id, KDCE_HardDeletionTarget__c, ContactId__c ';
        query += ' FROM ' + sObjectStr;
        if(whereClause != null && whereClause != '') query += whereClause;
        else query += ' WHERE KDCE_DeleteCheckTarget__c = TRUE ';
        System.debug('query => ' + query);

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext param1, List<KDCE_DropOutContact__c> scope) {

        Set<Id> contactIds = new Set<Id>();
        for(KDCE_DropOutContact__c row : scope){
            contactIds.add(row.ContactId__c);
        }

        /*
        List<KDCE_DropOutOrder__c> dropOrder = [SELECT Id, Contact__c FROM KDCE_DropOutOrder__c WHERE Contact__c IN : contactIds];
        List<KDCE_DropOutCase__c> dropCase = [SELECT Id , ContactId__c FROM KDCE_DropOutCase__c WHERE ContactId__c IN : contactIds];
        List<KDCE_DropOutOfflineProgram__c> dropOffline = [SELECT Id, Contact__c  FROM KDCE_DropOutOfflineProgram__c WHERE Contact__c IN : contactIds];

        Map<Id, KDCE_DropOutOrder__c> dropoutContactByOrder = new Map<Id, KDCE_DropOutOrder__c>();
        Map<Id, KDCE_DropOutCase__c> dropoutContByCase = new Map<Id, KDCE_DropOutCase__c>();
        Map<Id, KDCE_DropOutOfflineProgram__c> dropoutContactByOffline = new Map<Id, KDCE_DropOutOfflineProgram__c>();
        */

        Set<Id> nonDeleteIds = new Set<Id>();

        for(KDCE_DropOutOrder__c item : [
                SELECT Id, Contact__c FROM KDCE_DropOutOrder__c WHERE Contact__c IN :contactIds
        ]){
            nonDeleteIds.add(item.Contact__c);
        }

        for(KDCE_DropOutCase__c item : [
                SELECT Id, ContactId__c FROM KDCE_DropOutCase__c WHERE ContactId__c IN :contactIds
        ]){
            nonDeleteIds.add(item.ContactId__c);
        }

        for(KDCE_DropOutOfflineProgram__c item : [
                SELECT Id, Contact__c  FROM KDCE_DropOutOfflineProgram__c WHERE Contact__c IN :contactIds
        ]){
            nonDeleteIds.add(item.Contact__c);
        }

        List<KDCE_DropOutContact__c> updateContacts = new List<KDCE_DropOutContact__c>();

        // ContactId가 DropOutOrder/DropOutOfflineProgram/DropOutCase에 없는 경우,
        // HardDeletionTarget = true로 업데이트하고
        // HardDeletion 배치에서 삭제한다.
        for(KDCE_DropOutContact__c dropCont : scope){

            dropCont.KDCE_DeleteCheckTarget__c = false;

            if(!nonDeleteIds.contains(dropCont.ContactId__c)){
                dropCont.KDCE_HardDeletionTarget__c = true;
                //updateContacts.add(dropCont);
            }
        }

        Database.update(scope, false);

        //if(updateContacts.size() > 0) update updateContacts;

        /*
        List<KDCE_DropOutOrder__c> dropOrder = [SELECT Id, Contact__c FROM KDCE_DropOutOrder__c WHERE Contact__c IN : delTargetContIds];
        List<KDCE_DropOutCase__c> dropCase = [SELECT Id , ContactId__c FROM KDCE_DropOutCase__c WHERE ContactId__c IN : delTargetContIds];
        List<KDCE_DropOutOfflineProgram__c> dropOffline = [SELECT Id, Contact__c  FROM KDCE_DropOutOfflineProgram__c WHERE Contact__c IN : delTargetContIds];
        System.debug('dropOrder ' + dropOrder);
        System.debug('dropCase ' + dropCase);
        System.debug('dropOffline ' + dropOffline);

        Map<Id, KDCE_DropOutOrder__c> dropoutContactByOrder = new Map<Id, KDCE_DropOutOrder__c>();
        Map<Id, KDCE_DropOutCase__c> dropoutContByCase = new Map<Id, KDCE_DropOutCase__c>();
        Map<Id, KDCE_DropOutOfflineProgram__c> dropoutContactByOffline = new Map<Id, KDCE_DropOutOfflineProgram__c>();

        for(KDCE_DropOutOrder__c item : dropOrder){
            dropoutContactByOrder.put(item.Contact__c, item);
        }

        for(KDCE_DropOutCase__c item : dropCase){
            dropoutContByCase.put(item.ContactId__c, item);
            System.debug(item);
            System.debug(dropoutContByCase);
        }

        for(KDCE_DropOutOfflineProgram__c item : dropOffline){
            dropoutContactByOffline.put(item.Contact__c, item);
        }

        List<KDCE_DropOutContact__c> updateContacts = new List<KDCE_DropOutContact__c>();
        
        // ContactId가 DropOutOrder/DropOutOfflineProgram/DropOutCase에 없는 경우,
        // HardDeletionTarget = true로 업데이트하고
        // HardDeletion배치에서 삭제한다.
        for(KDCE_DropOutContact__c dropCont : scope){
            if(!dropoutContactByOrder.containsKey(dropCont.ContactId__c) && !dropoutContactByOffline.containsKey(dropCont.ContactId__c) &&
                    !dropoutContByCase.containsKey(dropCont.ContactId__c)){

                dropCont.KDCE_HardDeletionTarget__c = true;
                updateContacts.add(dropCont);
            }
        }

        if(!updateContacts.isEmpty()) update updateContacts;
         */
    }

    @SuppressWarnings('PMD')
    public void finish(Database.BatchableContext param1) {
        // Hard Deletion 따로 빼기
//        KDCE_ContactDropOutHardDeletion_ba ba = new KDCE_ContactDropOutHardDeletion_ba();
//        Database.executeBatch(ba, 200);
    }
}