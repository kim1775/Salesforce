/****************************************************************************************
  * @filename      : IF_MG_SFDC_Dummy_tr_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-05-24
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
    0.1     2021-05-24             Park HE         Create
****************************************************************************************/

@IsTest
private class IF_MG_SFDC_Dummy_tr_ts {
    @IsTest
    static void testBehavior() {

        Asset oldAsset = KDCE_TestUtil.assetCharger.clone(true);
        oldAsset.ContactId = KDCE_TestUtil.contactMember.Id;
        update oldAsset;

        IF_MG_SFDC_Dummy__c dummy = new IF_MG_SFDC_Dummy__c(
                Parentcodentify__c = KDCE_TestUtil.assetHolder.SerialNumber,
                ToReplaceCodentify__c = oldAsset.CCR_CodentifyId__c
        );
        insert dummy;

        IF_MG_SFDC_Dummy__c dummy2 = new IF_MG_SFDC_Dummy__c(
                Parentcodentify__c = 'testCodentify',
                ToReplaceCodentify__c = oldAsset.CCR_CodentifyId__c
        );
        insert dummy2;
    }
}