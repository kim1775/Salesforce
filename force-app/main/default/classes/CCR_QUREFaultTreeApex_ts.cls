/**
 * Created by I2MAX on 2021-07-16.
 */

@IsTest
public class CCR_QUREFaultTreeApex_ts {
    public static final String COURIERDELIVERYRT = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_CourierDeliveryConfiguration').getRecordTypeId();
    public static final String QUREREPLACEMENTRT = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_QureReplacementChannel').getRecordTypeId();
    public static final String PICKLISTRT = SObjectType.CCR_QureConfiguration__c.getRecordTypeInfosByDeveloperName().get('CCR_PicklistDependency').getRecordTypeId();
    /**
    * Method Name :  testdata
    * Arguments: null
    * Return : void
    * Description: This method is used to create test data
    **/
    @testSetup static void testdata() {
        user admuserKR = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        System.runAs(admuserKR) {
            List<CCR_DeviceDiagnostic__c> divList = new List<CCR_DeviceDiagnostic__c>();
            CCR_DeviceDiagnostic__c deiiceRec1 = new CCR_DeviceDiagnostic__c(Name = 'Other Issue',CCR_Active__c = true, CCR_DefaultMessage__c='test', CCR_DiagnosticDescription__c='Blinking Red Light',  CCR_Model__c='A1403', CCR_OrderPriority__c=1);
            divList.add(deiiceRec1);
            CCR_DeviceDiagnostic__c deiiceRec2 = new CCR_DeviceDiagnostic__c(Name = 'Paint Peeling (Holder)', CCR_Active__c = true, CCR_DiagnosticResult__c='HC1');
            divList.add(deiiceRec2);
            CCR_DeviceDiagnostic__c deiiceRec3 = new CCR_DeviceDiagnostic__c(Name = 'Out of Warranty', CCR_Active__c = true, CCR_MessageName__c ='Out of Warranty', CCR_DefaultMessage__c='Out of Warranty');
            divList.add(deiiceRec3);
            CCR_DeviceDiagnostic__c deiiceRec4 = new CCR_DeviceDiagnostic__c(Name = 'new veev issue',CCR_Active__c = true, CCR_DefaultMessage__c='test', CCR_DiagnosticDescription__c='Blinking Red Light',  CCR_Model__c='A1403', CCR_OrderPriority__c=1);
            divList.add(deiiceRec4);
            insert divList;
            CCR_DeviceDiagnostic__c deiiceRecChild = new CCR_DeviceDiagnostic__c(Name = 'Other Issue 1',CCR_Active__c = true, CCR_DefaultMessage__c='test', CCR_DiagnosticDescription__c='Bluetooth malfunction',  CCR_Model__c='A1403', CCR_OrderPriority__c=1, CCR_ParentDiagnostic__c=divList[0].Id);
            Insert deiiceRecChild;

            list<CCR_Material__c> mats= CCR_TestUtility.createMaterials(1,'D0201','2.4','JP04');
            Asset ast = CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETPRODUCED, 'TESTCODENTIFY', 'TESTPARENTCODENTIFY', 'TESTINTERNALID');
            Asset ast1 = CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETPRODUCED, 'TESTCODENTIFY1', 'TESTPARENTCODENTIFY1', 'TESTINTERNALID1');
            String marketConfigrecordtypeId = CCR_Utility.getRecordTypeId('CCR_QureConfiguration__c','Market Configuration');
            String marketRplacementrecordtypeId = CCR_Utility.getRecordTypeId('CCR_QureConfiguration__c','Market Replacement');
            List<CCR_QureConfiguration__c> qureConfigToInset = new List<CCR_QureConfiguration__c>();
            CCR_QureConfiguration__c paintPeelingConfig = new CCR_QureConfiguration__c(CCR_Model__c = 'A1403', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c = 'Paint Peeling',CCR_SubjectCode__c = 'C101', recordtypeid = marketConfigrecordtypeId, CCR_Country__c ='KR', CCR_CoveredInWarranty__c = true, CCR_MaterialGroupDescription__c ='Holder /S');
            CCR_QureConfiguration__c solvedFixRedLightConfig = new CCR_QureConfiguration__c(CCR_Model__c = 'A1403', CCR_DiagnosticResult__c = 'HA1', CCR_DiagnosticDescription__c = 'Solved - Fixed Red Light or No light',CCR_SubjectCode__c = 'A101', recordtypeid = marketConfigrecordtypeId, CCR_Country__c ='KR', CCR_CoveredInWarranty__c = false, CCR_MaterialGroupDescription__c ='Holder /S');
            qureConfigToInset.add(paintPeelingConfig);
            qureConfigToInset.add(solvedFixRedLightConfig);
            CCR_QureConfiguration__c marketQureConfig = new CCR_QureConfiguration__c(CCR_EligibleForReplacement__c = 14, recordtypeid = marketRplacementrecordtypeId, CCR_MaxNumberOfReplacementsPerDevice__c =3, CCR_Country__c ='KR');
            qureConfigToInset.add(marketQureConfig);
            CCR_QureConfiguration__c qureConfig1 = new CCR_QureConfiguration__c(CCR_Model__c = 'A1403', CCR_Color__c='SLV',
                    CCR_DisplayOrder__c = 1, CCR_MarketEnabled__c = TRUE,
                    CCR_Persona__c = 'Call Center Agent',
                    CCR_ReplacementChannel__c = 'CourierDelivery',
                    CCR_ReplacementType__c = 'SLU', CCR_Country__c ='KR',
                    recordtypeid = QUREREPLACEMENTRT);
            qureConfigToInset.add(qureConfig1);
            CCR_QureConfiguration__c qureConfig2 = new CCR_QureConfiguration__c(CCR_Model__c = 'DEFAULT',
                    CCR_DisplayOrder__c = 1, CCR_MarketEnabled__c = TRUE,
                    CCR_Persona__c = 'Call Center Agent',
                    CCR_ReplacementChannel__c = 'IQOS_Store',
                    CCR_ReplacementType__c = 'SLU', CCR_Country__c ='KR',
                    recordtypeid = QUREREPLACEMENTRT);
            qureConfigToInset.add(qureConfig2);
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'FirstName', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'LastName', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'StreetName', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'StreetNumber', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'City', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'PostalCode', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'Phone', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'Reference', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'Building', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'Apartment', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'Department', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'District', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'IDType', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'IDNumber', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_FormField__c = 'TaxID', CCR_MarketEnabled__c = true, CCR_Mandatory__c = true, RecordTypeId = COURIERDELIVERYRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_PicklistValue__c = 'testarea', CCR_MarketEnabled__c = true, RecordTypeId = PICKLISTRT));
            qureConfigToInset.add(new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_PicklistValue__c = 'testcity', CCR_MarketEnabled__c = true, RecordTypeId = PICKLISTRT));
            insert qureConfigToInset;
            List<CCR_QureConfiguration__c> pValuesList = [SELECT Id, CCR_PicklistValue__c, CCR_DependentOn__c
            FROM CCR_QureConfiguration__c
            WHERE RecordTypeId = :PICKLISTRT];
            for(CCR_QureConfiguration__c oneRec : [SELECT Id
            FROM CCR_QureConfiguration__c
            WHERE CCR_FormField__c = 'Department'
            AND RecordTypeId = :COURIERDELIVERYRT LIMIT 1]){
                pValuesList[0].CCR_DependentOn__c = oneRec.Id;
                pValuesList[1].CCR_DependentOn__c = pValuesList[0].Id;
            }
            update pValuesList;
            CCR_QureConfiguration__c idTypesDate;
            for(CCR_QureConfiguration__c oneRec : [SELECT Id
            FROM CCR_QureConfiguration__c
            WHERE CCR_FormField__c = 'IDType'
            AND RecordTypeId = :COURIERDELIVERYRT LIMIT 1]){
                idTypesDate = new CCR_QureConfiguration__c(CCR_Country__c = 'KR', CCR_DependentOn__c = oneRec.Id, CCR_PicklistValue__c = 'testIdType', CCR_MarketEnabled__c = true, RecordTypeId = PICKLISTRT);
            }
            insert idTypesDate;
            CCR_QureHistory__c paintPeelingHistory = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HC1', CCR_DiagnosticDescription__c = 'Paint Peeling');
            CCR_QureHistory__c solvedFixRedLightHistory = new CCR_QureHistory__c(CCR_Device__c = ast.Id, CCR_QureChannel__c = 'E-Commerce', CCR_DiagnosticResult__c = 'HA1', CCR_DiagnosticDescription__c = 'Solved - Fixed Red Light or No light');
            List<CCR_QureHistory__c> qureHistoryToInset = new List<CCR_QureHistory__c>();
            qureHistoryToInset.add(paintPeelingHistory);
            qureHistoryToInset.add(solvedFixRedLightHistory);
            insert qureHistoryToInset;
            user u = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            ast.OwnerId = u.id;
            update ast;
            ast1.OwnerId = u.id;
            update ast1;
            CCR_DeviceDiagnostic__c devicediagon = [SELECT id,name,CCR_Model__c,CCR_MessageName__c FROM CCR_DeviceDiagnostic__c WHERE CCR_MessageName__c ='Out of Warranty'];
            CCR_DeviceDiagnosticLocalization__c qureMessage = new CCR_DeviceDiagnosticLocalization__c(CCR_DeviceDiagnostic__c =devicediagon.Id, CCR_Country__c = 'KR', CCR_Language__c ='en', CCR_Message__c = 'Out of Warranty');
            insert qureMessage;
        }
    }

    /**
    * Method Name : positiveTest
    * Arguments: null
    * Return : void
    * Description: This method is used to test the QUre Fault Tree functionality
    **/
    static testMethod void positiveTest() {
        user ccUser =[SELECT id, name FROM user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(ccUser) {
            list<contact> con = CCR_TestUtility.createContacts(1);
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, Contactid,CCR_DeviceProductCode__r.CCR_ModelNumber__c FROM asset LIMIT 1];
            ast.ContactId = con[0].Id;
            update ast;
            system.debug('ast'+ast.CCR_DeviceProductCode__r.CCR_ModelNumber__c);
            List<CCR_DeviceDiagnostic__c> deviceDiagnostics = [SELECT id,name,CCR_ParentDiagnostic__c FROM CCR_DeviceDiagnostic__c WHERE CCR_ParentDiagnostic__c != null];

            CCR_QureHistory__c paintPeelingHistory;
            CCR_QureHistory__c solvedFixRedLightHistory;
            List<CCR_QureHistory__c> qureHistories = [SELECT Id, CCR_Consumer__c, CCR_Status__c, CCR_QureReplacementChannel__c, CCR_DiagnosticResult__c FROM CCR_QureHistory__c];
            for(CCR_QureHistory__c history : qureHistories){
                if(history.CCR_DiagnosticResult__c == 'HC1'){
                    paintPeelingHistory = history;
                }else if(history.CCR_DiagnosticResult__c == 'HA1'){
                    solvedFixRedLightHistory = history;
                }
                history.CCR_Consumer__c = con[0].id;
                history.CCR_Status__c = 'Active';
                history.CCR_QureReplacementChannel__c = '';
            }
            update qureHistories;
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = paintPeelingHistory.Id;
            qurmsg.Market = 'KR';
            qurmsg.channelSelected = 'CourierDelivery';
            qurmsg.UserType = 'Call Center Agent';
            qurmsg.model = 'A1403';

//            system.assertNotEquals(null, CCR_QUREFaultTreeApex.loadInetialDataForQure(ast.CCR_CodentifyId__c, 'KO', paintPeelingHistory.Id, 'Call Center Agent'));
            Test.startTest();
            CCR_QUREFaultTreeApex.queryDeviceDiagnosticRecs(ast.CCR_CodentifyId__c, deviceDiagnostics[0].CCR_ParentDiagnostic__c, null, 'KR', 'KO', paintPeelingHistory.id, 'Call Center Agent');
            CCR_QUREFaultTreeApex.queryDeviceDiagnosticRecs(ast.CCR_CodentifyId__c, null , deviceDiagnostics[0].Id, 'KR', 'KO', paintPeelingHistory.id, 'Call Center Agent');
            CCR_QUREFaultTreeApex.updateQureHistoryWithResult(JSON.serialize(qurmsg), 'HC1', 'Broken Heating Blade', true);
            CCR_QUREFaultTreeApex.updateQureHistoryWithResult(JSON.serialize(qurmsg), 'HC1', 'Broken Heating Blade', false);
            qurmsg.QureHistryId = solvedFixRedLightHistory.Id;
            CCR_QUREFaultTreeApex.createIssueSolvedhQUreCase(JSON.serialize(qurmsg));
            qurmsg.QureHistryId = paintPeelingHistory.Id;
            system.debug('Qure history'+[Select id,CCR_Status__c from CCR_QureHistory__c where id = :paintPeelingHistory.Id]);
            CCR_QUREFaultTreeApex.createQureCaseForReplacement(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.retrieveAddressDetails(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.replacementChannelsForDevice(JSON.serialize(qurmsg));
            qurmsg.UserType = 'Consumer';
            CCR_QUREFaultTreeApex.replacementChannelsForDevice(JSON.serialize(qurmsg));
            qurmsg.UserType = 'Call Center Agent';
            CCR_QUREFaultTreeApex.updateQureHistory(paintPeelingHistory);
            CCR_QUREFaultTreeApex.checkMaterialGroup(ast.CCR_CodentifyId__c);
            CCR_QUREFaultTreeApex.retrieveReplacementChannelsMetadata('CourierDelivery');
            List<case> qurecase = [SELECT Id FROM Case LIMIT 1];
            system.debug('qurecase'+qurecase);
            CCR_QUREFaultTreeApex.updateCaseRecord(qurecase);
            List<String> resultList = CCR_QUREFaultTreeApex.retrieveChildData('testarea');
            Test.stopTest();
        }
    }

    /**
* Method Name :  positiveCaseCreationForreplacement
* Arguments: null
* Return : void
* Description: This method is used to test the QUre Fault Tree functionality
**/
    static testMethod void positiveCaseCreationForreplacement() {
        user ccUser =[SELECT id, name FROM user WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(ccUser) {
            list<contact> con = CCR_TestUtility.createContacts(1);
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, Contactid,CCR_DeviceProductCode__r.CCR_ModelNumber__c FROM asset LIMIT 1];
            ast.ContactId = con[0].Id;
            update ast;
            CCR_QureHistory__c qureHis = [SELECT ID, CCR_Consumer__c,CCR_Status__c, CCR_DiagnosticDescription__c, CCR_QureReplacementChannel__c FROM CCR_QureHistory__c WHERE CCR_DiagnosticResult__c = 'HC1' LIMIT 1];
            qureHis.CCR_Consumer__c = con[0].id;
            qureHis.CCR_Status__c = 'Active';
            qureHis.CCR_QureReplacementChannel__c = '';
            qureHis.CCR_DiagnosticDescription__c = 'Bluetooth malfunction';
            update qureHis;
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            qurmsg.channelSelected = 'CourierDelivery';
            Test.startTest();
            CCR_QUREFaultTreeApex.loadInetialDataForQure(ast.CCR_CodentifyId__c, 'KO', qureHis.Id, 'Call Center Agent');
            CCR_QUREFaultTreeApex.createQureCaseForReplacement(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.retrieveAddressDetails(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.replacementChannelsForDevice(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.updateQureHistory(qureHis);
            CCR_QUREFaultTreeApex.checkMaterialGroup(ast.CCR_CodentifyId__c);
            CCR_QUREFaultTreeApex.retrieveReplacementChannelsMetadata('CourierDelivery');
            CCR_QUREFaultTreeApex.updateReplacementChannel(JSON.serialize(qurmsg));
            List<case> qurecase = [SELECT Id FROM case LIMIT 1];
//            system.assertNotEquals(null,qurecase);
            CCR_QUREFaultTreeApex.updateCaseRecord(qurecase);
            Test.stopTest();
        }
    }
    /**
* Method Name :  positiveTestAsset1
* Arguments: null
* Return : void
* Description: This method is used to test the QUre Fault Tree functionality
**/
    static testMethod void positiveTestAsset1() {
        user ccUser =[SELECT id, name FROM user WHERE CCR_UserType__c = 'Call Center Agent'  ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(ccUser) {
            list<contact> con = CCR_TestUtility.createContacts(1);
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, Contactid,CCR_DeviceProductCode__r.CCR_ModelNumber__c FROM asset LIMIT 1];
            ast.ContactId = con[0].Id;
            update ast;
            system.debug('ast'+ast.CCR_DeviceProductCode__r.CCR_ModelNumber__c);
            List<CCR_DeviceDiagnostic__c> deviceDiagnostics = [SELECT id,name,CCR_ParentDiagnostic__c FROM CCR_DeviceDiagnostic__c WHERE CCR_ParentDiagnostic__c != null];

            CCR_QureHistory__c paintPeelingHistory;
            CCR_QureHistory__c solvedFixRedLightHistory;
            List<CCR_QureHistory__c> qureHistories = [SELECT Id, CCR_Consumer__c, CCR_Status__c, CCR_QureReplacementChannel__c, CCR_DiagnosticResult__c FROM CCR_QureHistory__c];
            for(CCR_QureHistory__c history : qureHistories){
                if(history.CCR_DiagnosticResult__c == 'HC1'){
                    paintPeelingHistory = history;
                }else if(history.CCR_DiagnosticResult__c == 'HA1'){
                    solvedFixRedLightHistory = history;
                }
                history.CCR_Consumer__c = con[0].id;
                history.CCR_Status__c = 'Inactive';
                history.CCR_QureReplacementChannel__c = 'CourierDelivery';
            }
            update qureHistories;

            paintPeelingHistory.CCR_Status__c = 'Active';
            update paintPeelingHistory;
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = paintPeelingHistory.Id;
            qurmsg.Market = 'KR';
            qurmsg.channelSelected = CCR_Constants.PICKUPATCVSSTORE;

//            system.assertNotEquals(null, CCR_QUREFaultTreeApex.loadInetialDataForQure(ast.CCR_CodentifyId__c, 'KO', paintPeelingHistory.Id, 'Call Center Agent'));
            Test.startTest();
            CCR_QUREFaultTreeApex.queryDeviceDiagnosticRecs(ast.CCR_CodentifyId__c, deviceDiagnostics[0].CCR_ParentDiagnostic__c, null, 'KR', 'KO', paintPeelingHistory.id, 'Call Center Agent');
            CCR_QUREFaultTreeApex.queryDeviceDiagnosticRecs(ast.CCR_CodentifyId__c, null , deviceDiagnostics[0].Id, 'KR', 'KO', paintPeelingHistory.id, 'Call Center Agent');
            CCR_QUREFaultTreeApex.updateQureHistoryWithResult(JSON.serialize(qurmsg), 'HC1', 'Broken Heating Blade', true);
            CCR_QUREFaultTreeApex.updateQureHistoryWithResult(JSON.serialize(qurmsg), 'HC1', 'Broken Heating Blade', false);
            qurmsg.QureHistryId = solvedFixRedLightHistory.Id;
            CCR_QUREFaultTreeApex.createIssueSolvedhQUreCase(JSON.serialize(qurmsg));
            qurmsg.QureHistryId = paintPeelingHistory.Id;
            CCR_QUREFaultTreeApex.createQureCaseForReplacement(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.retrieveAddressDetails(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.replacementChannelsForDevice(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.updateQureHistory(paintPeelingHistory);
            CCR_QUREFaultTreeApex.checkMaterialGroup(ast.CCR_CodentifyId__c);
            CCR_QUREFaultTreeApex.retrieveReplacementChannelsMetadata('CourierDelivery');
            List<case> qurecase = [SELECT Id FROM case LIMIT 1];
            system.debug('qurecase'+qurecase);
            CCR_QUREFaultTreeApex.updateCaseRecord(qurecase);
            qurmsg.Salutation = 'Mr.';
            qurmsg.Address1 ='Address1';
            qurmsg.Address2 = 'Address2';
            qurmsg.FirstName = 'First Name';
            qurmsg.LastName = 'Last Name';
            qurmsg.AddressCity = 'City';
            qurmsg.AddressPostalCode = '1234';
            CCR_QUREFaultTreeApex.placeOrderInDemandWare(JSON.serialize(qurmsg));
            Test.stopTest();
        }

    }

    /**
* Method Name :  positiveTestForCVS
* Arguments: null
* Return : void
* Description: This method is used to test the CVS functionality
**/
    static testMethod void positiveTestForCVS() {
        user ccUser =[SELECT id, name FROM user WHERE CCR_UserType__c = 'Call Center Agent'  ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(ccUser) {
            list<contact> con = CCR_TestUtility.createContacts(1);
            con[0].MobilePhone = '111122222';
//            Update con;
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, Contactid,CCR_DeviceProductCode__r.CCR_ModelNumber__c FROM asset LIMIT 1];
            ast.ContactId = con[0].Id;
            update ast;

            CCR_QureHistory__c qureHis = [SELECT ID, CCR_Consumer__c,CCR_Status__c, CCR_QureReplacementChannel__c FROM CCR_QureHistory__c WHERE CCR_DiagnosticResult__c = 'HC1' LIMIT 1];
            qureHis.CCR_Consumer__c = con[0].id;
            qureHis.CCR_Status__c = 'Active';
            qureHis.CCR_QureReplacementChannel__c = 'CVSStore';
            update qureHis;

            CCR_QureMsg qurmsgCvs = new CCR_QureMsg();
            qurmsgCvs.Codentify = ast.CCR_CodentifyId__c;
            qurmsgCvs.QureHistryId = qureHis.Id;
            qurmsgCvs.Market = 'KR';
            qurmsgCvs.channelSelected = 'CVSStore';
            qurmsgCvs.ConsumerPhone = '1111122222';
            Test.startTest();
            //qurmsgCvs = CCR_QUREFaultTreeApex.createQureCaseForReplacement(JSON.serialize(qurmsgCvs));
            //system.assertNotEquals(null, qurmsgCvs.CaseId);
            CCR_QUREFaultTreeApex.placeOrderInDemandWare(JSON.serialize(qurmsgCvs));
            CCR_QUREFaultTreeApex.sendRequestToResendVoucher(JSON.serialize(qurmsgCvs));
            qurmsgCvs.UserType = 'Consumer';
            qurmsgCvs = CCR_QUREFaultTreeApex.sendRequestToResendVoucher(JSON.serialize(qurmsgCvs));
            qurmsgCvs.UserType = 'Service Center Agent';
            qurmsgCvs = CCR_QUREFaultTreeApex.sendRequestToResendVoucher(JSON.serialize(qurmsgCvs));
            qurmsgCvs.UserType = 'Flagship Store Agent';
            qurmsgCvs = CCR_QUREFaultTreeApex.sendRequestToResendVoucher(JSON.serialize(qurmsgCvs));
            Test.stopTest();
        }
    }

    /**
* Method Name :  positiveTestForiSWAP
* Arguments: null
* Return : void
* Description: This method is used to test the iSWAP functionality
**/
    static testMethod void positiveTestForiSWAP() {
        user ccUser =[SELECT id, name FROM user WHERE CCR_UserType__c = 'Call Center Agent'  ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(ccUser) {
            list<contact> con = CCR_TestUtility.createContacts(1);
            con[0].CCR_CountryPrefixNumber__c = '+421';
            con[0].MobilePhone = '0111122222';
//            Update con;
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, Contactid,CCR_DeviceProductCode__r.CCR_ModelNumber__c FROM asset LIMIT 1];
            ast.ContactId = con[0].Id;
            update ast;

            CCR_QureHistory__c qureHis = [SELECT ID, CCR_Consumer__c,CCR_Status__c, CCR_QureReplacementChannel__c FROM CCR_QureHistory__c WHERE CCR_DiagnosticResult__c = 'HC1' LIMIT 1];
            qureHis.CCR_Consumer__c = con[0].id;
            qureHis.CCR_Status__c = 'Active';
            update qureHis;

            CCR_QureMsg qurmsgiSwap = new CCR_QureMsg();
            qurmsgiSwap.Codentify = ast.CCR_CodentifyId__c;
            qurmsgiSwap.QureHistryId = qureHis.Id;
            qurmsgiSwap.Market = 'KR';
            qurmsgiSwap.channelSelected = 'iSWAP';
            qurmsgiSwap.ConsumerPhone = '+412123456789';
            Test.startTest();
            CCR_QUREFaultTreeApex.retrieveAddressDetails(JSON.serialize(qurmsgiSwap));
            qureHis.CCR_QureReplacementChannel__c = 'iSWAP';
            update qureHis;
            qurmsgiSwap.isCalloutSuccess = true;
            CCR_QUREFaultTreeApex.placeOrderInDemandWare(JSON.serialize(qurmsgiSwap));
            qurmsgiSwap.isCalloutSuccess = false;
            CCR_QUREFaultTreeApex.placeOrderInDemandWare(JSON.serialize(qurmsgiSwap));
//            system.assert(qurmsgiSwap.orderId == null);
            Test.stopTest();
        }
    }

    /**
    * Method Name :  negativeTestForLocalization
    * Arguments: null
    * Return : void
    * Description: This method is used to test negative For Localization
    **/
    static testMethod void negativeTestForLocalization() {
        List<CCR_DeviceDiagnostic__c> divList = [SELECT Id
        FROM CCR_DeviceDiagnostic__c
        WHERE Name = 'Other Issue'
        AND CCR_Active__c = true LIMIT 1];
        List<CCR_DeviceDiagnosticLocalization__c> divDigList = new List<CCR_DeviceDiagnosticLocalization__c> ();
        CCR_DeviceDiagnosticLocalization__c deviceRecChild0 = new CCR_DeviceDiagnosticLocalization__c(CCR_Active__c = true, CCR_Country__c = 'KR', CCR_Message__c='test',
                CCR_LocalisationUID__c = '10', CCR_Language__c='en', CCR_DeviceDiagnostic__c=divList[0].Id);
        divDigList.add(deviceRecChild0);
        CCR_DeviceDiagnosticLocalization__c deviceRecChild1 = new CCR_DeviceDiagnosticLocalization__c(CCR_Active__c = true, CCR_Country__c = 'KR', CCR_Message__c='test',
                CCR_LocalisationUID__c = '11', CCR_Language__c='ko', CCR_DeviceDiagnostic__c=divList[0].Id);
        divDigList.add(deviceRecChild1);
        CCR_DeviceDiagnosticLocalization__c deviceRecChild2 = new CCR_DeviceDiagnosticLocalization__c(CCR_Active__c = false, CCR_Country__c = 'KR', CCR_Message__c='test draft1',
                CCR_Language__c='pl', CCR_DeviceDiagnostic__c=divList[0].Id, CCR_Status__c = 'Draft');
        divDigList.add(deviceRecChild2);
        insert divDigList;

        List<CCR_DeviceDiagnosticLocalization__c> divDigList1 = new List<CCR_DeviceDiagnosticLocalization__c> ();
        CCR_DeviceDiagnosticLocalization__c deviceRecChild3 = new CCR_DeviceDiagnosticLocalization__c(CCR_Active__c = true, CCR_Country__c = 'KR', CCR_Message__c='test', CCR_Language__c='en', CCR_DeviceDiagnostic__c=divList[0].Id);
        divDigList1.add(deviceRecChild3);
        CCR_DeviceDiagnosticLocalization__c deviceRecChild4 = new CCR_DeviceDiagnosticLocalization__c(CCR_Active__c = true, CCR_Country__c = 'KR', CCR_Message__c='test', CCR_Language__c='ko', CCR_DeviceDiagnostic__c=divList[0].Id);
        divDigList1.add(deviceRecChild4);
        CCR_DeviceDiagnosticLocalization__c deviceRecChild5 = new CCR_DeviceDiagnosticLocalization__c(CCR_Active__c = false, CCR_Country__c = 'KR', CCR_Message__c='test draft2',
                CCR_Language__c='pl', CCR_DeviceDiagnostic__c=divList[0].Id, CCR_Status__c = 'Draft');
        divDigList1.add(deviceRecChild5);
        Test.startTest();
        try{
            insert divDigList1;
        }
        catch (Exception exp) {
            system.debug('Exception: '+exp.getStackTraceString());
        }
        List<CCR_DeviceDiagnosticLocalization__c> localRecs = [SELECT Id, CCR_Language__c, CCR_LocalisationUID__c
        FROM CCR_DeviceDiagnosticLocalization__c
        WHERE CCR_Language__c = 'ko' OR CCR_Language__c = 'pl'
        ORDER BY CCR_LocalisationUID__c];
//        System.assert(localRecs.size() == 2);
//        System.assert(!String.isEmpty(localRecs.get(0).CCR_LocalisationUID__c));
//        System.assert(!String.isEmpty(localRecs.get(1).CCR_LocalisationUID__c));

        localRecs.get(0).CCR_Language__c = 'en';
        try{
            update localRecs.get(0);
        }
        catch (Exception exp) {
            system.debug('Exception1: '+exp.getStackTraceString());
        }
        Test.stopTest();
        CCR_DeviceDiagnosticLocalization__c localRecResult = [SELECT CCR_Language__c
        FROM CCR_DeviceDiagnosticLocalization__c
        WHERE Id = :localRecs.get(0).Id LIMIT 1];
//        system.assert(localRecResult.CCR_Language__c != 'en');
    }

    /**
* Method Name :  testForDeletingOldLocalization
* Arguments: null
* Return : void
* Description: This method is used to test deleting old Localization records
**/
    @isTest static void testForDeletingOldLocalization() {
        List<CCR_DeviceDiagnostic__c> divList = [SELECT Id FROM CCR_DeviceDiagnostic__c
        WHERE Name = 'Other Issue'
        AND CCR_Active__c = true LIMIT 1];

        List<CCR_DeviceDiagnosticLocalization__c> devDiagLocalizationList = new List<CCR_DeviceDiagnosticLocalization__c> ();
        for(Integer i = 1; i <= 3; i++) {
            CCR_DeviceDiagnosticLocalization__c oldLocalizationRec = CCR_TestUtility.createDevDiagLocalization(divList[0].Id, false, 'pl', 'KR','Deployed');
            devDiagLocalizationList.add(oldLocalizationRec);
        }
        insert devDiagLocalizationList;

        Test.startTest();
        CCR_DeviceDiagnosticLocalization__c localizationRec = new CCR_DeviceDiagnosticLocalization__c(CCR_Active__c = true, CCR_Country__c = 'KR', CCR_Message__c='test new',
                CCR_Language__c='pl', CCR_DeviceDiagnostic__c=divList[0].Id, CCR_Status__c = 'Deployed');
        try {
            insert localizationRec;
        } catch(DmlException dmle) {
            System.debug('Error during insert DDL record: ' + dmle.getStackTraceString());
        }
        Test.stopTest();

        List<CCR_DeviceDiagnosticLocalization__c> localizationRecList = [SELECT Id
        FROM CCR_DeviceDiagnosticLocalization__c
        WHERE CCR_Language__c = 'pl' AND CCR_Active__c = false];
//        System.assert(localizationRecList.size() == 2);
    }

    /**
* Method Name :  testCDFormFields
* Arguments: null
* Return : void
* Description: This method is used to test Courier Delivery form fields logic
**/
    @isTest static void testCDFormFields() {
        user admuserKR = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        System.runAs(admuserKR) {
            list<contact> con = CCR_TestUtility.createContacts(1);
            Asset ast = [SELECT id, Status, CCR_CodentifyId__c, SerialNumber, Contactid,CCR_DeviceProductCode__r.CCR_ModelNumber__c FROM asset LIMIT 1];
            ast.ContactId = con[0].Id;
            update ast;
            CCR_QureHistory__c qureHis = [SELECT ID, CCR_Consumer__c,CCR_Status__c, CCR_DiagnosticDescription__c, CCR_QureReplacementChannel__c FROM CCR_QureHistory__c WHERE CCR_DiagnosticResult__c = 'HC1' LIMIT 1];
            qureHis.CCR_Consumer__c = con[0].id;
            qureHis.CCR_Status__c = 'Active';
            qureHis.CCR_QureReplacementChannel__c = '';
            qureHis.CCR_DiagnosticDescription__c = 'Bluetooth malfunction';
            update qureHis;
            Test.startTest();
            CCR_QureMsg qurmsg = new CCR_QureMsg();
            qurmsg.Codentify = ast.CCR_CodentifyId__c;
            qurmsg.QureHistryId = qureHis.Id;
            qurmsg.Market = 'KR';
            qurmsg.channelSelected = 'CourierDelivery';
            qurmsg.Salutation = 'Mr.';
            qurmsg.Address1 ='Address1';
            qurmsg.Address2 = 'Address2';
            qurmsg.Address3 ='Address3';
            qurmsg.Address4 = 'Address4';
            qurmsg.Address5 ='Address5';
            qurmsg.FirstName = 'First Name';
            qurmsg.LastName = 'Last Name';
            qurmsg.AddressCity = 'City';
            qurmsg.AddressPostalCode = '1234';
            qurmsg.Area = 'TestArea';
            qurmsg.District = 'TestDistrict';
            qurmsg.ConsumerPhone = '0123456789';
            qurmsg.IDType = 'IDType';
            qurmsg.IDNumber = 'IDNumber';
            qurmsg.TaxID = 'TaxID';
            qurmsg.formFieldsList = [SELECT CCR_FormField__c, CCR_Mandatory__c, CCR_Lenght__c, CCR_Regex__c, CCR_ReadOnly__c
            FROM CCR_QureConfiguration__c
            WHERE CCR_Country__c = :qurmsg.Market
            AND CCR_MarketEnabled__c = TRUE
            AND RecordTypeId = :COURIERDELIVERYRT
            ORDER BY CCR_DisplayOrder__c ASC];
//            system.assert(qurmsg.formFieldsList.size() > 0);
            CCR_QUREFaultTreeApex.placeOrderInDemandWare(JSON.serialize(qurmsg));
            CCR_QUREFaultTreeApex.runTest();
            Test.stopTest();
        }
    }
}