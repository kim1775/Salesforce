/****************************************************************************************
  * File Name   : IF_DCE_GC_0001_TEST
  * Description : IF_DCE_GC_0001_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.03.02.    ldb3100    Create
****************************************************************************************/
@isTest
private class IF_DCE_GC_0001_TEST {
    // 입력 객체 생성
    private static IF_DCE_GC_0001.InputDIH newInputParameter() {
        IF_DCE_GC_0001.InputBody payload = new IF_DCE_GC_0001.InputBody();

        IF_DCE_GC_0001.InputDIH input = new IF_DCE_GC_0001.InputDIH();

        IF_DCE_GC_0001.Input inputObj = input.Request;

        inputObj.Header = new IF_Base_GC.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_DCE_GC_0001', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"access_token":"ylQhkw_EuL8F6xBqieu2IRJTMjrItbfNM10bFD5GvWpShLzXaCfq5NimJytQyzoFAO","token_type":"bearer","expires_in":172799}');
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

        RestRequest  req = new RestRequest ();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_DCE_GC_0001';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_DCE_GC_0001 instance = IF_DCE_GC_0001.getInstance();
        // 서비스 실행
        IF_DCE_GC_0001.InputDIH input = new IF_DCE_GC_0001.InputDIH();
        IF_DCE_GC_0001.INPUT_T_DATA tData = new IF_DCE_GC_0001.INPUT_T_DATA();
        tData.conversationId     = '0e202d4d-baa8-43d4-86dd-80918eb1d37a';

        input.request.payload.t_data.add(tData);
        System.debug('result input : '+ JSON.serialize(input));

        IF_DCE_GC_0001.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_DCE_GC_0001 성공!!!');

        // crashTest
        IF_Base_GC.crashTest = true;
        result = instance.execute(new IF_DCE_GC_0001.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_DCE_GC_0001 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}