/**
 * @description       : Test class for Kakao chat feed controller
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 05-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-23-2021   Obidjon   Initial Version
 **/
@isTest
private class KakaoChatFeedController_Test {
    @testSetup
    private static void testSetup() {
        User standardUser = KakaoTestUtils.createUser('Standard User');
        KakaoTestUtils.assignPermissionSet('KakaoConsult_User', standardUser.Id);

        System.runAs(standardUser) {
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
    private static void testGetKakaoChatFeeds() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            Case kakaoCase = [SELECT Id FROM Case LIMIT 1];
            Test.startTest();
            List<Kakao_Chat_Feed__c> chatFeeds = KakaoChatFeedController.getKakaoChatFeeds(kakaoCase.Id);
            System.assertEquals(1, chatFeeds.size(), 'Failed to retrieve chat feeds from getKakaoChatFeeds');
            Test.stopTest();
        }
    }
}