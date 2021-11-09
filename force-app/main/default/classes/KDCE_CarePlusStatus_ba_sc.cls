/****************************************************************************************
  * @filename      : KDCE_CarePlusStatus_ba_sc
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-21
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
    0.1     2021-07-21             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_CarePlusStatus_ba_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = '[Asset] Care Plus Status Expired';

    // TODO 배치 주기는 추후 정의
    // Schedule Cron Expression
    private static String batchCron = '0 30 1 * * ? *';

    // Batch 수행 Size
    private static Integer batchSize = 200;

    public void execute(SchedulableContext SC) {
        KDCE_CarePlusStatus_ba_sc.executeBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        if(test.isRunningTest()) batchName = batchName + '_Test';
        System.schedule(batchName, batchCron, new KDCE_CarePlusStatus_ba_sc());
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
        Database.executeBatch(new KDCE_CarePlusStatus_ba(), batchSize);
    }
}