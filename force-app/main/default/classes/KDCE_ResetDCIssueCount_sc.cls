/****************************************************************************************
  * @filename      : KDCE_ResetDCIssueCount_sc
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-31
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-31          i2max_JE Yoon             Create
****************************************************************************************/
global class KDCE_ResetDCIssueCount_sc implements Schedulable {
    global void execute(SchedulableContext sc) {
        KDCE_ResetDCIssueCount_ba batch = new KDCE_ResetDCIssueCount_ba();
        Database.executeBatch(batch, 200);
    }
}