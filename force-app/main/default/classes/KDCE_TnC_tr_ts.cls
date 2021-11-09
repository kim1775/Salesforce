/****************************************************************************************
  * @filename      : KDCE_TnC_tr_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-15 오후 3:07
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
    0.1     2021-06-15 오후 3:07     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_TnC_tr_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    private static void testBehavior() {

        // KDCE_TermsandConditions_tr를 위한
        TermsandConditions__c tnC = [
                SELECT Id, KDCE_VersionName__c, KDCE_VersionNumber__c, KDCE_SubGroup__c, KDCE_Active__c
                FROM TermsandConditions__c
                WHERE Id = :KDCE_TestBizUtil.tnC.Id
        ];

        TermsandConditions__c newTnC = tnC.clone(false, true);
//        newTnC.KDCE_SubGroup__c = 'PMPO';
        insert newTnC;
    }

    @IsTest
    private static void testBehaviorTnCVersion() {
        System.debug('@@ testBehaviorTnCVersion @@');

        List<KDCE_TnCVersion__c> tnCVersions = new List<KDCE_TnCVersion__c>();
        KDCE_TnCVersion__c tnCVersion = KDCE_TestBizUtil.tnCVersion;
        KDCE_TnCVersion__c tnCVersion2 = tnCVersion.clone(false, true);
        KDCE_TnCVersion__c tnCVersion3 = tnCVersion.clone(false, true);
        tnCVersions.add(tnCVersion2);
        tnCVersions.add(tnCVersion3);

        String errorMessage;
        Test.startTest();
        try {
            List<Database.SaveResult> result = Database.insert(tnCVersions, false);
        } catch (DmlException error) {
            errorMessage = error.getMessage();
        }
        Test.stopTest();
//        System.assertEquals(null, System.Label.KDCE_InvalidCreateMultipleRecord, errorMessage);

    }

    @IsTest
    private static void testBehaviorTnCVersionSet() {

        List<KDCE_TnCVersion__c> tnCVersions = new List<KDCE_TnCVersion__c>();
        KDCE_TnCVersion__c tnCVersion = KDCE_TestBizUtil.tnCVersion;

        KDCE_TnCVersionSet__c tnCVersionSet = KDCE_TestBizUtil.tnCVersionSet;

        KDCE_TnCVersionSet__c newTnCVersionSet = tnCVersionSet.clone(false, true);
        Database.insert(newTnCVersionSet, false);
        update tnCVersionSet;

    }

    @IsTest
    private static void testBehaviorTnCAccepted() {
        KDCE_TnCAccepted__c tnCAccepted = KDCE_TestBizUtil.tnCAccepted;
        tnCAccepted.Accepted__c = false;
        update tnCAccepted;
    }
}