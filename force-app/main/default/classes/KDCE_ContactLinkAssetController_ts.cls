/****************************************************************************************
  * @filename      : KDCE_ContactLinkAssetController_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-05-19 오후 3:10
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
    0.1     2021-05-19 오후 3:10     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_ContactLinkAssetController_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior01() {
        Contact contact = KDCE_TestUtil.contactMember;
        Asset holder = KDCE_TestUtil.assetHolder;
        Asset charger = KDCE_TestUtil.assetCharger;
        List<Asset> assets = new List<Asset>();
        assets.add(holder);
        assets.add(charger);
        List<Map<String, String>> selectedList = new List<Map<String, String>>();
        Map<String, String> assetValueMap;
        for (Asset asset : assets) {
            assetValueMap = new Map<String, String>();
            assetValueMap.put('Id', asset.Id);
            selectedList.add(assetValueMap);
        }

        KDCE_ContactLinkAssetController.getInvalidContact(contact.Id);
        KDCE_ContactLinkAssetController.getInvalidStatus(holder.Id);
    }

    @IsTest
    static void testBehavior02() {
        Contact contact = KDCE_TestUtil.contactMember;
        Asset holder = KDCE_TestUtil.assetHolder;
        Asset charger = KDCE_TestUtil.assetCharger;
        List<Asset> assets = new List<Asset>();
        assets.add(holder);
        assets.add(charger);
        List<Map<String, String>> selectedList = new List<Map<String, String>>();
        Map<String, String> assetValueMap;
        for (Asset asset : assets) {
            assetValueMap = new Map<String, String>();
            assetValueMap.put('Id', asset.Id);
            selectedList.add(assetValueMap);
        }

        KDCE_ContactLinkAssetController.getAssetList(holder.Id);
        KDCE_ContactLinkAssetController.createContactLink(contact.Id, holder.Id);
    }

    @IsTest
    static void testBehavior03() {
        Contact contact = KDCE_TestUtil.contactMember;
        Asset holder = KDCE_TestUtil.assetHolder;
        Asset charger = KDCE_TestUtil.assetCharger;
        List<Asset> assets = new List<Asset>();
        assets.add(holder);
        assets.add(charger);
        List<Map<String, String>> selectedList = new List<Map<String, String>>();
        Map<String, String> assetValueMap;
        for (Asset asset : assets) {
            assetValueMap = new Map<String, String>();
            assetValueMap.put('Id', asset.Id);
            selectedList.add(assetValueMap);
        }

        KDCE_ContactLinkAssetController.createAssetLink(selectedList, contact.Id);
        KDCE_ContactLinkAssetController.createAssetUnlink(holder.Id);

    }
}