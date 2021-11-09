/****************************************************************************************
  * @filename      : KDCE_QualtricsResponse_tr_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-28
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
    0.1     2021-07-28             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_QualtricsResponse_tr_ts {
    @IsTest
    static void testBehavior() {
        Contact con = KDCE_TestUtil.contactMember;
        con.KDCE_ExternalId__c = 'testexternal';
        update con;
        KDCE_QualtricsResponse__c q1 = new KDCE_QualtricsResponse__c(Consumer_ID__c = con.KDCE_ExternalId__c,
                response_id__c = 'test', recordeddate__c = '2021-08-11T16:35:17.379Z');
        KDCE_QualtricsResponse__c q2 = new KDCE_QualtricsResponse__c(Consumer_ID__c = con.KDCE_ExternalId__c,
                response_id__c = 'test', recordeddate__c = '2021-08-10T16:35:17.379Z');
        List<KDCE_QualtricsResponse__c> qlist = new List<KDCE_QualtricsResponse__c>{q1, q2};
        insert qlist;
        update qlist;
    }
}