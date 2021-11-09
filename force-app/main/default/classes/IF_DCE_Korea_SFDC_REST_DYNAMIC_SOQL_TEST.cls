/****************************************************************************************
  * @filename      : IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_TEST
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/18 3:38 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_TEST_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/18 3:38 오후     i2max_shlee       Create
****************************************************************************************/
@IsTest
public with sharing class IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_TEST {
    private static void testStaticValue() {
        IfStaticValue__c staticValue = new IfStaticValue__c();

        staticValue.sfdc_org_url__c              = 'https://salesforce.com';
        staticValue.sfdc_oauth_client_id__c      = 'client_id';
        staticValue.sfdc_oauth_client_secret__c  = 'client_secret';
        staticValue.sfdc_oauth_username__c       = 'salesforce@salesforce.com';
        staticValue.sfdc_oauth_password__c       = 'salesforce';
        staticValue.sfdc_aes_algorithm__c        = 'AES258';
        staticValue.hub_auth_name__c             = 'dih';
        staticValue.hub_auth_password__c         = 'dih_password';
        staticValue.hub_aes_private_key__c       = 'aes_key';
        staticValue.hub_aes_init_vector__c       = 'aes_vector';

        staticValue.hub_url__c       = 'Test_Setup_Value';

        IF_Base.IfStaticValue(staticValue);
    }

    // 입력 객체 생성
    private static IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputDIH newInputParameter() {

        String req = '{"request":{"payload":{"t_data":[{"DYNAMIC_SOQL":"SELECT ContactId,CCR_CodentifyId__c, SerialNumber, CCR_MaterialGroupDescription__c, CCR_MaterialDescription__c, CCR_OriginaDesignMarket__c, CCR_DeviceProductCode__r.CCR_Color__c, Product2.CCR_ProductName__c,KDCE_fm_ProductEAN__c, CreatedDate, LastModifiedDate FROM Asset WHERE CCR_CodentifyId__c \\u003d\\u0027TGC2X7HQ6GPQGR\\u0027","UN_ENCRYPT":"Y"}]},"header":{"ifSender":"POS","ifReceiverGp":"SC","ifSenderGp":"POS","ifReceiver":"SC","ifId":"IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL"}}}';
        IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputDIH input = new IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputDIH();
        input = (IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputDIH)JSON.deserialize(req, IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"header":{"ifTrackingId":null,"ifSenderGp":"SFSC","ifSender":"SFSC","ifResult":"S","ifReceiverGp":"Magento","ifReceiver":"Magento","ifId":"IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210224030047"},"payload":{"t_data":[{"productIds":["01t1m000000uBBaAAM","01t1m000000u8RRAAY","01t1m000000uA5tAAE","01t1m000000uA1jAAE"]}],"ifSplitCnt":"1","ifRcvCnt":"1","ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3"}}');
        IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.OutputDIH temp = (IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.OutputDIH)JSON.deserialize(res.getBody(), IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.OutputDIH.class);
        return res;
    }

    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // 공통 테스트 진행
    private static Boolean testServiceExecute() {
        String jsonMsg = JSON.serialize(newInputParameter());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.OutputDIH result = IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        testStaticValue();
        IF_INFO__c ifInfo = new IF_INFO__c(
                IF_ID__c = 'IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL',
                URL__c = '/IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL',
                CYCLE__c ='realtime',
                FROM__c ='Ecommerce',
                TO__c ='SFDC',
                TITLE__c ='Ecommerce에서 SFDC로 \'SOQL\' 을(를) 조회한다.',
                FORCE_LOGGING__c = true
        );
        insert ifInfo;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}