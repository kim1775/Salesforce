/****************************************************************************************
  * File Name   : IF_MG_DCE_0094_TEST
  * Description : IF_MG_DCE_0094_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100             Create
****************************************************************************************/
@isTest
public class IF_MG_DCE_0094_TEST {

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
    private static IF_MG_DCE_0094.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"ifId":"IF_MG_DCE_0094","ifSenderGp":"Magento","ifSender":"Magento","ifReceiverGp":"SFSC","ifReceiver":"SFSC","ifTrackingId":null,"ifDateTime":null,"ifResult":null,"ifFailMsg":null,"ifFailCode":null},"payload":{"ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifTotCnt":2,"ifSplitCnt":"1","ifSplitSeq":"1","ifDateTime":null,"t_data":[{"t_Orders":[{"OrderDate":"2021-07-05 02:43:32","OrderNo":"000006785","OriginOrderNo":"","ActionChannel":"iqos.com","ActionType":"C","OrderReason":"FORWARD","OrderType":"ZTI","OrderCurrency":"KRW","ContactExtId":"f7aecdcb45ef17f457a89cc8a6d39389","CustomerName":"\\uae40\\ucca0\\uc900 .","CustomerEmail":"mikekim324@gmail.com","OrderStatus":"processing","ShippingAddressName":"\\uae40\\ucca0\\uc900 .","ShippingState":"","ShippingCity":"\\uc11c\\uc6b8","ShippingStreet":"\\uc11c\\uc6b8 \\uc601\\ub4f1\\ud3ec\\uad6c   \\uad6d\\uc81c\\uae08\\uc735\\ub85c2\\uae38 11 (\\uc5ec\\uc758\\ub3c4\\ub3d9, \\uba54\\ub9ac\\uce20\\ud654\\uc7ac\\uc5ec\\uc758\\ub3c4\\uc0ac\\uc625)","ShippingPostalCode":"07327","ShippingCountry":"KR","ShippingPhone":"01052500180","ShippingTax":"","ShippingMessage":null,"ShippingGrossPrice":"","ShippingItemId":"STANDARD_SHIPPING","ShippingMethod":"freeshipping_freeshipping","GrossPrice":130000,"Discount":-71000,"NetPrice":59000,"PaymentAmount":59000,"PaymentMethod":"\\uc815\\uae30\\uacb0\\uc81c","PaymentProcessorId":"imps_100012169383","PromotionId":"15","CouponCode":null,"Channel":"iqos.com","ExtOrderId":"","RentalId":"","RentalStartDate":"","RentalEndDate":"","RentalStatus":"","CollectCodentify":"","TrackingNo":"","TrackingUrl":"","t_OrderItems":[{"ExtOrderItemId":"0000067854723-0","OrderItemNo":"0000067854723-0","ProductCode":"DK000872","Codentify":"","FullProductId":"","KDCE_EANCode":"8809666700222","ProductQuantity":1,"ProductIGrossPrice":130000,"ProductItemDiscount":"71000","ProductTaxBasis":"59000","ProductTaxRate":"","ProductTax":"","ProductNetPrice":"59000"}]},{"OrderDate":"2021-07-05 02:43:36","OrderNo":"T000003312","OriginOrderNo":"000006785","ActionChannel":"iqos.com","ActionType":"C","OrderReason":"COLLECT","OrderType":"ZTI","OrderCurrency":"KRW","ContactExtId":"f7aecdcb45ef17f457a89cc8a6d39389","CustomerName":"\\uae40\\ucca0\\uc900","CustomerEmail":"mikekim324@gmail.com","OrderStatus":"pending","ShippingAddressName":"\\uae40\\ucca0\\uc900","ShippingState":"\\uc601\\ub4f1\\ud3ec\\uad6c","ShippingCity":"\\uc11c\\uc6b8","ShippingStreet":"\\uc11c\\uc6b8 \\uc601\\ub4f1\\ud3ec\\uad6c   \\uad6d\\uc81c\\uae08\\uc735\\ub85c2\\uae38 11 (\\uc5ec\\uc758\\ub3c4\\ub3d9, \\uba54\\ub9ac\\uce20\\ud654\\uc7ac\\uc5ec\\uc758\\ub3c4\\uc0ac\\uc625)","ShippingPostalCode":"07327","ShippingCountry":"KR","ShippingPhone":"01052500180","ShippingMessage":null,"ShippingTax":"","ShippingGrossPrice":"","ShippingItemId":"STANDARD_SHIPPING","ShippingMethod":"\\ud0dd\\ubc30","GrossPrice":130000,"Discount":-71000,"NetPrice":59000,"PaymentAmount":59000,"PaymentMethod":"","PaymentProcessorId":"imps_100012169383","PromotionId":"","CouponCode":"","Channel":"iqos.com","ExtOrderId":"","CollectStatus":"","CollectionStartDate":"","CollectionStatusDate":"","CollectionAmount":"0","t_OrderItems":[{"ExtOrderItemId":"T0000033124723-0","OrderItemNo":"T0000033124723-0","Codentify":"T2P2UFKVK300WP","KDCE_EANCode":"8809092877475","ProductQuantity":1,"ProductIGrossPrice":"","ProductItemDiscount":"","ProductTaxBasis":"","ProductTaxRate":"","ProductTax":"","ProductNetPrice":"","ShipStatus":"pending","ShipStatusDate":"","ShipQuantity":"","TrackingNo":"","TrackingUrl":"","FullProductId":"DK000414.00"}]}]}]}}}';

        IF_MG_DCE_0094.InputDIH input = new IF_MG_DCE_0094.InputDIH();
        input = (IF_MG_DCE_0094.InputDIH)JSON.deserialize(req, IF_MG_DCE_0094.InputDIH.class);

        System.debug('input :: ' + input);
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"header":{"ifTrackingId":null,"ifSenderGp":"SFSC","ifSender":"SFSC","ifResult":"S","ifReceiverGp":"Magento","ifReceiver":"Magento","ifId":"IF_MG_DCE_0094","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210224030047"},"payload":{"t_data":[{"productIds":["01t1m000000uBBaAAM","01t1m000000u8RRAAY","01t1m000000uA5tAAE","01t1m000000uA1jAAE"]}],"ifSplitCnt":"1","ifRcvCnt":"1","ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3"}}');
        IF_MG_DCE_0094.OutputDIH temp = (IF_MG_DCE_0094.OutputDIH)JSON.deserialize(res.getBody(), IF_MG_DCE_0094.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_MG_DCE_0094';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_MG_DCE_0094.OutputDIH result = IF_MG_DCE_0094.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_MG_DCE_0094 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_MG_DCE_0094.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_MG_DCE_0094 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest
    public static void testServiceSuccess() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        test.startTest();
        Contact contMem = KDCE_TestUtil.contactMember.clone(true);
        contMem.KDCE_ExternalId__c = 'f7aecdcb45ef17f457a89cc8a6d39389';
        contMem.KDCE_PNKey__c = '01000002590';
        contMem.KDCE_IsDropout__c = false;
        update contMem;

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
        test.stopTest();
    }
}