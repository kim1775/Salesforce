/****************************************************************************************
  * @filename      : KDCE_ManualEditAssetStatusQa
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-25
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
    0.1     2021-07-25             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_ManualEditAssetStatusQa {
    @AuraEnabled
    public static ReturnClass init(String recordId) {
        System.debug('== KDCE_ManualEditAssetStatusQa.init ==');

        Asset asset = [SELECT Id, Status FROM Asset WHERE Id = :recordId LIMIT 1];

        Set<String> availableStatus = new Set<String>{
                KDCE_GlobalValue.ASSET_STATUS_RETURNED,
                KDCE_GlobalValue.ASSET_STATUS_LOCKED,
                KDCE_GlobalValue.ASSET_STATUS_REPLACED
        };

        ReturnClass rtn = new ReturnClass();
        rtn.assetStatus = asset.Status;
        rtn.isEditable = false;
        rtn.targetAsset = asset;
        if (availableStatus.contains(asset.Status)) {
            rtn.isEditable = true;
            rtn.allowedStatusValue = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
        }
        if (asset.Status == KDCE_GlobalValue.ASSET_STATUS_ACTIVE) {
            rtn.isEditable = true;
            rtn.allowedStatusValue = KDCE_GlobalValue.ASSET_STATUS_PRODUCED;
        }

        return rtn;


    }
    @AuraEnabled
    public static String changeAssetStatus(Asset asset, String allowedStatusValue) {
        System.debug('== KDCE_ManualEditAssetStatusQa.changeAssetStatus ==');

        String result;
        asset.Status = allowedStatusValue;
        Database.SaveResult sr = Database.update(asset);
        result = sr.success ? 'Success' : 'Fail';

        return result;
    }

    public class ReturnClass {

        @AuraEnabled public String result { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public List<Asset> assetList { get; set; }
        @AuraEnabled public Map<String, String> parameter { get; set; }
        @AuraEnabled public Boolean isEditable { get; set; }
        @AuraEnabled public String assetStatus { get; set; }
        @AuraEnabled public String allowedStatusValue { get; set; }
        @AuraEnabled public Asset targetAsset { get; set; }

        public ReturnClass() {
            this.result = 'Success';
            this.errorMessage = '';
            this.parameter = new Map<String, String>();
        }
    }


}