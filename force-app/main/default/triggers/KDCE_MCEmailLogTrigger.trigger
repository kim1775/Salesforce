/****************************************************************************************
  * @filename      : KDCE_MCEmailLogTrigger
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-22 오후 3:11
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
    0.1     2021-06-22 오후 3:11     i2max_Jihyun.Lee        Create
****************************************************************************************/

trigger KDCE_MCEmailLogTrigger on KDCE_MCEmailLog__c (before insert, before update, after insert, after update) {
    new KDCE_MCEmailLog_tr().run();
}