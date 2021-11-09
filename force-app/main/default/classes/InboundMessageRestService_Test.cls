/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 04-25-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-25-2021   Obidjon   Initial Version
 **/
@isTest
private with sharing class InboundMessageRestService_Test {
    @testSetup
    private static void testSetup() {
        KakaoConsultDealerCredentials__c dealerCredentials = new KakaoConsultDealerCredentials__c();
        dealerCredentials.Channel_Secret__c = 'channelsecret';
        dealerCredentials.Sender_Key__c = 'senderkey';
        dealerCredentials.JWT_Token__c = 'jwtToken';
        dealerCredentials.Customer_Identify_Url__c = 'https://test.ap24.force.com';
        insert dealerCredentials;

        Case kakaoCase = new Case();
        kakaoCase.Subject = 'Test Case';
        insert kakaoCase;
    }

    @isTest
    private static void testDoPostExpireSession() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/expired_session';
        request.httpMethod = 'POST';
        String body = '{';
        body += '"user_key": "testuserkey",';
        body += '"sender_key": "senderkey",';
        body += '"session_id": "sessionid",';
        body += '"time": 1235567813,';
        body += '"serial_number": "12345",';
        body += '"type": "text",';
        body += '"content": "message",';
        body += '"attachment": {"url": "url"},';
        body += '"extra": "extra",';
        body += '"payload": "payload"';
        body += '}';
        request.requestBody = Blob.valueOf(body);
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        InboundMessageRestService.doPostMessages();
        System.assertEquals(200, response.statusCode, 'Failed status of doPostExpireSession');
        Test.stopTest();
    }
}