/****************************************************************************************
  * @filename      : IF_MG_DCE_0092_BIZ
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/23 4:56 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_MG_DCE_0092_BIZ_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/23 4:56 오후     i2max_shlee       Create
****************************************************************************************/
public with sharing class IF_MG_DCE_0092_BIZ {
    private static IF_MG_DCE_0092_BIZ sInstance = null;
    public static IF_MG_DCE_0092_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_MG_DCE_0092_BIZ();
        }
        return sInstance;
    }

    public IF_MG_DCE_0092.InputBody pre(IF_MG_DCE_0092.InputBody inputBody, IF_MG_DCE_0092.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_MG_DCE_0092.OutputBody post(IF_MG_DCE_0092.InputBody inputBody, IF_MG_DCE_0092.OutputBody outputBody) {

        // Param
        List<IF_KDCE_API_BizBase.T_Product> tProducts = inputBody.t_data != null ? inputBody.t_data[0].t_Products : null;

        tProducts = IF_KDCE_API_BizBase.setProductsByMagento(tProducts);
        List<Id> tProductIds = new List<Id>();
        for (IF_KDCE_API_BizBase.T_Product tProduct : tProducts) {
            tProductIds.add(tProduct.Id);
        }

        IF_MG_DCE_0092.OutputData outputData = new IF_MG_DCE_0092.OutputData();
        outputData.productIds = tProductIds;
        outputBody.t_data.add(outputData);
        //대량 인터페이스 분활 처리
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = String.valueOf(tProducts.size()); // 수신 수량(Count) 리턴 필드

        return outputBody;
    }
}