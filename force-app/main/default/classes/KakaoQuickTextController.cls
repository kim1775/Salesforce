/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 05-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   05-14-2021   Obidjon   Initial Version
 **/
public with sharing class KakaoQuickTextController {
    @testVisible
    private static String testExceptionMessage;

    @AuraEnabled(cacheable=true)
    public static List<Kakao_Quick_Text__c> getKakaoQuickTexts() {
        try {
            testException(KakaoQuickTextController.testExceptionMessage);
            List<Kakao_Quick_Text__c> kakaoQuickTextList = [
                SELECT Id, Content__c, Label__c
                FROM Kakao_Quick_Text__c
                WHERE Active__c = TRUE OR (Active__c = TRUE AND Global__c = TRUE)
                WITH SECURITY_ENFORCED
            ];

            return kakaoQuickTextList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void testException(String exceptionMessage) {
        if (String.isNotBlank(exceptionMessage)) {
            throw new AuraHandledException(exceptionMessage);
        }
    }
}