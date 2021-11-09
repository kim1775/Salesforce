/****************************************************************************************
  * @filename      : KDCE_Scheduler_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-21
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
    0.1     2021-07-21             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_Scheduler_ts {
    @IsTest
    static void testBehavior() {

        KDCE_DormantDropoutDailyDelOLI_ba_sc.runSchedule();
        KDCE_DormantDropoutDailyDelOLI_ba_sc.abortSchedule();
        KDCE_DormantDropoutDailyDelOLI_ba_sc.executeBatch();

        KDCE_CarePlusStatus_ba_sc.runSchedule();
        KDCE_CarePlusStatus_ba_sc.abortSchedule();
        KDCE_CarePlusStatus_ba_sc.executeBatch();

        KDCE_LiveOrderNull_ba_sc.runSchedule();
        KDCE_LiveOrderNull_ba_sc.abortSchedule();
        KDCE_LiveOrderNull_ba_sc.executeBatch();

        KDCE_ContactHAVStatus_ba_sc.runSchedule();
        KDCE_ContactHAVStatus_ba_sc.abortSchedule();
        KDCE_ContactHAVStatus_ba_sc.executeBatch();

        KDCE_LiveCaseDel_sc.runSchedule();
        KDCE_LiveCaseDel_sc.abortSchedule();
        KDCE_LiveCaseDel_sc.executeBatch();

        KDCE_ContactDropOutHardDeletion_ba_sc.runSchedule();
        KDCE_ContactDropOutHardDeletion_ba_sc.abortSchedule();
        KDCE_ContactDropOutHardDeletion_ba_sc.executeBatch();

        KDCE_IssuableCoupon_sc.runSchedule();
        KDCE_IssuableCoupon_sc.abortSchedule();
        KDCE_IssuableCoupon_sc.executeBatch();
    }
}