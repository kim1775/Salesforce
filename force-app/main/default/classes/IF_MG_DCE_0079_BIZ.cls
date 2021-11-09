/****************************************************************************************
  * File Name   : IF_MG_DCE_0079
  * Description : IF_MG_DCE_0079
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.04  ldb3100    Create
****************************************************************************************/
public with sharing class IF_MG_DCE_0079_BIZ {
    private static IF_MG_DCE_0079_BIZ sInstance = null;
    public static IF_MG_DCE_0079_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_MG_DCE_0079_BIZ();
        }
        return sInstance;
    }

    public IF_MG_DCE_0079.InputBody pre(IF_MG_DCE_0079.InputBody inputBody, IF_MG_DCE_0079.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_MG_DCE_0079.OutputBody post(IF_MG_DCE_0079.InputBody inputBody, IF_MG_DCE_0079.OutputBody outputBody) {

        System.debug('=== IF_MG_DCE_0079.OutputBody : ');

        // Input Data
        List<IF_KDCE_API_BizBase.T_Contact> tContacts = inputBody.t_data != null ? inputBody.t_data[0].t_Contacts : null;

        // Coupon Return (Coupon, Contact 정보 업데이트 및 Coupon History 생성)
        IF_KDCE_API_BizBase.T_Coupon tCoupon = IF_KDCE_API_BizService.setCoupon(tContacts);
        System.debug('=== tCoupon : ' + tCoupon);

        // Output 선언
        IF_MG_DCE_0079.OutputData outputData = new IF_MG_DCE_0079.OutputData();
        System.debug('=== outputData : ' + outputData);
        outputData.coupon = tCoupon;
        outputData.JobResult = tCoupon.JobResult;
//        outputData.jobResult;

        outputBody.t_data.add(outputData);
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = IF_Comm.convertEmpty(outputBody.t_data.size());   // 수신수량 return 필드
//
        return outputBody;
    }
}