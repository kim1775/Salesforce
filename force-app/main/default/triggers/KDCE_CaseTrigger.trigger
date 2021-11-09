/****************************************************************************************
  * @filename      : KDCE_CaseTrigger
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-03-03 오후 3:32
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
    0.1     2021-03-03 오후 3:32     i2max_Jihyun.Lee        Create
****************************************************************************************/

trigger KDCE_CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new KDCE_Case_tr().run();
}