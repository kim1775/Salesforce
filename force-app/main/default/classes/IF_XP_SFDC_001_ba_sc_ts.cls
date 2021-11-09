/****************************************************************************************
  * @filename      : IF_XP_SFDC_001_ba_sc_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-12
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
    0.1     2021-07-12             Park HE         Create
****************************************************************************************/
@IsTest
public with sharing class IF_XP_SFDC_001_ba_sc_ts {
    @IsTest
    static void testBehavior() {
        IF_XP_SFDC_001_ba_sc.runSchedule();
        IF_XP_SFDC_001_ba_sc.abortSchedule();
        IF_XP_SFDC_001_ba_sc.executeBatch(); 
    }
}