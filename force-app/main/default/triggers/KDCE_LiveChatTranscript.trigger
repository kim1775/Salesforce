/****************************************************************************************
 * @filename      : KDCE_LiveChatTranscript
 * @projectname   : 
 * @author        : Donghu
 * @date          : 2021-03-16
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
 0.1      2021-03-16                  Donghu          Create
 ****************************************************************************************/
trigger KDCE_LiveChatTranscript on LiveChatTranscript (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new KDCE_LiveChatTranscript_tr().run();
}