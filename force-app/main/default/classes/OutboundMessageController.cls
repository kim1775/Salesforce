/**
 * @description       : Outbound message controller
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   03-22-2021   Obidjon   Initial Version
 **/
public with sharing class OutboundMessageController {
    @AuraEnabled
    public static Boolean sendTextMessage(Id kakaoChatFeedId) {
            
        SendTextMessageHttpCallout.process(kakaoChatFeedId);

        return true;
    }

    @AuraEnabled
    public static Boolean sendImageMessage(Id kakaoChatFeedId) {

        SendImageMessageHttpCallout.process(kakaoChatFeedId);

        return true;
    }
}