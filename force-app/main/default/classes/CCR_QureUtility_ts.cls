/**
 * Created by I2MAX on 2021-07-20.
 */

@IsTest(seealldata = false)
private class CCR_QureUtility_ts {
    @testSetup static void testdata() {

        user admuserKR = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        CCR_CarePlusConfiguration__c testCSData = new CCR_CarePlusConfiguration__c(Name='KR', CCR_Country__c='Korea', CCR_CarePlusActivated__c=true, CCR_L0codes__c='C101', CCR_AccidentalDamageLimit__c=2);//Amrit Das added CCR_BrandFamiliesCovered__c as a part of CCR-174919
        insert testCSData;
        System.runAs(admuserKR) {
            list<CCR_Material__c> mats= CCR_TestUtility.createMaterials(1,'D0201','2.4','JP04');
            Asset ast = CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETPRODUCED, 'TESTCODENTIFY', 'TESTPARENTCODENTIFY', 'TESTINTERNALID');
            Asset ast1 = CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETPRODUCED, 'TESTCODENTIFY1', 'TESTPARENTCODENTIFY1', 'TESTINTERNALID1');
            Asset ast2 = CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETPRODUCED, 'CODENTIFYSUBS1', 'SERIALCODENTIFYSUBS1', 'TESTSUBSCRIPTI1');
            CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETREPLACED, 'TESTCODENTIFY2', 'TESTPARENTCODENTIFY2', 'TESTINTERNALID3');
            CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETREPLACED, 'CODENTIFYSUBS3', 'SERIALCODENTIFYSUBS3', 'TESTSUBSCRIPTI3');
            String marketConfigrecordtypeId = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_MarketConfiguration').getRecordTypeId();
            String marketRplacementrecordtypeId = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_MarketReplacement').getRecordTypeId();
            String subsRplacementrecordtypeId = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_SubscriptionReplacement').getRecordTypeId();
            List<CCR_QureConfiguration__c> configList = new List<CCR_QureConfiguration__c>();
            CCR_QureConfiguration__c qureConfig = new CCR_QureConfiguration__c(CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling',CCR_SubjectCode__c='C101', recordtypeid = marketConfigrecordtypeId, CCR_Country__c ='KR', CCR_CoveredInWarranty__c =true, CCR_CodeToBeEscalated__c = true, CCR_MaterialGroupDescription__c ='Holder /S',CCR_Model__c='A1403', CCR_L0code__c='C101');
            configList.add(qureConfig);
            CCR_QureConfiguration__c marketQureConfig = new CCR_QureConfiguration__c(CCR_EligibleForReplacement__c = 14, recordtypeid = marketRplacementrecordtypeId, CCR_MaxNumberOfReplacementsPerDevice__c =1, CCR_Country__c ='KR',CCR_Model__c='A1403');
            configList.add(marketQureConfig);
            CCR_QureConfiguration__c qureConfigTwo = new CCR_QureConfiguration__c(recordtypeid = subsRplacementrecordtypeId, CCR_Country__c ='KR', CCR_MaxNumberOfReplacementsPerDevice__c = 1);
            configList.add(qureConfigTwo);
            CCR_QureConfiguration__c qureConfigThree = new CCR_QureConfiguration__c(CCR_DiagnosticResult__c = 'HC3', CCR_DiagnosticDescription__c='Paint Peeling',CCR_SubjectCode__c='C101', recordtypeid = marketConfigrecordtypeId, CCR_Country__c ='KR', CCR_CoveredInWarranty__c =false, CCR_CodeToBeEscalated__c = false, CCR_MaterialGroupDescription__c ='Holder /S',CCR_Model__c='A1403', CCR_L0code__c='C101');
            configList.add(qureConfigThree);
            insert configList;
            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHis;
            user u = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            ast.OwnerId = u.id;
            update ast;
            ast1.OwnerId = u.id;
            update ast1;
            CCR_CarePlusConfiguration__c cpc = new CCR_CarePlusConfiguration__c();
            cpc.Name = 'testCPC';
            cpc.CCR_AccidentalDamageLimit__c = 1;
            cpc.CCR_CarePlusActivated__c = true;
            cpc.CCR_Country__c = 'kr';
            cpc.CCR_L0codes__c = 'C101';
            insert cpc;
        }
    }

    /**
* Method Name:  positiveTest
* Arguments: NA
* Return: NA.
* Description: This method is to test positive scenariao.
**/

    static testMethod void positiveTest() {
        Asset astUpdate = [SELECT id, KDCE_OriginalWarrantyDate__c FROM asset LIMIT 1];
        astUpdate.KDCE_OriginalWarrantyDate__c = system.today().addDays(100);
        update astUpdate;
        user userAgent =[SELECT id, name from user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(userAgent) {
            Account acc = new Account(Name='testAccount');
            insert acc;
            Contact ct = new Contact(LastName='testContact',Phone='01012341234');
            insert ct;
            Asset ast = new Asset(Name='testAsset',AccountId=acc.Id,ContactId=ct.Id);
            insert ast;
            Map<String, Map<String, String>> codentifyConsumerMap = new Map<String, Map<String, String>>();
            Map<String, String> map2 = new Map<String, String>();
            map2.put('SpiceId',ct.id);
            map2.put('ActionDate',String.valueOf(System.now()));
            codentifyConsumerMap.put(ast.CCR_CodentifyId__c, map2);
            test.startTest();

            CCR_QureHistory__c qureHisZero = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_Consumer__c = ct.id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC3', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHisZero;
            CCR_QureMsg qurmsgZero = new CCR_QureMsg();
            qurmsgZero.Codentify = ast.CCR_CodentifyId__c;
            qurmsgZero.QureHistryId = qureHisZero.Id;
            qurmsgZero.Market = 'KR';
            qurmsgZero.UserType = 'Consumer';
            CCR_QureUtility.deviceQureEligibility(qurmsgZero);

            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_Consumer__c = ct.id, CCR_QureChannel__c = 'Call Center', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHis;
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            Asset astUpdateTemp = [SELECT id, KDCE_OriginalWarrantyDate__c FROM asset WHERE Id =: ast.Id];
            astUpdateTemp.KDCE_OriginalWarrantyDate__c = system.today().addDays(100);
            update astUpdateTemp;
            CCR_QureUtility.deviceQureEligibility(qurmsg);
            String quremes = JSON.serialize(qurmsg);
            CCR_QureHistory__c qureHisOne = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_Consumer__c = ct.id, CCR_QureChannel__c = 'Call Center', CCR_DiagnosticResult__c = 'HC3', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHisOne;
            CCR_QureMsg qurmsgOne = new CCR_QureMsg();
            qurmsgOne.Codentify = ast.CCR_CodentifyId__c;
            qurmsgOne.QureHistryId = qureHisOne.Id;
            qurmsgOne.Market = 'KR';
            CCR_QureUtility.deviceQureEligibility(qurmsgOne);
            system.assert(quremes != null);
            CCR_QureUtility.prepareOverrideData(quremes,'Case', 'Status');
            CCR_QureUtility.deviceQureOverRide(quremes, false, null);
            CCR_QureUtility.getCaseSubtype('Pocket');
            CCR_QureUtility.getAssetDetails(ast.CCR_CodentifyId__c);
            CCR_QureUtility.updateUserLanguage('ko');
            CCR_QureUtility.deviceQureOverRide(quremes, true, 'Unsatisfied customer');
            test.stopTest();
        }
    }

    /**
* Method Name:  positiveTestTwo
* Arguments: NA
* Return: NA.
* Description: This method is to test positive scenariao.
**/
    static testMethod void positiveTestTwo() {
        user u =[SELECT id, name from user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(u) {
            Account acc = new Account(Name='testAccount');
            insert acc;
            Contact ct = new Contact(LastName='testContact',Phone='01012341234');
            insert ct;
            Asset ast = new Asset(Name='testAsset',AccountId=acc.Id,ContactId=ct.Id);
            insert ast;
            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHis;
            qureHis.CCR_Consumer__c = ct.id;
            update qureHis;
            Map<String, Map<String, String>> codentifyConsumerMap = new Map<String, Map<String, String>>();
            Map<String, String> map2 = new Map<String, String>();
            map2.put('SpiceId',ct.id);
            map2.put('ActionDate',String.valueOf(System.now()));
            codentifyConsumerMap.put(ast.CCR_CodentifyId__c, map2);
            test.startTest();
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            CCR_QureUtility.deviceQureEligibility(qurmsg);
            System.assert(qurmsg != null);
            test.stopTest();
        }
    }

    /**
* Method Name:  escaltedCaseTest
* Arguments: NA
* Return: NA.
* Description: This method is to test Escalated to CSC.
**/

    static testMethod void escaltedCaseTest() {
        user u =[SELECT id, name from user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        CCR_QureConfiguration__c qureconfig = [SELECT ID, CCR_CodeToBeEscalated__c from CCR_QureConfiguration__c WHERE CCR_DiagnosticResult__c ='HC1' ];
        qureconfig.CCR_CodeToBeEscalated__c = true;
        update qureconfig;
        System.runAs(u) {
            Account acc = new Account(Name='testAccount');
            insert acc;
            Contact ct = new Contact(LastName='testContact',Phone='01012341234');
            insert ct;
            Asset ast = new Asset(Name='testAsset',AccountId=acc.Id,ContactId=ct.Id);
            insert ast;
            ast.KDCE_OriginalWarrantyDate__c = null;
            update ast;
            list<contact> con = CCR_TestUtility.createContacts(1);
            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHis;
            system.assert(qureHis != null);
            qureHis.CCR_Consumer__c = con[0].id;
            update qureHis;
            test.startTest();
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            CCR_QureUtility.deviceQureEligibility(qurmsg);
            test.stopTest();
        }
    }


    /**
* Method Name:  codeNotCoveredTest
* Arguments: NA
* Return: NA.
* Description: This method is to test Code Not covered in Qure.
**/

    static testMethod void codeNotCoveredTest() {
        user u =[SELECT id, name from user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        CCR_QureConfiguration__c qureconfig = [SELECT ID, CCR_CoveredInWarranty__c from CCR_QureConfiguration__c WHERE CCR_DiagnosticResult__c ='HC1' ];
        qureconfig.CCR_CoveredInWarranty__c = false;
        update qureconfig;
        System.runAs(u) {
            Account ass = new Account(Name='testAccount');
            insert ass;
            Contact ct = new Contact(LastName='testContact',Phone='01012331234');
            Asset ast = new Asset(Name='testAsset', ContactId=ct.Id, AccountId=ass.Id);
            insert ast;
            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHis;
            system.assert(qureHis != null);
            qureHis.CCR_Consumer__c = ct.id;
            update qureHis;
            Map<String, Map<String, String>> codentifyConsumerMap = new Map<String, Map<String, String>>();
            Map<String, String> map2 = new Map<String, String>();
            map2.put('SpiceId',ct.id);
            map2.put('ActionDate',String.valueOf(System.now()));
            codentifyConsumerMap.put(ast.CCR_CodentifyId__c, map2);
            test.startTest();
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            CCR_QureUtility.deviceQureEligibility(qurmsg);
            test.stopTest();
        }
    }

    /**
* Method Name:  outoffWarrantyTest
* Arguments: NA
* Return: NA.
* Description: This method is to test out off warranty in Qure.
**/

    static testMethod void outoffWarrantyTest() {
        user u =[SELECT id, name from user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        CCR_QureConfiguration__c qureconfig = [SELECT ID, CCR_CoveredInWarranty__c from CCR_QureConfiguration__c WHERE CCR_DiagnosticResult__c ='HC1' ];
        qureconfig.CCR_CoveredInWarranty__c = true;
        update qureconfig;
        System.runAs(u) {
            list<contact> con = CCR_TestUtility.createContacts(1);
            Account ass = new Account(Name='testAccount');
            insert ass;
            Contact ct = new Contact(LastName='testContact',Phone='01012331234');
            Asset ast = new Asset(Name='testAsset', ContactId=ct.Id, AccountId=ass.Id);
            insert ast;
            ast.KDCE_OriginalWarrantyDate__c = date.today().addDays(-10);
            ast.ContactId =con[0].Id;
            update ast;

            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHis;
            qureHis.CCR_Consumer__c = con[0].id;
            update qureHis;
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            test.startTest();
            CCR_QureUtility.deviceQureEligibility(qurmsg);
            test.stopTest();
        }
    }

    /**
* Method Name:  overRIdeTest
* Arguments: NA
* Return: NA.
* Description: This method is to test over RIde in Qure.
**/

    static testMethod void overRIdeTest() {
        user u =[SELECT id, name from user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        CCR_QureConfiguration__c qureconfig = [SELECT ID, CCR_CoveredInWarranty__c from CCR_QureConfiguration__c WHERE CCR_DiagnosticResult__c ='HC1' ];
        qureconfig.CCR_CoveredInWarranty__c = false;
        update qureconfig;
        System.runAs(u) {
            Account ass = new Account(Name='testAccount');
            insert ass;
            Contact ct = new Contact(LastName='testContact',Phone='01012331234');
            Asset ast = new Asset(Name='testAsset', ContactId=ct.Id, AccountId=ass.Id);
            insert ast;
            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling', CCR_Status__c= 'Active');
            insert qureHis;
            system.assert(qureHis != null);
            qureHis.CCR_Consumer__c = ct.id;
            update qureHis;
            Map<String, Map<String, String>> codentifyConsumerMap = new Map<String, Map<String, String>>();
            Map<String, String> map2 = new Map<String, String>();
            map2.put('SpiceId',ct.id);
            map2.put('ActionDate',String.valueOf(System.now()));
            codentifyConsumerMap.put(ast.CCR_CodentifyId__c, map2);
            test.startTest();
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            CCR_QureUtility.deviceQureEligibility(qurmsg);
            test.stopTest();
        }
    }

    /**
    * Method Name:  defectiveDeviceTest
    * Description: This method is to test over RIde in Qure.
    **/
    static testMethod void defectiveDeviceTest() {
        user admuserKR = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        System.runAs(admuserKR) {
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, ContactId, CCR_DefectiveDevice__c, KDCE_OriginalWarrantyDate__c FROM asset LIMIT 1];
            ast.CCR_DefectiveDevice__c = true;
            ast.KDCE_OriginalWarrantyDate__c = system.today().addDays(100);
            update ast;
            String marketConfigrecordtypeId = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_MarketConfiguration').getRecordTypeId();
            CCR_QureConfiguration__c marketQureConfig = new CCR_QureConfiguration__c(CCR_EligibleForReplacement__c = 14, recordtypeid = marketConfigrecordtypeId, CCR_MaxNumberOfReplacementsPerDevice__c =1, CCR_Country__c ='KR',CCR_Model__c='A1403', CCR_SubjectCode__c = 'C002', CCR_DiagnosticResult__c = 'HC2');
            insert marketQureConfig;
            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC2', CCR_DiagnosticDescription__c='Broken Heating Blade', CCR_Status__c= 'Active');
            insert qureHis;
        }
        user testUser =[SELECT id, name from user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(testUser) {
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, Contactid FROM asset LIMIT 1];
            list<contact> con = CCR_TestUtility.createContacts(1);
            CCR_QureHistory__c qureHis = [SELECT ID, CCR_Consumer__c FROM CCR_QureHistory__c where  CCR_QureChannel__c = 'E-Commerce' AND CCR_DiagnosticResult__c = 'HC2' LIMIT 1];
            system.assert(qureHis != null);
            qureHis.CCR_Consumer__c = con[0].id;
            update qureHis;
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            test.startTest();
//            CCR_QureUtility.deviceQureEligibility(qurmsg);
            test.stopTest();
        }
    }

    static testMethod void test001(){
        Account ass = new Account(Name='testAccount');
        insert ass;
        Contact ct = new Contact(LastName='testContact',Phone='01012331234');
        Asset ast = new Asset(Name='testAsset', ContactId=ct.Id, AccountId=ass.Id);
        insert ast;
        CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC2', CCR_DiagnosticDescription__c='Broken Heating Blade', CCR_Status__c= 'Active');
        insert qureHis;
        Case c = new Case();
        insert c;
        List<Asset> astList = new List<Asset>();
        astList.add(ast);
        test.startTest();
        CCR_QureUtility.updateQureHistory(qureHis, true,true,true,c.Id,true,'broken','C002','Not Eligible',true,system.now(),true);
        CCR_QureUtility.updateQureDeviceReplacementChannel(ast,'LSP');
        CCR_QureUtility.updateQureDeviceEligibleDays(ast);
        CCR_QureUtility.getReplacementDate(astList);
        CCR_QureUtility.runTest();
        test.stopTest();
    }
}