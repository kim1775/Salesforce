/****************************************************************************************
  * @filename      : i2SEMA_NotificationGroupList_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-07-14 오후 3:50
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
    0.1     2021-07-14 오후 3:50     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
public with sharing class i2SEMA_NotificationGroupList_ts {

    static {
        i2SEMA_TestDataUtil.getSMSNotification();
    }

    @IsTest
    static void testBehavior() {
        i2SEMA_NotificationGroupList.getNotificationGroups(i2SEMA_TestDataUtil.smsNotification.NotificationGroup__c, 1, 1);
    }
}