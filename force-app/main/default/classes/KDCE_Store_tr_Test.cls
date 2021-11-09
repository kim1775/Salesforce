/****************************************************************************************
  * @filename      : KDCE_Store_tr_Test
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-27 오후 2:33
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
    0.1     2021-04-27 오후 2:33     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
public class KDCE_Store_tr_Test {
    @IsTest
    static void testBehavior() {
        KDCE_Store__c store = KDCE_TestBizUtil.getStore();
    }
}