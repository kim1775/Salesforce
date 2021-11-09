/****************************************************************************************
  * @filename      : KDCE_Task_tr_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-14 오후 2:58
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-06-14 오후 2:58     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_Task_tr_ts {
    static Map<String, Id> caseRecordTypeMap = KDCE_Util.getRecordTypeBySObject('Case');

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        List<Task> taskList = new List<Task>();

        Task newTask = new Task();
        newTask.Type = 'Call';
        newTask.ConversationId__c = 'Test Conversation Id';
        newTask.WhoId = KDCE_TestUtil.getContactMember().Id;
        newTask.CallType = 'Inbound';
//        newTask.WhatId = KDCE_TestUtil.getCaseItem().Id;
//        newTask.GC_Campaign_ID__c = '984e1970-a860-4e81-8f8c-03ca577271fd';
        taskList.add(newTask);
        System.debug('=== taskList : ' + taskList);

        Task newTask2 = newTask.clone(false, true);
        newTask2.WhoId = KDCE_TestUtil.getContactMember().Id;
        taskList.add(newTask2);

        Task newTask3 = newTask.clone(false, true);
        newTask3.GC_CampaignId__c = '984e1970-a860-4e81-8f8c-03ca577271fd';
        taskList.add(newTask3);
        insert taskList;

        newTask.CallDisposition = 'Call Dis';
        update newTask;

    }

    @IsTest
    static void testBehavior2() {

        // Campaign 생성
        List<Campaign> campaigns = new List<Campaign>();
        List<Campaign> updateCampaigns = new List<Campaign>();
        Campaign campaign = new Campaign();
//        campaign.purecloud__PureCloud_Campaign_ID__c = 'CamId001';
        campaign.Type = 'Type';
        campaign.Name = 'Campaing001';
        campaigns.add(campaign);

        Campaign campaign2 = new Campaign();
        campaign2.Name = 'Campaing002';
        campaigns.add(campaign2);

        Campaign campaign3 = new Campaign();
        campaign3.Name = 'Campaing003';
        campaigns.add(campaign3);

        insert campaigns;

        campaign3.ParentId = campaign2.Id;
        campaign2.ParentId = campaign.Id;
        updateCampaigns.add(campaign3);
        updateCampaigns.add(campaign2);

        update updateCampaigns;

        // Case 생성
        Case case2 = new Case();
        case2.Subject = 'Test';
        case2.ContactId = KDCE_TestUtil.getContactMember().Id;
        case2.KDCE_OutboundProgram__c = campaign3.Id;
        case2.RecordTypeId = caseRecordTypeMap.get('KDCE_OutboundProgram');
        //case2.CCR_SubType__c ='Lead Generation';
        //case2.CCR_SubjectCodeNew__c ='Remote Coach';
        insert case2;
        System.debug('=== case2 : ' + case2);

        // Task 생성
        List<Task> taskList = new List<Task>();
        Task newTask = new Task();
        newTask.Type = 'Call';
        newTask.ConversationId__c = 'Test Conversation Id';
        newTask.WhoId = KDCE_TestUtil.getContactMember().Id;
        newTask.WhatId = case2.Id;
        newTask.CallType = 'Inbound';
        newTask.GC_CampaignId__c = campaign.purecloud__PureCloud_Campaign_ID__c;//'984e1970-a860-4e81-8f8c-03ca577271fd';
        newTask.CallDisposition = 'CallDisposition';
        taskList.add(newTask);
        System.debug('=== taskList : ' + taskList);

        insert taskList;

        newTask.CallDisposition = 'CallDisposition22';
        update newTask;

    }


}