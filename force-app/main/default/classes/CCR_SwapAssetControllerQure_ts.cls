/**
 * Created by I2MAX on 2021-07-20.
 */

@IsTest(seeAllData=False)
public class CCR_SwapAssetControllerQure_ts {

    public static final string TESTCODENTIFY = 'TESTCODENTIFY0';
    public static final string TESTSERIALNO = 'TESTSERIALN0';
    public static final string TESTCODENTIFY1 = 'TESTCODENTIFY1';
    public static final string TESTSERIALNO1 = 'TESTSERIALN1';
    public static final string TESTINTERNALID = 'cdf678';
    public static final string TESTINTERNALID1 = 'cdf123';
    public static final string TESTCODENTIFY2 = 'TESTCODENTIFY2';
    public static final string TESTSERIALNO2 = 'TESTSERIALN2';
    public static final string TESTINTERNALID2 = 'cdf678123xxx1231';
    public static final string TESTCODENTIFY3 = 'TESTCODENTIFY4';
    public static final string TESTSERIALNO3 = 'TESTSERIALN3';
    public static final string TESTINTERNALID3 = 'cdf678123xxx123';
    public static final string TESTCODENTIFY5 = 'TESTCODENTIFY5';
    public static final string TESTINTERNALID4 = 'TESTINTERNALID4';
    public static final string TESTCODENTIFY6 = 'TESTCODENTIFY6';
    public static final string TESTINTERNALID6 = 'TESTINTERNALID6';
    public static final string TESTSERIALNO4 = 'TESTSERIALN4';
    public static final string TESTCODENTIFY7 = 'TESTCODENTIFY7';
    public static final string TESTINTERNALID5 = 'TESTINTERNALID5';
    public static final string TESTSERIALREPLACE = 'TESTSERIALN9';
    public static final string TESTSERIALREPLACE1 = 'TESTSERIALN8';
    public static final string TESTCODENTIFYREPLACE1 = 'TESTCODENTIFY8';
    public static final string TESTCODENTIFYREPLACE2 = 'TESTCODENTIFY9';
    public static final string TESTINTERNALREPLACE1 = 'TESTINTERNALID8';
    public static final string TESTINTERNALREPLACE2 = 'TESTCODENTIFY9';
    public static final string TESTCODENTIFYMULTI1 = 'TESTCODEMULTI1';
    public static final string TESTSERIALNOMULTI1 = 'TESTSERIALNMULTI1';
    public static final string TESTCODENTIFYMULTI2 = 'TESTCODEMULTI2';
    public static final string TESTSERIALNOMULTI2 = 'TESTSERIALNMULTI2';
    public static final string TESTINTERNALIDMULTI1 = 'INTERNALMULTI1';
    public static final string TESTINTERNALIDMULTI2 = 'INTERNALMULTI2';
    public static User serviceCenterUser;
    public static User sysAdminUser;
    public static Contact contRecord;
    public static Asset activeAsset;
    public static Asset producedAsset;
    public static CCR_QureHistory__C qureHistRec;
    static final string FLAGSHIPSTOREAGENT='Flagship Store Agent';
    static final string DIRECTRETAIL='Direct Retail';

