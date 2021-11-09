/****************************************************************************************
  * @filename      : KDCE_AdverseEventCaseDel_sc_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-18
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
    0.1     2021-06-18             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_AdverseEventCaseDel_sc_ts {
    @IsTest
    static void testBehavior() {
        KDCE_AdverseEventCaseDel_sc.runSchedule();
        KDCE_AdverseEventCaseDel_sc.abortSchedule();
        KDCE_AdverseEventCaseDel_sc.executeBatch();
    }
}