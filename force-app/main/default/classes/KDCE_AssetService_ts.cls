/****************************************************************************************
  * @filename      : KDCE_AssetService_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-04-27
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
    0.1     2021-04-27             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_AssetService_ts {
    @IsTest
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        System.debug(KDCE_TestUtil.materialChargerchild);

        Contact contact = KDCE_TestUtil.getContactMember();
        System.debug(contact);

        KDCE_OrderLineItem__c oli = KDCE_TestBizUtil.orderLineItem.clone(true);
        oli.Codentify__c = 'codentifyTest01, codentifyTest00';
        update oli;
        KDCE_AssetService.splitCodentify(oli);
        KDCE_AssetService.returnAssetLifeCycleValue(KDCE_TestUtil.assetHolder, 'Link', KDCE_TestUtil.contactMember.Id);
        KDCE_AssetService.returnAssetLifeCycleValue(KDCE_TestUtil.assetHolder, 'Link', KDCE_TestUtil.contactMember.Id);
        KDCE_AssetService.createAssetHistory(KDCE_TestUtil.assetHolder, KDCE_TestBizUtil.orderLineItem, 'Link');
        KDCE_AssetService.getOrderLineItems(new Set<Id>{KDCE_TestBizUtil.order.Id});
        KDCE_AssetService.getAssets(new Set<String>{KDCE_TestUtil.assetHolder.CCR_CodentifyId__c});
        KDCE_AssetService.getCodentifySet(new List<KDCE_OrderLineItem__c>{KDCE_TestBizUtil.orderLineItem});
        KDCE_AssetService.getCodentifyAssetMap(new List<Asset>{KDCE_TestUtil.assetHolder}, new Set<String>{KDCE_TestUtil.contactMember.Id});
        KDCE_AssetService.checkFirstLinkDate(new List<Asset>{KDCE_TestUtil.assetHolder, KDCE_TestUtil.assetCharger});
    }
}