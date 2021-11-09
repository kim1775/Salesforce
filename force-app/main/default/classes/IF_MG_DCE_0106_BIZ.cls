/****************************************************************************************
  * File Name   : IF_MG_DCE_0106
  * Description : IF_MG_DCE_0106
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.04  ldb3100    Create
    1.1  2021.03.16 i2max_Sukun Update
****************************************************************************************/
public with sharing class IF_MG_DCE_0106_BIZ {
    private static IF_MG_DCE_0106_BIZ sInstance = null;
    public static IF_MG_DCE_0106_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_MG_DCE_0106_BIZ();
        }
        return sInstance;
    }

    public IF_MG_DCE_0106.InputBody pre(IF_MG_DCE_0106.InputBody inputBody, IF_MG_DCE_0106.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_MG_DCE_0106.OutputBody post(IF_MG_DCE_0106.InputBody inputBody, IF_MG_DCE_0106.OutputBody outputBody) {

        // Param
        List<IF_KDCE_API_BizBase.T_Asset> tAssets = inputBody.t_data != null ? inputBody.t_data[0].t_Assets : null;

        tAssets = IF_KDCE_API_BizBase.setAssets(tAssets);
        List<Id> tAssetIds = new List<Id>();
        String JobResult = '0000';
        for (IF_KDCE_API_BizBase.T_Asset tAsset : tAssets) {
            System.debug('=== tAsset : ' + tAsset);
            if (!tAssetIds.contains(tAsset.Id)) tAssetIds.add(tAsset.Id);
            if (tAsset.JobResult != null && tAsset.JobResult != '') JobResult = tAsset.JobResult;
        }

        IF_MG_DCE_0106.OutputData outputData = new IF_MG_DCE_0106.OutputData();
        outputData.assetIds = tAssetIds;
        outputData.JobResult = JobResult;
        outputBody.t_data.add(outputData);
        //대량 인터페이스 분활 처리
        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = String.valueOf(inputBody.t_data.size()); // 수신 수량(Count) 리턴 필드

        return outputBody;
    }
}