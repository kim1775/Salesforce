/****************************************************************************************
  * @filename      : KDCE_AssetLifeCycleTrigger
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-03-03 오후 4:02
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
    0.1     2021-03-03 오후 4:02     i2max_Jihyun.Lee        Create
****************************************************************************************/

trigger KDCE_AssetLifeCycleTrigger on CCR_AssetLifeCycle__c (after insert) {
    new KDCE_AssetLifeCycle_tr().run();
}