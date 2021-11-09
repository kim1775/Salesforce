/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-03-24 오후 12:57
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
    0.1     2021-03-24 오후 12:57     i2max_Junseok.Kwon        Create
****************************************************************************************/

trigger KDCE_AssetTrigger on Asset (before insert, before update, before delete, after insert, after update, after delete) {
    new KDCE_Asset_tr().run();
}