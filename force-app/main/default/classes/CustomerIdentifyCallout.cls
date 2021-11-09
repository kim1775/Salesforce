/**
 * @description       : Customer identity link sending callout service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-14-2021   Obidjon   Initial Version
 **/
public with sharing class CustomerIdentifyCallout {
    public static void process(Id kakaoChatFeedId) {
        Kakao_Chat_Feed__c chatFeed = [
            SELECT Id, Message__c, User_Key_fm__c, Kakao_Consult_Chat__r.Case__c
            FROM Kakao_Chat_Feed__c
            WHERE Id = :kakaoChatFeedId
            WITH SECURITY_ENFORCED
        ];

        KakaoConsultDealerCredentials__c dealerCredentials = KakaoConsultDealerCredentials__c.getOrgDefaults();
        chatFeed.Message__c = 'Identifier link';

        String identifierLink =
            dealerCredentials.Customer_Identify_Url__c +
            'cid=' +
            chatFeed.Kakao_Consult_Chat__r.Case__c;

        List<Map<String, Object>> linkJsonObject = new List<Map<String, Object>>();
        linkJsonObject.add(new Map<String, Object>());
        linkJsonObject.get(0).put('name', '고객 정보 입력');
        linkJsonObject.get(0).put('type', 'WL');
        linkJsonObject.get(0).put('url_mobile', identifierLink);
        linkJsonObject.get(0).put('url_pc', identifierLink);

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('serial_number', chatFeed.Id);
        bodyMap.put('message_type', 'LI');
        bodyMap.put('message', '보다 빠르고 정확한 서비스 제공 위해서 개인 정보 입력해주세요!');
        bodyMap.put('links', linkJsonObject);

        HttpResponse response = RestApiHelper.makeApiCall(
            'Kakao_Consult_Chat',
            RestApiHelper.RestMethod.POST,
            'https://kakao-apis.enomix.co.kr/v1/chat/write',
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