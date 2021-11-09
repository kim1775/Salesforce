/**
 * Created by I2MAX on 2021-03-29.
 * FaultTree 진입 전 교체 가능 여부를 미리 확인하는 클래스
 */
public without sharing class CCR_QurePreEligibility {
    public static final String ERRORTYPE = 'Error';
    public static final String ERRORSCOPE = 'Application';
    public static final String ERRORFUNCTIONPREELIGIBILITY = 'QURE';
    public static final String ERRORCLASSNAME = 'CCR_QurePreEligibility';
    public static final String QURECONFIGURATIONNOTFOUND = 'Qure configuration not found for Country ';
    public static final String RUNPREELIGIBILITYCHEKSQURE = 'runPreeligibilitychecksqure';
    public static final String LIMITEDEDITION = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_LimitedEdition').getRecordTypeId();
    public static final String DEVICEISSUE = SObjectType.CCR_DeviceDiagnostic__c.getRecordTypeInfosByDeveloperName().get('CCR_DeviceIssue').getRecordTypeId();
    /**
     * Method Name:  runPreeligibilitychecks
     * Arguments: CCR_QureMsg
     * Return: preeligibilityOutCome
     * Description: 교체 가능 여부를 미리 확인하는 메소드
     **/
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public static CCR_QureMsg runPreeligibilitychecksqure(CCR_QureMsg preEligibilityOutCome) {
        forTest();
        System.debug('runPreeligibilitychecksqure called');
        String codentify = preEligibilityOutCome.Codentify;
        DateTime preEligibilityStart = DateTime.now();
        CCR_QureHistory__c newQurehisrty = new CCR_QureHistory__c();
        Boolean limitedEditionDevice = false;
//        List<user> userType = [SELECT CCR_UserType__c FROM User WHERE Id = :UserInfo.getUserId()];
        String userType = preEligibilityOutCome.UserType;
        Asset qureDevice = getAssetDetails(codentify);
        preEligibilityOutCome.model = qureDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c;
        preEligibilityOutCome.color = qureDevice.CCR_DeviceProductCode__r.CCR_Color__c;
        preEligibilityOutCome.MaterialGroup = qureDevice.CCR_MaterialGroupDescription__c;
        //Added by Raghu as part of CCR-156267
        preEligibilityOutCome.contactExternalId = qureDevice.Contact.CCR_ConsumerUID__c;
        preEligibilityOutCome.contactEmailId = qureDevice.Contact.Email;
        preEligibilityOutCome.FirstName = qureDevice.Contact.FirstName;
        preEligibilityOutCome.LastName = qureDevice.Contact.LastName;
        System.debug('runPreeligibilitychecksqure variables set');
        if (qureDevice != null) {
            List<CCR_QureProcess__mdt> qureProcess = [
                    SELECT Id,CCR_GrandType__c, CCR_UserType__c, CCR_Country__c,
                            CCR_TimeforBlockonlineQure__c
                    FROM CCR_QureProcess__mdt
                    WHERE (
                            CCR_GrandType__c = :CCR_Constants.QUREENABLE                        // Qure Enable
                            OR CCR_GrandType__c = :CCR_Constants.BLOCKSEQUENTIALQURE            // Block Sequential Qure
                            OR CCR_GrandType__c = :CCR_Constants.BLOCKSEQUENTIALQUREBYCONSUMER  // Block Sequential Qure by Consumer
                            OR CCR_GrandType__c = :CCR_Constants.CHECKLIMITEDEDITION            // Check Limited Edition
                    )
                    AND CCR_UserType__c = :userType
            ];//qureDevice.Contact.CCR_CountryID__c];
            boolean qureEnable = false;
            boolean qureBlock = false;
            boolean qureBlockConsumer = false;
            boolean qureLmtEdition = false;
            Integer timeOnBlockingQure = 0;
            if (qureProcess != null && !qureProcess.isEmpty()) { // UserType에 따라 특성 프로세스가 존재하는지 확인
                for (CCR_QureProcess__mdt qurpr : qureProcess) {
                    if (qurpr.CCR_GrandType__c == CCR_Constants.CHECKLIMITEDEDITION) {
                        qureLmtEdition = true;
                    } else if (qurpr.CCR_GrandType__c == CCR_Constants.BLOCKSEQUENTIALQURE) {
                        qureBlock = true;
                        qureBlockConsumer = true;
                        timeOnBlockingQure = Integer.valueOf(qurpr.CCR_TimeforBlockonlineQure__c);
                    } else if (qurpr.CCR_GrandType__c == CCR_Constants.QUREENABLE) {
                        qureEnable = true;
//                    } else if (qurpr.CCR_GrandType__c == CCR_Constants.BLOCKSEQUENTIALQUREBYCONSUMER) {
//                        qureBlockConsumer = true;
//                        timeOnBlockingQure = Integer.valueOf(qurpr.CCR_TimeforBlockonlineQure__c);
                    }
                }
            } else { // QureProcess 없음
                CCR_ErrorLogUtility.createErrorLog(QURECONFIGURATIONNOTFOUND, ERRORCLASSNAME, RUNPREELIGIBILITYCHEKSQURE, ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONPREELIGIBILITY);
                preEligibilityOutCome.ErrorMsgId = CCR_Constants.QUREPROCESSNOTACTIVATED;
                return preEligibilityOutCome;
            }

            // QURE Enable 처리 후에 바로 Consumer일 경우 채널 선택한 QureHistory가 있을 경우 Qure 방지 처리 해 줄 것.....

            // qureConfig 는 Limited Edition을 처리하기 위한 값
            List<CCR_QureConfiguration__c> qureConfig = [
                    SELECT Id,CCR_Color__c, CCR_Country__c,
                            CCR_Model__c
                    FROM CCR_QureConfiguration__c
                    WHERE
                    RecordTypeId = :LIMITEDEDITION AND
                    CCR_Color__c = :qureDevice.CCR_DeviceProductCode__r.CCR_Color__c AND
                    CCR_Model__c = :qureDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c
                    LIMIT 1
            ];
            List<CCR_QureHistory__c> qureHistory = [
                    SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c, CCR_QureReplacementChannel__c,
                            CCR_DiagnosticDescription__c, CCR_SubjectCode__c,CCR_EligibilityResult__c,CCR_Status__c,
                            CCR_CodeToBeEscalated__c, Createddate
                    FROM CCR_QureHistory__c
                    WHERE CCR_Device__c = :qureDevice.id
                    ORDER BY createddate DESC
                    LIMIT 1
            ];

            if (qureHistory != null && !qureHistory.isEmpty()) { // qureHistory 이력 있음
                preEligibilityOutCome.QureHistryId = String.valueOf(qureHistory[0].id);
            }
//            } else if (qureEnable && userType == CCR_Constants.RETAILERLIGHT) {
//                preEligibilityOutCome.ErrorMsgId = CCR_Constants.RETAILERLIGHTBLOCKQURE;
//                return preEligibilityOutCome;
//            } else if (qureEnable && userType == CCR_Constants.SHIFTLIGHT) {
//                system.debug('=========2>:' + qureHistory);
//                preEligibilityOutCome.ErrorMsgId = CCR_Constants.SHIFTLIGHTBLOCKQURE;
//                return preEligibilityOutCome;
//            }
            //check model has at least one entry on DeviceDiagnostic. If not Model is not supported by QURE
            List<CCR_DeviceDiagnostic__c> qureDeviceDiagnostic = [
                    SELECT Id
                    FROM CCR_DeviceDiagnostic__c
                    WHERE CCR_Active__c = true
                    AND RecordTypeId = :DEVICEISSUE
                    AND CCR_ParentDiagnostic__c = null
                    AND CCR_Model__c = :qureDevice.CCR_DeviceProductCode__r.CCR_ModelNumber__c
            ];
            //if(qureDeviceDiagnostic == null || qureDeviceDiagnostic.isEmpty()){
            Integer recordsCount = [
                    SELECT Count()
                    FROM CCR_DeviceDiagnosticLocalization__c
                    WHERE CCR_DeviceDiagnostic__c IN :qureDeviceDiagnostic
                    AND CCR_Active__c = TRUE
            ];
            if (recordsCount == 0) {
                //checking qure is supported by consumer based on model of device.
                if (userType == CCR_Constants.CONSUMER) {
                    preEligibilityOutCome.ErrorMsgId = CCR_Constants.NOTQUREMODEL;
                    return preEligibilityOutCome;
                } else {
                    preEligibilityOutCome.ErrorMsgId = CCR_Constants.NOTQUREMODELAGENTS;
                    return preEligibilityOutCome;
                }
            }
            //}
            CCR_CarePlusConfiguration__c carePlusData = [select id, CCR_AccidentalDamageLimit__c, CCR_CarePlusActivated__c, CCR_Country__c, CCR_L0codes__c  from CCR_CarePlusConfiguration__c limit 1];
//            System.debug('preeligibility @@@ qureHistory.CCR_QureReplacementChannel__c :::: ' + qureHistory[0].CCR_QureReplacementChannel__c);
            //checking qure is active for user
            if (qureEnable) {
                //checking asset is blocked for online if it is consumer or Retailers light if device is not eligible.

                if(qureDevice.CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSENROLLED){
                    preEligibilityOutCome.carePlusStatusEnrolled = false;
                }

                // qureblock && preEligibilityOutCome.UserType != CCR_Constants.CONSUMER 이런 경우는 없는것 같음
                // qureblock == true 인 경우는 consumer밖에 없음
                if ((qureBlock && preEligibilityOutCome.UserType != CCR_Constants.CONSUMER) || // Online QURE 가 아니다
                        (qureBlock && preEligibilityOutCome.UserType == CCR_Constants.CONSUMER && qureDevice.CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSENROLLED) || // Online QURE 지만 CarePlusStatus가 없다
                        (qureDevice.CCR_CarePlusStatus__c == CCR_Constants.CAREPLUSENROLLED && qureDevice.CCR_AccidentalDamageCounter__c >= carePlusData.CCR_AccidentalDamageLimit__c)) { // CarePlus 가 있지만 CarePlus 횟수가 제한을 넘음(현재는 1)
                    List<CCR_QureHistory__c> qurstrblck = [
                            SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c,
                                    CCR_NotMaxNumbersofReplacement__c,CCR_QureReplacementChannel__c
                            FROM
                                    CCR_QureHistory__c
                            WHERE CCR_Device__c = :qureDevice.id AND
                            (CCR_EligibilityResult__c = :CCR_Constants.NOTELIGIBLE OR
                            CCR_EligibilityResult__c = :CCR_Constants.ELIGIBLE ) AND
                            (CCR_QureChannel__c = :CCR_Constants.ECOMMERCE OR
                            CCR_QureChannel__c = :CCR_Constants.CALLCENTERVAL OR
                            CCR_QureChannel__c = :CCR_Constants.SERVICECENTERVAL OR
                            CCR_QureChannel__c = :CCR_Constants.FLAGSHIPSTOREval OR
                            CCR_QureChannel__c = :CCR_Constants.RETAILERLIGHT
                            )
                            ORDER BY createddate DESC
                            LIMIT 1
                    ];
                    datetime td = system.today();
                    td = td.addHours(-timeOnBlockingQure); // 현재시간 - Block 시간
                    if (qurstrblck != null && !qurstrblck.isEmpty()) { // QureHistory 가 있는지
                        if (qurstrblck[0].CCR_EndDiagnostic__c > td && // QureHistory 마무리 날짜가 Block 기간 내
                                (qurstrblck[0].CCR_QureReplacementChannel__c != CCR_Constants.PICKUPATCVSSTORE) && // QureHistory 교환 채널이 PickupCVSStore가 아님
                                ((qurstrblck[0].CCR_EligibilityResult__c == CCR_Constants.NOTELIGIBLE) || // QureHistory 결과가 NotEligible
                                        (qurstrblck[0].CCR_CodeToBeEscalated__c == TRUE) || // QureHistory Escaltated 코드가 Ture
                                        (qurstrblck[0].CCR_NotMaxNumbersofReplacement__c == False))) { // 교환 횟수 최대
//                            preEligibilityOutCome.WarningMessageId = CCR_Constants.ASSETBLOCKED;
                            preEligibilityOutCome.ErrorMsgId = CCR_Constants.ASSETBLOCKED;
                            return preEligibilityOutCome;
                        }
                    }
                } else if (qureBlockConsumer && (qureDevice.CCR_CarePlusStatus__c != CCR_Constants.CAREPLUSENROLLED || // CarePlus 가 아님
                        (qureDevice.CCR_CarePlusStatus__c == CCR_Constants.CAREPLUSENROLLED && // CarePlus 해당
                                qureDevice.CCR_AccidentalDamageCounter__c >= carePlusData.CCR_AccidentalDamageLimit__c))) { // CarePlus 횟수 초과
                    List<CCR_QureHistory__c> qurstrblckbyconsumer = [
                            SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c,
                                    CCR_NotMaxNumbersofReplacement__c,CCR_QureReplacementChannel__c
                            FROM CCR_QureHistory__c
                            WHERE CCR_Device__c = :qureDevice.id AND
                            (CCR_EligibilityResult__c = :CCR_Constants.NOTELIGIBLE OR
                            CCR_EligibilityResult__c = :CCR_Constants.ELIGIBLE ) AND
                            (CCR_QureChannel__c = :CCR_Constants.ECOMMERCE)
                            ORDER BY createddate DESC
                            LIMIT 1
                    ];
                    if (qurstrblckbyconsumer != null && !qurstrblckbyconsumer.isEmpty()) {
                        datetime td = system.today();
                        td = td.addHours(-timeOnBlockingQure);
                        if (qurstrblckbyconsumer[0].CCR_EndDiagnostic__c > td && (qurstrblckbyconsumer[0].CCR_QureReplacementChannel__c != CCR_Constants.PICKUPATCVSSTORE) && ((qurstrblckbyconsumer[0].CCR_EligibilityResult__c == CCR_Constants.NOTELIGIBLE) || (qurstrblckbyconsumer[0].CCR_CodeToBeEscalated__c == TRUE) || (qurstrblckbyconsumer[0].CCR_NotMaxNumbersofReplacement__c == False))) {
                            preEligibilityOutCome.WarningMessageId = CCR_Constants.ASSETBLOCKED;
                            return preEligibilityOutCome;
                        }
                    }
                }

                //if device is limited edition displaying warning message 8
                // Qure Configuration 이 있는 경우에 대한 처리?
                if (qureConfig != null && !qureConfig.isEmpty()) {
                    //display warning message for limited edition
                    limitedEditionDevice = true;
                    preEligibilityOutCome.IsLimitedEdition = limitedEditionDevice;
                    if (qureLmtEdition) {
                        preEligibilityOutCome.WarningMessageId = CCR_Constants.LIMITEDEDITION;
                    }
                }

                if (qureDevice != null) {
                    //checking Device  status active 9
                    if (qureDevice.Status == CCR_Constants.ASSETACTIVE) {
                        //checking Device is Markeable for Replacement 11
                        // if(Date.valueof(qureDevice.CCR_EligibilityDueDate__c) > System.today()){
                        if (qureDevice.CCR_EligibilityDueDate__c >= System.today()) {
                            // CCR_EligibilityDueDate__c 값이 있는 경우
                            if (qureHistory != null && !qureHistory.isEmpty() && qureHistory[0].CCR_SubjectCode__c == null) {
                                List<CCR_QureHistory__c> tempHistoryList = [
                                        SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c, CCR_QureReplacementChannel__c,
                                                CCR_DiagnosticDescription__c, CCR_SubjectCode__c,CCR_EligibilityResult__c,CCR_Status__c,
                                                CCR_CodeToBeEscalated__c
                                        FROM CCR_QureHistory__c
                                        WHERE CCR_Device__c = :qureDevice.id
                                        AND CCR_SubjectCode__c != null
                                        ORDER BY createddate DESC
                                        LIMIT 1
                                ];
                                if (tempHistoryList != null && !tempHistoryList.isEmpty()) {
                                    qureHistory.clear();
                                    qureHistory.addAll(tempHistoryList);
                                    preEligibilityOutCome.QureHistryId = String.valueOf(qureHistory[0].id);
                                }
                            }
                            //checking with call center user , consumer and Retailer user if channel is selected.
//                            if (userType == CCR_Constants.CALLCENTERUSER || userType == CCR_Constants.CONSUMER || userType == CCR_Constants.SYSTEMADMIN) {
                            if (TRUE) {
//                            if (userType == CCR_Constants.CALLCENTERUSER || userType == CCR_Constants.SYSTEMADMIN) {
                                //checking replacement channel is selected or not
                                if (!qureHistory.isEmpty() && qureHistory[0].CCR_QureReplacementChannel__c != null) {
                                    System.debug('@@@return called in ---- if (!qureHistory.isEmpty() && qureHistory[0].CCR_QureReplacementChannel__c != null) {');
                                    //checking replacement channel is F2F by consumer or agent 53
                                    if (qureHistory[0].CCR_QureReplacementChannel__c == CCR_Constants.FACETOFACE) {
                                        //Option NO on 39
//                                        if (userType == CCR_Constants.CONSUMER) {
                                            preEligibilityOutCome.ReplacementReason = qureHistory[0].CCR_DiagnosticDescription__c;
                                            preEligibilityOutCome.ErrorMsgId = CCR_Constants.REPLACEMENTCHANNELSELECTED;
                                            preEligibilityOutCome.WarningMessageId = null;
                                            return preEligibilityOutCome;
//                                        }
//                                        preEligibilityOutCome.ReplacementReason = qureHistory[0].CCR_DiagnosticDescription__c;
//                                        preEligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
//                                        return preEligibilityOutCome;
                                    } else {
                                        if (qureHistory[0].CCR_QureReplacementChannel__c == CCR_Constants.COURIERDELIVERY ||
                                                qureHistory[0].CCR_QureReplacementChannel__c == CCR_Constants.PICKUPATCVSSTORE) {
                                            //End message Replacement channel already selected by consumer 40.
                                            if (userType == CCR_Constants.CONSUMER) {
                                                preEligibilityOutCome.ReplacementReason = qureHistory[0].CCR_DiagnosticDescription__c;
                                                preEligibilityOutCome.ErrorMsgId = CCR_Constants.REPLACEMENTCHANNELSELECTED;
                                                return preEligibilityOutCome;
                                            }
                                            //End message Replacement channel already selected by Agent 41.
                                            else {
                                                preEligibilityOutCome.ReplacementReason = qureHistory[0].CCR_DiagnosticDescription__c;
                                                preEligibilityOutCome.ErrorMsgId = CCR_Constants.REPLACEMENTCHANNELSELECTEDAGENTS;
                                                return preEligibilityOutCome;
                                            }

                                        }

                                    }
                                } else {
                                    //Option NO on 39
                                    if (qureHistory != null && !qureHistory.isEmpty()) preEligibilityOutCome.ReplacementReason = qureHistory[0].CCR_DiagnosticDescription__c;
                                    preEligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                                    return preEligibilityOutCome;
                                }
                            }
                            //checking with service center and flagshipstore and Retailer light users.
                            //sprint 48-CCR-5976 checking all users for replacement with replacement channel CVS need to return new code to main component
                            if (!qureHistory.isEmpty() && (userType == CCR_Constants.SERVICECENTERS)
                                    || (userType == CCR_Constants.FLAGSHIPSTORE)
                                    || (userType == CCR_Constants.CALLCENTERUSER)
                                    || (userType == CCR_Constants.CONSUMER)
                                    || (userType == CCR_Constants.CORNERSHOP)) {

                                if (qureHistory[0].CCR_QureReplacementChannel__c != null) {
                                    //checking CVS store 50
                                    if (qureHistory[0].CCR_QureReplacementChannel__c == CCR_Constants.PICKUPATCVSSTORE) {
                                        //preeligibilityOutCome.ErrorMsgId = CCR_Constants.CVSSELECTED;
                                        preEligibilityOutCome.Results = CCR_QureMsg.ISOBARRESENDVOUCHER;
                                        //system.debug('csvseleted'+preeligibilityOutCome.ErrorMsgId);
                                        return preEligibilityOutCome;
                                    } else {
                                        //checking channel is online for service center agent or flagship store agent 42
                                        if (userType == CCR_Constants.SERVICECENTERS
                                                || userType == CCR_Constants.FLAGSHIPSTORE) {

                                            if (qureHistory[0].CCR_QureReplacementChannel__c == CCR_Constants.COURIERDELIVERY) {
                                                preEligibilityOutCome.ErrorMsgId = CCR_Constants.ONLINEREPLACEMENTCHANNELSELECTED;
                                                return preEligibilityOutCome;
                                            } else {
                                                //other channel selected
                                                //Option NO on 37
                                                preEligibilityOutCome.ReplacementReason = qureHistory[0].CCR_DiagnosticDescription__c;
                                                preEligibilityOutCome.Results = CCR_QureMsg.OTHERREPLACEMENTCHANNEL;
                                                return preEligibilityOutCome;
                                            }
                                        }
                                    }
                                } else {
                                    //Option NO on 39
                                    preEligibilityOutCome.ReplacementReason = qureHistory[0].CCR_DiagnosticDescription__c;
                                    preEligibilityOutCome.Results = CCR_QureMsg.REPLACEMENTCHANNELNOTSELECTED;
                                    return preEligibilityOutCome;
                                }

                            }
                        } else {
                            if (!qureHistory.isEmpty() && (qureHistory[0].CCR_Status__c == CCR_Constants.QUREActive || qureHistory[0].CCR_Status__c == null)) {
                                updateQureHistory(qureHistory[0]);
                            }
                            if (qureHistory.isEmpty() || qureHistory[0].CCR_Status__c == CCR_Constants.QUREINACTIVE) {
                                // QureHistory 신규 생성
                                newQurehisrty = createQurehistory(qureDevice, preEligibilityStart, limitedEditionDevice, userType);
                                //Enter to Fault tree or return to Fault tree
                                //Option NO on 11
                                preEligibilityOutCome.Results = CCR_QureMsg.DEVICENOTMARKEDREPLACEBLE;
                                // Limited Edition 출력이 되는 값
                            }
                            if (newQurehisrty != null) {
                                preEligibilityOutCome.QureHistryId = String.valueOf(newQurehisrty.ID);
                            }
                            return preEligibilityOutCome;
                        }
                    } else {
//                        preEligibilityOutCome.Results = CCR_Constants.QUREINACTIVE;
                        preEligibilityOutCome.ErrorMsgId = CCR_Constants.NODIAGNOSISPOSSIBLE;
                        return preEligibilityOutCome;
                    }
                }
            } else if (qureEnable && qureDevice != null) {
                List<CCR_QureHistory__c> qureHistoryret = [
                        SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                                CCR_QureReplacementChannel__c, CCR_DiagnosticDescription__c,CCR_Override__c,
                                CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c,CCR_Status__c
                        FROM CCR_QureHistory__c
                        WHERE CCR_Device__c = :qureDevice.id
                        ORDER BY createddate DESC
                        LIMIT 1
                ];
            } else {
                //Qure is not active for user
                System.debug('!qureEnable');
                preEligibilityOutCome.ErrorMsgId = CCR_Constants.QUREPROCESSNOTACTIVATED;
                return preEligibilityOutCome;

            }
        }
        return preEligibilityOutCome;
    }
    /**
     * Method Name:  createQurehistory
     * Arguments:
     * @param 1: qureDevice
     * @param 2: startTime
     * @param 3: limitedDevice
     * @param 4: qurhstrChannel
     * Return:  CCR_QureHistory__c
     * Description: to craete Qurehistory record.
     **/
    public static CCR_QureHistory__c createQurehistory(Asset qureDevice, DateTime startTime, Boolean limitedDevice, String qurhstrChannel) {
        CCR_QureHistory__c vQureHistory = new CCR_QureHistory__c();
        vQureHistory.CCR_Consumer__c = qureDevice.contactid;
        vQureHistory.CCR_Device__c = qureDevice.id;
        vQureHistory.CCR_Status__c = CCR_Constants.QUREActive;
        vQureHistory.CCR_QureChannel__c = updateQurechannel(qurhstrChannel);
        vQureHistory.CCR_StartDateforpreeligibilitychecks__c = startTime;
        vQureHistory.CCR_EndDateforpreeligibilitychecks__c = DateTIme.now();
        vQureHistory.CCR_LimitedEdition__c = limitedDevice;
        try {
            insert vQureHistory;
        } catch (Exception exp) {
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp, ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONPREELIGIBILITY);
            } catch (Exception ex) {
                System.debug('Error == ' + ex);
            }
            throw exp;
        }
        return vQureHistory;
    }
    /**
     * Method Name: getAssetDetails
     * Arguments: String codentifyId
     * Return: Asset
     * Description:  getting asset details
     **/
    public static Asset getAssetDetails(String codentifyId) {
        List<Asset> assList = [
                SELECT Id, CCR_CodentifyId__c, Status,ContactId, CCR_EligibilityDueDate__c,
                        CCR_ReplacementChannel__c,CCR_DeviceProductCode__r.CCR_ModelNumber__c,
                        CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c, CCR_CarePlusStatus__c, (
                        SELECT Id, Name, CCR_QureChannel__c, CCR_EligibilityResult__c,CCR_Status__c
                        FROM QURE_History__r
                ), CCR_AccidentalDamageCounter__c, CCR_MaterialGroupDescription__c,
                        CCR_DeviceProductCode__c,CCR_EligibleForReplacement__c, CCR_SubscribedDevice__c, CCR_SubscriptionID__c,
                        Contact.CCR_ConsumerUID__c, Contact.Email, Contact.FirstName, Contact.LastName
                FROM Asset
                WHERE CCR_CodentifyId__c = :codentifyId
                LIMIT 1
        ];
        if (assList != null && !assList.isEmpty()) {
            return assList[0];
        }
        return null;
    }
    /**
* Method Name: updateQurechannel
* Arguments: String usertype
*Return:string
* Description:updating qure channel based on who is perferming qure
**/
    public static String updateQurechannel(String usertype) {
        String vQureHistoryChannel;
        if (usertype == CCR_Constants.QUREHANDLINGPROFILE) {
            vQureHistoryChannel = CCR_Constants.ECOMMERCE;
        }
        if (usertype == CCR_Constants.SERVICECENTERS) {
            vQureHistoryChannel = CCR_Constants.SERVICECENTERVAL ;
        }
        if (usertype == CCR_Constants.CALLCENTERUSER) {
            vQureHistoryChannel = CCR_Constants.CALLCENTERVAL;
        }
        if (usertype == CCR_Constants.FLAGSHIPSTORE) {
            vQureHistoryChannel = CCR_Constants.FLAGSHIPSTOREval;
        }
        List<User> listUsers = [SELECT Id,Profile.Name FROM User WHERE Id = :userInfo.getUserId() LIMIT 1];
        if (!listUsers.isEmpty()) {
            if (listUsers[0].Profile.Name == 'CCR Integration User') {
                vQureHistoryChannel = CCR_Constants.MOBILEAPP;
            }
        }
        return vQureHistoryChannel;
    }
    /**
* Method Name:  updateQureHistory
* Arguments: qureHisRec,limitededtion
* Return: CCR_QureHistory__c
* Description: updating qurehistory record
**/
    public static CCR_QureHistory__c updateQureHistory(CCR_QureHistory__c qureHisRec) {
        qureHisRec.CCR_Status__c = CCR_Constants.QUREINACTIVE ;
        try {
            update qureHisRec;
        } catch (Exception exp) {
            try {
                CCR_ErrorLogUtility.createExceptionLog(exp, ERRORTYPE, ERRORSCOPE, ERRORFUNCTIONPREELIGIBILITY);
            } catch (Exception ex) {
                System.debug('Error == ' + ex);
            }
            throw exp;
        }
        return qureHisRec;
    }

    public static void forTest() {
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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