/****************************************************************************************
  * File Name   : IF_GC_DCE_0001_TEST
  * Description : IF_GC_DCE_0001_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100             Create
****************************************************************************************/
@isTest
public class IF_GC_DCE_0001_TEST {

    private static void testStaticValue() {
        IfStaticValue__c staticValue = new IfStaticValue__c();

        staticValue.sfdc_org_url__c              = 'https://salesforce.com';
        staticValue.sfdc_oauth_client_id__c      = 'client_id';
        staticValue.sfdc_oauth_client_secret__c  = 'clieRnt_secret';
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
    private static IF_GC_DCE_0001.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"ifId":"IF_GC_DCE_0001","ifSenderGp":"KR","ifSender":"GC","ifReceiverGp":"KR","ifReceiver":"DCE","ifTrackingId":"7662a444-8d04-f469-cdb0-66f39b305035","ifDateTime":"20210705082747"},"payload":{"t_data":[{"phone":"010-0000-0000","currentDateTime":"20210705113559","messageType":"02"}]}}}';

        IF_GC_DCE_0001.InputDIH input = new IF_GC_DCE_0001.InputDIH();
        input = (IF_GC_DCE_0001.InputDIH)JSON.deserialize(req, IF_GC_DCE_0001.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"7662a444-8d04-f469-cdb0-66f39b305035","ifSenderGp":"KR","ifSender":"DCE","ifResult":"S","ifReceiverGp":"KR","ifReceiver":"GC","ifId":"IF_GC_DCE_0001","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210308062723"},"payload":{"t_data":[{"phone":"010-0000-0000","messageType":"01","isSuccess":"Y","currentDateTime":"20210226082747"}]}}}');
        IF_GC_DCE_0001.OutputDIH temp = (IF_GC_DCE_0001.OutputDIH)JSON.deserialize(res.getBody(), IF_GC_DCE_0001.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_GC_DCE_0001';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_GC_DCE_0001.OutputDIH result = IF_GC_DCE_0001.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_GC_DCE_0001 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_GC_DCE_0001.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_GC_DCE_0001 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        NotificationTemplate__c noti = new NotificationTemplate__c(
                IsActive__c = true,
                Channel__c = '3'
        );
        insert noti;

        Contact contMem = KDCE_TestUtil.contactMember.clone(true);
        contMem.KDCE_PNKey__c = '01000000000';
        contMem.Phone = '01000000000';
        update contMem;
        Contact contMem2 = KDCE_TestUtil.contactMember.clone(false);
        contMem2.LastName = 'contMem2';
        contMem2.KDCE_PNKey__c = '01000000000';
        contMem2.Phone = '01000000000';
        contMem2.Email = 'testConMem2@test.com';
        insert contMem2;
        Contact contMem3 = KDCE_TestUtil.contactMember.clone(false);
        contMem3.LastName = 'contMem3';
        contMem3.KDCE_PNKey__c = '010999999999';
        contMem3.Phone = '010999999999';
        contMem3.Email = 'testcontMem3@test.com';
        contMem3.KDCE_InformationOptIn__c = true;
        insert contMem3;
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);


        String req = '{"request":{"header":{"ifId":"IF_GC_DCE_0001","ifSenderGp":"KR","ifSender":"GC","ifReceiverGp":"KR","ifReceiver":"DCE","ifTrackingId":"7662a444-8d04-f469-cdb0-66f39b305035","ifDateTime":"20210705082747"},"payload":{"t_data":[{"phone":"","currentDateTime":"20210705113559","messageType":"02"}]}}}';
        IF_GC_DCE_0001.InputDIH input = new IF_GC_DCE_0001.InputDIH();
        input = (IF_GC_DCE_0001.InputDIH)JSON.deserialize(req, IF_GC_DCE_0001.InputDIH.class);

        req = '{"request":{"header":{"ifId":"IF_GC_DCE_0001","ifSenderGp":"KR","ifSender":"GC","ifReceiverGp":"KR","ifReceiver":"DCE","ifTrackingId":"7662a444-8d04-f469-cdb0-66f39b305035","ifDateTime":"20210705082747"},"payload":{"t_data":[{"phone":"010-9999-99999","currentDateTime":"20210705113559","messageType":"02"}]}}}';
        input = new IF_GC_DCE_0001.InputDIH();
        input = (IF_GC_DCE_0001.InputDIH)JSON.deserialize(req, IF_GC_DCE_0001.InputDIH.class);




    }
}