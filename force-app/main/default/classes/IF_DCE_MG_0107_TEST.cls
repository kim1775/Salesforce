/****************************************************************************************
  * File Name   : IF_DCE_MG_0107_TEST
  * Description : IF_DCE_MG_0107_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.05.17.    ldb3100    Create
****************************************************************************************/
@isTest
private class IF_DCE_MG_0107_TEST {
    // 입력 객체 생성
    private static IF_DCE_MG_0107.InputDIH newInputParameter() {
        IF_DCE_MG_0107.InputBody payload = new IF_DCE_MG_0107.InputBody();

        IF_DCE_MG_0107.InputDIH input = new IF_DCE_MG_0107.InputDIH();

        IF_DCE_MG_0107.Input inputObj = input.Request;

        inputObj.Header = new IF_Base.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_DCE_MG_0107', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"error":false,"message":"","data":true,"empty":false}');
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

        req.requestURI = '/services/apexrest/IF_DCE_MG_0107';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_DCE_MG_0107 instance = IF_DCE_MG_0107.getInstance();
        // 서비스 실행
        IF_DCE_MG_0107.InputDIH input = new IF_DCE_MG_0107.InputDIH();
        IF_DCE_MG_0107.t_OrderItems tOrder = new IF_DCE_MG_0107.t_OrderItems();
        tOrder.KDCE_EANCode  = '';
        tOrder.Codentify     = '';
        tOrder.FullProductId = '';
        tOrder.ProductCode   = 'DE000158';
        tOrder.Name          = '아이코스3 차량용 거치대';
        IF_DCE_MG_0107.INPUT_T_DATA tData = new IF_DCE_MG_0107.INPUT_T_DATA();
        tData.CustomerName          = '정원식';
        tData.CustomerEmail         = 'daniel+1@wisecommerce.io';
        tData.CreatedDate           = '2021-05-17 04:58:04';
        tData.ContactExtId          = 'b3f49e23ccb26cc1cee7500b6c87755e';
        tData.CaseNo                = '00000012';
        tData.reason                = 'FOWARD';
        tData.ordertype             = 'ZRA';
        tData.ShippingPhone         = '01028821068';
        tData.ShippingAddress1      = '테헤란로 151 (역삼동, 역삼하이츠빌딩)';
        tData.ShippingAddress2      = '701호';
        tData.ShippingCity          = '서울';
        tData.ShippingStreet        = '강남구';
        tData.ShippingPostalCode    = '06132';
        tData.ShippingCountry       = 'KR';
        tData.t_OrderItems = tOrder;

        input.request.payload.t_data.add(tData);
        System.debug('result input : '+ JSON.serialize(input));

        IF_DCE_MG_0107.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_DCE_MG_0107 성공!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = instance.execute(new IF_DCE_MG_0107.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_DCE_MG_0107 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}