/****************************************************************************************
  * @filename      : KDCE_ManualEditAssetStatusQa_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-30
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
    0.1     2021-07-30             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_ManualEditAssetStatusQa_ts {
    @IsTest
    static void testBehavior() {
        Asset asset = KDCE_TestUtil.assetHolder.clone(true);
        asset.Status = 'Active' ;
        update asset;
        KDCE_ManualEditAssetStatusQa.init(asset.Id);
        KDCE_ManualEditAssetStatusQa.changeAssetStatus(asset, 'Produced');
    }
}