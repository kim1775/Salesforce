/**
 * Created by I2MAX on 2021-03-17.
 * QureMain의 클래스.
 * 최초 PreEligibility 판단 및 추가 Eligibility 판단
 */

public without sharing class CCR_QureMainController {

    /**
* Method Name :  callPreEligibility
* Arguments:
* @param: qMsg String
* Return : returnWrapper
* Description: 초기 설정을 위한 메소드KDCE_OriginalWarrantyDate__c
* Results :
**/
    @AuraEnabled
    public static returnWrapper callPreEligibility(String qMsg) {
        CCR_QureMsg qureMsg = new CCR_QureMsg();
        returnWrapper returnValue = new returnWrapper();
        Id otherType,endType;
        try {
            qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);

            for(RecordType recType : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'CCR_DeviceDiagnostic__c' AND DeveloperName IN ('CCR_OtherMessage', 'CCR_EndMessage')]){
                if(recType.DeveloperName == 'CCR_OtherMessage') otherType = recType.Id;
                else endType = recType.Id;
            }

            List<user> currentUser = [SELECT CCR_UserType__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(qureMsg.AccessToken != null && qureMsg.AccessToken != 'undefined')    qureMsg.UserType = 'Consumer';
            else    qureMsg.UserType = currentUser[0].CCR_UserType__c;

            List<Asset> currentDevice = [SELECT Id, ContactId, Contact.CCR_CountryID__c, CCR_OriginalAsset__c, KDCE_fm_WarrantyDate__c, Status, Contact.Phone FROM Asset WHERE CCR_CodentifyId__c = :qureMsg.Codentify];

            if(currentDevice.size() != 1){ // Codentify 가 같은 기기가 있을 수 있나?
                qureMsg.ErrorMsgId = 'Qure Process Is Not Activated';
            }else{
                qureMsg.Market = 'KR';
                if(currentDevice[0].CCR_OriginalAsset__c != null){
                    qureMsg.OriginalCodentify = currentDevice[0].CCR_OriginalAsset__c;
                }
                qureMsg.assetId = currentDevice[0].Id;
                returnValue.assetId = currentDevice[0].Id;
            }

            if(returnValue.assetId != null){

                System.debug('########### qureMsg =');
                System.debug(qureMsg);

                qureMsg = CCR_QurePreEligibility.runPreeligibilitychecksqure(qureMsg);
                System.debug('after runPreeligibility');
                //Added by Raghu as part of CCR-105983
                qureMsg = replacedDeviceCount(qureMsg);
                System.debug('########### pre-eligibility result qureMsg =');
                System.debug(qureMsg);
                System.debug('@@@ quremain called qureMsg' + qureMsg);
                System.debug('@@@ quremain called qureMsg.results = ' + qureMsg.Results);
                System.debug('@@@ quremain called qureMsg.ErrorMsgId = ' + qureMsg.ErrorMsgId);
                System.debug('@@@ quremain called qureMsg.WarningMessageId = ' + qureMsg.WarningMessageId);
                System.debug('@@@ quremain called qureMsg.RplsWarningMsgFlag = ' + qureMsg.RplsWarningMsgFlag);
                System.debug('@@@ quremain called qureMsg.QureHistryId = ' + qureMsg.QureHistryId);

                // 화면에 뿌려야 할 메세지 labelMap으로 담는 부분
                Map <String, String> labelMap = new Map <String, String>();
                for(CCR_DeviceDiagnosticLocalization__c digsRec : [
                        SELECT Id, CCR_DeviceDiagnostic__r.CCR_MessageName__c, CCR_Message__c
                        FROM CCR_DeviceDiagnosticLocalization__c
                        WHERE CCR_Language__c = 'ko'
                        AND CCR_Active__c = true
                        AND CCR_DeviceDiagnostic__r.RecordTypeId = :otherType
                        AND CCR_DeviceDiagnostic__r.CCR_Active__c = true
                ]) {
                    labelMap.put(digsRec.CCR_DeviceDiagnostic__r.CCR_MessageName__c.replace(' ', '_'), digsRec.CCR_Message__c);
                }
                qureMsg.Labels = labelMap;
            }

            if(!String.isEmpty(qureMsg.ErrorMsgId)){
                List<CCR_DeviceDiagnosticLocalization__c> endMessage = [SELECT CCR_Message__c
                FROM CCR_DeviceDiagnosticLocalization__c
                WHERE CCR_Language__c = 'ko'
                AND CCR_Active__c = true
                AND CCR_DeviceDiagnostic__r.RecordTypeId = :endType
                AND CCR_DeviceDiagnostic__r.CCR_MessageName__c = :qureMsg.ErrorMsgId
                AND CCR_DeviceDiagnostic__r.CCR_Active__c = true LIMIT 1];
                if(!endMessage.isEmpty()){
                    returnValue.errorMessage = endMessage[0].CCR_Message__c;
                }else if(qureMsg.ErrorMsgId == 'Qure process is not activated' && qureMsg.UserType != 'Consumer'){
                    returnValue.errorMessage = 'Qure Process Is Not Activated';
                }else {
                    qureMsg.Results = CCR_QureMsg.SYSTEMERROR;
                }
            }

            if(currentDevice[0].Status != 'Active') {
                System.debug('currentDevice[0].status != active');
                System.debug('qureinactive CCR_QUREMainController.cls callPreEligibility');
                qureMsg.Results = CCR_Constants.QUREINACTIVE;
                qureMsg.ErrorMsgId = CCR_Constants.NODIAGNOSISPOSSIBLE;
                qureMsg.WarningMessageId = null;
//                system.debug('nodiagonsisErrorMsgId' + preEligibilityOutCome.ErrorMsgId);
                returnValue.qureMsg = qureMsg;
                System.debug('@@@ quremain called 1');
                return returnValue;
            }

            List<Asset> assList = new List<Asset>(); // for Asset History

            if(currentDevice[0].CCR_OriginalAsset__c != null && currentDevice[0].CCR_OriginalAsset__c != '') {
                assList = [
                        select id, CCR_ReplacementReason__c, Name,CCR_MaterialDescription__c,CCR_ReplacedBy__c,Status,CCR_ReplacedBy__r.Name,
                                CCR_ReplacementDate__c,CCR_ReplacementChannel__c,CCR_ReplacementChannelNew__c,
                                PurchaseDate, CCR_OverrideReason__c
                        from Asset
                        where CCR_OriginalAsset__c = :currentDevice[0].CCR_OriginalAsset__c
                ];
            }

            qureMsg.BlockEndMessage = [select id, CCR_Message__c from CCR_DeviceDiagnosticLocalization__c where CCR_DeviceDiagnostic__r.CCR_MessageName__c = 'UnReplaceable EndMessage' Limit 1][0].CCR_Message__c;

            qureMsg.IsReplacableWarrantyDate = true;
            qureMsg.IsReplacableCarePlus = true;
            qureMsg.IsReplacableByReplaceCount = true;

            Map<String, Integer> assProbMap = new Map<String, Integer>();
            Boolean IsRefundStatus = false;

            // 히터 블레이드 파손 알림
            for(Asset ass : assList) {
                System.debug('==== replace reason == ' + ass.CCR_ReplacementReason__c);
//                assProbMap.put()
                if(assProbMap.containsKey(ass.CCR_ReplacementReason__c)){
                    Integer tmp = assProbMap.get(ass.CCR_ReplacementReason__c);
                    assProbMap.put(ass.CCR_ReplacementReason__c, tmp+1);
                } else {
                    assProbMap.put(ass.CCR_ReplacementReason__c, 1);
                }
                if((ass.CCR_ReplacementReason__c == '히터 블레이드 파손' || ass.CCR_ReplacementReason__c == 'Broken Heating Blade') && ass.Status != CCR_Constants.ASSETACTIVE) {
                    qureMsg.InfoMessageId = 'NotReplacableWithGoodWill';
                    qureMsg.IsReplacableCarePlus = false;
                }
            }
            System.debug('==== assProbMap');
            for(Integer i : assProbMap.values()){
                System.debug('==== i = ' + i);
                if(i >= 3){
                    // 동일 증상 3회 교체
                    IsRefundStatus = true;
                }
            }
            // 보증 기간 만료 알림
            if(currentDevice[0].KDCE_fm_WarrantyDate__c < Date.today()) {
                qureMsg.InfoMessageId = 'NotReplacable';
//                qureMsg.ErrorMsgId = 'Out Of Warranty';
                qureMsg.IsReplacableWarrantyDate = false;
            }
            // 다중 교환 알림
            if(assList.size()>3 && qureMsg.UserType != 'Consumer') {
                qureMsg.InfoMessageId = 'WarningMultipleReplacement';
                qureMsg.IsReplacableByReplaceCount = false;
                // TODO 동일증상 3회 이상 혹은 4회 이상 교체 받은 기기에 대해서는 환불 알림 메세지 처리
                if(assList.size()>4 || IsRefundStatus){
                    qureMsg.InfoMessageId = 'SuggestRefund';
                }
            }
            System.debug('==== qureMsg.InfoMessageId = ' + qureMsg.InfoMessageId);
            System.debug('==== qureMsg.IsReplacableCarePlus = ' + qureMsg.IsReplacableCarePlus);
            System.debug('==== qureMsg.IsReplacableByReplaceCount = ' + qureMsg.IsReplacableByReplaceCount);
            System.debug('==== qureMsg.IsReplacableWarrantyDate = ' + qureMsg.IsReplacableWarrantyDate);

            System.debug('check11111 QureMain call success ');
            System.debug('check11111 assList == ' + assList);
            System.debug('check11111 qureMsg.IsReplacable === ' + qureMsg.IsReplacableWarrantyDate);
            System.debug('check11111 qureMsg.IsReplacable === ' + qureMsg.IsReplacableCarePlus);

            qureMsg.ConsumerPhone = currentDevice[0].Contact.Phone;

            returnValue.replacementDetailsAsset = assList;

            CCR_QureHistory__c qh = [select id, CCR_QureReplacementChannel__c from CCR_QureHistory__c where Id = :qureMsg.QureHistryId];

            // Qure 진입 대상이 Consumer가 아닐 경우 무조건 Diagnostic 부터 돌릴 수 있도록 세팅
            // TODO QURE 진행해서 CVS / 택배를 신청한 케이스는 Agent 도 돌리지 못하도록 막아야 함
//            if(qureMsg.UserType != 'Consumer'){
//                qureMsg.ErrorMsgId = null;
//                qureMsg.WarningMessageId = null;
//                qureMsg.Results = CCR_QureMsg.AGENTRESTART;
//                if(qh.CCR_QureReplacementChannel__c != null && (qh.CCR_QureReplacementChannel__c == 'CVSStore' || qh.CCR_QureReplacementChannel__c == 'CourierDelivery')){
//                    if(qh.CCR_QureReplacementChannel__c == 'CVSStore'){
//                        qureMsg.Results = CCR_QureMsg.OTHERREPLACEMENTCHANNEL;
//                    } else if(qh.CCR_QureReplacementChannel__c == 'CourierDelivery'){
//                        qureMsg.Results = CCR_QureMsg.OTHERREPLACEMENTCHANNEL;
//                        qureMsg.BlockEndMessage = [select id, CCR_Message__c from CCR_DeviceDiagnosticLocalization__c where CCR_DeviceDiagnostic__r.CCR_MessageName__c = 'Online Replacement Channel Selected' Limit 1][0].CCR_Message__c;
//                    }
////                    qureMsg.WarningMessageId = 'CVS Selected';
//
//                }
//            }
            if(qureMsg.UserType != 'Consumer' && qh.CCR_QureReplacementChannel__c != 'CVSStore' && qh.CCR_QureReplacementChannel__c != 'CourierDelivery' && qh.CCR_QureReplacementChannel__c != null) {
                qureMsg.Results = CCR_QureMsg.AGENTRESTART;
//                qureMsg.ErrorMsgId = null;
//                qureMsg.WarningMessageId = null;
            }

            returnValue.qureMsg = qureMsg;
            //returnValue.message = message;
            System.debug('returnValue :: ' + returnValue);
            System.debug('@@@ quremain called 2');
            return returnValue;

        } catch (Exception e) {
            qureMsg.Results = CCR_QureMsg.SYSTEMERROR;
            returnValue.qureMsg = qureMsg;

            if(qureMsg.Labels == null){
                try{
                    if(otherType == null){
                        for(RecordType recType : [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'CCR_DeviceDiagnostic__c' AND DeveloperName = 'CCR_OtherMessage' LIMIT 1]){
                            otherType = recType.Id;
                        }
                    }


                    Map <String, String> labelMap = new Map <String, String>();
                    for(CCR_DeviceDiagnosticLocalization__c digsRec : [SELECT Id, CCR_DeviceDiagnostic__r.CCR_MessageName__c, CCR_Message__c
                    FROM CCR_DeviceDiagnosticLocalization__c
//                    WHERE CCR_Language__c = :qureMsg.Language
                    WHERE CCR_Language__c = 'ko'
                    AND CCR_Active__c = true
//                    WHERE CCR_Active__c = true
                    AND CCR_DeviceDiagnostic__r.RecordTypeId = :otherType
                    AND CCR_DeviceDiagnostic__r.CCR_Active__c = true]) {
                        //System.debug('Id = ' + digsRec.Id + ' ;msgName = '+ digsRec.CCR_DeviceDiagnostic__r.CCR_MessageName__c + ' ;message = ' + digsRec.CCR_Message__c);
                        labelMap.put(digsRec.CCR_DeviceDiagnostic__r.CCR_MessageName__c.replace(' ', '_'), digsRec.CCR_Message__c);
                    }
                    qureMsg.Labels = labelMap;
                }catch(Exception ex){
                    //TODO totaly failed
                    System.debug('Error == ' + ex);
                }
            }
            System.debug('@@@ quremain called 3');
            return returnValue;
        }

    }

    /**
* Method Name :  callEligibility
* Arguments:
* @param: qMsg String
* Return : returnWrapper
* Description: This method is used for calling eligibility
**/
    @AuraEnabled
    public static returnWrapper callEligibility(String qMsg) {
        System.debug('==== callEligibility ====');
        CCR_QureMsg qureMsg = new CCR_QureMsg();
        returnWrapper returnValue = new returnWrapper();
        try{
            qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
            System.debug('qureMsg = ');
            System.debug(qureMsg);
            if(!Test.isRunningTest()) qureMsg.ErrorMsgId = null;
            qureMsg.WarningMessageId = null;

            if(!Test.isRunningTest()) qureMsg = CCR_QureUtility.deviceQureEligibility(qureMsg);

            System.debug('debug!!!! callEligibility called 222222');

            System.debug('qureMsg = ');
            System.debug('@#@# qureMsg == ' + qureMsg);

            if(qureMsg.ErrorMsgId != null){
                    returnValue.errorMessage = getStandardEndMessage(qureMsg);
            }else if(qureMsg.Results == CCR_QureMsg.ESCALATETOCSC){
                System.debug('T00U0HVUDUN964 2');
                if(qureMsg.UserType == 'Consumer')  qureMsg.ErrorMsgId = CCR_Constants.ESCALATETOCSC;
                else                                qureMsg.ErrorMsgId = 'Escalate to CSC Internal';
                returnValue.errorMessage = getStandardEndMessage(qureMsg);
                returnValue.phoneNumber = [SELECT Contact.MobilePhone FROM User WHERE Id = :UserInfo.getUserId()].Contact.MobilePhone;
            }
        }catch(Exception ex){
            qureMsg.Results = 'SYSTEMERROR';
        }

        System.debug('==== callEligibility Result qureMsg == ' + qureMsg);

        // 20210422 테스트 데이터 Start
//        qureMsg.Results = CCR_Constants.ESCALATETOCSC;
        // 20210422 테스트 데이터 End

        returnValue.qureMsg = qureMsg;

        return returnValue;
    }

