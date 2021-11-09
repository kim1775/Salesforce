/****************************************************************************************
  * @filename      : KDCE_Util_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-07
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
    0.1     2021-07-07             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_Util_ts {
    @IsTest
    static void testBehavior() {
        KDCE_Util.getShortKrState('서울');
        KDCE_Util.getRecordTypeNameBySObject('Contact');
        KDCE_Util.getRecordNameBySObject('Contact');
        KDCE_Util.getRecordDeveloperNameBySObject('Contact');
        KDCE_Util.getSObjectByName('Contact');
        KDCE_Util.ddmmyyyyhmsToDate('17/12/2020 17:51:00.0000000');
        KDCE_Util.findObjectNameFromRecordIdPrefix('003');
        KDCE_Util.getFieldLabel('Contact', 'LastName');


    }
}