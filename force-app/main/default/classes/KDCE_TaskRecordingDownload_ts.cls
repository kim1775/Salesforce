/****************************************************************************************
  * @filename      : KDCE_TaskRecordingDownload_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-17 오전 11:33
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
    0.1     2021-06-17 오전 11:33     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_TaskRecordingDownload_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        Task task = KDCE_TestBizUtil.testTask;
        System.debug('=== task : ' + task);
        String taskId = task.Id;

        // Wrapper Class 생성
        KDCE_TaskRecordingDownload.RecordingWrapper rw = new KDCE_TaskRecordingDownload.RecordingWrapper();
        rw.conversationId = 'Test Conversation Id';
        rw.recordingId = taskId;

        KDCE_TaskRecordingDownload.getRecord(taskId);
        KDCE_TaskRecordingDownload.getRecording('Test Conversation Id', taskId);
        KDCE_TaskRecordingDownload.setAudit(rw);
        KDCE_TaskRecordingDownload.getRecordingAPI('Test Conversation Id');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"id":"","name":"","conversationId":"","path":"","startTime":"","endTime":"","media":"","annotations":[{"id":"","name":"","type":"","location":0,"durationMs":0,"absoluteLocation":0,"absoluteDurationMs":0,"recordingLocation":0,"recordingDurationMs":0,"user":{"id":"","name":"","division":{"id":"","name":"","selfUri":""},"chat":{"jabberId":""},"department":"","email":"","primaryContactInfo":[{"address":"","display":"","mediaType":"","type":"","extension":"","countryCode":""}],"addresses":[""],"state":"","title":"","username":"","manager":"","images":[{"resolution":"","imageUri":""}],"version":0,"certifications":[""],"biography":{"biography":"","interests":[""],"hobbies":[""],"spouse":"","education":[""]},"employerInfo":{"officialName":"","employeeId":"","employeeType":"","dateHire":""},"routingStatus":{"userId":"","status":"","startTime":""},"presence":{"id":"","name":"","source":"","primary":true,"presenceDefinition":"","message":"","modifiedDate":"","selfUri":""},"conversationSummary":{"userId":"","call":"","callback":"","email":"","message":"","chat":"","socialExpression":"","video":""},"outOfOffice":{"id":"","name":"","user":"","startDate":"","endDate":"","active":true,"indefinite":true,"selfUri":""},"geolocation":{"id":"","name":"","type":"","primary":true,"latitude":0,"longitude":0,"country":"","region":"","city":"","locations":[""],"selfUri":""},"station":{"associatedStation":"","effectiveStation":"","defaultStation":"","lastAssociatedStation":""},"authorization":{"roles":[""],"unusedRoles":[""],"permissions":[""],"permissionPolicies":[""]},"profileSkills":[""],"locations":[{"id":"","floorplanId":"","coordinates":{"":0},"notes":"","locationDefinition":""}],"groups":[{"id":"","name":"","description":"","dateModified":"","memberCount":0,"state":"","version":0,"type":"","images":[""],"addresses":[""],"rulesVisible":true,"visibility":"","owners":[""],"selfUri":""}],"team":{"id":"","name":"","description":"","dateModified":"","memberCount":0,"selfUri":""},"skills":[{"id":"","name":"","proficiency":0,"state":"","skillUri":"","selfUri":""}],"languages":[{"id":"","name":"","proficiency":0,"state":"","languageUri":"","selfUri":""}],"acdAutoAnswer":true,"languagePreference":"","lastTokenIssued":{"dateIssued":""},"selfUri":""},"description":"","keywordName":"","confidence":0,"keywordSetId":"","keywordSetName":"","utterance":"","timeBegin":"","timeEnd":"","keywordConfidenceThreshold":"","agentScoreModifier":"","customerScoreModifier":"","selfUri":""}],"transcript":[{"body":"","id":"","to":"","from":"","utc":"","chat":"","message":"","type":"","bodyType":"","senderCommunicationId":"","participantPurpose":"","user":{"id":"","name":"","displayName":"","username":"","images":[""]}}],"emailTranscript":[{"htmlBody":"","textBody":"","id":"","to":[{"email":"","name":""}],"cc":[""],"bcc":[""],"from":"","subject":"","attachments":[{"name":"","contentPath":"","contentType":"","attachmentId":"","contentLength":0}],"time":""}],"messagingTranscript":[{"from":"","fromUser":"","fromExternalContact":{"id":"","firstName":"","middleName":"","lastName":"","salutation":"","title":"","workPhone":{"display":"","extension":0,"acceptsSMS":true,"userInput":"","e164":"","countryCode":""},"cellPhone":"","homePhone":"","otherPhone":"","workEmail":"","personalEmail":"","otherEmail":"","address":{"address1":"","address2":"","city":"","state":"","postalCode":"","countryCode":""},"twitterId":{"id":"","name":"","screenName":"","verified":true,"profileUrl":""},"lineId":{"ids":[""],"displayName":""},"whatsAppId":{"phoneNumber":"","displayName":""},"facebookId":{"ids":[""],"displayName":""},"modifyDate":"","createDate":"","externalOrganization":{"id":"","name":"","companyType":"","industry":"","primaryContactId":"","address":"","phoneNumber":"","faxNumber":"","employeeCount":0,"revenue":0,"tags":[""],"websites":[""],"tickers":[""],"twitterId":"","externalSystemUrl":"","modifyDate":"","createDate":"","trustor":"","schema":"","customFields":{"":{}},"externalDataSources":[""],"selfUri":""},"surveyOptOut":true,"externalSystemUrl":"","schema":{"id":"","name":"","version":0,"appliesTo":[""],"enabled":true,"createdBy":"","dateCreated":"","jsonSchema":"","selfUri":""},"customFields":{"":{}},"externalDataSources":[{"platform":"","url":""}],"selfUri":""},"to":"","timestamp":"","id":"","messageText":"","messageMediaAttachments":[{"url":"","mediaType":"","contentLength":0,"name":"","id":""}],"messageStickerAttachments":[{"url":"","id":""}]}],"fileState":"","restoreExpirationTime":"","mediaUris":{"":{}},"estimatedTranscodeTimeMs":0,"actualTranscodeTimeMs":0,"archiveDate":"","archiveMedium":"","deleteDate":"","exportDate":"","exportedDate":"","outputDurationMs":0,"outputSizeInBytes":0,"maxAllowedRestorationsForOrg":0,"remainingRestorationsAllowedForOrg":0,"sessionId":"","users":[{"id":"","name":"","division":"","chat":"","department":"","email":"","primaryContactInfo":[""],"addresses":[""],"state":"","title":"","username":"","manager":"","images":[""],"version":0,"certifications":[""],"biography":"","employerInfo":"","routingStatus":"","presence":"","conversationSummary":"","outOfOffice":"","geolocation":"","station":"","authorization":"","profileSkills":[""],"locations":[""],"groups":[""],"team":"","skills":[""],"languages":[""],"acdAutoAnswer":true,"languagePreference":"","lastTokenIssued":"","selfUri":""}],"recordingFileRole":"","selfUri":""}'));
        KDCE_TaskRecordingDownload.getRecordingWrapper('Test Conversation Id', taskId);
        Test.stopTest();

    }


}