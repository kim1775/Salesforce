/**
 * @description       : Inbound message service rest service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 07-15-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-05-2021   Obidjon   Initial Version
 **/
@RestResource(urlMapping='/message')
global without sharing class InboundMessageRestService {
    private static Map<String, String> typeMap = new Map<String, String>{
        'text' => 'Text',
        'photo' => 'Image',
        'video' => 'Video',
        'audio' => 'Audio',
        'file' => 'File'
    };

    @SuppressWarnings('PMD.ApexCRUDViolation')
    @HttpPost
    global static void doPostMessages() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String requestBody = request.requestBody.toString();
        InboundMessage message = InboundMessage.parse(requestBody);

        KakaoConsultDealerCredentials__c dealerCredentials = KakaoConsultDealerCredentials__c.getOrgDefaults();
        String jwtToken = dealerCredentials.JWT_Token__c;
        String secret = dealerCredentials.Channel_Secret__c;
        String headerSignature = request.headers.get('X-Signature');

        KakaoConsult_JWT jwt = new KakaoConsult_JWT('HS256', 'JWT', jwtToken, secret);
        if (!Test.isRunningTest() && !jwt.verify(headerSignature)) {
            response.statusCode = 401;
            return;
        }

        Kakao_Consult_Chat__c consultChat;
        Kakao_Chat_Feed__c welcomeMessageFeed;
        try {
            consultChat = [
                SELECT Id
                FROM Kakao_Consult_Chat__c
                WHERE Session_Live__c = TRUE AND User_Key__c = :message.user_key
                LIMIT 1
            ];
        } catch (QueryException e) {
            List<Kakao_User_Mapping__c> kakaoUserMapping = [
                SELECT Id, Contact__c
                FROM Kakao_User_Mapping__c
                WHERE User_Key__c = :message.user_key AND Contact__c != NULL
            ];

            Case kakaoCase = new Case();
            if (!Test.isRunningTest()) {
                kakaoCase.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = 'Kakao_Chat_Queue'].Id;
            } else {
                kakaoCase.OwnerId = UserInfo.getUserId();
            }
            kakaoCase.Subject = '카카오상담';
            kakaoCase.Origin = 'Kakao Chat';
            if (kakaoUserMapping.size() > 0) {
                kakaoCase.ContactId = kakaoUserMapping.get(0).Contact__c;
            }
            insert kakaoCase;

            consultChat = new Kakao_Consult_Chat__c();
            consultChat.Session_Live__c = true;
            consultChat.User_Key__c = message.user_key;
            consultChat.Case__c = kakaoCase.Id;
            // In case of first message conflict
            List<Kakao_Consult_Chat__c> existingChatList = [
                SELECT Id
                FROM Kakao_Consult_Chat__c
                WHERE Session_Live__c = TRUE AND User_Key__c = :message.user_key
                LIMIT 1
            ];
            if (existingChatList.size() > 0) {
                delete kakaoCase;
                consultChat = existingChatList.get(0);
            } else {
                insert consultChat;
            }

            if (String.isNotBlank(dealerCredentials.Welcome_Message__c)) {
                welcomeMessageFeed = new Kakao_Chat_Feed__c();
                welcomeMessageFeed.Kakao_Consult_Chat__c = consultChat.Id;
                welcomeMessageFeed.Sender__c = 'Agent';
                welcomeMessageFeed.Status__c = 'Success';
                welcomeMessageFeed.Type__c = typeMap.get('text');
                welcomeMessageFeed.Message__c = dealerCredentials.Welcome_Message__c;
            }
        }
        consultChat = [SELECT Id, Case__c FROM Kakao_Consult_Chat__c WHERE Id = :consultChat.Id];

        Kakao_Chat_Feed__c chatFeed = new Kakao_Chat_Feed__c();
        chatFeed.Kakao_Consult_Chat__c = consultChat.Id;
        chatFeed.Sender__c = 'Customer';
        chatFeed.Status__c = 'Success';
        chatFeed.Type__c = typeMap.get(message.type);
        if (message.type == 'text') {
            chatFeed.Message__c = message.content;
        } else if (message.type == 'photo') {
            chatFeed.Image_Url__c = message.urlContent.url;
        } else {
            chatFeed.File_Url__c = message.urlContent.url;
        }
        insert chatFeed;

        if (message.type == 'photo') {
            FileSaveService.saveFile(chatFeed.Image_Url__c, consultChat.Case__c, chatFeed.Id);
        }

        if (welcomeMessageFeed != null && !Test.isRunningTest()) {
            insert welcomeMessageFeed;
            OutboundMessageController.sendTextMessage(welcomeMessageFeed.Id);
        }

        response.statusCode = 200;
    }
}