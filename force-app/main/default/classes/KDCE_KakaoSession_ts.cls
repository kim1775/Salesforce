/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-08-05 오후 3:49
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
    0.1     2021-08-05 오후 3:49     i2max_Junseok.Kwon        Create
****************************************************************************************/

@IsTest
private class KDCE_KakaoSession_ts {

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

    @IsTest
    static void testBehavior() {

        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            Kakao_Consult_Chat__c consultChat = [SELECT Id FROM Kakao_Consult_Chat__c LIMIT 1];
            Test.startTest();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            CalloutUtilsMock calloutMock = new CalloutUtilsMock(headers, '{"status":"success"}', 200);
            Test.setMock(HttpCalloutMock.class, calloutMock);
            KDCE_KakaoSession.closeSession(consultChat.Id);
            CRUDPermissionException crudPermissionException = new CRUDPermissionException('test', 'LAUNCH');
            Test.stopTest();
        }
    }
}