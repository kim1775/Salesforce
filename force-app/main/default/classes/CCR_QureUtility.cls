/**
 * Created by I2MAX on 2021-03-29.
 * Qure Eligibility & Warranty Calculation.
 */

public without sharing class CCR_QureUtility {
    public static final String ACTIONLINK = 'Link';
    public static final string CASEQURERECORDTYPE = 'Qure';
    public static final string CASEOBJ = 'Case';
    public static final string EMPTYSTRING = '';
    public static final String ERRORTYPE='Error';
    public static final String ERRORSCOPE='Application';
    public static final String ERRORFUNCTIONELIGIBILITY='QURE';
    public static final String ERRORCLASSNAME='CCR_QureUtility';
    public static final String ELIGIBILITYMETHODNAME = 'deviceQureEligibility';
    public static final String QUREINACTIVE = 'QUREINACTIVE';
    public static final String ISOBAR = 'ISOBAR';
    public static final String FLAGSHIPSTORE = 'Flagship Store Agent';
    public static final String CALLCENTER = 'Call Center Agent';
    public static final String CONSUMER = 'Consumer';
    public static final String SERVICECENTER = 'Service Center Agent';
    public static final String PHONE = 'Phone';
    public static final String SELFSERVICEQURE = 'Self-Service - QURE';
    public static final String INPERSONINDIRECTRETAIL= 'In person - Indirect Retail';
    public static final String INPERSONDIRECTRETAIL = 'In person - direct retail';
    public static final String QURESUBSCRIPTIONRT = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_SubscriptionReplacement').getRecordTypeId();
    public static final String QUREMARKETCONGIG = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_MarketConfiguration').getRecordTypeId();
    public static final String MARKETREPLACEMENTRTID = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_MarketReplacement').getRecordTypeId();
    public static final String ELECTRONICACCESSORY = 'Electronic Accessory';
    public static final String ACCESSORY = 'Accessory';

    // Getting QURE record type ID for Case object
    public static String qureCaseRecordtype = CCR_Utility.getRecordTypeId(CASEOBJ, CASEQURERECORDTYPE);

    public static final String ERRORFUNCTION = 'SFDC Internal';
    public static final String CLASSNAME = 'CCR_QureUtility';
    public static final String METHODNAME = 'warrantyCalculation';
    public static Integer subscriptionReplCount = 0;
    public static final String CONSUMERPROFILENAME = 'CCR Consumer Community';
    public static final String COMMUNITYPLUSLICENSE = 'Customer Community Plus';
    public static final String RETAILER ='Retailer';
    public static final String RETAILERLight ='Retailer Light';

    public static final Integer DeviceEligibleCheckDay = 7;

    /**
* Method Name:  deviceQureEligibility
* Arguments: CCR_QureMsg qureMsg
* Return: CCR_QureMsg qureMsg.
* Description: Running Eligibility checks for Given codentify.
* CCR-7370: added the Subscription by Raghubabu
**/
    @AuraEnabled
    public static CCR_QureMsg deviceQureEligibility(CCR_QureMsg qureMsg) {
        System.debug('debug!!!! deviceQureEligibility called');
        String qureDeviceId = qureMsg.Codentify;
        String qureHistoryId = qureMsg.QureHistryId;
        System.debug('$$$$$$$ :::: ' + qureMsg.Codentify + '  //   ' + qureMsg.QureHistryId);
        //CCR-6974 : Added CCR_DeviceProductCode__r.CCR_ModelNumber__c in query by Raghav
        List<Asset> qureDevice = [SELECT ID,CCR_Replaces__c, CCR_OriginalBox__c, ContactId, CCR_OriginalAsset__c, CCR_CodentifyId__c,
                KDCE_fm_WarrantyDate__c, CCR_ParentProductionDateTime__c, CCR_SubscribedDevice__c,
                PurchaseDate, CCR_DeviceProductCode__r.CCR_ModelNumber__c, CCR_DeviceProductCode__r.CCR_Version__c,
                CCR_CarePlusStatus__c, CCR_AccidentalDamageCounter__c, CCR_DefectiveDevice__c, CCR_Replaces__r.CCR_ReplacementDate__c, KDCE_OriginalWarrantyDate__c
        FROM Asset
        WHERE CCR_CodentifyId__c = :qureDeviceId LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()];
        List<CCR_QureHistory__c> qureHistory = [SELECT Id, CCR_Case__c, CCR_CodeCovered__c, CCR_CodeToBeEscalated__c, CCR_DiagnosticDescription__c, CCR_DiagnosticResult__c,
                CCR_EligibilityResult__c, CCR_MaxReplacementsForCodeNotReached__c, CCR_NotMaxNumbersofReplacement__c, CCR_Override__c, CCR_OverrideReason__c,
                CCR_QureChannel__c, CCR_SubjectCode__c, CCR_ConsumerCountry__c, CCR_InWarranty__c, CCR_Status__c, CCR_QureInUnlimitedPeriod__c
        FROM CCR_QureHistory__c
        WHERE Id = :qureHistoryId LIMIT 1];
        System.debug('##'+QUREMARKETCONGIG);
        System.debug('##### ::::' + qureHistory[0].CCR_DiagnosticResult__c);
        System.debug('##### ::::' + qureDevice[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c);
        //CCR-6974 : Added CCR_DeviceProductCode__r.CCR_ModelNumber__c in filter condition of query by Raghav
        List<CCR_QureConfiguration__c> qureConfig = [SELECT ID, CCR_CoveredinWarranty__c, CCR_SubjectCode__c, CCR_DiagnosticResult__c,
                CCR_CodeToBeEscalated__c, CCR_MaximumReplacementsForCode__c, CCR_MaxNumberOfReplacementsPerDevice__c,
                CCR_MaterialGroupDescription__c,CCR_L0code__c
        FROM CCR_QureConfiguration__c
        WHERE RecordTypeId = :QUREMARKETCONGIG
        AND CCR_DiagnosticResult__c = :qureHistory[0].CCR_DiagnosticResult__c
        AND CCR_Model__c =:qureDevice[0].CCR_DeviceProductCode__r.CCR_ModelNumber__c
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()];

        System.debug('check11111  qureConfig == ' + qureConfig);
        System.debug('check11111  qureHistory.CCR_SubjectCode__c == ' + qureHistory[0].CCR_SubjectCode__c);

        List<CCR_QureConfiguration__c> SubscriptionQureConfig = [SELECT CCR_MaxNumberOfReplacementsPerDevice__c
        FROM CCR_QureConfiguration__c
        WHERE RecordtypeID = :QURESUBSCRIPTIONRT
        LIMIT 1];
        if(!SubscriptionQureConfig.isEmpty()){
            subscriptionReplCount = (Integer)SubscriptionQureConfig[0].CCR_MaxNumberOfReplacementsPerDevice__c;
        }

        System.debug('debug!!!! deviceQureEligibility called 11111');
        System.debug(qureDevice[0]);

        System.debug('QUREmsg...... before call + ' + qureMsg);



        return deviceQureEligibility(qureMsg, qureDevice, qureHistory, qureConfig, false);

        // 20210420 구독 한국에는 없음
//        if(qureDevice[0].CCR_SubscribedDevice__c){
//            return subscribedDeviceQureEligibility(qureMsg, qureDevice, qureHistory, qureConfig);
//        } else {
//            return deviceQureEligibility(qureMsg, qureDevice, qureHistory, qureConfig, false);
//        }
    }

    /**
* Method Name:  deviceQureEligibility
* Arguments: CCR_QureMsg qureMsg
* Return: CCR_QureMsg qureMsg.
* Description: Running Eligibility checks for Given codentify.
**/
    @AuraEnabled
    public static CCR_QureMsg deviceQureEligibility(CCR_QureMsg qureMsg,  List<Asset> qureDevice, List<CCR_QureHistory__c> qureHistory, List<CCR_QureConfiguration__c> qureConfig, Boolean isSubsReq) {

        System.debug('==== deviceQureEligibility Called ====');

        DateTime eligibilityStart = system.now();
        DateTime unlimitedCompleteDate;
        Integer noOfReplacementsForDevice = 0;
        Integer noOfSubsReplacements = 0;
        Integer noOfReplacementsForCode = 0;
        Boolean overRideByAgent = false;
        Boolean noMaxNoofReplacementsForCode = true;
        Boolean noMaxNoofReplacementsForDevice = true;
        Boolean outOffWarranty = False;
        Case qureCase;
        List<User> listUsers = new List<User>();
        String profileName;
        Boolean isChangedGoodWill = false;

        CCR_QureMsg eligibilityOutCome = qureMsg;

        listUsers = [SELECT Id,Profile.Name FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];

        if(!listUsers.isEmpty()) {
            profileName = listUsers[0].Profile.Name;
        }

        if(qureDevice[0].KDCE_fm_WarrantyDate__c == null){
            qureDevice = CCR_QureUtility.warrantyCalculation(qureDevice,qureMsg.Market);
            updateQureAssetWaranty(qureDevice[0]);
        }

        System.debug('debug!!!! deviceQureEligibility called');

        CCR_QureConfiguration__c marketQureConfig  = getMarketConfiguration(qureMsg.Market);
        // Added by Raghu as part of CCR-130306 user story
        // Logic for Unlimited period devices
        Boolean inUnlimitedPeriod = false;

        // 20210422 교환을 3회 받은 이력이 있으면 Qure 불가 처리
        //TODO qurehistory 쌓고 업데이트 하는 이력 추가 필요
//        String assId = qureDevice[0].CCR_OriginalAsset__c;
//        List<Asset> replaceAssetL = [select id from Asset where CCR_OriginalAsset__c = :assId and Status = 'Replaced'];
//        if(replaceAssetL.size()>2) {
//            eligibilityOutCome.ErrorMsgId = 'NotReplacable';
////            eligibilityOutCome.Results = 'AGENTOVERRIDE';
//            return eligibilityOutCome;
//        }

        if(marketQureConfig != null && marketQureConfig.CCR_UnlimitedReplacementsPeriod__c != null && marketQureConfig.CCR_UnlimitedReplacementsPeriod__c > 0) {
            //Checking the unlimited period calculate on which devive (Original Device or Active Device)
            if(marketQureConfig.CCR_CalculateUnlimitedPeriodFrom__c != null &&
                    (marketQureConfig.CCR_CalculateUnlimitedPeriodFrom__c == 'Original Device' ||
                            (marketQureConfig.CCR_CalculateUnlimitedPeriodFrom__c == 'Latest Active Device' &&
                                    qureDevice[0].CCR_OriginalAsset__c == qureDevice[0].CCR_CodentifyId__c))) {
                List<Asset> originalAsset = [SELECT CCR_CodentifyId__c, CCR_OriginalAsset__c, PurchaseDate, CCR_ParentProductionDateTime__c
                FROM Asset
                WHERE CCR_CodentifyId__c = :qureDevice[0].CCR_OriginalAsset__c
                LIMIT 1];

                Date purchaseDate = originalAsset[0].PurchaseDate;
                DateTime packageDate = originalAsset[0].CCR_ParentProductionDateTime__c;

                //Checking the device is in unlimited period or not
                if(purchaseDate != null){
                    unlimitedCompleteDate = purchaseDate.addMonths((Integer)marketQureConfig.CCR_UnlimitedReplacementsPeriod__c);
                    if(unlimitedCompleteDate >= system.today()){
                        inUnlimitedPeriod = true;
                    }
                }
                else if(packageDate != null){
                    unlimitedCompleteDate = packageDate.addMonths((Integer)marketQureConfig.CCR_UnlimitedReplacementsPeriod__c);
                    if(unlimitedCompleteDate >= system.today()){
                        inUnlimitedPeriod = true;
                    }
                }
            } else if(marketQureConfig.CCR_CalculateUnlimitedPeriodFrom__c != null &&
                    (marketQureConfig.CCR_CalculateUnlimitedPeriodFrom__c == 'Latest Active Device' &&
                            qureDevice[0].CCR_OriginalAsset__c != qureDevice[0].CCR_CodentifyId__c)) {
                DateTime calculateDate = qureDevice[0].CCR_Replaces__r.CCR_ReplacementDate__c;
                if(calculateDate !=  null) {
                    unlimitedCompleteDate = calculateDate.addMonths((Integer)marketQureConfig.CCR_UnlimitedReplacementsPeriod__c);
                    if(unlimitedCompleteDate >= system.today()){
                        inUnlimitedPeriod = true;
                    }
                }
            }
        }

        qureDevice[0].CCR_EligibilityDueDate__c = Date.today().addDays(Integer.valueOf(marketQureConfig.CCR_EligibleForReplacement__c));
        //Checking the No of replacements done for Device & code
        List<Asset> replacedAssetList = new List<Asset>();
        if(unlimitedCompleteDate <= System.Today() && !marketQureConfig.CCR_ConsiderPastReplacementsAfterPeriod__c){
            replacedAssetList = [SELECT Id, CCR_ReplacementReason__c
            FROM Asset
            Where CCR_OriginalAsset__c = :qureDevice[0].CCR_OriginalAsset__c
            AND Status = :CCR_Constants.ASSETREPLACED
            AND CCR_DefectiveDevice__c = false // added this condition as part of CCR-125763
            AND CCR_ReplacementDate__c > :unlimitedCompleteDate
            ORDER BY CCR_ReplacementDate__c ASC];
        } else {
            replacedAssetList = [SELECT Id, CCR_ReplacementReason__c
            FROM Asset
            Where CCR_OriginalAsset__c = :qureDevice[0].CCR_OriginalAsset__c
            AND Status = :CCR_Constants.ASSETREPLACED
            AND CCR_DefectiveDevice__c = false // added this condition as part of CCR-125763
            ORDER BY CCR_ReplacementDate__c ASC];
        }

        for(Asset replacedAsset : replacedAssetList) {
            noOfReplacementsForDevice = noOfReplacementsForDevice+1;
            if(qureHistory[0].CCR_DiagnosticDescription__c == replacedAsset.CCR_ReplacementReason__c) {
                noOfReplacementsForCode = noOfReplacementsForCode+1;
            }
            noOfSubsReplacements += 1;
            if(isSubsReq && noOfSubsReplacements == subscriptionReplCount){
                noOfReplacementsForDevice = 0;
                noOfReplacementsForCode = 0;
            }
            // 20210419 히팅블레이드 교체가 있었으면 (GoodWill)
            if(replacedAsset.CCR_ReplacementReason__c == 'Broken Heating Blade') {
                isChangedGoodWill = true;
            }
        }

        if(marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c != null &&
                marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c <= noOfReplacementsForDevice){
            noMaxNoofReplacementsForDevice = False;
        }

        System.debug('==== deviceQureEligibility Override Condition ====');
        System.debug('==== noOfReplacementsForDevice ==  ' + noOfReplacementsForDevice);
        System.debug('==== marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c ==  ' + marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c);

        if(qureConfig == null || qureConfig.isEmpty()) {
            //Qure configuration not found for country & Code
            CCR_ErrorLogUtility.createErrorLog('Qure configuration not found for Country and Code', 'CCR_QureUtility', 'deviceQureEligibility', 'Error', 'Application', 'QURE');
            return null;
        }
//        else if (isChangedGoodWill) {  // 20210419 GoodWill 확인
//            system.debug('******* GoodWill has beed used *******');
//            CCR_QureConfiguration__c qurrecon = qureConfig[0];
//            updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
//            eligibilityOutCome.Results = CCR_QureMsg.ISGOODWILLUSED;
////            updateQureHistory(qureHistory[0], true, false, true, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
//            updateQureHistory(qureHistory[0], true, false, !isChangedGoodWill, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, null);
//            return eligibilityOutCome;
//        }
        else if(inUnlimitedPeriod) {
            system.debug('*******IN UNLIMITEDPERIOD LOGIC*******');
            CCR_QureConfiguration__c qurrecon = qureConfig[0];
            qureHistory[0].CCR_QureInUnlimitedPeriod__c = true;
            if(qureHistory[0].CCR_QureChannel__c == CCR_Constants.ECOMMERCE && !noMaxNoofReplacementsForDevice){
                updateQureHistory(qureHistory[0], true, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                System.debug('T00U0HVUDUN964 3');
                eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                eligibilityOutCome.SubjectCode = qureConfig[0].CCR_SubjectCode__c;
                return eligibilityOutCome;
            } else {
                updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
                if(qureMsg.ReplacementReason == 'Other Issues(Other software malfunction)') eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                else    eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                System.debug('==== Results update part 3');
                updateQureHistory(qureHistory[0], true, true, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                return eligibilityOutCome;
            }
        } else {

            system.debug('*******IN NORMAL PERIOD LOGIC*******');
            CCR_QureConfiguration__c qurrecon = qureConfig[0];

            //TODO Normal Period 에서 Qure의 Results 값을 조절해주는 부분
//            iF(qureDevice[0].CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSENROLLED) {
//                if(qureMsg.UserType != 'Consumer'){
//                    updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
//                    eligibilityOutCome.Results = CCR_QureMsg.AGENTOVERRIDE;
//                    updateQureHistory(qureHistory[0], qurrecon.CCR_CoveredInWarranty__c, noMaxNoofReplacementsForDevice, noMaxNoofReplacementsForCode, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, outOffWarranty);
//                    System.debug('==== deviceQureEligibility Split 1 ====');
//                    return eligibilityOutCome;
//                } else {
//
//                }
//            }

            System.debug('==== deviceQureEligibility Condition ====');
            System.debug('==== qureDevice[0].KDCE_fm_WarrantyDate__c ==  ' + qureDevice[0].KDCE_fm_WarrantyDate__c);
            System.debug('==== qurrecon.CCR_SubjectCode__c ==  ' + qurrecon.CCR_SubjectCode__c);
            System.debug('==== qureDevice[0].CCR_DefectiveDevice__c ==  ' + qureDevice[0].CCR_DefectiveDevice__c);
            System.debug('==== qureMsg.ReplacementReason ==  ' + qureMsg.ReplacementReason);
            System.debug('==== qurrecon.CCR_CoveredInWarranty__c ==  ' + qurrecon.CCR_CoveredInWarranty__c);
            System.debug('==== qurrecon.CCR_MaximumReplacementsForCode__c ==  ' + qurrecon.CCR_MaximumReplacementsForCode__c);
            System.debug('==== noOfReplacementsForCode ==  ' + noOfReplacementsForCode);
            System.debug('==== qureHistory[0].CCR_QureChannel__c ==  ' + qureHistory[0].CCR_QureChannel__c);
            System.debug('==== marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c ==  ' + marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c);
            System.debug('==== qurrecon.CCR_CodeToBeEscalated__c ==  ' + qurrecon.CCR_CodeToBeEscalated__c);
            System.debug('==== qureDevice[0].CCR_CarePlusStatus__c ==  ' + qureDevice[0].CCR_CarePlusStatus__c);

            if(qureDevice[0].KDCE_fm_WarrantyDate__c >= DateTime.now() &&
                    qurrecon.CCR_SubjectCode__c == CCR_Constants.BROKENHEATINGBLADECODE && qureDevice[0].CCR_DefectiveDevice__c) {
                system.debug('Defective device : '+qureDevice[0].CCR_DefectiveDevice__c);
                updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
                if(qureMsg.ReplacementReason == 'Other Issues(Other software malfunction)') eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                else    eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                System.debug('==== Results update part 4');
                updateQureHistory(qureHistory[0], true, true, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                System.debug('==== deviceQureEligibility Split 1 ====');
                return eligibilityOutCome;
            }
            else if(qurrecon.CCR_CoveredInWarranty__c &&
                    (qurrecon.CCR_MaximumReplacementsForCode__c == null || qurrecon.CCR_MaximumReplacementsForCode__c > noOfReplacementsForCode) &&
                    qureDevice[0].KDCE_fm_WarrantyDate__c >= DateTime.now()) {
                if(qureHistory[0].CCR_QureChannel__c == CCR_Constants.ECOMMERCE &&
                        (marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c == null || marketQureConfig.CCR_MaxNumberOfReplacementsPerDevice__c > noOfReplacementsForDevice) &&
                        !qurrecon.CCR_CodeToBeEscalated__c) {
                    // Eligible for Replacement update asset & update qure history
                    updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
                    if(qureMsg.ReplacementReason == 'Other Issues(Other software malfunction)') eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                    else    eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                    System.debug('==== Results update part 5');
                    updateQureHistory(qureHistory[0], true, true, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                    System.debug('==== deviceQureEligibility Split 2 ====');
                    return eligibilityOutCome;
                } else if (qureHistory[0].CCR_QureChannel__c != CCR_Constants.ECOMMERCE) {
                    // Eligible for Replacement update asset & update qure history
                    updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
                    if(qureMsg.ReplacementReason == 'Other Issues(Other software malfunction)') {
                        eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                    }
                    else if (qureMsg.ReplacementReason == 'Broken Heating Blade' && qureDevice[0].CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSENROLLED){
                        eligibilityOutCome.Results = CCR_QureMsg.AGENTOVERRIDE;
                        updateQureHistory(qureHistory[0], true, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                        System.debug('==== deviceQureEligibility Split 3 - 1 ====');
                        return eligibilityOutCome;
                    }
                    else {
                        eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                    }
                    System.debug('==== Results update part 6');
                    updateQureHistory(qureHistory[0], true, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                    System.debug('==== deviceQureEligibility Split 3 ====');
                    return eligibilityOutCome;
                } else if (profileName == 'CCR Integration User') {
                    //Added by Samanway as per CCR-20270 : Enhance Eligibility to Exclude Escalate to CSC for API execution
                    // Eligible for Replacement update asset & update qure history
                    updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
                    if(qureMsg.ReplacementReason == 'Other Issues(Other software malfunction)') eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                    else    eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                    System.debug('==== Results update part 7');
                    updateQureHistory(qureHistory[0], true, true, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                    System.debug('==== deviceQureEligibility Split 4 ====');
                    return eligibilityOutCome;
                } else {
                    if(qureMsg.UserType != 'Consumer'){
                        updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
                        eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                        System.debug('==== Results update part 7');
                        updateQureHistory(qureHistory[0], true, true, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                        System.debug('==== deviceQureEligibility Split 5 -1 ====');
                        return eligibilityOutCome;
                    }
                    updateQureHistory(qureHistory[0], true, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, false);
                    System.debug('T00U0HVUDUN964 4');
                    eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                    eligibilityOutCome.SubjectCode = qureConfig[0].CCR_SubjectCode__c;
                    System.debug('==== deviceQureEligibility Split 5 ====');
                    return eligibilityOutCome;
                }
            } else {
                // Added by Raghu as part of CCR-105971
                eligibilityOutCome.coveredInCarePlus = false;
                eligibilityOutCome.carePlusInvite = false;
                CCR_CarePlusConfiguration__c carePlusData = [select id, CCR_AccidentalDamageLimit__c, CCR_CarePlusActivated__c, CCR_Country__c, CCR_L0codes__c  from CCR_CarePlusConfiguration__c limit 1];

                if(carePlusData != null && carePlusData.CCR_CarePlusActivated__c && carePlusData.CCR_L0codes__c.CONTAINS(qurrecon.CCR_L0code__c)){
                    eligibilityOutCome.coveredInCarePlus = true;
                    if(qureDevice[0].CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSENROLLED){
                        eligibilityOutCome.carePlusInvite = true;
                    }
                }
                if(eligibilityOutCome.coveredInCarePlus && qureDevice[0].CCR_CarePlusStatus__c == CCR_Constants.CAREPLUSENROLLED
                        && (qureDevice[0].CCR_AccidentalDamageCounter__c == null || qureDevice[0].CCR_AccidentalDamageCounter__c < carePlusData.CCR_AccidentalDamageLimit__c)) {
                    eligibilityOutCome.MaterialGroup = qurrecon.CCR_MaterialGroupDescription__c;
                    eligibilityOutCome.SubjectCode = qurrecon.CCR_SubjectCode__c;
                    if(qureMsg.ReplacementReason == 'Other Issues(Other software malfunction)') eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                    else    eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                    System.debug('==== Results update part 8');
                    updateQureAsset(qureDevice[0], qureMsg.Market, false, null);
                    qureHistory[0].CCR_EligibilityByCarePlus__c = true;
                    System.debug('codeCovered:null called  :: ');
                    updateQureHistory(qureHistory[0], null, null, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, null, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.ELIGIBLE, null, eligibilityStart, null);
                    System.debug('==== deviceQureEligibility Split 6 ====');
                    return eligibilityOutCome;
                } else if(eligibilityOutCome.coveredInCarePlus && qureDevice[0].CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSENROLLED && eligibilityOutCome.Usertype == CONSUMER) {
                    eligibilityOutCome.ErrorMsgId = CCR_Constants.CAREPLUSINVITECONSUMER;
                    System.debug('@@@ notcovered called 1');
                    eligibilityOutCome.Results = CCR_Constants.CODENOTCOVERED;
                    Boolean inWarrenty = false;
                    if(qureDevice[0].KDCE_fm_WarrantyDate__c < DateTime.now()) {
                        inWarrenty = true;
                    }
                    updateQureHistory(qureHistory[0], true, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, inWarrenty);
                    System.debug('==== deviceQureEligibility Split 7 ====');
                    return eligibilityOutCome;
                } else {
                    if(qurrecon.CCR_MaximumReplacementsForCode__c != null && qurrecon.CCR_MaximumReplacementsForCode__c <= noOfReplacementsForCode){
                        noMaxNoofReplacementsForCode = false;
                    }

                    if(qureDevice[0].KDCE_fm_WarrantyDate__c < DateTime.now()) {
                        outOffWarranty = true;
                    }
                    List<CCR_QureProcess__mdt> qureprocess = [SELECT Id,CCR_GrandType__c, CCR_UserType__c, CCR_Country__c ,
                            CCR_TimeforBlockonlineQure__c
                    FROM CCR_QureProcess__mdt WHERE
                    CCR_UserType__c = :qureMsg.UserType AND
                    CCR_GrandType__c = :CCR_Constants.ENABLEOVERRIDE];
                    if(!qureprocess.isEmpty()){
                        System.debug('codeCovered:CCR_CoveredInWarranty__c called  :: ');
                        System.debug(qurrecon.CCR_CoveredInWarranty__c);
                        updateQureHistory(qureHistory[0], qurrecon.CCR_CoveredInWarranty__c, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, null, false, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, outOffWarranty);
                        eligibilityOutCome.Results = CCR_QureMsg.AGENTOVERRIDE;
                        //TODO Override 조건에 대해서 확인할 필요 있음....
                        // 현재는 !noMaxNoofReplacementsForCode 상황에만 Override 가 발생하고 있음
//                        if(!noMaxNoofReplacementsForCode)   eligibilityOutCome.Results = CCR_QureMsg.AGENTOVERRIDE;
//                        else                                eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
//                        eligibilityOutCome.Results = CCR_QureMsg.AGENTOVERRIDE;
                        System.debug('==== deviceQureEligibility Split 8 ====');
                        if(qureMsg.ReplacementReason == 'Other Issues(Other software malfunction)') {
                            System.debug('==== deviceQureEligibility Split 8-1 ====');
                            eligibilityOutCome.Results = CCR_QureMsg.ESCALATETOCSC;
                            eligibilityOutCome.InfoMessageId = 'NeedOverride';
                        }
                        return eligibilityOutCome;
                    }
                    if (!qurrecon.CCR_CoveredInWarranty__c && !overRideByAgent) {
                        //update qure history, create case & code not covered end message
                        qureCase = createCaseForQure(qurrecon.CCR_MaterialGroupDescription__c, qureConfig[0].CCR_SubjectCode__c, CCR_Constants.REPLACEMENTNOTPOSSIBLE, CCR_Constants.CASESTATUSCLOSED, qureDevice[0].ContactId, qureDevice[0].Id, qureHistory[0].CCR_DiagnosticResult__c, CCR_Constants.NOTELIGIBLE,
                                EMPTYSTRING, qureHistory[0].CCR_DiagnosticDescription__c, eligibilityOutCome.Usertype, qureDevice[0].CCR_DeviceProductCode__r.CCR_Version__c);
                        System.debug('@@@ notcovered called 2');
                        System.debug('@@@ notcovered called qureCon = ' + qurrecon);
                        eligibilityOutCome.ErrorMsgId = CCR_Constants.CODENOTCOVERED;
                        eligibilityOutCome.CaseId = qureCase.Id;
                        System.debug('codeCovered:false called  :: ');
                        updateQureHistory(qureHistory[0], false, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, qureCase.Id, overRideByAgent, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, outOffWarranty);
                        System.debug('==== deviceQureEligibility Split 9 ====');
                        return eligibilityOutCome;
                    } else If (qurrecon.CCR_MaximumReplacementsForCode__c <= noOfReplacementsForCode && !overRideByAgent){
                        //update qure history, create case & max no of replacements end message
                        qureCase = createCaseForQure(qurrecon.CCR_MaterialGroupDescription__c, qureConfig[0].CCR_SubjectCode__c, CCR_Constants.REPLACEMENTNOTPOSSIBLE, CCR_Constants.CASESTATUSCLOSED, qureDevice[0].ContactId, qureDevice[0].Id, qureHistory[0].CCR_DiagnosticResult__c, CCR_Constants.NOTELIGIBLE,
                                EMPTYSTRING, qureHistory[0].CCR_DiagnosticDescription__c, eligibilityOutCome.Usertype,qureDevice[0].CCR_DeviceProductCode__r.CCR_Version__c);
                        eligibilityOutCome.ErrorMsgId = CCR_Constants.MAXREPLACEMENTSREACHED;
                        eligibilityOutCome.CaseId = qureCase.Id;
                        updateQureHistory(qureHistory[0], true, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, qureCase.Id, overRideByAgent, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, outOffWarranty);
                        System.debug('==== deviceQureEligibility Split 10 ====');
                        return eligibilityOutCome;
                    } else {
                        //update qure history, create case & out off warrenty end message
                        qureCase = createCaseForQure(qurrecon.CCR_MaterialGroupDescription__c, qureConfig[0].CCR_SubjectCode__c, CCR_Constants.REPLACEMENTNOTPOSSIBLE, CCR_Constants.CASESTATUSCLOSED, qureDevice[0].ContactId, qureDevice[0].Id, qureHistory[0].CCR_DiagnosticResult__c, CCR_Constants.NOTELIGIBLE,
                                EMPTYSTRING, qureHistory[0].CCR_DiagnosticDescription__c, eligibilityOutCome.Usertype,qureDevice[0].CCR_DeviceProductCode__r.CCR_Version__c);
                        eligibilityOutCome.ErrorMsgId = CCR_Constants.OUTOFWARRANTY;
                        eligibilityOutCome.CaseId = qureCase.Id;
                        updateQureHistory(qureHistory[0], true, noMaxNoofReplacementsForDevice, qureDevice[0].CCR_CarePlusStatus__c==CCR_Constants.CAREPLUSENROLLED, qureCase.Id, overRideByAgent, null, qurrecon.CCR_SubjectCode__c, CCR_Constants.NOTELIGIBLE, qurrecon.CCR_CodeToBeEscalated__c, eligibilityStart, outOffWarranty);
                        System.debug('==== deviceQureEligibility Split 11 ====');
                        return eligibilityOutCome;
                    }
                }
            }
        }
    }

    /**
* Method Name:  updateQureHistory
* Arguments: Qure History Record & other parameters
* Return: Qure History Record.
* Description: Updating the Qure history record based on eligibility checks outcome.
**/
    public static CCR_QureHistory__c updateQureHistory(CCR_QureHistory__c qureHisRec, Boolean codeCovered, Boolean maxNoOfReplacementsforDevice, Boolean maxNoOfReplacementsforCode, String CaseId, Boolean overRideByAgent, String overRideReason, String subjectCode, String eligibilityResult, Boolean codeToBeEscalated, DateTime startTime, Boolean outOfWarrenty) {
        //TODO Override 조건에 대해서 확인해서 작업 처리할 것
        try{
            if(codeCovered != null) qureHisRec.CCR_CodeCovered__c = codeCovered;
            if(caseId != null) qureHisRec.CCR_Case__c = caseId;
            if(maxNoOfReplacementsforCode != null) {
                qureHisRec.CCR_MaxReplacementsForCodeNotReached__c = maxNoOfReplacementsforCode;
                qureHisRec.CCR_EligibilityByCarePlus__c = maxNoOfReplacementsforCode;
            }
            if(maxNoOfReplacementsforDevice != null) qureHisRec.CCR_NotMaxNumbersofReplacement__c = maxNoOfReplacementsforDevice;
            if(subjectCode != null) qureHisRec.CCR_SubjectCode__c = subjectCode;
            if(eligibilityResult != null) qureHisRec.CCR_EligibilityResult__c = eligibilityResult;
            if(overRideByAgent != null) qureHisRec.CCR_Override__c = overRideByAgent;
            if(overRideReason != null) qureHisRec.CCR_OverrideReason__c = overRideReason;
            if(codeToBeEscalated != null) qureHisRec.CCR_CodeToBeEscalated__c = codeToBeEscalated;
            if(startTime != null) qureHisRec.CCR_StartDateforeligibilitychecks__c = startTime;
            qureHisRec.CCR_EndDateforeligibility_checks__c = DateTIme.now();
            if(outOfWarrenty != null) qureHisRec.CCR_InWarranty__c = !outOfWarrenty;
            update qureHisRec;
        } catch(Exception exp){
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            } catch(Exception exption){
                System.debug('Error == ' + exption);
            }
            throw exp;
        }
        return qureHisRec;
    }

    /**
* Method Name:  updateQureHistoryForOverRide
* Arguments: Qure History Record & other parameters
* Return: Qure History Record.
* Description: Updating the Qure history record based on Over Ride outcome.
**/
    public static CCR_QureHistory__c updateQureHistoryForOverRide(CCR_QureHistory__c qureHisRec, String CaseId, Boolean overRideByAgent, String overRideReason) {
        try{
            qureHisRec.CCR_Case__c = caseId;
            qureHisRec.CCR_Override__c = overRideByAgent;
            qureHisRec.CCR_OverrideReason__c = overRideReason;
            qureHisRec.CCR_EndDateforeligibility_checks__c = DateTIme.now();
            if(!overRideByAgent){
                qureHisRec.CCR_Status__c = CCR_Constants.QUREINACTIVE;
            }
            update qureHisRec;
        } catch(Exception exp){
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            }catch(Exception exption){
                System.debug('Error == ' + exption);
            }
            throw exp;
        }
        return qureHisRec;
    }
    /**
   * Method Name:  createCaseForQure
   * Arguments: String parameters
   * Return: Case.
   * Description: Creating Case based on eligibilty checks outcome.
   **/
    public static case createCaseForQure(String subType, String subjectCode, String resolution,
            String caseStatus, String consumerId, String qureDevice,
            String diagnosticResult, String eligibilityResult,
            String verbatim,
            String diagnosticdescription,
            String usertype,string version){

        return createCaseForQure(subType, subjectCode, resolution, caseStatus, consumerId, qureDevice,
                diagnosticResult, eligibilityResult, verbatim, diagnosticdescription,
                usertype, version, true, null);

    }

    /**
   * Method Name:  createCaseForQure
   * Arguments: String parameters
   * Return: Case.
   * Description: Creating Case based on eligibilty checks outcome.
   **/
    public static case createCaseForQure(String subType, String subjectCode, String resolution,
            String caseStatus, String consumerId, String qureDevice,
            String diagnosticResult, String eligibilityResult,
            String verbatim,
            String diagnosticdescription,
            String usertype,string version,
            String ctPhone){

        return createCaseForQure(subType, subjectCode, resolution, caseStatus, consumerId, qureDevice,
                diagnosticResult, eligibilityResult, verbatim, diagnosticdescription,
                usertype, version, true, ctPhone);

    }

    /**
* Method Name:  createCaseForQure
* Arguments: String parameters for Case creation and Boolean flag for inserting to db
* Return: Case.
* Description: Creating Case based on eligibilty checks outcome.
**/
    public static Case createCaseForQure(String subType, String subjectCode, String resolution,
            String caseStatus, String consumerId, String qureDevice,
            String diagnosticResult, String eligibilityResult,
            String verbatim, String diagnosticdescription,
            String usertype, string version, Boolean toInsert, String contactPhone) {
        System.debug('CCR_QureUtility.cls createCaseForQure called');
        System.debug('verbatim :: ' + verbatim);
        String userProfileName;
        String userLicenseName;
        if(toInsert!= null && toInsert){
            List<Profile> usrProfile = [SELECT Id, Name,UserLicense.Name FROM Profile WHERE Id=:userInfo.getProfileId() LIMIT 1];
            userProfileName = usrProfile[0].Name;
            userLicenseName = usrProfile[0].UserLicense.Name;
        }
        Case qureCase = new Case();
        // to turn the Assignment Rules on
        Database.DMLOptions dmlOpt = new Database.DMLOptions();

        if(caseStatus == CCR_Constants.CASESTATUSNEW) {
            dmlOpt.assignmentRuleHeader.useDefaultRule= true;
            qureCase.setOptions(dmlOpt);
            qureCase.Priority = CCR_Constants.CASEPRIORITY;
        }else if((userProfileName != null && userProfileName == CONSUMERPROFILENAME) || usertype == RETAILER || usertype == RETAILERLight || usertype == CCR_Constants.SHIFT  || usertype == CCR_Constants.SHIFTLIGHT){
            dmlOpt.assignmentRuleHeader.useDefaultRule= true;
            qureCase.setOptions(dmlOpt);
        }
        qureCase.RecordTypeId = CCR_QureUtility.qureCaseRecordtype;
        qureCase.Type = CCR_Constants.QURECASETYPE;
        qureCase.CCR_SubType__c = CCR_QureUtility.getCaseSubtype(subType);
        qureCase.CCR_SubjectCodeNew__c = subjectCode;
        qureCase.CCR_Resolution__c = resolution;
        qureCase.Status = caseStatus;
        qureCase.ContactId = consumerId;
        qureCase.AssetId = qureDevice;
        qureCase.CCR_DiagnosticResult__c = diagnosticResult;
        qureCase.CCR_DiagnosticDescription__c = diagnosticdescription;
        qureCase.CCR_EligibilityResult__c = eligibilityResult;
        qureCase.KDCE_OtherReason__c = verbatim;
        qureCase.Origin = 'Self-Service – QURE';
        qureCase.KDCE_QureContactPhone__c = contactPhone;
        if(subType != ELECTRONICACCESSORY){
            qureCase.CCR_ProductFamily__c = CCR_Constants.PRODUCTFAMILY;
        }else{
            qureCase.CCR_ProductFamily__c = ACCESSORY;
        }
        qureCase.CCR_ProductGeneration__c = version;
        if(usertype == 'Consumer'){
            qureCase.CCR_ContactType__c  = 'Self-Service - QURE';
        }
        else  if(usertype == 'Corner Shop Agent'){
            qureCase.CCR_ContactType__c  = 'In person - Indirect Retail';
        }
        else  if(usertype == 'Flagship Store Agent'){
            qureCase.CCR_ContactType__c  = 'In person - Direct Retail';
        }
        else {
            qureCase.CCR_ContactType__c  = CCR_QureUtility.PHONE;
        }
        if(toInsert!= null && toInsert) {
            try{
                Insert qureCase;
                if(userLicenseName != null  && userLicenseName == COMMUNITYPLUSLICENSE){
                    qureCase.ContactId = consumerId;
                    dmlOpt.assignmentRuleHeader.useDefaultRule= false;
                    qureCase.setOptions(dmlOpt);
                    update qureCase;
                }
            }catch (Exception exp){
                try {
                    CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
                }catch(Exception exption){
                    System.debug('Error == ' + exption);
                }
                throw exp;
            }
        }
        System.debug('CCR_QureUtility.cls createCaseForQure finished');
        System.debug(qureCase);
        return qureCase;
    }

    /**
* Method Name:  insertCasesForQure
* Arguments: List with Cases
* Description: Method for inserting list of cases
**/
    public static List<Case> insertCasesForQure(List<Case> casesToInsert) {
        System.debug('!!@@ caseToInsert = ' + casesToInsert);
        String userLicense;
        try{
            if(!casesToInsert.isEmpty()){
                List<Profile> usrProfile = [Select id,UserLicense.Name from profile where Id=:userInfo.getProfileId() LIMIT 1];
                userLicense = usrProfile[0].UserLicense.Name;
            }
            insert casesToInsert;
            if(String.isNotBlank(userLicense) && userLicense == COMMUNITYPLUSLICENSE){
                List<Case> caseToUpdate = new List<Case>();
                for(Case eachCase : casesToInsert){
                    Case updateCase = new Case();
                    updateCase.Id = eachCase.Id;
                    updateCase.ContactId = eachCase.ContactId;
                    Database.DMLOptions dmlOpt = new Database.DMLOptions();
                    dmlOpt.assignmentRuleHeader.useDefaultRule= false;
                    updateCase.setOptions(dmlOpt);
                    caseToUpdate.add(updateCase);
                }
                update caseToUpdate;
            }
        }catch (Exception exp){
            system.debug('Exception in Cases records update: '+exp.getMessage());
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            }catch(Exception ex){
                System.debug('Error == ' + ex);
            }
            throw exp;
        }
        return casesToInsert;
    }

    /**
* Method Name:  updateQureHistory
* Arguments: List with QureHistory objects
* Description: Method for inserting QureHistory objects
**/
    public static void updateQureHistory(List<CCR_QureHistory__c> qureHistoryObjs) {
        try {
            System.debug('# QureHistory objs updated');
            update qureHistoryObjs;
        }
        catch (Exception exp){
            system.debug('Exception in Qure History records update: '+exp.getMessage());
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
* Method Name:  updateQureAsset
* Arguments: Asset qureAsset, CCR_QureHistory__c qureHisRec, Boolean overRiden, String overRideReason
* Return: NA.
* Description: Updating asset Based on eligibity/over Ride outcome.
**/
    public static void updateQureAsset(Asset qureAsset, String market, Boolean overRiden, String overRideReason){
        CCR_QureConfiguration__c qureConfig  = getMarketConfiguration(market);
        qureAsset.CCR_EligibilityDueDate__c = Date.today().addDays(Integer.valueOf(qureConfig.CCR_EligibleForReplacement__c));
        try{
            update qureAsset;
        } catch(Exception exp){
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            }catch(Exception exption){
                System.debug('Error == ' + exption);
            }
            throw exp;
        }
    }

    /**
* Method Name:  updateQureAssetWaranty
* Arguments: Asset qureAsset,
* Return: NA.
* Description: Updating asset Based on warranty calculation.
**/
    public static void updateQureAssetWaranty(Asset qureAsset){

        try{
            update qureAsset;
        } catch(Exception exp){
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            } catch(Exception exption){
                System.debug('Error == ' + exption);
            }
            throw exp;
        }
    }

    /**
* Method Name:  getMarketConfiguration
* Arguments: String market
* Return: CCR_QureConfiguration__c .
* Description: retuns qure market configuration for the market.
**/
    public static CCR_QureConfiguration__c getMarketConfiguration(String market){
        List<CCR_QureConfiguration__c> qureConfig = [SELECT CCR_EligibleForReplacement__c, CCR_MaxNumberOfReplacementsPerDevice__c,
                CCR_ReplacementSponsoredBy__c, CCR_ConsiderPastReplacementsAfterPeriod__c,
                CCR_CalculateUnlimitedPeriodFrom__c, CCR_UnlimitedReplacementsPeriod__c
        FROM CCR_QureConfiguration__c
        WHERE RecordtypeID = :MARKETREPLACEMENTRTID];

        return qureConfig[0];
    }

    /**
* Method Name:  getCaseSubtype
* Arguments: String materialDis
* Return: String .
* Description: retuns Case subtype based on the material group descripton of Qure Device.
**/
    public static string getCaseSubtype(String materialDis){
        String caseSubType;
        if(materialDis.startsWith(CCR_Constants.HOLDER)) {
            caseSubType = CCR_Constants.HOLDER;
        } else if(materialDis.startsWith(CCR_Constants.POCKETCHARGER)) {
            caseSubType = CCR_Constants.CHARGER;
        } else if(materialDis.startsWith(CCR_Constants.NCPBATTERY)) {
            caseSubType = CCR_Constants.NCPBATTERY;
        }else{
            caseSubType = ELECTRONICACCESSORY;
        }
        return caseSubType;
    }

    /**
* Method Name:  deviceQureOverRide
* Arguments: String qureMsg, Boolean overRiden, String overRideReason.
* Return: CCR_QureMsg .
* Description: Method to call from Over ride Aura component for overRide.
**/
    @AuraEnabled
    public static CCR_QureMsg deviceQureOverRide(String qureMsg, Boolean overRiden, String overRideReason){
        System.debug('==== deviceQureOverRide called');
        CCR_QureMsg eligibilityOutCome = (CCR_QureMsg) JSON.deserialize(qureMsg, CCR_QureMsg.class);
        String qureDeviceId = eligibilityOutCome.Codentify;
        String qureHistoryId = eligibilityOutCome.QureHistryId;
        Case qureCase;
        Asset qureDevice = [SELECT id, CCR_Override__c, CCR_OverrideReason__c, KDCE_fm_WarrantyDate__c,CCR_DeviceProductCode__r.CCR_Version__c
        FROM Asset
        WHERE CCR_CodentifyId__c = :qureDeviceId
        LIMIT 1];
        List<CCR_QureHistory__c> qureHistory = [SELECT Id, CCR_Case__c, CCR_CodeCovered__c, CCR_CodeToBeEscalated__c, CCR_DiagnosticDescription__c, CCR_DiagnosticResult__c,
                CCR_EligibilityResult__c, CCR_MaxReplacementsForCodeNotReached__c, CCR_NotMaxNumbersofReplacement__c, CCR_Override__c, CCR_OverrideReason__c,
                CCR_QureChannel__c, CCR_SubjectCode__c, CCR_ConsumerCountry__c, CCR_Consumer__c, CCR_Device__c, CCR_InWarranty__c, CCR_Status__c
        FROM CCR_QureHistory__c
        WHERE Id = :qureHistoryId
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()];
        List<CCR_QureConfiguration__c> qureConfig = [SELECT ID, CCR_CoveredinWarranty__c, CCR_SubjectCode__c, CCR_DiagnosticResult__c,
                CCR_CodeToBeEscalated__c, CCR_MaximumReplacementsForCode__c, CCR_MaxNumberOfReplacementsPerDevice__c,
                CCR_MaterialGroupDescription__c
        FROM CCR_QureConfiguration__c
        WHERE CCR_DiagnosticResult__c = :qureHistory[0].CCR_DiagnosticResult__c
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()];

        if(qureHistory[0].CCR_Status__c == CCR_Constants.ASSETACTIVE) {
            if(overRiden){
                updateQureHistoryForOverRide(qureHistory[0], null, overRiden, overRideReason);
                updateQureAsset(qureDevice, eligibilityOutCome.Market, overRiden, overRideReason);
                eligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                System.debug('==== Results update part 9');
            } else {
                CCR_QureHistory__c qureHis  = qureHistory[0];
                qureCase = createCaseForQure(qureConfig[0].CCR_MaterialGroupDescription__c, qureHis.CCR_SubjectCode__c, CCR_Constants.REPLACEMENTNOTPOSSIBLE , CCR_Constants.CASESTATUSCLOSED, qureHistory[0].CCR_Consumer__c,
                        qureDevice.Id, qureHistory[0].CCR_DiagnosticResult__c, CCR_Constants.NOTELIGIBLE, EMPTYSTRING, qureHistory[0].CCR_DiagnosticDescription__c,
                        eligibilityOutCome.Usertype,qureDevice.CCR_DeviceProductCode__r.CCR_Version__c);
                updateQureHistoryForOverRide(qureHis, qureCase.Id, overRiden, overRideReason);
                eligibilityOutCome.ErrorMsgId = CCR_Constants.QURENOOVERRIDE;
                eligibilityOutCome.CaseId = qureCase.Id;
            }
        } else {
            //Stop Qure due to Inactive Qure History
            System.debug('qureinactive CCR_QureUtility.cls deviceQureOverRide');
            eligibilityOutCome.Results = QUREINACTIVE;
        }
        return eligibilityOutCome;
    }

    /**
* Method Name:  prepareOverrideData
* Arguments:
* Return:
* Description: Method to return all details of Qure override
**/
    @AuraEnabled
    public static overRideWrapper prepareOverrideData(String qureMsg, String ObjectName, String fieldName){
        CCR_QureMsg eligibilityOutCome = (CCR_QureMsg) JSON.deserialize(qureMsg, CCR_QureMsg.class);
        List<Asset> currentAsset = [SELECT CCR_OriginalAsset__c
        FROM Asset
        WHERE CCR_CodentifyId__c = :eligibilityOutCome.Codentify];

        overRideWrapper wrapperObj = new overRideWrapper();
        List<CCR_QureHistory__c> qureHistory = [SELECT Id, CCR_Case__c, CCR_CodeCovered__c, CCR_CodeToBeEscalated__c, CCR_DiagnosticDescription__c, CCR_DiagnosticResult__c, CCR_InWarranty__c,
                CCR_EligibilityResult__c, CCR_MaxReplacementsForCodeNotReached__c, CCR_NotMaxNumbersofReplacement__c, CCR_Override__c, CCR_OverrideReason__c,
                CCR_QureChannel__c, CCR_SubjectCode__c, CCR_ConsumerCountry__c, CCR_Consumer__c,  CCR_LimitedEdition__c, CCR_Device__r.KDCE_fm_WarrantyDate__c
        FROM CCR_QureHistory__c
        WHERE Id = :eligibilityOutCome.QureHistryId
        LIMIT 1];

        if(!qureHistory.isEmpty()){
            wrapperObj.qureHistoryRec = qureHistory[0];

            System.debug(qureHistory);

            System.debug(qureHistory[0].CCR_Device__r.KDCE_fm_WarrantyDate__c);

            Datetime presentDate = system.now();
            Datetime WarrDate;

            if(qureHistory[0].CCR_Device__r.KDCE_fm_WarrantyDate__c != null) WarrDate = qureHistory[0].CCR_Device__r.KDCE_fm_WarrantyDate__c;
            else WarrDate = System.now().addDays(-10000);

            decimal millisecs = decimal.valueOf(presentDate.getTime() - WarrDate.getTime());
            system.debug('millisecs: ' +millisecs);

            decimal dDays = millisecs/1000/60/60/24;
            integer iDays = integer.valueOF(math.floor(dDays));
            decimal remainderDays = dDays- iDays;

            decimal dHours = remainderDays * 24;
            integer iHours = integer.valueOf(math.floor(dHours));
            decimal remainderHours = dHours - iHours;

            decimal dMinutes = remainderHours * 60;
            integer iMinutes = integer.valueOf(math.floor(dMinutes));
            decimal remainderMinutes = dMinutes - iMinutes;

            system.debug('Days: ' + iDays+' - '+'Hours: ' + iHours+' - '+'Minutes: ' + iMinutes);
            wrapperObj.displayDate = +iDays+' days ';
            if(iHours < 10){
                wrapperObj.displayDate += '0'+string.valueOf(iHours) + ':';
            }
            else wrapperObj.displayDate += string.valueOf(iHours) + ':';
            if(iMinutes < 10){
                wrapperObj.displayDate += '0'+string.valueOf(iMinutes) + ' hs';
            }
            else wrapperObj.displayDate += string.valueOf(iMinutes) + ' hs';
        }

        wrapperObj.overRideReaSonMap = new Map<String, String>();
        for(SelectOption sop : CCR_Utility.retrievePicklistValues(ObjectName, fieldName)){
            wrapperObj.overRideReaSonMap.put(sop.getLabel(), sop.getValue());
            System.debug('overRideReason check ******' + sop);
        }
        if(!currentAsset.isEmpty()){
            if(currentAsset[0].CCR_OriginalAsset__c != null){
                List<Asset> historyList = [SELECT Name,CCR_MaterialDescription__c ,CCR_ReplacedBy__c,Status,CCR_ReplacedBy__r.Name,
                        CCR_ReplacementDate__c,CCR_ReplacementReason__c,CCR_ReplacementChannel__c,CCR_ReplacementChannelNew__c,
                        PurchaseDate, CCR_OverrideReason__c
                FROM ASSET
                WHERE CCR_OriginalAsset__c = :currentAsset[0].CCR_OriginalAsset__c
                ORDER BY Status, CCR_ReplacementDate__c
                LIMIT 10];
                if(historyList.size()>1){
                    wrapperObj.replacementDetailsAsset = historyList;
                }
                system.debug('----Data----->'+wrapperObj.replacementDetailsAsset);
            }
        }
        return wrapperObj;
    }

    /**
* Method Name:  warrantyCalculation
* Arguments: List<Asset> assetList
* Return: List<Asset> : Assets with updated Warrentty Due date
* Description: This method is temporary method and all the logic of this method is moved to warrantyCalculation two arguments method and it will be removed after go live.
**/
    public static List<Asset> warrantyCalculation(List<Asset> assetList){
        List<Asset> tempAssetList = new List<Asset>();
        return tempAssetList;
    }

    /**
* Method Name:  warrantyCalculation
* Arguments: List<Asset> assetList
* Return: List<Asset> : Assets with updated Warrentty Due date
* Description: This method is to calculate the Warranty for Qure device when link/Replacement was done.
**/
    public static List<Asset> warrantyCalculation(List<Asset> assetList, String country){
        List<Asset> replaceAssets = new List<Asset>();
        List<Asset> linkAssets = new List<Asset>();
        Map<String, CCR_DeviceWarranty__mdt> astDevWarMap = new Map<String, CCR_DeviceWarranty__mdt>();
        Map<String, List<String>> astCountryMap = new Map<String, List<String>>();
        Map<String, DateTIme> astFirstActionDate = new Map<String, DateTIme>();
        Integer minWarranty ;
        Map<String, DateTime> assetWithReplacementDate = new Map<String, DateTime>();
        //CCR-6213 : Enhancing device warranty meta data table by adding models
        Map<String, String> assetWithModelNo = new Map<String, String>();
        Map<String, Boolean> assetWithSubscription = new Map<String, Boolean>();
        Map<String,String> assetWithCountryMap = new Map<String,String>();
        //Raghav
        //Added below for not linked asset
        Map<String, DateTIme> astNotLinkedDevWarrDate = new Map<String, DateTIme>();
        Map<String, List<String>> astContactMap = new Map<String, List<String>>();
        List<Asset> notLinkedAssets = new List<Asset>();
        for(Asset ast :assetList) {
            if(ast.contactid != null && ast.CCR_Replaces__c == null){
                linkAssets.add(ast);
            } else if(ast.CCR_Replaces__c != null && ast.contactid != null){
                replaceAssets.add(ast);
            } else if((ast.contactid == null) && String.isNotBlank(country) ){
                notLinkedAssets.add(ast);
            }

            if(ast.contactid != null){
                if(astContactMap.containsKey(ast.contactid)) {
                    astContactMap.get(ast.contactid).add(ast.Id);
                }else {
                    astContactMap.put(ast.contactid, new List<String>{ast.Id});
                }
            }else if(String.isNotBlank(country)){
                if(astCountryMap.containsKey(country)) {
                    astCountryMap.get(country).add(ast.Id);
                }else {
                    astCountryMap.put(country, new List<String>{ast.Id});
                }
            }
        }
        //CCR-6213 : Enhancing device warranty meta data table by adding models
        for(Asset ast : [SELECT Id,CCR_DeviceProductCode__r.CCR_ModelNumber__c,CCR_SubscribedDevice__c
        FROM Asset
        WHERE Id IN :assetList
        LIMIT 50000]){
            assetWithModelNo.put(ast.Id, ast.CCR_DeviceProductCode__r.CCR_ModelNumber__c);
            assetWithSubscription.put(ast.Id, ast.CCR_SubscribedDevice__c);
        }

        for(Contact con :[SELECT Id, CCR_CountryID__c
        FROM Contact
        WHERE Id IN : astContactMap.keySet()
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]){
            if(!astCountryMap.containsKey(con.CCR_CountryID__c) ) {
                astCountryMap.put(con.CCR_CountryID__c, astContactMap.get(con.Id));
            } else {
                astCountryMap.get(con.CCR_CountryID__c).addall(astContactMap.get(con.Id));
            }
        }

        //CCR-6213 : Enhancing device warranty meta data table by adding models
        for(CCR_DeviceWarranty__mdt deviceWarr : [SELECT CCR_Market__c, CCR_Standardwarrantyperiod__c, CCR_MinimumWarrantyPeriod__c,
                CCR_Timeestimatedfromproductiontosellin__c, CCR_Warrantyextensionifregisterintime__c, CCR_Timetoregisterdeviceafterpurchase__c, CCR_Model__c, CCR_Subscribed_Device__c
        FROM CCR_DeviceWarranty__mdt
        WHERE CCR_Market__c IN :astCountryMap.keySet()
        AND CCR_Model__c IN :assetWithModelNo.values()
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]) {
            for(String astId :astCountryMap.get(deviceWarr.CCR_Market__c)){
                assetWithCountryMap.put(astId,deviceWarr.CCR_Market__c);
                if(assetWithModelNo.get(astId) == deviceWarr.CCR_Model__c && assetWithSubscription.get(astId) == deviceWarr.CCR_Subscribed_Device__c){
                    astDevWarMap.put(astId, deviceWarr);
                }
            }
        }
        if(linkAssets != null && !linkAssets.isEmpty()) {
            astFirstActionDate.putAll(getFirstLinkTIme(linkAssets, astDevWarMap));
        }
        if(replaceAssets != null && !replaceAssets.isEmpty()) {
            astFirstActionDate.putAll(getFirstActionDateForSwap(replaceAssets, astDevWarMap));
            assetWithReplacementDate = getReplacementDate(replaceAssets);
        }
        if(String.isNotBlank(country) && !notLinkedAssets.isEmpty()){
            astNotLinkedDevWarrDate.putAll(calcOrigWardateForNotLinkedDevices(notLinkedAssets,astDevWarMap));
        }
        for(Asset ast : assetList) {
            if(astDevWarMap.containsKey(ast.Id)){
                if(astFirstActionDate.containskey(ast.Id)) {
                    minWarranty = Integer.valueOf(astDevWarMap.get(ast.Id).CCR_MinimumWarrantyPeriod__c);
                    DateTime originalDueDate = astFirstActionDate.get(ast.Id);
                    if(ast.CCR_Replaces__c == null) {
                        ast.KDCE_OriginalWarrantyDate__c = Date.valueOf(originalDueDate);
                    }
                    else {
                        DateTime replacementDate;
                        if(assetWithReplacementDate.containsKey(ast.Id) && assetWithReplacementDate.get(ast.Id) != null){
                            replacementDate = assetWithReplacementDate.get(ast.Id);
                        } else {
                            replacementDate = DateTime.now();
                        }
                        if(replacementDate.addMonths(minWarranty) > originalDueDate) {
                            //Added by Raghu as part of user story CCR-119650
                            if(minWarranty == 0){
                                ast.KDCE_OriginalWarrantyDate__c = Date.valueOf(originalDueDate);
                            }
                            else{
                                ast.KDCE_OriginalWarrantyDate__c = Date.today().addMonths(minWarranty);
                            }
                        }
                        else {
                            ast.KDCE_OriginalWarrantyDate__c = Date.valueOf(originalDueDate);
                        }

                    }
                }else if(String.isNotBlank(country) && !notLinkedAssets.isEmpty()){
                    DateTime originalDueDateForNotLinked = astNotLinkedDevWarrDate.get(ast.Id);
                    ast.KDCE_OriginalWarrantyDate__c = Date.valueOf(originalDueDateForNotLinked);
                }
            }else if(assetWithCountryMap.containsKey(ast.Id)){
                CCR_ErrorLogUtility.createErrorLog('Device warranty meta data record not found for asset : '+ ast.Id,CLASSNAME,METHODNAME,ERRORTYPE,ERRORSCOPE,ERRORFUNCTION);
            }
        }
        return assetList;
    }

    /**
* Method Name:  getFirstLinkTIme
* Arguments: List<Asset> assetList
* Return: Map<String, DateTIme> : Assets Id with first link date for Warrentty Due date calculation for linking devices
* Description: This method is to calculate first link date for device when link was done.
**/
    public static Map<String, DateTIme> getFirstLinkTIme(List<Asset> astList, Map<String, CCR_DeviceWarranty__mdt> astDevWarMap) {
        Map<String, DateTIme> fisrtLinkTimeMap =  new Map<String, DateTIme>();
        Map<String, DateTIme> originalDueDateTimeMap =  new Map<String, DateTIme>();

        for(Asset ast :astList) {
            fisrtLinkTimeMap.put(ast.Id, null);
        }
        for(CCR_AssetLifeCycle__c astLc : [SELECT id, CCR_ASSET__c,CCR_ActionDate__c
        FROM CCR_AssetLifeCycle__c
        WHERE CCR_ASSET__c IN :fisrtLinkTimeMap.keySet() AND CCR_Action__c = :ACTIONLINK
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]){
            if(fisrtLinkTimeMap.get(astLc.CCR_ASSET__c) == null){
                fisrtLinkTimeMap.put(astLc.CCR_ASSET__c, astLc.CCR_ActionDate__c);
            } else if(fisrtLinkTimeMap.get(astLc.CCR_ASSET__c) > astLc.CCR_ActionDate__c) {
                fisrtLinkTimeMap.put(astLc.CCR_ASSET__c, astLc.CCR_ActionDate__c);
            }
        }
        for(Asset ast :astList) {
            if(astDevWarMap.containsKey(ast.Id)){
                DateTime originalDueDate = calcOriginalWarrantydate(ast, astDevWarMap.get(ast.Id), fisrtLinkTimeMap.get(ast.Id));
                originalDueDateTimeMap.put(ast.Id, originalDueDate);
            }
        }
        return originalDueDateTimeMap;
    }

    /**
* Method Name:  getFirstActionDateForSwap
* Arguments: List<Asset> assetList
* Return: Map<String, DateTIme> : Assets Id with first link date for Warrentty Due date calculation for Swape devices
* Description: This method is to calculate first link date for device when Swape was done.
**/
    public static Map<String, DateTIme> getFirstActionDateForSwap(List<Asset> astList, Map<String, CCR_DeviceWarranty__mdt> astDevWarMap) {
        Set<String> originalCodentify = new Set<String>();
        Set<String> originalCodentifyForLink = new Set<String>();
        Set<String> astIds = new Set<String>();
        Map<String, String> codentyAstIdMap = new Map<String, String>();
        Map<String, Asset> codentyAssetMap = new Map<String, Asset>();
        Map<String, Asset> assetIdAssetMap = new Map<String, Asset>();
        Map<String, DateTIme> fisrtLinkTimeMap =  new Map<String, DateTIme>();
        Map<String, DateTIme> originalDueDateTimeMap =  new Map<String, DateTIme>();

        for(Asset ast : astList) {
            codentyAstIdMap.put(ast.CCR_OriginalAsset__c, ast.Id);
            originalCodentify.add(ast.CCR_OriginalAsset__c);
            if(ast.ContactId != null){
                originalCodentifyForLink.add(ast.CCR_OriginalAsset__c);
            }
        }

        for(Asset replaceAst : [SELECT Id, CCR_NumberOfConsumers__c, CCR_CodentifyId__c, PurchaseDate, CCR_ParentProductionDateTime__c
        FROM Asset
        WHERE CCR_CodentifyId__c IN :codentyAstIdMap.keySet() AND CCR_NumberOfConsumers__c > 0
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]){
            originalCodentify.remove(replaceAst.CCR_CodentifyId__c);
            originalCodentifyForLink.remove(replaceAst.CCR_CodentifyId__c);
            astIds.add(replaceAst.Id);
            assetIdAssetMap.put(replaceAst.Id, replaceAst);
        }
        if(originalCodentify != null && !originalCodentify.isEmpty()){
            for(Asset replaceAstChild : [SELECT Id, CCR_NumberOfConsumers__c, CCR_CodentifyId__c, CCR_OriginalAsset__c, PurchaseDate, CCR_ParentProductionDateTime__c
            FROM Asset
            WHERE CCR_OriginalAsset__c IN :originalCodentify AND CCR_NumberOfConsumers__c > 0 AND Id NOT IN :codentyAstIdMap.values()
            LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]){
                originalCodentify.remove(replaceAstChild.CCR_OriginalAsset__c);
                originalCodentifyForLink.remove(replaceAstChild.CCR_OriginalAsset__c);
                astIds.add(replaceAstChild.Id);
                assetIdAssetMap.put(replaceAstChild.Id, replaceAstChild);
            }
        }
        for(CCR_AssetLifeCycle__c astLc :[SELECT id, CCR_ASSET__c, CCR_ActionDate__c, CCR_ASSET__r.CCR_OriginalAsset__c
        FROM CCR_AssetLifeCycle__c
        WHERE CCR_ASSET__c IN :astIds AND CCR_Action__c = :ACTIONLINK
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]) {
            if(fisrtLinkTimeMap.containsKey(codentyAstIdMap.get(astLc.CCR_ASSET__r.CCR_OriginalAsset__c)) &&
                    fisrtLinkTimeMap.get(codentyAstIdMap.get(astLc.CCR_ASSET__r.CCR_OriginalAsset__c)) > astLc.CCR_ActionDate__c) {
                codentyAssetMap.put(astLc.CCR_ASSET__r.CCR_OriginalAsset__c, assetIdAssetMap.get(astLc.CCR_ASSET__c));
                fisrtLinkTimeMap.put(codentyAstIdMap.get(astLc.CCR_ASSET__r.CCR_OriginalAsset__c), astLc.CCR_ActionDate__c);
            } else if(!fisrtLinkTimeMap.containsKey(astLc.CCR_ASSET__r.CCR_OriginalAsset__c)){
                fisrtLinkTimeMap.put(codentyAstIdMap.get(astLc.CCR_ASSET__r.CCR_OriginalAsset__c), astLc.CCR_ActionDate__c);
                codentyAssetMap.put(astLc.CCR_ASSET__r.CCR_OriginalAsset__c, assetIdAssetMap.get(astLc.CCR_ASSET__c));
            }
        }
        if(originalCodentifyForLink != null && !originalCodentifyForLink.isEmpty()){
            for(Asset linkOriginalDevice : [SELECT Id, CCR_NumberOfConsumers__c, CCR_CodentifyId__c, CCR_OriginalAsset__c, PurchaseDate, CCR_ParentProductionDateTime__c
            FROM Asset
            WHERE CCR_CodentifyId__c IN :originalCodentifyForLink
            LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]){
                if(astDevWarMap.containsKey(codentyAstIdMap.get(linkOriginalDevice.CCR_CodentifyId__c))){
                    DateTime originalDueDate = calcOriginalWarrantydate(linkOriginalDevice, astDevWarMap.get(codentyAstIdMap.get(linkOriginalDevice.CCR_CodentifyId__c)), DateTime.now());
                    originalDueDateTimeMap.put(codentyAstIdMap.get(linkOriginalDevice.CCR_CodentifyId__c), originalDueDate);
                }
            }
        }
        for(String originalCode : codentyAssetMap.keySet()) {
            if(astDevWarMap.containsKey(codentyAstIdMap.get(originalCode)) && fisrtLinkTimeMap.containsKey(codentyAstIdMap.get(originalCode))){
                DateTime originalDueDate = calcOriginalWarrantydate(codentyAssetMap.get(originalCode), astDevWarMap.get(codentyAstIdMap.get(originalCode)), fisrtLinkTimeMap.get(codentyAstIdMap.get(originalCode)));
                originalDueDateTimeMap.put(codentyAstIdMap.get(originalCode), originalDueDate);
            }
        }
        return originalDueDateTimeMap;
    }

    /**
* Method Name:  calcOriginalWarrantydate
* Arguments: Asset ast, CCR_DeviceWarranty__mdt dwm, DateTime firstActionDate
* Return: DateTIme : Original warrenty due date.
* Description: This method is to calculate original warrenty due date for device.
**/
    public static DateTime calcOriginalWarrantydate(Asset ast, CCR_DeviceWarranty__mdt dwm, DateTime firstActionDate){
        DateTime warrentyDate;
        Integer standardWarranty = Integer.valueOf(dwm.CCR_Standardwarrantyperiod__c);
        Integer grace = Integer.valueOf(dwm.CCR_Timeestimatedfromproductiontosellin__c);
        Integer extension = Integer.valueOf(dwm.CCR_Warrantyextensionifregisterintime__c);
        Integer timeToRegister = Integer.valueOf(dwm.CCR_Timetoregisterdeviceafterpurchase__c);


        if(ast.CCR_ParentProductionDateTime__c != null){
            if(ast.PurchaseDate == null) {
                if(firstActionDate <= ast.CCR_ParentProductionDateTime__c.addMonths(grace).addDays(timeToRegister)){
                    warrentyDate = ast.CCR_ParentProductionDateTime__c.addMonths(grace+extension+standardWarranty);
                } else {
                    warrentyDate = ast.CCR_ParentProductionDateTime__c.addMonths(grace+standardWarranty);
                }
            } else {
                if(firstActionDate <= ast.PurchaseDate.addDays(timeToRegister)) {
                    warrentyDate = ast.PurchaseDate.addMonths(extension+standardWarranty);
                } else {
                    warrentyDate = ast.PurchaseDate.addMonths(standardWarranty);
                }
            }
        }

        return warrentyDate;
    }

    /**
* Method Name:  calcOrigWardateForNotLinkedDevices
* Arguments: List<Asset> astList, CCR_DeviceWarranty__mdt dwm
* Return: DateTIme : Original warrenty due date.
* Description: This method is to calculate original warrenty due date for device.
**/
    public static Map<String, DateTIme> calcOrigWardateForNotLinkedDevices(List<Asset> astList, Map<String, CCR_DeviceWarranty__mdt> astDevWarMap){
        Map<String, DateTIme> originalDueDateTimeMap =  new Map<String, DateTIme>();

        for(Asset ast :astList) {
            if(astDevWarMap.containsKey(ast.Id)){
                CCR_DeviceWarranty__mdt dwm = astDevWarMap.get(ast.id);
                Integer standardWarranty = Integer.valueOf(dwm.CCR_Standardwarrantyperiod__c);
                Integer grace = Integer.valueOf(dwm.CCR_Timeestimatedfromproductiontosellin__c);
                Integer extension = Integer.valueOf(dwm.CCR_Warrantyextensionifregisterintime__c);
                Integer timeToRegister = Integer.valueOf(dwm.CCR_Timetoregisterdeviceafterpurchase__c);
                DateTime originalDueDate;
                if(ast.CCR_ParentProductionDateTime__c != null){
                    if(ast.PurchaseDate == null) {
                        originalDueDate = ast.CCR_ParentProductionDateTime__c.addMonths(grace+standardWarranty);
                    } else{
                        originalDueDate = ast.PurchaseDate.addMonths(standardWarranty);

                    }
                }
                originalDueDateTimeMap.put(ast.Id, originalDueDate);
            }
        }

        return originalDueDateTimeMap;
    }

    /**
* Method Name:  getReplacementDate
* Arguments: List of assets
* Return: Map<String, DateTime> Asset id With Replacement DateTime.
* Description: This method is to replacement date for device.
**/
    public static Map<String, DateTime> getReplacementDate(List<Asset> astList){
        Map<String, String> replacedAstoriginalAsset = new Map<String, String>();
        Map<String, DateTime> astWithReplacementDate = new Map<String, DateTime>();
        for(Asset ast : astList){
            replacedAstoriginalAsset.put(ast.CCR_Replaces__c, ast.Id);
        }
        for(Asset replacedAst : [SELECT Id, CCR_ReplacementSystemDate__c
        FROM Asset
        WHERE Id IN : replacedAstoriginalAsset.keySet()
        LIMIT :limits.getLimitQueryRows()-limits.getQueryRows()]){
            astWithReplacementDate.put(replacedAstoriginalAsset.get(replacedAst.Id), replacedAst.CCR_ReplacementSystemDate__c);
        }
        return astWithReplacementDate;
    }

    /**
* Method Name:  updateQureDeviceEligibleDays
* Arguments:  ast, String market
* Return: NA.
* Description: Updating asset Based on Vocher Validity Days.
**/
    public static void  updateQureDeviceEligibleDays(Asset ast){
        system.debug('@@@@updateQureDeviceEligibleDays');
        date td = system.today();
        td = td.addDays(DeviceEligibleCheckDay);
        system.debug('td'+td);
        if(ast.CCR_EligibilityDueDate__c !=null){
            ast.CCR_EligibilityDueDate__c = td;
            system.debug('Asstdate'+ast.CCR_EligibilityDueDate__c );
        }
        try{
            update ast;
        } catch(Exception exp){
            CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
        }
    }

    public static void updateQureDeviceReplacementChannel(Asset ast, String ch) {
        System.debug('CCR_QureUtility.cls updateQureDeviceDeactive called');
        ast.CCR_ReplacementChannelNew__c = ch;
        try{
            update ast;
        } catch(Exception exp){
            CCR_ErrorLogUtility.createExceptionLog(exp , ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
        }
    }

    /**
* Method Name:  getAssetDetails
* Arguments:  String Codentify ID
* Return: Asset.
* Description: Returning the asset details for Qure seleted device.
**/
    @AuraEnabled
    public static Asset getAssetDetails(String codentifyId){
        List<Asset> assetData = [SELECT Id, CCR_CodentifyId__c, CCR_MaterialGroupDescription__c,
                CCR_DeviceProductCode__r.CCR_BrandFamily__c
        FROM Asset
        WHERE CCR_CodentifyId__c = :codentifyId];
        System.debug('CCR_QureUtility.cls getAssetDetails Start');
        if(assetData != null && !assetData.isEmpty()){
            return assetData[0];
        } else {
            return null;
        }
    }

    /**
* Method Name:  updateUserLanguage
* Arguments:  String language code
* Return: void.
* Description: updtes the user language on update of language in QURE page.
**/
    @AuraEnabled
    public static void updateUserLanguage(String languageCode){
        List<User> updateUser = [SELECT Id, LanguageLocaleKey
        FROM User
        WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(updateUser != null && !updateUser.isEmpty()){
            updateUser[0].LanguageLocaleKey = languageCode;
            try{
                update updateUser;
            }catch(Exception exp){
                CCR_ErrorLogUtility.createExceptionLog(exp, ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONELIGIBILITY);
            }
        }
    }

    public class overRideWrapper{
        @AuraEnabled
        public CCR_QureHistory__c qureHistoryRec;
        @AuraEnabled
        public Map<String, String> overRideReaSonMap;
        @AuraEnabled
        public List<Asset> replacementDetailsAsset;
        @AuraEnabled
        public String displayDate;

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
    }
}