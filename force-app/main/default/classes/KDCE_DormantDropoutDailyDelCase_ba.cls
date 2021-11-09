/****************************************************************************************
  * @filename      : KDCE_DormantDropoutDailyDelCase_ba
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-20
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
    0.1     2021-06-20             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_DormantDropoutDailyDelCase_ba implements Database.Batchable<SObject>, Database.Stateful {

    /*public String jobId;
    public Boolean isNextBatch = true;*/

    public Set<Id> delTargetContactIds;
    private static List<String> deleteSObject = new List<String>{
            'KDCE_DormantCase__c',
            'KDCE_DropoutCase__c'
    };

    public static List<String> getDeleteSObject() {
        return deleteSObject.clone();
    }

    private List<String> copiedTargetSObjects;

    private String deleteTargetSObject;

    class DeleteTargetException extends Exception {
    }

    // 기본 생성자 은닉화.
    @SuppressWarnings('PMD')
    @TestVisible
    private KDCE_DormantDropoutDailyDelCase_ba() {
    }

    public KDCE_DormantDropoutDailyDelCase_ba(List<String> targetSObjects) {
        copiedTargetSObjects = targetSObjects.clone();
        deleteTargetSObject = copiedTargetSObjects.remove(0);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (!deleteSObject.contains(this.deleteTargetSObject)) {
            throw new DeleteTargetException('삭제 대상 SObject가 아닙니다.');
        }
        String query = '';
        Integer lastYear = -3;
        Date d = Date.today().addYears(lastYear);
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        String deleteTargetDt = dt.formatGmt('yyyy-MM-dd\'T\'00:mm:ssZ');
        query += 'SELECT Id, CreatedDate__c, ContactId__c ';
        query += 'FROM ' + deleteTargetSObject;
        if(!Test.isRunningTest()) query += ' WHERE CreatedDate__c < ' + deleteTargetDt;
        System.debug('deleteTargetSObject => ' + deleteTargetSObject);
        System.debug('query => ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Set<Id> contIds = new Set<Id>();

        if(deleteTargetSObject == 'KDCE_DropOutCase__c'){
            for(KDCE_DropOutCase__c item : (List<KDCE_DropOutCase__c>)scope){
                contIds.add(item.ContactId__c);
            }

            List<KDCE_DropOutContact__c> checkList = [SELECT Id, KDCE_DeleteCheckTarget__c FROM KDCE_DropOutContact__c WHERE ContactId__c IN :contIds];
            for(KDCE_DropOutContact__c row : checkList){
                row.KDCE_DeleteCheckTarget__c = true;
            }
            Database.update(checkList, false);
        }

        Database.delete(scope, false);
        //delete scope;
        //if(!contIds.isEmpty()) delTargetContactIds.addAll(contIds);
    }

    public void finish(Database.BatchableContext bc) {

        if (this.copiedTargetSObjects.size() != 0) {
            KDCE_DormantDropoutDailyDelCase_ba ba = new KDCE_DormantDropoutDailyDelCase_ba(this.copiedTargetSObjects);
            //ba.delTargetContactIds = delTargetContactIds;
            Database.executeBatch(ba, 200);
        }
        else {
            KDCE_DropoutDailyCheckHardDelContact_ba ba = new KDCE_DropoutDailyCheckHardDelContact_ba();
            //ba.delTargetContIds = delTargetContactIds;
            Database.executeBatch(ba, 200);
        }

    }
}