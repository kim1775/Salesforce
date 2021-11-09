/****************************************************************************************
  * @filename      : KDCE_CouponTrigger
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-03
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-03          i2max_JE Yoon             Create
****************************************************************************************/
trigger KDCE_CouponTrigger on KDCE_Coupon__c (before insert, before update, after insert, after update) {

    new KDCE_Coupon_tr().run();

}