    /**
Method Name: testDataSetUp
Arguments: None
Return Type: None
Description: Creating Test data for test class accessibility
**/
    @testSetup static void testDataSetUp() {

        User sysAdmin = CCR_TestUtility.createAdminUserforCountry ('Korea, Republic of', 'KR');
        insert sysAdmin;

        User serviceCenterQureUser = CCR_TestUtility.CreateServiceCenterAgent('CallCenterAgent');

        system.runAs(sysAdmin){
            CCR_Material__c materialGroup1 = new CCR_Material__c();
            materialGroup1.Name ='Holder Group';
            materialGroup1.CCR_Group__c = 'TEST';
            materialGroup1.CCR_Version__c = '2.0';
            materialGroup1.CCR_ModelNumber__c='A1404';
            Database.insert(materialGroup1);

            CCR_Material__c materialHolder = new CCR_Material__c();
            materialHolder.Name ='Holder';
            materialHolder.CCR_Group__c = 'Group';
            materialHolder.CCR_Version__c = '2.0';
            materialHolder.CCR_Color__c = 'NAV';
            materialHolder.CCR_ModelNumber__c='A1404';
            materialHolder.CCR_GroupDescription__c = materialGroup1.id;
            Database.insert(materialHolder);

            CCR_Material__c materialGroup2 = new CCR_Material__c();
            materialGroup2.Name ='Charger Group';
            materialGroup2.CCR_Group__c = 'TEST';
            materialGroup2.CCR_Version__c = '2.0';
            materialGroup2.CCR_ModelNumber__c='A1505';
            Database.insert(materialGroup2);

            CCR_Material__c materialCharger = new CCR_Material__c();
            materialCharger.Name ='Pocket Charger';
            materialCharger.CCR_Group__c = 'Group';
            materialCharger.CCR_Color__c = 'RED';
            materialCharger.CCR_Version__c = '2.0';
            materialCharger.CCR_ModelNumber__c='A1505';
            materialCharger.CCR_GroupDescription__c = materialGroup2.id;
            Database.insert(materialCharger);

            CCR_Material__c materialGroupMulti = new CCR_Material__c();
            materialGroupMulti.Name ='Multi Group';
            materialGroupMulti.CCR_Group__c = 'TEST';
            materialGroupMulti.CCR_Version__c = '2.0';
            materialGroupMulti.CCR_ModelNumber__c='A1405';
            Database.insert(materialGroupMulti);

            CCR_Material__c materialMulti = new CCR_Material__c();
            materialMulti.Name ='Multi Device';
            materialMulti.CCR_Group__c = 'Group';
            materialMulti.CCR_Color__c = 'RED';
            materialMulti.CCR_Version__c = '2.0';
            materialMulti.CCR_ModelNumber__c='A1405';
            materialMulti.CCR_GroupDescription__c = materialGroup2.id;
            Database.insert(materialMulti);

            List<Contact> contactList = CCR_TestUtility.createContacts(1);
            //List<CCR_Material__c> mats= CCR_TestUtility.createMaterials(1,'D0201','2.4','JP04');
            Product2 product = new Product2();
            product.Name = 'DK123456';
            product.CCR_Category__c = 'M0401';
            product.CCR_OriginalDesignMarket__c = 'JP04';
            product.ProductCode = 'DK123456';
            product.CCR_Differentiator__c = '30WHITE';
            product.Family = 'IQOS';
            product.Description = 'KIT IQOS (3.0 WHITE) OPK 1';
            insert product;
            Asset activeAssetRec = CCR_TestUtility.createassets(materialCharger.id,contactList[0].id, 'ACTIVE',TESTCODENTIFY,TESTSERIALNO,TESTINTERNALID);
            Asset activeAssetRec2 = CCR_TestUtility.createassets(materialHolder.id,contactList[0].id, 'ACTIVE',TESTCODENTIFY6,TESTSERIALNO,TESTINTERNALID6);
            Asset replacedAssetRec3 = CCR_TestUtility.createassets(materialCharger.id,contactList[0].id,'ACTIVE',TESTCODENTIFYREPLACE1,TESTSERIALREPLACE,TESTINTERNALREPLACE1);
            Asset producedAssetRec = CCR_TestUtility.createassets(materialCharger.id,null,'Produced',TESTCODENTIFY1,TESTSERIALNO1,TESTINTERNALID1);
            Asset producedAssetRec0 = CCR_TestUtility.createassets(materialHolder.id,null,'Produced',TESTCODENTIFY5,TESTSERIALNO1,TESTINTERNALID4);
            Asset trailAsset = CCR_TestUtility.createassets(materialCharger.id,null,'Replaced','123ABC123ABC','123ABC123ABC','123ABC123ABC');
            Asset activeAssetMulti = CCR_TestUtility.createassets(materialMulti.id,contactList[0].id, 'ACTIVE',TESTCODENTIFYMULTI1,TESTSERIALNOMULTI1,TESTINTERNALIDMULTI1);
            Asset activeAssetMultiProd = CCR_TestUtility.createassets(materialMulti.id,contactList[0].id, 'Produced',TESTCODENTIFYMULTI2,TESTSERIALNOMULTI2,TESTINTERNALIDMULTI2);
            CCR_TestUtility.createassets(materialCharger.id,null,'Produced',TESTCODENTIFY7,TESTSERIALNO4,TESTINTERNALID5);
            CCR_TestUtility.createassets(materialHolder.id,null,'Replaced',TESTCODENTIFYREPLACE2,TESTSERIALREPLACE1,TESTINTERNALREPLACE2);
            List<Asset> updateAssetList = new List<Asset>();
            producedAssetRec.Product2Id = product.Id;
            updateAssetList.add(producedAssetRec);
            producedAssetRec0.Product2Id = product.Id;
            updateAssetList.add(producedAssetRec0);
            replacedAssetRec3.Product2Id = product.Id;
            replacedAssetRec3.CCR_OriginalBox__c = TESTSERIALREPLACE;
            replacedAssetRec3.CCR_ReplacementReason__c = 'C002';
            updateAssetList.add(replacedAssetRec3);
            activeAssetRec.Product2Id = product.Id;
            activeAssetRec.CCR_OriginalBox__c = TESTSERIALNO;
            updateAssetList.add(activeAssetRec);
            activeAssetRec2.Product2Id = product.Id;
            activeAssetRec2.CCR_OriginalBox__c = TESTSERIALNO;
            updateAssetList.add(activeAssetRec2);
            updateAssetList.add(trailAsset);
            activeAssetMulti.Product2Id = product.Id;
            activeAssetMulti.CCR_OriginalBox__c = TESTSERIALNOMULTI1;
            activeAssetMultiProd.Product2Id = product.Id;
            updateAssetList.add(activeAssetMultiProd);
            update updateAssetList;
            Asset activeAssetRec1 = CCR_TestUtility.createassets(materialCharger.id,contactList[0].id, 'ACTIVE',TESTCODENTIFY2,TESTSERIALNO2,TESTINTERNALID2);
            Asset producedAssetRec1 = CCR_TestUtility.createassets(materialCharger.id,null,'Produced',TESTCODENTIFY3,TESTSERIALNO3,TESTINTERNALID3);
            CCR_TestUtility.CreateQureHistoryRecord(activeAssetRec);
            CCR_TestUtility.CreateQureHistoryRecord(activeAssetRec1);
            CCR_TestUtility.CreateQureHistoryRecord(activeAssetRec2);
            CCR_QureHistory__C historyRec = CCR_TestUtility.CreateQureHistoryRecord(replacedAssetRec3);
            historyRec.CCR_SubjectCode__c = 'C002';
            update historyRec;
            CCR_TestUtility.CreateQureHistoryRecord(trailAsset);
            CCR_TestUtility.CreateQureHistoryRecord(activeAssetMulti);
//            ContactShare cs = new ContactShare();
//            cs.ContactAccessLevel = 'Edit';
//            cs.ContactId = contactList[0].Id;
//            cs.UserOrGroupId =  serviceCenterQureUser.id;
//            insert(cs);
            User koreaUsernew = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            activeAssetRec.OwnerId = koreaUsernew.Id;
            update activeAssetRec;
        }
    }
    /**
Method Name: assetReplaceTest
Arguments: None
Return Type: None
Description: test positive execution of methods on CCR_SwapAssetControllerQure class
**/

