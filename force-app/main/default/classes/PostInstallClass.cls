/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 06-14-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-25-2021   Obidjon   Initial Version
 **/
global class PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            List<PushTopic> customerChat = [SELECT Id FROM PushTopic WHERE Name = 'KakaoConsultChatCustomer'];
            if (customerChat == null || customerChat.size() == 0) {
                PushTopic pushTopic = new PushTopic();
                pushTopic.Name = 'KakaoConsultChatCustomer';
                pushTopic.Query = 'Select Id, Kakao_Consult_Chat__c from Kakao_Chat_Feed__c';
                pushTopic.ApiVersion = 51.0;
                pushTopic.NotifyForOperationCreate = true;
                pushTopic.NotifyForOperationUpdate = true;
                pushTopic.NotifyForOperationUndelete = true;
                pushTopic.NotifyForOperationDelete = true;
                pushTopic.NotifyForFields = 'All';
                if (!Test.isRunningTest()) {
                    insert pushTopic;
                }
            }

            List<PushTopic> expiredChatTopic = [SELECT Id FROM PushTopic WHERE Name = 'KakaoConsultChatExpired'];
            if (expiredChatTopic == null || expiredChatTopic.size() == 0) {
                PushTopic topic = new PushTopic();
                topic.Name = 'KakaoConsultChatExpired';
                topic.Query = 'Select Id, Session_Live__c from Kakao_Consult_Chat__c';
                topic.ApiVersion = 51.0;
                topic.NotifyForOperationCreate = false;
                topic.NotifyForOperationUpdate = true;
                topic.NotifyForOperationUndelete = false;
                topic.NotifyForOperationDelete = false;
                topic.NotifyForFields = 'All';
                if (!Test.isRunningTest()) {
                    insert topic;
                }
            }

            List<Group> kakaoConsultGroupList = [SELECT Id FROM Group WHERE DeveloperName = 'Kakao_Chat_Queue'];
            if (Test.isRunningTest() || kakaoConsultGroupList == null || kakaoConsultGroupList.size() == 0) {
                Group kakaoConsultGroup = new Group();
                kakaoConsultGroup.Name = 'Kakao Chat Queue';
                kakaoConsultGroup.DeveloperName = 'Kakao_Chat_Queue';
                kakaoConsultGroup.Type = 'Queue';
                if (!Test.isRunningTest()) {
                    insert kakaoConsultGroup;
                }

                QueuesObject kakaoConsultQueue = new QueueSObject();
                kakaoConsultQueue.QueueId = kakaoConsultGroup.Id;
                kakaoConsultQueue.SobjectType = 'Case';
                if (!Test.isRunningTest()) {
                    insert kakaoConsultQueue;
                }
            }
        }
    }
}