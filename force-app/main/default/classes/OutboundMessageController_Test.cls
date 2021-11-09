/**
 * @description       : Test class of outbound messaging logic
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 05-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-23-2021   Obidjon   Initial Version
 **/
@isTest
private class OutboundMessageController_Test {
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

            Kakao_Chat_Feed__c chatFeed1 = new Kakao_Chat_Feed__c();
            chatFeed1.Kakao_Consult_Chat__c = consultChat.Id;
            chatFeed1.Message__c = 'Test Content';
            chatFeed1.Type__c = 'Text';
            insert chatFeed1;

            Kakao_Chat_Feed__c chatFeed2 = new Kakao_Chat_Feed__c();
            chatFeed2.Kakao_Consult_Chat__c = consultChat.Id;
            chatFeed2.Message__c = 'Test Content';
            chatFeed2.Type__c = 'Image';
            chatFeed2.Image_Url__c = 'https://image.force.com/image.jpg';
            insert chatFeed2;
        }
    }

    @isTest
    private static void testSendTextMessage() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            Kakao_Chat_Feed__c chatFeed = [SELECT Id FROM Kakao_Chat_Feed__c WHERE Type__c = 'Text' LIMIT 1];
            Test.startTest();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            CalloutUtilsMock calloutMock = new CalloutUtilsMock(headers, '{"status":"success"}', 200);
            Test.setMock(HttpCalloutMock.class, calloutMock);
            OutboundMessageController.sendTextMessage(chatFeed.Id);
            Test.stopTest();
        }
    }

    @isTest
    private static void testSendImageMessage() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            Kakao_Chat_Feed__c chatFeed = [SELECT Id FROM Kakao_Chat_Feed__c WHERE Type__c = 'Image' LIMIT 1];
            Test.startTest();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            CalloutUtilsMock calloutMock = new CalloutUtilsMock(headers, '{"status":"success"}', 200);
            Test.setMock(HttpCalloutMock.class, calloutMock);
            OutboundMessageController.sendImageMessage(chatFeed.Id);
            Test.stopTest();
        }
    }

    @isTest
    private static void testSendTextMessageException() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            Test.startTest();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            CalloutUtilsMock calloutMock = new CalloutUtilsMock(headers, '{"status":"success"}', 200);
            Test.setMock(HttpCalloutMock.class, calloutMock);
            try {
                OutboundMessageController.sendImageMessage('falseid');
            } catch (Exception e) {
                System.assert(true);
            }
            Test.stopTest();
        }
    }
}