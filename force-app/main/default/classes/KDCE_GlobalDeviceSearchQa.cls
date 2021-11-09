/****************************************************************************************
 * @filename      : KDCE_GlobalDeviceSearchQa
 * @projectname   : PMK LocalDCE QA
 * @author        : i2max_Sukun
 * @date          : 2/18/21 1:57 PM
 * @group         : Service
 * @group-content :
 * @description   : Server-Side Controller for KDCE_GlobaDeviceSearchQa Component.
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2/18/21 1:57 PM            i2max_Sukun           Create
 0.2     3/2/21                     i2max_Sukun           Update
 0.3     5/21/21                    i2max_Sukun           Update
 ****************************************************************************************/

public with sharing class KDCE_GlobalDeviceSearchQa {
    // 데이터 반환 타입
    private static final String RETURN_TYPE = 'json';

    private static final String COM_ERR_VALID_SEARCH = System.Label.COM_ERR_VALID_SEARCH;
    private static final String LAB_COM_ERR_GLOBALDEVICE_ALREADY_ASSET = System.Label.LAB_COM_ERR_GLOBALDEVICE_ALREADY_ASSET;
    /**
    * search : 제품검색
    * @param searchTerm : 검색어
    * @return Object
    */
    @AuraEnabled
    public static Object search(String searchTerm){
        // 12자리 혹은 14자리 시리얼 번호가 아닐 경우 검색 x
        if(searchTerm.length() == 12 || searchTerm.length() == 14) {
            return call(searchTerm);
        } else {
            return COM_ERR_VALID_SEARCH;
        }
    }

    /**
    * save : 제품정보 저장
    * @param contactId
    * @param recordList
    */
    @AuraEnabled
    public static String save(String contactId, String productListJSONString, String materialListJSONString) {
        List<Asset> assetsToRegister = new List<Asset>();
        Asset newAsset;
        List<CCR_AssetLifeCycle__c> assetLifeCyclesToRegister = new List<CCR_AssetLifeCycle__c>();
        CCR_AssetLifeCycle__c assetLifeCycle;
        Map<String, Id> productMap = new Map<String, Id>();     // 매핑해줄 Product(Product2) 아이디 조회용 맵
        Map<String, Id> materialMap = new Map<String, Id>();    // 매핑해줄 Material(CCR_Material__c) 아이디 조회용 맵
        // 시리얼번호를 통해 조회된 아이템들을 Asset으로 등록할 시
        Map<String, ProductWrapper> productWrapperMap = new Map<String, ProductWrapper>();  // Asset의 부모격인 Product 참조용
        Map<String, MaterialWrapper> materialWrapperMap = new Map<String, MaterialWrapper>();   // Asset과 대응격인 Material 참조용

        Set<String> productExternalKeySet = new Set<String>();
        List<ProductWrapper> registeringDeviceProductList = (List<ProductWrapper>) JSON.deserialize(productListJSONString, List<ProductWrapper>.Class);
        for (ProductWrapper pw : registeringDeviceProductList) {
            productExternalKeySet.add(pw.ProductCode);
            productWrapperMap.put(pw.ProductCode, pw);
        }

        // Product2의 Name은 제품의 ProductCode를 사용
        List<Product2> productList = [SELECT Id, Name FROM Product2 WHERE Name IN :productExternalKeySet];
        for (Product2 prod : productList) {
            productMap.put(prod.Name, prod.Id);
        }

        Set<String> materialExternalKeySet = new Set<String>();
        List<MaterialWrapper> registeringDeviceMaterialList = (List<MaterialWrapper>) JSON.deserialize(materialListJSONString, List<MaterialWrapper>.Class);
        for (MaterialWrapper mw : registeringDeviceMaterialList) {
            materialExternalKeySet.add(mw.ProductCode);
            materialWrapperMap.put(mw.ProductCode, mw);
        }

        // CCR_Material__c의 Name은 제품의 ProductCode를 사용
        List<CCR_Material__c> materials = [SELECT Id, Name FROM CCR_Material__c WHERE Name IN :materialExternalKeySet];
        for (CCR_Material__c material : materials) {
            materialMap.put(material.Name, material.Id);
        }

        // Asset으로 등록하기 위함
        AssetWrapper assetWrapper = new AssetWrapper();
        assetWrapper.pwMap = productWrapperMap;
        assetWrapper.mwMap = materialWrapperMap;

        // 갯수 비교 - List index out of bounds 방지용 확인 (일반적으로 Device의 Material들에 대하여 Asset으로 전부 등록)
        Integer pwCount = productWrapperMap.keySet().size();
        Integer mwCount = materialWrapperMap.keySet().size();
        Integer maxCount = pwCount <= mwCount ? mwCount : pwCount;

        Set<String> isAlreadyAssetSet = new Set<String>();
        for(Integer idx=0; idx<maxCount; idx++) {
            isAlreadyAssetSet.add(materialWrapperMap.values()[idx].ItemId);
        }

        // Parent인것도 전부 조회
        // CCR_CodentifyId 역시 인덱싱된 external key이므로 사용가능하며, 기존 Map을 update
        List<Asset> isAlreadyAssetList = [SELECT Id, CCR_CodentifyId__c FROM Asset WHERE CCR_CodentifyId__c IN :isAlreadyAssetSet];

        String packagingDt;
        String productionDt;
        if(isAlreadyAssetList.size() == 0) {

            for (Integer index = 0; index < maxCount; index++) {
                // 날짜형식 :: 2021-01-28 23:04:40.000Z
                packagingDt = productWrapperMap.values()[0].ProductionDateTimeUTC;
                packagingDt = packagingDt.replace('T', ' ');
                productionDt = materialWrapperMap.values()[index].ProductionDateTimeUTC;
                productionDt = productionDt.replace('T', ' ');

                newAsset = new Asset();
                newAsset.ContactId = contactId;
                newAsset.CCR_CodentifyId__c = materialWrapperMap.values()[index].ItemId; // asset단위는 material과 1대1 매핑
                newAsset.Name = materialWrapperMap.values()[index].ItemId;
                // Interface 결과 구조 - 다중 수신 등으로 변경 시 Product2Id 매핑 로직부터 수정 - 현재 로직대로는 ID 1개 당 매핑될 Product에 대한 디바이스 정보는 1개만 수신되므로 Product의 인덱스는 0으로 고정
                newAsset.Product2Id = productMap.get(productWrapperMap.values()[0].ProductCode);
                newAsset.SerialNumber = productWrapperMap.values()[0].ItemId;
                newAsset.CCR_DeviceProductCode__c = materialMap.get(materialWrapperMap.values()[index].ProductCode);
                newAsset.Status = KDCE_Util.getPicklistValue('Asset', 'Status').get('Active');
                newAsset.CCR_InternalId__c = materialWrapperMap.values()[index].InternalId;
                newAsset.CCR_ProductionLineCode__c = materialWrapperMap.values()[index].ProductionLineCode;
                newAsset.CCR_ParentProductionDateTime__c = Datetime.valueOf(packagingDt);
                newAsset.CCR_ProductionDateTime__c = Datetime.valueOf(productionDt);
                newAsset.CCR_FactoryName__c = materialWrapperMap.values()[index].FactoryName;
                newAsset.CCR_FactoryCode__c = materialWrapperMap.values()[index].FactoryCode;
                newAsset.CCR_OriginalAsset__c = newAsset.CCR_CodentifyId__c;
                newAsset.CCR_OriginalBox__c = newAsset.SerialNumber;
                newAsset.CCR_FirstLinkDatetoCurrentContact__c = System.today();

                System.debug(newAsset);
                assetsToRegister.add(newAsset);
            }

            List<Database.SaveResult> srList = Database.insert(assetsToRegister, true);
            for (Database.SaveResult insertResult : srList) {
                System.debug('Asset DML error >> ' + insertResult.errors);
            }

            for (Asset asset : assetsToRegister) {
                assetLifeCycle = KDCE_AssetService.returnAssetLifeCycleValue( asset, KDCE_GlobalValue.ASSETLIFECYCLE_ACTION_LINK, contactId );
                assetLifeCyclesToRegister.add(assetLifeCycle);
            }

            List<Database.SaveResult> alsrList = Database.insert(assetLifeCyclesToRegister, true);
            System.debug('alsrList : ' + alsrList);
            for (Database.SaveResult insertResult : alsrList) {
                if(insertResult.isSuccess()){}
                System.debug('Asset Life Cycle DML error >> ' + insertResult.errors);
            }
            return '1'; // Success Indicator String
        } else {
            return LAB_COM_ERR_GLOBALDEVICE_ALREADY_ASSET;
        }
    }

    /**
    * call : Interface 호출
    * @param pageSize : 출력 할 페이지의 사이즈
    * @param pageNumber : 페이지 번호
    * @param searchTerm : 검색어
    * @return Object
    */
    private static Object call(String searchTerm){
        String result;
        try{
            IF_DCE_iTrack_0001.OutputDIH jsonObj = IF_KDCE_CallOutController.getGlobalDeviceInfo(searchTerm);
            List<String> tData = jsonObj.response.payload.t_data;
            System.debug('searchTerm ::: ' + searchTerm);
            System.debug('jsonObj ::: ' + jsonObj);
            System.debug('tData ::: ' + tData);

            Map<String, Object> parsedObject = (!Test.isRunningTest())? (Map<String,Object>)JSON.deserializeUntyped(tData[0]) : new Map<String, Object>();
            // 더 이상 Map형태의 parse가 되지 않는 최종 Map형태의 JSON의 경우, 최종 Parsing 직전까지 Parsing Object를 넘겨줄 수 있도록 한다 (Device JSON 구조로 인한 설계)된
            // Device JSON 구조: PackagedItem={a, b, c, Children={Item=[{... => PackagedItem부터 넘겨줄 수 있어야 한다.
            Map<String, Object> finalParseBeforeObj;
            Map<String, Object> parsingObj;

            Boolean foundAdequateJSON = false;
            while(foundAdequateJSON == false) {
                try {
                    parsingObj = (Map<String,Object>)parsedObject.values()[0];
                    finalParseBeforeObj = parsedObject;
                    parsedObject = parsingObj;
                    if(parsedObject.containsKey('Item')) foundAdequateJSON = true;
                } catch (Exception e) {
                    // 최종 parsed Object 확인 용도
                    System.debug('Final Parsed Object Result' + parsedObject);
                    foundAdequateJSON = true;
                }
            }

            result = JSON.serialize(finalParseBeforeObj);

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.deserializeUntyped(result);
    }

    public class ProductWrapper {
        @AuraEnabled public String ItemId                       { get; set; }
        @AuraEnabled public String ProductCode                  { get; set; }
        @AuraEnabled public String ProductDescription           { get; set; }
        @AuraEnabled public String ProductionDateTimeUTC        { get; set; }
        @AuraEnabled public String InternalId                   { get; set; }
        @AuraEnabled public List<MaterialWrapper> materialList  { get; set; }
    }

    public class MaterialWrapper {
        @AuraEnabled public String ItemId                       { get; set; }
        @AuraEnabled public String ProductCode                  { get; set; }
        @AuraEnabled public String ProductDescription           { get; set; }
        @AuraEnabled public String ProductionDateTimeUTC        { get; set; }
        @AuraEnabled public String InternalId                   { get; set; }
        @AuraEnabled public String FactoryName                  { get; set; }
        @AuraEnabled public String FactoryCode                  { get; set; }
        @AuraEnabled public String ProductionLineCode           { get; set; }
    }

    public class AssetWrapper {
        @AuraEnabled public Map<String, ProductWrapper> pwMap   { get; set; }
        @AuraEnabled public Map<String, MaterialWrapper> mwMap  { get; set; }
    }
}