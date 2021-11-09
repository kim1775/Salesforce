/****************************************************************************************
  * @filename      : KDCE_RestoreContactController_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-18 오후 5:21
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
    0.1     2021-06-18 오후 5:21     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_RestoreContactController_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior(){
        KDCE_DormantContact__c dormantContact = new KDCE_DormantContact__c();
        dormantContact.ContactId__c = KDCE_TestUtil.contactMember.Id;
        insert dormantContact;

        KDCE_RestoreContactController.convertDormant(dormantContact.Id);
    }
}