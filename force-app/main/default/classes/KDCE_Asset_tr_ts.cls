/****************************************************************************************
  * @filename      : KDCE_Asset_tr_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-04-19
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
    0.1     2021-04-19             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_Asset_tr_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testAssetLifeCycle() {
        Test.startTest();
        System.debug('aaa + ' + KDCE_TestUtil.contactMember);
        KDCE_TestUtil.assetCharger.AccountId = null;
        KDCE_TestUtil.assetCharger.ContactId = KDCE_TestUtil.contactMember.Id;
        KDCE_TestUtil.assetCharger.KDCE_ShipmentDate__c = System.today();
        KDCE_TestUtil.assetCharger.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;

        update KDCE_TestUtil.assetCharger;

        System.debug('KDCE_TestUtil.assetCharger' + KDCE_TestUtil.assetCharger);
        System.debug('KDCE_TestUtil.assetCharger' + KDCE_TestUtil.assetCharger.Product2.CCR_Version__c);
        System.debug('KDCE_TestUtil.assetCharger' + KDCE_TestUtil.assetCharger.Product2Id);
        System.debug('KDCE_TestUtil.assetCharger' + KDCE_TestUtil.assetCharger.Product2);
        System.debug('KDCE_TestUtil.assetCharger' + KDCE_TestUtil.assetCharger.CCR_DeviceProductCode__r.CCR_GroupDescription__r.Name);
        System.debug('KDCE_TestUtil.assetCharger' + KDCE_TestUtil.assetCharger.CCR_DeviceProductCode__c);
        System.debug('KDCE_TestUtil.assetCharger' + KDCE_TestUtil.assetCharger.CCR_DeviceProductCode__r.CCR_GroupDescription__c);

        KDCE_AssetHistory__c assetHistory = new KDCE_AssetHistory__c();

        System.assertNotEquals(assetHistory, null);

        System.assertEquals(KDCE_TestUtil.assetCharger.Status, KDCE_GlobalValue.ASSET_STATUS_ACTIVE);

        KDCE_TestUtil.assetCharger.Status = KDCE_GlobalValue.ASSET_STATUS_PRODUCED;
        update KDCE_TestUtil.assetCharger;
        System.assertEquals(KDCE_TestUtil.assetCharger.Status, KDCE_GlobalValue.ASSET_STATUS_PRODUCED);
        Test.stopTest();

    }

    @IsTest
    static void testRestoreAsset() {
        Test.startTest();
        KDCE_TestUtil.assetCharger.Status = KDCE_GlobalValue.ASSET_STATUS_PRODUCED;
        update KDCE_TestUtil.assetCharger;
        System.assertEquals(KDCE_TestUtil.assetCharger.Status, KDCE_GlobalValue.ASSET_STATUS_PRODUCED);
        Test.stopTest();

    }

    @IsTest
    static void testDeleteRelatedAsset() {
        Test.startTest();
        Asset asset = KDCE_TestUtil.assetCharger.clone(false);
        asset.Status = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
        asset.CCR_CodentifyId__c = String.valueOf(Integer.valueOf((Math.random() * 1000000)));
        insert asset;

        asset.Status = KDCE_GlobalValue.ASSET_STATUS_PRODUCED;
        update asset;
//        System.assertEquals(KDCE_TestUtil.assetCharger.Status, KDCE_GlobalValue.ASSET_STATUS_PRODUCED);
//        System.debug('aa : ' + KDCE_TestUtil.assetCharger.Status);
        Test.stopTest();

    }

}