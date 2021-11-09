/****************************************************************************************
 * @filename      : KDCE_StoreTrigger
 * @projectname   : 
 * @author        : i2max_SeokHo
 * @date          : 2021-03-03 오후 1:32
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2021-03-03 오후 1:32      i2max_SeokHo         Create
 ****************************************************************************************/

trigger KDCE_StoreTrigger on KDCE_Store__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new KDCE_Store_tr().run();
}