/****************************************************************************************
  * File Name   : IF_MG_DCE_0094
  * Description : IF_MG_DCE_0094
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.04  ldb3100    Create
    1.1  2021.03.30 i2max_Sukun Update
****************************************************************************************/
public with sharing class IF_MG_DCE_0094_BIZ {
    private static IF_MG_DCE_0094_BIZ sInstance = null;
    public static IF_MG_DCE_0094_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_MG_DCE_0094_BIZ();
        }
        return sInstance;
    }

    public IF_MG_DCE_0094.InputBody pre(IF_MG_DCE_0094.InputBody inputBody, IF_MG_DCE_0094.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_MG_DCE_0094.OutputBody post(IF_MG_DCE_0094.InputBody inputBody, IF_MG_DCE_0094.OutputBody outputBody) {

        // Param

        List<IF_KDCE_API_BizBase.T_Order> tOrders = inputBody.t_data != null ? inputBody.t_data[0].t_Orders : null;

        tOrders = IF_KDCE_API_BizBase.setOrdersByMagento(tOrders);
        List<Id> tOrderIds = new List<Id>();
        for (IF_KDCE_API_BizBase.T_Order tOrder : tOrders) {
            tOrderIds.add(tOrder.Id);
        }

        IF_MG_DCE_0094.OutputData outputData = new IF_MG_DCE_0094.OutputData();
        outputData.orderIds = tOrderIds;
        outputBody.t_data.add(outputData);
        //대량 인터페이스 분활 처리
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = String.valueOf(inputBody.t_data.size()); // 수신 수량(Count) 리턴 필드


        return outputBody;
    }
}