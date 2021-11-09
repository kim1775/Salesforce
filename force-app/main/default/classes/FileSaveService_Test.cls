/**
 * @description       : Test class for file save service logic
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 05-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-23-2021   Obidjon   Initial Version
 **/
@isTest
public class FileSaveService_Test {
    @isTest
    private static void testProcess() {
        User standardUser = KakaoTestUtils.createUser('Standard User');
        KakaoTestUtils.assignPermissionSet('KakaoConsult_User', standardUser.Id);

        System.runAs(standardUser) {
            Case kakaoCase = new Case();
            kakaoCase.Subject = 'Test Case';
            insert kakaoCase;

            Test.startTest();
            Map<String, String> headers = new Map<String, String>();
            headers.put('Content-Type', 'application/json');
            CalloutUtilsMock calloutMock = new CalloutUtilsMock(headers, '{"status":"success"}', 200);
            Test.setMock(HttpCalloutMock.class, calloutMock);
            FileSaveService.saveFile('https://test.force.com', kakaoCase.Id, 'Test file');
            Test.stopTest();
        }
    }
}