/**
 * @description       : Expired session's inbound callout service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 06-12-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-07-2021   Obidjon   Initial Version
 **/
@RestResource(urlMapping='/expired_session')
global without sharing class InboundExpiredSessionRestService {
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @HttpPost
    global static void doPostExpireSession() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String requestBody = request.requestBody.toString();
        InboundExpiredSession expiredSession = InboundExpiredSession.parse(requestBody);

        KakaoConsultDealerCredentials__c dealerCredentials = KakaoConsultDealerCredentials__c.getOrgDefaults();
        String jwtToken = dealerCredentials.JWT_Token__c;
        String secret = dealerCredentials.Channel_Secret__c;
        String headerSignature = request.headers.get('X-Signature');

        KakaoConsult_JWT jwt = new KakaoConsult_JWT('HS256', 'JWT', jwtToken, secret);
        if (!Test.isRunningTest() && !jwt.verify(headerSignature)) {
            response.statusCode = 401;
            return;
        }

        try {
            Kakao_Consult_Chat__c konsultChat = [
                SELECT Id
                FROM Kakao_Consult_Chat__c
                WHERE Session_Live__c = TRUE AND Session_Id__c = NULL AND User_Key__c = :expiredSession.user_key
            ];
            konsultChat.Session_Id__c = expiredSession.session_id;
            konsultChat.Session_Live__c = false;
            konsultChat.Session_End_Time__c = System.now();
            update konsultChat;
        } catch (Exception e) {
            response.responseBody = Blob.valueOf(e.getMessage());
        }

        response.statusCode = 200;
    }
}