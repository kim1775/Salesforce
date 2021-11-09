/****************************************************************************************
 * @filename      : KDCE_TnCVersionTrigger
 * @projectname   : PMK Local DCE
 * @author        : i2max_Sukun
 * @date          : 4/6/21 3:20 PM
 * @group         : Service
 * @group-content :
 * @description   : Terms and Conditions Version: version management related trigger
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     4/6/21 3:20 PM            i2max_Sukun           Create
 ****************************************************************************************/
trigger KDCE_TnCVersionTrigger on KDCE_TnCVersion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new KDCE_TnCVersion_tr().run();
}