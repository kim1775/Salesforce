/****************************************************************************************
  * @filename      : IF_KDCE_CalloutIFController
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/19 2:23 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_KDCE_CalloutIFController_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/19 2:23 오후     i2max_shlee       Create
    0.2     2021/02/23          i2max_Sukun           Update (InterfaceService -> CalloutService로 dependency injection 변경하였습니다)
****************************************************************************************/
public with sharing class IF_KDCE_CalloutController {

    /** Global PMI Legacy 호출 API 정의 */
    /**
     * @description 단건의 Global Device S/N 정보 조회 요청 (IF_DCE_iTrack_0001)
     * @param condetifyCode {String} Global Device Codentifiy Code (Serial Number)
     * @return {IF_DCE_iTrack_0001.OutputDIH} IF 결과값
     *
     * IF_KDCE_InterfaceController.getGlobalDeviceInfo('condetifyCode');
     */
    public static IF_DCE_iTrack_0001.OutputDIH getGlobalDeviceInfo(String condetifyCode){
        return IF_KDCE_CalloutService.getGlobalDeviceInfo(condetifyCode);
    }

    /**
     * @description Heets 정보 조회 요청 (IF_DCE_Vault_0001)
     * @param condetifyCode {String} Heets Codentifiy Code (Serial Number)
     * @return {IF_DCE_Vault_0001.OutputDIH} IF 결과값
     */
    public static IF_DCE_Vault_0001.OutputDIH getHeetsInfo(String condetifyCode){
        System.debug('=== condetifyCode : ' + condetifyCode);
        return IF_KDCE_CalloutService.getHeetsInfo(condetifyCode);
    }

    /**
     * @description Bitly shorten url 요청 (IF_SFDC_Bitly_0001)
     * @param longUrl {String} Long URL
     * @return {String} Short URL
     */
    public static String getShortURL(String longUrl){
        return IF_KDCE_CalloutService.getShortURL(longUrl);
    }
    /**
     * @description 교환 바우처 MMS 전송 요청 : QURE GS25 바우쳐 발급 요청 API 호출
     * @param CCR_QureMsg
     * @return {IF_DCE_DN_0001.OutputDIH} IF 결과값
     */
    public static IF_DCE_DN_0001.OutputDIH callIssueGS25VoucherAPI(CCR_QureMsg qureMsg){
        return IF_KDCE_CalloutService.callIssueGS25VoucherAPI(qureMsg);
    }

    /**
     * @description Magento Order 요청 : QURE 에서 Magento로 Order 요청
     * @param CCR_QureMsg
     * @return {IF_DCE_MG_0107.OutputDIH} IF 결과값
     */
    public static IF_DCE_MG_0107.OutputDIH callMagentoOrderAPI(CCR_QureMsg qureMsg){
        return IF_KDCE_CalloutService.callMagentoOrderAPI(qureMsg);
    }

}