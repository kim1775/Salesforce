/****************************************************************************************
 * @filename      : ChatterService_ts
 * @projectname   : 
 * @author        : i2max_SeokHo
 * @date          : 2021-03-30 오후 4:52
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
 0.1     2021-03-30 오후 4:52      i2max_SeokHo         Create
 ****************************************************************************************/

@isTest
private class ChatterService_ts {
    @isTest
    static void testBehavior() {
        String targetRecordId = UserInfo.getUserId();

        ChatterService.simpleChatterFeed(null, targetRecordId, 'test', new Set<String>{ targetRecordId });
        ChatterService.simpleChatterFeed(null, new Set<String>{ targetRecordId }, 'test');
    }
}