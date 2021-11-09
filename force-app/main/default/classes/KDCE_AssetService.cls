/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-03-05 오후 5:21
  * @group         : 
  * @group-content : 
  * @description   : Asset 관련 비지니스 로직 정리
  * @tester        : KDCE_AssetService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-03-05 오후 5:21     i2max_Junseok.Kwon        Create
****************************************************************************************/

public without sharing class KDCE_AssetService {

   /* public static KDCE_AssetHistory__c createAssetHistory(Asset device, String actionType, Contact ct){
        return createAssetHistory(device, actionType, ct, null, null);
    }

    public static KDCE_AssetHistory__c createAssetHistory(Asset device, String actionType, Contact ct, String status, String labelling){

        KDCE_AssetHistory__c ah = new KDCE_AssetHistory__c();
        ah.ActionType__c        = actionType;
        ah.ActionDate__c        = System.now();
        ah.Contact__c           = ct.Id;
        ah.StatusValue__c       = status;
        ah.LabellingValue__c    = labelling;

        return ah;
    }*/

    public static KDCE_AssetHistory__c createAssetHistory(Asset device, KDCE_OrderLineItem__c oli, String actionType){

        KDCE_AssetHistory__c ah = new KDCE_AssetHistory__c();
        ah.ActionType__c        = actionType;
        ah.ActionDate__c        = System.now();
        ah.Asset__c             = device.Id;
        ah.OrderLineItem__c     = oli == null? null : oli.Id;

        return ah;
    }


    /**
     * @author Park HE
     * @description  CCR_AssetLifeCycle__c 레코드 생성
     * @param assetId
     * @param contactId
     * @param action (Link or Unlink)
     *
     * @return CCR_AssetLifeCycle__c 단일 레코드
     */
    public static CCR_AssetLifeCycle__c returnAssetLifeCycleValue(Asset asset, String action, Id contactId) {

        CCR_AssetLifeCycle__c alc = new CCR_AssetLifeCycle__c(
                CCR_Asset__c = asset.Id,
                CCR_Action__c = KDCE_Util.getPicklistValue('CCR_AssetLifeCycle__c', 'CCR_Action__c').get(action),
                CCR_ActionDate__c = System.now(),
                CCR_Consumer__c = contactId,
                KDCE_DeviceType__c = asset.KDCE_DeviceType__c
        );
        return alc;
    }

    public static List<KDCE_OrderLineItem__c> getOrderLineItems(Set<Id> orderIds){
        List<KDCE_OrderLineItem__c> oliList = new List<KDCE_OrderLineItem__c>([
                SELECT  Id, Codentify__c, Order__c, Order__r.Contact__c, Order__r.OrderDate__c, Order__r.OrderType__c,
                        Order__r.Name, Order__r.OrderStatus__c, Order__r.OrderReason__c, Order__r.OriginOrder__c
                FROM    KDCE_OrderLineItem__c WHERE Order__c IN :orderIds
        ]);

        System.debug('================================================= getOrderLineItems (Start) ================================================= ');
        System.debug(oliList);
        System.debug('================================================= getOrderLineItems (End) =================================================== ');

        return oliList;
    }

    public static List<Asset> getAssets(Set<String> codentifySet){
        List<Asset> assets = new List<Asset>([
                SELECT  Id, CCR_CodentifyId__c, SerialNumber, ContactId, Product2Id, ProductCode, PurchaseDate, Status, KDCE_DeviceType__c, KDCE_DeviceLabelling__c,
                        AccountId, CCR_PurchaseChannel__c, KDCE_ShipmentDate__c, CCR_CarePlusDueDate__c, KDCE_fm_WarrantyDate__c, KDCE_RentalCount__c, CCR_ReplacedBy__c
                FROM    Asset
                WHERE   CCR_CodentifyId__c IN :codentifySet OR SerialNumber IN : codentifySet
        ]);

        System.debug('==================================================== getAssets (Start) ===================================================== ');
        System.debug(assets);
        System.debug('==================================================== getAssets (End) ======================================================= ');

        return assets;
    }

    public static Set<String> getCodentifySet(List<KDCE_OrderLineItem__c> oliList){
        Set<String> codentifySet = new Set<String>();
        String tempCodentify;
        for (KDCE_OrderLineItem__c oli : oliList) {
            if (oli.Codentify__c <> null) {
                tempCodentify = oli.Codentify__c;

                for(String str : tempCodentify.split(',')){
                    codentifySet.add(str.trim());
                }
            }
        }

        System.debug('==================================================== getCodentifySet (Start) ===================================================== ');
        System.debug(codentifySet);
        System.debug('==================================================== getCodentifySet (End) ======================================================== ');

        return codentifySet;
    }

    public static Map<String, List<Asset>> getCodentifyAssetMap(List<Asset> assetList, Set<String> codentifySet){
        Map<String, List<Asset>> codentifyAssetMap = new Map<String, List<Asset>>();
        //(OLI의) Codentify별로 Asset 저장하기
        for (Asset asset : assetList) {
            for (String codentify : codentifySet) {
                if (codentify == asset.CCR_CodentifyId__c || codentify == asset.SerialNumber) {
                    if (codentifyAssetMap.containsKey(codentify)) {
                        codentifyAssetMap.get(codentify).add(asset);
                    } else {
                        codentifyAssetMap.put(codentify, new List<Asset>{asset});
                    }
                }
            }
        }

        System.debug('==================================================== getCodentifyAssetMap (Start) ===================================================== ');
        System.debug(codentifyAssetMap);
        System.debug('==================================================== getCodentifyAssetMap (End) ======================================================== ');

        return codentifyAssetMap;
    }

    public static Set<String> splitCodentify(KDCE_OrderLineItem__c oli){
        Map<Id, List<String>> codentifyByOli = new Map<Id, List<String>>();
        Set<String> tempCodentifyList = new Set<String>();
        String tempCodentify;
        if(oli.Codentify__c != null) {
            tempCodentify = oli.Codentify__c;
            for (String str : tempCodentify.split(',')) {
                tempCodentifyList.add(str.trim());
            }
        }
            System.debug('================================================= splitCodentify (Start) ================================================= ');
            System.debug(tempCodentifyList);
            System.debug('================================================= splitCodentify (End) =================================================== ');
        return tempCodentifyList;
    }

    public static void checkFirstLinkDate(List<Asset> newList) {
        System.debug('@@@@@@ checkFirstLinkDate @@@@@@');

        Set<Id> assetIds = new Set<Id>();
        for (Asset item : newList) {
            assetIds.add(item.Id);
        }
        System.debug('assetIds ======= :: ' + assetIds);

        Map<String, AggregateResult> arLifeCycleMap = new Map<String, AggregateResult>();


        List<AggregateResult> arLifeCycleList = [
                SELECT MIN(CCR_ActionDate__c) actiondate, CCR_Asset__c asset
                FROM CCR_AssetLifeCycle__c
                WHERE CCR_Asset__c IN :assetIds AND CCR_ActionDate__c <> NULL AND CCR_Consumer__c <> NULL
                GROUP BY CCR_Asset__c
        ];
        String arKey;
        for (AggregateResult lifeCycle : arLifeCycleList) {
            arKey = (String) lifeCycle.get('asset');
            arLifeCycleMap.put(arKey, lifeCycle);
        }

        System.debug('====== arLifeCycleList ========' + arLifeCycleList);
        System.debug('====== arLifeCycleMap ========' + arLifeCycleMap);

        arKey = null;
        AggregateResult ar;

        List<Asset> updateAsset = new List<Asset>();

        for (Asset item : newList) {
            arKey = item.Id;
            if (arLifeCycleMap.containsKey(arKey)) {
                ar = arLifeCycleMap.get(arKey);

                updateAsset.add(new Asset(Id = item.Id,
                        CCR_FirstLinkDatetoCurrentContact__c = ((Datetime) (ar.get('actiondate'))).date()));
            }
        }
        update updateAsset;
    }
}