/****************************************************************************************
  * @filename      : KDCE_AdverseEventCaseDel_sc
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-08
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
    0.1     2021-06-08             Park HE         Create
****************************************************************************************/
global with sharing class KDCE_AdverseEventCaseDel_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = '[Case] Delete 6-Adverse Event Case (3 months have passed)';

    // TODO 배치 주기는 추후 정의
    // Schedule Cron Expression
    private static String batchCron = '0 20 2 * * ? *';

    // Batch 수행 Size
    private static Integer batchSize = 200;

    global void execute(SchedulableContext SC) {
        KDCE_AdverseEventCaseDel_sc.executeBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new KDCE_AdverseEventCaseDel_sc());
    }

    /**
     *  배치 Schedule 삭제
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if (!Test.isRunningTest()) System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     */
    public static void executeBatch() {
        KDCE_RecordBulkDelete_ba nextBa = new KDCE_RecordBulkDelete_ba();
        String query ='';
        Date conditionDate;
        if(conditionDate == null) conditionDate = Date.today();
        String objName = 'Case';
        String recordType = 'CCR_AdverseEvent';
        Integer lastMonth = -3;
        String day = String.valueOf(conditionDate.addMonths(Integer.valueOf(lastMonth))) + 'T23:59:59.000Z'; // 3달이 지나면 삭제
        query += 'SELECT Id, CreatedDate, RecordType.DeveloperName ';
        query += ' FROM';
        query += ' ' + objName;
        query += ' WHERE CreatedDate <= ' + day;
        query += ' AND RecordType.DeveloperName = \'' + recordType + '\'';

        System.debug('query => ' + query);

        nextBa.query = query;

        Database.executeBatch(nextBa, batchSize);
    }
}