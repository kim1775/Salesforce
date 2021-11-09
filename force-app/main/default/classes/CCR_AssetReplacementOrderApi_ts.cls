/**
 * Created by I2MAX on 2021-07-19.
 */

@IsTest(seeAllData=False)
public class CCR_AssetReplacementOrderApi_ts {
//public without sharing class CCR_AssetReplacementOrderApiTest {
    @testsetup static void setTestdata(){
        user admuser = CCR_TestUtility.createAdminUserforCountry('Korea, Republic of','KR');
        system.runAs(admuser) {
            Account acc = CCR_TestUtility.getAcc();
            List<contact> con =CCR_TestUtility.createContacts(1);
            List<CCR_Material__c> mats= CCR_TestUtility.createMaterials(1,'D0201','2.2','JP04');
            Asset ast = CCR_TestUtility.createassets(mats[0].id,con[0].id, CCR_Constants.ASSETACTIVE,'xyz353','54545454545','cdf678');
            User callCenterUserKorea = CCR_TestUtility.createCallCntAgentForCountry('Korea, Republic of');
            ast.OwnerId = callCenterUserKorea.Id;
            Update ast;
        }
    }

    /**
* Method Name :  testReplacementOrderPositive
* Arguments: None
* Return : None
* Description: This Method tests testReplacementOrder
**/
    @istest static void testReplacementOrderPositive () {

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
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = false;
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            Test.startTest();
            HttpMockFactory mockData = new HttpMockFactory(200, 'SUCCESS', '{ "access_token": "NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2FyYm9uLnN1cGVy", "scope": "am_application_scope,openid openid","id_token": "eyJ4NXQiOiJZVEV4TlRWa1pqVXhOREprTnpGbVlXWmxOakF5T0RFeVpqSTNZelV6TW1SallUTTVNREkyT0EiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoic2ZfVW05ckFobHFvZmQwN05iYVFndyIsImF1ZCI6WyJwZ2h6bmxMeHQ2NXc2OHp4Q3pfeHZ0TENIdlVhIl0sImF6cCI6InBnaHpubEx4dDY1dzY4enhDel94dnRMQ0h2VWEiLCJhdXRoX3RpbWUiOjE1MTU1MDY4MDcsImlzcyI6Imh0dHBzOlwvXC9hcGltLWlkZW50aXR5LnFhLXBtaWRjZS5jb20iLCJleHAiOjE1MTU1MTA2MzAsImlhdCI6MTUxNTUwNzAzMH0.kmYjPunr49l9NPvyL-ynLe0JQLL2xdlyuKflExSoVFy889GHpsjFncuBnhxDkBgvlNY4_XKllQ-jEaXrLVEaYGQekkrkIQ4jiogiwvmO7d2P3JLGZECggMVQ7uOhsNW4kfSaYTeK9P3xHp7eUu-Gx0zVxeO28zWnKlqIcXWqOviEPYQsPe5HsBs7Z3XP-KKneTMeaaW82Yr0VFVDYSmqCE3ZB82JPXs73Dn05plv792N_D01SMJR4MCNO-BRq_e7IZzAx63x8lO1H7UdVxLPZs8UHRtP-8cpXvxYYk85IvKatkb0akazFJlRhj46zQ_Ya35e5QXYKcZ5l205KlYWWg","token_type": "Bearer","expires_in": 3076}');
            Test.setMock(HttpCalloutMock.class, mockData);
            DateTime trasactionStartTime = system.now();
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            DateTime trasactionEndTime = system.now();
            CCR_AssetReplacementOrderApi.pushTelemetryEvent(trasactionStartTime, trasactionEndTime, ast.CCR_CodentifyId__c);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testGetProductId
* Arguments: None
* Return : None
* Description: This Method tests retrival of product id
**/
    @istest static void testGetProductId () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        system.runas(koreaCallCenterUser) {
            Account ass = new Account(Name='testAccount');
            insert ass;
            List<Contact> ctList = [select id from Contact];
            Asset ast = new Asset(Name='testAsset', ContactId=ctList[0].Id, AccountId=ass.Id);
            insert ast;
//            List<Asset> assetList = [SELECT ID, CCR_CodentifyId__c, CCR_DeviceProductCode__r.CCR_Version__c FROM Asset LIMIT 1];
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = false;
//            Cache.Org.put(CCR_AssetReplacementOrderApi.DWACCESSTOKENVALUE, 'NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2Fy' , 320);
            test.startTest();
            HttpMockFactory mockData = new HttpMockFactory(200, 'SUCCESS', '{"_v":"18.3","_type":"product_search_result","count":11,"hits":[{"_type":"product","_resource_state":"89f3276304e0de244a9f23533e0d3b46bf6a69ee1051cdf42720740cce3beaad","id":"DA000219.00-RPL","in_stock":true,"image":{"_type":"media_file","abs_url":"https://dev21-eu-pmi.demandware.net/on/demandware.static/-/Sites-KR_Master_Catalog/default_Desciption/vada3ac68207eaa75f6d50dc688bbb99cee6aa395/images/large/lo-res/IQOS_BLUE_HOLDER.png"},"name":{"default_Desciption":"IQOS Holder","ko-KR":"???? ?? ??","translated_Desciption":"IQOS Holder"},"c_color":"Blue","c_deviceVersion":"2.4","c_masterProductID":"A1403","c_smdlColor":"BLU"}]}');
            test.setMock(HttpCalloutMock.class, mockData);
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            HttpMockFactory mockData1 = new HttpMockFactory(401, 'SUCCESS', 'test');
            test.setMock(HttpCalloutMock.class, mockData1);
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testGetProductIdAuthError
* Arguments: None
* Return : None
* Description: This Method tests retrival of product id
**/
    @istest static void testGetProductIdAuthError () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact ct = new Contact(LastName='TestContact');
        insert ct;
        Asset ast = new Asset(Name='TestAsset',AccountId=acc.Id,ContactId=ct.Id,CCR_CodentifyId__c='testCodentify');
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = false;
//            Cache.Org.put(CCR_AssetReplacementOrderApi.DWACCESSTOKENVALUE, 'NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2Fy' , 320);
            Test.startTest();
            HttpMockFactory mockData1 = new HttpMockFactory(401, 'SUCCESS', 'test');
            Test.setMock(HttpCalloutMock.class, mockData1);
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            Test.stopTest();
        }
    }
    /**
* Method Name :  testGetProductIdError
* Arguments: None
* Return : None
* Description: This Method tests retrival of product id
**/
    @istest static void testGetProductIdError () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact ct = new Contact(LastName='TestContact');
        insert ct;
        Asset ast = new Asset(Name='TestAsset',AccountId=acc.Id,ContactId=ct.Id,CCR_CodentifyId__c='testCodentify');
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = false;
//            Cache.Org.put(CCR_AssetReplacementOrderApi.DWACCESSTOKENVALUE, 'NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2Fy' , 320);
            test.startTest();
            HttpMockFactory mockData2 = new HttpMockFactory(404, 'SUCCESS', 'test');
            test.setMock(HttpCalloutMock.class, mockData2);
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
* Method Name :  testReplacementOrderNegative
* Arguments: None
* Return : None
* Description: This Method tests testReplacementOrder
**/
    @istest static void testReplacementOrderNegative () {

        User franceCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact ct = new Contact(LastName='TestContact');
        insert ct;
        Asset ast = new Asset(Name='TestAsset',AccountId=acc.Id,ContactId=ct.Id,CCR_CodentifyId__c='testCodentify');
        insert ast;
//        CCR_AssetReplacementOrderApi.assetList.add(ast);
        system.runas(franceCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = 'test';
            qureMsgObj.CaseId = 'test';
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = true;
            test.startTest();
            HttpMockFactory mockData = new HttpMockFactory(200, 'SUCCESS', '{ "access_token": "NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2FyYm9uLnN1cGVy", "scope": "am_application_scope,openid openid","id_token": "eyJ4NXQiOiJZVEV4TlRWa1pqVXhOREprTnpGbVlXWmxOakF5T0RFeVpqSTNZelV6TW1SallUTTVNREkyT0EiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoic2ZfVW05ckFobHFvZmQwN05iYVFndyIsImF1ZCI6WyJwZ2h6bmxMeHQ2NXc2OHp4Q3pfeHZ0TENIdlVhIl0sImF6cCI6InBnaHpubEx4dDY1dzY4enhDel94dnRMQ0h2VWEiLCJhdXRoX3RpbWUiOjE1MTU1MDY4MDcsImlzcyI6Imh0dHBzOlwvXC9hcGltLWlkZW50aXR5LnFhLXBtaWRjZS5jb20iLCJleHAiOjE1MTU1MTA2MzAsImlhdCI6MTUxNTUwNzAzMH0.kmYjPunr49l9NPvyL-ynLe0JQLL2xdlyuKflExSoVFy889GHpsjFncuBnhxDkBgvlNY4_XKllQ-jEaXrLVEaYGQekkrkIQ4jiogiwvmO7d2P3JLGZECggMVQ7uOhsNW4kfSaYTeK9P3xHp7eUu-Gx0zVxeO28zWnKlqIcXWqOviEPYQsPe5HsBs7Z3XP-KKneTMeaaW82Yr0VFVDYSmqCE3ZB82JPXs73Dn05plv792N_D01SMJR4MCNO-BRq_e7IZzAx63x8lO1H7UdVxLPZs8UHRtP-8cpXvxYYk85IvKatkb0akazFJlRhj46zQ_Ya35e5QXYKcZ5l205KlYWWg","token_type": "Bearer","expires_in": 3076}');
            Test.setMock(HttpCalloutMock.class, mockData);
            CCR_AssetReplacementOrderApi.singleProdReq = true;
//            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
            HttpMockFactory mockData1 = new HttpMockFactory(401, 'BADREQUEST', '{ "access_token": "NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2FyYm9uLnN1cGVy", "scope": "am_application_scope,openid openid","id_token": "eyJ4NXQiOiJZVEV4TlRWa1pqVXhOREprTnpGbVlXWmxOakF5T0RFeVpqSTNZelV6TW1SallUTTVNREkyT0EiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoic2ZfVW05ckFobHFvZmQwN05iYVFndyIsImF1ZCI6WyJwZ2h6bmxMeHQ2NXc2OHp4Q3pfeHZ0TENIdlVhIl0sImF6cCI6InBnaHpubEx4dDY1dzY4enhDel94dnRMQ0h2VWEiLCJhdXRoX3RpbWUiOjE1MTU1MDY4MDcsImlzcyI6Imh0dHBzOlwvXC9hcGltLWlkZW50aXR5LnFhLXBtaWRjZS5jb20iLCJleHAiOjE1MTU1MTA2MzAsImlhdCI6MTUxNTUwNzAzMH0.kmYjPunr49l9NPvyL-ynLe0JQLL2xdlyuKflExSoVFy889GHpsjFncuBnhxDkBgvlNY4_XKllQ-jEaXrLVEaYGQekkrkIQ4jiogiwvmO7d2P3JLGZECggMVQ7uOhsNW4kfSaYTeK9P3xHp7eUu-Gx0zVxeO28zWnKlqIcXWqOviEPYQsPe5HsBs7Z3XP-KKneTMeaaW82Yr0VFVDYSmqCE3ZB82JPXs73Dn05plv792N_D01SMJR4MCNO-BRq_e7IZzAx63x8lO1H7UdVxLPZs8UHRtP-8cpXvxYYk85IvKatkb0akazFJlRhj46zQ_Ya35e5QXYKcZ5l205KlYWWg","token_type": "Bearer","expires_in": 3076}');
            Test.setMock(HttpCalloutMock.class, mockData1);
//            CCR_AssetReplacementOrderApi.getOrgAccessToken('www.test123123.com');
        }
    }
    /**
    * Method Name :  testReplacementOrderPositive
    * Arguments: None
    * Return : None
    * Description: This Method tests testReplacementOrder
    **/
    @istest static void testReplacementOrderTelemetry () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact ct = new Contact(LastName='TestContact');
        insert ct;
        Asset ast = new Asset(Name='TestAsset',AccountId=acc.Id,ContactId=ct.Id,CCR_CodentifyId__c='testCodentify');
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = false;
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.productId = '2';
//            Cache.Org.put('local.CCRTokens.CCRDWAccessToken', 'NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2FyYm9uLnN1cGVy', 3076);
            test.startTest();
            HttpMockFactory mockData = new HttpMockFactory(200, 'SUCCESS', '{"_v":"18.3","_type":"product_search_result","count":11,"hits":[{"_type":"product","_resource_state":"89f3276304e0de244a9f23533e0d3b46bf6a69ee1051cdf42720740cce3beaad","id":"DA000219.00-RPL","in_stock":true,"image":{"_type":"media_file","abs_url":"https://dev21-eu-pmi.demandware.net/on/demandware.static/-/Sites-KR_Master_Catalog/default_Desciption/vada3ac68207eaa75f6d50dc688bbb99cee6aa395/images/large/lo-res/IQOS_BLUE_HOLDER.png"},"name":{"default_Desciption":"IQOS Holder","ko-KR":"???? ?? ??","translated_Desciption":"IQOS Holder"},"c_color":"Blue","c_deviceVersion":"2.4","c_masterProductID":"A1403","c_smdlColor":"BLU"}]}');
            test.setMock(HttpCalloutMock.class, mockData);
            DateTime trasactionStartTime = system.now();
            CCR_AssetReplacementOrderApi.authenticateStartTime = system.now().addMinutes(1);
            CCR_AssetReplacementOrderApi.authenticateEndTime = system.now().addMinutes(2);
            CCR_AssetReplacementOrderApi.getProdIDStartTime = system.now().addMinutes(3);
            CCR_AssetReplacementOrderApi.getProdIDEndTime = system.now().addMinutes(4);
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            DateTime trasactionEndTime = system.now();
            CCR_AssetReplacementOrderApi.pushTelemetryEvent(trasactionStartTime, trasactionEndTime, ast.CCR_CodentifyId__c);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
            HttpMockFactory mockData1 = new HttpMockFactory(401, 'BADREQUEST', 'test');
            test.setMock(HttpCalloutMock.class, mockData1);
            qureMsgObj = CCR_AssetReplacementOrderApi.replaceAsset(qureMsgObj);
        }
    }
    /**
    * Method Name :  testGetProductIdAuthErrorTest
    * Arguments: None
    * Return : None
    * Description: This Method tests auth error
    **/
    @istest static void testGetProductIdAuthErrorTest () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact ct = new Contact(LastName='TestContact');
        insert ct;
        Asset ast = new Asset(Name='TestAsset',AccountId=acc.Id,ContactId=ct.Id,CCR_CodentifyId__c='testCodentify');
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = false;
//            Cache.Org.put(CCR_AssetReplacementOrderApi.DWACCESSTOKENVALUE, 'NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2Fy' , 320);
            test.startTest();
            HttpMockFactory mockData1 = new HttpMockFactory(401, 'SUCCESS', 'test');
            Test.setMock(HttpCalloutMock.class, mockData1);
            CCR_AssetReplacementOrderApi.errorCodes = 'test';
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
            HttpMockFactory mockData = new HttpMockFactory(402, 'SUCCESS', '{ "access_token": "NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2FyYm9uLnN1cGVy", "scope": "am_application_scope,openid openid","id_token": "eyJ4NXQiOiJZVEV4TlRWa1pqVXhOREprTnpGbVlXWmxOakF5T0RFeVpqSTNZelV6TW1SallUTTVNREkyT0EiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoic2ZfVW05ckFobHFvZmQwN05iYVFndyIsImF1ZCI6WyJwZ2h6bmxMeHQ2NXc2OHp4Q3pfeHZ0TENIdlVhIl0sImF6cCI6InBnaHpubEx4dDY1dzY4enhDel94dnRMQ0h2VWEiLCJhdXRoX3RpbWUiOjE1MTU1MDY4MDcsImlzcyI6Imh0dHBzOlwvXC9hcGltLWlkZW50aXR5LnFhLXBtaWRjZS5jb20iLCJleHAiOjE1MTU1MTA2MzAsImlhdCI6MTUxNTUwNzAzMH0.kmYjPunr49l9NPvyL-ynLe0JQLL2xdlyuKflExSoVFy889GHpsjFncuBnhxDkBgvlNY4_XKllQ-jEaXrLVEaYGQekkrkIQ4jiogiwvmO7d2P3JLGZECggMVQ7uOhsNW4kfSaYTeK9P3xHp7eUu-Gx0zVxeO28zWnKlqIcXWqOviEPYQsPe5HsBs7Z3XP-KKneTMeaaW82Yr0VFVDYSmqCE3ZB82JPXs73Dn05plv792N_D01SMJR4MCNO-BRq_e7IZzAx63x8lO1H7UdVxLPZs8UHRtP-8cpXvxYYk85IvKatkb0akazFJlRhj46zQ_Ya35e5QXYKcZ5l205KlYWWg","token_type": "Bearer","expires_in": 3076}');
            Test.setMock(HttpCalloutMock.class, mockData);
            CCR_AssetReplacementOrderApi.errorCodes = 'test';
            IF_INFO__c inf = new IF_INFO__c();
            inf.URL__c = 'test.com';
            inf.IF_ID__c = 'IF_DEC_MG_0107';
            insert inf;
            qureMsgObj = CCR_AssetReplacementOrderApi.replaceAsset(qureMsgObj);
        }
    }
    /**
    * Method Name :  testReplacementOrderFailed
    * Arguments: None
    * Return : None
    * Description: This Method tests order creation failed
    **/
    @istest static void testReplacementOrderFailed () {

        User koreaCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact ct = new Contact(LastName='TestContact');
        insert ct;
        Asset ast = new Asset(Name='TestAsset',AccountId=acc.Id,ContactId=ct.Id,CCR_CodentifyId__c='testCodentify');
        insert ast;
        system.runas(koreaCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = ast.CCR_CodentifyId__c;
            qureMsgObj.CaseId = 'test';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1402';
            qureMsgObj.IsLimitedEdition = false;
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.productId = '2';
//            Cache.Org.put('local.CCRTokens.CCRDWAccessToken', 'NDIwZmVlZTEtOWRiYi0zZDFmLWI1MTgtNGE5NDM5ZWUzNzU1OmFwcGxpY2F0aW9uLXNhbGVzZm9yY2UtcWFAY2FyYm9uLnN1cGVy', 3076);
            test.startTest();
            HttpMockFactory mockData1 = new HttpMockFactory(200, 'SUCCESS', '{"_v":"18.3","_type":"product_search_result","count":11,"hits":[{"_type":"product","_resource_state":"89f3276304e0de244a9f23533e0d3b46bf6a69ee1051cdf42720740cce3beaad","id":"DA000219.00-RPL","in_stock":true,"image":{"_type":"media_file","abs_url":"https://dev21-eu-pmi.demandware.net/on/demandware.static/-/Sites-KR_Master_Catalog/default_Desciption/vada3ac68207eaa75f6d50dc688bbb99cee6aa395/images/large/lo-res/IQOS_BLUE_HOLDER.png"},"name":{"default_Desciption":"IQOS Holder","ko-KR":"???? ?? ??","translated_Desciption":"IQOS Holder"},"c_color":"Blue","c_deviceVersion":"2.4","c_masterProductID":"A1503","c_smdlColor":"BLU"}]}');
            test.setMock(HttpCalloutMock.class, mockData1);
            qureMsgObj = CCR_AssetReplacementOrderApi.deviceReplacementOrder(qureMsgObj);
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }
    /**
    * Method Name :  testReplacementAuthFail
    * Arguments: None
    * Return : None
    * Description: This Method tests authentication failed
    **/
    @istest static void testReplacementAuthFail () {

        User franceCallCenterUser = [SELECT id,CCR_UserType__c from user WHERE  CCR_UserType__c ='Call Center Agent' ORDER BY CreatedDate DESC limit 1];
        Account acc = new Account(Name='TestAccount');
        insert acc;
        Contact ct = new Contact(LastName='TestContact');
        insert ct;
        Asset ast = new Asset(Name='TestAsset',AccountId=acc.Id,ContactId=ct.Id,CCR_CodentifyId__c='testCodentify');
        insert ast;
        system.runas(franceCallCenterUser) {
            CCR_QureMsg qureMsgObj = new CCR_QureMsg();
            qureMsgObj.Codentify = 'test';
            qureMsgObj.CaseId = 'test';
            qureMsgObj.ReplacementReason = 'For Testing';
            qureMsgObj.Salutation = 'MR';
            qureMsgObj.FirstName = 'Andrew';
            qureMsgObj.LastName = 'Martin';
            qureMsgObj.AddressStreet = '12 B';
            qureMsgObj.AddressPostalCode = '2';
            qureMsgObj.AddressCity = 'Milan';
            qureMsgObj.Market = 'KR';
            qureMsgObj.model = 'A1403';
            qureMsgObj.IsLimitedEdition = false;
            test.startTest();
            HttpMockFactory mockData = new HttpMockFactory(401, 'BADREQUEST', 'test');
            Test.setMock(HttpCalloutMock.class, mockData);
//            CCR_AssetReplacementOrderApi.getOrgAccessToken('test.com');
            system.assertNotEquals(null, qureMsgObj);
            test.stopTest();
        }
    }


    /* mock class */
    public class HttpMockFactory implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;
        protected Map<String, String> responseHeaders;
        public HttpMockFactory(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
            this.responseHeaders = responseHeaders;
        }

        public System.HttpResponse respond(System.HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.body);
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            return res;
        }
    }

}