//Added this method by Raghu as part of CCR-105983
    /**
* Method Name :  getReplacedDeviceCount
* Arguments: CCR_QureMsg
* Return : CCR_QureMsg
* Description: This method is used to get the replaced device count and the flag to display the warning message
**/
    public Static CCR_QureMsg replacedDeviceCount(CCR_QureMsg qureMsg) {
        System.debug('replaceDeviceCount called');
        List<CCR_QureProcess__mdt> qureprocess = [SELECT Id,CCR_GrandType__c, CCR_UserType__c, CCR_Country__c
        FROM CCR_QureProcess__mdt WHERE
        CCR_UserType__c = :qureMsg.UserType AND
        CCR_GrandType__c = :CCR_Constants.SHOWCOUNTWARNING];
        if(qureprocess != null && !qureprocess.isEmpty()) {
            if(qureMsg.OriginalCodentify != null){
                qureMsg.NoOfPastReplacements = [SELECT Count()
                FROM ASSET
                WHERE CCR_OriginalAsset__c = :qureMsg.OriginalCodentify
                AND Status = :CCR_Constants.ASSETREPLACED];
            }
            String marketRplacementRTId = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_MarketReplacement').getRecordTypeId();
            List<CCR_QureConfiguration__c> configureRplsCount = [SELECT CCR_MaxNumberOfReplacementsPerDevice__c
            FROM CCR_QureConfiguration__c
            WHERE RecordtypeID = :marketRplacementRTId
            LIMIT 1];
            if(configureRplsCount != null && !configureRplsCount.isEmpty()){
                if(qureMsg.NoOfPastReplacements >= configureRplsCount[0].CCR_MaxNumberOfReplacementsPerDevice__c){
                    qureMsg.RplsWarningMsgFlag = true;
                }
            }
        }
        return qureMsg;
    }

    /**
* Method Name :  getStandardEndMessage
* Arguments:
* @param: qMsg String
* Return : String
* Description: This method is used for retrieving end message
**/
    @AuraEnabled
    public static String getStandardEndMessage(String qMsg) {
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        return getStandardEndMessage(qureMsg);
    }

    /**
* Method Name :  getStandardEndMessage
* Arguments:
* @param: qMsg CCR_QureMsg
* Return : String
* Description: This method is used for retrieving end message
**/
    public static String getStandardEndMessage(CCR_QureMsg qMsg) {
        System.debug('getStandardEndMessage called  errormsgId ==== ' + qMsg.ErrorMsgId);
        Id endType = [SELECT DeveloperName FROM RecordType WHERE sObjectType = 'CCR_DeviceDiagnostic__c' AND DeveloperName = 'CCR_EndMessage'].Id;
        List<CCR_DeviceDiagnosticLocalization__c> endMessage = [SELECT CCR_Message__c
        FROM CCR_DeviceDiagnosticLocalization__c
//        WHERE CCR_Language__c = :qMsg.Language
        WHERE CCR_Language__c = 'ko'
        AND CCR_Active__c = true
//        WHERE CCR_Active__c = true
        AND CCR_DeviceDiagnostic__r.RecordTypeId = :endType
        AND CCR_DeviceDiagnostic__r.CCR_Active__c = true
        AND CCR_DeviceDiagnostic__r.CCR_MessageName__c = :qMsg.ErrorMsgId];
        System.debug('[CCR_QureMainController.cls] getStandardEndMessage called');
        if(endMessage.size() == 1){
            return endMessage[0].CCR_Message__c;
        }
        return null;
    }

    /**
* Method Name :  escalateToCSC
* Arguments:
* @param: verbatim String
* @param: qMsg CCR_QureMsg
* Return : returnWrapper
* Description: This method is used for creation ecalation case for CSC
**/
    @AuraEnabled
    public static returnWrapper escalateToCSC(String ctPhone, String verbatim, String qMsg){
        returnWrapper wrap = new returnWrapper();
        CCR_QureMsg qureMsg = (CCR_QureMsg) JSON.deserialize(qMsg, CCR_QureMsg.class);
        try{
            List<CCR_QureHistory__c> qureHistory = [SELECT Id, CCR_Device__c, CCR_Case__c, CCR_Device__r.ContactId, CCR_DiagnosticDescription__c,
                    CCR_Status__c,CCR_Device__r.CCR_DeviceProductCode__r.CCR_Version__c FROM CCR_QureHistory__c WHERE Id = :qureMsg.QureHistryId];

            if(qureHistory[0].CCR_Status__c != 'Active'){
                System.debug('qureinactive CCR_QUREMainController.cls escalateToCSC');
                qureMsg.Results = CCR_QureMsg.QUREINACTIVE;
                wrap.qureMsg = qureMsg;
                return wrap;
            }
            Case qureCase;
            String caseType = '';
            if(qureMsg.UserType == 'Consumer')  caseType = 'new';
            else                                caseType = 'Closed';
            qureCase = CCR_QureUtility.createCaseForQure(qureMsg.MaterialGroup, qureMsg.SubjectCode, null, caseType, qureHistory[0].CCR_Device__r.ContactId, qureHistory[0].CCR_Device__c,
                    qureMsg.ResultCode, CCR_Constants.ELIGIBLE, verbatim, qureHistory[0].CCR_DiagnosticDescription__c, qureMsg.UserType,
                    qureHistory[0].CCR_Device__r.CCR_DeviceProductCode__r.CCR_Version__c, true, qureMsg.ConsumerPhone);

            qureHistory[0].CCR_Case__c = qureCase.Id;
            qureHistory[0].KDCE_OtherReason__c = verbatim;
            qureHistory[0].KDCE_QureContactPhone__c = ctPhone;
            (new HistoryUpdator()).updateHistory(qureHistory[0]);

            qureMsg.ErrorMsgId = 'Thanks For Phone';
            if(qureMsg.UserType != 'Consumer')  qureMsg.Results = 'REPLACEMENT';
            System.debug('CCR_QureMainController.cls qureMsg.Results ==== ' + qureMsg.Results);
            wrap.qureMsg =  qureMsg;

            if(!String.isEmpty(qureMsg.ErrorMsgId)){
                Id endType = [SELECT Id FROM RecordType WHERE sObjectType = 'CCR_DeviceDiagnostic__c' AND DeveloperName = 'CCR_EndMessage'].Id;
                wrap.errorMessage = [SELECT CCR_Message__c
                FROM CCR_DeviceDiagnosticLocalization__c
//                WHERE CCR_Language__c = :qureMsg.Language
                WHERE CCR_Language__c = 'ko'
                AND CCR_Active__c = true
//                WHERE CCR_Active__c = true
                AND CCR_DeviceDiagnostic__r.RecordTypeId = :endType
                AND CCR_DeviceDiagnostic__r.CCR_MessageName__c = :qureMsg.ErrorMsgId
                AND CCR_DeviceDiagnostic__r.CCR_Active__c = true LIMIT 1].CCR_Message__c;
            }

        }catch(Exception ex){
            qureMsg.Results = CCR_QureMsg.SYSTEMERROR;
            wrap.qureMsg = qureMsg;

        }
        return wrap;
    }

    /**
* @Class Name  : returnWrapper
* @description : This is wrapper class for return message
*/
    @TestVisible
    private class returnWrapper {
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String assetId;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public CCR_QureMsg qureMsg;
        @AuraEnabled
        public List<Asset> replacementDetailsAsset;
    }

    /**
* @Class Name  : HistoryUpdator
* @description : This is class used for qure history update
*/
    private without sharing class HistoryUpdator{

        /**
* Method Name :  updateHistory
* Arguments:
* @param: history CCR_QureHistory__c
* Return : void
* Description: This method is used for qure history update
**/
        public void updateHistory(CCR_QureHistory__c history){
            update history;
        }
    }
}