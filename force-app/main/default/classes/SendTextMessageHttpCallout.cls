/**
 * @description       : Text message send service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 06-17-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   03-22-2021   Obidjon   Initial Version
 **/
public without sharing class SendTextMessageHttpCallout {
    @future(callout=true)
    public static void process(Id kakaoChatFeedId) {
        Kakao_Chat_Feed__c chatFeed = [
            SELECT Id, Message__c, User_Key_fm__c, Status__c
            FROM Kakao_Chat_Feed__c
            WHERE Id = :kakaoChatFeedId
            WITH SECURITY_ENFORCED
        ];

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('serial_number', chatFeed.Id);
        bodyMap.put('message_type', 'TX');
        bodyMap.put('message', chatFeed.Message__c);

        HttpResponse response = RestApiHelper.makeApiCall(
            'Kakao_Consult_Chat',
            RestApiHelper.RestMethod.POST,
            'https://kakao-apis.enomix.co.kr/v1/chat/write',
            bodyMap,
            chatFeed.User_Key_fm__c
        );

        if (chatFeed.Status__c == 'Success') {
            return;
        }
        try {
            if (Schema.SObjectType.Kakao_Chat_Feed__c.fields.Status__c.isUpdateable()) {
                chatFeed.Status__c = response.getStatusCode() == 200 ? 'Success' : 'Error';
                update chatFeed;
            } else {
                throw new CRUDPermissionException('No update permission on Status of Kakao_Chat_Feed object');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}