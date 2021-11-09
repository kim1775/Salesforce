/****************************************************************************************
 * @filename      : KDCE_TnCVersionSetTrigger
 * @projectname   : PMK Local DCE
 * @author        : i2max_Sukun
 * @date          : 4/6/21 3:21 PM
 * @group         : Service
 * @group-content :
 * @description   : Terms and Conditions Version Set: version management related trigger
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     4/6/21 3:21 PM            i2max_Sukun           Create
 ****************************************************************************************/
trigger KDCE_TnCVersionSetTrigger on KDCE_TnCVersionSet__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new KDCE_TnCVersionSet_tr().run();
}