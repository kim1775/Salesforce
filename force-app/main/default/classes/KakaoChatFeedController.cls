/**
 * @description       : Kakao Chat feed controller
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-25-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   03-09-2021   Obidjon   Initial Version
 **/
public with sharing class KakaoChatFeedController {
    @AuraEnabled(cacheable=true)
    public static List<Kakao_Chat_Feed__c> getKakaoChatFeeds(Id caseId) {
        try {
            Kakao_Consult_Chat__c kakaoConsultChat = [
                SELECT Id, Case__c
                FROM Kakao_Consult_Chat__c
                WHERE Case__r.Id = :caseId
                WITH SECURITY_ENFORCED
            ];

            List<Kakao_Chat_Feed__c> chatFeeds = [
                SELECT
                    Id,
                    Message__c,
                    Image_Url__c,
                    File_Url__c,
                    Sender__c,
                    Sent_Time__c,
                    Status__c,
                    Type__c,
                    IsAgent__c,
                    Kakao_Consult_Chat__c,
                    Session_Live_fm__c
                FROM Kakao_Chat_Feed__c
                WHERE Kakao_Consult_Chat__c = :kakaoConsultChat.Id
                WITH SECURITY_ENFORCED
                ORDER BY Sent_Time__c
            ];

            for (Kakao_Chat_Feed__c chatFeed : chatFeeds) {
                chatFeed.Sent_Time_formatted__c = chatFeed.Sent_Time__c.format(
                    'HH:mm',
                    UserInfo.getTimeZone().toString()
                );
            }

            return chatFeeds;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}