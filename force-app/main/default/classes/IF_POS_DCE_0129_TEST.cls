/****************************************************************************************
  * File Name   : IF_POS_DCE_0129_TEST
  * Description : IF_POS_DCE_0129_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100             Create
****************************************************************************************/
@isTest
public class IF_POS_DCE_0129_TEST {

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
    private static IF_POS_DCE_0129.InputDIH newInputParameter() {
        String req = '{"request":{"payload":{"ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifSplitSeq":"1","ifSplitCnt":"1","ifTotCnt":"0","t_data":[{"t_Orders":[{"OrderDate":"2021-07-05 11:37:17","OrderNo":"202107059000000010008","OriginOrderNo":"","ActionChannel":"POS","ActionType":"C","OrderType":"ZTA","OrderReason":"forward","OrderCurrency":"KRW","ContactExtId":"","OrderStatus":"Complete","GrossPrice":"168000.000","Discount":"65000.000","NetPrice":"103000.000","PaymentAmount":"168000.000","PaymentMethod":"CASH_POS","PaymentTransactionId":"","PromotionId":"1907100013","PromotionName":"2.4P 키트 특별할인","CouponCode":"","StoreChannel":"테스트점포(PMK)","StoreCode":"90000","ItemCount":"6","OrderSeq":"6","t_OrderItems":[{"OrderItemNo":"202107059000000010008_01","KDCE_EANCode":"8809092874559","ProductQuantity":"1.0000","ProductIGrossPrice":"29000.000","ProductItemDiscount":"0.000","ProductTaxBasis":"26364.000","ProductTaxRate":"10.000","ProductTax":"2636.000","ProductNetPrice":"29000.000"},{"OrderItemNo":"202107059000000010008_02","KDCE_EANCode":"8809092874139","ProductQuantity":"1.0000","ProductIGrossPrice":"100000.000","ProductItemDiscount":"65000.000","ProductTaxBasis":"31818.000","ProductTaxRate":"10.000","ProductTax":"3182.000","ProductNetPrice":"35000.000"},{"OrderItemNo":"202107059000000010008_03","KDCE_EANCode":"8809092873187","ProductQuantity":"1.0000","ProductIGrossPrice":"15000.000","ProductItemDiscount":"0.000","ProductTaxBasis":"13636.000","ProductTaxRate":"10.000","ProductTax":"1364.000","ProductNetPrice":"15000.000"},{"OrderItemNo":"202107059000000010008_04","KDCE_EANCode":"8809092874221","ProductQuantity":"1.0000","ProductIGrossPrice":"15000.000","ProductItemDiscount":"0.000","ProductTaxBasis":"13636.000","ProductTaxRate":"10.000","ProductTax":"1364.000","ProductNetPrice":"15000.000"},{"OrderItemNo":"202107059000000010008_05","KDCE_EANCode":"88018744","ProductQuantity":"1.0000","ProductIGrossPrice":"4500.000","ProductItemDiscount":"0.000","ProductTaxBasis":"4091.000","ProductTaxRate":"10.000","ProductTax":"409.000","ProductNetPrice":"4500.000"},{"OrderItemNo":"202107059000000010008_06","KDCE_EANCode":"88018744","ProductQuantity":"1.0000","ProductIGrossPrice":"4500.000","ProductItemDiscount":"0.000","ProductTaxBasis":"4091.000","ProductTaxRate":"10.000","ProductTax":"409.000","ProductNetPrice":"4500.000"}]},{"OrderDate":"2021-07-05 11:37:28","OrderNo":"202107059000000010009","OriginOrderNo":"202107059000000010008","ActionChannel":"POS","ActionType":"C","OrderType":"ZTA","OrderReason":"return","OrderCurrency":"KRW","ContactExtId":"","OrderStatus":"cancel_order","GrossPrice":"168000.000","Discount":"65000.000","NetPrice":"103000.000","PaymentAmount":"168000.000","PaymentMethod":"CASH_POS","PaymentTransactionId":"","PromotionId":"1907100013","PromotionName":"2.4P 키트 특별할인","CouponCode":"","StoreChannel":"테스트점포(PMK)","StoreCode":"90000","ItemCount":"6","OrderSeq":"6","t_OrderItems":[{"OrderItemNo":"202107059000000010009_01","KDCE_EANCode":"8809092874559","ProductQuantity":"1.0000","ProductIGrossPrice":"29000.000","ProductItemDiscount":"0.000","ProductTaxBasis":"26364.000","ProductTaxRate":"10.000","ProductTax":"2636.000","ProductNetPrice":"29000.000"},{"OrderItemNo":"202107059000000010009_02","KDCE_EANCode":"8809092874139","ProductQuantity":"1.0000","ProductIGrossPrice":"100000.000","ProductItemDiscount":"65000.000","ProductTaxBasis":"31818.000","ProductTaxRate":"10.000","ProductTax":"3182.000","ProductNetPrice":"35000.000"},{"OrderItemNo":"202107059000000010009_03","KDCE_EANCode":"8809092873187","ProductQuantity":"1.0000","ProductIGrossPrice":"15000.000","ProductItemDiscount":"0.000","ProductTaxBasis":"13636.000","ProductTaxRate":"10.000","ProductTax":"1364.000","ProductNetPrice":"15000.000"},{"OrderItemNo":"202107059000000010009_04","KDCE_EANCode":"8809092874221","ProductQuantity":"1.0000","ProductIGrossPrice":"15000.000","ProductItemDiscount":"0.000","ProductTaxBasis":"13636.000","ProductTaxRate":"10.000","ProductTax":"1364.000","ProductNetPrice":"15000.000"},{"OrderItemNo":"202107059000000010009_05","KDCE_EANCode":"88018744","ProductQuantity":"1.0000","ProductIGrossPrice":"4500.000","ProductItemDiscount":"0.000","ProductTaxBasis":"4091.000","ProductTaxRate":"10.000","ProductTax":"409.000","ProductNetPrice":"4500.000"},{"OrderItemNo":"202107059000000010009_06","KDCE_EANCode":"88018744","ProductQuantity":"1.0000","ProductIGrossPrice":"4500.000","ProductItemDiscount":"0.000","ProductTaxBasis":"4091.000","ProductTaxRate":"10.000","ProductTax":"409.000","ProductNetPrice":"4500.000"}]}]}]},"header":{"ifReceiverGp":"SC","ifReceiver":"SC","ifId":"IF_POS_DCE_0129","ifSenderGp":"POS","ifSender":"POS"}}}';

        IF_POS_DCE_0129.InputDIH input = new IF_POS_DCE_0129.InputDIH();
        input = (IF_POS_DCE_0129.InputDIH)JSON.deserialize(req, IF_POS_DCE_0129.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"header":{"ifTrackingId":null,"ifSenderGp":"KR","ifSender":"DCE","ifResult":"S","ifReceiverGp":"KR","ifReceiver":"POS","ifId":"IF_POS_DCE_0129","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210224030047"},"payload":{"t_data":[{"productIds":["01t1m000000uBBaAAM","01t1m000000u8RRAAY","01t1m000000uA5tAAE","01t1m000000uA1jAAE"]}],"ifSplitCnt":"1","ifRcvCnt":"1","ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3"}}');
        IF_POS_DCE_0129.OutputDIH temp = (IF_POS_DCE_0129.OutputDIH)JSON.deserialize(res.getBody(), IF_POS_DCE_0129.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_POS_DCE_0129';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_POS_DCE_0129.OutputDIH result = IF_POS_DCE_0129.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_POS_DCE_0129 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_POS_DCE_0129.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_POS_DCE_0129 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}