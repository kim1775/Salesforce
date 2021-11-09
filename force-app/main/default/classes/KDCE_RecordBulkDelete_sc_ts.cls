/****************************************************************************************
 * @filename      : KDCE_RecordBulkDelete_sc_ts
 * @projectname   : 
 * @author        : i2max_SeokHo
 * @date          : 2021-03-26 오전 10:42
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2021-03-26 오전 10:42      i2max_SeokHo         Create
 ****************************************************************************************/

@isTest
private class KDCE_RecordBulkDelete_sc_ts {
    @isTest
    static void testBehavior() {
        KDCE_RecordBulkDelete_sc.runSchedule();
        KDCE_RecordBulkDelete_sc.abortSchedule();
        KDCE_RecordBulkDelete_sc.executeBatch();
    }
}