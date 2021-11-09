/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 06-13-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-23-2021   Obidjon   Initial Version
 **/
@isTest
private class InboundExpiredSessionRestService_Test {
    @testSetup
    private static void testSetup() {
        User standardUser = KakaoTestUtils.createUser('Standard User');
        KakaoTestUtils.assignPermissionSet('KakaoConsult_User', standardUser.Id);

        System.runAs(standardUser) {
            KakaoConsultDealerCredentials__c dealerCredentials = new KakaoConsultDealerCredentials__c();
            dealerCredentials.Channel_Secret__c = 'channelsecret';
            dealerCredentials.Sender_Key__c = 'senderkey';
            dealerCredentials.JWT_Token__c = 'jwtToken';
            dealerCredentials.Customer_Identify_Url__c = 'https://test.ap24.force.com';
            insert dealerCredentials;

            Case kakaoCase = new Case();
            kakaoCase.Subject = 'Test Case';
            insert kakaoCase;

            Kakao_Consult_Chat__c consultChat = new Kakao_Consult_Chat__c();
            consultChat.Case__c = kakaoCase.Id;
            consultChat.User_Key__c = 'testuserkey';
            consultChat.Session_Live__c = true;
            insert consultChat;
        }
    }

    @isTest
    private static void testDoPostExpireSession() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = '/services/apexrest/expired_session';
            request.httpMethod = 'POST';
            String body = '{';
            body += '"user_key": "testuserkey",';
            body += '"sender_key": "senderkey",';
            body += '"session_id": "sessionid",';
            body += '"payload": "payload"';
            body += '}';
            request.requestBody = Blob.valueOf(body);
            Test.startTest();
            RestContext.request = request;
            RestContext.response = response;
            InboundExpiredSessionRestService.doPostExpireSession();
            System.assertEquals(200, response.statusCode, 'Failed status of doPostExpireSession');
            Test.stopTest();
        }
    }
}