/****************************************************************************************
  * @filename      : KDCE_LiveOrderNull_ba_ts
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
private class KDCE_LiveOrderNull_ba_ts {
    @IsTest
    static void testBehavior() {
        Contact con = KDCE_TestUtil.contactProspect.clone(true);
        KDCE_Order__c order = KDCE_TestBizUtil.order.clone(false);
        order.Contact__c = con.Id;
        insert order;
        test.setCreatedDate(order.Id, System.now().addYears(-5).addDays(-5));

        Test.startTest();
        Database.executeBatch(new KDCE_LiveOrderNull_ba(), 200 );
        Test.stopTest();

    }

    @IsTest
    static void testScheduler() {
        KDCE_LiveOrderNull_ba_sc.runSchedule();
        KDCE_LiveOrderNull_ba_sc.abortSchedule();
        KDCE_LiveOrderNull_ba_sc.executeBatch();
    }
}