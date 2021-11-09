/**
 * Created by I2MAX on 2021-06-22.
 */

@IsTest
private class CCR_QUREAgentPageExt_ts {
    static final string TESTDEVICE = 'codenfi123';
    static final string TESTDEVICE11 = 'DVC.00036';
    static final string TESTGROUP = 'D0103';
    static final string TESTPARENTCODENTIFY1 = 'parentid123';
    static final string TESTPARENTCODENTIFY2 = 'parentid321';
    static final string TESTSTATUS = 'Active';
    static final string TESTCODENTIFY1 = 'codenfi123';
    static final string TESTCODENTIFY2 = 'codenfi321';
    static final string TESTINTERNALID1= '456945566653211';
    static final string TESTINTERNALID2= '456945566653222';

    /**
    * Method Name:  tetData
    * Arguments: NA
    * Return: NA.
    * Description: This method is to create test data.
    **/
    @testSetup static void setData(){
        user koreaAdmin = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of', 'KR');
        user polandAdmin = CCR_TestUtility.createAdminUserforCountry('Poland', 'PL');
        user guestUser;
        if(UserInfo.getOrganizationId() == '00D1m0000008mvREAQ') {
            guestUser = CCR_TestUtility.createGuestUser('onlineQure 프로필'); //QA
        } else {
            guestUser = CCR_TestUtility.createGuestUser('Service - onlineQure Profile'); //PRD
        }
        list<CCR_Material__c> mats= CCR_TestUtility.createMaterials(2,'D0201','2.2','JP04');
        list<Contact> koreaConList = CCR_TestUtility.createContactsForSpecificCountry(1, 'KR');
        list<Contact> polandConList = CCR_TestUtility.createContactsForSpecificCountry(1, 'PL');

        system.runAs(koreaAdmin){
            Asset ast=CCR_TestUtility.createassets(mats[0].id, koreaConList[0].id, TESTSTATUS, TESTCODENTIFY1, TESTPARENTCODENTIFY1, TESTINTERNALID1);
            User koreaUser = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            ast.OwnerId=koreaUser.id;
            update ast;
        }

        system.runAs(polandAdmin){
            Asset ast=CCR_TestUtility.createassets(mats[0].id, polandConList[0].id, TESTSTATUS, TESTCODENTIFY2, TESTPARENTCODENTIFY2, TESTINTERNALID2);
            User koreaUser = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            ast.OwnerId=koreaUser.id;
            update ast;
        }
    }
    /*
* Method Name: positiveTestAsset
* Arguments:
* Return : Pagereference
* Description :
*/
    static testMethod void positiveTestAsset(){
        user admUser = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of', 'KR');
        system.runAs(admUser){
            asset astRec =[select id,name,CCR_ReplacedBy__c,CCR_Replaces__c,contactid,Status,CCR_OriginalAsset__c,CCR_OriginalBox__c,CCR_CodentifyId__c,SerialNumber from asset WHERE CCR_CodentifyId__c = 'codenfi123'];
            system.currentPageReference().getParameters().put('codentify',astRec.CCR_CodentifyId__c);
            Test.Starttest();
            Apexpages.StandardController controller = new Apexpages.StandardController(astRec);
            CCR_QUREAgentPageExt ext=new CCR_QUREAgentPageExt(controller);
            System.assert(ext.qureEnabled == true);
            Test.stopTest();
        }
    }
    /*
* Method Name: negativeTestAsset
* Arguments:
* Return : Pagereference
* Description : difference in country codes between asset and owner
*/
    static testMethod void negativeTestAsset(){
        user admUser = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of', 'KR');
        System.runAs(admUser){
            asset ast =[SELECT Id,name,contactid,Status,CCR_CodentifyId__c,SerialNumber FROM asset WHERE CCR_CodentifyId__c = 'codenfi321'];
            System.currentPageReference().getParameters().put('codentify',ast.CCR_CodentifyId__c);
            Test.startTest();
            Apexpages.StandardController controller = new Apexpages.StandardController(ast);
            CCR_QUREAgentPageExt ext=new CCR_QUREAgentPageExt(controller);
            Test.stopTest();
        }
    }
    /*
    * Method Name: negativeTestAssetLinked
    * Arguments:
    * Return : Pagereference
    * Description :
    */
    static testMethod void negativeTestAssetLinked(){

        User admUser = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of', 'KR');
        System.runAs(admUser){
            Asset astRec1 =[SELECT Id, name, contactid, Status, CCR_CodentifyId__c, SerialNumber from asset limit 1];
            Database.update(astRec1);
            system.currentPageReference().getParameters().put('codentify',astRec1.CCR_CodentifyId__c);
            Test.Starttest();
            Apexpages.StandardController controller = new Apexpages.StandardController(astRec1);
            CCR_QUREAgentPageExt ext = new CCR_QUREAgentPageExt(controller);
            Test.stopTest();
        }
    }

    static testMethod void guestTestAsset(){
        user admUser;
        if(UserInfo.getOrganizationId() == '00D1m0000008mvREAQ') {
            admUser = CCR_TestUtility.createGuestUser('onlineQure 프로필'); //QA
        } else {
            admUser = CCR_TestUtility.createGuestUser('Service - onlineQure Profile'); //PRD
        }
        Asset ass = new Asset();
        ass.name = 'test123';
        Account acc = CCR_TestUtility.getAcc();
        ass.AccountId = acc.id;
        insert ass;
        System.runAs(admUser){
            System.currentPageReference().getParameters().put('codentify',ass.CCR_CodentifyId__c);
            Test.startTest();
            Apexpages.StandardController controller = new Apexpages.StandardController(ass);
            CCR_QUREAgentPageExt ext=new CCR_QUREAgentPageExt(controller);
            CCR_Utility.testRun();
            Test.stopTest();
        }
    }
}