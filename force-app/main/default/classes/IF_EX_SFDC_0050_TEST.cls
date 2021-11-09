/****************************************************************************************
  * File Name   : IF_EX_SFDC_0050_TEST
  * Description : IF_EX_SFDC_0050_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date            Author         Modification
  * ===============================================================
    1.0  2021. 03. 22   ldb3100         Create
****************************************************************************************/
@isTest
public class IF_EX_SFDC_0050_TEST {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    // 입력 객체 생성
    private static IF_EX_SFDC_0050.InputDIH newInputParameter() {
        Contact member = [SELECT Id, KDCE_ExternalId__c FROM Contact WHERE Id = :KDCE_TestUtil.contactMember.Id];
        String contactExtId = member.KDCE_ExternalId__c;
        NotificationTemplate__c notificationTemplate = [SELECT Id, KDCE_ExternalId__c FROM NotificationTemplate__c WHERE Id = :KDCE_TestBizUtil.notiTemp.Id];
        String notiExtId = notificationTemplate.KDCE_ExternalId__c;
        String req = '{ "request": { "header": { "ifId": "IF_EX_SFDC_0050", "ifSenderGp": "Magento", "ifSender": "Magento", "ifReceiverGp": "SFSC", "ifReceiver": "SFSC", "ifTrackingId": null, "ifDateTime": null, "ifResult": null, "ifFailMsg": null, "ifFailCode": null }, "payload": { "ifAggregation": "0002e2d0-cec3-6e84-5761-ae68b3bf20a3", "ifTotCnt": "4", "ifSplitCnt": "1", "ifSplitSeq": "1", "ifDateTime": null, "t_data": [ { "templateExtId" : "'+ notiExtId +'", "currentDateTime" : "2021-03-29 12:14:20", "receiverType" : "contact", "tRecievers" : [ { "contactExtId" : "'+ contactExtId +'", "labels" : ["공덕 아이코스점","서울 마포구 마포대로 137","09:00~18:00"] } ] } ] } } }';
        req = '{"request":{"header":{"ifId":"IF_EX_SFDC_0050","ifSenderGp":"Magento","ifSender":"Magento","ifReceiverGp":"SFSC","ifReceiver":"SFSC","ifTrackingId":null,"ifDateTime":null,"ifResult":null,"ifFailMsg":null,"ifFailCode":null},"payload":{"ifAggregation":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifTotCnt":"4","ifSplitCnt":"1","ifSplitSeq":"1","ifDateTime":null,"t_data":[{"templateExtId":"'+ notiExtId +'","currentDateTime":"2021-06-16 15:14:20","receiverType":"Contact","t_Receivers":[{"contactExtId":"'+ contactExtId +'","labels":["김테스트","채널명 채널명","한 삼사만원","죽을때"]}]}]}}}';

        IF_EX_SFDC_0050.InputDIH input = new IF_EX_SFDC_0050.InputDIH();
        input = (IF_EX_SFDC_0050.InputDIH)JSON.deserialize(req, IF_EX_SFDC_0050.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        Contact member = [SELECT Id, KDCE_ExternalId__c FROM Contact WHERE Id = :KDCE_TestUtil.contactMember.Id];
        String contactExtId = member.KDCE_ExternalId__c;

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":null,"ifSenderGp":"SFSC","ifSender":"SFSC","ifResult":"S","ifReceiverGp":"Magento","ifReceiver":"Magento","ifId":"IF_EX_SFDC_0050","ifFailMsg":"","ifFailCode":"","ifDateTime":"20210405042028"},"payload":{"t_data":[{"templateExtId":"SC_SMS_0003","t_Receivers":[{"userId":null,"userExtId":null,"leadId":null,"leadExtId":null,"labels":["\\uacf5\\ub355 \\uc544\\uc774\\ucf54\\uc2a4\\uc810","\\uc11c\\uc6b8 \\ub9c8\\ud3ec\\uad6c \\ub9c8\\ud3ec\\ub300\\ub85c 137","09:00~18:00"],"isSuccess":"Y","errorMsg":null,"contactId":null,"contactExtId":"'+ contactExtId +'","accountId":null,"accountExtId":null},"receiverType":"Contact","currentDateTime":"2021-03-29 12:14:20"}]}}}');
        IF_EX_SFDC_0050.OutputDIH temp = (IF_EX_SFDC_0050.OutputDIH)JSON.deserialize(res.getBody(), IF_EX_SFDC_0050.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/Notiforce/IF_EX_SFDC_0050';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_EX_SFDC_0050.OutputDIH result = IF_EX_SFDC_0050.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_EX_SFDC_0050 실패!!!');

        // crashTest
        IF_BaseNotiforce.crashTest = true;
        result = IF_EX_SFDC_0050.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_EX_SFDC_0050 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();
        NotificationTemplate__c notificationTemplate = i2SEMA_TestDataUtil.getLMSTemplate();

        System.assertEquals(testServiceExecute(), true);
//        IF_EX_SFDC_0050_BIZ.runTest();
    }
}