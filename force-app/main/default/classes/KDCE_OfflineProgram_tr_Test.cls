/****************************************************************************************
  * @filename      : KDCE_OfflineProgram_tr_Test
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-27 오후 3:59
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
    0.1     2021-04-27 오후 3:59     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
public class KDCE_OfflineProgram_tr_Test {

    @IsTest
    static void testBehavior() {
        KDCE_OfflineProgram__c program = KDCE_TestBizUtil.getOfflineProgram();
    }
}