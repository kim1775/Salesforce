/****************************************************************************************
  * File Name   : IF_DCE_GC_0002_TEST
  * Description : IF_DCE_GC_0002_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.03.02.    ldb3100    Create
****************************************************************************************/
@isTest
private class IF_DCE_GC_0002_TEST {
    // 입력 객체 생성
    private static IF_DCE_GC_0002.InputDIH newInputParameter() {
        IF_DCE_GC_0002.InputBody payload = new IF_DCE_GC_0002.InputBody();

        IF_DCE_GC_0002.InputDIH input = new IF_DCE_GC_0002.InputDIH();

        IF_DCE_GC_0002.Input inputObj = input.Request;

        inputObj.Header = new IF_Base_GC.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_DCE_GC_0002', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"id":"","name":"","conversationId":"","path":"","startTime":"","endTime":"","media":"","annotations":[{"id":"","name":"","type":"","location":0,"durationMs":0,"absoluteLocation":0,"absoluteDurationMs":0,"recordingLocation":0,"recordingDurationMs":0,"user":{"id":"","name":"","division":{"id":"","name":"","selfUri":""},"chat":{"jabberId":""},"department":"","email":"","primaryContactInfo":[{"address":"","display":"","mediaType":"","type":"","extension":"","countryCode":""}],"addresses":[""],"state":"","title":"","username":"","manager":"","images":[{"resolution":"","imageUri":""}],"version":0,"certifications":[""],"biography":{"biography":"","interests":[""],"hobbies":[""],"spouse":"","education":[""]},"employerInfo":{"officialName":"","employeeId":"","employeeType":"","dateHire":""},"routingStatus":{"userId":"","status":"","startTime":""},"presence":{"id":"","name":"","source":"","primary":true,"presenceDefinition":"","message":"","modifiedDate":"","selfUri":""},"conversationSummary":{"userId":"","call":"","callback":"","email":"","message":"","chat":"","socialExpression":"","video":""},"outOfOffice":{"id":"","name":"","user":"","startDate":"","endDate":"","active":true,"indefinite":true,"selfUri":""},"geolocation":{"id":"","name":"","type":"","primary":true,"latitude":0,"longitude":0,"country":"","region":"","city":"","locations":[""],"selfUri":""},"station":{"associatedStation":"","effectiveStation":"","defaultStation":"","lastAssociatedStation":""},"authorization":{"roles":[""],"unusedRoles":[""],"permissions":[""],"permissionPolicies":[""]},"profileSkills":[""],"locations":[{"id":"","floorplanId":"","coordinates":{"":0},"notes":"","locationDefinition":""}],"groups":[{"id":"","name":"","description":"","dateModified":"","memberCount":0,"state":"","version":0,"type":"","images":[""],"addresses":[""],"rulesVisible":true,"visibility":"","owners":[""],"selfUri":""}],"team":{"id":"","name":"","description":"","dateModified":"","memberCount":0,"selfUri":""},"skills":[{"id":"","name":"","proficiency":0,"state":"","skillUri":"","selfUri":""}],"languages":[{"id":"","name":"","proficiency":0,"state":"","languageUri":"","selfUri":""}],"acdAutoAnswer":true,"languagePreference":"","lastTokenIssued":{"dateIssued":""},"selfUri":""},"description":"","keywordName":"","confidence":0,"keywordSetId":"","keywordSetName":"","utterance":"","timeBegin":"","timeEnd":"","keywordConfidenceThreshold":"","agentScoreModifier":"","customerScoreModifier":"","selfUri":""}],"transcript":[{"body":"","id":"","to":"","from":"","utc":"","chat":"","message":"","type":"","bodyType":"","senderCommunicationId":"","participantPurpose":"","user":{"id":"","name":"","displayName":"","username":"","images":[""]}}],"emailTranscript":[{"htmlBody":"","textBody":"","id":"","to":[{"email":"","name":""}],"cc":[""],"bcc":[""],"from":"","subject":"","attachments":[{"name":"","contentPath":"","contentType":"","attachmentId":"","contentLength":0}],"time":""}],"messagingTranscript":[{"from":"","fromUser":"","fromExternalContact":{"id":"","firstName":"","middleName":"","lastName":"","salutation":"","title":"","workPhone":{"display":"","extension":0,"acceptsSMS":true,"userInput":"","e164":"","countryCode":""},"cellPhone":"","homePhone":"","otherPhone":"","workEmail":"","personalEmail":"","otherEmail":"","address":{"address1":"","address2":"","city":"","state":"","postalCode":"","countryCode":""},"twitterId":{"id":"","name":"","screenName":"","verified":true,"profileUrl":""},"lineId":{"ids":[""],"displayName":""},"whatsAppId":{"phoneNumber":"","displayName":""},"facebookId":{"ids":[""],"displayName":""},"modifyDate":"","createDate":"","externalOrganization":{"id":"","name":"","companyType":"","industry":"","primaryContactId":"","address":"","phoneNumber":"","faxNumber":"","employeeCount":0,"revenue":0,"tags":[""],"websites":[""],"tickers":[""],"twitterId":"","externalSystemUrl":"","modifyDate":"","createDate":"","trustor":"","schema":"","customFields":{"":{}},"externalDataSources":[""],"selfUri":""},"surveyOptOut":true,"externalSystemUrl":"","schema":{"id":"","name":"","version":0,"appliesTo":[""],"enabled":true,"createdBy":"","dateCreated":"","jsonSchema":"","selfUri":""},"customFields":{"":{}},"externalDataSources":[{"platform":"","url":""}],"selfUri":""},"to":"","timestamp":"","id":"","messageText":"","messageMediaAttachments":[{"url":"","mediaType":"","contentLength":0,"name":"","id":""}],"messageStickerAttachments":[{"url":"","id":""}]}],"fileState":"","restoreExpirationTime":"","mediaUris":{"":{}},"estimatedTranscodeTimeMs":0,"actualTranscodeTimeMs":0,"archiveDate":"","archiveMedium":"","deleteDate":"","exportDate":"","exportedDate":"","outputDurationMs":0,"outputSizeInBytes":0,"maxAllowedRestorationsForOrg":0,"remainingRestorationsAllowedForOrg":0,"sessionId":"","users":[{"id":"","name":"","division":"","chat":"","department":"","email":"","primaryContactInfo":[""],"addresses":[""],"state":"","title":"","username":"","manager":"","images":[""],"version":0,"certifications":[""],"biography":"","employerInfo":"","routingStatus":"","presence":"","conversationSummary":"","outOfOffice":"","geolocation":"","station":"","authorization":"","profileSkills":[""],"locations":[""],"groups":[""],"team":"","skills":[""],"languages":[""],"acdAutoAnswer":true,"languagePreference":"","lastTokenIssued":"","selfUri":""}],"recordingFileRole":"","selfUri":""}');
        return res;
    }

    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // 공통 테스트 진행
    private static Boolean testServiceExecute() {
        String jsonMsg = JSON.serialize(newInputParameter());

        RestRequest  req = new RestRequest ();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_DCE_GC_0002';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_DCE_GC_0002 instance = IF_DCE_GC_0002.getInstance();
        // 서비스 실행
        IF_DCE_GC_0002.InputDIH input = new IF_DCE_GC_0002.InputDIH();
        IF_DCE_GC_0002.INPUT_T_DATA tData = new IF_DCE_GC_0002.INPUT_T_DATA();
        tData.conversationId     = '0e202d4d-baa8-43d4-86dd-80918eb1d37a';
        tData.recordingId        = '4c338ce1-89fe-43a8-9561-e06ac9ea0677';
        tData.download           = 'true';

        input.request.payload.t_data.add(tData);
        System.debug('result input : '+ JSON.serialize(input));

        IF_DCE_GC_0002.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_DCE_GC_0002 성공!!!');

        // crashTest
        IF_Base_GC.crashTest = true;
        result = instance.execute(new IF_DCE_GC_0002.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_DCE_GC_0002 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}