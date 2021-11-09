/**
 * Created by I2MAX on 2021-07-20.
 */

@istest(seeAllData=False)
public class CCR_CSVIsobarVoucherCodeApi_ts {
    @testsetup static void setTestdata(){
        user admuser = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        system.runAs(admuser) {
            List<contact> con =CCR_TestUtility.createContacts(1);
            CCR_QureHistory__c qureHistObj = new CCR_QureHistory__c();
            List<CCR_Material__c> mats= CCR_TestUtility.createMaterials(1,'D0201','2.2','JP04');
            Asset ast = CCR_TestUtility.createassets(mats[0].id,con[0].id, CCR_Constants.ASSETACTIVE,'xyz353','54545454545','cdf678');
            User callCenterUserKorea = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            ast.OwnerId = callCenterUserKorea.Id;
            Update ast;
            List<Case> caseList = new List<Case>();
            caseList = CCR_TestUtility.createCases(1,con[0].Id);
            if(!caseList.isEmpty()) {
                qureHistObj.CCR_Case__c = caseList[0].Id;
                qureHistObj.CCR_Device__c = ast.Id;
                database.insert(qureHistObj);
            }
            CCR_ISOBARGetVoucherApiDetails__c vc = new CCR_ISOBARGetVoucherApiDetails__c();
            vc.Name = 'test';
            vc.CCR_ApiKey__c = 'test';
            vc.CCR_AuthenticationEndpoint__c = 'test';
            vc.CCR_GetVoucherEndpoint__c = 'test';
            vc.CCR_ResendVoucherEndpoint__c = 'test';
            vc.CCR_ApiSecret__c = 'test';
            vc.CCR_PrivateKey__c = 'XT3LEBuUuE81Z0qW';
            vc.CCR_SaltKey__c = 'Ame7kBGjV7mDoQUw';
            vc.CCR_Country__c = 'kr';
            vc.CCR_Active__c = true;
            insert vc;
            IF_INFO__c info = new IF_INFO__c();
            info.IF_ID__c = 'IF_DCE_DN_0001';
            info.URL__c = 'test';
            info.CYCLE__c = 'realtime';
            info.FROM__c = 'test';
            info.TO__c = 'test';
            info.TITLE__c = 'test';
            info.FORCE_LOGGING__c = false;
            info.TargetAccessToken__c = 'test';
            insert info;
            IfStaticValue__c sv = new IfStaticValue__c();
            sv.Name = 'Danal';
            insert sv;
            CCR_TestUtility.createCallCntAgentForCountry('France');
        }
    }
    /**
* Method Name :  testGetVoucherPositive
* Arguments: None
* Return : None
* Description: This Method tests get voucher
**/
    @istest static void testGetVoucherPositive () {

        List<Case> caseList = new List<Case>();
        caseList = [SELECT Id FROM Case LIMIT 1];
        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            if(!caseList.isEmpty()) {
                qureMsgObj.CaseId = caseList[0].Id;
            }
            qureMsgObj.Market = 'KR';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
//            Cache.Org.put('local.CCRTokens.CCRIsobarAccessToken', 'test' , 300);
            CCR_GenerateGetVourcherMock getVoucherMock = new CCR_GenerateGetVourcherMock();
            test.setMock(HttpCalloutMock.class, getVoucherMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.getVoucher(qureMsgObj);
            CCR_CSVIsobarVoucherCodeApi.runTest();
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testGetVoucherNegative
* Arguments: None
* Return : None
* Description: This Method tests get voucher negative scenarios
**/
    @istest static void testGetVoucherNegative () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'KR';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
//            Cache.Org.put('local.CCRTokens.CCRIsobarAccessToken', 'test' , 300);
            CCR_GenerateVoucherMockError getVoucherMock = new CCR_GenerateVoucherMockError();
            test.setMock(HttpCalloutMock.class, getVoucherMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.getVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testGetvoucherFeatureActivationNegative
* Arguments: None
* Return : None
* Description: This Method tests get voucher feature activation scenario
**/
    @istest static void testGetvoucherFeatureActivationNegative () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'IT';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
//            Cache.Org.put('local.CCRTokens.CCRIsobarAccessToken', 'test' , 300);
            CCR_GenerateGetVourcherMock getVoucherMock = new CCR_GenerateGetVourcherMock();
            test.setMock(HttpCalloutMock.class, getVoucherMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.getVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testGenerateAccessTokenPositive
* Arguments: None
* Return : None
* Description: This Method tests generate access token
**/
    @istest static void testGenerateAccessTokenPositive () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'KR';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
            CCR_GenerateTokenMock getTokenMock = new CCR_GenerateTokenMock();
            test.setMock(HttpCalloutMock.class, getTokenMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.getVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testGenerateAccessTokenNegative
* Arguments: None
* Return : None
* Description: This Method tests testReplacementOrder negative scenario
**/
    @istest static void testGenerateAccessTokenNegative () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Case cs = new Case();
        insert cs;
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = cs.Id;
            qureMsgObj.Market = 'KR';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
            CCR_GenerateTokenMockError getTokenMock = new CCR_GenerateTokenMockError();
            test.setMock(HttpCalloutMock.class, getTokenMock);
//            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.getVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testResendVoucherPositive
* Arguments: None
* Return : None
* Description: This Method tests resend voucher
**/
    @istest static void testResendVoucherPositive () {

        List<CCR_QureHistory__c> qureHistList = new List<CCR_QureHistory__c>();
        qureHistList = [SELECT Id, CCR_Case__r.CCR_OrderId__c FROM CCR_QureHistory__c LIMIT 1];
        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            if(!qureHistList.isEmpty()) {
                qureMsgObj.QureHistryId = qureHistList[0].Id;
            }
            qureMsgObj.Market = 'KR';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
//            Cache.Org.put('local.CCRTokens.CCRIsobarAccessToken', 'test' , 300);
            CCR_ResendVourcherMock resendVoucherMock = new CCR_ResendVourcherMock();
            test.setMock(HttpCalloutMock.class, resendVoucherMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.resendVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testResendVoucherInvalidQureHist
* Arguments: None
* Return : None
* Description: This Method tests resend voucher
**/
    @istest static void testResendVoucherInvalidQureHist () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'KR';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
//            Cache.Org.put('local.CCRTokens.CCRIsobarAccessToken', 'test' , 300);
            CCR_ResendVourcherMock resendVoucherMock = new CCR_ResendVourcherMock();
            test.setMock(HttpCalloutMock.class, resendVoucherMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.resendVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name : testResendVoucherNegative
* Arguments: None
* Return : None
* Description: This Method tests resend voucher negative scenario
**/
    @istest static void testResendVoucherNegative () {

        List<CCR_QureHistory__c> qureHistList = new List<CCR_QureHistory__c>();
        qureHistList = [SELECT Id, CCR_Case__r.CCR_OrderId__c FROM CCR_QureHistory__c LIMIT 1];
        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            if(!qureHistList.isEmpty()) {
                qureMsgObj.QureHistryId = qureHistList[0].Id;
            }
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'KR';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
//            Cache.Org.put('local.CCRTokens.CCRIsobarAccessToken', 'test' , 300);
            CCR_ResendGetVourcherMockError resendVoucherMock = new CCR_ResendGetVourcherMockError();
            test.setMock(HttpCalloutMock.class, resendVoucherMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.resendVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testResendvoucherFeatureActivation
* Arguments: None
* Return : None
* Description: This Method tests resend voucher feature activation scenario
**/
    @istest static void testResendvoucherFeatureActivation () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account ass = new Account(Name='testAccount');
        insert ass;
        List<Contact> ctList = [select id from Contact];
        Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'IT';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.ConsumerPhone = '01072442438';
            test.startTest();
//            Cache.Org.put('local.CCRTokens.CCRIsobarAccessToken', 'test' , 300);
            CCR_ResendVourcherMock resendVoucherMock = new CCR_ResendVourcherMock();
            test.setMock(HttpCalloutMock.class, resendVoucherMock);
            qureMsgObj = CCR_CSVIsobarVoucherCodeApi.resendVoucher(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* @Class Name        CCR_GenerateTokenMock
* @version           1.0
* @date              23/07/2018
* @description       This class mocks the response from ISOBAR Webservice whenever a callout(s) is made from test class
*/
    public class CCR_GenerateTokenMock implements HttpCalloutMock {
        /**
* Method Name :  respond
* Arguments: Request and responseparameters
* Return : None
* Description: This Method mocks the AIT webservice to throw response when ISOBAR webservice callout is made from Test class.
**/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"expiredAt":"2018-07-23 10:58:54","resCode":"00","accessToken":"MjM5NEI4NjE2OEQ5Q0Y2QTAzNDUxRTIwQjk1RUFGNTExNTMyMzM2MzM0ODg2","resMsg":"Success","now":"2018-07-23 10:28:54"}');
            res.setStatusCode(200);
            return res;
        }
    }
    /**
* @Class Name        CCR_GenerateTokenMockError
* @version           1.0
* @date              23/07/2018
* @description       This class mocks the response from ISOBAR Webservice whenever a callout(s) is made from test class
*/
    public class CCR_GenerateTokenMockError implements HttpCalloutMock {
        /**
* Method Name :  respond
* Arguments: Request and responseparameters
* Return : None
* Description: This Method mocks the ISOBAR webservice to throw response when ISOBAR webservice callout is made from Test class.
**/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "access_token": "NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2FyYm9uLnN1cGVy", "scope": "am_application_scope,openid openid","id_token": "eyJ4NXQiOiJZVEV4TlRWa1pqVXhOREprTnpGbVlXWmxOakF5T0RFeVpqSTNZelV6TW1SallUTTVNREkyT0EiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoic2ZfVW05ckFobHFvZmQwN05iYVFndyIsImF1ZCI6WyJwZ2h6bmxMeHQ2NXc2OHp4Q3pfeHZ0TENIdlVhIl0sImF6cCI6InBnaHpubEx4dDY1dzY4enhDel94dnRMQ0h2VWEiLCJhdXRoX3RpbWUiOjE1MTU1MDY4MDcsImlzcyI6Imh0dHBzOlwvXC9hcGltLWlkZW50aXR5LnFhLXBtaWRjZS5jb20iLCJleHAiOjE1MTU1MTA2MzAsImlhdCI6MTUxNTUwNzAzMH0.kmYjPunr49l9NPvyL-ynLe0JQLL2xdlyuKflExSoVFy889GHpsjFncuBnhxDkBgvlNY4_XKllQ-jEaXrLVEaYGQekkrkIQ4jiogiwvmO7d2P3JLGZECggMVQ7uOhsNW4kfSaYTeK9P3xHp7eUu-Gx0zVxeO28zWnKlqIcXWqOviEPYQsPe5HsBs7Z3XP-KKneTMeaaW82Yr0VFVDYSmqCE3ZB82JPXs73Dn05plv792N_D01SMJR4MCNO-BRq_e7IZzAx63x8lO1H7UdVxLPZs8UHRtP-8cpXvxYYk85IvKatkb0akazFJlRhj46zQ_Ya35e5QXYKcZ5l205KlYWWg","token_type": "Bearer","expires_in": 3076}');
            res.setStatusCode(402);
            return res;
        }
    }
    /**
* @Class Name        CCR_GenerateGetVourcherMock
* @version           1.0
* @date              23/07/2018
* @description       This class mocks the response from ISOBAR Webservice whenever a callout(s) is made from test class
*/
    public class CCR_GenerateGetVourcherMock implements HttpCalloutMock {
        /**
* Method Name :  respond
* Arguments: Request and responseparameters
* Return : None
* Description: This Method mocks the ISOBAR webservice to throw response when ISOBAR webservice callout is made from Test class.
**/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"resCode":"00","voucherIdx":"1448","resMsg":"Success","caseNo":"01916922"}');
            res.setStatusCode(200);
            return res;
        }
    }
    /**
* @Class Name        CCR_GenerateVoucherMockError
* @version           1.0
* @date              23/07/2018
* @description       This class mocks the response from Demandware for order creation whenever a callout(s) is made from test class
*/
    public class CCR_GenerateVoucherMockError implements HttpCalloutMock {
        /**
* Method Name :  respond
* Arguments: Request and responseparameters
* Return : None
* Description: This Method mocks the ISOBAR webservice to throw response when ISOBAR webservice callout is made from Test class.
**/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"resCode":"06","voucherIdx":"0","resMsg":"Duplicated Case No.","caseNo":"01916922"}');
            res.setStatusCode(200);
            return res;
        }
    }
    /**
* @Class Name        CCR_ResendVourcherMock
* @version           1.0
* @date              23/07/2018
* @description       This class mocks the response from ISOBAR Webservice whenever a callout(s) is made from test class
*/
    public class CCR_ResendVourcherMock implements HttpCalloutMock {
        /**
* Method Name :  respond
* Arguments: Request and responseparameters
* Return : None
* Description: This Method mocks the AIT webservice to throw response when AIT webservice callout is made from Test class.
**/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"resCode":"00","resMsg":"Success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    /**
* @Class Name        CCR_ResendGetVourcherMockError
* @version           1.0
* @date              23/07/2018
* @description       This class mocks the response from ISOBAR Webservice whenever a callout(s) is made from test class
*/
    public class CCR_ResendGetVourcherMockError implements HttpCalloutMock {
        /**
* Method Name :  respond
* Arguments: Request and responseparameters
* Return : None
* Description: This Method mocks the AIT webservice to throw response when AIT webservice callout is made from Test class.
**/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"resCode":"06","resMsg":"Duplicated Case No."}');
            res.setStatusCode(200);
            return res;
        }
    }
}