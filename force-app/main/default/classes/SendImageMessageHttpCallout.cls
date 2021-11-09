/**
 * @description       : Image send service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-05-2021   Obidjon   Initial Version
 **/
public with sharing class SendImageMessageHttpCallout {
    @future(callout=true)
    public static void process(Id kakaoChatFeedId) {
        Kakao_Chat_Feed__c chatFeed = [
            SELECT Id, Image_Url__c, User_Key_fm__c
            FROM Kakao_Chat_Feed__c
            WHERE Id = :kakaoChatFeedId
            WITH SECURITY_ENFORCED
        ];

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('serial_number', chatFeed.Id);
        bodyMap.put('message_type', 'IM');
        bodyMap.put('image_url', chatFeed.Image_Url__c);

        HttpResponse response = RestApiHelper.makeApiCall(
            'Kakao_Consult_Chat',
            RestApiHelper.RestMethod.POST,
            '/v1/chat/write',
            bodyMap,
            chatFeed.User_Key_fm__c
        );
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