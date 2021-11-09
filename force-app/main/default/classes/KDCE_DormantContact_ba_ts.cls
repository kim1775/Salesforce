/****************************************************************************************
  * @filename      : KDCE_DormantContact_ba_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-14 오후 2:12
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
    0.1     2021-06-14 오후 2:12     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
public class KDCE_DormantContact_ba_ts {

    @IsTest
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        Datetime dt = System.now().addYears(-2);

        Contact con = KDCE_TestUtil.contactMember.clone(true);
        con.KDCE_PersonalInfoValidityPeriod__c = '1y';
        con.KDCE_LastCouponUsedDate__c = dt;
        con.KDCE_LastCaseDate__c = dt;
        con.KDCE_LastCloseDate__c = dt;
        con.KDCE_LastCRMResponseDate__c = dt;
        con.KDCE_LastNPSResponseDate__c = dt ;
        update con;

        System.debug(con.KDCE_fm_IsTargetDormant__c);

        Test.startTest();
        KDCE_DormantContact_ba batch = new KDCE_DormantContact_ba();
        Database.executeBatch(batch, 2000);
        Test.stopTest();

    }
}