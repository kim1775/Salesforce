/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 06-13-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   06-13-2021   Obidjon   Initial Version
 **/
@isTest
private class InboundReferenceRestService_Test {
    @testSetup
    private static void testSetup() {
        KakaoConsultDealerCredentials__c dealerCredentials = new KakaoConsultDealerCredentials__c();
        dealerCredentials.Channel_Secret__c = 'channelsecret';
        dealerCredentials.Sender_Key__c = 'senderkey';
        dealerCredentials.JWT_Token__c = 'jwtToken';
        dealerCredentials.Customer_Identify_Url__c = 'https://test.ap24.force.com';
        insert dealerCredentials;
    }

    @isTest
    private static void doPostReference() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/reference';
        request.httpMethod = 'POST';
        String body = '{';
        body += '"user_key": "aEmSUzBR1OsV",';
        body += '"sender_key": "6f77c070905056b409a5125ef96c99ab659c2b34",';
        body += '"app_user_id": "123456",';
        body += '"time": 1.623491429556e12,';
        body += '"reference": { "extra": "", "text": "", "lastText": "", "lastTextDate": "", "appUserId": null },';
        body += '"last_reference": { "extra": "", "bot": "", "bot_event": "", "created_at": "" }';
        body += '}';

        request.requestBody = Blob.valueOf(body);
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        InboundReferenceRestService.doPostReference();
        System.assertEquals(200, response.statusCode, 'Failed status of doPostExpireSession');
        Test.stopTest();
    }
}