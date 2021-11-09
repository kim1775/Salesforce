/****************************************************************************************
  * @filename      : KDCE_ContactCaseSummary_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-17 오후 5:08
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
    0.1     2021-06-17 오후 5:08     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_ContactCaseSummary_ts {
    private static Map<String, Id> caseRecordTypeMap = KDCE_Util.getRecordTypeBySObject('Case');
    private final static Id inquiryCriticalRTId = caseRecordTypeMap.get('CCR_InquiryCriticalInquiries');

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        Map<String, Integer> stringIntegerMap = new Map<String, Integer>();
        stringIntegerMap.put('test', 1);

        Contact contact = KDCE_TestUtil.contactMember;
        Case testCase = new Case(
                Subject = 'Test',
                RecordTypeId = inquiryCriticalRTId,
                ContactId = contact.Id
        );
        insert testCase;

        KDCE_ContactCaseSummary.getSummaryInfo(contact.Id);
//        KDCE_ContactCaseSummary.returnInfoWrappers(stringIntegerMap);
    }
}