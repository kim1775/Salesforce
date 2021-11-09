/**
 * @description       : Session close request callout service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 06-12-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   03-22-2021   Obidjon   Initial Version
 **/
public with sharing class EndSessionCallout {
    public static void process(Id kakaoConsultId) {
        Kakao_Consult_Chat__c consultChat = [
            SELECT Id, Session_Live__c, User_Key__c
            FROM Kakao_Consult_Chat__c
            WHERE Id = :kakaoConsultId
            WITH SECURITY_ENFORCED
        ];

        Map<String, Object> bodyMap = new Map<String, Object>();
        HttpResponse response = RestApiHelper.makeApiCall(
            'Kakao_Consult_Chat',
            RestApiHelper.RestMethod.POST,
            'https://kakao-apis.enomix.co.kr/v1/chat/end',
            bodyMap,
            consultChat.User_Key__c
        );
        try {
            if (response.getStatusCode() == 200) {
                consultChat.Session_Live__c = false;
                consultChat.Session_End_Time__c = System.now();
                if (Schema.SObjectType.Kakao_Consult_Chat__c.fields.Session_Live__c.isUpdateable()) {
                    update consultChat;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}