/****************************************************************************************
  * @filename      : KDCE_CouponHistoryTrigger
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-05
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-05          i2max_JE Yoon             Create
****************************************************************************************/
trigger KDCE_CouponHistoryTrigger on KDCE_CouponHistory__c (after insert) {
    new KDCE_CouponHistory_tr().run();
}