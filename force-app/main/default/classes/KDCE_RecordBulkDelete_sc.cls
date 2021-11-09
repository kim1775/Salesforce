/****************************************************************************************
 * @filename      : KDCE_RecordBulkDelete_sc
 * @projectname   : 
 * @author        : i2max_SeokHo
 * @date          : 2021-03-23 오후 4:25
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2021-03-23 오후 4:25      i2max_SeokHo         Create
 ****************************************************************************************/

global without sharing class  KDCE_RecordBulkDelete_sc implements Schedulable  {

    // Schedule 등록 배치명
    private static String batchName = '[Case] 3달이 지난 RecordType : 6-Adverse Event 삭제';

    // TODO 배치 주기는 추후 정의
    // Schedule Cron Expression
    private static String batchCron = '0 15 * * * ? ';

    // Batch 수행 Size
    private static Integer batchSize = 200;

    global void execute(SchedulableContext SC) {
        KDCE_RecordBulkDelete_sc.executeBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new KDCE_RecordBulkDelete_sc());
    }

    /**
     *  배치 Schedule 삭제
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출) 
     */
    public static void executeBatch() {
        KDCE_RecordBulkDelete_ba nextBa = new KDCE_RecordBulkDelete_ba();
        nextBa.query = 'SELECT Id From Case Where CreatedDate < Last_N_Years:3';
//        nextBa.query = 'SELECT Id From KDCE_DropOutCase__c Where CreatedDate__c < Last_N_Years:3';
//        nextBa.query = 'SELECT Id From KDCE_DormantCase__c Where CreatedDate__c < Last_N_Years:3';

        // order는 delete 아님님
//       nextBa.query = 'SELECT Id From KDCE_DormantOrder__c Where CreatedDate__c < Last_N_Years:5';
//        nextBa.query = 'SELECT Id From KDCE_DropOutOrder__c Where CreatedDate__c < Last_N_Years:5';


        Database.executeBatch(nextBa, batchSize);
    }
}