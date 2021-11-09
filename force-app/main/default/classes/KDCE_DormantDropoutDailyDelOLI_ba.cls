/****************************************************************************************
  * @filename      : KDCE_DormantDropoutDailyDelOLI_ba
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
public with sharing class KDCE_DormantDropoutDailyDelOLI_ba implements Database.Batchable<SObject>, Database.Stateful {

    /*public String jobId;
    public Boolean isNextBatch = true;*/

    public  Set<Id> delTargetContactIds;
    private static List<String> deleteSObject = new List<String>{
            'KDCE_DormantOrderLineItem__c',
            'KDCE_DropoutOrderLineItem__c'
    };

    public static List<String> getDeleteSObject() {
        return deleteSObject.clone();
    }

    private List<String>    copiedTargetSObjects;

    private String          deleteTargetSObject;

    class DeleteTargetException extends Exception {}

    // 기본 생성자 은닉화.
    @SuppressWarnings('PMD')
    //@TestVisible
    private KDCE_DormantDropoutDailyDelOLI_ba() {}

    public KDCE_DormantDropoutDailyDelOLI_ba(List<String> targetSObjects) {
        copiedTargetSObjects = targetSObjects.clone();
        deleteTargetSObject = copiedTargetSObjects.remove(0);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('deleteTargetSObject :::: ' + deleteTargetSObject);
        if(!deleteSObject.contains(this.deleteTargetSObject)) {
            throw new DeleteTargetException('삭제 대상 SObject가 아닙니다.');
        }
        String query = '';
        Integer lastYear = -5;
        Date d = Date.today().addYears(lastYear);
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        //String deleteTargetDt = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        String deleteTargetDt = dt.formatGmt('yyyy-MM-dd\'T\'00:mm:ssZ');
        query += 'SELECT Id, CreatedDate__c ';
        query += 'FROM ' + deleteTargetSObject;
        if(!Test.isRunningTest()) query += ' WHERE CreatedDate__c < ' + deleteTargetDt;

        System.debug('query => ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        //delete scope;
        Database.delete(scope, false);
    }

    public void finish(Database.BatchableContext bc) {

        if (this.copiedTargetSObjects.size() != 0) {
            KDCE_DormantDropoutDailyDelOLI_ba ba = new KDCE_DormantDropoutDailyDelOLI_ba(this.copiedTargetSObjects);
            Database.executeBatch(ba, 200);
        }else {
            Database.executeBatch(new KDCE_DormantDropoutDailyDelOrder_ba(KDCE_DormantDropoutDailyDelOrder_ba.getDeleteSObject()), 200);
        }
    }
}