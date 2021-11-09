/**
 * @description       : Session Controller
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   03-22-2021   Obidjon   Initial Version
 **/
public with sharing class KakaoConsultSessionController {
    @AuraEnabled
    public static Boolean endSession(Id kakaoConsultId) {
        EndSessionCallout.process(kakaoConsultId);
        return true;
    }

    @AuraEnabled
    public static Boolean sendIdentifyLink(Id kakaoChatFeedId) {
        CustomerIdentifyCallout.process(kakaoChatFeedId);
        return true;
    }
}