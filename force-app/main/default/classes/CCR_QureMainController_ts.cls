/**
 * Created by I2MAX on 2021-07-14.
 */

@istest(seeAllData = false)
public class CCR_QureMainController_ts {
    /**
    * Method Name :  testdata
    * Arguments: null
    * Return : void
    * Description: This method is used to create test data
    **/
    @testSetup static void testdata() {
        User admuserKR = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        System.runAs(admuserKR) {
            List<CCR_Material__c> mats= CCR_TestUtility.createMaterials(1,'D0201','2.2','JP04');
            List<Contact> con = CCR_TestUtility.createContacts(1);
            user usr = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            update usr;

            con[0].OwnerId = usr.Id;
            TriggerHandler.bypass('DTE_ContactTriggerHandler');
            TriggerHandler.bypass('CAA_ContactTriggerHandler');
            update con;

            Asset ast = CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETPRODUCED, 'TESTCODENTIFY', 'TESTPARENTCODENTIFY', 'TESTINTERNALID');
            ast.Status = 'Active';
            ast.ContactId = con[0].Id;
            ast.OwnerId = usr.id;
            TriggerHandler.bypass('CCR_AssetTriggerHandler');
            update ast;

            CCR_QureHistory__c qureHis = new CCR_QureHistory__c();
            qureHis.CCR_Status__c = 'Active';
            qureHis.CCR_Device__c = ast.Id;
            qureHis.CCR_QureChannel__c = 'E-Commerce';
            qureHis.CCR_DiagnosticResult__c = 'HB1' ;
            qureHis.CCR_DiagnosticDescription__c = 'Blinking Red Light';
            insert qureHis;

            System.debug(qureHis);

            Id endMessageType, otherMessageType;
            for(RecordType rec : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'CCR_DeviceDiagnostic__c' AND DeveloperName IN ('CCR_EndMessage', 'CCR_OtherMessage')]){
                if(rec.DeveloperName == 'CCR_EndMessage') endMessageType = rec.Id;
                else otherMessageType = rec.Id;
            }

            CCR_DeviceDiagnostic__c endMessage = new CCR_DeviceDiagnostic__c();
            endMessage.RecordTypeId = endMessageType;
            endMessage.Name = 'Test End Message';
            endMessage.CCR_MessageName__c = 'Thanks For Phone';
            endMessage.CCR_EndMessageType__c = 'Standard Message';
            endMessage.CCR_Active__c = true;
            endMessage.CCR_DefaultMessage__c = 'test message';

            CCR_DeviceDiagnostic__c endMessage2 = new CCR_DeviceDiagnostic__c();
            endMessage2.RecordTypeId = endMessageType;
            endMessage2.Name = 'Test End Message';
            endMessage2.CCR_MessageName__c = 'UnReplaceable EndMessage';
            endMessage2.CCR_EndMessageType__c = 'Standard Message';
            endMessage2.CCR_Active__c = true;
            endMessage2.CCR_DefaultMessage__c = 'test message';

            CCR_DeviceDiagnostic__c otherMessage = new CCR_DeviceDiagnostic__c();
            otherMessage.RecordTypeId = otherMessageType;
            otherMessage.Name = 'Test Other Message';
            otherMessage.CCR_MessageName__c = 'Generic Error';
            otherMessage.CCR_Active__c = true;
            otherMessage.CCR_DefaultMessage__c = 'test message';

            List<CCR_DeviceDiagnostic__c> diagnosticsToInsert = new List<CCR_DeviceDiagnostic__c>();
            diagnosticsToInsert.add(endMessage);
            diagnosticsToInsert.add(otherMessage);
            diagnosticsToInsert.add(endMessage2);
            insert diagnosticsToInsert;

            CCR_DeviceDiagnosticLocalization__c endMessageLocalization = new CCR_DeviceDiagnosticLocalization__c();
            endMessageLocalization.CCR_Active__c = true;
            endMessageLocalization.CCR_Country__c = 'KR';
            endMessageLocalization.CCR_DeviceDiagnostic__c = endMessage.Id;
            endMessageLocalization.CCR_Language__c = 'ko';
            endMessageLocalization.CCR_Message__c = 'test message';

            CCR_DeviceDiagnosticLocalization__c otherMessageLocalization = new CCR_DeviceDiagnosticLocalization__c();
            otherMessageLocalization.CCR_Active__c = true;
            otherMessageLocalization.CCR_Country__c = 'KR';
            otherMessageLocalization.CCR_DeviceDiagnostic__c = otherMessage.Id;
            otherMessageLocalization.CCR_Language__c = 'ko';
            otherMessageLocalization.CCR_Message__c = 'test message';

            CCR_DeviceDiagnosticLocalization__c otherMessageLocalization2 = new CCR_DeviceDiagnosticLocalization__c();
            otherMessageLocalization2.CCR_Active__c = true;
            otherMessageLocalization2.CCR_Country__c = 'KR';
            otherMessageLocalization2.CCR_DeviceDiagnostic__c = endMessage2.Id;
            otherMessageLocalization2.CCR_Language__c = 'ko';
            otherMessageLocalization2.CCR_Message__c = 'test message';

