/**
 * @description       : Test class for Kakao consult session logic
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 05-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-23-2021   Obidjon   Initial Version
 **/
@isTest
private class KakaoConsultSessionController_Test {
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
            insert consultChat;

            Kakao_Chat_Feed__c chatFeed = new Kakao_Chat_Feed__c();
            chatFeed.Kakao_Consult_Chat__c = consultChat.Id;
            chatFeed.Message__c = 'Test Content';
            insert chatFeed;
        }
    }

    @isTest
    private static void testEndSession() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            Kakao_Consult_Chat__c consultChat = [SELECT Id FROM Kakao_Consult_Chat__c LIMIT 1];
            Test.startTest();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            CalloutUtilsMock calloutMock = new CalloutUtilsMock(headers, '{"status":"success"}', 200);
            Test.setMock(HttpCalloutMock.class, calloutMock);
            KakaoConsultSessionController.endSession(consultChat.Id);
            CRUDPermissionException crudPermissionException = new CRUDPermissionException('test', 'LAUNCH');
            Test.stopTest();
        }
    }

    @isTest
    private static void testSendIdentifyLink() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            Kakao_Chat_Feed__c chatFeed = [SELECT Id FROM Kakao_Chat_Feed__c LIMIT 1];
            Test.startTest();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            CalloutUtilsMock calloutMock = new CalloutUtilsMock(headers, '{"status": "success"}', 200);
            Test.setMock(HttpCalloutMock.class, calloutMock);
            KakaoConsultSessionController.sendIdentifyLink(chatFeed.Id);
            Test.stopTest();
        }
    }
}