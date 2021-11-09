/****************************************************************************************
  * @filename      : KDCE_LiveCaseDel_sc
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-11
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : KDCE_Scheduler_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-06-11             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_LiveCaseDel_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName =  '[Case] Live Case Delete Job (More than 3 Years)';

    // TODO 배치 주기는 추후 정의
    // Schedule Cron Expression
    private static String batchCron = '0 40 5 * * ? *';

    // Batch 수행 Size
    private static Integer batchSize = 200;

    public void execute(SchedulableContext SC) {
        KDCE_RecordBulkDelete_sc.executeBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        if(test.isRunningTest()) batchName = batchName + '_Test';
        System.schedule(batchName, batchCron, new KDCE_RecordBulkDelete_sc());
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
        KDCE_RecordBulkDelete_ba ba = new KDCE_RecordBulkDelete_ba();
        String query = '';
        String sObjName = 'Case';
        Integer lastYear = -3;
        Date d = Date.today().addYears(lastYear);
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        String deleteTargetDt = dt.formatGmt('yyyy-MM-dd\'T\'00:mm:ssZ');
        query += 'SELECT Id, CreatedDate ';
        query += 'FROM ' + sObjName;
        query += ' WHERE CreatedDate < ' + deleteTargetDt ;
        System.debug('query => ' + query);

        ba.query = query;
        Database.executeBatch(ba, batchSize);
    }
}