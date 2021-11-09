/***********************로*****************************************************************
 * @filename      : KDCE_TermsandConditions_tr
 * @projectname   : PMK Local DCE
 * @author        : i2max_Sukun
 * @date          : 4/5/21 1:05 PM
 * @group         : Service
 * @group-content :
 * @description   : Terms and Conditions Trigger Business Logic Class
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     4/5/21 1:05 PM            i2max_Sukun           Create
 ****************************************************************************************/
public with sharing class KDCE_TermsandConditions_tr extends TriggerHandler {

    public override void beforeInsert() {
        forceSetToNextVersionNumber();
    }

    public override void beforeUpdate() {
//        Make sure there's no newer version of the TNC Master();
    }

    private void forceSetToNextVersionNumber() {
        Map<String, Decimal> versionMap = new Map<String, Decimal>();

        for (TermsandConditions__c tnc : (List<TermsandConditions__c>) Trigger.new) {
            System.debug('=== tnc : ' + tnc);
            versionMap.put(tnc.KDCE_SubGroup__c, tnc.KDCE_VersionNumber__c);
        }

        List<TermsandConditions__c> termsandConditions = [
                SELECT KDCE_VersionName__c, KDCE_VersionNumber__c, KDCE_SubGroup__c FROM TermsandConditions__c
                WHERE KDCE_SubGroup__c IN :versionMap.keyset()
                AND KDCE_Active__c = TRUE
                ORDER BY KDCE_VersionNumber__c DESC
        ];

        if(termsandConditions.size() > 0) {
            for (TermsandConditions__c retrievedTnc : termsandConditions) {
                versionMap.put(retrievedTnc.KDCE_SubGroup__c, retrievedTnc.KDCE_VersionNumber__c + 1);  // SubGroup마다 가장 높은 버전이 최종적으로 Key에 대한 Value 값으 들어갈 것
            }
        }

        String tempType;
        for (TermsandConditions__c tncNewSetting : (List<TermsandConditions__c>) Trigger.new) {
            System.debug('=== tempType : ' + tempType);
            System.debug('=== tncNewSetting : ' + tncNewSetting);
            if(tempType != tncNewSetting.KDCE_SubGroup__c) {
                tempType = tncNewSetting.KDCE_SubGroup__c;
            } else {
                System.debug('=== 여기탄다 ');
                // custom validation error - trigger new에 같은 타입에 대한 여러개 레코드가 존재할 경우
                // 해당 레코드들에 대하여는 에러처리
                tncNewSetting.addError(System.Label.KDCE_InvalidCreateMultipleRecordSameType);
            }
            tncNewSetting.KDCE_VersionNumber__c = versionMap.get(tempType);
            tncNewSetting.KDCE_VersionName__c = String.valueOf(versionMap.get(tempType));
        }
    }
}