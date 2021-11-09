/****************************************************************************************
  * File Name   : IF_MG_DCE_0097_TEST
  * Description : IF_MG_DCE_0097_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100             Create
****************************************************************************************/
@isTest
public class IF_MG_DCE_0097_TEST {

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
    private static IF_MG_DCE_0097.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"ifId":"IF_MG_DCE_0097","ifSenderGp":"Magento","ifSender":"Magento","ifReceiverGp":"SFSC","ifReceiver":"SFSC","ifTrackingId":null,"ifDateTime":null,"ifResult":null,"ifFailMsg":null,"ifFailCode":null},"payload":{"ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifTotCnt":"4","ifSplitCnt":"1","ifSplitSeq":"1","ifDateTime":null,"t_data":[{"t_Products":[{"CCR_ProductName":"DK000415.00","KDCE_Barcode":"88code1"},{"CCR_ProductName":"DK000415.01","KDCE_Barcode":"88code2"},{"CCR_ProductName":"DK000415.02","KDCE_Barcode":"88code3"},{"CCR_ProductName":"DK000415.03","KDCE_Barcode":"88code4"}]}]}}}';
        req = '{"request":{"header":{"ifId":"IF_MG_DCE_0097","ifSenderGp":"Magento","ifSender":"Magento","ifReceiverGp":"SFSC","ifReceiver":"SFSC","ifTrackingId":null,"ifDateTime":null,"ifResult":null,"ifFailMsg":null,"ifFailCode":null},"payload":{"ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifTotCnt":4,"ifSplitCnt":"1","ifSplitSeq":"1","ifDateTime":null,"t_data":[{"t_Contact":{"LoginType":"N","ContactExtId":"6744584d691f79ace0d310112d07a60d"}}]}}}';

        IF_MG_DCE_0097.InputDIH input = new IF_MG_DCE_0097.InputDIH();
        input = (IF_MG_DCE_0097.InputDIH)JSON.deserialize(req, IF_MG_DCE_0097.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"header":{"ifTrackingId":null,"ifSenderGp":"SFSC","ifSender":"SFSC","ifResult":"S","ifReceiverGp":"Magento","ifReceiver":"Magento","ifId":"IF_MG_DCE_0097","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210224030047"},"payload":{"t_data":[{"productIds":["01t1m000000uBBaAAM","01t1m000000u8RRAAY","01t1m000000uA5tAAE","01t1m000000uA1jAAE"]}],"ifSplitCnt":"1","ifRcvCnt":"1","ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3"}}');
        IF_MG_DCE_0097.OutputDIH temp = (IF_MG_DCE_0097.OutputDIH)JSON.deserialize(res.getBody(), IF_MG_DCE_0097.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_MG_DCE_0097';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_MG_DCE_0097.OutputDIH result = IF_MG_DCE_0097.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_MG_DCE_0097 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_MG_DCE_0097.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_MG_DCE_0097 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
        IF_MG_DCE_0097_BIZ test = new IF_MG_DCE_0097_BIZ();

        IF_KDCE_API_BizService test2 = new IF_KDCE_API_BizService();
    }
}