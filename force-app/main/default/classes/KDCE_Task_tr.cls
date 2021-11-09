/****************************************************************************************
 * @filename      : KDCE_Task_tr
 * @projectname   : 
 * @author        : Donghu
 * @date          : 2021/03/09
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
 0.1      2021/03/09                  Donghu          Create
 ****************************************************************************************/
public with sharing class KDCE_Task_tr extends TriggerHandler {
    // todo :: GC_CampaignId__c -> GC_CampaignId__c 필드 변경

    private static Map<String, Id> caseRecordTypeMap = KDCE_Util.getRecordTypeBySObject('Case');    // Case RecordType 별 DeveloperName, Id의 Map

    public override void beforeInsert() {
        //mappingCaseWithTask();
    }
    public override void beforeUpdate() {
    }

    public override void afterInsert() {
        createCaseByCall();
    }

    public override void afterUpdate() {
        createCaseByCall();
        // sendNotificationToOwner();
    }

    /**
     *  CTI에서 Task를 생성하면 자동으로 Case를 생성한다.
     *  Task의 Name으로 Contact 지정 
     */
    private void createCaseByCall() {
        System.debug('== createCaseByCall ==');
        System.debug('Trigger.isInsert : ' + Trigger.isInsert);
        System.debug('Trigger.isUpdate : ' + Trigger.isUpdate);
        System.debug((List<Task>)Trigger.new);
        Map<String, Case> taskCaseMap = new Map<String, Case>();

        Case newCase;
        String wId;
        Task oldTask;
        Map<Id, String> taskContactMap = new Map<Id, String>();
        Map<Id, String> taskCampaignMap = new Map<Id, String>();
        Map<String, Campaign> campaignParentMap = new Map<String, Campaign>();
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        for (Task task : (List<Task>) Trigger.new) {
            wId = task.WhoId;
            //Outbound Program Call
            if (task.Type == 'Call' && task.ConversationId__c != null && task.WhoId != null && task.WhatId == null && task.GC_CampaignId__c != null) {
                if (wId != null && wId.startsWith('003'))taskContactMap.put(task.Id, task.WhoId);
                campaignParentMap.put(task.GC_CampaignId__c, null);

            }

            //CTI Task 여부 확인
            if (task.Type == 'Call' && task.ConversationId__c != null && task.WhoId != null && task.WhatId == null && task.GC_CampaignId__c == null) {
                newCase = new Case();

                newCase.KDCE_CallResult__c = task.CallDisposition;
                newCase.Origin = 'Phone';
                newCase.KDCE_ANI__c = task.ANI__c;
                newCase.KDCE_RecordingURL__c = task.RecordingURL__c;
                newCase.KDCE_IVR__c = task.IVR__c;
                newCase.KDCE_ConversationId__c = task.ConversationId__c;
                newCase.KDCE_CallDurationInSeconds__c = task.CallDurationInSeconds;
                newCase.KDCE_CallType__c = task.CallType;
                newCase.KDCE_CallResult__c = task.CallDisposition;
                newCase.KDCE_CallDuration__c = task.CallDuration__c;
                newCase.KDCE_ConnectedTime__c = task.ConnectedTime__c;
                newCase.KDCE_AfterCallTime__c = task.AfterCallTime__c;
                newCase.KDCE_DisconnectedTIme__c = task.DisconnectedTime__c;

                if (wId != null && wId.startsWith('003')) newCase.ContactId = task.WhoId;
                if (task.CallType == '인바운드' || task.CallType.containsIgnoreCase('Inbound')) {
                    newCase.CCR_Inbound_Outbound__c = 'Inbound';
                } else if (task.CallType == '아웃바운드' || task.CallType.containsIgnoreCase('Outbound')) {
                    newCase.CCR_Inbound_Outbound__c = 'Outbound';
                    newCase.RecordTypeId = caseRecordTypeMap.get('KDCE_OutboundProgram');
                }

                taskCaseMap.put(task.Id, newCase);
            }

            // Task의 Wrap-up Code > Case Call Result에 업데이트
            if (task.Type == 'Call' && task.ConversationId__c != null && task.WhoId != null && task.WhatId != null) {
                if (task.CallDisposition == null) continue;
                if (!Trigger.isUpdate) continue;
                oldTask = (Task) Trigger.oldMap.get(task.Id);
                if (oldTask.CallDisposition != task.CallDisposition) {
                    newCase = new Case(Id = task.WhatId);
                    newCase.KDCE_ANI__c = task.ANI__c;
                    newCase.KDCE_RecordingURL__c = task.RecordingURL__c;
                    newCase.KDCE_IVR__c = task.IVR__c;
                    newCase.KDCE_ConversationId__c = task.ConversationId__c;
                    newCase.KDCE_CallDurationInSeconds__c = task.CallDurationInSeconds;
                    newCase.KDCE_CallType__c = task.CallType;
                    newCase.KDCE_CallResult__c = task.CallDisposition;
                    newCase.KDCE_CallDuration__c = task.CallDuration__c;
                    newCase.KDCE_ConnectedTime__c = task.ConnectedTime__c;
                    newCase.KDCE_AfterCallTime__c = task.AfterCallTime__c;
                    newCase.KDCE_DisconnectedTIme__c = task.DisconnectedTime__c;

                    taskCaseMap.put(task.Id, newCase);
                }
            }
        }

        /**
         * Outbound Program의 경우 Outbound Master Campaign을 기준으로
         * 최초 전화시에 Case 생성 이후 부재 전화에는 기존의 Case 매핑
        */
        if (!campaignParentMap.isEmpty()) {
            List<Campaign> cpList = [
                    SELECT Id, Name, Type, purecloud__PureCloud_Campaign_ID__c, ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.Type, Parent.Parent.Parent.Name
                    FROM Campaign
                    WHERE purecloud__PureCloud_Campaign_ID__c IN:campaignParentMap.keySet()
            ];

            for (Campaign campaign : cpList) {
//                if (campaign.Parent.Parent.Parent.Type == 'Outbound Master') {
                if (campaign.Type == 'Outbound Program') {
//                    campaignParentMap.put(campaign.purecloud__PureCloud_Campaign_ID__c, campaign.Parent.Parent.Parent); // 한 케이스에서 관리
                    campaignParentMap.put(campaign.purecloud__PureCloud_Campaign_ID__c, campaign); // 일자별 캠페인 매핑해서 관리
                    campaignMap.put(campaign.purecloud__PureCloud_Campaign_ID__c, campaign);
                }
            }
            String outboundRecordId = caseRecordTypeMap.get('KDCE_OutboundProgram');


            Set<Id> campaignIds = new Set<Id>();
            Set<String> taskContactStrings = new Set<String>();
            for(Campaign c : campaignParentMap.values()){
                campaignIds.add(c?.Id);
            }

            for(String tempStr : taskContactMap.values()){
                taskContactStrings.add(tempStr);
            }

            String query = '';
            query += ' SELECT Id,KDCE_OutboundProgram__c,ContactId ';
            query += ' FROM Case ';
            query += ' WHERE RecordTypeId = :outboundRecordId ';
            query += ' AND KDCE_OutboundProgram__c != null ';
//            if (!Test.isRunningTest()) query += ' AND KDCE_OutboundProgram__c IN:campaignParentMap.values() ';  // Test Class를 위한 처리
            if (!Test.isRunningTest()) query += ' AND KDCE_OutboundProgram__c IN:campaignIds ';  // Test Class를 위한 처리
            if (!Test.isRunningTest()) query += ' AND ContactId != null ';
//            if (!Test.isRunningTest()) query += ' AND ContactId IN :taskContactMap.values() ';
            if (!Test.isRunningTest()) query += ' AND ContactId IN :taskContactStrings ';
            List<Case> caseList = Database.query(query);

            Map<String, Case> parentCaseMap = new Map<String, Case>();
            for (Case tempCase : caseList) {
                parentCaseMap.put(getCampaignKey(tempCase), tempCase);
            }

            for (Task task : (List<Task>) Trigger.new) {
                if (task.Type == 'Call' && task.ConversationId__c != null && task.WhoId != null && task.WhatId == null && task.GC_CampaignId__c != null) {
                    System.debug('=== parentCaseMap : ' + parentCaseMap);
                    if (parentCaseMap.containsKey(getCampaignKey(task, campaignParentMap))) {
                        newCase = parentCaseMap.get(getCampaignKey(task, campaignParentMap));
                        newCase.KDCE_CallResult__c = task.CallDisposition;
                        newCase.Origin = 'Phone';
                        newCase.KDCE_ANI__c = task.ANI__c;
                        newCase.KDCE_RecordingURL__c = task.RecordingURL__c;
                        newCase.KDCE_IVR__c = task.IVR__c;
                        newCase.KDCE_ConversationId__c = task.ConversationId__c;
                        newCase.KDCE_CallDurationInSeconds__c = task.CallDurationInSeconds;
                        newCase.KDCE_CallType__c = task.CallType;
                        newCase.KDCE_CallResult__c = task.CallDisposition;
                        newCase.KDCE_CallDuration__c = task.CallDuration__c;
                        newCase.KDCE_ConnectedTime__c = task.ConnectedTime__c;
                        newCase.KDCE_AfterCallTime__c = task.AfterCallTime__c;
                        newCase.KDCE_DisconnectedTIme__c = task.DisconnectedTime__c;
                        newCase.CCR_Inbound_Outbound__c = 'Outbound';
                        taskCaseMap.put(task.Id, newCase);
                    } else {
                        newCase = new Case();
                        newCase.RecordTypeId = outboundRecordId;
                        wId = task.WhoId;

                        if (wId != null && wId.startsWith('003')) newCase.ContactId = task.WhoId;
                        newCase.KDCE_CallResult__c = task.CallDisposition;
                        newCase.Origin = 'Phone';
                        newCase.KDCE_ANI__c = task.ANI__c;
                        newCase.KDCE_RecordingURL__c = task.RecordingURL__c;
                        newCase.KDCE_IVR__c = task.IVR__c;
                        newCase.KDCE_ConversationId__c = task.ConversationId__c;
                        newCase.KDCE_CallDurationInSeconds__c = task.CallDurationInSeconds;
                        newCase.KDCE_CallType__c = task.CallType;
                        newCase.KDCE_CallResult__c = task.CallDisposition;
                        newCase.KDCE_CallDuration__c = task.CallDuration__c;
                        newCase.KDCE_ConnectedTime__c = task.ConnectedTime__c;
                        newCase.KDCE_AfterCallTime__c = task.AfterCallTime__c;
                        newCase.KDCE_DisconnectedTIme__c = task.DisconnectedTime__c;
                        newCase.CCR_Inbound_Outbound__c = 'Outbound';

                        if (campaignParentMap.containsKey(task.GC_CampaignId__c) && campaignParentMap.get(task.GC_CampaignId__c) != null) {
                            newCase.KDCE_OutboundProgram__c = campaignParentMap.get(task.GC_CampaignId__c).Id;
                            newCase.Subject = campaignParentMap.get(task.GC_CampaignId__c).Name ;
                        }

                        newCase.KDCE_OB_FirstAgent__c = UserInfo.getUserId();
                        newCase.KDCE_OB_FirstDate__c = Date.today();
                        taskCaseMap.put(task.Id, newCase);
                    }

                }


            }


        }


        // 신규 Case 생성
        if (!taskCaseMap.isEmpty()) {
            System.debug('=== taskCaseMap.values() : ' + taskCaseMap.values());
            /*if(!Test.isRunningTest())*/   upsert taskCaseMap.values();

            List<Task> taskList = [
                    SELECT Id,WhatId
                    FROM Task
                    WHERE Id IN:taskCaseMap.keySet()
                    AND WhatId = null
            ];
            //Task와 Case 매핑
            for (Task task : taskList) {
                task.WhatId = taskCaseMap.get(task.Id)?.Id;
            }
//            if (!taskList.isEmpty() && !Test.isRunningTest()) update taskList;
            if (!taskList.isEmpty() ) update taskList;
        }
    }

    private String getCampaignKey(Case newCase) {
        return newCase.KDCE_OutboundProgram__c + '' + newCase.ContactId;
    }
    private String getCampaignKey(Task task, Map<String, Campaign> campaignMap) {
        System.debug('=== campaignMap : ' + campaignMap);
        if (campaignMap.containsKey(task.GC_CampaignId__c)
                && campaignMap.get(task.GC_CampaignId__c) != null
                && task.WhoId != null) {
            return campaignMap.get(task.GC_CampaignId__c).Id + '' + task.WhoId;
        } else {
            return null;
        }
    }

//    private void mappingCaseWithTask() {
//        System.debug(' == mappingCaseWithTask == ');
//        List<Task> targetTask = new List<Task>();
//        List<Campaign> targetCampaignList = new List<Campaign>();
//        Set<String> CampaignIds = new Set<String>();
//
//        for (Task task : (List<Task>) Trigger.new) {
//            if(Trigger.isUpdate) {
//                Task oldTask = (Task) Trigger.oldMap.get(task.Id);
//                if ((task.GC_CampaignId__c == null && oldTask.GC_CampaignId__c != null)
//                        && task.WhatId <> null) {
//                    targetTask.add(task);
//                    CampaignIds.add(task.GC_CampaignId__c);
//                }
//            }
//        }
//
//        System.debug('start');
//        Map<String, Id> campaignMapByGCId = new Map<String, Id>();
//        if(CampaignIds <> null){
//            targetCampaignList = [SELECT Id, purecloud__PureCloud_Campaign_ID__c FROM Campaign WHERE purecloud__PureCloud_Campaign_ID__c IN : CampaignIds];
//            for(Campaign campaign : targetCampaignList){
//                campaignMapByGCId.put(campaign.purecloud__PureCloud_Campaign_ID__c, campaign.Id);
//            }
//        }
//
//        List<Case> updateCases = new List<Case>();
//        Case tempCase;
//        if (targetTask <> null) {
//            for (Task task : targetTask) {
//                tempCase = new Case(
//                        Id = task.WhatId,
//                        KDCE_OutboundProgram__c = campaignMapByGCId?.get(task.GC_CampaignId__c)
//                );
//                updateCases.add(tempCase);
//            }
//        }
//
//        if(!updateCases.isEmpty()) update updateCases;
//    }
}