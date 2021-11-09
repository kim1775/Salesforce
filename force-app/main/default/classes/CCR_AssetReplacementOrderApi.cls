/**
 * Created by I2MAX on 2021-03-17.
 * Api class for Asset replacement order
 */

public without sharing class CCR_AssetReplacementOrderApi {
    public static final String CONTENTTYPE = 'Content-Type';
    public static final String ACCEPT = 'Accept';
    public static final String JSONFORMATTEXT = 'application/json';
    public static final String TOKENKEYTEXT = 'tokenkey';
    public static final Integer SUCCESSSTATUSCODE = 200;
    public static final String KEYTEXT = 'AES128';
    public static final String CLASSUTILITY = 'CCR_AssetReplacementOrderApi';
    public static final String REPLACEMENTORDERMETHOD = 'replaceAsset';
    public static final String ERRORTEXT = 'Error';
    public static final String INTEGRATIONTEXT = 'Integration';
    public static final String MAGENTOINTEGRATION = 'Order Replacement Integration';
    public static final String BLANKTEXT = '';
    public static final String ORDERIDTEXT = 'orderid';
    public static final String ASSETCODENTIFYIDTEXT = 'Asset Codentify Id : ';
    public static final String CASEIDTEXT = ' Case Id : ';
    public static final String PRODUCTIDTEXTMESSAGE = ' Product Id : ';
    public static final String AUTHORIZATIONTEXT = 'Authorization';
    public static final String AUTHENTICATIONTEXT = 'Authentication';
    public static final String BEARERTEXT = 'Bearer ';
    public static final String GRANTYPETEXT = 'grant_type=client_credentials';
    public static final String GETMETHODTEXT = 'GET';
    public static final String POSTMETHODTEXT = 'POST';
    public static final Integer UNKNOWNCODEERROR = 0;
    public static final Integer UPDATESTATUSCODESUCCESS = 200;
    public static final Integer UNAUTHENTICATIONERROR = 401;
    public static final String ACCESSTOKENTEXT = 'access_token';
    //public static final String ENDPOINTAUTH = 'callout:CCR_DWGetProductIdAuthentication';
    public static final String DWAUTHORIZATIONHEADER = 'Basic {!$Credential.AuthorizationHeaderValue}';
    public static final String TOKENEXPIREIN = 'expires_in';
    public static final String PRODUCTIDRETRIVALISSUEMESSAGE = 'There was issue to retrieve Product Id from Demandware.';
    public static final String FEATUREACTIVATIONISSUEMESSAGE = 'This feature not activated for your user.Please contact your administrator.';
    public static final String MASTERPRODUCTIDTEXT = 'c_masterProductID';
    public static final String COLORTEXT = 'c_smdlColor';
    public static final String CATALOGTEXT = 'catalog_id';
    public static final String SELECTATTRIBUTETEXT = 'selectAttribute';
    public static final String SELECTTEXT = 'select';
    public static final String DEFAULTSELECT = '(count, hits.(id))';
    public static final String DEFAULTOPERATOR = 'is';
    public static final String PRODUCTIDTEXT = 'id';
    public static final String RESPONSEBODYTEXT = '.Response from API : ';
    public static final String REQUESTBODYTEXT = 'Request to API : ';
    public static final String USERCOUNTRYTEXT = 'Country : ';
    public static final String ENDPOINTTEXT = '.End point url : ';
    public static final String DEMANDWARETEXT = 'Demandware';
    public static final String DEVTEXT = 'dev';
    public static final String METRICTEXT = 'metric';
    public static final String SFDCTEXT = 'sfdc';
    public static final String CONSUMERCARETEXT = 'consumercare';
    public static final String REPLACEMENTORDER = 'Replacement-Order';
    public static final String CLASSTEXT = 'Class';
    public static final String CLASSNAMETEXT = 'CCR_AssetReplacementOrderApi';
    public static final String HIPHEN = '_';
    public static final String DWINTEGRATIONMODULE = 'demandware_integration';
    public static final String SEMICOLONTEXT = ';' ;
    public static final Integer ZEROTEXT = 0;
    public static final String DEFAULTALLSELECT = '(count, hits.(id, c_smdlColor, c_color, c_description, c_deviceVersion,  c_masterProductID, in_stock, image.(abs_url), name))';
    public static final String LIMITEDEDITION = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_LimitedEdition').getRecordTypeId();
    public static String accessToken;
    public static String errorCodes = BLANKTEXT;
    public static String errorLogReference = BLANKTEXT;
    public static Integer noOfErrors = ZEROTEXT;
    public static Datetime authenticateStartTime;
    public static Datetime authenticateEndTime;
    public static Long authenticateDuration;
    public static Datetime getProdIDStartTime;
    public static Datetime getProdIDEndTime;
    public static Long getProdIdDuration;
    public static Datetime replOrderCreatStartTime;
    public static Datetime replOrderCreatEndTime;
    public static Long replOrderCreatDuration;
    public static CCR_TelemtryUtility.Data_Details dataDetails = new CCR_TelemtryUtility.Data_Details();
    public static CCR_TelemtryUtility.QureProductData qureProdData = new CCR_TelemtryUtility.QureProductData();
    public static List<CCR_TelemtryUtility.QureProductData> qureProdDataArray = new List<CCR_TelemtryUtility.QureProductData>();
    public static String DWACCESSTOKENVALUE = 'local.CCRTokens.CCRDWAccessToken';//Platform cache to store access token from Demandware
    public static List<Asset> assetList;
    public static User currentuser;
    public static Boolean singleProdReq = false;


    /**
    * Method Name :  checkDeviceForReplacement
    * Arguments: CCR_QureMsg qureObj
    * Return : CCR_QureMsg
    * Description: Receive inputs from Qure process and call Demandware API for replacement order, added by Raghu for the user story CCR-156214
    **/
    public static CCR_QureMsg deviceReplacementOrder(CCR_QureMsg qureObj) {

        getCallOutAndAssetDetails(qureObj);
        if (qureObj.IsLimitedEdition) {
            singleProdReq = true;
        }

        if (Test.isRunningTest()){
            Asset ass = new Asset();
            assetList.add(ass);
        }
        Id ctId = assetList[0].ContactId;
        Contact extId = [select id, KDCE_ExternalId__c, Email, KDCE_ECLoginEmail__c from Contact where id = :ctId limit 1];
        qureObj.contactExternalId = extId.KDCE_ExternalId__c;
        qureObj.contactEmailId = extId.KDCE_ECLoginEmail__c;
//        qureObj.ProductCode = assetList[0].ProductCode;
        qureObj.ProductName = assetList[0].ProductDescription;
        qureObj.productId = assetList[0].KDCE_fm_ProductEAN__c;
        qureObj.Product2Name = assetList[0].Product2.Name;

        if (!Test.isRunningTest()) {
            ModelProductMapping__c mpm = [select id, fm_ProductCode__c from ModelProductMapping__c where ModelNumber__c = :assetList[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c and Color__c = :assetList[0].CCR_DeviceProductCode__r.CCR_Color__c];
            qureObj.ProductCode = mpm.fm_ProductCode__c;
        } else {
            qureObj.ProductCode = 'testProductCode';
        }

        IF_DCE_MG_0107.OutputDIH outPut = new IF_DCE_MG_0107.OutputDIH();
        if (!Test.isRunningTest()) {
            output = IF_KDCE_CalloutController.callMagentoOrderAPI(qureObj);
        }

        List<String> tdList = output.response.payload.t_data;
        Map<String, String> tdMap = new Map<String, String>();
        if(!tdList.isEmpty()) {
            for (String t : tdList[0].replaceAll('\\\\', '').replaceAll('"', '').replaceAll('\\{', '').replaceAll('\\}', '').split(',')) {
                List<String> temp = t.split(':');
                tdMap.put(temp[0], temp[1]);
                system.debug(t);
            }
        }
        System.debug(tdMap);

        Boolean isSuccess = false;
        if(output.response.header.ifResult == 'S') isSuccess = true;

        if(isSuccess){
            if(tdMap.get('error') == 'false'){
                qureObj.isCalloutSuccess = true;
                if(tdMap.get('order_id') != null)   qureObj.orderId = tdMap.get('order_id');
                else                                qureObj.orderId = 'OnlineQureOrder';
            } else {
                qureObj.isCalloutSuccess = false;
                qureObj.calloutErrorStr = tdMap.get('message');
            }
        } else {
            qureObj.isCalloutSuccess = false;
            qureObj.calloutErrorStr = tdMap.get('message');

            CCR_ErrorLogUtility.createErrorLog(REQUESTBODYTEXT + 'reqBody' + RESPONSEBODYTEXT + tdMap.get('message') + ENDPOINTTEXT + 'listISOBARDetails[0].CCR_GetVoucherEndpoint__c' + ASSETCODENTIFYIDTEXT
                    + qureObj.Codentify + CASEIDTEXT + qureObj.CaseId + qureObj.ConsumerPhone,
                    CLASSUTILITY , REPLACEMENTORDERMETHOD , ERRORTEXT , INTEGRATIONTEXT,
                    MAGENTOINTEGRATION);
            noOfErrors++;
            if(errorCodes == BLANKTEXT)
                errorCodes = tdMap.get('message');
            else {
                errorCodes = errorCodes+ BLANKTEXT +tdMap.get('message');
            }
        }
        return qureObj;
    }

    /**
    * Method Name :  replaceAsset
    * Arguments: CCR_QureMsg qureObj
    * Return : None
    * Description: Receive inputs from Qure process and call Demandware API for replacement order
    **/
    public static CCR_QureMsg replaceAsset(CCR_QureMsg qureObj) {
        System.debug('replaceAsset called$$$');
        HttpRequest postRequest = new HttpRequest();
        List<Case> caseList = new List<Case>();
        List<Contact> contactList = new List<Contact>();
        String reqBody = BLANKTEXT;
        String orderId = BLANKTEXT;
        String saltKey = BLANKTEXT;
        String privateKey = BLANKTEXT;
        String dataEncrypted = BLANKTEXT;
        String endpoint = BLANKTEXT;
        String authorizationHeader = BLANKTEXT;
        IF_DCE_MG_0107.OutputDIH outPut = new IF_DCE_MG_0107.OutputDIH();

        Id ctId = assetList[0].ContactId;
        Contact extId = [select id, KDCE_ExternalId__c, Email from Contact where id = :ctId limit 1];
        qureObj.contactExternalId = extId.KDCE_ExternalId__c;
        qureObj.contactEmailId = extId.Email;
        //START
        try {
            if (!assetList.isEmpty()) {
                caseList = [SELECT Id,CaseNumber FROM Case WHERE Id = :qureObj.CaseId];
                if(!Test.isRunningTest()) {
                    output = IF_KDCE_CalloutController.callMagentoOrderAPI(qureObj);
                }
                qureObj.orderId = orderId;
                qureObj.isCalloutSuccess = true;
                return qureObj;
            } else {
                CCR_ErrorLogUtility.createErrorLog(REQUESTBODYTEXT + reqBody + RESPONSEBODYTEXT + output + ENDPOINTTEXT + endpoint + ASSETCODENTIFYIDTEXT + qureObj.Codentify + CASEIDTEXT + qureObj.CaseId + PRODUCTIDTEXTMESSAGE + qureObj.productId,
                        CLASSUTILITY, REPLACEMENTORDERMETHOD, ERRORTEXT, INTEGRATIONTEXT,
                        MAGENTOINTEGRATION);
                qureObj.isCalloutSuccess = false;
                qureObj.calloutErrorStr = 'output';
                noOfErrors++;
                if (errorCodes == BLANKTEXT) {
                    errorCodes = String.ValueOf('res.getStatusCode()');
                } else {
                    errorCodes = errorCodes + SEMICOLONTEXT + String.ValueOf('res.getStatusCode()');
                }
                List<DTE_ErrorLog__c> listErrorLog = [
                        SELECT id
                        FROM DTE_ErrorLog__c
                        WHERE CCR_ClassName__c = :CLASSUTILITY
                        ORDER BY createddate DESC
                        LIMIT 1
                ];

                if (errorLogReference == BLANKTEXT)
                    errorLogReference = String.valueof(listErrorLog[0].id); else
                        errorLogReference = errorLogReference + SEMICOLONTEXT + String.valueof(listErrorLog[0].id);
                return qureObj;
            }
        } catch (System.CalloutException exp) {
            //Create exception log record
            CCR_ErrorLogUtility.createExceptionLog(exp, ERRORTEXT, INTEGRATIONTEXT, MAGENTOINTEGRATION);
            //Update qureObj with error message and return to the calling method
            qureObj.isCalloutSuccess = false;
            qureObj.calloutErrorStr = exp.getMessage();
            return qureObj;
        }
        //Update qureObj with error message and return to the calling method
//        qureObj.isCalloutSuccess = false;
//        return qureObj;
    }

    /**
    * Method Name :  pushTelemetryEvent
    * Arguments: datetime, datetime, string
    * Return : Void
    * Description: Used to push event to telemetry platform event
    **/
    Public static void pushTelemetryEvent(DateTime startTime, DateTime transEndTime, String transIntiator) {
        try {
            CCR_TelemtryUtility.JSON_Payload jsonPayload = new CCR_TelemtryUtility.JSON_Payload();
            CCR_TelemtryUtility.SFDC_Details sfdcDetails = new CCR_TelemtryUtility.SFDC_Details();
            CCR_TelemtryUtility.TriggerModule_Details triggerModuleDetails = new CCR_TelemtryUtility.TriggerModule_Details();
            CCR_TelemtryUtility.Source_Details sourceDetails = new CCR_TelemtryUtility.Source_Details();
            CCR_TelemtryUtility.App_Detail appDetails = new CCR_TelemtryUtility.App_Detail();
            CCR_TelemtryUtility.Metric_Set metricSet = new CCR_TelemtryUtility.Metric_Set();
            CCR_TelemtryUtility.Custom_Details customDetails = new CCR_TelemtryUtility.Custom_Details();
            String environmnetName = BLANKTEXT;
            String host = String.ValueOf(URL.getSalesforceBaseUrl().getHost());
            List<CCR_InstanceMapping__mdt> instanceMappingList = [
                    SELECT id,CCR_InstanceType__c
                    from CCR_InstanceMapping__mdt
                    where CCR_OrganisationId__c = :UserInfo.getOrganizationId().substring(0, 15)
                    LIMIT 1
            ];
            if (!instanceMappingList.isEmpty()) {
                environmnetName = instanceMappingList[0].CCR_InstanceType__c;
            } else {
                environmnetName = DEVTEXT;
            }
            jsonPayload.index = METRICTEXT + HIPHEN + SFDCTEXT + HIPHEN + DWINTEGRATIONMODULE + HIPHEN + environmnetName + HIPHEN + system.now();
            jsonPayload.type = METRICTEXT;
            sourceDetails.environment = environmnetName;
            sourceDetails.timestamp = string.valueof(system.now());
            appDetails.id = SFDCTEXT + HIPHEN + CONSUMERCARETEXT + HIPHEN + DWINTEGRATIONMODULE;
            appDetails.alias = SFDCTEXT + HIPHEN + DWINTEGRATIONMODULE;
            sourceDetails.app = appDetails;
            metricSet.host = host;
            metricSet.module = DWINTEGRATIONMODULE;
            sourceDetails.metricset = metricSet;
            sourceDetails.custom = customdetails;
            triggerModuleDetails.transactiontrigger = REPLACEMENTORDER;
            triggerModuleDetails.type = CLASSTEXT;
            triggerModuleDetails.runninguser = userinfo.getuserid();
            triggerModuleDetails.transactionstarttime = string.valueof(startTime);
            triggerModuleDetails.transactionendtime = string.valueof(transEndTime);
            triggerModuleDetails.transactionduration = String.ValueOf(transEndTime.getTime() - startTime.getTime());
            triggerModuleDetails.errorcodes = errorCodes;
            triggerModuleDetails.numberoferrors = noOfErrors;
            triggerModuleDetails.errorlogref = errorLogReference;
            triggerModuleDetails.transactionID = DEMANDWARETEXT + HIPHEN + transIntiator + HIPHEN + string.valueof(system.now());
            triggerModuleDetails.classname = CLASSNAMETEXT;
            dataDetails.authenticate_starttime = string.valueof(authenticateStartTime);
            dataDetails.authenticate_endtime = string.valueof(authenticateEndTime);
            if (authenticateStartTime != null && authenticateEndTime != null)
                dataDetails.authenticate_duration = string.valueof(Integer.valueof(authenticateEndTime.getTime() - authenticateStartTime.getTime()));
            dataDetails.getproductid_starttime = string.valueof(getProdIDStartTime);
            dataDetails.getproductid_endtime = string.valueof(getProdIDEndTime);
            if (getProdIDStartTime != null && getProdIDEndTime != null)
                dataDetails.getproductid_duration = string.valueof(Integer.valueof(getProdIDEndTime.getTime() - getProdIDStartTime.getTime()));
            dataDetails.replacementordercreation_starttime = string.valueof(replOrderCreatStartTime);
            dataDetails.replacementordercreation_endtime = string.valueof(replOrderCreatEndTime);
            dataDetails.replacementordercreation_duration = string.valueof(replOrderCreatDuration);
            dataDetails.qureproductdata = qureProdDataArray;
            triggerModuleDetails.data = dataDetails;
            sfdcDetails.demandware_integration = triggerModuleDetails;
            jsonPayload.source = sourceDetails;
            sourceDetails.sfdc = sfdcDetails;
            CCR_TelemtryUtility.publishEvent(jsonPayload);
            system.debug(jsonPayload);
        } catch (Exception ex) {
            CCR_ErrorLogUtility.createExceptionLog(ex, 'Error', 'Integration', 'Telemetry_Engine');
        }
    }

    /**
* Method Name :  getCallOutAndAssetDetails
* Arguments: String
* Return : List<CCR_DemandwareReplaceOrderDetails__mdt>
* Description: Used to get the call out details form the CCR_DemandwareReplaceOrderDetails__mdt metadata
**/
    Public static void getCallOutAndAssetDetails(CCR_QureMsg qureObj) {
        assetList = [
                SELECT Id,CCR_CodentifyId__c, CCR_SpiceId__c, CCR_DeviceProductCode__r.CCR_ModelNumber__c,
                        CCR_DeviceProductCode__r.CCR_Group__c, CCR_DeviceProductCode__r.CCR_Color__c,
                        CCR_DeviceProductCode__r.CCR_Version__c, ContactId, ProductCode, ProductDescription, KDCE_fm_ProductEAN__c, Product2.Name
                FROM ASSET
                WHERE CCR_CodentifyId__c = :qureObj.Codentify
        ];
        //Get current user record
        currentuser = [
                SELECT Id, profile.name
                FROM user
                WHERE id = :userInfo.getUserId()
                limit 1
        ];
    }

    //Wrapper class structure for Res_Name
    public class Res_Name {
        @AuraEnabled
        public String default_Desciption;
        @AuraEnabled
        public String translated_Desciption;
    }

    //Wrapper class structure for Res_Image
    public class Res_Image {
        @AuraEnabled
        public String abs_url;
    }

    //Wrapper class structure for Res_Hits
    public class Res_Hits {
        @AuraEnabled
        public Res_Image image;
        @AuraEnabled
        public Res_Name name;
        @AuraEnabled
        public String c_color;
        @AuraEnabled
        public Boolean in_stock;
        @AuraEnabled
        public String c_deviceVersion;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String c_masterProductID;
        @AuraEnabled
        public String c_smdlColor;
    }
}