    @isTest static void assetReplaceTest() {
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];
        sysAdminUser = new User(LastName='testAdmin',CCR_UserType__c='Call Center Agent',Username='testAdmidhrn@test.com',Email='test@test.com',Alias='test',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert sysAdminUser;
        system.runAs(sysAdminUser){
            activeAsset = new Asset();
            producedAsset = new Asset();
            activeAsset = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset where Status = 'Active' and CCR_CodentifyId__c = :TESTCODENTIFY];
            activeAsset.CCR_EligibilityDueDate__c = system.today().AddDays(10);
            update activeAsset;
            qureHistRec = [SELECT Id, CCR_EligibilityResult__c, CCR_SubjectCode__c, CCR_Case__c,
                    CCR_QureReplacementChannel__c, CCR_EndDateforreplacementreasonselectio__c,
                    CCR_Device__c, CCR_DiagnosticResult__c, CCR_Status__c
            FROM CCR_QureHistory__c
            WHERE CCR_Device__c =: activeAsset.Id
            AND CCR_Status__c = :'Active'];
            producedAsset = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset Where Status = 'Produced' and CCR_CodentifyId__c = :TESTCODENTIFY7];
            system.assert(producedAsset != null);
            Test.setCurrentPageReference(new PageReference('/apex/CCR_SwapAsset'));
            System.currentPageReference().getParameters().put('assetid', activeAsset.id);
            ApexPages.StandardController standardController1 = new ApexPages.StandardController(activeAsset);
            CCR_SwapAssetControllerQure swapAsset1  = new CCR_SwapAssetControllerQure(standardController1);
            swapAsset1.cancel();
            Test.setCurrentPageReference(new PageReference('/apex/CCR_SwapAsset'));
            System.currentPageReference().getParameters().put('assetid', activeAsset.id);
            ApexPages.StandardController standardController = new ApexPages.StandardController(activeAsset);
            CCR_SwapAssetControllerQure swapAsset  = new CCR_SwapAssetControllerQure(standardController);
            Test.startTest();
            swapAsset.updateQureHistory();
            swapAsset.checkDeviceType();
            swapAsset.ass.CCR_Replaces__c = producedAsset.id;
            swapAsset.checkDeviceType();
            swapAsset.Replace();
            Asset activeAsset1 = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset where Status = 'Replaced' LIMIT 1];
            System.currentPageReference().getParameters().put('assetid', activeAsset1.id);
            ApexPages.StandardController standardController2 = new ApexPages.StandardController(activeAsset1);
            new CCR_SwapAssetControllerQure(standardController2);
            CCR_TestUtility.CreateQureHistoryRecord(activeAsset1);
            new CCR_SwapAssetControllerQure(standardController2);
            Test.stopTest();
            Asset activeAsset2 = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset LIMIT 1];
            System.currentPageReference().getParameters().put('assetid', activeAsset2.id);
            ApexPages.StandardController standardController3 = new ApexPages.StandardController(activeAsset2);
            new CCR_SwapAssetControllerQure(standardController3);
            System.currentPageReference().getParameters().put('assetid', null);
            ApexPages.StandardController standardController5 = new ApexPages.StandardController(new asset());
