/****************************************************************************************
  * @filename      : KDCE_Product_tr_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-17 오후 2:10
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
    0.1     2021-06-17 오후 2:10     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_Product_tr_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        Product2 prod = KDCE_TestUtil.product;
        update prod;
    }
}