            List<CCR_DeviceDiagnosticLocalization__c> localizationsToInsert = new List<CCR_DeviceDiagnosticLocalization__c>();
            localizationsToInsert.add(endMessageLocalization);
            localizationsToInsert.add(otherMessageLocalization);
            localizationsToInsert.add(otherMessageLocalization2);
            insert localizationsToInsert;

        }
    }

    /**
    * Method Name :  positivePreEligibility
    * Arguments: null
    * Return : void
    * Description: This method is used to test the QURE Main functionality
    **/
    static testMethod void positivePreEligibility() {
        user usr = [SELECT Id, Name, Profile.Name FROM User WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(usr) {
            CCR_QureMsg qMsg = new CCR_QureMsg();
            qMsg.Codentify = 'TESTCODENTIFY';
            qMsg.IsLimitedEdition = false;
            qMsg.Language = 'EN';
            qMsg.Market = 'KR';
            String qMsgString = Json.serialize(qMsg);
            CCR_QureMainController.returnWrapper retWrap = CCR_QureMainController.callPreEligibility(qMsgString);

        }
    }

    /**
* Method Name :  negativePreEligibility
* Arguments: null
* Return : void
* Description: This method is used to test the QURE Main functionality
**/
    static testMethod void negativePreEligibility() {
        user usr = [SELECT Id, Name, Profile.Name FROM User WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(usr) {
            CCR_QureMainController.returnWrapper retWrap = CCR_QureMainController.callPreEligibility('Exception');
        }
    }

    /**
* Method Name :  positiveEligibility
* Arguments: null
* Return : void
* Description: This method is used to test the QURE Main functionality
**/
    static testMethod void testEligibility() {
        CCR_QureMsg qMsg = new CCR_QureMsg();
        qMsg.Codentify = 'TESTCODENTIFY';
        qMsg.IsLimitedEdition = false;
        qMsg.Language = 'EN';
        qMsg.Market = 'KR';
        qMsg.ResultCode = 'HB1';
        qMsg.UserType = 'Call Center Agent';
        qMsg.ErrorMsgId = 'Thanks For Phone';
        String qMsgString = Json.serialize(qMsg);
        CCR_QureMainController.returnWrapper retWrap = CCR_QureMainController.callEligibility(qMsgString);

        qMsg.ErrorMsgId = null;
        qMsg.Results = CCR_QureMsg.ESCALATETOCSC;
        qMsgString = Json.serialize(qMsg);
        retWrap = CCR_QureMainController.callEligibility(qMsgString);


        retWrap = CCR_QureMainController.callEligibility('Exception');
    }

    /**
* Method Name :  getMessage
* Arguments: null
* Return : void
* Description: This method is used to test the QURE Main functionality
**/
    static testMethod void getMessage() {
        CCR_QureMsg qMsg = new CCR_QureMsg();
        qMsg.Codentify = 'TESTCODENTIFY';
        qMsg.IsLimitedEdition = false;
        qMsg.Language = 'EN';
        qMsg.Market = 'KR';
        qMsg.ErrorMsgId = 'Thanks For Phone';
        String qMsgString = Json.serialize(qMsg);
        String message = CCR_QureMainController.getStandardEndMessage(qMsgString);

    }

    /**
* Method Name :  positiveEscalation
* Arguments: null
* Return : void
* Description: This method is used to test the QURE Main functionality
**/
    static testMethod void positiveEscalation() {
        user usr = [SELECT Id, Name, Profile.Name FROM User WHERE CCR_UserType__c = 'Call Center Agent' ORDER BY CreatedDate DESC LIMIT 1];
        System.runAs(usr) {
            CCR_QureMsg qMsg = new CCR_QureMsg();
            qMsg.Codentify = 'TESTCODENTIFY';
            qMsg.IsLimitedEdition = false;
            qMsg.Language = 'EN';
            qMsg.Market = 'KR';
            qMsg.ResultCode = 'HB1';
            qMsg.UserType = 'Call Center Agent';

            List<CCR_Material__c> mats= [select id from CCR_Material__c];
            List<Contact> con = CCR_TestUtility.createContacts(1);

            Asset ast = CCR_TestUtility.createassets(mats[0].id, null, CCR_Constants.ASSETPRODUCED, 'TESTCODENTIFY2', 'TESTPARENTCODENTIFY2', 'TESTINTERNALID2');
            ast.Status = 'Active';
            ast.ContactId = con[0].Id;
            ast.OwnerId = usr.id;
            TriggerHandler.bypass('CCR_AssetTriggerHandler');
            update ast;

            CCR_QureHistory__c qureHis = new CCR_QureHistory__c();
            qureHis.CCR_Status__c = 'Active';
            qureHis.CCR_Device__c = ast.Id;
            qureHis.CCR_QureChannel__c = 'E-Commerce';
            qureHis.CCR_DiagnosticResult__c = 'HB1' ;
            qureHis.CCR_DiagnosticDescription__c = 'Blinking Red Light';
            insert qureHis;

//            qMsg.QureHistryId = [SELECT Id FROM CCR_QureHistory__c LIMIT 1].Id;
            qMsg.QureHistryId = qureHis.Id;
            qMsg.MaterialGroup = CCR_Constants.HOLDER;
            String qMsgString = Json.serialize(qMsg);
            CCR_QureMainController.returnWrapper retWrap = CCR_QureMainController.escalateToCSC('0123456789', null, qMsgString);

        }
    }

}