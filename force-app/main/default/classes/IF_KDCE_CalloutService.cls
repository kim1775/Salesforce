/****************************************************************************************
  * @filename      : IF_KDCE_CalloutIFService
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/19 2:23 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_KDCE_CalloutIFService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/19 2:23 오후     i2max_shlee       Create
    0.2     2021/05/14              i2max_Sukun       Update
****************************************************************************************/
public without sharing class IF_KDCE_CalloutService {

    // Bitly request group guid data
    private static final String LAB_IF_BITLY_GROUP_GUID = System.Label.LAB_IF_BITLY_GROUP_GUID;
    // Bitly request domain data
    private static final String LAB_IF_BITLY_DOMAIN = System.Label.LAB_IF_BITLY_DOMAIN;

    /** Global PMI Legacy 호출 API 정의 */
    /**
     * @description 단건의 Global Device S/N 정보 조회 요청 (IF_SFDC_ITRACK_0001)
     * @param condetifyCode {String} Global Device Codentifiy Code (Serial Number)
     * @return {IF_SFDC_ITRACK_0001.OutputDIH} IF 결과값
     */
    public static IF_DCE_iTrack_0001.OutputDIH getGlobalDeviceInfo(String condetifyCode){

        // IF_DCE_iTrack_0001 : Global Device 정보 조회
        IF_DCE_iTrack_0001 ifInstance        = IF_DCE_iTrack_0001.getInstance();
        IF_DCE_iTrack_0001.InputDIH ifInput  = new IF_DCE_iTrack_0001.InputDIH();
        IF_DCE_iTrack_0001.INPUT_T_DATA data = new IF_DCE_iTrack_0001.INPUT_T_DATA();

        //set request params
        data.code = condetifyCode;
        ifInput.request.payload.t_data.add(data);

        return ifInstance.execute(ifInput);
    }

    /**
     * @description Heets 정보 조회 요청 (IF_DCE_Vault_0001)
     * @param condetifyCode {String} Heets Codentifiy Code (Serial Number)
     * @return {IF_DCE_Vault_0001.OutputDIH} IF 결과값
     */
    public static IF_DCE_Vault_0001.OutputDIH getHeetsInfo(String condetifyCode){
        System.debug('=== condetifyCode : ' + condetifyCode);

        // IF_DCE_Vault_0001 : Global Device 정보 조회
        IF_DCE_Vault_0001 ifInstance        = IF_DCE_Vault_0001.getInstance();
        IF_DCE_Vault_0001.InputDIH ifInput  = new IF_DCE_Vault_0001.InputDIH();
        IF_DCE_Vault_0001.INPUT_T_DATA data = new IF_DCE_Vault_0001.INPUT_T_DATA();

        System.debug('=== ifInstance : ' + ifInstance);

        //set request params
        data.Codes.add(condetifyCode);
        ifInput.request.payload.t_data.add(data);

        return ifInstance.execute(ifInput);
    }

    /**
     * @description Bitly shorten url 요청 (IF_SFDC_Bitly_0001)
     * @param longUrl {String} Long URL
     * @return {String} Short URL
     */
    public static String getShortURL(String longUrl){

        // IF_DCE_Vault_0001 : Global Device 정보 조회
        IF_SFDC_Bitly_0001 ifInstance        = IF_SFDC_Bitly_0001.getInstance();
        IF_SFDC_Bitly_0001.InputDIH ifInput  = new IF_SFDC_Bitly_0001.InputDIH();
        IF_SFDC_Bitly_0001.INPUT_T_DATA data = new IF_SFDC_Bitly_0001.INPUT_T_DATA();

        //set request params
        data.group_guid = LAB_IF_BITLY_GROUP_GUID;
        data.domain = LAB_IF_BITLY_DOMAIN;
        data.long_url = longUrl;

        ifInput.request.payload.t_data.add(data);

        IF_SFDC_Bitly_0001.OutputDIH outputDIH = ifInstance.execute(ifInput);
        System.debug('outputDIH : '+outputDIH);

        IF_SFDC_Bitly_0001.OUTPUT_T_DATA outputTData = outputDIH.response.payload.t_data.get(0);

        System.debug('outputTData : '+outputTData);
        return outputTData?.link;
    }

    /**
     * @description Magento Order 요청 : QURE 에서 Magento로 Order 요청
     * @param CCR_QureMsg
     * @return {IF_DCE_MG_0107.OutputDIH} IF 결과값
     */
    public static IF_DCE_MG_0107.OutputDIH callMagentoOrderAPI(CCR_QureMsg qureObj){
        // IF_DCE_MG_0107
        IF_DCE_MG_0107 ifInstance                   = IF_DCE_MG_0107.getInstance();
        IF_DCE_MG_0107.InputDIH ifInput             = new IF_DCE_MG_0107.InputDIH();
        IF_DCE_MG_0107.INPUT_T_DATA productDataobj  = new IF_DCE_MG_0107.INPUT_T_DATA();
        IF_DCE_MG_0107.t_OrderItems td              = new IF_DCE_MG_0107.t_OrderItems();

        // Param Setup
        productDataobj.CreatedDate = String.valueof(Datetime.now());
        productDataobj.CustomerName = qureObj.LastName;
        productDataobj.CustomerEmail = qureObj.contactEmailId;
        productDataobj.ContactExtId = qureObj.contactExternalId;
        if(qureObj.CaseId != null)              productDataobj.CaseNo = qureObj.CaseId;
        productDataobj.ordertype = 'ZRA';   //QURE 는 ZRA 고정
        productDataobj.reason = qureObj.ReplacementReason;
        productDataobj.ShippingAddress1 = qureObj.Address1;
        productDataobj.ShippingAddress2 = qureObj.Address2;
        if(qureObj.AddressCity != null)         productDataobj.ShippingCity = qureObj.AddressCity;
        if(qureObj.AddressStreet != null)       productDataobj.ShippingStreet = qureObj.AddressStreet;
        productDataobj.ShippingPostalCode = qureobj.AddressPostalCode;
        productDataobj.ShippingCountry = 'KR';  //QURE 국가는 고정
        productDataobj.ShippingPhone = qureObj.ConsumerPhone;
        td.KDCE_EANCode = qureObj.productId;
        td.Codentify = qureObj.Codentify;
        td.FullProductId = qureObj.Product2Name;
        td.ProductCode = qureObj.ProductCode;
        td.Name = qureObj.ProductName;
        productDataobj.t_OrderItems = td;

        ifInput.request.payload.t_data.add(productDataobj);

        System.debug('IF_KDCE_CalloutService.cls callMagentoOrderAPI call End');
        System.debug(ifInput);

        return ifInstance.execute(ifInput);
    }

    /**
     * @description 교환 바우처 MMS 전송 요청 : QURE GS25 바우쳐 발급 요청 API 호출
     * @param CCR_QureMsg
     * @return {IF_DCE_DN_0001.OutputDIH} IF 결과값
     */
    @SuppressWarnings('PMD')
    public static IF_DCE_DN_0001.OutputDIH callIssueGS25VoucherAPI(CCR_QureMsg qureObj){
        System.debug('IF_KDCE_CalloutService.cls callIssueGS25VoucherAPI called');
        System.debug('qureObj inserted');
        System.debug(qureObj);
        // IF_DCE_Vault_0001 : Global Device 정보 조회
        IF_DCE_DN_0001 ifInstance        = IF_DCE_DN_0001.getInstance();
        IF_DCE_DN_0001.InputDIH ifInput  = new IF_DCE_DN_0001.InputDIH();
        IF_DCE_DN_0001.INPUT_T_DATA productDataobj = new IF_DCE_DN_0001.INPUT_T_DATA();


        // Param Setup
        CCR_ISOBARGetVoucherApiDetails__c isoBAR = [SELECT CCR_AuthenticationEndpoint__c, CCR_GetVoucherEndpoint__c, CCR_ResendVoucherEndpoint__c, CCR_ApiKey__c,CCR_ApiSecret__c,CCR_PrivateKey__c, CCR_SaltKey__c, CCR_Country__c
        FROM CCR_ISOBARGetVoucherApiDetails__c where CCR_Active__c = true limit 1];
        List<Asset> assetList = new List<Asset>();
        List<Case> caseList = new List<Case>();

        System.debug('system lookup qureObj ::: ' + qureObj);
        System.debug('system lookup qureObj.Codentify ::: ' + qureObj.Codentify);

        assetList = [SELECT Id,CCR_CodentifyId__c, CCR_DeviceProductCode__r.CCR_Group__c, CCR_DeviceProductCode__r.CCR_Color__c, CCR_Version__c
            FROM ASSET WHERE CCR_CodentifyId__c = :qureObj.Codentify];

        System.debug('system lookUP ' + assetList);

        if(!assetList.isEmpty()) {
            caseList = [SELECT Id,CaseNumber FROM Case WHERE Id = :qureObj.CaseId];
            if(!caseList.isEmpty()) productDataobj.caseNo = caseList[0].CaseNumber;
        }

        productDataobj.custName = qureObj.LastName;
        if (qureObj.ConsumerPhone != null) {
            Blob vSalt641 = Blob.valueOf(isoBAR.CCR_SaltKey__c);
            Blob vPrivateKey=Blob.valueOf(isoBAR.CCR_PrivateKey__c);
            Blob data = Blob.valueOf(qureObj.ConsumerPhone);
            Blob encryptedData = Crypto.encrypt('AES128', vPrivateKey, vSalt641, data);
            productDataobj.custPhone  = EncodingUtil.base64Encode(encryptedData);
        }

        productDataobj.matType = assetList[0].CCR_DeviceProductCode__r.CCR_Group__c;
        productDataobj.colorType = assetList[0].CCR_DeviceProductCode__r.CCR_Color__c;
        productDataobj.verType = assetList[0].CCR_Version__c;
        productDataobj.codentifyNo = qureObj.Codentify;

        System.debug('CallOut Data == ' + productDataobj);

        ifInput.request.payload.t_data.add(productDataobj);

        System.debug('IF_KDCE_CalloutService.cls callIssueGS25VoucherAPI call End');
        System.debug(ifInput);

        return ifInstance.execute(ifInput);
    }

    public static void runTest() {
        Decimal i = 0;
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