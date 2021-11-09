/****************************************************************************************
  * @filename      : KDCE_OfflineProgramTrigger
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-12 오후 1:45
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
    0.1     2021-04-12 오후 1:45     i2max_Jihyun.Lee        Create
****************************************************************************************/

trigger KDCE_OfflineProgramTrigger on KDCE_OfflineProgram__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new KDCE_OfflineProgram_tr().run();
}