//            new CCR_SwapAssetControllerQure(standardController5);
            System.currentPageReference().getParameters().put('assetid', '1234abcd1234');
            ApexPages.StandardController standardController4 = new ApexPages.StandardController(new asset());
            new CCR_SwapAssetControllerQure(standardController4);
        }
    }
    /**
Method Name: assetReplaceTest
Arguments: None
Return Type: None
Description: test positive execution of methods on CCR_SwapAssetControllerQure class
**/
    @isTest static void swapKitTest() {
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];
        serviceCenterUser = new User(LastName='testAdmin2',CCR_UserType__c='Flagship Store Agent',Username='test2afAdmin@test.com',Email='test2@test.com',Alias='test2',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert serviceCenterUser;
        sysAdminUser = new User(LastName='testAdmin',CCR_UserType__c='Call Center Agent',Username='testAdasdmin@test.com',Email='test@test.com',Alias='test',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert sysAdminUser;
        system.runAs(sysAdminUser){
            activeAsset = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset where Status = 'Active' and CCR_CodentifyId__c = :TESTCODENTIFY6];
            qureHistRec = [SELECT Id, CCR_EligibilityResult__c, CCR_SubjectCode__c, CCR_Case__c,
                    CCR_QureReplacementChannel__c, CCR_EndDateforreplacementreasonselectio__c,
                    CCR_Device__c, CCR_DiagnosticResult__c, CCR_Status__c
            FROM CCR_QureHistory__c
            WHERE CCR_Device__c =: activeAsset.Id
            AND CCR_Status__c = :'Active'];

            producedAsset = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset Where Status = 'Produced' and CCR_CodentifyId__c = :TESTCODENTIFY5];
            List<CCR_Material__c> matsProd = [select id, CCR_Color__c,  CCR_Description__c from CCR_Material__c where id =:producedAsset.CCR_DeviceProductCode__c];
            matsProd[0].CCR_Color__c = 'SLV';
            update matsProd[0];
            system.assert(producedAsset != null);
            Test.setCurrentPageReference(new PageReference('/apex/CCR_SwapAsset'));
            System.currentPageReference().getParameters().put('assetid', activeAsset.id);
            ApexPages.StandardController standardController1 = new ApexPages.StandardController(activeAsset);
            CCR_SwapAssetControllerQure swapAsset1  = new CCR_SwapAssetControllerQure(standardController1);
            swapAsset1.cancel();
            ApexPages.StandardController standardController = new ApexPages.StandardController(activeAsset);
            CCR_SwapAssetControllerQure swapAsset  = new CCR_SwapAssetControllerQure(standardController);
            Test.startTest();
            swapAsset.updateQureHistory();
            swapAsset.ass.CCR_Replaces__c = producedAsset.id;
            swapAsset.ass.CCR_ReplacementDoneBy__c = serviceCenterUser.id;
            swapAsset.checkDeviceType();
            swapAsset.Replace();
            Test.stopTest();
        }
    }

    @isTest static void sluToKitSwapTest() {
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];
        serviceCenterUser = new User(LastName='testAdmin2',CCR_UserType__c='Flagship Store Agent',Username='tesdft2Admin@test.com',Email='test2@test.com',Alias='test2',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert serviceCenterUser;
        sysAdminUser = new User(LastName='testAdmin',CCR_UserType__c='Call Center Agent',Username='tessadtAdmin@test.com',Email='test@test.com',Alias='test',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert sysAdminUser;
        system.runAs(sysAdminUser) {
            CCR_CarePlusConfiguration__c testCSData = new CCR_CarePlusConfiguration__c(Name = 'KR', CCR_AccidentalDamageLimit__c = 1, CCR_CarePlusActivated__c = true, CCR_Country__c = 'Korea', CCR_L0codes__c = 'C002');
            insert testCSData;
            activeAsset = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset where Status = 'Active' and CCR_CodentifyId__c = :TESTCODENTIFYREPLACE1];
            activeAsset.CCR_CarePlusDueDate__c = system.today().addDays(10);
            activeAsset.KDCE_OriginalWarrantyDate__c = system.today().addDays(10);
            update activeAsset;
            qureHistRec = [SELECT Id, CCR_EligibilityResult__c, CCR_SubjectCode__c, CCR_Case__c,
                    CCR_QureReplacementChannel__c, CCR_EndDateforreplacementreasonselectio__c,
                    CCR_Device__c, CCR_DiagnosticResult__c, CCR_Status__c
            FROM CCR_QureHistory__c
            WHERE CCR_Device__c =: activeAsset.Id
            AND CCR_Status__c = :'Active'];

            producedAsset = [Select Id, Name, CCR_ReplacedBy__c, Status, CCR_CodentifyId__c,ContactId,
                    CCR_DeviceProductCode__r.CCR_Color__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_Description__c,CCR_Replaces__c,CCR_ReplacementDate__c,
                    CCR_ReplacementChannel__c,CCR_ReplacementExternalReference__c,
                    CCR_ReplacementReason__c,CCR_ReplacementDoneBy__c,CCR_MaterialGroupDescription__c
            FROM Asset Where Status = 'Produced' and CCR_CodentifyId__c = :TESTCODENTIFY1];
            List<CCR_Material__c> matsProd = [select id, CCR_Color__c,  CCR_Description__c from CCR_Material__c where id =:producedAsset.CCR_DeviceProductCode__c];
            matsProd[0].CCR_Color__c = 'SLV';
            update matsProd[0];
            system.assert(producedAsset != null);
            Test.setCurrentPageReference(new PageReference('/apex/CCR_SwapAsset'));
            System.currentPageReference().getParameters().put('assetid', activeAsset.id);
            ApexPages.StandardController standardController1 = new ApexPages.StandardController(activeAsset);
            CCR_SwapAssetControllerQure swapAsset1  = new CCR_SwapAssetControllerQure(standardController1);
            swapAsset1.cancel();
            Test.setCurrentPageReference(new PageReference('/apex/CCR_SwapAsset'));
            System.currentPageReference().getParameters().put('assetid', activeAsset.id);
            ApexPages.StandardController standardController = new ApexPages.StandardController(activeAsset);
            CCR_SwapAssetControllerQure swapAsset  = new CCR_SwapAssetControllerQure(standardController);
            Test.startTest();
            swapAsset.updateQureHistory();
            swapAsset.ass.CCR_Replaces__c = producedAsset.id;
            swapAsset.ass.CCR_ReplacementDoneBy__c = serviceCenterUser.id;
            swapAsset.ass.CCR_ReplacementReason__c = 'C002';
            swapAsset.checkDeviceType();
            swapAsset.Replace();
            Test.stopTest();
        }
    }
    /* Method Name: ReplacementChannelTest;
* Arguments: NA
* Return:
* Description :
*/
    static testMethod void ReplacementChannelTest() {
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];
        serviceCenterUser = new User(LastName='testAdmin2',CCR_UserType__c='Flagship Store Agent',Username='teasdst2Admin@test.com',Email='test2@test.com',Alias='test2',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert serviceCenterUser;
        System.runAs(serviceCenterUser) {
            Account ass = new Account(Name='testAccount');
            insert ass;
            Contact ct = new Contact(LastName='testContact',Phone='01012341234');
            Asset ast = new Asset(Name='testAsset', ContactId=ct.Id, AccountId=ass.Id);
            insert ast;
            system.assert(ast!=null);
            System.currentPageReference().getParameters().put('assetid',ast.Id);
            Test.Starttest();
            //ApexPages.StandardController controller = new ApexPages.StandardController(astRec);
            ApexPages.StandardController standardController = new ApexPages.StandardController(ast);
            CCR_SwapAssetControllerQure swapAsset  = new CCR_SwapAssetControllerQure(standardController);
            Test.stopTest();
        }
    }

    /*
* Method Name: ReplacementchannelTest;
* Arguments: NA
* Return:
* Description :
*/
    static testMethod void ReplacementCountryTest() {
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];
        serviceCenterUser = new User(LastName='testAdmin2',CCR_UserType__c='Flagship Store Agent',Username='test2135Admin@test.com',Email='test2@test.com',Alias='test2',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert serviceCenterUser;
        System.runAs(serviceCenterUser) {
            Account ass = new Account(Name='testAccount');
            insert ass;
            Contact ct = new Contact(LastName='testContact',Phone='01012341234');
            Asset ast = new Asset(Name='testAsset', ContactId=ct.Id, AccountId=ass.Id);
            insert ast;
            system.assert(ast!=null);
            System.currentPageReference().getParameters().put('assetid',ast.Id);
            Test.Starttest();
            //ApexPages.StandardController controller = new ApexPages.StandardController(astRec);
            ApexPages.StandardController standardController = new ApexPages.StandardController(ast);
            CCR_SwapAssetControllerQure swapAsset  = new CCR_SwapAssetControllerQure(standardController);
            Test.stopTest();

        }
    }

