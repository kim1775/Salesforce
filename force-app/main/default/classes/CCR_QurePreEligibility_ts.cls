/**
 * Created by I2MAX on 2021-07-17.
 */

@IsTest(seealldata=false)
public class CCR_QurePreEligibility_ts {
    static final string TESTDEVICE = 'Test Device';
    static final string TESTCODENTIFY = 'xyz353';
    static final string TESTINTERNALID = 'cdf678';
    static final string TESTPARENTCODENTIFY = 'abc123';
    static final string TESTCONLNAME = 'John';
    static final string TESTCONFNAME = 'King';
    static final String DEVICEISSUE = SObjectType.CCR_DeviceDiagnostic__c.getRecordTypeInfosByDeveloperName().get('CCR_DeviceIssue').getRecordTypeId();
    /**
* Method Name :  testdata
* Arguments:
@ String -
@ String -
@ String -
* Return : None
* Description: Test data method.
**/
    @testSetup static void testdata(){
        //List<CCR_DeviceDiagnostic__c> DeviceDiagnosticdata= Test.loadData(CCR_DeviceDiagnostic__c.sObjectType, 'CCR_DeviceDiagnosticCS');
        CCR_CarePlusConfiguration__c testCSData = new CCR_CarePlusConfiguration__c(Name='KR', CCR_Country__c='Korea', CCR_CarePlusActivated__c=true, CCR_L0codes__c='C101', CCR_AccidentalDamageLimit__c=2);//Amrit Das added CCR_BrandFamiliesCovered__c as a part of CCR-174919
        insert testCSData;
        user admuser=CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        System.runAs(admuser) {
            List<Contact> con = CCR_TestUtility.createContacts(1);
            //List<CCR_DeviceDiagnostic__c> deviceDiagnostics = Test.loadData(CCR_DeviceDiagnostic__c.sObjectType, 'CCR_DeviceDiagnostics');
            list<CCR_Material__c> mats= CCR_TestUtility.createMaterials(1,'D0201','2.4','JP04');
            mats[0].CCR_Color__c = 'SLV';
            update mats;
            CCR_DeviceDiagnostic__c devicediagnostic = new CCR_DeviceDiagnostic__c(CCR_Model__c = 'A1403', CCR_Active__c = true, RecordTypeId = DEVICEISSUE);
            insert devicediagnostic;
            CCR_DeviceDiagnosticLocalization__c qureMessage = new CCR_DeviceDiagnosticLocalization__c(CCR_DeviceDiagnostic__c =devicediagnostic.Id, CCR_Country__c = 'KR', CCR_Language__c ='en', CCR_Message__c = 'test message');
            insert qureMessage;
            List<RecordType> limitedEditionType = [SELECT Id
            FROM RecordType
            WHERE SObjectType = 'CCR_QureConfiguration__c'
            AND DeveloperName = 'CCR_LimitedEdition'];
            Asset ast = CCR_TestUtility.createassets(mats[0].id,con[0].id, CCR_Constants.ASSETACTIVE, TESTCODENTIFY, TESTPARENTCODENTIFY, TESTINTERNALID);
            CCR_QureHistory__c qureHis = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c='Paint Peeling',
                    CCR_EndDiagnostic__c = datetime.now(), CCR_EligibilityResult__c = CCR_Constants.NOTELIGIBLE);
            insert qureHis;
            CCR_QureConfiguration__c qureConfig = new CCR_QureConfiguration__c( CCR_Model__c = 'A1403',CCR_Color__c='SLV',
                    recordtypeid = limitedEditionType[0].Id, CCR_Country__c ='KR');
            insert qureConfig;
            user u = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            ast.OwnerId = u.Id;
            update ast;
            con[0].OwnerId = u.Id;
            update con;
        }
    }
    /*
* Method Name: positiveTestAsset;
* Arguments :
* Return : Pagereference
* Description :test
*/
    static testMethod void positiveTestAsset() {
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c ='Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Call Center Agent';
        update usrqure;
        system.debug('&&&&'+usrqure);
        DateTime startTime = DateTime.now();
        Boolean limitedDevice = false;
        String qurhstrChannel ='Call Center Agent';
        System.runAs(usrqure) {
            asset astRec =[SELECT Id, Status, CCR_CodentifyId__c,
                    Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_ModelNumber__c,
                    CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            astRec.Status = 'active';
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            system.debug('astRec.CCR_EligibilityDueDate__c'+astRec.CCR_EligibilityDueDate__c);
            update astRec;
            system.debug('astRec  '+astRec);
            system.Debug('quey res '+[SELECT Id FROM CCR_DeviceDiagnostic__c
            WHERE CCR_Active__c = true AND
            CCR_Model__c=:astRec.CCR_DeviceProductCode__r.CCR_ModelNumber__c]);
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];
            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.PICKUPATCVSSTORE;
            update qureHistory;
            system.debug('qureHistory'+qureHistory);
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c  != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            quremsg.UserType = 'Call Center Agent';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.COURIERDELIVERY;
            update qureHistory;
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.FACETOFACE;
            update qureHistory;
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            CCR_QurePreEligibility.updateQurechannel(usrqure.CCR_UserType__c);
            CCR_QurePreEligibility.createQurehistory(astRec, startTime, limitedDevice, qurhstrChannel);
            CCR_QurePreEligibility.updateQureHistory(qureHistory[0]);
            test.stopTest();

        }
    }

    /*
* Method Name: positiveTestAsset;
* Arguments :
* Return : Pagereference
* Description :test
*/
    static testMethod void testNodeviceDiagnostic() {
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c ='Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Call Center Agent';
        update usrqure;
        system.debug('&&&&'+usrqure);
        DateTime startTime = DateTime.now();
        Boolean limitedDevice = false;
        String qurhstrChannel ='Call Center Agent';
        System.runAs(usrqure) {
            asset astRec =[SELECT Id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c,
                    CCR_DeviceProductCode__r.CCR_ModelNumber__c,CCR_EligibilityDueDate__c
            FROM asset limit 1];
            astRec.Status = 'active';
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            system.Debug('quey res '+[SELECT Id FROM CCR_DeviceDiagnostic__c
            WHERE CCR_Active__c = true AND
            CCR_Model__c=:astRec.CCR_DeviceProductCode__r.CCR_ModelNumber__c]);
            CCR_DeviceDiagnostic__c devicediagnostic = [SELECT Id,CCR_Model__c
            FROM CCR_DeviceDiagnostic__c
            WHERE CCR_Model__c ='A1403'];
            devicediagnostic.CCR_Active__c = false;
            update devicediagnostic;
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];
            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.PICKUPATCVSSTORE;
            update qureHistory;
            system.debug('qureHistory'+qureHistory);
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c  != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            CCR_QurePreEligibility.updateQurechannel(usrqure.CCR_UserType__c);
            CCR_QurePreEligibility.createQurehistory(astRec, startTime, limitedDevice, qurhstrChannel);
            CCR_QurePreEligibility.updateQureHistory(qureHistory[0]);
            test.stopTest();

        }
    }
    /**
* Method Name :  testdata
* Arguments: positiveTestAsset1
* Return : None
* Description: Test data method.
**/
    static testMethod void positiveTestAsset1() {
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c ='Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Consumer';
        update usrqure;
        DateTime startTime = DateTime.now();
        Boolean limitedDevice = false;
        String qurhstrChannel ='Consumer';
        System.runAs(usrqure) {
            //List<Contact> con = CCR_TestUtility.createContacts(1);
            asset astRec =[SELECT Id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c,CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            astRec.Status = 'active';
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            system.debug('astRec.CCR_EligibilityDueDate__c'+astRec.CCR_EligibilityDueDate__c);
            update astRec;
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];
            CCR_DeviceDiagnostic__c devicediagnostic = [SELECT Id,CCR_Model__c
            FROM CCR_DeviceDiagnostic__c
            WHERE CCR_Model__c ='A1403'];
            devicediagnostic.CCR_Active__c = true ;
            update devicediagnostic;
            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.COURIERDELIVERY;
            update qureHistory;
            system.debug('qureHistory'+qureHistory);
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c  != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            CCR_QurePreEligibility.updateQurechannel(usrqure.CCR_UserType__c);
            CCR_QurePreEligibility.createQurehistory(astRec, startTime, limitedDevice, qurhstrChannel);
            CCR_QurePreEligibility.updateQureHistory(qureHistory[0]);
            test.stopTest();

        }
    }
    /**
* Method Name :  positiveTestAsset2
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void positiveTestAsset2() {
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c ='Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Flagship Store Agent';
        update usrqure;
        DateTime startTime = DateTime.now();
        Boolean limitedDevice = false;
        String qurhstrChannel ='SYSADm';
        System.runAs(usrqure) {
            asset astRec =[SELECT Id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.Status = 'active';
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            system.debug('astRec.CCR_EligibilityDueDate__c'+astRec.CCR_EligibilityDueDate__c);
            update astRec;
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];
            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.COURIERDELIVERY;
            update qureHistory;
            system.debug('qureHistory'+qureHistory);
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c  != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            CCR_QurePreEligibility.updateQurechannel(usrqure.CCR_UserType__c);
            CCR_QurePreEligibility.createQurehistory(astRec, startTime, limitedDevice, qurhstrChannel);
            CCR_QurePreEligibility.updateQurechannel(CCR_Constants.SERVICECENTERS);
            CCR_QurePreEligibility.updateQurechannel(CCR_Constants.FLAGSHIPSTORE);
            test.stopTest();

        }
    }
    /**
* Method Name :  positiveTestAsset2
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void positiveTestAsset3(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Flagship Store Agent';
        update usrqure;
        system.debug('####'+usrqure);
        DateTime startTime = DateTime.now();
        Boolean limitedDevice = false;
        String qurhstrChannel = CCR_Constants.SERVICECENTERS;
        System.runAs(usrqure) {
            asset astRec =[SELECT Id, Status, CCR_CodentifyId__c,
                    Contact.CCR_CountryID__c,
                    CCR_EligibilityDueDate__c
            FROM asset  LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.Status = 'active';
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            system.debug('astRec.CCR_EligibilityDueDate__c'+astRec.CCR_EligibilityDueDate__c);
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.PICKUPATCVSSTORE;
            update qureHistory;
            system.debug('qureHistory'+qureHistory);
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c  != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            CCR_QurePreEligibility.updateQurechannel(usrqure.CCR_UserType__c);
            CCR_QurePreEligibility.createQurehistory(astRec, startTime, limitedDevice, qurhstrChannel);
            CCR_QurePreEligibility.updateQurechannel(CCR_Constants.SERVICECENTERS);
            CCR_QurePreEligibility.updateQurechannel(CCR_Constants.FLAGSHIPSTORE);
            CCR_QurePreEligibility.updateQureHistory(qureHistory[0]);
            test.stopTest();


        }

    }
    /**
* Method Name :
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void negiviteTest(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(usrqure) {
            asset astRec =[SELECT Id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            astRec.Status = 'Produced';
            Update astRec;
            System.assert(astRec.Status != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();
        }
    }
    /**
* Method Name :  positiveTestAsset4
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void positiveTestAsset4(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            //astRec.Status = 'active';
            system.debug('status'+astRec.Status);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.FACETOFACE;
            update qureHistory;
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c != null);
            system.debug('qureHistoryF2F'+qureHistory);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();

        }

    }

    static testMethod void positiveTestAsset6(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            //astRec.Status = 'active';
            system.debug('status'+astRec.Status);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = null;
            update qureHistory;
//            System.assert(qureHistory[0].CCR_QureReplacementChannel__c != null);
            system.debug('qureHistoryF2F'+qureHistory);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();

        }

    }

    /**
* Method Name :  positiveTestAsset5
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void positiveTestAsset5(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.Status = 'active';
            system.debug('status'+astRec.Status);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.PICKUPATCVSSTORE;
            update qureHistory;
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c != null);
            system.debug('qureHistoryCVS'+qureHistory);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();
        }
    }
    /**
* Method Name :  negiviteTest2
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void negiviteTest2(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('usrqure'+usrqure);
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.COURIERDELIVERY;
            update qureHistory;
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();

        }

    }
    /**
* Method Name :  negiviteTest3
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void negiviteTest3(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Consumer';
        update usrqure;
        system.debug('usrqure@@'+usrqure);
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            system.assert(astRec.CCR_EligibilityDueDate__c !=null);
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = null;
            update qureHistory;
            system.debug('QureReplacementChannel'+qureHistory);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();

        }

    }
    /**
* Method Name :  negiviteTest3
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void negiviteTest4(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Flagship Store Agent';
        update usrqure;
        system.debug('servicecenter'+usrqure);
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = CCR_Constants.FACETOFACE;
            update qureHistory;
            System.assert(qureHistory[0].CCR_QureReplacementChannel__c != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();

        }
    }
    /**
* Method Name :  negiviteTest3
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void negiviteTest5(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Corner Shop Agent';
        update usrqure;
        system.debug('servicecenter2'+usrqure);
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            update astRec;
            system.assert(astRec.CCR_EligibilityDueDate__c != null);
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = null;
            update qureHistory;
            system.debug('QureReplacementChannel'+qureHistory);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();

        }

    }

    static testMethod void negiviteTest6(){
        user usrqure =[SELECT Id,CCR_UserType__c
        FROM user
        WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        usrqure.CCR_UserType__c = 'Consumer';
        update usrqure;
        system.debug('servicecenter2'+usrqure);
        System.runAs(usrqure) {
            asset astRec =[SELECT id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
//            astRec.CCR_EligibilityDueDate__c = system.today().addDays(1) ;
            astRec.CCR_CarePlusStatus__c = 'Disenrolled';
            update astRec;
//            system.assert(astRec.CCR_EligibilityDueDate__c != null);
            List<CCR_QureHistory__c> qureHistory = [SELECT Id,CCR_QureChannel__c,CCR_Device__c,CCR_EndDiagnostic__c,
                    CCR_QureReplacementChannel__c,
                    CCR_EligibilityResult__c,CCR_CodeToBeEscalated__c FROM CCR_QureHistory__c
            WHERE CCR_Device__c =:astRec.id
            ORDER BY createddate DESC LIMIT 1];

            qureHistory[0].CCR_QureReplacementChannel__c = null;
            update qureHistory;
            system.debug('QureReplacementChannel'+qureHistory);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();

        }

    }

    /**
* Method Name :  qureNotActive
* Arguments:
* Return : None
* Description: Test data method.
**/
    static testMethod void qureNotActive(){
        user usrqure =[SELECT Id,CCR_UserType__c,country
        FROM user WHERE  CCR_UserType__c = 'Call Center Agent'
        ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('user'+usrqure);
        System.runAs(usrqure) {
            asset astRec =[SELECT Id, Status, CCR_CodentifyId__c,Contact.CCR_CountryID__c,contactid, CCR_EligibilityDueDate__c
            FROM asset LIMIT 1];
            System.currentPageReference().getParameters().put('asset',astRec.Id);
            contact con = [SELECT Id,CCR_CountryID__c
            FROM contact
            WHERE id =: astRec.contactid];
            con.CCR_CountryID__c = 'FR';
            update con;
            system.debug('@@astRec'+astRec);
            system.assert(con.CCR_CountryID__c != null);
            test.startTest();
            CCR_QureMsg quremsg = new CCR_QureMsg();
            quremsg.Codentify = astRec.CCR_CodentifyId__c;
            quremsg.Market = 'KR';
            CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
            test.stopTest();
        }
    }

    /**
   * Method Name :  qureNotActive
   * Description: Test data method.
   **/
    static testMethod void subscriptionsDeviceQureBlock(){
        asset astRec =[SELECT Id, CCR_SubscribedDevice__c, CCR_SubscriptionID__c,
                Status, CCR_CodentifyId__c, Contact.CCR_CountryID__c,
                CCR_DeviceProductCode__r.CCR_ModelNumber__c, CCR_EligibilityDueDate__c
        FROM asset limit 1];
        astRec.CCR_SubscribedDevice__c = true;
        astRec.CCR_SubscriptionID__c = '12345SubscriptionDevice';
        update astRec;
        test.startTest();
        CCR_QureMsg quremsg = new CCR_QureMsg();
        quremsg.Codentify = astRec.CCR_CodentifyId__c;
        quremsg.Market = 'KR';
        quremsg.UserType = 'Call Center Agent';
        CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg);
        //system.assert(quremsg.ErrorMsgId == CCR_Constants.SUBSCRIPTIONUNPAIDAGENT);
        CCR_QureMsg quremsg1 = new CCR_QureMsg();
        quremsg1.Codentify = astRec.CCR_CodentifyId__c;
        quremsg1.Market = 'KR';
        quremsg1.UserType = 'Consumer';
        CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg1);
//        system.assert(quremsg1.ErrorMsgId == CCR_Constants.SUBSCRIPTIONUNPAIDCONSUMER);
        CCR_QureMsg quremsg2 = new CCR_QureMsg();
        quremsg2.Codentify = astRec.CCR_CodentifyId__c;
        quremsg2.Market = 'KR';
        quremsg2.UserType = 'Call Center Agent';
        CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg2);
//        system.assert(quremsg2.ErrorMsgId == CCR_Constants.SUBSQUREDISABLEAGENT);
        CCR_QureMsg quremsg3 = new CCR_QureMsg();
        quremsg3.Codentify = astRec.CCR_CodentifyId__c;
        quremsg3.Market = 'KR';
        quremsg3.UserType = 'Consumer';
        CCR_QurePreEligibility.runPreeligibilitychecksqure(quremsg3);
//        system.assert(quremsg3.ErrorMsgId == CCR_Constants.SUBSQUREDISABLECONSUMER);
        CCR_QurePreEligibility.forTest();
        CCR_Constants c = new CCR_Constants();
        test.stopTest();
    }
}