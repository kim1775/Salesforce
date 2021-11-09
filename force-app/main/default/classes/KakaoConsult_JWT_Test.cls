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
private class KakaoConsult_JWT_Test {
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
    private static void testVerify() {
        KakaoConsultDealerCredentials__c dealerCredentials = KakaoConsultDealerCredentials__c.getOrgDefaults();
        String jwtToken = dealerCredentials.JWT_Token__c;
        String secret = dealerCredentials.Channel_Secret__c;
        String headerSignature = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqd3RUb2tlbiI6Imp3dFRva2VuIn0.i-dbIe0W3r6s84IysAxlWa_fL4yrmutImUlay7Z9AIU';

        KakaoConsult_JWT jwt = new KakaoConsult_JWT('HS256', 'JWT', jwtToken, secret);
        System.assert(jwt.verify(headerSignature), 'JWT verification failed');
    }
}