/****************************************************************************************
  * @filename      : KDCE_DropOutContactSoftDeletion_ba_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-18
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
    0.1     2021-06-18             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_DropOutContactSoftDeletion_ba_ts {

    //static Contact cont;

    @TestSetup
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        List<SObject> sObjects = new List<SObject>();
        Contact cont = KDCE_TestUtil.contactProspect.clone(false);
        cont.KDCE_LastLoginDate__c = System.today().addMonths(-13);
        cont.Email = 'test@test.net';
        cont.Phone = '01098765432';
        cont.LastName = 'contTest';
        insert cont;

        Case ca = KDCE_TestUtil.caseItem.clone(true);
        ca.ContactId = cont.Id;
        ca.Status = KDCE_GlobalValue.CASE_STATUS_CLOSED;
        Test.setCreatedDate(ca.Id, System.today().addMonths(-15));
        sObjects.add(ca);


        KDCE_Order__c order = KDCE_TestBizUtil.order.clone(true);
        order.Contact__c = cont.Id;
        order.OrderStatus__c = KDCE_GlobalValue.ORDER_STATUS_CLOSE;
        sObjects.add(order);

        KDCE_OfflineProgram__c offline = KDCE_TestBizUtil.offlineProgram.clone(true);
        offline.Contact__c = cont.Id;
        offline.Status__c = KDCE_GlobalValue.OFF_PG_STATUS_COMPLETE;
        sObjects.add(offline);

        update sObjects;

    }

    @IsTest
    static void testBehavior2() {
        Test.startTest();

        Contact cont = [SELECT Id FROM Contact LIMIT 1];

        cont.KDCE_LastLoginDate__c = System.today().addMonths(-13);
        cont.KDCE_LastCouponUsedDate__c = System.today().addMonths(-13);
        cont.KDCE_LastCaseDate__c = System.today().addMonths(-13);
        cont.KDCE_LastCloseDate__c = System.today().addMonths(-13);
        cont.KDCE_LastCRMResponseDate__c = System.today().addMonths(-13);
        cont.KDCE_LastNPSResponseDate__c = System.today().addMonths(-13);
        cont.KDCE_ReactivateDormantDate__c = System.today().addMonths(-13);
        //sObjects.add(cont);
        update cont;

        Database.executeBatch(new KDCE_DropOutContactSoftDeletion_ba(), 200);
        Test.stopTest();
    }
}