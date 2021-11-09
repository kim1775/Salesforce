/****************************************************************************************
 * @filename      : KDCE_TnCAcceptedTrigger
 * @projectname   : PMK Local DCE
 * @author        : i2max_Sukun
 * @date          : 5/11/21 10:49 AM
 * @group         : Service
 * @group-content :
 * @description   : TnC Accepted Trigger
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     5/11/21 10:49 AM            i2max_Sukun           Create
 ****************************************************************************************/
trigger KDCE_TnCAcceptedTrigger on KDCE_TnCAccepted__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new KDCE_TnCAccepted_tr().run();
    new KDCE_TnCAccepted_tr().run();
}