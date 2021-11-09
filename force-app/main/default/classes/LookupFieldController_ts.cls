/****************************************************************************************
  * @filename      : LookupFieldController_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-07-08 오후 4:53
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
    0.1     2021-07-08 오후 4:53     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class LookupFieldController_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }
    static String objectName = 'Contact';
    static List<String> returnFields = new List<String>{'LastName','FirstName','KDCE_PhoneMask__c','KDCE_EmailMask__c'};
    static List<String> queryFields = new List<String>{'FirstName','LastName','KDCE_PhoneMask__c','KDCE_EmailMask__c'};
    static String searchText = 'Contact';
    static String sortColumn = 'LastName';
    static String sortOrder = 'DESC';
    static Integer maxResults = 3;
    static String filter;
    static String searchMethod = 'SOQL';

    @IsTest
    static void testBehavior01() {
        LookupFieldController.GetRecentRecords(objectName, returnFields, maxResults);
    }

    @IsTest
    static void testBehavior02() {
        LookupFieldController.SearchRecordsSOQL(objectName, returnFields, queryFields, searchText, sortColumn, sortOrder, maxResults, filter);
    }

    @IsTest
    static void testBehavior03() {
        LookupFieldController.SearchRecordsSOSL(objectName, returnFields, filter, searchText, sortColumn, sortOrder, maxResults);
    }

    @IsTest
    static void testBehavior04() {
        LookupFieldController.GetRecord(objectName, returnFields, KDCE_TestUtil.getContactMember().Id);
    }

    @IsTest
    static void testBehavior05() {
        LookupFieldController.getObjectDetails(objectName);
        LookupFieldController.getEncryptedFieldsMap();
    }
}