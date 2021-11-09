/****************************************************************************************
  * @filename      : KDCE_ModelProductMapping_tr_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-09
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-07-09             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_ModelProductMapping_tr_ts {
    @IsTest
    static void testBehavior() {
        ModelProductMapping__c item = new ModelProductMapping__c(
                ModelNumber__c  = '00000',
                Color__c        = 'GOLD'
        );
        insert item;
        update item;
    }
}