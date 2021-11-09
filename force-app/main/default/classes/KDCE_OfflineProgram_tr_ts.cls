/****************************************************************************************
  * @filename      : KDCE_OfflineProgram_tr_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-05-17 오전 9:38
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
    0.1     2021-05-17 오전 9:38     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_OfflineProgram_tr_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior01() {
        KDCE_OfflineProgram__c op = KDCE_TestBizUtil.offlineProgram;
        op.Status__c = 'Cancel';
        op.ProgramType__c = 'ZTI';
        op.CancelDate__c = System.today();
        update op;
    }

    @IsTest
    static void testBehavior02() {
        KDCE_OfflineProgram__c op = KDCE_TestBizUtil.offlineProgram;
        op.Status__c = 'Rental Process';
        op.CancelDate__c = System.today();
        update op;
    }

    @IsTest
    static void testBehavior03() {
        KDCE_OfflineProgram__c op = KDCE_TestBizUtil.offlineProgram;
        //op.Status__c = 'Rental Purchase';
        update op;
    }

    @IsTest
    static void testBehavior04() {
        KDCE_OfflineProgram__c op = new KDCE_OfflineProgram__c();
        op.Contact__c = KDCE_TestUtil.getContactMember().Id;
        op.ProgramType__c = 'ZRN';
        op.Status__c = 'Rental Process';
        op.NewHolder__c = KDCE_TestUtil.assetHolder.Id;
        op.NewCharger__c = KDCE_TestUtil.assetCharger.Id;
        insert op;

        op.CancelDate__c = System.today();
        op.Status__c = 'Rental Cancel';
        update op;
    }
}