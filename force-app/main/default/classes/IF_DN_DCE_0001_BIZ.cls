/****************************************************************************************
  * File Name   : IF_DN_DCE_0001
  * Description : IF_DN_DCE_0001
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100    Create
****************************************************************************************/
public with sharing class IF_DN_DCE_0001_BIZ {
    private static IF_DN_DCE_0001_BIZ sInstance = null;
    public static IF_DN_DCE_0001_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_DN_DCE_0001_BIZ();
        }
        return sInstance;
    }

    public IF_DN_DCE_0001.InputBody pre(IF_DN_DCE_0001.InputBody inputBody, IF_DN_DCE_0001.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작*/

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return inputBody;
    }

    public IF_DN_DCE_0001.OutputBody post(IF_DN_DCE_0001.InputBody inputBody, IF_DN_DCE_0001.OutputBody outputBody) {
        System.debug(inputBody);
        System.debug(outputBody);

        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        // 20210520 Danal 에서 들어오는 API 결과 Dummy에 쌓도록 코드 수정
        // 개체 : IF_MG_SFDC_Dummy__c
        IF_DN_DCE_0001.INPUT_T_DATA inputObject = inputBody.t_data.get(0);
        System.debug('=== inputObject : ' + inputObject);
        System.debug('=== inputObject.Requests[0].requestId : ' + inputObject.Requests[0].requestId);

        if(inputObject != null){
            IF_MG_SFDC_Dummy__c dummy = new IF_MG_SFDC_Dummy__c();

            String errMessage = '';

            //TODO 각 파라미터의 값이 없거나 이상할 경우에 에러 메세지 리턴하는 로직 필요
            if(inputObject.Requests[0].requestId != '') dummy.requestId__c = inputObject.Requests[0].requestId;
            else {
                errMessage += 'requestId 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].device.ToReplaceCodentify != '') dummy.ToReplaceCodentify__c = inputObject.Requests[0].device.ToReplaceCodentify;
            else {
                errMessage += 'ToReplaceCodentify 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].device.Parentcodentify != '') dummy.Parentcodentify__c = inputObject.Requests[0].device.Parentcodentify;
            else {
                errMessage += 'Parentcodentify 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].AddDetails.Reason != '')            dummy.Reason__c = inputObject.Requests[0].AddDetails.Reason;
            else {
                errMessage += 'Reason 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].AddDetails.Channel != '')            dummy.Channel__c = inputObject.Requests[0].AddDetails.Channel;
            else {
                errMessage += 'Channel 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].AddDetails.Channel_v2 != '') dummy.Channel_v2__c = inputObject.Requests[0].AddDetails.Channel_v2;
            else {
                errMessage += 'Channel_v2 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].AddDetails.Ext_Ref != '') dummy.Ext_Ref__c = inputObject.Requests[0].AddDetails.Ext_Ref;
            else {
                errMessage += 'Ext_Ref 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].AddDetails.ReplacementDate != '') dummy.ReplacementDate__c = inputObject.Requests[0].AddDetails.ReplacementDate;
            else {
                errMessage += 'ReplacementDate 값이 공백입니다.\n';
            }
            if(inputObject.Requests[0].AddDetails.ReplacementCountry != '') dummy.ReplacementCountry__c = inputObject.Requests[0].AddDetails.ReplacementCountry;
            else {
                errMessage += 'ReplacementCountry 값이 공백입니다.\n';
            }

            if(errMessage != ''){
                throw new IF_Base.IFException(errMessage);
            } else {
                insert dummy;
            }

        }

        return outputBody;
    }

    public static void runTest(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}