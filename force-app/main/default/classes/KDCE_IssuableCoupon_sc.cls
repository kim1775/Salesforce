/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-08-12 오후 9:37
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
    0.1     2021-08-12 오후 9:37     i2max_Junseok.Kwon        Create
****************************************************************************************/

public with sharing class KDCE_IssuableCoupon_sc implements Schedulable{

    // Schedule 등록 배치명
    private static String batchName = '[Coupon] Issuable Coupon Management Batch';
    // Schedule Cron Expression (1시간마다)
    private static String batchCron = '0 00 4 * * ?'; //' 0 0 * * * ? *';

    // Batch 수행 Size
    private static Integer batchSize = 2000;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        KDCE_IssuableCoupon_sc.executeBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        if(test.isRunningTest()) batchName = batchName + '_Test';
        System.schedule(batchName, batchCron, new KDCE_IssuableCoupon_sc());
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

        // MGM
        KDCE_IssuableCouponCount_ba batchMGM = new KDCE_IssuableCouponCount_ba();
        batchMGM.couponType = 'MGM';
        Database.executeBatch(batchMGM, batchSize);

        // CVS - CU
        KDCE_IssuableCouponCount_ba batchCU = new KDCE_IssuableCouponCount_ba();
        batchCU.couponType = 'CVS';
        batchCU.cvsChannel = 'CU';
        Database.executeBatch(batchCU, batchSize);

        // CVS - K7
        KDCE_IssuableCouponCount_ba batchK7 = new KDCE_IssuableCouponCount_ba();
        batchK7.couponType = 'CVS';
        batchK7.cvsChannel = 'K7';
        Database.executeBatch(batchK7, batchSize);

        // CVS - GS
        KDCE_IssuableCouponCount_ba batchGS = new KDCE_IssuableCouponCount_ba();
        batchGS.couponType = 'CVS';
        batchGS.cvsChannel = 'GS';
        Database.executeBatch(batchGS, batchSize);

        // CVS - MS
        KDCE_IssuableCouponCount_ba batchMS = new KDCE_IssuableCouponCount_ba();
        batchMS.couponType = 'CVS';
        batchMS.cvsChannel = 'MS';
        Database.executeBatch(batchMS, batchSize);

        // CVS - EM
        KDCE_IssuableCouponCount_ba batchEM = new KDCE_IssuableCouponCount_ba();
        batchEM.couponType = 'CVS';
        batchEM.cvsChannel = 'EM';
        Database.executeBatch(batchEM, batchSize);

        // CVS - CS
        KDCE_IssuableCouponCount_ba batchCS = new KDCE_IssuableCouponCount_ba();
        batchCS.couponType = 'CVS';
        batchCS.cvsChannel = 'CS';
        Database.executeBatch(batchCS, batchSize);

        // CVS - SS
        KDCE_IssuableCouponCount_ba batchSS = new KDCE_IssuableCouponCount_ba();
        batchSS.couponType = 'CVS';
        batchSS.cvsChannel = 'SS';
        Database.executeBatch(batchSS, batchSize);
    }
}