/****************************************************************************************
  * @filename      : KDCE_ContactDropOutHardDeletion_ba_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-02
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
    0.1     2021-06-02             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_ContactDropOutHardDeletion_ba_ts {
    @IsTest
    static void testBehavior() {
        KDCE_DropOutContact__c dropOutCon = new KDCE_DropOutContact__c(Name='testDor', KDCE_HardDeletionTarget__c = true);
        insert dropOutCon;
        Test.setCreatedDate(dropOutCon.Id, System.today().addDays(-15));
        System.debug(dropOutCon);

        Test.startTest();
        Database.executeBatch(new KDCE_ContactDropOutHardDeletion_ba(), 200);
        Test.stopTest();

    }

    @IsTest
    static void testScheduler() {
        KDCE_ContactDropOutHardDeletion_ba_sc.runSchedule();
        KDCE_ContactDropOutHardDeletion_ba_sc.abortSchedule();
        KDCE_ContactDropOutHardDeletion_ba_sc.executeBatch();
    }
}