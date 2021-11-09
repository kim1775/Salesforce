/****************************************************************************************
  * File Name   : IF_MG_DCE_0096
  * Description : IF_MG_DCE_0096
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.04  ldb3100    Create
    1.1  2021.03.17 i2max_Sukun Update
****************************************************************************************/
public with sharing class IF_MG_DCE_0096_BIZ {
    private static IF_MG_DCE_0096_BIZ sInstance = null;
    public static IF_MG_DCE_0096_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_MG_DCE_0096_BIZ();
        }
        return sInstance;
    }

    public IF_MG_DCE_0096.InputBody pre(IF_MG_DCE_0096.InputBody inputBody, IF_MG_DCE_0096.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_MG_DCE_0096.OutputBody post(IF_MG_DCE_0096.InputBody inputBody, IF_MG_DCE_0096.OutputBody outputBody) {

        // Param
        List<IF_KDCE_API_BizBase.T_Contact> tContacts = inputBody.t_data != null ? inputBody.t_data[0].t_Contacts : null;

        tContacts = IF_KDCE_API_BizBase.setContacts(tContacts);
//        List<Id> tContactIds = new List<Id>();
        List<String> tContactExtIds = new List<String>();
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
//            tContactIds.add(tContact.Id);
            tContactExtIds.add(tContact.ContactExtId);
        }

        IF_MG_DCE_0096.OutputData outputData = new IF_MG_DCE_0096.OutputData();
//        outputData.t_Contacts = tContacts;
//        outputData.contactIds = tContactIds;
        outputData.contactExtIds = tContactExtIds;
        outputBody.t_data.add(outputData);
        //대량 인터페이스 분활 처리
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = String.valueOf(tContacts.size()); // 수신 수량(Count) 리턴 필드

        return outputBody;
    }
}