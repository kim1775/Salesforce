/****************************************************************************************
  * @filename      : KDCE_ContactTrigger
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-02-25 오전 8:58
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
    0.1     2021-02-25 오전 8:58     i2max_Jihyun.Lee        Create
****************************************************************************************/

trigger KDCE_ContactTrigger on Contact (before insert, before update, before delete, after insert, after update) {
    new KDCE_Contact_tr().run();
}