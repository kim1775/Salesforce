/****************************************************************************************
  * @filename      : KDCE_SurveyTakenTrigger
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-05-06 오후 2:34
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
    0.1     2021-05-06 오후 2:34     i2max_Jihyun.Lee        Create
****************************************************************************************/

trigger KDCE_SurveyTakenTrigger on SurveyTaker__c (before insert, before update, after insert, after update) {
    new KDCE_SurveyTaken_tr().run();
}