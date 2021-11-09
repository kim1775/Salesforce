/****************************************************************************************
  * @filename      : IF_KDCE_API_BizService_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-07-02 오후 6:28
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-07-02 오후 6:28     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class IF_KDCE_API_BizService_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehaviorProduct() {
        List<IF_KDCE_API_BizBase.T_Product> tProducts = new List<IF_KDCE_API_BizBase.T_Product>();
        IF_KDCE_API_BizBase.T_Product tProduct = new IF_KDCE_API_BizBase.T_Product();
        tProduct.Name = 'productCodeTest';
        tProduct.ProductCode = 'productCodeTest';
        tProduct.CCR_Category = 'M0401';
        tProduct.CCR_OriginalDesignMarket = 'RU04';
        tProduct.CCR_Version = '3.0M';
        tProduct.KDCE_EANCode = 'eanCode';
        tProducts.add(tProduct);
        IF_KDCE_API_BizService.setProductsByPOS(tProducts);
        IF_KDCE_API_BizService.getConsumerRecordTypeId('Anonymous');
        IF_KDCE_API_BizService.getConsumerRecordTypeId('Prospect');
        IF_KDCE_API_BizService.getConsumerRecordTypeId('Member');
    }
}