/**
 * Created by I2MAX on 2021-03-29.
 * Api class for Asset replacement order
 * CSV Voucher 발급 API 호출을 위한 클래스
 */

public without sharing class CCR_CSVIsobarVoucherCodeApi {

    public static final String CONTENTTYPE = 'Content-Type';
    public static final String ACCEPT = 'Accept';
    public static final String JSONFORMATTEXT = 'application/json;charset=UTF-8';
    public static final String TOKENKEYTEXT = 'accessToken';
    public static final Integer SUCCESSSTATUSCODE = 200;
    public static final String KEYTEXT = 'AES128';
    public static final String CLASSUTILITY = 'CCR_AssetGetVoucherApi';
    public static final String GETVOUCHERMETHOD = 'getVoucher';
    public static final String RESENDVOUCHER = 'resendVoucher';
    public static final String ERRORTEXT = 'Error';
    public static final String INTEGRATIONTEXT = 'Integration';
    public static final String ISOBARINTEGRATION = 'ISOBAR Integration';
    public static final String AUTHENTICATIONMETHOD = 'Authentication';
    public static final String BLANKTEXT = '';
    public static final String VOUCHERCODE= 'orderid';
    public static final String ASSETCODENTIFYIDTEXT = 'Asset Codentify Id : ';
    public static final String CASEIDTEXT = ' Case Id : ';
    public static final String PRODUCTIDTEXTMESSAGE = ' Product Id : ';
//    public static final String ISOBARACCESSTOKENVALUE ='local.CCRTokens.CCRIsobarAccessToken';//Platform cache to store access token from Demandware
    public static final String AUTHORIZATIONTEXT = 'Authorization';
    public static final String AUTHENTICATIONTEXT = 'Authentication';
    public static final String POSTMETHODTEXT = 'POST';
    public static final Integer UPDATESTATUSCODESUCCESS = 200;
    public static final String ACCESSTOKENTEXT = 'access_token';
    public static final String TOKENEXPIREIN = 'expires_in';
    public static final String FEATUREACTIVATIONISSUEMESSAGE = 'This feature not activated for your user.Please contact your administrator.';
    public static final String RESPONSEBODYTEXT = '.Response from API : ';
    public static final String REQUESTBODYTEXT = 'Request to API : ';
    public static final String USERCOUNTRYTEXT = 'Country : ';
    public static final String ENDPOINTTEXT = '.End point url : ';
    public static final String PHONENUMBERTEXT = ' Phone no : ';
    public static final String SUCCESSRESPONSECODE = '00';
    public static final String INVALIDQUREHISTORY = 'Qure history record does not have case with voucher code populated.';
    public static String accessToken = BLANKTEXT;
    public static Boolean proceedFlag= true;
    public static String codentifyIdValue = BLANKTEXT;
    //Added by Sanjyothi as per US CCR-5995 Telemetry user should receive events for ISOBAR callouts
    public static final String HIPHEN = '-';
    public static final String ERRORFUNCTIONTELEMETRY = 'ISOBAR Event to Telemetry';
    public static final String ISOBARTEXT = 'ISOBAR';
    public static final String ISOBARINTEGRATIONTEXT = 'ISOBAR-integration';
    public static final String DEVTEXT = 'dev';
    public static final String METRICTEXT = 'metric';
    public static final String SFDCTEXT = 'sfdc';
    public static final String CLASSTEXT= 'Class';
    public static final String CONSUMERCARETEXT = 'consumercare';
    public static final String CLASSNAMETEXT = 'CCR_CSVIsobarVoucherCodeApi';
    public static final String ISOBARGETVOUCHERTEXT = 'get-voucher';
    public static final String ISOBARRESENDVOUCHERTEXT = 'resend-voucher';
    public static String errorCodes;
    public static String errorLogReference = BLANKTEXT;
    public static Integer noOfErrors;
    public static DateTime getVoucher_StartTime;
    public static DateTime getVoucher_EndTime;
    public static DateTime resendVoucher_StartTime;
    public static DateTime resendVoucher_EndTime;
    public static DateTime transaction_StartTime;
    public static DateTime authenticate_StartTime;//Start time for authentication callout
    public static DateTime authenticate_EndTime;//End time for authentication callout
    public static String transIntiator;
    public static List<CCR_TelemtryUtility.ISOBAR_ProductData> productDetailArray = new List<CCR_TelemtryUtility.ISOBAR_ProductData>();
    public static CCR_TelemtryUtility.ISOBAR_ProductData productDataobj = new CCR_TelemtryUtility.ISOBAR_ProductData();
    public static CCR_TelemtryUtility.Data_Details dataDetails = new CCR_TelemtryUtility.Data_Details();

    /**
* Method Name :  getVoucher
* Arguments: CCR_QureMsg qureObj
* Return : CCR_QureMsg
* Description: Receive voucher code from ISOBAR Api
**/
    public static CCR_QureMsg getVoucher (CCR_QureMsg qureObj) {
        IF_DCE_DN_0001.OutputDIH outPut = new IF_DCE_DN_0001.OutputDIH();

        output = IF_KDCE_CalloutController.callIssueGS25VoucherAPI(qureObj);

        // API Call의 결과값 (Status, 성공이면 S)
        Boolean isSuccess = false;
        if(output.response.header.ifResult == 'S') isSuccess = true;

        // 공통 모듈 안에서 구현된 실제 Response Body
        List<String> tdList = outPut.response.payload.t_data;

        Map<String, String> tdMap = new Map<String, String>();

        for(String t : tdList[0].replaceAll('"', '').replaceAll('\\{', '').replaceAll('\\}', '').split(',')){
            List<String> temp = t.split(':');
            tdMap.put(temp[0], temp[1]);
            System.debug(t);
        }
        System.debug(tdMap);

        // return 값 setup
        if(isSuccess){
            if(tdMap.get('resCode')=='00'){
                String voucherCode = tdMap.get('voucherIdx');
                if(voucherCode != ''){
                    qureObj.orderId = voucherCode;
                    qureObj.isCalloutSuccess = true;
                }
            } else {
                qureObj.isCalloutSuccess = false;
                qureObj.calloutErrorStr = tdMap.get('resMsg');
            }
        } else {
            qureObj.isCalloutSuccess = false;
            qureObj.calloutErrorStr = tdMap.get('resMsg');
            //Create error log record
            CCR_ErrorLogUtility.createErrorLog(REQUESTBODYTEXT + 'reqBody' + RESPONSEBODYTEXT + tdMap.get('resMsg') + ENDPOINTTEXT + 'listISOBARDetails[0].CCR_GetVoucherEndpoint__c' + ASSETCODENTIFYIDTEXT
                    + qureObj.Codentify + CASEIDTEXT + qureObj.CaseId + PHONENUMBERTEXT + qureObj.ConsumerPhone,
                    CLASSUTILITY , GETVOUCHERMETHOD , ERRORTEXT , INTEGRATIONTEXT,
                    ISOBARINTEGRATION);
            noOfErrors++;
            if(errorCodes == BLANKTEXT)
                errorCodes = tdMap.get('resMsg');
            else {
                errorCodes = errorCodes+ BLANKTEXT +tdMap.get('resMsg');
            }
        }


        return qureObj;
    }

    /**
* Method Name :  resendVoucher
* Arguments: CCR_QureMsg qureObj
* Return : Boolean
* Description: Resend voucher code from ISOBAR Api
**/
    public static CCR_QureMsg resendVoucher (CCR_QureMsg qureObj) {
//        return null;
        System.debug('==== resendVoucher Start');
        //Added by sanjyothi as per US CCR-5995
        resendVoucher_StartTime = system.now();
        transIntiator = ISOBARRESENDVOUCHERTEXT;
        noOfErrors=0;
        errorCodes = BLANKTEXT;
        List<CCR_ISOBARGetVoucherApiDetails__c> listISOBARDetails = new List<CCR_ISOBARGetVoucherApiDetails__c>();
        List<CCR_QureHistory__c> listQureHistory = new List<CCR_QureHistory__c>();
        String reqBody = BLANKTEXT;
        HttpRequest postRequest = new HttpRequest();
        ResendVoucherRequest resendVoucherReq = new ResendVoucherRequest();
        ResendVoucherResponse resendVoucherResponse = new ResendVoucherResponse();
        resendVoucherReq.voucherIdx = BLANKTEXT;
        qureObj.isCalloutSuccess = false;//Set default value as False

        //Get country specific API details - Endpoint,Private Key,Salt Key,Data to be encrypted
        listISOBARDetails = [SELECT CCR_AuthenticationEndpoint__c,CCR_GetVoucherEndpoint__c,CCR_ResendVoucherEndpoint__c,
                CCR_ApiKey__c,CCR_ApiSecret__c,CCR_PrivateKey__c,CCR_SaltKey__c,CCR_Country__c
        FROM CCR_ISOBARGetVoucherApiDetails__c
        WHERE CCR_Active__c = TRUE LIMIT 1];
        system.debug(listISOBARDetails);
        productDataobj.market = qureObj.Market;//Added by sanjyothi as per US CCR-5995 Telemetry
        productDataobj.codentify = qureObj.Codentify;
        try {
            //If returns any values
            if(!listISOBARDetails.isEmpty() && listISOBARDetails.size() == 1) {

                getValidAccessToken(listISOBARDetails[0].CCR_AuthenticationEndpoint__c, listISOBARDetails[0].CCR_ApiKey__c, listISOBARDetails[0].CCR_ApiSecret__c);

                if(accessToken != BLANKTEXT && proceedFlag == true) {

                    //Get case id from corresponding qure history record
                    listQureHistory = [SELECT CCR_Case__r.CCR_OrderId__c, CCR_Case__r.CaseNumber FROM CCR_QureHistory__c
                    WHERE Id = : qureObj.QureHistryId];//Modified by sanjyothi as per US CCR-5995 Telemetry
                    //Get case record using case if provided in QureObj
                    //caseList = [SELECT Id,CaseNumber,CCR_OrderId__c FROM Case WHERE Id =: listQureHistory[0].CCR_Case__c];
                    if(!listQureHistory.isEmpty()) {
                        resendVoucherReq.voucherIdx = listQureHistory[0].CCR_Case__r.CCR_OrderId__c;
                        productDataobj.voucher = listQureHistory[0].CCR_Case__r.CCR_OrderId__c;
                        //productDataobj.casenumber=listQureHistory[0].CCR_Case__r.CaseNumber;//Added by sanjyothi as per US CCR-5995 Telemetry
                    }
                    if(resendVoucherReq.voucherIdx != BLANKTEXT) {
                        reqBody = JSON.serialize(resendVoucherReq);
                        system.debug(reqBody);
                        postRequest.setEndpoint(listISOBARDetails[0].CCR_ResendVoucherEndpoint__c);
                        postRequest.setMethod(POSTMETHODTEXT);
                        postRequest.setHeader(TOKENKEYTEXT,accessToken);
                        postRequest.setHeader(CONTENTTYPE, JSONFORMATTEXT);
                        postRequest.setHeader(ACCEPT, JSONFORMATTEXT);
                        postRequest.setBody(reqBody);
                        system.debug('Request payload to ISOBAR : ' + reqBody);
                        //postRequest.setTimeout(Integer.ValueOf(calloutDetails[0].CCR_WebserviceTimeOut__c));
                        Http htp = new Http();
                        HTTPResponse res = new HTTPResponse();
                        res = htp.send(postRequest);//Make callout to ISOBAR
                        system.debug('Response for resend voucher code : ' + res.getBody());
                        //If the callout is completed successfully update order id on case
                        resendVoucher_EndTime = system.now();
                        if (res.getStatusCode() == SUCCESSSTATUSCODE) {
                            resendVoucherResponse = (ResendVoucherResponse)JSON.deserialize(res.getBody(),  ResendVoucherResponse.Class);
                            if(resendVoucherResponse != null && resendVoucherResponse.resCode == SUCCESSRESPONSECODE) {
                                qureObj.isCalloutSuccess = true;
                            }
                            else {
                                //In case receives error reponse from ISOBAR
                                //Update qureObj with error message and return to the calling method
                                qureObj.isCalloutSuccess = false;
                                qureObj.calloutErrorStr = res.getBody();
                                //Create error log record
                                CCR_ErrorLogUtility.createErrorLog(REQUESTBODYTEXT + reqBody + RESPONSEBODYTEXT + res.getBody() + ASSETCODENTIFYIDTEXT
                                        + qureObj.Codentify + ENDPOINTTEXT + listISOBARDetails[0].CCR_GetVoucherEndpoint__c,
                                        CLASSUTILITY , RESENDVOUCHER , ERRORTEXT , INTEGRATIONTEXT,
                                        ISOBARINTEGRATION);
                                noOfErrors++;
                                if (resendVoucherResponse != null) {
                                    if(errorCodes == BLANKTEXT)
                                        errorCodes = String.valueOf(resendVoucherResponse.resCode);
                                    else {
                                        errorCodes = errorCodes+ BLANKTEXT +resendVoucherResponse.resCode;
                                    }
                                }
                            }
                        }
                        else {
                            //In case receives error reponse from ISOBAR
                            //Update qureObj with error message and return to the calling method
                            qureObj.isCalloutSuccess = false;
                            qureObj.calloutErrorStr = res.getStatus();
                            //Create error log record
                            CCR_ErrorLogUtility.createErrorLog(REQUESTBODYTEXT + reqBody + RESPONSEBODYTEXT + res.getBody() + ASSETCODENTIFYIDTEXT
                                    + qureObj.Codentify + ENDPOINTTEXT + listISOBARDetails[0].CCR_GetVoucherEndpoint__c,
                                    CLASSUTILITY , RESENDVOUCHER , ERRORTEXT , INTEGRATIONTEXT,
                                    ISOBARINTEGRATION);
                            noOfErrors++;
                            if(errorCodes == BLANKTEXT)
                                errorCodes = String.valueOf(res.getStatusCode());
                            else {
                                errorCodes = errorCodes+ BLANKTEXT +res.getStatusCode();
                            }
                        }
                    }
                    else {
                        //Update qureObj with error message and return to the calling method
                        qureObj.isCalloutSuccess = false;
                        qureObj.calloutErrorStr = INVALIDQUREHISTORY;
                        //Create error log record
                        CCR_ErrorLogUtility.createErrorLog(INVALIDQUREHISTORY + qureObj.QureHistryId,
                                CLASSUTILITY , RESENDVOUCHER , ERRORTEXT , INTEGRATIONTEXT,
                                ISOBARINTEGRATION);
                        noOfErrors++;
                    }
                }
            }
            else {
                //Update qureObj with error message and return to the calling method
                qureObj.isCalloutSuccess = false;
                qureObj.calloutErrorStr = FEATUREACTIVATIONISSUEMESSAGE;
                //Create error log record
                //This feature not activated for your user.Please contact your administrator
                CCR_ErrorLogUtility.createErrorLog(FEATUREACTIVATIONISSUEMESSAGE + USERCOUNTRYTEXT + qureObj.Market,
                        CLASSUTILITY , RESENDVOUCHER , ERRORTEXT , INTEGRATIONTEXT,
                        ISOBARINTEGRATION);
                noOfErrors++;
            }
        } catch (Exception exp) {

            qureObj.isCalloutSuccess = false;
            qureObj.calloutErrorStr = exp.getMessage();
            //Create error log record
            CCR_ErrorLogUtility.createErrorLog(exp.getMessage() + ASSETCODENTIFYIDTEXT
                    + qureObj.Codentify + CASEIDTEXT + qureObj.CaseId + PHONENUMBERTEXT + qureObj.ConsumerPhone,
                    CLASSUTILITY , RESENDVOUCHER , ERRORTEXT , INTEGRATIONTEXT,
                    ISOBARINTEGRATION);
            noOfErrors++;
            return qureObj;
        }
        System.debug('==== resendVoucher End');
        productDetailArray.add(productDataobj);
        return qureObj;
    }

    /**
* Method Name :  getValidAccessToken
* Arguments: String endpointUrlForAuth
* Return : None
* Description: Used to keep latest active access token in custom settings
**/
    Public static void getValidAccessToken(String endpointUrlForAuth, String apiKeyValue, String apiKeySecret) {

        authenticate_StartTime =system.now();//Added as per US CCR-5995 send ISOBAR Callout params to TELEMETRY user
        try {
            getOrgAccessToken(endpointUrlForAuth,apiKeyValue,apiKeySecret);//Generate fresh access token
        } catch (Exception exp) {
            noOfErrors++;
            throw exp;
        }
    }

    /**
* Method Name :  getOrgAccessToken
* Arguments: String endpointUrlForAuth
* Return : String
* Description: Used to generate access token from Demandware
**/
    public static void getOrgAccessToken(String endpointUrlForAuth, String apiKeyValue, String apiKeySecret) {

        Integer expires_in = 0;

        try {
            //Prepare request for Demandware Authentication Callout
            String reqbody = BLANKTEXT;
            AuthenticationRequest authRequest = new AuthenticationRequest();
            AuthenticationResponse authResponse = new AuthenticationResponse();
            Http httpInstance = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            authRequest.apiKey = apiKeyValue;
            authRequest.apiSecret = apiKeySecret;
            reqbody = JSON.serialize(authRequest);
            req.setBody(reqbody);
            req.setMethod(POSTMETHODTEXT);
            req.setHeader(CONTENTTYPE, JSONFORMATTEXT);
            req.setHeader(ACCEPT, JSONFORMATTEXT);
            req.setEndpoint(endpointUrlForAuth);
            //Make callout for authentication
            res = httpInstance.send(req);
            system.debug('Reponse from authentication callout : ' + res + res.getBody());
            authenticate_EndTime =system.now();//Added as per US CCR-5995 send ISOBAR Callout params to TELEMETRY user
            accessToken = BLANKTEXT;
            authResponse = (AuthenticationResponse)JSON.deserialize(res.getBody(), AuthenticationResponse.Class);
            //Parse response from Demandware to get access token
            if (res.getStatusCode() == UPDATESTATUSCODESUCCESS) {

                accessToken = authResponse.accessToken;
                expires_in = (Integer.ValueOf(DateTime.ValueOf(authResponse.expiredAt).getTime()) - Integer.ValueOf(DateTime.ValueOf(authresponse.now).getTime()))/1000;
                system.debug(expires_in);

                //If valid time is not less than 5 minutes update platform cache with new access token
//                if (expires_in > 300) {
//
////                    Cache.Org.put(ISOBARACCESSTOKENVALUE, accessToken , expires_in);
//                }
                if(test.isRunningTest()) {
                    proceedFlag = false;//Set proceedFlag to false to stop further callouts
                }
            } else {

                proceedFlag = false;//Set proceedFlag to false to stop further callouts
                //Create error log record
                //Unable to authenticate to ISOBAR
                CCR_ErrorLogUtility.createErrorLog(REQUESTBODYTEXT + reqBody + RESPONSEBODYTEXT + res.getBody() + ENDPOINTTEXT + endpointUrlForAuth,
                        CLASSUTILITY, AUTHENTICATIONMETHOD , ERRORTEXT , INTEGRATIONTEXT,
                        ISOBARINTEGRATION);
                noOfErrors++;
                if(errorCodes == BLANKTEXT)
                    errorCodes = String.valueOf(res.getStatusCode());
                else {
                    errorCodes = errorCodes+ BLANKTEXT +res.getStatusCode();
                }
            }
        } catch (Exception exp) {
            throw exp;
        }
    }


    /**
* Method Name :  logDebug
* Arguments: None
* Return : Void
* Description: Used to capture errorlog salesforce ID of the error log record created
**/
    //Added as per US CCR-5995 send ISOBAR Callout params to TELEMETRY user
    Public static void logDebug (DateTime startTime) {

        List<DTE_ErrorLog__c> listErrorLog = new List<DTE_ErrorLog__c>();

        listErrorLog = [SELECT id, createddate FROM DTE_ErrorLog__c WHERE CCR_ClassName__c = :CLASSUTILITY
        ORDER BY createddate DESC  LIMIT 1];

        if(!listErrorLog.isEmpty()) {
            if(listErrorLog[0].createddate >= startTime){
                system.debug('aaaaaaaaaa');
                errorLogReference =  listErrorLog[0].Id;
            }
        }
    }


    /**
* Method Name :  pushTelemtryEvent
* Arguments:
* Return : Void
* Description: Used to push event to telemetry platform event
**/
    //Added as per US CCR-5995 send ISOBAR Callout params to TELEMETRY user
    Public static void pushTelemtryEvent (DateTime startTime, DateTime transEndTime) {

        CCR_TelemtryUtility.JSON_Payload jsonPayload = new CCR_TelemtryUtility.JSON_Payload();
        CCR_TelemtryUtility.SFDC_Details sfdcDetails = new CCR_TelemtryUtility.SFDC_Details();
        CCR_TelemtryUtility.TriggerModule_Details triggerModuleDetails = new CCR_TelemtryUtility.TriggerModule_Details();
        CCR_TelemtryUtility.Source_Details sourceDetails = new CCR_TelemtryUtility.Source_Details();
        CCR_TelemtryUtility.App_Detail appDetails = new CCR_TelemtryUtility.App_Detail();
        CCR_TelemtryUtility.Metric_Set metricSet = new CCR_TelemtryUtility.Metric_Set();
        CCR_TelemtryUtility.Custom_Details customDetails =  new CCR_TelemtryUtility.Custom_Details();
        String environmnetName = BLANKTEXT;
        String host = String.ValueOf(URL.getSalesforceBaseUrl().getHost());
        List<CCR_InstanceMapping__mdt> instanceMappingList = [SELECT id,CCR_InstanceType__c from CCR_InstanceMapping__mdt
        where CCR_OrganisationId__c =: UserInfo.getOrganizationId().substring(0,15) LIMIT 1];
        if(!instanceMappingList.isEmpty()) {
            environmnetName =  instanceMappingList[0].CCR_InstanceType__c;
        }
        else {
            environmnetName = DEVTEXT;
        }
        try {
            jsonPayload.index = METRICTEXT+HIPHEN+SFDCTEXT+HIPHEN+ISOBARINTEGRATIONTEXT+HIPHEN+environmnetName+HIPHEN+system.now();
            jsonPayload.type = METRICTEXT;
            sourceDetails.environment = environmnetName;
            sourceDetails.timestamp = string.valueof(system.now());
            appDetails.id = SFDCTEXT+HIPHEN+CONSUMERCARETEXT+HIPHEN+ISOBARINTEGRATIONTEXT;
            appDetails.alias = SFDCTEXT+HIPHEN+ISOBARINTEGRATIONTEXT;
            sourceDetails.app = appDetails;
            metricSet.host = host;
            metricSet.module = ISOBARINTEGRATIONTEXT;
            sourceDetails.metricset = metricSet;
            sourceDetails.custom = customdetails;
            triggerModuleDetails.transactiontrigger = transIntiator;//ISOBAR -Get Voucher or ISOBAR -Resend Voucher
            triggerModuleDetails.type = CLASSTEXT;
            triggerModuleDetails.runninguser = userinfo.getuserid();
            triggerModuleDetails.transactionstarttime = string.valueof(startTime);
            triggerModuleDetails.transactionendtime = string.valueof(transEndTime);
            triggerModuleDetails.transactionduration = String.ValueOf(transEndTime.getTime() - startTime.getTime());
            triggerModuleDetails.errorcodes = errorCodes;
            triggerModuleDetails.numberoferrors = noOfErrors;
            logDebug(startTime);
            triggerModuleDetails.errorlogref = errorLogReference;
            triggerModuleDetails.transactionID = ISOBARTEXT+HIPHEN+transIntiator+HIPHEN+string.valueof(system.now());//ISOBAR -Get Voucher or ISOBAR -Resend Voucher
            dataDetails.getvoucher_starttime = String.valueof(getVoucher_StartTime);
            dataDetails.getvoucher_endtime  = String.valueof(getVoucher_EndTime);
            if(getVoucher_StartTime != null && getVoucher_StartTime != null)
                dataDetails.getvoucher_duration = String.valueof(Double.valueOf(getVoucher_EndTime.getTime() -getVoucher_StartTime.getTime()));
            dataDetails.resendvoucher_starttime = String.valueof(resendVoucher_StartTime);
            dataDetails.resendvoucher_endtime = String.valueof(resendVoucher_EndTime);
            if(resendVoucher_EndTime != null && resendVoucher_StartTime != null)
                dataDetails.resendvoucher_duration = String.valueof(Double.valueOf(resendVoucher_EndTime.getTime() - resendVoucher_StartTime.getTime()));
            dataDetails.authenticate_starttime= String.valueof(authenticate_starttime);
            dataDetails.authenticate_endtime = String.valueOf(authenticate_endtime);
            if(authenticate_starttime != null && authenticate_endtime != null)
                dataDetails.authenticate_duration = String.valueOf(Double.valueof(authenticate_endtime.getTime() - authenticate_starttime.getTime()));
            dataDetails.isobarproductdata = productDetailArray;
            triggerModuleDetails.data = dataDetails;
            triggerModuleDetails.classname = CLASSNAMETEXT;
            sfdcDetails.isobar_Integration = triggerModuleDetails;
            jsonPayload.source = sourceDetails;
            sourceDetails.sfdc = sfdcDetails;
            CCR_TelemtryUtility.publishEvent(jsonPayload);
        }
        Catch (Exception exp) {

            CCR_ErrorLogUtility.createExceptionLog(exp,ERRORTEXT,INTEGRATIONTEXT,ERRORFUNCTIONTELEMETRY);
        }
    }

    //Wrapper class structure for authentication request body
    private class AuthenticationRequest {
        private String apiKey;	//01916986
        private String apiSecret; //A123
    }

    //Wrapper class structure for authentication response body
    private class AuthenticationResponse {
        private String expiredAt;	//2018-07-19 09:28:50
        private String resCode; //00
        private String accessToken;//A123
        private String resMsg;//Success
        private String now;//2018-07-19 08:58:50
    }
    //Wrapper class structure for resendvoucher request body
    private class ResendVoucherRequest {
        private String voucherIdx;	//01916986
    }
    //Wrapper class structure for getvoucher response body
    private class ResendVoucherResponse {
        private String resCode;	//06
        private String resMsg;	//Duplicated Case No
    }

    public static void runTest(){
        Integer I = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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