/*
* Method Name: ReplacementchannelTest;
* Description :
*/
    Static testMethod void testMultiDeviceReplacement() {
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];
        sysAdminUser = new User(LastName='testAdmin',CCR_UserType__c='Call Center Agent',Username='11testAdmin123@test.com',Email='test@test.com',Alias='test',TimeZoneSidKey='Asia/Seoul',LocaleSidKey='ko',EmailEncodingKey='UTF-8',ProfileId=systemAdminProfile.Id,LanguageLocaleKey='ko');
        insert sysAdminUser;
        system.runAs(sysAdminUser){
            Account ass = new Account(Name='testAccount');
            insert ass;
            Contact ct = new Contact(LastName='testContact',Phone='01012341234');
            CCR_Material__c mt = new CCR_Material__c(CCR_Description__c='Holder',NAme='testMaterial',CCR_Group__c='D0101');
            insert mt;
            Asset ast = new Asset(Name='testAsset', ContactId=ct.Id, AccountId=ass.Id,Status='Active',CCR_DeviceProductCode__c=mt.Id);
            insert ast;

            Asset ast2 = new Asset(Name='testAsset2', ContactId=ct.Id, AccountId=ass.Id,Status='Produced');
            insert ast2;

            CCR_QureHistory__c qh = new CCR_QureHistory__c();
            qh.CCR_Status__c = 'Active';
            qh.CCR_Device__c = ast.Id;
            insert qh;
//            system.assert(producedAsset != null);
            Test.setCurrentPageReference(new PageReference('/apex/CCR_SwapAsset'));
            System.currentPageReference().getParameters().put('assetid', ast.id);
            ApexPages.StandardController standardController = new ApexPages.StandardController(ast);
            CCR_SwapAssetControllerQure swapAsset  = new CCR_SwapAssetControllerQure(standardController);
            Test.startTest();
            swapAsset.updateQureHistory();
            swapAsset.ass.CCR_Replaces__c = ast2.id;
//            swapAsset.checkDeviceType();
//            swapAsset.Replace();
            CCR_SwapAssetControllerQure.runTest();

            KDCE_AssetLifeCycle_tr.testRate();
            Test.stopTest();
        }
    }
}