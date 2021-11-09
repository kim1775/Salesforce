/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 04-25-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-25-2021   Obidjon   Initial Version
 **/
@isTest
private with sharing class PostInstallClass_Test {
    @isTest
    private static void testInstallScript() {
        PostInstallClass postinstall = new PostInstallClass();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1, 0), true);
    }
}