/****************************************************************************************
 * @filename      : KDCE_TnCAccepted_tr
 * @projectname   : PMK Local DCE QA
 * @author        : i2max_Sukun
 * @date          : 5/11/21 9:58 AM
 * @group         : Service
 * @group-content :
 * @description   : TnC Accepted Trigger Business Logic Class
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     5/11/21 9:58 AM            i2max_Sukun           Create
 0.2     5/21/21                    i2max_Sukun           Update
 ****************************************************************************************/
public with sharing class KDCE_TnCAccepted_tr extends TriggerHandler {
    // Call Center Profile Name
    private static final String CALL_CENTER_PROFILE = System.Label.KDCE_COM_PROFILE_NAME_CALL_CENTER;
    // TnC Accept Behavior에 따른 History Description
    private static final String LAB_TNC_HISTORY_DESC_ACCEPT = System.Label.LAB_TNC_HISTORY_DESC_ACCEPT;
    private static final String LAB_TNC_HISTORY_DESC_DECLINE = System.Label.LAB_TNC_HISTORY_DESC_DECLINE;
    private static final String LAB_TNC_HISTORY_DESC_DECLINE_MARKETING = System.Label.LAB_TNC_HISTORY_DESC_DECLINE_MARKETING;
    private static final String LAB_TNC_HISTORY_DESC_DECLINE_INFORMATION = System.Label.LAB_TNC_HISTORY_DESC_DECLINE_INFORMATION;
    private static final String LAB_TNC_HISTORY_DESC_DECLINE_MARKETINGANDINFORMATION = System.Label.LAB_TNC_HISTORY_DESC_DECLINE_MARKETINGANDINFORMATION;

    public override void afterUpdate() {
        updateDefaultBehavior();
    }

    /**
     * @description Accepted 내역 변경 시 Contact Accepted 내역에 따라 Marketing Opt-In, Information Opt-In 내역 반영
     * @description Accepted 내역 변경 시 TnCHistory 생성
     * @param
     * @return
     */
    private void updateDefaultBehavior() {
        ParamWrapper param = setRelevantContactAcceptanceInfo();
        createTnCHistory(param);
    }

    /**
     * @description Accepted 내역 변경 시 Contact Accepted 내역에 따라 Marketing Opt-In, Information Opt-In 내역 반영
     * @param
     * @return ParamWrapper (History 생성 시 필요한 추가 정보들을 Wrapper Class로 전달)
     */
    private ParamWrapper setRelevantContactAcceptanceInfo() {

        Map<Id, KDCE_TnCAccepted__c> tnCAcceptedOldMap = (Map<Id, KDCE_TnCAccepted__c>) Trigger.oldMap;
        Map<Id, KDCE_TnCAccepted__c> tnCAcceptedNewMap = (Map<Id, KDCE_TnCAccepted__c>) Trigger.newMap;
        Map<Id, Contact> contactsToBeUpdatedMap = new Map<Id, Contact>();
        List<Contact> contactsRetrieved;
        Set<String> channelSet = new Set<String>();

        ParamWrapper paramWrapper = new ParamWrapper();
        Map<Id, User> modifiedUserMap = new Map<Id, User>();
        Map<Id, Integer> finalOptOutIndicatorMap = new Map<Id, Integer>();

        for (KDCE_TnCAccepted__c tnCAccepted : (List<KDCE_TnCAccepted__c>) Trigger.new) {
            if (tnCAcceptedOldMap.get(tnCAccepted.Id).Accepted__c != tnCAccepted.Accepted__c) {
                if (tnCAccepted.Contact__c != null) contactsToBeUpdatedMap.put(tnCAccepted.Contact__c, null);
                if (tnCAccepted.fm_Channel__c != null) channelSet.add(tnCAccepted.fm_Channel__c);
            }
        }

        if (contactsToBeUpdatedMap.keySet().size() > 0) {
            contactsRetrieved = [
                    SELECT Id,
                            KDCE_MarketingOptIn__c,
                            KDCE_InformationOptIn__c,
                            RecordType.DeveloperName,
                            // Contact의 TnC Accepted 내역 중 같은 버전에 대한 내역만 retrieve
                    (
                            SELECT TnCVersionSet__r.TaC__r.KDCE_SubGroup__c,
                                    fm_MarketingOptIn__c,
                                    fm_InformationOptIn__c,
                                    TnCVersionSet__r.TnCVersion__r.VersionNumber__c,
                                    TnCVersionSet__r.Channel__c,
                                    Accepted__c,
                                    LastModifiedBy.Profile.Name,
                                    LastModifiedBy.LastName,
                                    fm_Channel__c
                            FROM TnCAccepted__r
                            WHERE
                                fm_Channel__c IN :channelSet
                            ORDER BY TnCVersionSet__r.TnCVersion__r.VersionNumber__c, TnCVersionSet__r.Channel__c, TnCVersionSet__r.ChannelNo__c
                    )

                    FROM Contact
                    WHERE Id IN :contactsToBeUpdatedMap.keySet()
            ];


            if (contactsRetrieved.size() > 0) {
                //flag
                Boolean marketingFlag = TRUE;
                Boolean informationFlag = TRUE;
                Set<String> channelComparingSet = new Set<String>();

                for (Contact con : contactsRetrieved) {
                    for (KDCE_TnCAccepted__c affectingTnCAccepted : con.TnCAccepted__r) {
                        if(tnCAcceptedNewMap.containsKey(affectingTnCAccepted.Id)) {
                            channelComparingSet.add(affectingTnCAccepted.fm_Channel__c);
                            finalOptOutIndicatorMap.put(affectingTnCAccepted.Id, null);
                        }
                    }

                    for (KDCE_TnCAccepted__c tnCAccepted : con.TnCAccepted__r) {
                        if(channelComparingSet.contains(tnCAccepted.fm_Channel__c)) {
                            //비동의 레코드 있을 시
                            if (!tnCAccepted.Accepted__c) {

                                // Accepted의 T&C Version Set이 Marketing 동의와 관련된 Version Set일 경우
                                if (tnCAccepted.fm_MarketingOptIn__c) {
                                    marketingFlag = FALSE;
                                }
                                // Accepted의 T&C Version Set이 Information 동의와 관련된 Version Set일 경우
                                if (tnCAccepted.fm_InformationOptIn__c) {
                                    informationFlag = FALSE;
                                }
                            }
                        }
                        if (tnCAcceptedNewMap.containsKey(tnCAccepted.Id)) modifiedUserMap.put(tnCAccepted.LastModifiedById, tnCAccepted.LastModifiedBy);
                    }

                    // 1은 marketingFlag FALSE 변경, 2는 InformationFlag FALSE 변경, 3은 둘다 FALSE 변경
                    Integer changeIndicator = marketingFlag == FALSE ?
                            (informationFlag == FALSE ? 3 : 1) :
                            (informationFlag == FALSE ? 2 : 0);

                    // [1] Map 내의 tnCAccepted에 대하여 해당 Contact의 Optout 최종 flag 정보 저장
                    for (Id id : finalOptOutIndicatorMap.keySet()) {
                        finalOptOutIndicatorMap.put(id, changeIndicator);
                    }

                    con.KDCE_MarketingOptIn__c = marketingFlag;
                    con.KDCE_InformationOptIn__c = informationFlag;

                    contactsToBeUpdatedMap.put(con.Id, con);
                }
            }
        }

        if (contactsToBeUpdatedMap.values().size() > 0) update contactsToBeUpdatedMap.values();

        paramWrapper.userMap = modifiedUserMap;
        paramWrapper.finalIndicatorMap = finalOptOutIndicatorMap;
        return paramWrapper;
    }

    /**
     * @description Accepted 내역 변경 시 TnCHistory 생성
     * @param ParamWrapper
     * @return
     */
    private void createTnCHistory(ParamWrapper additionalInformation) {
        List<KDCE_TnCHistory__c> tnCHistoryList = new List<KDCE_TnCHistory__c>();
        KDCE_TnCHistory__c tnCHistory;
        Map<Id, KDCE_TnCAccepted__c> tnCAcceptedOldMap = (Map<Id, KDCE_TnCAccepted__c>) Trigger.oldMap;

        for (KDCE_TnCAccepted__c tnCAccepted : (List<KDCE_TnCAccepted__c>) Trigger.new) {

            if (tnCAcceptedOldMap?.get(tnCAccepted.Id)?.Accepted__c != tnCAccepted?.Accepted__c) {
                tnCHistory = new KDCE_TnCHistory__c(
                        DTE_Contact__c = tnCAccepted?.Contact__c,
                        KDCE_TnCVersionSet__c = tnCAccepted?.TnCVersionSet__c,
                        KDCE_TnC__c = tnCAccepted?.TnC__c,
                        KDCE_Accepted__c = tnCAccepted?.Accepted__c,
                        CCR_Acceptance_Date__c = Datetime.now());

                tnCHistory.KDCE_Description__c = additionalInformation.userMap.get(tnCAccepted.LastModifiedById).LastName + '(이)가 고객의 해당 약관을 ';

                if (!tnCAccepted.Accepted__c) {
                    switch on additionalInformation.finalIndicatorMap.get(tnCAccepted.Id) {
                        when 1 {
                            tnCHistory.KDCE_Description__c += LAB_TNC_HISTORY_DESC_DECLINE_MARKETING;
                        }
                        when 2 {
                            tnCHistory.KDCE_Description__c += LAB_TNC_HISTORY_DESC_DECLINE_INFORMATION;
                        }
                        when 3 {
                            tnCHistory.KDCE_Description__c += LAB_TNC_HISTORY_DESC_DECLINE_MARKETINGANDINFORMATION;
                        }
                        when else {
                            tnCHistory.KDCE_Description__c += LAB_TNC_HISTORY_DESC_DECLINE;
                        }
                    }
                } else {
                    tnCHistory.KDCE_Description__c += LAB_TNC_HISTORY_DESC_ACCEPT;
                }

                // Call Center Profile일 경우
//                if (additionalInformation.userMap.get(tnCAccepted.LastModifiedById).Profile.Name.equals(CALL_CENTER_PROFILE)) {
//                    tnCHistory.KDCE_Description__c += ' (Modified by Call Center Agent)';
//                    tnCHistory.KDCE_Channel__c = 'call center';
//                }

                tnCHistoryList.add(tnCHistory);
            }

        }
        if(tnCHistoryList.size() > 0) insert tnCHistoryList;
    }

    private class ParamWrapper {
        private Map<Id, User> userMap { get; set; }
        private Map<Id, Integer> finalIndicatorMap { get; set; }

        ParamWrapper() {
            userMap = new Map<Id, User>();
            finalIndicatorMap = new Map<Id, Integer>();
        }
    }
}