/****************************************************************************************
  * File Name   : IF_POS_DCE_0143
  * Description : IF_POS_DCE_0143
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.05  ldb3100    Create
****************************************************************************************/
public with sharing class IF_POS_DCE_0143_BIZ {
    private static IF_POS_DCE_0143_BIZ sInstance = null;
    public static IF_POS_DCE_0143_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_POS_DCE_0143_BIZ();
        }
        return sInstance;
    }

    public IF_POS_DCE_0143.InputBody pre(IF_POS_DCE_0143.InputBody inputBody, IF_POS_DCE_0143.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_POS_DCE_0143.OutputBody post(IF_POS_DCE_0143.InputBody inputBody, IF_POS_DCE_0143.OutputBody outputBody) {

        // Param
        IF_KDCE_API_BizBase.T_POS_Contact tContact = inputBody.t_data != null ? inputBody.t_data[0].t_Contact : null;

        List<IF_KDCE_API_BizBase.T_POS_Contact> tContacts = IF_KDCE_API_BizBase.getContactsByPOS(tContact);
//
        IF_POS_DCE_0143.OutputData outputData = new IF_POS_DCE_0143.OutputData();
        outputData.t_Contacts = tContacts;
        outputBody.t_data.add(outputData);
        //대량 인터페이스 분활 처리
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = String.valueOf(inputBody.t_data.size()); // 수신 수량(Count) 리턴 필드

        return outputBody;
    }
}