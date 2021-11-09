/****************************************************************************************
 * @filename      : KDCE_TaskTrigger
 * @projectname   : 
 * @author        : Donghu
 * @date          : 2021/03/09
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
 0.1      2021/03/09                  Donghu          Create
 ****************************************************************************************/
trigger KDCE_TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new KDCE_Task_tr().run();
}