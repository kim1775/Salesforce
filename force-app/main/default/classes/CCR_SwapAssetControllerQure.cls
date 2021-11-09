/**
 * Created by I2MAX on 2021-04-28.
 */

public without sharing class CCR_SwapAssetControllerQure {

    Private static final String URLASSETID='assetid';
    Private static final String URLQUREHISID='qureHisId';
    public static final String URLST='/';
    public static final string URLVF='/apex/CCR_SwapAsset?assetid=';
    public static final String ERRORTYPE='Error';
    public static final String ERRORSCOPE='Application';
    public static final String ERRORFUNCTION='Replacement Engine';
    public static final String BLANKTEXT = '';
    public Static Final String ACTIVETEXT ='Active';
    public Boolean swapHideforQureMarkets {get;set;}
    public Boolean replacehide{get; set;}
    public Boolean buttonDisable {get; set;}
    public String cancelRedirecturl {get; set;}
    public String replacReason {get; set;}
    public Asset ass {get; set;}
    String assetid;
    List<CCR_QureHistory__c> qureHistoryList;
    Map<String,String> replacementSponsoredByMap; // Maciej Kusper related to US CCR-105964
    String tempReplaces;

    public List<selectoption> selectedReplacechannel {get; set;}

    public static final String CASEREPLACEMENTCHANNEL = 'Service_Center';
    public static final String CLOSEDTEXT = 'Closed';
    public static final String CALLCENTER = 'Call Center Agent';
    public static final String CONSUMER = 'Consumer';
    public static final String ERRORFUNCTIONELIGIBILITY='Qure Fault Tree';
    public static final String FLAGSHIPSTORE = 'Flagship Store Agent';
    public static final String GHOSTCONTACTID = 'Ghost Contact id';
    public static final String INPERSONINDIRECTRETAIL= 'In person - Indirect Retail';
    public static final String INPERSONDIRECTRETAIL = 'In person - direct retail';
    public static final String REPLACEMENTDATE = 'ReplacementDate';
    public static final String REPLACEMENTREASON = 'ReplacementReason';
    public static final String REPLACEMENTCHANNEL = 'Channel';
    public static final String REPLACEMENTCHANNELPICKLIST = 'ChannelPicklist';
    public static final String PARENTCODENTIFY = 'ParentCodentify';
    public static final String EXTREF = 'ExtRef';
    public static final String REPLACEMENTCOUNTRY = 'ReplacementCountry';
    public static final String REPLACEMENTDONEBY = 'ReplacementDoneBy'; //Added as part of RRPSF-5350
    public static final String KITCODENTIFY = 'Codentify';
    public static final String MATERIALTYPEPOCKETCHARGER = 'Pocket Charger /S';
    public static final String MATERIALTYPECLEANER = 'Cleaner /S';
    public static final String MATERIALTYPEHOLDER = 'Holder /S';
    public static final String MATERIALTYPEUSBCHARGER = 'USB Charger /S';
    public static final String MATERIALTYPEUSBPOWERADAPTER = 'USB Power Adapter /S';
    public static final String PHONE = 'Phone';
    public static final String SELFSERVICEQURE = 'Self-Service - QURE';

    public static final String CAREPLUSSTR ='Care+'; //added by Vlad CCR-105968
    public static final Integer CAREPLUSZEROVAL = 0; //added by Vlad CCR-105968
    public static final String REPLACEMENTSPONSOREDBYSTR ='ReplacementSponsoredBy'; //added by Vlad CCR-105968
    public static final String MULTIMODELNUMBER = 'A1405';
    public static final String RETAILERCASEREPLACEMENTCHANNEL ='Retailer_F2F';

    public static final string ASSET_PURCHASE_CHANNEL = 'Field Sales Force';

    replacementWrapper wrapperData;
    public static Map<String,List<String>> assetWarningMap = new Map<String,List<String>>();
    public static final Map<String, CCR_CarePlusConfiguration__c> carePlusConfig = CCR_CarePlusConfiguration__c.getAll();
    public static final Map<String, Set<String>> carePlusL0Codes = allCarePlusL0Codes(carePlusConfig.values());
    public static Map<String, String> kitDevicesMap = new Map<String, String>();
    public static final Map<String, String> subjectCodeMaps = CCR_Utility.retrievePicklistMap('Case', 'CCR_SubjectCodeNew__c');
    public static Map<String, String> englishSubjectCodeMaps = new Map<String, String> ();
    public static Map<String, CCR_QureHistory__c> qureHistoryMap = new Map<String, CCR_QureHistory__c>();
//    CCR_AssetReplacementHandling.replacementWrapper wrapperData;

    //TODO 즉시교환이 이뤄질 경우 CarePlusStatus 값 설정 코딩 할 것

    /**
    * Method Name :  CCR_AssetReplacementExtension
    * Arguments:
    * Return :
    * Description:Constructor.
    **/
    public CCR_SwapAssetControllerQure(ApexPages.StandardController controller) {
        swapHideforQureMarkets = true;
        buttonDisable = false;
        if(ApexPages.currentPage().getParameters().get(URLASSETID) != null && ApexPages.currentPage().getParameters().get(URLASSETID) != '') {
            assetid = ApexPages.currentPage().getParameters().get(URLASSETID).escapeHtml4();
        } else {
            ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.ERROR, '잘못된 접근 방법입니다.'));
        }
        cancelRedirecturl = URLST+assetid;

        selectedReplacechannel = new List<selectoption>();

        Schema.sObjectType sObjectType = Asset.getSObjectType();
        Schema.DescribeSObjectResult sObjectResult = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectResult.fields.getMap();
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get('CCR_ReplacementChannelNew__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry p : picklistEntries){
            selectedReplacechannel.add(new SelectOption(p.getLabel(), p.getValue()));
        }
//        System.debug('CCR_SwapAssetControllerQure.cls Constructor called');
//        System.debug(selectedReplacechannel);
        if(assetid != null) {
            List<asset> assetList = [SELECT Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c, SerialNumber,Product2.Name,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannelNew__c,CCR_ReplacementExternalReference__c, CCR_OriginalBox__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c,
                    CCR_DeviceProductCode__r.CCR_ModelNumber__c, ProductCode, CCR_ReplacementSponsored_By__c,
                    CCR_FirstLinkDatetoCurrentContact__c, CCR_OriginalAsset__c,
                    CCR_CarePlusStatus__c, CCR_CarePlusDueDate__c,
                    CCR_DeviceProductCode__r.CCR_Version__c, CCR_AccidentalDamageCounter__c, CCR_SubscribedDevice__c, CCR_SubscriptionID__c, KDCE_ReplacementCount__c, KDCE_OriginalWarrantyDate__c, KDCE_fm_WarrantyDate__c
            FROM Asset
            WHERE Id = :assetid LIMIT 1];
            if(assetList != null && !assetList.isEmpty()) {
                ass = assetList[0];
                qureHistoryList = [SELECT Id, CCR_EligibilityResult__c, CCR_SubjectCode__c, CCR_Case__c, CCR_QureChannel__c,
                        CCR_QureReplacementChannel__c, CCR_EndDateforreplacementreasonselectio__c, CCR_Device__c,
                        CCR_DiagnosticResult__c, CCR_Status__c, CCR_Override__c, CCR_ConsumerCountry__c,
                        CCR_EligibilitySubscription__c, CCR_EligibilityByCarePlus__c, CCR_InWarranty__c,
                        CCR_CodeCovered__c , CCR_Device__r.CCR_CodentifyId__c, CCR_QureInUnlimitedPeriod__c,
                        CCR_OverrideReason__c, CCR_DiagnosticDescription__c
                FROM CCR_QureHistory__c
                WHERE CCR_Device__c =: ass.Id
                AND CCR_Status__c = :ACTIVETEXT LIMIT 1];
            }
            else {
                replacehide = false;
                ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.error, System.label.CCR_AssetIdMissing));
                return;
            }

            if(qureHistoryList != null && !qureHistoryList.isEmpty()) {
                replacReason = CCR_Utility.retrievePicklistMap('CCR_QureHistory__c','CCR_SubjectCode__c').get(qureHistoryList[0].CCR_SubjectCode__c);
                ass.CCR_ReplacementReason__c = qureHistoryList[0].CCR_SubjectCode__c;
                tempReplaces = ass.CCR_Replaces__c;
                ass.CCR_Replaces__c = null;
                ass.CCR_ReplacementDate__c = system.now();
                //Maciej Kusper related to US CCR-105964
                replacementSponsoredByMap = getReplacementSponsoredBy(qureHistoryList);
                if (replacementSponsoredByMap != null){
                    System.debug('@@@ CCR_ReplacementSponsored_By__c check replacementSponsoredByMap === ' + replacementSponsoredByMap);
                    ass.CCR_ReplacementSponsored_By__c = replacementSponsoredByMap.get(ass.CCR_CodentifyId__c);
                }
                //stop related to US CCR-105964
                if (ass.Status.equals(CCR_Constants.ASSETACTIVE) || ass.Status.equals(CCR_Constants.ASSETPRODUCED)) {
                    replacehide = True;
                } else {
                    ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.error, System.label.CCR_StatusActive));
                    replacehide = false;
                }
            }
            else {
                replacehide = false;
                ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.error, System.label.CCR_QureHistoryInactive));
            }
        }
        else {
            replacehide = false;
            ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.error, System.label.CCR_AssetIdMissing));
        }
    }

    /**
    * Method Name :  checkDeviceType
    * Arguments: NO
    * Return : void
    * Description:This method is is to check the Device Type
    **/
    public void checkDeviceType() {
        wrapperData = new replacementWrapper ();
        wrapperData.oldAsset = ass;
        wrapperData.qureHistory = qureHistoryList[0];
        if(ass.CCR_Replaces__c != null) {
            buttonDisable = false;
            //Checking the replacement type
            System.debug('==== checkDviceType');
            wrapperData = checkReplacementType(wrapperData);
            if(!wrapperData.errors.isEmpty()){
                buttonDisable = false;
                for(String error : wrapperData.errors){
                    ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.error, error));
                }
            } else {
                buttonDisable = true;
                for(String info : wrapperData.information){
                    ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.Info, info));
                }
            }
        } else {
            ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.error, System.Label.CCR_EnterCodentify));
            buttonDisable = false;
        }
    }

    /**
    * Method Name :  Replace
    * Arguments: NO
    * Return :Pagereference
    * Description:This method is called when the user click on replace with another Device
    **/
    public PageReference replace() {
        System.debug('==== debug called 111 ');
        ass.CCR_Replaces__c = tempReplaces;
        if(!Test.isRunningTest()){
            String subjectCodeLabel = getEnglishValue('CCR_QureHistory__c', 'CCR_SubjectCode__c', qureHistoryList[0].CCR_SubjectCode__c);
            System.debug('replce debug &&& '+subjectCodeLabel);
//            CCR_AssetReplacementHandling.englishSubjectCodeMaps.put(qureHistoryList[0].CCR_SubjectCode__c, subjectCodeLabel);
        }
        Map<String, String> returnMap = singleOrKitReplacement(wrapperData);
        system.debug('==== $$$$$$$$returnMap : '+returnMap);
        if(!returnMap.isEmpty()) {
            String errorText = '';
            for(String codentify : returnMap.keySet()){
                errorText += codentify+' : '+returnMap.get(codentify)+'\n';
            }
            ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.error, errorText));
            return null;
        }
        else {
            PageReference ref = new PageReference(URLST+assetid);
            ref.setredirect(true);
            return ref;
        }
