/****************************************************************************************
  * @filename      : KDCE_CarePlusStatus_ba_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-05-28
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
    0.1     2021-05-28             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_CarePlusStatus_ba_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior1() {
        Test.startTest();

        Asset asset = KDCE_TestUtil.assetCharger.clone(true);
        asset.CCR_CarePlusDueDate__c = System.Today().addDays(-1);
        asset.KDCE_ReplacementSource__c = 'Qure';
        update asset;

        KDCE_CarePlusStatus_ba ba = new KDCE_CarePlusStatus_ba();
        Id batchId = Database.executeBatch(ba);
        Test.stopTest();

    }

    @IsTest
    static void testBehavior2() {
        Test.startTest();

        Asset asset = KDCE_TestUtil.assetCharger.clone(true);
        asset.CCR_CarePlusDueDate__c = System.Today().addDays(-1);
        asset.CCR_Override__c = true;
        update asset;

        KDCE_CarePlusStatus_ba ba = new KDCE_CarePlusStatus_ba();
        Id batchId = Database.executeBatch(ba);
        Test.stopTest();

    }

    @IsTest
    static void testBehavior3() {
        Test.startTest();

        Asset asset = KDCE_TestUtil.assetCharger.clone(true);
        asset.CCR_CarePlusDueDate__c = System.Today().addDays(-1);
        asset.KDCE_ReplacementSource__c = null;
        update asset;

        KDCE_CarePlusStatus_ba ba = new KDCE_CarePlusStatus_ba();
        Id batchId = Database.executeBatch(ba);
        Test.stopTest();

    }


}