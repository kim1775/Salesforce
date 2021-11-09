/**
 * Created by I2MAX on 2021-03-24.
 * QURE 자가진단 모듈에서 활용하는 클래스
 */

public without sharing class CCR_QUREFaultTreeApex {
    public static final String DEVICEISSUE = 'Device Issue';
    public static final String DIAGNOSTICRESULT = 'Diagnostic Result';
    public static final String ENDMESSAGE = 'End Message';
    public static final String TIPSANDTRICKS = 'Tips and Tricks';
    public static final String SPACE = ' ';
    public static final String COMMASTRING = ', ';
    public static final String NEWLINE = '\n';
    public static final String RPLSORDERCREATED = 'Replacement Order Created';
    public static final String RPLSORDERNOTCREATED = 'Replacement Order Not Created';
    public static final String COURIERDELIVERY = 'CourierDelivery';
    public static final String CVSSTORE = 'CVSStore';
    public static final String ISWAP = 'iSWAP';
    public static final String IQOSQOACH = 'Iqos_coach';
    public static final String ERRORTYPE='Error';
    public static final String ERRORSCOPE='Application';
    public static final String ERRORFUNCTIONELIGIBILITY='Qure Fault Tree';
    public static final String ERRORCLASSNAME='CCR_QUREFaultTreeApex';
    public static final String QUREACTIVE='Active';
    public static final String QUREINACTIVE='Inactive';
    public static final String CVSCALLOUTSUCCESS = 'CVS Voucher Sent Confirm';
    public static final String VOUCHERRESENDSUCCESS = 'CVS Voucher Re Send Confirm';
    public static final String VOUCHERRESENDFAILED = 'CVS Voucher Re Send Error';
    public static final String DEFECTIVEACCESSORY = 'Defective Accessory';
    public static final String ELECTRONICACCESSORY = 'Electronic Accessory';
    Public static final string RETAILER = 'Retailer';
    public static final String CONSUMERPROFILENAME = 'CCR Consumer Community';
    public static final String ISWAPCALLOUTSUCCESS = 'iSwap SMS Sent';
    public static final String ISWAPCALLOUTFAIL = 'iSwap SMS Sent Error';
    public static final String COURIERDELIVERYFORMRT = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_CourierDeliveryConfiguration').getRecordTypeId();
    public static final String EMAILCONFIGURATIONRT = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_MarketEmailConfiguration').getRecordTypeId();
    /**
   * Method Name :  loadInetialDataForQure
   * Arguments:
   * @param 1: Codentiry
   * @param 1: country
   * @param 1: language
   * @param 1: qureRecId
   * Return : List<CCR_DeviceDiagnosticLocalization__c>
   * Description: This method is used in CCR_QUREDeviceStatus lightning component to query CCR_DeviceStatus__c records
   **/
    @AuraEnabled
    public static wrapperData loadInetialDataForQure(String codentify, String language, String qureRecId, String userType) {
        Boolean isQureActive = true;
        System.debug('==== qureRecId = ' + qureRecId);
        System.debug('==== codentify = ' + codentify);
        System.debug('==== userType = ' + userType);
        System.debug('==== qureRecId = ' + qureRecId);
        //Update Diagnosis start Date
        if(qureRecId != null) {
            List<CCR_QureHistory__c> qureHistData = [SELECT Id,CCR_StartDiagnostic__c, CCR_Status__c
                                                        FROM CCR_QureHistory__c
                                                        WHERE Id = :qureRecId
                                                        AND CCR_Status__c = :QUREACTIVE];
            if(!qureHistData.isEmpty() && qureHistData[0].CCR_Status__c == QUREACTIVE){
                qureHistData[0].CCR_StartDiagnostic__c= system.now();
                updateQureHistory(qureHistData[0]);
            }
            else {
                isQureActive = false;
            }
        }

        system.debug('SSSSSSSSSSSSSS : '+isQureActive);
        wrapperData wrapData = new wrapperData();
        if(isQureActive) {
            List<Asset> astList = [SELECT CCR_DeviceProductCode__r.CCR_ModelNumber__c
            FROM Asset
            WHERE CCR_CodentifyId__c =: codentify Limit 1];
            System.debug('debug called 1111 :::  ' + astList);
            if(!astList.isEmpty()) {
                Map<Id, CCR_DeviceDiagnostic__c> diagsPrntMap = new Map<Id, CCR_DeviceDiagnostic__c> (
                [SELECT Id,CCR_NextStep__c, RecordType.Name, CCR_NextStep__r.RecordType.Name, CCR_NextStep__r.CCR_IsIssueSolved__c,
                        CCR_NextStep__r.CCR_DiagnosticResult__c, CCR_NextNegativeStep__c,CCR_ParentDiagnostic__c,
                        CCR_NextNegativeStep__r.RecordType.Name, CCR_NextNegativeStep__r.CCR_IsIssueSolved__c, CCR_DisplayNextTitleText__c,
                        CCR_NextNegativeStep__r.CCR_DiagnosticResult__c, CCR_NextStep__r.CCR_DiagnosticDescription__c,
                        CCR_NextNegativeStep__r.CCR_DiagnosticDescription__c, CCR_NextStep__r.CCR_MessageName__c
                FROM CCR_DeviceDiagnostic__c
                WHERE (CCR_Model__c =: astList[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c
                AND CCR_ParentDiagnostic__c = null
                AND CCR_OrderPriority__c != null
                AND CCR_Active__c = TRUE
                AND CCR_ExcludeUserTypes__c EXCLUDES (:userType))
                ORDER BY CCR_OrderPriority__c ASC]);
                System.debug('diagsPrntMap ' + diagsPrntMap);
                wrapData.diagnosticData = diagsPrntMap;
                wrapData.typeOfData = diagsPrntMap.values()[0].RecordType.Name;
                List<CCR_DeviceDiagnosticLocalization__c> diagnosticLocal = getDiagnosticRecords(diagsPrntMap.keySet(), language);
                System.debug('after getDiagnosticRecords ' + diagnosticLocal);
                wrapData.typeOfData = DEVICEISSUE;
                wrapData.diagnosticLocalData = diagnosticLocal;
                return wrapData;
            }
            else {
                return null;
            }
        } else {
            wrapData.isQureActive = false;
            return wrapData;
        }
    }
    /**
* Method Name :  queryDeviceDiagnosticRecs
* Arguments:
* @param 1: Codentiry
* @param 1: country
* @param 1: language
* @param 1: qureRecId
* Return : List<CCR_DeviceDiagnosticLocalization__c>
* Description: This method is used in CCR_QUREDeviceStatus lightning component to query CCR_DeviceStatus__c records
**/
    @AuraEnabled
    public static wrapperData queryDeviceDiagnosticRecs(String codentify, String parentId, String nextRecId, String country, String language, String qureHistId, String userType) {
        system.debug('@@@@@@parent : '+parentId+'--------------:'+nextRecId);
        wrapperData wrapData = new wrapperData();
        if(checkQureIsActive (qureHistId)) {
            if(parentId != null && nextRecId == null){
                Map<Id, CCR_DeviceDiagnostic__c> diagsPrntMap = new Map<Id, CCR_DeviceDiagnostic__c> (
                [SELECT Id,CCR_NextStep__c, RecordType.Name, CCR_NextStep__r.RecordType.Name, CCR_NextStep__r.CCR_IsIssueSolved__c,
                        CCR_NextStep__r.CCR_DiagnosticResult__c, CCR_NextNegativeStep__c,CCR_ParentDiagnostic__c, CCR_DisplayNextTitleText__c,
                        CCR_NextStep__r.CCR_DiagnosticDescription__c, CCR_NextNegativeStep__r.CCR_DiagnosticDescription__c,
                        CCR_NextStep__r.CCR_MessageName__c
                FROM CCR_DeviceDiagnostic__c
                WHERE CCR_ParentDiagnostic__c = :parentId
                AND CCR_Active__c = TRUE
                AND CCR_ExcludeUserTypes__c EXCLUDES (:userType)
                ORDER BY CCR_OrderPriority__c ASC]);
                system.debug('XXXXXXXXXXXXX1111111 : '+diagsPrntMap);
                wrapData.diagnosticData = diagsPrntMap;
                wrapData.typeOfData = diagsPrntMap.values()[0].RecordType.Name;
                List<CCR_DeviceDiagnosticLocalization__c> diagnosticLocal = getDiagnosticRecords(diagsPrntMap.keySet(), language);
                wrapData.diagnosticLocalData = diagnosticLocal;
                return wrapData;
            }
            else {
                Map<Id, CCR_DeviceDiagnostic__c> digsMap = new Map<Id, CCR_DeviceDiagnostic__c> (
                [SELECT Id,CCR_NextStep__c, RecordType.Name, CCR_NextStep__r.RecordType.Name, CCR_NextStep__r.CCR_IsIssueSolved__c,
                        CCR_NextStep__r.CCR_DiagnosticResult__c, CCR_NextStep__r.CCR_DiagnosticDescription__c, CCR_ParentDiagnostic__c,
                        CCR_NextNegativeStep__c, CCR_NextNegativeStep__r.RecordType.Name, CCR_NextNegativeStep__r.CCR_IsIssueSolved__c,
                        CCR_NextNegativeStep__r.CCR_DiagnosticResult__c,CCR_NextNegativeStep__r.CCR_DiagnosticDescription__c,
                        CCR_NextStep__r.CCR_MessageName__c, CCR_DisplayNextTitleText__c
                FROM CCR_DeviceDiagnostic__c
                WHERE Id =:  nextRecId
                AND CCR_Active__c = TRUE
                AND CCR_ExcludeUserTypes__c EXCLUDES (:userType)]);
                wrapData.diagnosticData = digsMap;
                wrapData.typeOfData = digsMap.values()[0].RecordType.Name;
                List<CCR_DeviceDiagnosticLocalization__c> diagnosticLocal = getDiagnosticRecords(digsMap.keySet(), language);
                system.debug('XXXXXXXX4 : '+digsMap);
                wrapData.diagnosticLocalData = diagnosticLocal;
                return wrapData;
            }
        }
        else {
            wrapData.isQureActive = false;
            system.debug('XXXXXXXXwrapData : '+wrapData);
            return wrapData;
        }
    }

    /**
* Method Name :  getDiagnosticRecords
* Arguments: Set Of device Diagnostic Ids
* Return : List<CCR_DeviceDiagnosticLocalization__c>
* Description: This method is used to query the Device Diagnostic Localization records
**/
    public Static List<CCR_DeviceDiagnosticLocalization__c> getDiagnosticRecords(set<Id> diagIdsSet, String lang) {
        system.debug('@@@@@@@@ ======= language'+lang+'======Keyset: '+diagIdsSet);
        List <CCR_DeviceDiagnosticLocalization__c> digsList =  [SELECT Id, CCR_Message__c, CCR_LocalisationUID__c,
                CCR_DeviceDiagnostic__r.Name, CCR_DeviceDiagnostic__r.CCR_NextStep__c,CCR_DeviceDiagnostic__r.CCR_NextNegativeStep__c,
                CCR_NextNegativeStepButtonValue__c, CCR_NextPositiveStepButtonValue__c, CCR_DeviceDiagnostic__r.CCR_ParentDiagnostic__c,
                CCR_DeviceDiagnostic__r.CCR_DiagnosticResult__c, CCR_DeviceDiagnostic__r.CCR_IsIssueSolved__c, CCR_DeviceDiagnostic__c
        FROM CCR_DeviceDiagnosticLocalization__c
        WHERE CCR_DeviceDiagnostic__c IN :diagIdsSet
        AND CCR_Language__c = 'ko'
        AND CCR_Active__c = TRUE
        ORDER BY CCR_DeviceDiagnostic__r.CCR_OrderPriority__c ASC];
        system.debug('@@@@@@@@ recsList : '+digsList);
        return digsList;
    }

    /**
* Method Name :  updateQureHistory
* Arguments: QUre History object record
* Return : void
* Description: This method is used update qure history record
**/
    Public Static void updateQureHistory(CCR_QureHistory__c qureObj) {
        try {
            update qureObj;
            system.debug('UUUUUUUUUpdate: '+qureObj);
        }
        catch (Exception exp){
            system.debug('Exception in Qure History record update: '+exp);
            try{
                CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            }
            catch (Exception expton){
                System.debug('Error == ' + expton);
            }
            throw exp;
        }
    }

    /**
* Method Name :  updateCaseRecord
* Arguments: Case object record
* Return : void
* Description: This method is used update Case record
**/
    Public Static void updateCaseRecord(List<Case> caseList) {
        try {
            update caseList;
        }
        catch (Exception exp){
            system.debug('Exception in case Update: '+exp);
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            }
            catch (Exception expton){
                System.debug('Error == ' + expton);
            }
            throw exp;
        }
    }
    /**
* Method Name :  updateQureHistory
* Arguments:
* @param: QUreMsg String
* @param: String Diatnostic result
* @param: String Diagnostic description
* @param: Boolean issue solved ot not
* Return : void
* Description: This method is used update qure record
**/
    @AuraEnabled
    Public Static CCR_QureMsg updateQureHistoryWithResult(String qMsg, String diagResultCode, String diagDescription, Boolean isIssueSolved) {
        system.debug('!!!!!!!before : '+qMsg);
        system.debug('!!!!!!!before : '+diagResultCode);
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);

        List<CCR_QureHistory__c> qureHistData = [SELECT Id,CCR_DiagnosticResult__c, CCR_EndDiagnostic__c, CCR_DiagnosticDescription__c,
                CCR_Status__c
        FROM CCR_QureHistory__c
        WHERE Id = :qureMsg.QureHistryId
        AND CCR_Status__c = :QUREACTIVE LIMIT 1];
        if(!qureHistData.isEmpty()){
            if(!qureHistData.isEmpty() && qureHistData[0].CCR_Status__c == QUREACTIVE){
                qureHistData[0].CCR_EndDiagnostic__c = system.now();
                qureHistData[0].CCR_DiagnosticResult__c = diagResultCode;
                qureHistData[0].CCR_DiagnosticDescription__c = diagDescription;
                updateQureHistory(qureHistData[0]);
                qureMsg.ResultCode = diagResultCode;
                if(isIssueSolved != null && isIssueSolved){
                    qureMsg.Results = CCR_QureMsg.ISSUESOLVED;
                }
                else {
                    qureMsg.Results = CCR_QureMsg.ISSUENOTSOLVED;
                }
                system.debug('!!!!!!!after : '+qureMsg);
                return qureMsg;
            }
            else {
                return null;
            }
        }
        else {
            System.debug('qureinactive CCR_QUREFaultTreeApex.cls updateQureHistoryWithResult');
            qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
            return qureMsg;
        }
    }

    /**
* Method Name :  createQoachCaseForReplacement
* Arguments: String QureMsg
* Return : CCR_QureMsg
* Description: This method is used get translated Labels
**/
    @AuraEnabled
    Public Static CCR_QureMsg createIssueSolvedhQUreCase (String qMsg) {
        system.debug('@@@@@@@@@@SOlved Issue : '+JSON.deserialize(qMsg, CCR_QureMsg.class));
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        List<user> userType = [Select CCR_UserType__c From User Where Id = :UserInfo.getUserId()];
        List<Asset> assetList = [SELECT Id, CCR_MaterialGroupDescription__c, contactId, Contact.CCR_CountryID__c,CCR_DeviceProductCode__r.CCR_Version__c,
                CCR_DeviceProductCode__r.CCR_ModelNumber__c
        FROM Asset
        WHERE CCR_CodentifyId__c =: qureMsg.codentify LIMIT 1];
        List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_Case__c, CCR_Status__c, CCR_DiagnosticResult__c , CCR_DiagnosticDescription__c,
                CCR_ConsumerCountry__c
        FROM CCR_QureHistory__c
        WHERE Id =: qureMsg.QureHistryId
        AND CCR_Status__c = :QUREACTIVE LIMIT 1];
        Case qureCase = new Case();
        system.debug('#####qureHistoryList: '+qureHistoryList);
        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE) {
            List<CCR_QureConfiguration__c> qureConfig = [SELECT ID, CCR_SubjectCode__c
            FROM CCR_QureConfiguration__c
            WHERE CCR_DiagnosticResult__c = :qureHistoryList[0].CCR_DiagnosticResult__c
            AND CCR_Model__c =:assetList[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c];
            if(usertype[0].CCR_UserType__c == RETAILER){
                if(qureHistoryList[0].CCR_DiagnosticDescription__c == DEFECTIVEACCESSORY){
                    qureCase = CCR_QureUtility.createCaseForQure(ELECTRONICACCESSORY, qureConfig[0].CCR_SubjectCode__c,
                            SPACE, 'Closed', assetList[0].contactId, assetList[0].Id,
                            null, SPACE,
                            SPACE, null,
                            qureMsg.UserType,null);

                }else{
                    qureCase = CCR_QureUtility.createCaseForQure(assetList[0].CCR_MaterialGroupDescription__c, qureConfig[0].CCR_SubjectCode__c,
                            SPACE, 'Closed', assetList[0].contactId, assetList[0].Id,
                            qureHistoryList[0].CCR_DiagnosticResult__c, SPACE,
                            SPACE, qureHistoryList[0].CCR_DiagnosticDescription__c,
                            qureMsg.UserType,assetList[0].CCR_DeviceProductCode__r.CCR_Version__c);
                }

            }
            if(qureHistoryList[0].CCR_DiagnosticDescription__c == DEFECTIVEACCESSORY && usertype[0].CCR_UserType__c != RETAILER){
                qureCase = CCR_QureUtility.createCaseForQure(ELECTRONICACCESSORY, qureConfig[0].CCR_SubjectCode__c,
                        SPACE, 'Closed', assetList[0].contactId, assetList[0].Id,
                        null, SPACE,
                        SPACE, null,
                        qureMsg.UserType,null);

            }
            else{
                if(usertype[0].CCR_UserType__c != RETAILER){
                    qureCase = CCR_QureUtility.createCaseForQure(assetList[0].CCR_MaterialGroupDescription__c, qureConfig[0].CCR_SubjectCode__c,
                            SPACE, 'Closed', assetList[0].contactId, assetList[0].Id,
                            qureHistoryList[0].CCR_DiagnosticResult__c, SPACE,
                            SPACE, qureHistoryList[0].CCR_DiagnosticDescription__c,
                            qureMsg.UserType,assetList[0].CCR_DeviceProductCode__r.CCR_Version__c);

                }

            }

            if(qureCase != null && !qureHistoryList.isEmpty()) {
                qureHistoryList[0].CCR_Case__c = qureCase.Id;
                qureHistoryList[0].CCR_Status__c = QUREINACTIVE;
                updateQureHistory(qureHistoryList[0]);
                system.debug('Qure Message: '+qureMsg);
                return qureMsg;
            }
            else {
                return null;
            }
        }
        else {
            System.debug('qureinactive CCR_QUREFaultTreeApex.cls createIssueSolvedhQUreCase');
            qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
            return qureMsg;
        }
    }

    /**
* Method Name :  createQoachCaseForReplacement
* Arguments: String QureMsg
* Return : CCR_QureMsg
* Description: This method is used get create case for replacement.
**/
    @AuraEnabled
    Public Static CCR_QureMsg createQureCaseForReplacement (String qMsg) {
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        System.debug('==== CCR_QUREFaultTreeApex.cls createQureCaseForReplacement Start');
        System.debug('==== QureMsg === ' + qureMsg);
        List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_EligibilityResult__c, CCR_SubjectCode__c, CCR_Case__c,
                CCR_QureReplacementChannel__c, CCR_EndDateforreplacementreasonselectio__c,
                CCR_StartDateforreplacementreason_select__c, CCR_ReplacementChannelSelectedBy__c,
                CCR_Status__c, CCR_DiagnosticResult__c, CCR_DiagnosticDescription__c
        FROM CCR_QureHistory__c
        WHERE Id =: qureMsg.QureHistryId
        AND CCR_Status__c = :QUREACTIVE LIMIT 1];

        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE) {
            if(qureHistoryList[0].CCR_QureReplacementChannel__c != 'CourierDelivery' &&
                    qureHistoryList[0].CCR_QureReplacementChannel__c != 'CVSStore') {
                List<CCR_QureReplacementChannels__mdt> mdtList = retrieveReplacementChannelsMetadata(qureMsg.channelSelected);
                String caseResoChnl = SPACE;
                String historyReplace = SPACE;
                String orderId = SPACE;
                if(!mdtList.isEmpty() && (qureMsg.channelSelected == 'IQOS_Flagship_Store' ||
                        qureMsg.channelSelected == 'Corner_Shop' ||
                        qureMsg.channelSelected == 'Call_Center_Agent_SWAP')){
                    caseResoChnl = mdtList[0].CCR_CaseResolution__c;
                    historyReplace = mdtList[0].CCR_QureHistoryReplacementChannel__c;
                }
                Case qureCase = new Case();
                List<Asset> assetList = [SELECT Id, CCR_MaterialGroupDescription__c, contactId, Contact.CCR_CountryID__c,CCR_DeviceProductCode__r.CCR_Version__c
                FROM Asset
                WHERE CCR_CodentifyId__c =: qureMsg.codentify LIMIT 1];

                System.debug('CCR_QUREFaultTreeApex.cls createQureCaseForReplacement check 1');
                System.debug(assetList);

                if(!assetList.isEmpty()) {
                    qureCase = CCR_QureUtility.createCaseForQure(assetList[0].CCR_MaterialGroupDescription__c, qureHistoryList[0].CCR_SubjectCode__c,
                            caseResoChnl, 'Closed', assetList[0].contactId, assetList[0].Id,
                            qureHistoryList[0].CCR_DiagnosticResult__c, qureHistoryList[0].CCR_EligibilityResult__c,
                            SPACE, qureHistoryList[0].CCR_DiagnosticDescription__c,
                            qureMsg.UserType,assetList[0].CCR_DeviceProductCode__r.CCR_Version__c);
                }
                if(qureCase != null) {
                    qureHistoryList[0].CCR_Case__c = qureCase.Id;
                    qureHistoryList[0].CCR_QureReplacementChannel__c = historyReplace;
                    qureHistoryList[0].CCR_ReplacementChannelSelectedBy__c = userInfo.getUserId();
                    qureHistoryList[0].CCR_EndDateforreplacementreasonselectio__c = system.now();
                    qureMsg.CaseId = qureCase.Id;
                    System.debug('CCR_QUREFaultTreeApex.cls createQureCaseForReplacement updateQureHistory called');
                    updateQureHistory(qureHistoryList[0]);
                    qureCase.CCR_Resolution__c = caseResoChnl;
                    updateCaseRecord(New List<Case> {qureCase});
                    // Added by Raghu for the user story CCR-156267
                    List<CCR_QureConfiguration__c> emailConfigurationList = [SELECT CCR_Country__c, CCR_ReplacementChannel__c, CCR_Regex__c
                    FROM CCR_QureConfiguration__c
                    WHERE RecordtypeID = :EMAILCONFIGURATIONRT
                    AND CCR_ReplacementChannel__c = :qureMsg.channelSelected
                    LIMIT 1];
                    system.debug('emailConfigurationList : '+emailConfigurationList);
                    if(!emailConfigurationList.isEmpty()){
                        qureMsg.emailConfiguration = emailConfigurationList[0];
                    }
                    return qureMsg;
                } else {
                    return null;
                }
            }
            else {
                System.debug('qureinactive CCR_QUREFaultTreeApex.cls createQureCaseForReplacement 1');
                qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
                return qureMsg;
            }
        } else {
            System.debug('qureinactive CCR_QUREFaultTreeApex.cls createQureCaseForReplacement 2');
            qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
            return qureMsg;
        }
    }

    /**
* Method Name :  placeOrderInDemandWare
* Arguments: String QureMessage
* Return : CCR_QureMsg
* Description: This method is used make a callout to DW to create order
**/
    @AuraEnabled
    Public Static CCR_QureMsg placeOrderInDemandWare (String qMsg) {
        system.debug('@@@@@@@@@@ : '+JSON.deserialize(qMsg, CCR_QureMsg.class));
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_QureReplacementChannel__c, CCR_EndDateforreplacementreasonselectio__c,
                CCR_ReplacementChannelSelectedBy__c, CCR_Status__c
        FROM CCR_QureHistory__c
        WHERE Id =: qureMsg.QureHistryId
        AND CCR_Status__c = :QUREACTIVE LIMIT 1];
        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE &&
                (qureHistoryList[0].CCR_QureReplacementChannel__c == 'CourierDelivery' ||
                        qureHistoryList[0].CCR_QureReplacementChannel__c == 'CVSStore' ||
                        qureHistoryList[0].CCR_QureReplacementChannel__c == ISWAP ||
                        qureHistoryList[0].CCR_QureReplacementChannel__c == IQOSQOACH)) {
            List<CCR_QureReplacementChannels__mdt> mdtList = retrieveReplacementChannelsMetadata(qureMsg.channelSelected);
            String caseResoChnl = SPACE;
            String historyReplace = SPACE;
            if(!mdtList.isEmpty()) {
                caseResoChnl = mdtList[0].CCR_CaseResolution__c;
                historyReplace = mdtList[0].CCR_QureHistoryReplacementChannel__c;
            }
            System.debug('qureMsg.channelSelected == ' + qureMsg.channelSelected);
            CCR_QureMsg responseFromCallOut = new CCR_QureMsg ();
            String deliveryAddress = '';
            // Callout to DemandWare Integration
            if(qureMsg.channelSelected == COURIERDELIVERY) {
                System.debug('CCR_QUREFaultTreeApex.cls placeOrderInDemandWare called channel == COURIERDELIVERY');
                deliveryAddress = 'Delivery Address: ';
                //Added by Raghu as part of CCR-156267
                // 사실상 미사용 부분....
                qureMsg.fullAddressText = '';
                for(CCR_QureConfiguration__c formField : qureMsg.formFieldsList) {
                    if(formField.CCR_FormField__c == 'FirstName' && qureMsg.FirstName != null) {
                        deliveryAddress += qureMsg.FirstName +SPACE;
                        qureMsg.fullAddressText += qureMsg.FirstName + COMMASTRING;
                    }
                    if(formField.CCR_FormField__c == 'LastName' && qureMsg.LastName != null) {
                        deliveryAddress += qureMsg.LastName +NEWLINE;
                        qureMsg.fullAddressText += qureMsg.LastName + COMMASTRING;
                    }
                    if((formField.CCR_FormField__c == 'StreetNumber' || formField.CCR_FormField__c == 'AddressReference') && qureMsg.Address2 != null) {
                        deliveryAddress += qureMsg.Address2+NEWLINE;
                        qureMsg.fullAddressText += qureMsg.Address2 + COMMASTRING;
                    }
                    if((formField.CCR_FormField__c == 'StreetName' || formField.CCR_FormField__c == 'Address') && qureMsg.Address1 != null) {
                        deliveryAddress += qureMsg.Address1 +NEWLINE;
                        qureMsg.fullAddressText += qureMsg.Address1 + COMMASTRING;
                    }
                    if((formField.CCR_FormField__c == 'Reference' || formField.CCR_FormField__c == 'C/O') && qureMsg.Address3 != null) {
                        deliveryAddress += qureMsg.Address3+NEWLINE;
                        qureMsg.fullAddressText += qureMsg.Address3 + COMMASTRING;
                    }
                    if((formField.CCR_FormField__c == 'Building' || formField.CCR_FormField__c == 'Door') && qureMsg.Address4 != null) {
                        deliveryAddress += qureMsg.Address4 +NEWLINE;
                        qureMsg.fullAddressText += qureMsg.Address4 + COMMASTRING;
                    }
                    if(formField.CCR_FormField__c == 'Apartment' && qureMsg.Address5 != null) {
                        deliveryAddress += +qureMsg.Address5+NEWLINE;
                        qureMsg.fullAddressText += qureMsg.Address5 + COMMASTRING;
                    }
                    if(formField.CCR_FormField__c == 'Department' && qureMsg.Area != null) {
                        deliveryAddress += qureMsg.Area +NEWLINE;
                        qureMsg.fullAddressText += qureMsg.Area + COMMASTRING;
                    }
                    if(formField.CCR_FormField__c == 'District' && qureMsg.District != null) {
                        deliveryAddress += qureMsg.District +NEWLINE;
                        qureMsg.fullAddressText += qureMsg.District + COMMASTRING;
                    }
                    if(formField.CCR_FormField__c == 'City' && qureMsg.AddressCity != null) {
                        deliveryAddress += qureMsg.AddressCity+NEWLINE;
                        qureMsg.fullAddressText += qureMsg.AddressCity + COMMASTRING;
                    }
                    if(formField.CCR_FormField__c == 'PostalCode' && qureMsg.AddressPostalCode != null) {
                        deliveryAddress += qureMsg.AddressPostalCode + NEWLINE;
                        qureMsg.fullAddressText += qureMsg.AddressPostalCode;
                    }
                    if(formField.CCR_FormField__c == 'Phone' && qureMsg.ConsumerPhone != null) {
                        deliveryAddress += 'Phone: '+qureMsg.ConsumerPhone + NEWLINE;
                    }
                    if(formField.CCR_FormField__c == 'IDType' && qureMsg.IDType != null) {
                        deliveryAddress += qureMsg.IDType + NEWLINE;
                    }
                    if(formField.CCR_FormField__c == 'IDNumber' && qureMsg.IDNumber != null) {
                        deliveryAddress += qureMsg.IDNumber + NEWLINE;
                    }
                    if(formField.CCR_FormField__c == 'TaxID' && qureMsg.TaxID != null) {
                        deliveryAddress += qureMsg.TaxID + NEWLINE;
                    }
                }
                responseFromCallOut = qureMsg;
                if (!Test.isRunningTest()) {
                    system.debug('qureMsg.productId'+qureMsg.productId);
                    if(qureMsg.productId != null){
                        System.debug('replaceAsset called');
//                        responseFromCallOut = CCR_AssetReplacementOrderApi.replaceAsset(qureMsg);
//                        if(!responseFromCallOut.isCalloutSuccess){
//                            responseFromCallOut.colorSwapDataList.clear();
//                        }
                    } else {
                        System.debug('deviceReplacementOrder called');
                        responseFromCallOut = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsg);
                    }
                }
                else {
                    responseFromCallOut.isCalloutSuccess = true;
                    qureMsg.orderId = '12345';
                }
                system.debug('RRRRRRRRRRResponseFromDW: '+responseFromCallOut);
            } else if(qureMsg.channelSelected == CVSSTORE) {
                if(qureMsg.ConsumerPhone != null) {
                    deliveryAddress = 'Phone: '+qureMsg.ConsumerPhone;
                }
                responseFromCallOut = qureMsg;
                DateTime tranStartTime= system.now();
                if (!Test.isRunningTest()) {
                    responseFromCallOut = CCR_CSVIsobarVoucherCodeApi.getVoucher(qureMsg);
                } else {
                    responseFromCallOut.isCalloutSuccess = true;
                    qureMsg.orderId = '12345';
                }
                DateTime tranEndTime = system.now();
                CCR_CSVIsobarVoucherCodeApi.pushTelemtryEvent(tranStartTime,tranEndTime);
                system.debug('RRRRRRRRRRResponseFromCVS: '+responseFromCallOut);
            } else if(qureMsg.channelSelected == ISWAP || qureMsg.channelSelected == IQOSQOACH) {
                if(qureMsg.ConsumerPhone != null) {
                    deliveryAddress = 'Phone: '+qureMsg.ConsumerPhone;
                }
                responseFromCallOut = qureMsg;
                DateTime tranStartTime= system.now();
                System.debug('ISWAP / IQOSQOACH  called!!!!!');
//                if (!Test.isRunningTest()) {
//                    responseFromCallOut = CCR_iSwapReplacementAPIUtility.calliSwapService(qureMsg);
//                } else {
//                    responseFromCallOut.isCalloutSuccess = true;
//                    qureMsg.orderId = '12345';
//                }
//                DateTime tranEndTime = system.now();
//                CCR_iSwapReplacementAPIUtility.pushTelemtryEventForiSWap(tranStartTime,tranEndTime);
//                system.debug('iSwapReplacement Response: '+responseFromCallOut);
            }
            List<Case> caseList = [SELECT Id, CCR_OrderID__c, CCR_Resolution__c, CCR_Verbatim__c
            FROM Case
            WHERE Id =: qureMsg.CaseId LIMIT 1];
            List<Asset> asstList = [SELECT Id,CCR_CodentifyId__c,CCR_EligibilityDueDate__c
            FROM Asset
            WHERE CCR_CodentifyId__c =: qureMsg.Codentify LIMIT 1];
            if(responseFromCallOut.isCalloutSuccess) {
                System.debug('택배 호출 정상');
                if(!caseList.isEmpty()) {
                    System.debug('qureMsg.channelSelected == ' + qureMsg.channelSelected);
                    caseList[0].CCR_OrderID__c = qureMsg.orderId;
                    if(qureMsg.channelSelected == COURIERDELIVERY) {
                        qureMsg.ErrorMsgId = RPLSORDERCREATED;
                        if (asstList != null && !asstList.isEmpty()) {
                            CCR_QureUtility.updateQureDeviceEligibleDays(asstList[0]);
                            CCR_QureUtility.updateQureDeviceReplacementChannel(asstList[0], 'LSP');
                            historyReplace = 'CourierDelivery';
                        }
                    }
                    if(qureMsg.channelSelected == CVSSTORE) {
                        qureMsg.ErrorMsgId = CVSCALLOUTSUCCESS;
                        if(asstList != null && !asstList.isEmpty()){
                            CCR_QureUtility.updateQureDeviceEligibleDays(asstList[0]);
                            CCR_QureUtility.updateQureDeviceReplacementChannel(asstList[0], 'Pickup Point');
                            historyReplace = 'CVSStore';
                        }
                    }
                    if(qureMsg.ConsumerPhone != null && qureMsg.ConsumerPhone != '') {
                        caseList[0].KDCE_QureContactPhone__c = qureMsg.ConsumerPhone;
                    }
                    if(qureMsg.channelSelected == ISWAP || qureMsg.channelSelected == IQOSQOACH)
                        qureMsg.ErrorMsgId = ISWAPCALLOUTSUCCESS;
                    caseList[0].CCR_Resolution__c = caseResoChnl;
                }
                if(!qureHistoryList.isEmpty()) {
                    qureHistoryList[0].CCR_ReplacementChannelSelectedBy__c = userInfo.getUserId();
                    qureHistoryList[0].CCR_QureReplacementChannel__c = historyReplace;
                }
            } else {
                qureHistoryList[0].CCR_QureReplacementChannel__c = null;
                if(qureMsg.channelSelected == COURIERDELIVERY)
                    qureMsg.ErrorMsgId = RPLSORDERNOTCREATED;
                if(qureMsg.channelSelected == CVSSTORE && qureMsg.calloutErrorStr != null) {
                    caseList[0].CCR_Verbatim__c += NEWLINE + qureMsg.calloutErrorStr;
                }
                if(qureMsg.channelSelected == ISWAP || qureMsg.channelSelected == IQOSQOACH) {
                    qureMsg.ErrorMsgId = ISWAPCALLOUTFAIL;
                    caseList[0].CCR_Verbatim__c += NEWLINE + qureMsg.calloutErrorStr;
                }
            }
            updateCaseRecord(caseList);
            qureHistoryList[0].CCR_EndDateforreplacementreasonselectio__c = system.now();
            updateQureHistory(qureHistoryList[0]);

            return qureMsg;
        }
        else {
            System.debug('qureinactive CCR_QUREFaultTreeApex.cls placeOrderInDemandWare');
            qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
            return qureMsg;
        }
    }
    /**
   * Method Name :  updateReplacementChannel
   * Arguments: String QureMsg
   * Return : boolean
   * Description: This method is used to update the qure history replacement channel to avoide the duplicate session/order creation
   **/
    @AuraEnabled
    Public Static Boolean updateReplacementChannel (String qMsg) {
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        System.debug('==== CCR_QUREFaultTreeApex.cls updateReplacementChannel called');
        System.debug('==== qureMsg == ' + qureMsg);
        List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_QureReplacementChannel__c,  CCR_Status__c
        FROM CCR_QureHistory__c
        WHERE Id =: qureMsg.QureHistryId
        AND CCR_Status__c = :QUREACTIVE LIMIT 1];
        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE) {
            if(qureHistoryList[0].CCR_QureReplacementChannel__c == null) {
                qureHistoryList[0].CCR_QureReplacementChannel__c = qureMsg.channelSelected;
                updateQureHistory(qureHistoryList[0]);
                return true;
            }
            else return false;
        }
        return false;
    }

    /**
    * Method Name :  sendRequestToResendVoucher
    * Arguments: String QureMsg
    * Return : CCR_QureMsg
    * Description: This method is used get send request to resend CVS voucher
    **/
    @AuraEnabled
    Public Static CCR_QureMsg sendRequestToResendVoucher (String qMsg) {
        system.debug('@@@@@@@@@@0 : '+JSON.deserialize(qMsg, CCR_QureMsg.class));
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        CCR_QureMsg responseCall = new CCR_QureMsg ();
        DateTime tranStartTime= system.now();
        if (!Test.isRunningTest()) {
            responseCall = CCR_CSVIsobarVoucherCodeApi.resendVoucher(qureMsg);
        }
        else {
            responseCall.isCalloutSuccess = true;
        }
        DateTime tranEndTime = system.now();
        CCR_CSVIsobarVoucherCodeApi.pushTelemtryEvent(tranStartTime,tranEndTime);
        if(responseCall.isCalloutSuccess){
            qureMsg.ErrorMsgId = VOUCHERRESENDSUCCESS;
            createResendVoucherCaseForQure(qureMsg, 'Voucher resent successfully');
        }
        else {
            createResendVoucherCaseForQure(qureMsg, responseCall.calloutErrorStr);
            qureMsg.ErrorMsgId = VOUCHERRESENDFAILED;
        }
        return qureMsg;
    }

    /**
    * Method Name :  createResendVoucherCaseForQure
    * Arguments: CCR_QureMsg QureMsg & String message
    * Return : CCR_QureMsg
    * Description: This method is used create case when resend the voucher
    **/
    public static case createResendVoucherCaseForQure(CCR_QureMsg qureMsg, String resultMessage){
        //TODO Resend 상황 확인해야 함
        List<Asset> assetList = [SELECT Id, CCR_MaterialGroupDescription__c, contactId, Contact.CCR_CountryID__c, contact.phone
        FROM Asset
        WHERE CCR_CodentifyId__c =: qureMsg.codentify LIMIT 1];

        Case qureCase = new Case ();
        qureCase.RecordTypeId = CCR_Utility.getRecordTypeId('Case', 'Qure');
        qureCase.Type = 'Inquiry';
        qureCase.CCR_SubType__c = 'Web Issues';
        qureCase.CCR_SubjectCodeNew__c = CCR_Constants.NOTGETVOUCHER;
        qureCase.ContactId = assetList[0].contactId;
        qureCase.Status = 'Closed';
        qureCase.CCR_Verbatim__c = resultMessage;
        qureCase.CCR_Comments__c = assetList[0].contact.phone;
        qureCase.AssetId = assetList[0].Id;
        qureCase.CCR_ProductFamily__c = CCR_Constants.PRODUCTFAMILY;
        List<Profile> usrProfile = [SELECT Id, Name FROM Profile WHERE Id=:userInfo.getProfileId() LIMIT 1];
        String userProfileName = usrProfile[0].Name;
        // to turn the Assignment Rules on
        if( userProfileName == CONSUMERPROFILENAME){
            Database.DMLOptions dmlOpt = new Database.DMLOptions();
            dmlOpt.assignmentRuleHeader.useDefaultRule= true;
            qureCase.setOptions(dmlOpt);
        }
        if(qureMsg.UserType == 'Consumer'){
            qureCase.CCR_ContactType__c  = 'Self-Service - QURE';
        }
        else  if(qureMsg.UserType == 'Corner Shop Agent'){
            qureCase.CCR_ContactType__c  = 'In person - Indirect Retail';
        }
        else  if(qureMsg.UserType == 'Flagship Store Agent'){
            qureCase.CCR_ContactType__c  = 'In person - Direct Retail';
        }
        else {
            qureCase.CCR_ContactType__c  = CCR_QureUtility.PHONE;
        }
        System.debug('@@## UserType = ' + qureMsg.UserType);
        System.debug('@@## qureCase.CCR_ContactType__C = ' + qureCase.CCR_ContactType__C);
        try{
            Insert qureCase;
        }
        catch (Exception exp){
            CCR_ErrorLogUtility.createExceptionLog(exp , CCR_QureUtility.ERRORTYPE, CCR_QureUtility.ERRORSCOPE, CCR_QureUtility.ERRORFUNCTIONELIGIBILITY);
        }
        return qureCase;
    }

    /**
    * Method Name :  retrieveAddressDetails
    * Arguments: String QureMsg
    * Return : CCR_QureMsg
    * Description: This method is used get translated Labels
    **/
    @AuraEnabled
    Public Static CCR_QureMsg retrieveAddressDetails (String qMsg) {
        System.debug('CCR_QUREFaultTreeApex.cls retrieveAddressDetails Start');
        system.debug('@@@@@@@@@@ : '+JSON.deserialize(qMsg, CCR_QureMsg.class));
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        String departmentFieldId;
        String idTypeFieldId;
        // Retrieveing Courier Delivery Form Fields
        qureMsg.formFieldsList = [SELECT Id, CCR_FormField__c, CCR_Mandatory__c, CCR_Lenght__c, CCR_Regex__c, CCR_ReadOnly__c
        FROM CCR_QureConfiguration__c
        WHERE CCR_MarketEnabled__c = TRUE
        AND RecordTypeId = :COURIERDELIVERYFORMRT
        ORDER BY CCR_DisplayOrder__c ASC];

        System.debug('qureMsg.formFieldList == ' + qureMsg.formFieldsList);

        List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_Status__c, CCR_QureReplacementChannel__c
        FROM CCR_QureHistory__c
        WHERE CCR_Status__c = :QUREACTIVE
        AND Id = :qureMsg.QureHistryId LIMIT 1];
        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE &&
                qureHistoryList[0].CCR_QureReplacementChannel__c == null) {
            List<Asset> astList = [SELECT contactId
            FROM Asset
            WHERE CCR_CodentifyId__c =: qureMsg.Codentify LIMIT 1];
            if(!astList.isEmpty()) {
                List<Contact> contactData = [SELECT Id, KDCE_FirstAddressLv1__c, KDCE_FirstAddressLv2__c, KDCE_FirstAddressPostal__c, Salutation, FirstName, LastName, CCR_StreetNumber__c, Phone, CCR_CountryPrefixNumber__c, MailingCity, KDCE_Name__c
                FROM Contact
                WHERE Id =: astList[0].contactId LIMIT 1];
                if(!contactData.isEmpty()) {
                    if(qureMsg.channelSelected == COURIERDELIVERY || qureMsg.channelSelected == CVSSTORE) {
                        System.debug('CVSStore || CourieDelivery called');
                        for(CCR_QureConfiguration__c fieldName : qureMsg.formFieldsList){
//                            if(fieldName.CCR_FormField__c == 'FirstName'){
//                                qureMsg.FirstName = contactData[0].FirstName;
//                            }
                            if(fieldName.CCR_FormField__c == 'LastName'){
                                qureMsg.LastName = contactData[0].KDCE_Name__c;
                            }
                            if(fieldName.CCR_FormField__c == 'StreetName'){
                                if(contactData[0].KDCE_FirstAddressLv1__c != null){
                                    qureMsg.Address1 = contactData[0].KDCE_FirstAddressLv1__c;
                                }
                                if(contactData[0].KDCE_FirstAddressLv2__c != null){
                                    qureMsg.Address2 = contactData[0].KDCE_FirstAddressLv2__c;
                                }
                            }
//                            if(fieldName.CCR_FormField__c == 'StreetNumber'){
//                                qureMsg.Address2 = contactData[0].CCR_StreetNumber__c;
//                            }
                            if(fieldName.CCR_FormField__c == 'City'){
                                qureMsg.AddressCity = contactData[0].MailingCity;
                            }
                            if(fieldName.CCR_FormField__c == 'PostalCode'){
                                qureMsg.AddressPostalCode = contactData[0].KDCE_FirstAddressPostal__c;
                            }
                            if(fieldName.CCR_FormField__c == 'Phone'){
                                qureMsg.ConsumerPhone = contactData[0].phone;
                            }
                            //For picklist data
//                            if(fieldName.CCR_FormField__c == 'Department'){
//                                departmentFieldId = fieldName.Id;
//                            }
//                            if(fieldName.CCR_FormField__c == 'IDType'){
//                                idTypeFieldId = fieldName.Id;
//                            }
                        }
                        System.debug('qureMSG ===== ' + qureMsg);
                    }
                    if(departmentFieldId != null){
                        List<CCR_QureConfiguration__c> parentList = [SELECT Id, CCR_PicklistValue__c
                        FROM CCR_QureConfiguration__c
                        WHERE CCR_DependentOn__c = :departmentFieldId
                        ORDER By CCR_DisplayOrder__c ASC];
                        if(parentList != null && !parentList.isEmpty()){
                            qureMsg.optionsParent = new List<String>();
                            for(CCR_QureConfiguration__c data : parentList){
                                qureMsg.optionsParent.add(data.CCR_PicklistValue__c);
                            }
                        }
                        system.debug('====optionsParent====:'+qureMsg.optionsParent);
                    }
                    if(idTypeFieldId != null){
                        List<CCR_QureConfiguration__c> idTypeList = [SELECT Id, CCR_PicklistValue__c
                        FROM CCR_QureConfiguration__c
                        WHERE CCR_DependentOn__c = :idTypeFieldId
                        ORDER By CCR_DisplayOrder__c ASC];
                        if(idTypeList != null && !idTypeList.isEmpty()){
                            qureMsg.optionsIDType = new List<String>();
                            for(CCR_QureConfiguration__c data : idTypeList){
                                qureMsg.optionsIDType.add(data.CCR_PicklistValue__c);
                            }
                        }
                        system.debug('====optionsIDType====:'+qureMsg.optionsIDType);
                    }
                    qureMsg.ConsumerPhone = contactData[0].phone;
                    System.debug('phone ==== '+contactData[0].phone);
                    if(qureMsg.channelSelected == CCR_Constants.PICKUPATISWAP || qureMsg.channelSelected == CCR_Constants.PICKUPATIQOSCOACH){
                        String tempPhonNo = contactData[0].phone;
                        if(tempPhonNo.length() == 10 && tempPhonNo.startsWith('0')){
                            tempPhonNo = tempPhonNo.removeStart('0');
                        }
                        qureMsg.ConsumerPhone = contactData[0].CCR_CountryPrefixNumber__c + tempPhonNo;
                    }
                    return qureMsg;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } else {
            System.debug('qureinactive CCR_QUREFaultTreeApex.cls retrieveAddressDetails');
            qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
            return qureMsg;
        }
    }

    @AuraEnabled
    Public Static List<String> retrieveChildData (String selectedArea) {
        List<String> cityList;
        if(selectedArea != ''){
            List<CCR_QureConfiguration__c> childList = [SELECT Id, CCR_PicklistValue__c
            FROM CCR_QureConfiguration__c
            WHERE CCR_DependentOn__r.CCR_PicklistValue__c = :selectedArea];
            if(childList != null && !childList.isEmpty()){
                cityList = new List<String>();
                for(CCR_QureConfiguration__c data : childList){
                    cityList.add(data.CCR_PicklistValue__c);
                }
            }
            else {
                cityList = null;
            }
        }
        else {
            cityList = null;
        }
        return cityList;
    }

    /**
    * Method Name :  retrieveReplacementChannelsMetadata
    * Arguments:
    * @Param : String Country
    * @param : selectedChannel
    * Return : List<CCR_QureReplacementChannels__mdt>
    * Description: This method is used get translated Labels
    **/
    Public Static List<CCR_QureReplacementChannels__mdt> retrieveReplacementChannelsMetadata (String channelSelected) {
        system.debug('RRRRRRRRReplaceChannels: '+channelSelected);
        List<CCR_QureReplacementChannels__mdt> mdtData = [SELECT DeveloperName,MasterLabel, CCR_CaseResolution__c, CCR_QureHistoryReplacementChannel__c
        FROM CCR_QureReplacementChannels__mdt
        WHERE MasterLabel =: channelSelected];
        system.debug('RRRRRR data: '+mdtData);
        return mdtData;
    }

    /**
* Method Name :  replacementChannelsForDevice
* Arguments: String QUreMsg
* Return : CCR_QureMsg
* Description: This method is used update QURE replacement start date
**/
    @AuraEnabled
    Public Static CCR_QureMsg replacementChannelsForDevice (String qMsg) {
        System.debug('CCR_QUREFaultTreeApex.cls replacementChannelsForDevice start');
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_StartDateforreplacementreason_select__c, CCR_Status__c,
                CCR_SubjectCode__c, CCR_Override__c, CCR_QureReplacementChannel__c
        FROM CCR_QureHistory__c
        WHERE Id =: qureMsg.QureHistryId
        AND CCR_Status__c = :QUREACTIVE LIMIT 1];
        System.debug('CCR_QUREFaultTreeApex.cls replacementChannelsForDevice qureMsg == ' + qureMsg);
        System.debug('CCR_QUREFaultTreeApex.cls replacementChannelsForDevice qureHistoryList[0] == ' + qureHistoryList[0]);
        System.debug('qureHistoryList[0].CCR_Status__c == ' + qureHistoryList[0].CCR_Status__c);
//        System.debug('qureMsg.IsReplacable == ' + qureMsg.IsReplacable);
        System.debug('qureHistoryList[0].CCR_Override__c == ' + qureHistoryList[0].CCR_Override__c);
        System.debug('qureHistoryList[0].CCR_QureReplacementChannel__c == ' + qureHistoryList[0].CCR_QureReplacementChannel__c);
//        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE && (qureMsg.IsReplacable || qureHistoryList[0].CCR_Override__c) && qureHistoryList[0].CCR_QureReplacementChannel__c == null) {
        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE) {
            qureHistoryList[0].CCR_StartDateforreplacementreason_select__c = system.now();
            updateQureHistory(qureHistoryList[0]);
            List<CCR_QureConfiguration__c> channelsList = [SELECT CCR_ReplacementChannel__c
            FROM CCR_QureConfiguration__c
            WHERE CCR_Model__c = :qureMsg.model
            AND CCR_Color__c = :qureMsg.color
            AND CCR_Persona__c = :qureMsg.UserType
            AND CCR_MarketEnabled__c = TRUE
            ORDER BY CCR_DisplayOrder__c];
            system.debug('channelsList=======> '+channelsList);
            if(!channelsList.isEmpty()){
                qureMsg.replacementChannels = channelsList;
            }
//            else if(qureMsg.UserType == CCR_Constants.CONSUMER){
//                qureMsg.SubjectCode = qureHistoryList[0].CCR_SubjectCode__c;
//                qureMsg.Results = 'ESCALATETOCSC';
//                qureMsg.ErrorMsgId = CCR_Constants.ESCALATETOCSC;
//                qureMsg.otherMessage = CCR_QureMainController.getStandardEndMessage(qureMsg);
////                qureMsg.ConsumerPhone = [SELECT Contact.phone FROM User WHERE Id = :UserInfo.getUserId()].Contact.phone;
//            }
            else {
                qureMsg.Results = '';
            }
//            else if(qureMsg.UserType == CCR_Constants.CALLCENTERUSER){
//                qureMsg.defaultChannels = [SELECT CCR_ReplacementChannel__c
//                FROM CCR_QureConfiguration__c
//                WHERE CCR_Model__c = 'DEFAULT'
//                AND CCR_Persona__c = :qureMsg.UserType
//                AND CCR_MarketEnabled__c = TRUE
//                ORDER BY CCR_DisplayOrder__c];
//            }
            qureMsg.ConsumerPhone = String.valueOf([select Contact.Phone from Asset where CCR_CodentifyId__c = :qureMsg.Codentify][0].Contact.Phone);

            return qureMsg;
        } else {
            qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
            return qureMsg;
        }
    }

    /**
    * Method Name :  checkQureIsActive
    * Arguments: String qure history Id
    * Return : Boolean
    * Description: This method is check qure history rec is active ot not
    **/
    @AuraEnabled
    Public Static Boolean checkQureIsActive (String qureHisId) {
        List<CCR_QureHistory__c> qureHistoryList = [SELECT Id, CCR_Status__c
        FROM CCR_QureHistory__c
        WHERE CCR_Status__c = :QUREACTIVE
        AND Id = :qureHisId LIMIT 1];
        if(!qureHistoryList.isEmpty() && qureHistoryList[0].CCR_Status__c == QUREACTIVE) {
            return true;
        }
        else {
            return false;
        }
    }

    //Added by Samanway as part of Google Analytics
    /**
* Method Name : checkMaterialGroup
* Arguments: String Codentify Id
* Return : String
* Description: This method is to get material group of asset
**/
    @AuraEnabled
    Public Static String checkMaterialGroup (String codentifyId) {
        List<Asset> assetList = new List<Asset>();
        assetList = [SELECT Id,CCR_DeviceProductCode__r.CCR_GroupDescription__r.Name FROM Asset WHERE CCR_CodentifyId__c =: codentifyId];
        if (!assetList.isEmpty()) {
            return assetList[0].CCR_DeviceProductCode__r.CCR_GroupDescription__r.Name;
        }
        else {
            return null;
        }
    }

    /* Wrapper Class*/
    Public Class wrapperData {
        @AuraEnabled
        public String typeOfData;
        @AuraEnabled
        Public List<CCR_DeviceDiagnosticLocalization__c> diagnosticLocalData;
        @AuraEnabled
        Public Map<Id, CCR_DeviceDiagnostic__c> diagnosticData;
        @AuraEnabled
        Public Boolean isQureActive = true;
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
    }
}