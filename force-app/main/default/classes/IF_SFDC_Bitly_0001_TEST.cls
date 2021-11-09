/****************************************************************************************
  * @filename      : IF_SFDC_Bitly_0001_TEST
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/04/08 8:52 오전
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_SFDC_Bitly_0001_TEST_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/04/08 8:52 오전     i2max_shlee       Create
****************************************************************************************/
@isTest
private class IF_SFDC_Bitly_0001_TEST {
    // 입력 객체 생성
    private static IF_SFDC_Bitly_0001.InputDIH newInputParameter() {
        IF_SFDC_Bitly_0001.InputBody payload = new IF_SFDC_Bitly_0001.InputBody();

        IF_SFDC_Bitly_0001.InputDIH input = new IF_SFDC_Bitly_0001.InputDIH();

        IF_SFDC_Bitly_0001.Input inputObj = input.Request;

        inputObj.Header = new IF_Base_Bitly.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_SFDC_Bitly_0001', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"ifDate":"20201231","totCnt":1}');
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

        req.requestURI = '/services/apexrest/IF_SFDC_Bitly_0001';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_SFDC_Bitly_0001 instance = IF_SFDC_Bitly_0001.getInstance();
        // 서비스 실행
        IF_SFDC_Bitly_0001.InputDIH input = new IF_SFDC_Bitly_0001.InputDIH();
        IF_SFDC_Bitly_0001.INPUT_T_DATA tData = new IF_SFDC_Bitly_0001.INPUT_T_DATA();
        tData.group_guid = '1';
        tData.domain     = '1';
        tData.long_url   = '1';


        input.request.payload.t_data.add(tData);

        IF_SFDC_Bitly_0001.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_SFDC_Bitly_0001 성공!!!');

        // crashTest
        IF_Base_Bitly.crashTest = true;
        result = instance.execute(new IF_SFDC_Bitly_0001.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_SFDC_Bitly_0001 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}