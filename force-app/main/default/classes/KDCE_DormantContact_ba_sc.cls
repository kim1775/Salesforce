/****************************************************************************************
  * @filename      : KDCE_DormantContact_ba_sc
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-22 오후 5:01
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
    0.1     2021-06-22 오후 5:01     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_DormantContact_ba_sc implements Schedulable{

    // Schedule 등록 배치명
    private static String batchName = '[Contact] Dormant Contact';
    // Schedule Cron Expression (정각)
    private static String batchCron = '0 40 2 * * ?'; //' 0 0 * * * ? *';

    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        KDCE_DormantContact_ba_sc.executeBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        if(test.isRunningTest()) batchName = batchName + '_Test';
        System.schedule(batchName, batchCron, new KDCE_DormantContact_ba_sc());
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
        Database.executeBatch(new KDCE_DormantContact_ba(), batchSize);
    }
}