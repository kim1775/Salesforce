/****************************************************************************************
  * @filename      : IF_KDCE_CalloutController_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-28
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-06-28             Park HE         Create
****************************************************************************************/

@IsTest
private class IF_KDCE_CalloutController_ts {
    @IsTest
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
        Asset tempAsset = KDCE_TestUtil.assetHolder.clone();
        CCR_ISOBARGetVoucherApiDetails__c tempISOBAR = new CCR_ISOBARGetVoucherApiDetails__c(
                CCR_Active__c = true,
                Name ='test',
                CCR_SaltKey__c = 'Ame7kBGjV7mDoQUw',
                CCR_PrivateKey__c = 'XT3LEBuUuE81Z0qW');
        insert tempISOBAR;

        CCR_QureMsg qureMsg = new CCR_QureMsg();
        qureMsg.Codentify       = tempAsset.CCR_CodentifyId__c;
        qureMsg.ConsumerPhone   = '01012345678';
        System.debug(qureMsg);


        IF_KDCE_CallOutController.getGlobalDeviceInfo('test');
        IF_KDCE_CallOutController.getHeetsInfo('test');
        //IF_KDCE_CallOutController.getShortURL('tryiqos.kr');
        IF_KDCE_CallOutController.callIssueGS25VoucherAPI(qureMsg);
        IF_KDCE_CallOutController.callMagentoOrderAPI(qureMsg);

//        IF_KDCE_CallOutController.runTest();
        IF_KDCE_CalloutService.runTest();
    }
}