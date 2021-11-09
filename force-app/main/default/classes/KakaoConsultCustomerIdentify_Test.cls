/**
 * @description       : Test class for customer identify logic
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-23-2021   Obidjon   Initial Version
 **/
@isTest
private class KakaoConsultCustomerIdentify_Test {
    @testSetup
    private static void testSetup() {
        Case kakaoCase = new Case();
        kakaoCase.Subject = 'Test Case';
        insert kakaoCase;

        Kakao_Consult_Chat__c consultChat = new Kakao_Consult_Chat__c();
        consultChat.Case__c = kakaoCase.Id;
        consultChat.User_Key__c = 'testuserkey';
        insert consultChat;
    }

    @isTest
    private static void testDoPostCustomerInformation() {
        Case kakaoCase = [SELECT Id FROM Case LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        String bodyString = '{';
        bodyString += '"cid":"' + kakaoCase.Id + '",';
        bodyString += '"firstName":"First",';
        bodyString += '"lastName":"Last",';
        bodyString += '"phone":"01012341234",';
        bodyString += '"email":"email@mail.com",';
        bodyString += '"payload":"payload"';
        bodyString += '}';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(bodyString);
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        KakaoConsultCustomerIdentify.doPostCustomerInformation();
        System.assertEquals(200, response.statusCode, 'Failed status from doPostCustomerInformation');
        Test.stopTest();
    }
}