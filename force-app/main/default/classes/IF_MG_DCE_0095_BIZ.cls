/****************************************************************************************
  * File Name   : IF_MG_DCE_0095
  * Description : IF_MG_DCE_0095
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.04  ldb3100    Create
****************************************************************************************/
public with sharing class IF_MG_DCE_0095_BIZ {
    private static IF_MG_DCE_0095_BIZ sInstance = null;
    public static IF_MG_DCE_0095_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_MG_DCE_0095_BIZ();
        }
        return sInstance;
    }

    public IF_MG_DCE_0095.InputBody pre(IF_MG_DCE_0095.InputBody inputBody, IF_MG_DCE_0095.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_MG_DCE_0095.OutputBody post(IF_MG_DCE_0095.InputBody inputBody, IF_MG_DCE_0095.OutputBody outputBody) {

        // Param
        /*
        List<IF_KDCE_API_BizBase.T_Product> tProducts = inputBody.t_data != null ? inputBody.t_data[0].t_Products : null;

        tProducts = IF_KDCE_API_BizBase.setProducts(tProducts);
        List<Id> tProductIds = new List<Id>();
        for (IF_KDCE_API_BizBase.T_Product tProduct : tProducts) {
            tProductIds.add(tProduct.Id);
        }

        IF_MG_DCE_0095.OutputData outputData = new IF_MG_DCE_0095.OutputData();
        outputData.productIds = tProductIds;
        outputBody.t_data.add(outputData);
        //대량 인터페이스 분활 처리
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = String.valueOf(inputBody.t_data.size()); // 수신 수량(Count) 리턴 필드
         */

        return outputBody;
    }
}