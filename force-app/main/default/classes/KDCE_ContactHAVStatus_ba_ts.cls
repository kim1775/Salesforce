/****************************************************************************************
  * @filename      : KDCE_ContactHAVStatus_ba_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-14 오후 5:45
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
    0.1     2021-06-14 오후 5:45     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_ContactHAVStatus_ba_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        Test.startTest();
        KDCE_ContactHAVStatus_ba batch = new KDCE_ContactHAVStatus_ba();
        Database.executeBatch(batch, 2000);
        Test.stopTest();
    }
}