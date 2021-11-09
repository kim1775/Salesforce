/****************************************************************************************
  * @filename      : IF_XP_SFDC_001Trigger
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-23
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-23          i2max_JE Yoon             Create
****************************************************************************************/
trigger IF_XP_SFDC_001Trigger on IF_XP_SFDC_001__c (before insert) {
    new IF_XP_SFDC_001_tr().run();
}