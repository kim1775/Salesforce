/****************************************************************************************
  * @filename      : KDCE_ResetDCIssueCount_ba_Test
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-31
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-31          i2max_JE Yoon             Create
****************************************************************************************/
@IsTest
private class KDCE_ResetDCIssueCount_ba_Test {
    static String developerName_Coupon_CVS = 'Coupon_CVS';

    @TestSetup
    static void setData() {
        CouponTestDataUtil.getCoupon(developerName_Coupon_CVS, 'Produce');
    }

    @IsTest
    static void testCase01() {

        Test.startTest();

        String lastName = developerName_Coupon_CVS+0;
        List<KDCE_Coupon__c> coupons = [SELECT Id, Status__c, Contact__c FROM KDCE_Coupon__c LIMIT 1];
        //List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE KDCE_Name__c = :lastName LIMIT 1];
        Contact con = [SELECT Id, LastName FROM Contact LIMIT 1];
        con.KDCE_DCIssueCount__c = 3;
        coupons[0].Status__c = 'Issue';
        coupons[0].Contact__c = con.Id;

        update con;
        update coupons;

        String CRON_EXP = '0 0 0 3 9 ? 2022';

        String jobId = System.schedule('ResetDCIssueCount_sc', CRON_EXP, new KDCE_ResetDCIssueCount_sc());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE  Id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        //System.assertNotEquals(0, [SELECT Id, KDCE_DCIssueCount__c FROM Contact WHERE Id = :con.Id].KDCE_DCIssueCount__c);

        Test.stopTest();

    }
}