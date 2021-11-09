/****************************************************************************************
 * @filename      : KDCE_RecordBulkDelete_ba_ts
 * @projectname   : 
 * @author        : i2max_SeokHo
 * @date          : 2021-03-26 오전 10:40
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
 0.1     2021-03-26 오전 10:40      i2max_SeokHo         Create
 ****************************************************************************************/

@isTest
private class KDCE_RecordBulkDelete_ba_ts {
    @isTest
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
        KDCE_RecordBulkDelete_ba ba = new KDCE_RecordBulkDelete_ba();
        ba.query = 'Select Id From Contact Limit 1';
        Database.executeBatch(ba, 1);
    }
}