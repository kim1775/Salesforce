/****************************************************************************************
 * @filename      : KDCE_LiveChatTranscript_tr
 * @projectname   : 
 * @author        : Donghu
 * @date          : 2021-03-16
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1      2021-03-16                  Donghu          Create
 ****************************************************************************************/
public without sharing class KDCE_LiveChatTranscript_tr extends TriggerHandler {

    private static Map<String, Id> caseRecordTypeMap = KDCE_Util.getRecordTypeBySObject('Case');
    private final static Id inquiryCriticalRTId = caseRecordTypeMap.get('CCR_InquiryCriticalInquiries');

    public override void beforeInsert() {
        setContactId();
//        setCaseId();
    }

    public override void beforeUpdate() {
        setContactId();
        setCaseId();
    }

    /**
     * Chat 생성시 Case 생성
     * Case tr에서 생성되는 Contact 값을
     * Live Chat Contact 값에 추가
     *
     */
    private void setContactId() {
        System.debug('set Contact Id');
        Set<String> caseSet = new Set<String>();
        for (LiveChatTranscript lct : (List<LiveChatTranscript>) Trigger.new) {
            System.debug('lct :: ' + lct);

            if (lct.ContactId == null && lct.CaseId != null) {
                caseSet.add(lct.CaseId);
            }
        }
        if (caseSet.isEmpty())  return;
        System.debug(caseSet );

        Map<String, String> caseContactMap = new Map<String, String>();
        for (Case newCase : [
                SELECT Id, ContactId
                FROM Case
                WHERE Id IN:caseSet
        ]) {
            caseContactMap.put(newCase.Id, newCase.ContactId);
        }
        System.debug(caseContactMap );
        for (LiveChatTranscript lct : (List<LiveChatTranscript>) Trigger.new) {
            if (lct.ContactId == null && lct.CaseId != null && caseContactMap.containsKey(lct.CaseId)) {
                lct.ContactId = caseContactMap.get(lct.CaseId);
                System.debug('lct.ContactId :: ' + lct.ContactId);
            }
        }

    }

    private void setCaseId() {
        System.debug('@@@@@@ setCaseId @@@@@@');
        List<Case> insertCases = new List<Case>();
        String uniqueKey;
        Case newCase;
        Map<String, Case> caseMillisMap = new Map<String, Case>();
        Map<String, LiveChatTranscript> lctMillisMap = new Map<String, LiveChatTranscript>();
        Map<Id, Id> lctByCaseId = new Map<Id, Id>();
        List<LiveChatTranscript> liveChatTranscripts = new List<LiveChatTranscript>();
        for (LiveChatTranscript lct : (List<LiveChatTranscript>) Trigger.new) {
            if (lct.CaseId == null && lct.ContactId != null) liveChatTranscripts.add(lct);
        }

        for (LiveChatTranscript lct : liveChatTranscripts) {
            System.debug('=== lct.ContactId : ' + lct.ContactId);
            uniqueKey = String.valueOf(System.currentTimeMillis() + Math.random() * 1000);
            newCase = new Case(
                    ContactId = lct.ContactId != null ? lct.ContactId : null
                    , Origin = 'Chat'
                    , RecordTypeId = inquiryCriticalRTId
                    , CCR_ContactType__c = 'Chat'
            );
            caseMillisMap.put(uniqueKey, newCase);
            lctMillisMap.put(uniqueKey, lct);
        }
        System.debug('=== caseMillisMap : ' + caseMillisMap);
        System.debug('=== lctMillisMap : ' + lctMillisMap);

        if (!caseMillisMap.values().isEmpty() && caseMillisMap.values() != null) {
            if(!Test.isRunningTest()){

                TriggerHandler.bypass('KDCE_Case_tr');
                Database.insert(caseMillisMap.values());
                TriggerHandler.clearBypass('KDCE_Case_tr');
            }
            for (String key : lctMillisMap.keySet()) {
                if (caseMillisMap.containsKey(key)) {
                    lctMillisMap.get(key).CaseId = caseMillisMap?.get(key).Id;
                }
            }
        }
    }

}