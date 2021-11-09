/****************************************************************************************
  * @filename      : IF_MG_DCE_0078_BIZ
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-07 오후 2:34
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
    0.1     2021-06-07 오후 2:34     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class IF_MG_DCE_0078_BIZ {
    private static IF_MG_DCE_0078_BIZ sInstance = null;
    public static IF_MG_DCE_0078_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_MG_DCE_0078_BIZ();
        }
        return sInstance;
    }

    public IF_MG_DCE_0078.InputBody pre(IF_MG_DCE_0078.InputBody inputBody, IF_MG_DCE_0078.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_MG_DCE_0078.OutputBody post(IF_MG_DCE_0078.InputBody inputBody, IF_MG_DCE_0078.OutputBody outputBody) {

        System.debug('=== inputBody : ' + inputBody);
        System.debug('=== inputBody.t_data : ' + inputBody.t_data);
        List<KDCE_Coupon__c> couponList = new List<KDCE_Coupon__c>();
        Boolean couponAvailable;
        String JobResult;

        // Input Data
        String couponCode = inputBody.t_data != null ? inputBody.t_data[0].couponCode : null;
        String contactExtId = inputBody.t_data != null ? inputBody.t_data[0].contactExtId : null;
        System.debug('=== couponCode : ' + couponCode);
        System.debug('=== contactExtId : ' + contactExtId);
        IF_KDCE_API_BizBase.validate(false, couponCode == null, 'Coupon Code 값이 무조건 있어야 합니다.');
        IF_KDCE_API_BizBase.validate(false, contactExtId == null, 'Contact External Id 값이 무조건 있어야 합니다.');

        // 해당 쿠폰 검색
        List<KDCE_Coupon__c> coupons = [
                SELECT  Id, Name, Amount__c, CouponCode__c, IsAvailable__c, IsSend__c, ExpiryDate__c,
                        Contact__c, fm_ContactExtId__c, ru_UseCount__c, Status__c, Type__c
                FROM    KDCE_Coupon__c
                WHERE   CouponCode__c = :couponCode
        ];
        // 해당 Contact 검색
        List<Contact> contacts = [SELECT Id, KDCE_LASLAU__c FROM Contact WHERE KDCE_ExternalId__c = :contactExtId];
        System.debug('=== coupons : ' + coupons);
        System.debug('=== contacts : ' + contacts);

        /** validation **/
        IF_KDCE_API_BizBase.validate(false, contacts.isEmpty(), '일치하는 Contact이 존재하지 않습니다.');
        if (coupons.isEmpty()) JobResult = '0401';                                                      // 없는 번호의 쿠폰일 경우
        else {
            if (coupons[0].IsAvailable__c == false) JobResult = '0402';                                     // 이미 사용된 쿠폰일 경우
            if (coupons[0].ExpiryDate__c < System.today()) JobResult = '0403';                              // 만료된 쿠폰일 경우
            if (coupons[0].Type__c == 'MGM' && contacts[0].KDCE_LASLAU__c == 'LAU') JobResult = '0404';     // LAU가 MGM 입력했을 경우
            IF (coupons[0].Type__c == 'MGM' && coupons[0].Contact__c == contacts[0].Id) JobResult = '0405'; // (MGM) 자신의 쿠폰번호를 입력했을 때
        }


        // Output 선언
        IF_MG_DCE_0078.OutputData outputData = new IF_MG_DCE_0078.OutputData();
        System.debug('=== outputData : ' + outputData);
        outputData.JobResult        = JobResult == null ? '0000' : JobResult;
        outputData.couponAvailable  = JobResult == null ? true : false;
        outputData.coupons          = coupons.isEmpty() ? null : coupons;
        outputBody.t_data.add(outputData);
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = IF_Comm.convertEmpty(outputBody.t_data.size());   // 수신수량 return 필드
//
        return outputBody;
    }
}