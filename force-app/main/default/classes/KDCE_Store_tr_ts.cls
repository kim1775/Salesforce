/****************************************************************************************
 * @filename      : KDCE_Store_tr_ts
 * @projectname   : 
 * @author        : i2max_SeokHo
 * @date          : 2021-03-26 오전 9:35
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
 0.1     2021-03-26 오전 9:35      i2max_SeokHo         Create
 ****************************************************************************************/

@isTest
private class KDCE_Store_tr_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }
    @IsTest
    static void testBehavior() {
        Id RT_Store_Direct = Schema.SObjectType.KDCE_Store__c.getRecordTypeInfosByDeveloperName().get('Store_Direct').getRecordTypeId();

        List<KDCE_Store__c> stores = new List<KDCE_Store__c>();
        KDCE_Store__c newStore = new KDCE_Store__c();
        newStore.Name = 'Test';
        newStore.RecordTypeId = RT_Store_Direct;
        KDCE_Store__c newStore2 = newStore.clone();
        newStore2.Name = 'Test2';
        stores.add(newStore);
        stores.add(newStore2);
        insert stores;

    }
}