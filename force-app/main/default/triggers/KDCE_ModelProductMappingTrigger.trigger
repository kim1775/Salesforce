/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-06-14 오전 9:21
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
    0.1     2021-06-14 오전 9:21     i2max_Junseok.Kwon        Create
****************************************************************************************/

trigger KDCE_ModelProductMappingTrigger on ModelProductMapping__c (before insert, before update) {
    new KDCE_ModelProductMapping_tr().run();
}