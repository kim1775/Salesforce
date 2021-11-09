/****************************************************************************************
  * @filename      : KDCE_MCEmailLog_tr_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-22 오후 4:28
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
    0.1     2021-06-22 오후 4:28     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_MCEmailLog_tr_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        KDCE_MCEmailLog__c mcLog = new KDCE_MCEmailLog__c();
        mcLog.KDCE_SubscriberKey__c = KDCE_TestUtil.contactMember.Id;
        mcLog.KDCE_EmailOptout__c = true;
        mcLog.KDCE_External_ID__c = 'TestMCEmailLog';
        insert mcLog;
        update mcLog;
    }
}