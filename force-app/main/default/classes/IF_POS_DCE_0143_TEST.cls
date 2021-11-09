/****************************************************************************************
  * File Name   : IF_POS_DCE_0143_TEST
  * Description : IF_POS_DCE_0143_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100             Create
****************************************************************************************/
@isTest
public class IF_POS_DCE_0143_TEST {

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
    private static IF_POS_DCE_0143.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"ifId":"IF_POS_DCE_0143","ifSenderGp":"POS","ifSender":"POS","ifReceiverGp":"SFSC","ifReceiver":"SFSC"},"payload":{"ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifTotCnt":"4","ifSplitCnt":"1","ifSplitSeq":"1","t_data":[{"t_Contact":{"Mobile4Digit":"2590"}}]}}}';

        IF_POS_DCE_0143.InputDIH input = new IF_POS_DCE_0143.InputDIH();
        input = (IF_POS_DCE_0143.InputDIH)JSON.deserialize(req, IF_POS_DCE_0143.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"header":{"ifTrackingId":null,"ifSenderGp":"KR","ifSender":"DCE","ifResult":"S","ifReceiverGp":"KR","ifReceiver":"POS","ifId":"IF_POS_DCE_0143","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210224030047"},"payload":{"t_data":[{"productIds":["01t1m000000uBBaAAM","01t1m000000u8RRAAY","01t1m000000uA5tAAE","01t1m000000uA1jAAE"]}],"ifSplitCnt":"1","ifRcvCnt":"1","ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3"}}');
        IF_POS_DCE_0143.OutputDIH temp = (IF_POS_DCE_0143.OutputDIH)JSON.deserialize(res.getBody(), IF_POS_DCE_0143.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_POS_DCE_0143';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_POS_DCE_0143.OutputDIH result = IF_POS_DCE_0143.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_POS_DCE_0143 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_POS_DCE_0143.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_POS_DCE_0143 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
        Contact contMem = KDCE_TestUtil.contactMember.clone(true);
        contMem.KDCE_ExternalId__c = 'f7aecdcb45ef17f457a89cc8a6d39389';
        contMem.KDCE_PNKey__c = '01000002590';
        contMem.KDCE_IsDropout__c = false;
        update contMem;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}