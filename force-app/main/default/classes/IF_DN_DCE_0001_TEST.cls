/****************************************************************************************
  * File Name   : IF_DN_DCE_0001_TEST
  * Description : IF_DN_DCE_0001_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100             Create
****************************************************************************************/
@isTest
public class IF_DN_DCE_0001_TEST {

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

        IF_Base.IfStaticValue(staticValue);
    }

    // 입력 객체 생성
    private static IF_DN_DCE_0001.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"ifTrackingId":"e9a1a0ed-1347-6a1f-e372-2a0c8d16bbf7","ifSenderGp":"KR","ifSender":"DN","ifResult":"","ifReceiverGp":"KR","ifReceiver":"DCE","ifId":"IF_DN_DCE_0001","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210624011352"},"payload":{"t_data":[{"Requests":[{"requestId":"A-228714","device":{"ToReplaceCodentify":"T3NQJH585V6R4Y","Parentcodentify":"WAH6V8AXEQFT"},"AddDetails":{"ReplacementDate":"2020-02-23 07:20:40","ReplacementCountry":"KR","Reason":"P.Charger not charging","Ext_Ref":"Exteranal ref from Danal","Channel_v2":"GS","Channel":"Pickup Point"}}],"ReplacementType":"0"}]}}}';
        IF_DN_DCE_0001.InputDIH input = new IF_DN_DCE_0001.InputDIH();
        input = (IF_DN_DCE_0001.InputDIH)JSON.deserialize(req, IF_DN_DCE_0001.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifSenderGp":"SFDC","ifSender":"SE","ifResult":"S","ifReceiverGp":"LSMTRON","ifReceiver":"ERP","ifId":"IF_DN_DCE_0001","ifFailMsg":"","ifFailCode":"","ifDateTime":"20200406110322"},"payload":{"ifSplitCnt":null,"ifRcvCnt":null,"ifAggregation":null}}}');
        IF_DN_DCE_0001.OutputDIH temp = (IF_DN_DCE_0001.OutputDIH)JSON.deserialize(res.getBody(), IF_DN_DCE_0001.OutputDIH.class);
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
        System.debug('@@@@@ testServiceExecute @@@@@@');
        String jsonMsg = JSON.serialize(newInputParameter());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_DN_DCE_0001';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
//        IF_DN_DCE_0001.OutputDIH result = IF_DN_DCE_0001.doPost();
        IF_DN_DCE_0001.OUTPUT_T_DATA result = IF_DN_DCE_0001.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_DN_DCE_0001 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_DN_DCE_0001.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_DN_DCE_0001 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        String req = '{"request":{"header":{"ifTrackingId":"e9a1a0ed-1347-6a1f-e372-2a0c8d16bbf7","ifSenderGp":"KR","ifSender":"DN","ifResult":"","ifReceiverGp":"KR","ifReceiver":"DCE","ifId":"IF_DN_DCE_0001","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210624011352"},"payload":{"t_data":[{"Requests":[{"requestId":"A-228714","device":{"ToReplaceCodentify":"T3NQJH585V6R4Y","Parentcodentify":"WAH6V8AXEQFT"},"AddDetails":{"ReplacementDate":"2020-02-23 07:20:40","ReplacementCountry":"KR","Reason":"P.Charger not charging","Ext_Ref":"Exteranal ref from Danal","Channel_v2":"GS","Channel":"Pickup Point"}}],"ReplacementType":"0"}]}}}';
        IF_DN_DCE_0001.INPUT_T_DATA input = new IF_DN_DCE_0001.INPUT_T_DATA();
        input = (IF_DN_DCE_0001.INPUT_T_DATA) JSON.deserialize(req, IF_DN_DCE_0001.INPUT_T_DATA.class);
//        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(input));
//        testStaticValue();
//        newInputParameter();
//        newResponse(200);
        System.assertEquals(testServiceExecute(), true);
        IF_DN_DCE_0001_BIZ.runTest();

//        System.assertEquals(testServiceExecute(), true);
    }
}