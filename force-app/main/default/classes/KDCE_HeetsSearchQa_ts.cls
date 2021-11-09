/****************************************************************************************
  * @filename      : KDCE_HeetsSearchQa_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-17 오후 2:18
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-06-17 오후 2:18     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_HeetsSearchQa_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
        KDCE_TestUtil.getContactMember();
        KDCE_TestUtil.getProduct();
    }

    @IsTest
    static void testBehavior() {
        KDCE_HeetsSearchQa.validate(KDCE_TestUtil.contactMember.Id);

        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"ResultCode":"0", "ResultMessage":"OkCode", "PackagedItem": [{"ItemId":"codentifyTest0", "AlternateId":"codentifyTest0", "ProductionDateTimeUTC":null}]}'));
        //Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        KDCE_HeetsSearchQa.search('codentifyTest0');
        KDCE_HeetsSearchQa.save(KDCE_TestUtil.caseItem.Id, 'codentifyTest0', 'parentCodent', 'PM KOREA RRP INC. (Yangsan)', 'productCodeTest', 'EHC1 HEETS GOLD MNT S50 PRI 20 SLI', 'KE', 'ManufacturingCenterId');

        Test.stopTest();

        KDCE_HeetsSearchQa.save(KDCE_TestUtil.caseItem.Id, 'codentifyTest0', 'parentCodent', 'PM KOREA RRP INC. (Yangsan)', 'productCodeTest', 'EHC1 HEETS GOLD MNT S50 PRI 20 SLI', 'KE', 'ManufacturingCenterId');

    }

    @IsTest
    static void saveTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        // 현 화면에 보여지는  레코드 Id가 - Heets 제품에 대한 Case일 경우에 한하여 작동하므로 해당하는 Case Record Id가 필요
        // TestDataUtil의 Case Record Type (특정 Record Type Case 생성 무시, static Case의 Record Type 업데이트 불가) 이슈로 임의로 Case 데이터 생성 TODO TestUtil 데이터 세팅과정 확인이 필요해 보입니다.
        Case heetsCase = new Case(
                Subject = 'Heets Case',
                ContactId = contact.Id,
                RecordTypeId = KDCE_TestUtil.getRecordTypeId('Case', 'CCR_NewHeatStick'));
        insert heetsCase;

        String recordId = [SELECT Id FROM Case WHERE Id = :heetsCase.Id].Id;
        // 컴포넌트의 경우, 사용자 입력값이기에 Param 값들 하드코딩 하시면 됩니다.
        String productPackCodentifyId;
        String longName;
        String brandCode = [SELECT Name FROM Product2 LIMIT 1].Name;
        String brandDesc;
        String generationDate = '12/24/1995 12:00:00.';
        String factorycode = 'KE';
        String factorycodeCheck = 'ManufacturingCenterId';
        Test.startTest();
        KDCE_HeetsSearchQa.save(recordId, productPackCodentifyId, longName, brandCode, brandDesc, generationDate, factorycode, factorycodeCheck);
        Test.stopTest();
    }

    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
//        res.setBody('{"ifDate":"20201231","totCnt":1}');
        res.setBody('');
        return res;
    }
}