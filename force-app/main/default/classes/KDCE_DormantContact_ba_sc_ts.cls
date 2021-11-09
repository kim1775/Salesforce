/****************************************************************************************
  * @filename      : KDCE_DormantContact_ba_sc_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-07
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
    0.1     2021-07-07             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_DormantContact_ba_sc_ts {

    @isTest
    static void testBehavior() {
        KDCE_DormantContact_ba_sc.runSchedule();
        KDCE_DormantContact_ba_sc.abortSchedule();
        KDCE_DormantContact_ba_sc.executeBatch();

    }
}