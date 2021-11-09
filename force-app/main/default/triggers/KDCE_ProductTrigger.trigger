/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-05-10 오후 2:12
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
    0.1     2021-05-10 오후 2:12     i2max_Junseok.Kwon        Create
****************************************************************************************/

trigger KDCE_ProductTrigger on Product2 (before insert, before update) {

    new KDCE_Product_tr().run();

}