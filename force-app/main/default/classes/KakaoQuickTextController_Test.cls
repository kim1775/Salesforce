/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 05-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   05-23-2021   Obidjon   Initial Version
 **/
@isTest
private class KakaoQuickTextController_Test {
    @testSetup
    private static void testSetup() {
        User standardUser = KakaoTestUtils.createUser('Standard User');
        KakaoTestUtils.assignPermissionSet('KakaoConsult_User', standardUser.Id);

        System.runAs(standardUser) {
            List<Kakao_Quick_Text__c> kakaoQuickTextList = new List<Kakao_Quick_Text__c>();
            for (Integer i = 0; i < 10; i++) {
                Kakao_Quick_Text__c quickText = new Kakao_Quick_Text__c();
                quickText.Active__c = true;
                quickText.Label__c = 'Quick Text Test ' + String.valueOf(i);
                quickText.Content__c = 'Content of test quick text ' + String.valueOf(i);
                kakaoQuickTextList.add(quickText);
            }

            insert kakaoQuickTextList;
        }
    }

    @isTest
    private static void testGetKakaoQuickTexts() {
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(standardUser) {
            List<Kakao_Quick_Text__c> quickTextList = KakaoQuickTextController.getKakaoQuickTexts();
            System.assertEquals(10, quickTextList.size(), 'Error with quick text insert and retrieve logic');

            KakaoQuickTextController.testExceptionMessage = 'TestException';
            try {
                KakaoQuickTextController.getKakaoQuickTexts();
            } catch (Exception e) {
            }
        }
    }
}