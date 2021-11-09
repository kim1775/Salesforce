/****************************************************************************************
  * @filename      : KDCE_DormantDropoutDailyDelOLI_ba_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-21
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
    0.1     2021-06-21             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_DormantDropoutDailyDelOLI_ba_ts {
    @IsTest
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        KDCE_Order__c order = KDCE_TestBizUtil.order.clone(true);
        Contact cont = KDCE_TestUtil.contactMember.clone(true);
        KDCE_DormantOrderLineItem__c dorOli = new KDCE_DormantOrderLineItem__c( CreatedDate__c = System.now().addYears(-6));
        KDCE_DropOutOrderLineItem__c dropOli = new KDCE_DropOutOrderLineItem__c(CreatedDate__c = System.now().addYears(-6), Order__c = order.Id);

        // Order, Offline, Case 데이터 만들기.
        KDCE_DormantOrder__c dorOrder = new KDCE_DormantOrder__c(CreatedDate__c = System.now().addYears(-6), Contact__c = cont.Id);
        KDCE_DropOutOrder__c dropOrder = new KDCE_DropOutOrder__c(CreatedDate__c = System.now().addYears(-6), Contact__c = cont.Id);

        KDCE_DormantOfflineProgram__c dorOff = new KDCE_DormantOfflineProgram__c(CreatedDate__c = System.now().addYears(-6), Contact__c = cont.Id);
        KDCE_DropOutOfflineProgram__c dropOff = new KDCE_DropOutOfflineProgram__c(CreatedDate__c = System.now().addYears(-6), Contact__c = cont.Id);

        KDCE_DormantCase__c dorCase = new KDCE_DormantCase__c(CreatedDate__c = System.now().addYears(-6), ContactId__c = cont.Id);
        KDCE_DropOutCase__c dropCase = new KDCE_DropOutCase__c(CreatedDate__c = System.now().addYears(-6), ContactId__c = cont.Id);

        KDCE_DropOutContact__c dropCont = new KDCE_DropOutContact__c(ContactId__c = cont.Id, KDCE_DeleteCheckTarget__c = true);
        List<SObject> sObjects = new List<SObject>{dorOli, dropOli, dorOrder, dropOrder, dorOff, dropOff, dorCase, dropCase, dropCont  };
        insert sObjects;

        Database.executeBatch(new KDCE_DormantDropoutDailyDelOLI_ba(KDCE_DormantDropoutDailyDelOLI_ba.getDeleteSObject()), 200);
    }
}