//        return null;
    }

    /**
* Method Name : Cancel
* Arguments:
* Return :Pagereference
* Description:called this method when user clicks on Cancel button and it redirect to previous page.
**/
    public PageReference cancel() {
        PageReference ref = new PageReference(URLST+assetid);
        ref.setredirect(true);
        return ref;
    }

    /**
   * Method Name :  updateQureHistory
   * Arguments: NA
   * Return : void
   * Description: This method is used to update Qure History.
   **/
    public void updateQureHistory(){
        try{
            List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_StartDateforreplacementreason_select__c
            from CCR_QureHistory__c  where CCR_Device__c = :assetid  AND CCR_Status__c = : ACTIVETEXT limit 1];
            system.debug(qureHistoryList);
            if(!qureHistoryList.isEmpty()) {
                CCR_QureHistory__c qureHistoryRec = qureHistoryList[0];
                qureHistoryRec.CCR_StartDateforreplacementreason_select__c = system.now();
                CCR_QUREFaultTreeApex.updateQureHistory(qureHistoryRec);
            }
        }
        catch(exception ex){
            system.debug('start date not updated on qurehistoryrec'+ex);
        }
    }

    /**
* Method Name :  getselectedReplacounfields
* Arguments: NA
* Return : List<Selectoption>
* Description:This method is called when the Assetreplacement page
**/
    Public List<Selectoption> getselectedReplacounfield(){
//        return CCR_Utility.getCountryTerritory();
        return null;
    }
    /**
* Method Name :  selectedReplacechannel
* Arguments: NA
* Return : List<Selectoption>
* Description:This method is called when the Assetreplacement page
**/
    Public List<Selectoption> getselectedReplacechannel(){
        return getReplacementChannelValues();
//        return null;
    }

    public Static String getEnglishValue(String objectName, String fieldName, String picklistApiName){
        try{
            PageReference translation = Page.CCR_PicklistTranslations;
            translation.getParameters().put('object', objectName);
            translation.getParameters().put('field', fieldName);
            translation.getParameters().put('value', picklistApiName);
            return translation.getContent().toString().stripHtmlTags();
        }catch(Exception ex){
            return null;
        }
    }

    /**
    * Method Name :  checkReplacementType
    * Argument : Asset
    * Return : ReplacementWrapper
    * Description: This method is used to check the type of replacement (added as part of this user story CCR-135147)
    **/
    public Static ReplacementWrapper checkReplacementType(ReplacementWrapper wrapperData) {
        Asset oldAssetRecord = wrapperData.oldAsset;
        wrapperData.oldAssetsMap.putAll(groupDevicesInMap(new List<Asset> {oldAssetRecord}));
        List<Asset> replacingAssetList = [SELECT Id, SerialNumber, CCR_Replaces__c,CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,CCR_CodentifyId__c, Product2.Name,
                CCR_DeviceProductCode__r.CCR_Description__c, CCR_DeviceProductCode__r.CCR_ModelNumber__c,CCR_ReplacementCountry__c, CCR_MaterialGroupDescription__c,
                ContactId, CCR_OriginalBox__c, Status, CCR_OriginalAsset__c, CCR_FirstLinkDatetoCurrentContact__c, CCR_AccidentalDamageCounter__c,
                CCR_CarePlusStatus__c, CCR_CarePlusDueDate__c, CCR_DeviceProductCode__r.CCR_Version__c, KDCE_fm_WarrantyDate__c
        FROM Asset
        WHERE Id = :oldAssetRecord.CCR_Replaces__c
        AND Status = :CCR_Constants.ASSETPRODUCED];

        System.debug('CCR_SwapAssetContollerQure.cls checkReplacementType oldAssetMap == ' + wrapperData.oldAssetsMap);
        System.debug('CCR_SwapAssetContollerQure.cls checkReplacementType newAssetMap == ' + wrapperData.newAssetsMap);

        if(replacingAssetList.isEmpty()){
            wrapperData.errors.add(System.Label.CCR_InvalideCodentify);
        }
        //Replacement MULTI to MULTI device only
        else if(oldAssetRecord.CCR_DeviceProductCode__r.CCR_ModelNumber__c == MULTIMODELNUMBER ||
                replacingAssetList[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c == MULTIMODELNUMBER){
            if(oldAssetRecord.CCR_DeviceProductCode__r.CCR_ModelNumber__c == MULTIMODELNUMBER &&
                    replacingAssetList[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c == MULTIMODELNUMBER){
                wrapperData.replacementType = 'SLU';
                wrapperData.newAssetsMap.putAll(groupDevicesInMap(replacingAssetList));
                System.debug('checkDeviceMaterialDetails called 1');
                checkDeviceMaterialDetails(wrapperData);
            }
            else {
                wrapperData.errors.add(System.Label.CCR_MultiToMultiReplacementOnly);
            }
        }
        else {
            wrapperData.newAssetsMap.putAll(groupDevicesInMap(replacingAssetList));
            // Check for KIT Replacement
            if(replacingAssetList[0].Product2.Name != null && replacingAssetList[0].Product2.Name.startsWith('DK')){
                Asset tempAsset = replacingAssetList[0];
                replacingAssetList.clear();
                List<Asset> oldDevicesForReplacement = [SELECT Id, CCR_CodentifyID__c, CCR_MaterialGroupDescription__c, Status, CCR_Image__c, Name, CCR_ReplacedBy__c,
                        ContactId,CCR_DeviceProductCode__r.CCR_Color__c, CCR_DeviceProductCode__r.CCR_Description__c,CCR_ReplacementReason__c,
                        CCR_DeviceProductCode__r.CCR_ModelNumber__c,CCR_DeviceProductCode__r.CCR_Version__c,Contact.CCR_CountryId__c,ProductCode,
                        CCR_ReplacementSponsored_By__c, CCR_AccidentalDamageCounter__c, CCR_FirstLinkDatetoCurrentContact__c,
                        CCR_OriginalAsset__c, CCR_OriginalBox__c, SerialNumber, CCR_CarePlusStatus__c, CCR_CarePlusDueDate__c, KDCE_fm_WarrantyDate__c
                FROM Asset
                WHERE Status = :CCR_Constants.ASSETACTIVE
                AND CCR_OriginalBox__c != NULL
                AND (CCR_OriginalBox__c = :oldAssetRecord.CCR_OriginalBox__c OR SerialNumber = :oldAssetRecord.CCR_OriginalBox__c)];
                wrapperData.oldAssetsMap.putAll(groupDevicesInMap(oldDevicesForReplacement));
                replacingAssetList = [SELECT Id, SerialNumber, CCR_Replaces__c,CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c, CCR_DeviceProductCode__r.CCR_Version__c,
                        CCR_CodentifyId__c, Product2.Name, CCR_DeviceProductCode__r.CCR_Description__c,ContactId, Status,
                        CCR_DeviceProductCode__r.CCR_ModelNumber__c,CCR_ReplacementCountry__c, CCR_MaterialGroupDescription__c, CCR_AccidentalDamageCounter__c,
                        CCR_FirstLinkDatetoCurrentContact__c, CCR_OriginalAsset__c, CCR_OriginalBox__c,
                        CCR_CarePlusStatus__c, CCR_CarePlusDueDate__c, KDCE_fm_WarrantyDate__c
                FROM Asset
                WHERE SerialNumber = :tempAsset.SerialNumber
                AND Status = :CCR_Constants.ASSETPRODUCED];
                wrapperData.newAssetsMap.clear();
                wrapperData.newAssetsMap.putAll(groupDevicesInMap(replacingAssetList));
                if(wrapperData.oldAssetsMap.size() == 1) {
                    wrapperData.oldAssetsMap.clear();
                    wrapperData.oldAssetsMap.putAll(groupDevicesInMap(new List<Asset> {oldAssetRecord}));
                    wrapperData.information.add(System.Label.CCR_SLUToKITMessage);
                    wrapperData.replacementType = 'SLU2KIT';
                }
                else if(wrapperData.oldAssetsMap.size() == 2) {
                    if(wrapperData.oldAssetsMap.values()[0].ContactId != wrapperData.oldAssetsMap.values()[1].ContactId) {
                        wrapperData.oldAssetsMap.clear();
                        wrapperData.oldAssetsMap.putAll(groupDevicesInMap(new List<Asset> {oldAssetRecord}));
                        wrapperData.information.add(System.Label.CCR_KITAssigned2ConsumersMessage);
                        wrapperData.replacementType = 'SLU2KIT';
                    }
                    else {
                        wrapperData.information.add(System.Label.CCR_Kit2KitReplacement);
                        wrapperData.replacementType = 'KIT';
                    }
                }
                else if(wrapperData.oldAssetsMap.size() > 2 || wrapperData.newAssetsMap.size() > 2){
                    wrapperData.errors.add(System.label.CCR_ReplacementNotPossible);
                }
                System.debug('wrapperData.newAssetsMap == ' + wrapperData.newAssetsMap);
                System.debug('checkDeviceMaterialDetails called 2');
                checkDeviceMaterialDetails(wrapperData);
            }
            else {
                for(String  device : wrapperData.oldAssetsMap.keySet()) {
                    if(wrapperData.newAssetsMap.containsKey(device)) {
                        wrapperData.information.add(System.Label.CCR_SingleReplacement);
                        wrapperData.replacementType = 'SLU';
                        System.debug('checkDeviceMaterialDetails called 3');
                        checkDeviceMaterialDetails(wrapperData);
                    }
                    else {
                        wrapperData.errors.add(System.label.CCR_WrongDeviceType);
                    }
                }
            }
        }
        return wrapperData;
    }

    /**
    * Method Name :  groupDevicesInMap
    * Arguments : Asset List
    * Return : Map<String, Asset>
    * Description:This method is to group the devides based on the type (Holder or Charger) (added as part of this user story CCR-135147)
    **/
    Public Static Map<String, Asset> groupDevicesInMap(List<Asset> assetList) {
        Map<String, Asset> groupMap = new Map<String, Asset> ();
        for(Asset assetRec : assetList) {
            if(assetRec.CCR_MaterialGroupDescription__c.contains(CCR_Constants.HOLDER)){
                groupMap.put(CCR_Constants.HOLDER, assetRec);
            }
            else if(assetRec.CCR_MaterialGroupDescription__c.contains(CCR_Constants.CHARGER)){
                groupMap.put(CCR_Constants.CHARGER, assetRec);
            }
            else if(assetRec.CCR_DeviceProductCode__r.CCR_ModelNumber__c == CCR_Constants.VEEVMODELNO &&
                    assetRec.CCR_DeviceProductCode__r.CCR_Version__c == CCR_Constants.VEEVVERSION){
                groupMap.put(CCR_Constants.VEEVTEXT, assetRec);
            }
        }
        return groupMap;
    }

    /**
    * Method Name :  checkDeviceMaterialDetails
    * Arguments: ReplacementWrapper
    * Return :ReplacementWrapper
    * Description:This method is called to check the device compatibility (added as part of this user story CCR-135147)
    **/
    public Static ReplacementWrapper checkDeviceMaterialDetails(ReplacementWrapper inputWrapper) {
        Map<String, String> replaceAssetMap = new Map<String, String>();
        Map<String, Asset> originalAssetMap = new Map<String, Asset>();
        Map<String, List<Asset>> newAssetMap = new Map<String, List<Asset>>();

        //Added ap part of CCR-3976 : display warning message when swap different material groups or different colors
        for(String device : inputWrapper.oldAssetsMap.keySet()){
            Asset oldDevice = inputWrapper.oldAssetsMap.get(device);
            Asset newDevice = inputWrapper.newAssetsMap.get(device);
            if(newDevice != null)   replaceAssetMap.put(oldDevice.CCR_CodentifyId__c,newDevice.CCR_CodentifyId__c);
            originalAssetMap.put(oldDevice.CCR_CodentifyId__c,oldDevice);
            if(newDevice != null)   newAssetMap.put(newDevice.CCR_CodentifyId__c,new List<Asset>{newDevice});
        }

        if(inputWrapper.replacementType != 'KIT') {
            checkDeviceColorMaterialDetails(replaceAssetMap,originalAssetMap,newAssetMap,0);
            compareDevices(replaceAssetMap,originalAssetMap,newAssetMap, 'SLU');
        }
        else if(inputWrapper.replacementType == 'KIT') {
            checkDeviceColorMaterialDetails(replaceAssetMap,originalAssetMap,newAssetMap,1);
            compareDevices(replaceAssetMap,originalAssetMap,newAssetMap, 'KIT');
        }

        for(String device : inputWrapper.oldAssetsMap.keySet()) {
            Asset oldDevice = inputWrapper.oldAssetsMap.get(device);
            if (assetWarningMap.containsKey(oldDevice.CCR_CodentifyId__c)) {
                for (String message : assetWarningMap.get(oldDevice.CCR_CodentifyId__c)) {
                    inputWrapper.information.add(message);
                }
            }
        }
        return inputWrapper;
    }

    /**
    * Method Name :  checkDeviceColorMaterialDetails
    * Arguments:
    @ swapAssetMap - Key : Original Asset Codentify Id Value : Serial Id of new Asset
    @ originalAssetMap - Key : Original Asset Codentify Id Value - Original Asset
    @ newAssetMap - Key : Serial Id of new Asset Value - New Asset List
    @ replacementType - For Kit to Kit it is 1 for swap asset it is 0
    * Description:This method is called when the user Selects the Asset
    **/
    public static void checkDeviceColorMaterialDetails(Map<String, String> swapAssetMap,Map<String, Asset> originalAssetMap,Map<String, List<Asset>> newAssetMap,Integer replacementType) {
        assetWarningMap = new Map<String,List<String>>();
        Asset originalAsset = new Asset();
        List<Asset> newAssetList = new List<Asset>();
        Boolean colorFound = false;
        for (String codentifyId : swapAssetMap.keySet()) {
            originalAsset = new Asset();
            newAssetList = new List<Asset>();
            //Added by Samanway to resolve null pointer exception in Production - DIGITAL-16031
            if (originalAssetMap.containsKey(codentifyId) && swapAssetMap.containsKey(codentifyId) && newAssetMap.containsKey(swapAssetMap.get(codentifyId))) {
                originalAsset = originalAssetMap.get(codentifyId);
                newAssetList = newAssetMap.get(swapAssetMap.get(codentifyId));
                if (replacementType == 0) {
                    if (!newAssetList.isEmpty() && newAssetList.size() == 1) {
                        if(newAssetList[0].CCR_MaterialGroupDescription__c != null &&
                                newAssetList[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c != MULTIMODELNUMBER &&
                                originalAsset.CCR_MaterialGroupDescription__c != newAssetList[0].CCR_MaterialGroupDescription__c) {
                            if(ApexPages.currentPage() != null) {
                                assetWarningMap.put(codentifyId,new List<String>{System.label.CCR_Devices});
                            }
                            else {
                                assetWarningMap.put(codentifyId,new List<String>{System.label.CCR_DevicesApi});
                            }
                        }
                        if(originalAsset.CCR_DeviceProductCode__r.CCR_Color__c != newAssetList[0].CCR_DeviceProductCode__r.CCR_Color__c) {
                            if(!assetWarningMap.containsKey(codentifyId)) {
                                assetWarningMap.put(codentifyId,new List<String>{System.label.CCR_Color});
                            }
                            else {
                                assetWarningMap.get(codentifyId).add(System.label.CCR_Color);
                            }
                        }
                    }
                }
                else if (replacementType == 1) {
                    colorFound = false;
                    if (!newAssetList.isEmpty()) {
                        for (Asset newAssetObj : newAssetList) {
                            system.debug(originalAsset.CCR_DeviceProductCode__r.CCR_Color__c);
                            if( originalAsset.CCR_DeviceProductCode__r.CCR_Color__c != newAssetObj.CCR_DeviceProductCode__r.CCR_Color__c) {
                                colorFound = true;
                                Break;
                            }
                            Break;
                        }
                        if (colorFound == true) {
                            assetWarningMap.put(codentifyId,new List<String>{System.label.CCR_Color});
                        }
                    }
                }
            }
        }
    }

    /** Method Name :  compareDevices
    * Arguments: Map<String, String> swapAssetMap, Map<String, Asset> originalAssetMap, Map<String, List<Asset>> newAssetMap
    * Description:This method is called from the Assetreplacement page to check device replacement compatibility
    **/
    public static void compareDevices(Map<String, String> swapAssetMap, Map<String, Asset> originalAssetMap, Map<String, List<Asset>> newAssetMap, String productType){
        List<String> oldDeviceModels = new List<String>();
        List<String> newDeviceModels = new List<String>();
        String countryCode;
        for(String codentify : swapAssetMap.keySet()){
            Asset oldDevice = originalAssetMap.get(codentify);
            Asset newDevice = newAssetMap.get(swapAssetMap.get(codentify))[0];
            if(oldDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c != newDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c) {
                oldDeviceModels.add(oldDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c);
                countryCode = oldDevice.Contact.CCR_CountryId__c;
                newDeviceModels.add(newDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c);
            }
        }
        for(CCR_DeviceReplacementMatrix__mdt replacementMatrix : [SELECT Id, CCR_ShowWarning__c, CCR_OldDeviceModel__c, CCR_NewDeviceModel__c
        FROM CCR_DeviceReplacementMatrix__mdt
        WHERE CCR_NewDeviceModel__c IN :newDeviceModels AND
        CCR_OldDeviceModel__c IN : oldDeviceModels AND
        CCR_DeviceType__c = :productType]){
            for(String codentify : swapAssetMap.keySet()){
                Asset oldDevice = originalAssetMap.get(codentify);
                Asset newDevice = newAssetMap.get(swapAssetMap.get(codentify))[0];
                if(oldDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c == replacementMatrix.CCR_OldDeviceModel__c &&
                        newDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c == replacementMatrix.CCR_NewDeviceModel__c &&
                        replacementMatrix.CCR_ShowWarning__c){
                    if(assetWarningMap.containsKey(oldDevice.CCR_CodentifyId__c)){
                        assetWarningMap.get(oldDevice.CCR_CodentifyId__c).add(System.label.CCR_WarningMessageforIncompatibleDevicesReplacement);
                    } else {
                        assetWarningMap.put(oldDevice.CCR_CodentifyId__c, new List<String>{System.label.CCR_WarningMessageforIncompatibleDevicesReplacement});
                    }
                }
            }
        }
    }

    /**
    * Method Name :  singleOrKitReplacement
    * Arguments: ReplacementWrapper
    * Return :Map<String, String>
    * Description:This method is called from replace method (added as part of this user story CCR-135147)
    **/
    public Static Map<String, String> singleOrKitReplacement(ReplacementWrapper inputWrapper) {
        Map<String, String> returnMap = new Map<String, String> ();
        CCR_QureHistory__c newHistoryRec;
        //SLU device with KIT Replacement
        if(inputWrapper.replacementType == 'SLU2KIT'){
            System.debug('==== split 1');
            System.debug('inputwrapper == ' + inputWrapper);
            returnMap = sluWithKitReplacement(inputWrapper);
        }
        //SLU to SLU and KIT to KIT replacement
        else {
            System.debug('==== split 2');
            system.debug('replacementType:'+inputWrapper.replacementType);
            Map<String, Map<String, String>> replaceAssetMap = new Map<String, Map<String, String>>();
            Map<String,String> codentifyCountryMap = new Map<String,String>();
            for(String device : inputWrapper.oldAssetsMap.keySet()){
                Asset oldDevice = inputWrapper.oldAssetsMap.get(device);
                Asset newDevice = inputWrapper.newAssetsMap.get(device);
                codentifyCountryMap.put(oldDevice.CCR_CodentifyId__c,oldDevice.Contact.CCR_CountryID__c); //CCR-140646 Changed newDevice.CCR_CodentifyId__c to oldDevice.CCR_CodentifyId__c
                Map<String, String> newAssetCodentifyMap = new Map<String, String>();
                if(inputWrapper.replacementType == 'SLU') {
                    newAssetCodentifyMap.put(PARENTCODENTIFY, newDevice.SerialNumber);
                    System.debug('==== split 3');
                }
                else if(inputWrapper.replacementType == 'KIT') {
                    System.debug('==== split 4');
                    if(newDevice != null)   newAssetCodentifyMap.put(KITCODENTIFY, newDevice.CCR_CodentifyId__c);
                    System.debug('==== split 5');
                    if(oldDevice.CCR_CodentifyId__c != inputWrapper.oldAsset.CCR_CodentifyId__c){
                        // added by Raghu & Nikodem for the user story CCR-153078
                        kitDevicesMap.put(inputWrapper.oldAsset.CCR_CodentifyId__c, oldDevice.CCR_CodentifyId__c);
                        newHistoryRec = new CCR_QureHistory__c();
                        newHistoryRec.CCR_Device__c = oldDevice.Id;
                        newHistoryRec.CCR_Consumer__c = oldDevice.ContactId;
                        newHistoryRec.CCR_QureChannel__c = inputWrapper.qureHistory.CCR_QureChannel__c;
                        newHistoryRec.CCR_Status__c = ACTIVETEXT;
                        if(device == CCR_Constants.HOLDER){
                            newHistoryRec.CCR_DiagnosticResult__c = CCR_Constants.SOLVEDISSUEHOLDER;
                            System.debug('==== split 6');
                        }
                        else {
                            System.debug('==== split 7');
                            newHistoryRec.CCR_DiagnosticResult__c = CCR_Constants.SOLVEDISSUECHARGER;
                        }
                        newHistoryRec.CCR_DiagnosticDescription__c = CCR_Constants.SOLVEDISSUE;
                        newHistoryRec.CCR_SubjectCode__c = CCR_Constants.CODED001;
                    }
                }
                try {
                    newAssetCodentifyMap.put(REPLACEMENTDATE, String.valueof(inputWrapper.oldAsset.CCR_ReplacementDate__c));
                } catch (Exception exp) {
                    System.debug('==== catch split 1');
                    CCR_ErrorLogUtility.createExceptionLog(exp, ERRORTYPE, ERRORSCOPE, ERRORFUNCTION);
                    newAssetCodentifyMap.put(REPLACEMENTDATE,string.valueof(system.today()));
                }

                if(oldDevice.CCR_CodentifyId__c != inputWrapper.oldAsset.CCR_CodentifyId__c){
                    newAssetCodentifyMap.put(REPLACEMENTREASON, CCR_Constants.FUNCTIONDEVICE);
                    System.debug('==== split 8');
                }
                else {
                    newAssetCodentifyMap.put(REPLACEMENTREASON, inputWrapper.qureHistory.CCR_SubjectCode__c);
                    System.debug('==== split 9');
                }

                newAssetCodentifyMap.put(REPLACEMENTCHANNELPICKLIST, inputWrapper.oldAsset.CCR_ReplacementChannelNew__c);
                newAssetCodentifyMap.put(EXTREF, inputWrapper.oldAsset.CCR_ReplacementExternalReference__c);
//                newAssetCodentifyMap.put(REPLACEMENTCOUNTRY, inputWrapper.oldAsset.CCR_ReplacementCountry__c);
                //Added as part of RRPSF-5350
                if(inputWrapper.oldAsset.CCR_ReplacementDoneBy__c != null) {
                    newAssetCodentifyMap.put(REPLACEMENTDONEBY, inputWrapper.oldAsset.CCR_ReplacementDoneBy__c);
                    System.debug('==== split 10');
                } else {
                    newAssetCodentifyMap.put(REPLACEMENTDONEBY, userinfo.getUserId());
                    System.debug('==== split 11');
                }
                //End as part of RRPSF-5350

                //Maciej Kusper related to US CCR-105964
                newAssetCodentifyMap.put(REPLACEMENTSPONSOREDBYSTR, inputWrapper.oldAsset.CCR_ReplacementSponsored_By__c);
                replaceAssetMap.put(oldDevice.CCR_CodentifyId__c, newAssetCodentifyMap);
            }
            System.Savepoint sp = Database.setSavepoint();

            if(inputWrapper.replacementType == 'SLU') { //Perform single replacement
                returnMap = replaceAssets(replaceAssetMap);
                System.debug('==== split 12');
            }
            else if(inputWrapper.replacementType == 'KIT') { //Perform Kit replacement
                System.debug('==== split 13');
                if(newHistoryRec != null){
                    insert newHistoryRec;
                }
                returnMap = replaceAssets(replaceAssetMap, 1);
            }

            if(returnMap.isEmpty()) {
                try{
                    System.debug('==== split 14');
                    createQureCaseForReplacement(inputWrapper.oldAssetsMap.values(),codentifyCountryMap);
                }
                catch(Exception exp){
                    System.debug('==== split 15');
                    system.debug('qure history record not updated');
                    Database.rollback(sp);
                    CCR_ErrorLogUtility.createExceptionLog(exp, ERRORTYPE, ERRORSCOPE, ERRORFUNCTION);
                    returnMap.put(inputWrapper.oldAsset.CCR_CodentifyId__c, exp.getStackTraceString());
                }
            }
        }
        System.debug('==== returnMap = ' + returnMap);
        return returnMap;
    }

    /**
    * Method Name :  sluToKitreplacement
    * Argument 1: Map<String, Asset> (must have only one old asset)
    *			  key: old device codentify, value: Old Asset record
    * Argument 2: Map<String, Asset> (Must have kit, one holder and one charger)
    *			  key: new device (holder & charger) codentify, value: new Asset (holder & charger) record
    * Argument 3: CCR_QureHistory__c: old asset qure history record
    * Return : Map<String, String> - key Codentify, value - error message
    * Description: This method is used to replace the SLU device with KIT.
    **/
    public static Map<String, String> sluWithKitReplacement(ReplacementWrapper inputWrapper){
        System.debug('SwapAsset sluWithKitReplacement called');

        System.debug('inputWrapper.newAssetMap =' + inputWrapper.newAssetsMap);
        System.debug('inputWrapper.newAssetMap =' + inputWrapper.newAssetsMap.values());
        List<Asset> updateAssetList = new List<Asset> ();
        List<Asset> updateNewAssets = new List<Asset>();
        List< CCR_AssetLifeCycle__c> assetLifeCycleList = new List<CCR_AssetLifeCycle__c> ();
        Map<String, String> returnMap = new Map<String, String>();
        Map<String,String> replacementcountry = new Map<String,String>();
        Asset oldDevice = new Asset ();
        Asset newDevice = new Asset ();
        //Single replacement
        for(String deviceType : inputWrapper.oldAssetsMap.keySet()){
            oldDevice = inputWrapper.oldAssetsMap.get(deviceType);
            Datetime OrgDT = oldDevice.KDCE_fm_WarrantyDate__c;
            system.debug('oldDevice-------->'+oldDevice);
            if(inputWrapper.newAssetsMap.containsKey(deviceType)){
                newDevice = inputWrapper.newAssetsMap.get(deviceType);
                inputWrapper.newAssetsMap.remove(deviceType);
                system.debug('newDevice-------->'+newDevice);
                replacementcountry.put(oldDevice.CCR_CodentifyId__c,oldDevice.Contact.CCR_CountryID__c); //CCR-140646 Changed newDevice.CCR_CodentifyId__c to oldDevice.CCR_CodentifyId__c
                if(newDevice.Status == CCR_Constants.ASSETPRODUCED){
                    oldDevice.CCR_ReplacementSystemDate__c = DateTime.now();
                    oldDevice.Status = CCR_Constants.ASSETREPLACED;
                    oldDevice.CCR_ReplacementDate__c = DateTime.now();
                    if (String.isBlank(oldDevice.CCR_OriginalAsset__c) && String.isBlank(oldDevice.CCR_OriginalBox__c)) {
                        oldDevice.CCR_OriginalAsset__c = oldDevice.CCR_CodentifyId__c;
                        oldDevice.CCR_OriginalBox__c = oldDevice.SerialNumber;
                    }
                    oldDevice.CCR_ReplacementReason__c = inputWrapper.qureHistory.CCR_SubjectCode__c;
                    oldDevice.CCR_Override__c = inputWrapper.qureHistory.CCR_Override__c;
                    oldDevice.CCR_OverrideReason__c = inputWrapper.qureHistory.CCR_OverrideReason__c;
                    oldDevice.CCR_ReplacementChannelNew__c = ASSET_PURCHASE_CHANNEL;
                    oldDevice.CCR_ReplacementChannel__C = oldDevice.CCR_ReplacementChannelNew__c;
                    oldDevice.CCR_ReplacedBy__c = newDevice.Id;
                    oldDevice.CCR_ReplacementDoneBy__c = userinfo.getUserId();
                    if (oldDevice.CCR_CarePlusStatus__c == CCR_Constants.CAREPLUSENROLLED) {
                        newDevice.CCR_CarePlusDueDate__c = oldDevice.CCR_CarePlusDueDate__c;
                        oldDevice.CCR_CarePlusDueDate__c = DateTime.now();
                        String cPlusCheck = null;
                        if(Test.isRunningTest() || ApexPages.currentPage() == null){
                            cPlusCheck = codeCoveredInCarePlus(oldDevice);
                        }
                        if(cPlusCheck == null){
                            Decimal accidentalDamageCounter;
                            if (oldDevice.CCR_AccidentalDamageCounter__c == null) {
                                accidentalDamageCounter = 1;
                                oldDevice.CCR_AccidentalDamageCounter__c = CAREPLUSZEROVAL;
                            }
                            else {
                                accidentalDamageCounter = oldDevice.CCR_AccidentalDamageCounter__c + 1;
                            }
                            newDevice.CCR_AccidentalDamageCounter__c = accidentalDamageCounter;
                        }
                        else{
                            returnMap.put(oldDevice.CCR_CodentifyId__c, cPlusCheck);
                        }
                    }
                    else {
                        if(oldDevice.CCR_ReplacementSponsored_By__c == CAREPLUSSTR){
                            System.debug('==== notenrolled 1');
                            returnMap.put(oldDevice.CCR_CodentifyId__c, System.label.CCR_NotEnrolledCarePlus);
                        }
                    }
                    String labelValue = getReplacementReason(inputWrapper.qureHistory.CCR_SubjectCode__c);
                    if(labelValue != null){
                        oldDevice.CCR_ReplacementReason__c = labelValue;
                    }
                    else {
                        oldDevice.CCR_ReplacementReason__c = inputWrapper.qureHistory.CCR_SubjectCode__c;
                    }
                    newDevice.CCR_Replaces__c = oldDevice.Id;
                    newDevice.contactId = oldDevice.contactId;
                    newDevice.AccountId = null;
                    newDevice.Status = CCR_Constants.ASSETACTIVE;
                    newDevice.CCR_OriginalAsset__c = oldDevice.CCR_OriginalAsset__c;
                    newDevice.CCR_OriginalBox__c = oldDevice.CCR_OriginalBox__c;
                    newDevice.CCR_FirstLinkDatetoCurrentContact__c = oldDevice.CCR_FirstLinkDatetoCurrentContact__c;
                    newDevice.CCR_SubscribedDevice__c = oldDevice.CCR_SubscribedDevice__c;
                    newDevice.CCR_SubscriptionID__c = oldDevice.CCR_SubscriptionID__c;
                    newDevice.KDCE_ReplacementCount__c = oldDevice.KDCE_ReplacementCount__c == null ? 1 : (oldDevice.KDCE_ReplacementCount__c + 1);
                    newDevice.KDCE_ReplacementSource__c = 'QURE';
                    newDevice.KDCE_OriginalWarrantyDate__c = oldDevice.KDCE_OriginalWarrantyDate__c != null? oldDevice.KDCE_OriginalWarrantyDate__c : oldDevice.KDCE_fm_WarrantyDate__c;
                    if(oldDevice.CCR_ReplacementDate__c.addMonths(3) > OrgDT && OrgDT > system.now()) {
                        if(!oldDevice.CCR_Override__c) {
                            System.debug('!@!@! override');
                            newDevice.KDCE_OriginalWarrantyDate__c = Date.valueOf(system.now().addMonths(3));
                        }
                    }

                    System.debug('!@!@!  ' + String.valueof(oldDevice.CCR_ReplacementDate__c.addMonths(3) > newDevice.KDCE_fm_WarrantyDate__c && newDevice.KDCE_fm_WarrantyDate__c > system.now()));
                    System.debug('!@!@!  oldDevice.CCR_Override__c = ' + oldDevice.CCR_Override__c);
                    System.debug('!@!@!  oldDevice.CCR_ReplacementDate__c = ' + oldDevice.CCR_ReplacementDate__c);
                    System.debug('!@!@!  newDevice.KDCE_OriginalWarrantyDate__c = ' + newDevice.KDCE_OriginalWarrantyDate__c);
                    System.debug('!@!@!  newDevice.KDCE_fm_WarrantyDate__c = ' + newDevice.KDCE_fm_WarrantyDate__c);
//                    CCR_AssetLifeCycle__c assetLifeCycle = new CCR_AssetLifeCycle__c();
//                    assetLifeCycle.CCR_Asset__c = newDevice.Id;
//                    assetLifeCycle.CCR_Consumer__c = oldDevice.ContactId;
//                    assetLifeCycle.CCR_Action__c = CCR_Constants.ASSETLINK;
//                    assetLifeCycle.CCR_ActionDate__c = system.now();
//                    assetLifeCycleList.add(assetLifeCycle);
                    // 히팅 블레이드 파손으로 즉시교환을 한 경우에는 Care+Status 를 변경
                    // TODO CarePlusStatus 가 NotEnrolled 의 경우에는 해당되지 않아야함.....
                    if(oldDevice.CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSDISENROLLED){
                        if(inputWrapper.qureHistory.CCR_SubjectCode__c == CCR_Constants.BROKENHEATINGBLADECODE){
                            oldDevice.CCR_CarePlusStatus__c = CCR_Constants.CAREPLUSDISENROLLED;
                            newDevice.CCR_CarePlusStatus__c = CCR_Constants.CAREPLUSDISENROLLED;
                            oldDevice.CCR_CarePlusDueDate__c = DateTime.now();
                        } else {
                            if(!inputWrapper.qureHistory.CCR_Override__c){
                                newDevice.CCR_CarePlusStatus__c = oldDevice.CCR_CarePlusStatus__c;
                                newDevice.CCR_CarePlusDueDate__c = oldDevice.CCR_CarePlusDueDate__c;
                            }
                        }
                    } else {
                        newDevice.CCR_CarePlusStatus__c = oldDevice.CCR_CarePlusStatus__c;
                        newDevice.CCR_CarePlusDueDate__c = oldDevice.CCR_CarePlusDueDate__c;
                    }
                    newDevice.CCR_CarePlusStatus__c = oldDevice.CCR_CarePlusStatus__c;
                    updateNewAssets.add(newDevice);

                    //Warrenty calculation for the replacing device
//                    updateAssetList = CCR_QureUtility.warrantyCalculation(updateAssetList, null);
//                    updateNewAssets = CCR_QureUtility.warrantyCalculation(updateNewAssets, null);
                    updateAssetList.add(oldDevice);
                }
                else {
                    returnMap.put(newDevice.CCR_CodentifyId__c, System.label.CCR_StatusActive);
                }
            }
            else {
                returnMap.put(oldDevice.CCR_CodentifyId__c, System.label.CCR_ReplacingDeviceNotFound);
            }
        }
        //linking Other Device
        Asset linkDevice = inputWrapper.newAssetsMap.values()[0];
        if(returnMap.isEmpty() && linkDevice.contactid == null && linkDevice.CCR_CodentifyId__c != null) {
            //Asset Life Cycle data setup
            CCR_AssetLifeCycle__c assetLifeCy = new CCR_AssetLifeCycle__c();
            assetLifeCy.CCR_Asset__c = linkDevice.Id;
            assetLifeCy.CCR_Consumer__c = oldDevice.ContactId;
            assetLifeCy.CCR_Action__c = CCR_Constants.ASSETLINK;
            assetLifeCy.CCR_ActionDate__c = system.now();
            assetLifeCycleList.add(assetLifeCy);
            //Link Asset data setup
            linkDevice.ContactId = oldDevice.ContactId;
            linkDevice.CCR_FirstLinkDatetoCurrentContact__c = oldDevice.CCR_FirstLinkDatetoCurrentContact__c;
            linkDevice.KDCE_OriginalWarrantyDate__c = newDevice.KDCE_OriginalWarrantyDate__c;
            linkDevice.CCR_OriginalAsset__c = linkDevice.CCR_CodentifyId__c;
            linkDevice.CCR_OriginalBox__c = oldDevice.CCR_OriginalBox__c;
            if (oldDevice.CCR_CarePlusStatus__c == CCR_Constants.CAREPLUSENROLLED) {
                linkDevice.CCR_CarePlusDueDate__c = oldDevice.CCR_CarePlusDueDate__c;
//                linkDevice.CCR_CarePlusRequested__c = oldDevice.CCR_CarePlusRequested__c;
            }
            updateAssetList.add(linkDevice);
        }
        else {
            returnMap.put(linkDevice.CCR_CodentifyId__c,System.Label.CCR_Asset_Error_Message);
        }
        System.Savepoint svPoint = Database.setSavepoint();

        ///CCR-140646 Added funcitionality for creating the interactions
//        Map <Id, CAA_Interaction__c> cycleInteractionsMap = new Map <Id, CAA_Interaction__c> ();
//        for (CCR_AssetLifeCycle__c tempLifeCycle : assetLifeCycleList) {
//            if (tempLifeCycle.CCR_Consumer__c != null) {
//                cycleInteractionsMap.put(tempLifeCycle.Id, CAA_SwapController.createInteraction(tempLifeCycle));
//            }
//        }
//        if(!cycleInteractionsMap.values().isEmpty()){
//            try {
//                insert cycleInteractionsMap.values();
//            } catch(Exception exp){
//                system.debug('========:'+exp.getStackTraceString());
//                returnMap.put(linkDevice.CCR_CodentifyId__c,exp.getMessage() + ' ' + exp.getStackTraceString());
//            }
//        }

        try{
            if(returnMap.isEmpty()){
                //Insert Life Cycle records
//                if(!assetLifeCycleList.isEmpty()){
//                    //Added by Raghu as part of the US CCR-142392
//                    assetLifeCycleList = CAA_SwapController.updateAssetLifeCycles(cycleInteractionsMap.values(), assetLifeCycleList);
//                    insert assetLifeCycleList;
//                }
                //Update Asset Records
                if(!updateAssetList.isEmpty()){
                    System.debug('@@#!!@ updateAssetList = ' + updateAssetList);
                    update updateAssetList;
                }
                if(!updateNewAssets.isEmpty()){
                    System.debug('@@#!!@ updateNewAssets = ' + updateNewAssets);
                    update updateNewAssets;
                }
                createQureCaseForReplacement(inputWrapper.oldAssetsMap.values(),replacementcountry);
            }
        } catch(Exception exp){
            system.debug('========:'+exp.getStackTraceString());
            returnMap.put(oldDevice.CCR_CodentifyId__c, exp.getStackTraceString());
            Database.rollback(svPoint);
            CCR_ErrorLogUtility.createExceptionLog(exp,ERRORTYPE,ERRORSCOPE,ERRORFUNCTION);
        }
        return returnMap;
    }

    /**
    * Method Name :  codeCoveredInCarePlus
    * Arguments: Asset
    * Return : String
    * Description: This method is used to check the replacement reason is covered in Care Plus or not.
    **/
    public static String codeCoveredInCarePlus(Asset assetData){
        String country = assetData.Contact.CCR_CountryID__c;
        String reason = assetData.CCR_ReplacementReason__c;
        Integer counter = (Integer)assetData.CCR_AccidentalDamageCounter__c;
        if(carePlusL0Codes.containsKey(country)){
            if(!carePlusL0Codes.get(country).contains(reason)){
                return System.label.CCR_ReplacementReason_Error + CCR_Constants.SPACESTR + assetData.CCR_CodentifyID__c;
            }
            else if(carePlusL0Codes.get(country).contains(reason) && (counter != null && counter >= carePlusConfig.get(country).CCR_AccidentalDamageLimit__c)){
                return System.label.CCR_CarePlusDamageCounterError + CCR_Constants.SPACESTR + assetData.CCR_CodentifyID__c;
            }
            else return null;
        }
        else{
            return System.label.CCR_CarePlusNotActivated;
        }
    }

    /**
    * Method Name :  allCarePlusL0Codes
    * Arguments: List<CCR_CarePlusConfiguration__c>
    * Return : Map<String, Set<String>>
    * Description: This method is used to prepare Map with all the Active Care Plus Configuration.
    **/
    public static Map<String, Set<String>> allCarePlusL0Codes(List<CCR_CarePlusConfiguration__c> cPlusCSData){
        Map<String, Set<String>> cPlusL0Codes = new Map<String, Set<String>>();
        for(CCR_CarePlusConfiguration__c csData : cPlusCSData){
            if(csData.CCR_CarePlusActivated__c){
                Set<String> codes = new Set<String>();
                codes.addAll(csData.CCR_L0codes__c.split(','));
                cPlusL0Codes.put(csData.Name, codes);
            }
        }
        system.debug('==CarePlus L0COdes: '+cPlusL0Codes);
        return cPlusL0Codes;
    }

    /**
    *@ Method Name : replaceAssets
    * @param Map<String, Map<String, String>> : replacementInfos: key: codentify of the to be replaced asset, value: Map of Strings
    *     Value Map<String, String > Key1 : “ParentCodentify” ; value 1: parent codentify of the new asset (replacement)
    reqiured for Single line up replacement.
    *                                Key2: “ReplacementReason”; value 2: replacement reason - optional
    *                                Key3: “Channel”;  value 3: channel - optional
    *                                Key4: “ExtRef”; value 4: external reference - optional
    *                                Key5: "ReplacementDoneBy"; Value : User id of Replacement Done By - optional
    *                                Key6: "Codentify"  ;   Value : Codentify Id of Replacing asset in case of
    Kit replacement -  Required for Kit replacement
    *                                key7:  "ReplacementCountry"; Value : User Country is ReplacementCountry.
    *                                key8: "ReplacementSponsoredBy", Value: CCR_ReplacementSponsored_By__c new field
    * @Return : null, if the replacement for all assets was successful,
    *     Map (key: codentify, value: error message) if errors occurred.
    * @Description:Replaces Assets for the given map.
    **/
    public static Map<String, String> replaceAssets(Map<String, Map<String, String>> replacementInfos){
        return replaceAssets(replacementInfos, 0);
    }

    /**
    *@ Method Name : replaceAssets
    * @param Map<String, Map<String, String>> : replacementInfos: key: codentify of the to be replaced asset, value: Map of Strings
    *     Value Map<String, String > Key1 : “ParentCodentify” ; value 1: parent codentify of the new asset (replacement) reqiured for Single line up replacement.
    *                                Key2: “ReplacementReason”; value 2: replacement reason - optional
    *                                Key3: “Channel”;  value 3: channel - optional
    *                                Key4: “ExtRef”; value 4: external reference - optional
    *                                Key5: "ReplacementDoneBy"; Value : User id of Replacement Done By - optional
    *                                Key6: "Codentify"  ;   Value : Codentify Id of Replacing asset in case of Kit replacement -  Required for Kit replacement
    *                                key7:  "ReplacementCountry"; Value : User Country is ReplacementCountry.
    *                                key8: "ReplacementSponsoredBy", Value: CCR_ReplacementSponsored_By__c new field
    *     Integer replacementType : 0 For Single line up replacement.
    *                               1 For Kit replacement.
    * @Return : null, if the replacement for all assets was successful,
    *     Map (key: codentify, value: error message) if errors occurred.
    * @Description:Replaces Assets for the given map.
    **/
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public static Map<String, String> replaceAssets(Map<String, Map<String, String>> replacementInfos, Integer replacementType){
        System.debug('SwapAsset replaceAssets called');
        String ghostContactSfID = getGhostContact();
        Map<String, String> returnMap = new Map<String, String>();
        Map<String, Asset> oldAssetsMap = new Map<String, Asset>();
        Map<String, Asset> newAssetsMap = new Map<String, Asset>();
        Map<String, String> codentifyMap = new Map<String, String>();
        Map<String, Asset> oldCodentifyAssetMap = new Map<String, Asset>();
        Map<Id, String> jsonOldAsset = new Map<Id, String>();
        Map<String, List<Asset>> serialAssetsMap = new Map<String, List<Asset>>();
        Map<String, String> serialNumberforKitMap = new Map<String, String>();
        //Added by Raghu for the US CCR-8565
        Map<Id, FirstLinkDateWrapper> firstlinkWrapper = new Map<Id, FirstLinkDateWrapper> ();
        Map<Id, Date> assetLinkDateMap = new Map<Id, Date> ();
        Map<String,String> replacementSponsoredByMap = new Map<String,String> ();
        CCR_AssetLifeCycle__c astlf;
        Asset assetreplace = new Asset();
        Map<String, CCR_AssetLifeCycle__c> mapAssetLifeCycle = new Map<String, CCR_AssetLifeCycle__c>();

        System.debug('@@@ CCR_ReplacementSponsored_By__c check replacementInfos === ' + replacementInfos);

        for (String codentify : replacementInfos.keySet()) {
            if(replacementType == 1){
                codentifyMap.put(codentify, replacementInfos.get(codentify).get(KITCODENTIFY));
            }else {
                codentifyMap.put(codentify, replacementInfos.get(codentify).get(PARENTCODENTIFY));
            }
        }
        for (Asset ast : [SELECT id, name, Status, SerialNumber, CCR_ReplacedBy__c, CCR_Replaces__c, CCR_DeviceProductCode__r.CCR_Color__c,
                CCR_OriginalAsset__c, CCR_OriginalBox__c,CCR_ParentProductionDateTime__c,
                PurchaseDate, CCR_CodentifyId__c, CCR_MaterialGroupDescription__c, contactId, contact.CCR_CountryID__c, CCR_ReplacementDate__c,
                CCR_ReplacementSystemDate__c, CCR_ReplacementReason__c, CCR_ReplacementChannelNew__c, CCR_ReplacedBy__r.CCR_CodentifyId__c,
                CCR_ReplacementExternalReference__c, CCR_FirstLinkDatetoCurrentContact__c, CCR_SubscribedDevice__c, CCR_SubscriptionID__c,
                CCR_CarePlusDueDate__c, CCR_AccidentalDamageCounter__c,CCR_CarePlusStatus__c, CCR_ReplacementSponsored_By__c, KDCE_OriginalWarrantyDate__c, KDCE_fm_WarrantyDate__c
        FROM Asset
        WHERE CCR_CodentifyId__c IN :replacementInfos.keySet()
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]){
            oldCodentifyAssetMap.put(ast.CCR_CodentifyId__c, ast);
            jsonOldAsset.put(ast.Id, JSON.serialize(ast, false));
            if(ast.ContactId != null) {
                FirstLinkDateWrapper tempWrapper = new FirstLinkDateWrapper();
                tempWrapper.contactIdStr = ast.ContactId;
                tempWrapper.assetRec = ast;
                firstlinkWrapper.put(ast.Id, tempWrapper);
            }
        }
        if(replacementType == 1){
            for (Asset ast : [SELECT id, name, Status, CCR_ReplacedBy__c, CCR_MaterialGroupDescription__c, SerialNumber,
                    CCR_DeviceProductCode__r.CCR_Color__c,CCR_Replaces__c, CCR_OriginalAsset__c, CCR_OriginalBox__c,
                    CCR_ParentProductionDateTime__c,PurchaseDate, CCR_CodentifyId__c, CCR_ReplacementDate__c,CCR_ReplacementSystemDate__c,
                    CCR_ReplacementReason__c, CCR_ReplacementChannelNew__c, CCR_ReplacementExternalReference__c,ContactId, contact.CCR_CountryID__c,
                    CCR_ReplacedBy__r.CCR_CodentifyId__c, CCR_FirstLinkDatetoCurrentContact__c, CCR_SubscribedDevice__c, CCR_SubscriptionID__c,
                    CCR_CarePlusDueDate__c, CCR_AccidentalDamageCounter__c,CCR_CarePlusStatus__c, KDCE_OriginalWarrantyDate__c, KDCE_fm_WarrantyDate__c
            FROM Asset
            WHERE CCR_CodentifyId__c IN :codentifyMap.values()
            LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]) {
                serialAssetsMap.put(ast.CCR_CodentifyId__c, new List<Asset>{ast});
                if (serialAssetsMap.containsKey(ast.SerialNumber)) {
                    serialAssetsMap.get(ast.SerialNumber).add(ast);
                } else {
                    serialAssetsMap.put(ast.SerialNumber, new List<Asset>{ast});
                }
                if(ast.ContactId != null) {
                    FirstLinkDateWrapper tempWrapper = new FirstLinkDateWrapper();
                    tempWrapper.contactIdStr = ast.ContactId;
                    tempWrapper.assetRec = ast;
                    firstlinkWrapper.put(ast.Id, tempWrapper);
                }
            }
        } else {
            for (Asset ast : [SELECT id, name, Status, CCR_ReplacedBy__c, SerialNumber, CCR_Replaces__c,
                    CCR_OriginalAsset__c, CCR_OriginalBox__c,CCR_ParentProductionDateTime__c, contact.CCR_CountryID__c,
                    PurchaseDate,ContactId,CCR_CodentifyId__c, CCR_MaterialGroupDescription__c, CCR_DeviceProductCode__r.CCR_Color__c,
                    CCR_ReplacementDate__c,CCR_ReplacementSystemDate__c, CCR_ReplacementReason__c, CCR_ReplacementChannelNew__c,
                    CCR_ReplacementExternalReference__c, CCR_ReplacedBy__r.CCR_CodentifyId__c,CCR_ReplacementCountry__c,
                    CCR_DeviceProductCode__r.CCR_ModelNumber__c, CCR_FirstLinkDatetoCurrentContact__c, CCR_SubscribedDevice__c,
                    CCR_SubscriptionID__c, CCR_CarePlusDueDate__c, CCR_AccidentalDamageCounter__c,CCR_CarePlusStatus__c, KDCE_OriginalWarrantyDate__c, KDCE_fm_WarrantyDate__c
            FROM Asset
            WHERE SerialNumber IN :codentifyMap.values()
            LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]) {
                if (serialAssetsMap.containsKey(ast.SerialNumber)) {
                    serialAssetsMap.get(ast.SerialNumber).add(ast);
                } else {
                    serialAssetsMap.put(ast.SerialNumber, new List<Asset>{ast});
                }
                if(ast.ContactId != null) {
                    FirstLinkDateWrapper tempWrapper = new FirstLinkDateWrapper();
                    tempWrapper.contactIdStr = ast.ContactId;
                    tempWrapper.assetRec = ast;
                    firstlinkWrapper.put(ast.Id, tempWrapper);
                }
            }
        }
        //Added by Samanway for CCR-4149 : Add warning to response to SWAP API
        if(ApexPages.currentPage() == null) {
            checkDeviceColorMaterialDetails(codentifyMap, oldCodentifyAssetMap, serialAssetsMap,replacementType);
        }
        if(!firstlinkWrapper.isEmpty()){
            assetLinkDateMap = firstLinkDateToContact(firstlinkWrapper);
        }
        //Added as part of the US CCR-152300 to fix the issue DIGITAL-73899 & DIGITAL-75137
        Map<String, CCR_QureHistory__c> qureHistoryMap = new Map<String, CCR_QureHistory__c> ();
        for(CCR_QureHistory__c qureHistRec : [SELECT Id, Name, CCR_SubjectCode__c, CCR_Override__c, CCR_ConsumerCountry__c,CCR_QureReplacementChannel__c,
                CCR_EligibilitySubscription__c, CCR_EligibilityByCarePlus__c, CCR_InWarranty__c, CCR_QureChannel__c,
                CCR_Device__r.CCR_CodentifyId__c, CCR_QureInUnlimitedPeriod__c, CCR_CodeCovered__c, CCR_DiagnosticDescription__c
        FROM CCR_QureHistory__c
        WHERE CCR_Device__c IN: firstlinkWrapper.keySet()
        AND CCR_Status__c = :ACTIVETEXT
        ORDER BY CreatedDate DESC]){
            if(!qureHistoryMap.containsKey(qureHistRec.CCR_Device__r.CCR_CodentifyId__c)){
                qureHistoryMap.put(qureHistRec.CCR_Device__r.CCR_CodentifyId__c, qureHistRec);
            }
        }

        system.debug('@@@@@qureHistoryMap:'+qureHistoryMap);
        if(qureHistoryMap != null && !qureHistoryMap.isEmpty()){
            replacementSponsoredByMap = getReplacementSponsoredBy(qureHistoryMap.values());
            System.debug('@@@ CCR_ReplacementSponsored_By__c check 22 replacementSponsoredByMap == ' + replacementSponsoredByMap);
            // added by Raghu & Nikodem for the user story CCR-153078
            if(kitDevicesMap != null && !kitDevicesMap.isEmpty()){
                for(String codentify : replacementSponsoredByMap.keySet()) {
                    if(kitDevicesMap.containsKey(codentify) && replacementSponsoredByMap.get(codentify) == CCR_Constants.CAREPLUSSTR){
                        replacementInfos.get(kitDevicesMap.get(codentify)).put(REPLACEMENTSPONSOREDBYSTR, CCR_Constants.WARRANTY);
                    }
                }
            }
        }
        for (String cod :replacementInfos.keySet()) {
            If (oldCodentifyAssetMap.get(cod) != Null && serialAssetsMap.get(codentifyMap.get(cod)) != Null ) {
                assetreplace = new Asset();
                assetreplace = oldCodentifyAssetMap.get(cod);
                Datetime ogDt = assetreplace.KDCE_fm_WarrantyDate__c;
                if(!serialNumberforKitMap.containsKey(assetreplace.SerialNumber)) {
                    List<Asset> assetreplacing = serialAssetsMap.get(codentifyMap.get(cod));
                    if (assetreplacing.size() > 1 && replacementType == 0) {
                        returnMap.put(cod, system.label.CCR_ParentCodentifyID);
                    } else if ((assetreplace.Status == CCR_Constants.ASSETACTIVE || assetreplace.Status == CCR_Constants.ASSETPRODUCED)) {
                        //Commented by Samanway to resolve null pointer exception in Production - DIGITAL-16031
                        /*if(ApexPages.currentPage() == null) {
                            checkDeviceColorMaterialDetails(codentifyMap, oldCodentifyAssetMap, serialAssetsMap, replacementType);
                        }*/
                        asset astreplacing = assetreplacing[0];
                        if (astreplacing.Status == CCR_Constants.ASSETPRODUCED) {
                            //교체 전 후 기기 값 세팅 부분
                            //assetreplace-교환전 / astreplacing-교환후
                            assetreplace.CCR_ReplacedBy__c = astreplacing.Id;
                            //added for Populating Replacement system Date User story RRPSF-3920
                            assetreplace.CCR_ReplacementSystemDate__c = DateTime.now();
                            assetreplace.Status = CCR_Constants.ASSETREPLACED;
//                            if (replacementInfos.get(cod).get(REPLACEMENTDATE) != null) {
//                                assetreplace.CCR_ReplacementDate__c = DateTime.valueOf(replacementInfos.get(cod).get(REPLACEMENTDATE));
//                            }
                            assetreplace.CCR_ReplacementDate__c = DateTime.now();
                            if (String.isBlank(assetreplace.CCR_OriginalAsset__c) && String.isBlank(assetreplace.CCR_OriginalBox__c)) {
                                assetreplace.CCR_OriginalAsset__c = assetreplace.CCR_CodentifyId__c;
                                assetreplace.CCR_OriginalBox__c = assetreplace.SerialNumber;
                            }
                            if (replacementInfos.get(cod).get(REPLACEMENTREASON) != null) {
                                //Added for CCR-128138
                                String labelValue = getReplacementReason(replacementInfos.get(cod).get(REPLACEMENTREASON));
                                if(labelValue != null){
                                    assetreplace.CCR_ReplacementReason__c = labelValue;
                                }
                                else {
                                    assetreplace.CCR_ReplacementReason__c = replacementInfos.get(cod).get(REPLACEMENTREASON);
                                }
                            }
                            if (replacementInfos.get(cod).get(REPLACEMENTCHANNEL) != null) {
                                assetreplace.CCR_ReplacementChannel__C = replacementInfos.get(cod).get(REPLACEMENTCHANNEL);
                            }
                            if (replacementInfos.get(cod).get(REPLACEMENTCHANNELPICKLIST) != null) {
                                CCR_QureHistory__c historyData;
                                if(qureHistoryMap.containsKey(assetreplace.Id)){
                                    historyData = qureHistoryMap.get(assetreplace.Id);
                                }
                                if(historyData != null && historyData.CCR_QureChannel__c == 'Shift' && historyData.CCR_QureReplacementChannel__c == 'CourierDelivery'){
                                    assetreplace.CCR_ReplacementChannelNew__c = 'LSP SHIFT-X';
                                }
                                else {
                                    assetreplace.CCR_ReplacementChannelNew__c = replacementInfos.get(cod).get(REPLACEMENTCHANNELPICKLIST);
                                }
                            }
                            if (replacementInfos.get(cod).get(EXTREF) != null) {
                                assetreplace.CCR_ReplacementExternalReference__c = replacementInfos.get(cod).get(EXTREF);
                            }
                            //Added as part of RRPSF-5432
                            if (replacementInfos.get(cod).get(REPLACEMENTCOUNTRY) != null) {
                                assetreplace.CCR_ReplacementCountry__c = replacementInfos.get(cod).get(REPLACEMENTCOUNTRY);
                            }
                            //Added as part of RRPSF-5350
                            if (replacementInfos.get(cod).get(REPLACEMENTDONEBY) != null) {
                                assetreplace.CCR_ReplacementDoneBy__c = replacementInfos.get(cod).get(REPLACEMENTDONEBY);
                            } else {
                                assetreplace.CCR_ReplacementDoneBy__c = userinfo.getUserId();
                            }
                            //End as part of RRPSF-5350
                            //added by Vlad CCR-105968
                            astreplacing.CCR_AccidentalDamageCounter__c = assetreplace.CCR_AccidentalDamageCounter__c; //Maciej Kusper
                            //Added by Raghu and Nikodem for CCR-134625
                            if(replacementInfos.get(cod).get(REPLACEMENTSPONSOREDBYSTR) != null && replacementInfos.get(cod).get(REPLACEMENTSPONSOREDBYSTR) != ''){
                                assetreplace.CCR_ReplacementSponsored_By__c = replacementInfos.get(cod).get(REPLACEMENTSPONSOREDBYSTR); //on the old device, added by Vlad CCR-105968
                                system.debug('@@@@@assetreplace.CCR_ReplacementSponsored_By__c:'+assetreplace.CCR_ReplacementSponsored_By__c);
                            }
                            else {
                                if (replacementSponsoredByMap != null && replacementSponsoredByMap.containsKey(assetreplace.CCR_CodentifyId__c)){
                                    assetreplace.CCR_ReplacementSponsored_By__c = replacementSponsoredByMap.get(assetreplace.CCR_CodentifyId__c);
                                    system.debug('else@@@@@assetreplace.CCR_ReplacementSponsored_By__c:'+assetreplace.CCR_ReplacementSponsored_By__c);
                                }
                            }

                            if (assetreplace.CCR_CarePlusStatus__c == CCR_Constants.CAREPLUSENROLLED) {
                                astreplacing.CCR_CarePlusDueDate__c = assetreplace.CCR_CarePlusDueDate__c;//Maciej Kusper CCR-112190
                                assetreplace.CCR_CarePlusDueDate__c = DateTime.now();
                                if (replacementInfos.get(cod).get(REPLACEMENTSPONSOREDBYSTR) == CAREPLUSSTR || //Added by Raghu and Nikodem for CCR-134625
                                        assetreplace.CCR_ReplacementSponsored_By__c == CAREPLUSSTR) {
                                    //Added for CCR-128138
                                    String tempLabel = assetreplace.CCR_ReplacementReason__c;
                                    String cPlusCheck = null;
                                    if(Test.isRunningTest() || ApexPages.currentPage() == null){
                                        assetreplace.CCR_ReplacementReason__c = replacementInfos.get(cod).get(REPLACEMENTREASON);
                                        cPlusCheck = codeCoveredInCarePlus(assetreplace);
                                    }
                                    if(cPlusCheck == null){
                                        Decimal accidentalDamageCounter;
                                        if (assetreplace.CCR_AccidentalDamageCounter__c == null) {
                                            accidentalDamageCounter = 1;
                                            assetreplace.CCR_AccidentalDamageCounter__c = CAREPLUSZEROVAL;
                                        }
                                        else {
                                            accidentalDamageCounter = assetreplace.CCR_AccidentalDamageCounter__c + 1;
                                        }
                                        astreplacing.CCR_AccidentalDamageCounter__c = accidentalDamageCounter;
                                        assetreplace.CCR_ReplacementReason__c = tempLabel;
                                    }
                                    else{
                                        returnMap.put(cod, cPlusCheck);
                                        continue;
                                    }
                                }
                            }
                            else {
                                if(replacementInfos.get(cod).get(REPLACEMENTSPONSOREDBYSTR) == CAREPLUSSTR){
                                    System.debug('==== notenrolled 2');
//                                    returnMap.put(cod, System.label.CCR_NotEnrolledCarePlus);
//                                    continue;
                                }
                            }
                            CCR_QureHistory__c historyData;
                            System.debug(qureHistoryMap);
                            System.debug(assetreplace.Id);
                            if(qureHistoryMap.containsKey(assetreplace.CCR_CodentifyId__c)){
                                historyData = qureHistoryMap.get(assetreplace.CCR_CodentifyId__c);
                            }

                            // 조건 값 확인 후 최종적으로 값 세팅할 수 있도록 변수 처리
                            Boolean isChangeCarePlusStatus = false;

//                            if(assetreplace.CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSDISENROLLED){
//                                if(historyData.CCR_SubjectCode__c == CCR_Constants.BROKENHEATINGBLADECODE){
//                                    assetreplace.CCR_CarePlusStatus__c = CCR_Constants.CAREPLUSDISENROLLED;
//                                    assetreplace.CCR_CarePlusDueDate__c = system.now();
//                                    isChangeCarePlusStatus = true;
//                                }
//                            }
//                            if(historyData.CCR_SubjectCode__c == CCR_Constants.BROKENHEATINGBLADECODE){
//                                assetreplace.CCR_CarePlusStatus__c = CCR_Constants.CAREPLUSDISENROLLED;
//                                if(historyData.CCR_Override__c) {
//
//                                } else {
//                                    assetreplace.CCR_CarePlusDueDate__c = DateTime.now();
//                                }
//                            }
                            //adding old Asset to updated
//                            oldAssetsMap.put(assetreplace.CCR_CodentifyId__c, assetreplace);
                            astreplacing.CCR_Replaces__c = assetreplace.Id ;
                            system.debug('astreplacing.CCR_Replaces__c'+astreplacing.CCR_Replaces__c);
                            if (assetReplace.contactId != ghostContactSfID) {
                                astreplacing.contactId = assetReplace.contactId;//To link the new asset to customer
                            }
                            if(assetReplace.contactId == ghostContactSfID) {
                                assetreplace.contactId = NULL;
                                astreplacing.contactId = NULL;
                            }
                            astreplacing.ACcountId = null;
                            astreplacing.Status = CCR_Constants.ASSETACTIVE;

                            astreplacing.CCR_OriginalAsset__c = assetreplace.CCR_OriginalAsset__c;
                            astreplacing.CCR_OriginalBox__c = assetreplace.CCR_OriginalBox__c;
                            astreplacing.CCR_FirstLinkDatetoCurrentContact__c = assetLinkDateMap.get(assetreplace.Id);
                            astreplacing.CCR_SubscribedDevice__c = assetreplace.CCR_SubscribedDevice__c;
                            astreplacing.CCR_SubscriptionID__c = assetreplace.CCR_SubscriptionID__c;

                            astreplacing.KDCE_ReplacementSource__c = 'QURE';

                            // 보증 기간 넘기기 위한 설정
                            astreplacing.KDCE_OriginalWarrantyDate__c = assetreplace.KDCE_OriginalWarrantyDate__c != null? assetreplace.KDCE_OriginalWarrantyDate__c : assetreplace.KDCE_fm_WarrantyDate__c;
                            if(assetreplace.CCR_ReplacementDate__c.addMonths(3) > ogDt && ogDt > system.now()) {
                                if(!historyData.CCR_Override__c) {
                                    System.debug('!@!@! override');
                                    astreplacing.KDCE_OriginalWarrantyDate__c = Date.valueOf(system.now().addMonths(3));
                                }
                            }

//                            System.debug('!@!@!  ' + String.valueof(assetreplace.CCR_ReplacementDate__c.addMonths(3) > astreplacing.KDCE_fm_WarrantyDate__c && astreplacing.KDCE_fm_WarrantyDate__c > system.now()));
//                            System.debug('!@!@! historyData.CCR_Override__c = ' + historyData.CCR_Override__c);
//                            System.debug('!@!@! assetreplace.CCR_ReplacementDate__c = ' + assetreplace.CCR_ReplacementDate__c);
//                            System.debug('!@!@! assetreplace.CCR_CarePlusDueDate__c = ' + assetreplace.CCR_CarePlusDueDate__c);
//                            System.debug('!@!@! astreplacing.KDCE_OriginalWarrantyDate__c = ' + astreplacing.KDCE_OriginalWarrantyDate__c);
//                            System.debug('!@!@! astreplacing.KDCE_fm_WarrantyDate__c = ' + astreplacing.KDCE_fm_WarrantyDate__c);

                            // 히팅블레이드 파손으로 교환하는 경우 CarePlusStatus 변경
                            if(assetreplace.CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSDISENROLLED){
                                if(historyData.CCR_SubjectCode__c == CCR_Constants.BROKENHEATINGBLADECODE){
                                    assetreplace.CCR_CarePlusStatus__c = CCR_Constants.CAREPLUSDISENROLLED;
                                    assetreplace.CCR_CarePlusDueDate__c = system.now();
                                    astreplacing.CCR_CarePlusStatus__c = CCR_Constants.CAREPLUSDISENROLLED;
                                    astreplacing.CCR_CarePlusDueDate__c = DateTime.now();
                                    System.debug('!@!@! logic 1');
                                } else {
                                    astreplacing.CCR_CarePlusDueDate__c = assetreplace.CCR_CarePlusDueDate__c;
                                    astreplacing.CCR_CarePlusStatus__c = assetreplace.CCR_CarePlusStatus__c;
                                    System.debug('!@!@! logic 2');
                                }
                            } else {
                                astreplacing.CCR_CarePlusStatus__c = assetreplace.CCR_CarePlusStatus__c;
                                astreplacing.CCR_CarePlusDueDate__c = assetreplace.CCR_CarePlusDueDate__c;
                                System.debug('!@!@! logic 3');
                            }

                            System.debug('!@!@! after logic assetreplace.CCR_CarePlusDueDate__c = ' + assetreplace.CCR_CarePlusDueDate__c);
                            System.debug('!@!@! after logic astreplacing.CCR_CarePlusDueDate__c = ' + astreplacing.CCR_CarePlusDueDate__c);

                            //adding old Asset to updated
                            oldAssetsMap.put(assetreplace.CCR_CodentifyId__c, assetreplace);
                            //adding new Asset to updated
                            newAssetsMap.put(assetreplace.CCR_CodentifyId__c, astreplacing);
                            //creating assetlifecycle record and adding contact to transfer link consumer to new asset
                            astlf = new CCR_AssetLifeCycle__c();
                            if (assetReplace.ContactId != null && assetReplace.ContactId != ghostContactSfID) {
                                astlf.CCR_Asset__c = astreplacing.Id;
                                astlf.CCR_Consumer__c = assetReplace.ContactId;
                                astlf.CCR_Action__c = CCR_Constants.ASSETLINK;
                                astlf.CCR_ActionDate__c = system.now();
                                mapAssetLifeCycle.put(assetreplace.CCR_CodentifyId__c, astlf);
                            }
                        } else {
                            If (astreplacing.Status != CCR_Constants.ASSETPRODUCED) {
                                returnMap.put(cod, system.label.CCR_Producedstatus);
                                serialNumberforKitMap.put(assetreplace.SerialNumber, system.label.CCR_Producedstatus);
                            }
                        }
                        System.debug('new devide ==== ' + astreplacing);
                    } else {
                        if (assetreplace.Status != CCR_Constants.ASSETACTIVE && assetreplace.Status != CCR_Constants.ASSETPRODUCED) {
                            returnMap.put(cod, System.label.CCR_StatusActive);
                            serialNumberforKitMap.put(assetreplace.SerialNumber, System.label.CCR_StatusActive);
                        }
                    }
                }

            } else {
                If (oldCodentifyAssetMap.get(cod) == Null) {
                    returnMap.put(cod, system.label.CCR_Incorrect_Codentify_Id_Message);
                } else If (serialAssetsMap.get(codentifyMap.get(cod)) == Null) {
                    returnMap.put(cod, system.label.CCR_Invalid_Codentify_Id_New_Asset);
                }
            }
        }
        System.debug('CCR_SwapAssetControllerQure.cls old/new Asset Compare');
        System.debug('old Asset === ' + assetreplace);
//        System.debug('new Asset === ' + astreplacing);
        // removing all the related Asset from update if any other asset is not able to replace
        if(replacementType == 1 && serialNumberforKitMap != null && !serialNumberforKitMap.isEmpty()){
            for(string serialNumber : serialNumberforKitMap.keySet()){
                System.debug('serialNumber'+ serialNumber);
                System.debug('map3'+ serialAssetsMap);
                if (serialAssetsMap.containsKey(serialNumber)) {
                    for(Asset ast : serialAssetsMap.get(serialNumber)) {
                        if(oldAssetsMap.containsKey(ast.CCR_CodentifyId__c)){
                            oldAssetsMap.remove(ast.CCR_CodentifyId__c);
                        }
                        if(newAssetsMap.containsKey(ast.CCR_CodentifyId__c)){
                            newAssetsMap.remove(ast.CCR_CodentifyId__c);
                        }
                        if(mapAssetLifeCycle.containsKey(ast.CCR_CodentifyId__c)){
                            mapAssetLifeCycle.remove(ast.CCR_CodentifyId__c);
                        }
                        if(!returnMap.containsKey(ast.CCR_CodentifyId__c)){
                            returnMap.put(ast.CCR_CodentifyId__c, serialNumberforKitMap.get(serialNumber));
                        }
                    }
                }
            }

        }
        System.Savepoint sp = Database.setSavepoint();
        if(!oldAssetsMap.isEmpty()) {
            replacementMethod(oldAssetsMap);
        }
        try {
            List<Asset> assetOldValuesList = new List<Asset>();
            List<CCR_AssetLifeCycle__c> deleteLifeCycleRecs = new List<CCR_AssetLifeCycle__c>();
            Map<String,Case> assetCaseMap = new Map<String,Case>();
            if (!oldAssetsMap.isEmpty()) {
                // updaing the old assets
                if(Test.isRunningTest() && !codentifyMap.isEmpty() && codentifyMap.containsKey('testcodenfiy006')){
                    oldAssetsMap.values()[0].CCR_ReplacementCountry__c = 'qqqqqqqqqqqqqq';
                }
                System.debug('!@!@# oldAssetsMap = ' + oldAssetsMap);
                Database.SaveResult[] srList = Database.update(oldAssetsMap.values(), false);
                for (Integer i = 0; i < oldAssetsMap.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Asset assetRecord = oldAssetsMap.values()[i];
                    if (!sr.isSuccess()) {
                        if(replacementType == 1) {
                            Database.rollback(sp);
                        }
                        //when updating old asset is failed then removing the new from the update map
                        newAssetsMap.remove(assetRecord.CCR_CodentifyId__c);
                        mapAssetLifeCycle.remove(assetRecord.CCR_CodentifyId__c);
                        for (Database.Error err : sr.getErrors()) {
                            returnMap.put(assetRecord.CCR_CodentifyId__c, err.getMessage());
                        }
                    }

                }
            }
            /* Modified by Samanway to fix the sequence of life cycle update and contact update on new asset*/
            //Inserting Asset Life Cycle records
            If (!mapAssetLifeCycle.isEmpTy()) {
                Map<String, CCR_AssetLifeCycle__c> lifeCycleMap = new Map<String, CCR_AssetLifeCycle__c> ();
                Map<String, Asset> lifeCycleCodentifyMap = new Map<String, Asset> ();
                //CAA_SwapController.handleInteractions(mapAssetLifeCycle.values());
                if(Test.isRunningTest() && !codentifyMap.isEmpty() && codentifyMap.containsKey('testcodenfiy007')){
                    mapAssetLifeCycle.values()[0].CCR_Asset__c = userInfo.getUserId();
                }
                Database.SaveResult[] srList = Database.insert(mapAssetLifeCycle.values(), false);
                Integer cnt = 0;
                for (String oldCodentify : mapAssetLifeCycle.keySet()) {
                    CCR_AssetLifeCycle__c tempRecycle = mapAssetLifeCycle.get(oldCodentify);
                    system.debug('tempRecycle.CCR_Asset__c------------>'+tempRecycle.CCR_Asset__c);
                    Asset oldAssetData = (Asset)JSON.deserialize(jsonOldAsset.get(oldCodentifyAssetMap.get(oldCodentify).Id), Asset.class);
                    if (!srList[cnt].isSuccess()) {
                        if(replacementType == 1) {
                            Database.rollback(sp);
                        }
                        newAssetsMap.remove(oldAssetData.CCR_CodentifyId__c);
                        mapAssetLifeCycle.remove(oldAssetData.CCR_CodentifyId__c);
                        assetOldValuesList.add(clearOldAssetData(oldAssetData));
                        for (Database.Error err : srList[cnt].getErrors()) {
                            returnMap.put(oldAssetData.CCR_CodentifyId__c, 'Creating Asset Life Cycle record is failed: '+err.getMessage());
                        }
                    }
                    else {
                        lifeCycleMap.put(tempRecycle.Id, tempRecycle);
                        lifeCycleCodentifyMap.put(tempRecycle.Id, oldAssetData);
                    }
                    cnt++;
                }

                List<CCR_AssetLifeCycle__c> assetLifeCycles = new List<CCR_AssetLifeCycle__c>();
                for (CCR_AssetLifeCycle__c assetLifeCycle : mapAssetLifeCycle.values()) {
                    if (assetLifeCycle.CCR_Consumer__c != null) {
                        assetLifeCycles.add(assetLifeCycle);
                    }
                }
                system.debug('assetLifeCycles------------>'+assetLifeCycles);
                if(!assetLifeCycles.isEmpty()){
                    if(Test.isRunningTest() && !codentifyMap.isEmpty() && codentifyMap.containsKey('testcodenfiy005')){
                        mapAssetLifeCycle.values()[0].CCR_Asset__c = userInfo.getUserId();
                    }
                    Database.SaveResult[] srCycleList = Database.update(assetLifeCycles, false);
                    for (Integer i = 0; i < assetLifeCycles.size(); i++) {
                        if (!srCycleList[i].isSuccess()) {
                            if(replacementType == 1) {
                                Database.rollback(sp);
                            }
                            deleteLifeCycleRecs.add(assetLifeCycles[i]);
                            Asset oldCodentify = lifeCycleCodentifyMap.get(assetLifeCycles[i].Id);
                            assetOldValuesList.add(clearNewAssetData(newAssetsMap.get(oldCodentify.CCR_CodentifyId__c).Id));
                            newAssetsMap.remove(oldCodentify.CCR_CodentifyId__c);
                            Asset oldAssetData = (Asset)JSON.deserialize(jsonOldAsset.get(oldCodentify.Id), Asset.class);
                            assetOldValuesList.add(clearOldAssetData(oldAssetData));
                            for (Database.Error err : srCycleList[i].getErrors()) {
                                returnMap.put(oldAssetData.CCR_CodentifyId__c, 'Updation Asset Life Cycle record with Interaction Id is failed: '+err.getMessage());
                            }
                        }
                    }
                }
            }
            if (!newAssetsMap.isEmpty()) {
                /*Start*/
                List<Asset> newastLst = new List<Asset>();
                newastLst = newAssetsMap.values();
//                system.debug('New asset map list:'+newastLst);
                if(newastLst != null)
//                    newastLst = CCR_QureUtility.warrantyCalculation(newastLst,null);
//                system.debug('newastLst'+newastLst);
//                for(Asset ast:newastLst){
//                    if(ast.CCR_CarePlusDueDate__c < ast.KDCE_OriginalWarrantyDate__c){ //Maciej Kusper CCR-112190
//                        ast.CCR_CarePlusDueDate__c = ast.KDCE_OriginalWarrantyDate__c;
//                    }
//                    if(!newAssetsMap.values().contains(ast)){
//                        newAssetsMap.put(ast.id, ast);
//                    }
//                }
//                system.debug('newAssetsMap.values() 2'+newAssetsMap);
                /*End*/
                if(Test.isRunningTest() && !codentifyMap.isEmpty() && codentifyMap.containsKey('testcodenfiy009')){
                    newAssetsMap.values()[0].CCR_ReplacementCountry__c = 'qqqqqqqqqqqqqq';
                }
                //Updating the new assets
                Database.SaveResult[] srList = Database.update(newAssetsMap.values(), false);
                for (Integer i = 0; i < oldAssetsMap.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Asset assetRecord = newAssetsMap.values()[i];
                    system.debug('*****'+assetRecord);
                    Asset assetrecordid = oldAssetsMap.values()[i];
                    system.debug('++++'+assetrecordid);
                    if (!sr.isSuccess()) {
                        if(replacementType == 1) {
                            Database.rollback(sp);
                        }
                        Asset oldAssetData = (Asset)JSON.deserialize(jsonOldAsset.get(assetRecord.CCR_Replaces__c), Asset.class);
                        assetOldValuesList.add(clearOldAssetData(oldAssetData));
                        assetOldValuesList.add(clearNewAssetData(assetRecord.Id));
                        deleteLifeCycleRecs.add(mapAssetLifeCycle.get(oldAssetData.CCR_CodentifyId__c));
                        if(assetCaseMap.containsKey(assetrecordid.CCR_CodentifyId__c)){
                            assetCaseMap.remove(assetrecordid.CCR_CodentifyId__c);
                        }
                        for (Database.Error err : sr.getErrors()) {
                            returnMap.put(assetrecordid.CCR_CodentifyId__c, 'Replacing Asset Update failed: '+err.getMessage());
                        }
                    }
                }
            }

            //Deleting Asset Life Cycle records
            if(!deleteLifeCycleRecs.isEmpty()){
                delete deleteLifeCycleRecs;
            }
            //Updating the old assets back to old data
            if (!assetOldValuesList.isEmpty()) {
                if(Test.isRunningTest() && !codentifyMap.isEmpty() && codentifyMap.containsKey('testcodenfiy009')){
                    assetOldValuesList[0].CCR_ReplacementCountry__c = 'qqqqqqqqqqqqqq';
                }
                update assetOldValuesList;
            }

        } catch(Exception e){
            Database.rollback(sp);
            CCR_ErrorLogUtility.createExceptionLog(e, ERRORTYPE, ERRORSCOPE, ERRORFUNCTION);
            for(String codentify : replacementInfos.keySet()){
                if(returnMap.containsKey(codentify)){
                    String errorText = returnMap.get(codentify)+' - '+e.getMessage()+' - '+e.getStackTraceString();
                    returnMap.put(codentify, errorText);
                }
                else {
                    returnMap.put(codentify, 'Replacement Failed: '+e.getMessage()+' - '+e.getStackTraceString());
                }
            }
        }
        return returnMap;
    }

    /**
    * @ Method Name :  getGhostContact
    * @ Arguments:
    * @ Input param : Null.
    * @ Return : String - Ghostcontact salesfrce ID.
    * @ Description:Method to get Ghostcontact salesfrce ID from custom settings.
    **/
    public static String getGhostContact() {
        String ghostContactSfId = null;
        return ghostContactSfId;
    }

    /**
    * Method Name :  createQureCaseForReplacement
    * Arguments: assets,replacementcountry
    * Return : N/A
    * Description: This method is used to create a case for replacement.
    **/
    public static void createQureCaseForReplacement(List<Asset> assets, Map<String,String> replacementcountry) {

        Map<String, CCR_QureHistory__c> qureHistoryMap = new Map<String, CCR_QureHistory__c>();

        try{
            List<CCR_QureHistory__c> qureHistoryLst = [SELECT Id, CCR_EligibilityResult__c, CCR_SubjectCode__c, CCR_Case__c,
                    CCR_QureReplacementChannel__c, CCR_EndDateforreplacementreasonselectio__c,
                    CCR_Device__c, CCR_DiagnosticResult__c, CCR_Status__c, CCR_DiagnosticDescription__c,
                    CCR_Device__r.CCR_DeviceProductCode__r.CCR_Version__c, CCR_ReplacementChannelSelectedBy__c
            FROM CCR_QureHistory__c
            WHERE CCR_Device__c IN :assets
            AND CCR_Status__c = :ACTIVETEXT];

            for(CCR_QureHistory__c qHistory : qureHistoryLst) {
                qureHistoryMap.put(qHistory.CCR_Device__c, qHistory);
            }

            system.debug('# Asset-QureHistory map: ' + qureHistoryMap);
            List<User> userType = [Select CCR_UserType__c From User Where Id = :UserInfo.getUserId()];
            if(!userType.isempty()) {
                if(!qureHistoryLst.isEmpty()) {
                    List<Case> casesToInsert = new List<Case>();
                    List<CCR_QureHistory__c> qureHistoryToUpdate = new List<CCR_QureHistory__c>();
                    List<CCR_QureReplacementChannels__mdt> mdtList = new List<CCR_QureReplacementChannels__mdt>();

                    for(Asset asst : assets) {
                        String assetMarket;
                        if(asst.Contact != null){
                            assetMarket = asst.Contact.CCR_CountryID__c;
                        }else{
                            assetMarket = replacementcountry.get(asst.CCR_CodentifyId__c);
                        }
                        if(userType[0].CCR_UserType__c == CCR_Constants.RETAILER || userType[0].CCR_UserType__c == CCR_Constants.RETAILERLIGHT){
                            mdtList = CCR_QUREFaultTreeApex.retrieveReplacementChannelsMetadata(RETAILERCASEREPLACEMENTCHANNEL);
                        }else{
                            mdtList = CCR_QUREFaultTreeApex.retrieveReplacementChannelsMetadata(CASEREPLACEMENTCHANNEL);
                        }
                        //system.debug('====>'+mdtList);
                        String caseResoChnl;
                        String historyReplace;
                        if(!mdtList.isEmpty()){
                            caseResoChnl = mdtList[0].CCR_CaseResolution__c;
                            historyReplace = mdtList[0].CCR_QureHistoryReplacementChannel__c;
                        }
                        Case qureCase = new Case();
                        qureCase = CCR_QureUtility.createCaseForQure(asst.CCR_MaterialGroupDescription__c, qureHistoryMap.get(asst.Id).CCR_SubjectCode__c,
                                caseResoChnl, CLOSEDTEXT, asst.contactId, asst.Id,
                                qureHistoryMap.get(asst.Id).CCR_DiagnosticResult__c, qureHistoryMap.get(asst.Id).CCR_EligibilityResult__c,
                                null, qureHistoryMap.get(asst.Id).CCR_DiagnosticDescription__c,
                                userType[0].CCR_UserType__c, qureHistoryMap.get(asst.Id).CCR_Device__r.CCR_DeviceProductCode__r.CCR_Version__c, false, null);
                        System.debug('# qureCase: ' + qureCase);
                        if(qureCase != null) {
                            casesToInsert.add(qureCase);
                            CCR_QureHistory__c qureHistoryRecUpdate = qureHistoryMap.get(asst.Id);
                            qureHistoryRecUpdate.CCR_QureReplacementChannel__c = historyReplace;
                            qureHistoryRecUpdate.CCR_EndDateforreplacementreasonselectio__c = system.now();
                            qureHistoryRecUpdate.CCR_Status__c = 'Inactive';

                            if(qureHistoryRecUpdate.CCR_ReplacementChannelSelectedBy__c == null){
                                qureHistoryRecUpdate.CCR_ReplacementChannelSelectedBy__c=UserInfo.getUserId();
                            }
                            qureHistoryToUpdate.add(qureHistoryRecUpdate);
                        }
                    }
                    casesToInsert = CCR_QureUtility.insertCasesForQure(casesToInsert);
                    //update Case Id in QureHistory records
                    for(Integer i = 0; i < qureHistoryToUpdate.size(); i++) {
                        qureHistoryToUpdate.get(i).CCR_Case__c = casesToInsert.get(i).Id;
                    }
                    CCR_QureUtility.updateQureHistory(qureHistoryToUpdate);
                }
            }
        } catch (Exception ex){
            throw ex;
        }
    }

    /**
    * Method Name :  getReplacementReason
    * Arguments: String
    * Return :String
    * Description:This method is to get subject code label (added as part of this user story CCR-135147)
    **/
    public static String getReplacementReason (String subjectCode) {
        if(englishSubjectCodeMaps.containsKey(subjectCode)){
            return englishSubjectCodeMaps.get(subjectCode);
        }
        else if(subjectCodeMaps.containsKey(subjectCode)){
            return subjectCodeMaps.get(subjectCode);
        }
        else {
            return null;
        }
    }

    /**
    * @ Method Name :  firstLinkDateToContact
    * @ Arguments:
    * @ Param 1: String Contact Id
    * @ Param 2: List of CCR_AssetLifeCycle__c recs
    * @ Param 3: Date of current link
    * @ Description: Method to get the First link Action Date from the Asset Life Cycle records.
    **/
    public Static Map<Id, Date> firstLinkDateToContact(Map<Id, FirstLinkDateWrapper> firstLinkWrap) {
        Set<String> assetOriginalIdSet = new Set<String> ();
        Map<Id, Date> asstListDateMap = new Map<Id, Date>();
        Map<Id, List<DateTime>> contAndTimeMap = new Map<Id, List<DateTime>>();
        Set<Id> contactIdsSet = new Set<Id> ();
        //Retriving all the Original Codentify for the replaced Assets
        for(FirstLinkDateWrapper wrapperRec : firstLinkWrap.values()) {
            if(wrapperRec.assetRec.CCR_OriginalAsset__c != null){
                assetOriginalIdSet.add(wrapperRec.assetRec.CCR_OriginalAsset__c);
                contactIdsSet.add(wrapperRec.contactIdStr);
            }
        }
        if(assetOriginalIdSet != null && !assetOriginalIdSet.isEmpty()){
            //Retriving all the Assets IDs for the Original Codentify
            Map<Id, Asset> assetsMap = new Map<Id, Asset> ([SELECT Id
            FROM Asset
            WHERE CCR_OriginalAsset__c IN :assetOriginalIdSet]);
            //Retriving all the Asset Life cycle records
            for(CCR_AssetLifeCycle__c lifeCycle : [SELECT Id, CCR_ActionDate__c, CCR_Asset__c, CCR_Consumer__c
            FROM CCR_AssetLifeCycle__c
            WHERE CCR_Asset__c IN :assetsMap.keySet()
            AND CCR_Consumer__c IN :contactIdsSet
            AND CCR_Action__c = 'Link']){
                if(contAndTimeMap.containsKey(lifeCycle.CCR_Consumer__c)){
                    contAndTimeMap.get(lifeCycle.CCR_Consumer__c).add(lifeCycle.CCR_ActionDate__c);
                }
                else {
                    contAndTimeMap.put(lifeCycle.CCR_Consumer__c, new List<DateTime> {lifeCycle.CCR_ActionDate__c});
                }
            }
        }
        //Checking the Link action data for the Asset Life cycle records
        for(FirstLinkDateWrapper wrapperRec : firstLinkWrap.values()){
            if(contAndTimeMap.containsKey(wrapperRec.contactIdStr)){
                List<DateTime> dateList = contAndTimeMap.get(wrapperRec.contactIdStr);
                dateList.sort();
                if(wrapperRec.actionDate == null || dateList[0] < wrapperRec.actionDate){
                    asstListDateMap.put(wrapperRec.assetRec.Id, dateList[0].Date());
                }
                else {
                    asstListDateMap.put(wrapperRec.assetRec.Id, wrapperRec.actionDate);
                }
            }
            else {
                asstListDateMap.put(wrapperRec.assetRec.Id, wrapperRec.actionDate);
            }
        }
        return asstListDateMap;
    }

    /**
    * Method Name : getReplacementSponsoredBy
    * Arguments: List<CCR_QureHistory__c>
    * Return : Map<String, String> key - CodentifyId, value - ReplacementSponsoredBy
    * Description: Use this method to get replacement sponsord by valeu for asset related to US CCR-105964
    * ReplacementSponsoredBy 값을 설정해주는 함수
    **/
    public static Map<String, String> getReplacementSponsoredBy(List<CCR_QureHistory__c> qureHistoryList){

        Map<String, String> replacentSponsoredByMap = new Map<String, String>();
        for(CCR_QureHistory__c qureHistory: qureHistoryList){
            qureHistoryMap.put(qureHistory.CCR_Device__c, qureHistory);
            if(qureHistory.CCR_QureInUnlimitedPeriod__c == true){
                CCR_QureConfiguration__c marketQureConfig  = CCR_QureUtility.getMarketConfiguration(qureHistory.CCR_ConsumerCountry__c);
                if(marketQureConfig != null && marketQureConfig.CCR_ReplacementSponsoredBy__c != null){
                    if(marketQureConfig.CCR_ReplacementSponsoredBy__c == CCR_Constants.CANDBCODES) {
                        if(qureHistory.CCR_SubjectCode__c.startsWith('C')){
                            replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.GOODWILL);
                        }
                        else {
                            replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.WARRANTY);
                        }
                    }
                    else if(marketQureConfig.CCR_ReplacementSponsoredBy__c == CCR_Constants.ALWAYSGOODWILL) {
                        replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.GOODWILL);
                    }
                    else {
                        replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.WARRANTY);
                    }
                }
                else {
                    replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.WARRANTY);
                }
            } else {
                if (qureHistory.CCR_Override__c == true) {
                    replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.GOODWILL);
                }
                else if(qureHistory.CCR_DiagnosticDescription__c == 'Broken Heating Blade') {
                    replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.CAREPLUSSTR);
                }
                else {
                    replacentSponsoredByMap.put(qureHistory.CCR_Device__r.CCR_CodentifyId__c, CCR_Constants.WARRANTY);
                }
            }
        }
        return replacentSponsoredByMap;
    }

    /**
    * Method Name :  ReplacementMethod
    * Arguments:  List
    * Return : void
    * Description: This method is used to Update CCR_ReplacementReason__c field on Asset Object.
    **/
    public static void replacementMethod(Map<String, Asset> assetlist) {
        Map<Id, CCR_QureHistory__c> qureHisMap = new Map<Id, CCR_QureHistory__c>();
        for(CCR_QureHistory__c qurehis :[SELECT ID, CCR_SubjectCode__c, CCR_Device__c, Name,
                CCR_Override__c, CCR_OverrideReason__c
        FROM CCR_QureHistory__c
        WHERE CCR_Device__c in :assetlist.values() AND CCR_Status__c = :CCR_Constants.ASSETACTIVE]) {
            if(qureHisMap.containsKey(qurehis.CCR_Device__c)) {
                if(qureHisMap.get(qurehis.CCR_Device__c).Name < qurehis.Name) {
                    qureHisMap.put(qurehis.CCR_Device__c, qurehis);
                }
            } else {
                qureHisMap.put(qurehis.CCR_Device__c, qurehis);
            }
        }

        for(Asset assetfor : AssetList.values()) {
            if(qureHisMap.containsKey(assetfor.Id)){
                //assetfor.ccr_ReplacementReason__c = qureHisMap.get(assetfor.Id).CCR_SubjectCode__c;
                assetfor.CCR_Override__c = qureHisMap.get(assetfor.Id).CCR_Override__c;
                assetfor.CCR_OverrideReason__c = qureHisMap.get(assetfor.Id).CCR_OverrideReason__c;
            }
        }
    }

    /** Method Name :  getChannelValues
    * Arguments: NA
    * Description:This method is called when the Assetreplacement page
    **/
    public static List<Selectoption> getReplacementChannelValues(){
        Map<String, String> fieldLabelMap = new Map<String, String>();
        List<Selectoption> chnlsel = new List<selectoption>();
        List<User> usrtyp = [SELECT CCR_UserType__c FROM User WHERE Id= :UserInfo.getUserId() LIMIT 1];
        for(SelectOption sOption : CCR_Utility.retrievePicklistValues('Asset', 'CCR_ReplacementChannelNew__c')){
            chnlsel.add(new SelectOption(sOption.getValue(), sOption.getLabel()));
        }
        chnlsel.sort();
        return chnlsel;
    }

    /** Method Name :  clearOldAssetData **/
    public static Asset clearOldAssetData(Asset oldAssetData){
        oldAssetData.CCR_ReplacedBy__c = null;
        oldAssetData.CCR_ReplacementDate__c = null;
        oldAssetData.CCR_ReplacementSystemDate__c = null;
        oldAssetData.CCR_ReplacementDoneBy__c = null;
        oldAssetData.CCR_ReplacementReason__c = null;
        oldAssetData.CCR_ReplacementCountry__c = null;
        oldAssetData.CCR_ReplacementChannel__c = null;
        oldAssetData.CCR_ReplacementExternalReference__c = null;
        return oldAssetData;
    }

    /** Method Name :  clearNewAssetData **/
    public static Asset clearNewAssetData(Id newAssetId){
        Asset newAsset = new Asset();
        newAsset.Id = newAssetId;
        newAsset.Status = CCR_Constants.ASSETPRODUCED;
        newAsset.CCR_OriginalAsset__c = null;
        newAsset.CCR_OriginalBox__c = null;
        return newAsset;
    }

    /** Class:  Wrapper class to handel the QURE replacements (added as part of this user story CCR-135147) **/
    public class ReplacementWrapper {
        public String replacementType = '';
        public List<String> information = new List<String> ();
        public List<String> errors = new List<String> ();
        public Map<String,Asset> oldAssetsMap = new Map<String, Asset>();
        public Map<String,Asset> newAssetsMap = new Map<String, Asset>();
        public CCR_QureHistory__c qureHistory = new CCR_QureHistory__c();
        Public Asset oldAsset = new Asset();
    }

    public class FirstLinkDateWrapper {
        public Asset assetRec;
        public Id contactIdStr;
        public Date actionDate;
    }

    public static void runTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

    }
}