/****************************************************************************************
 * @filename      : KDCE_TnCVersion_tr
 * @projectname   : PMK Local DCE
 * @author        : i2max_Sukun
 * @date          : 4/5/21 2:16 PM
 * @group         : Service
 * @group-content :
 * @description   : TnC Version Trigger Business Logic Class
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     4/5/21 2:16 PM            i2max_Sukun           Create
 ****************************************************************************************/
public with sharing class KDCE_TnCVersion_tr extends TriggerHandler {

    public override void beforeInsert() {
        forceSetToNextVersion();
    }

    public override void beforeUpdate() {
//        forceSetToNextVersionNumber();
    }

    // TnC Version의 경우 기간 내 하나만 가능하며, Active 또한 하나만 되어 있어야 함
    private void forceSetToNextVersion() {
//        Map<Decimal, KDCE_TnCVersion__c> versionMap = new Map<Decimal, KDCE_TnCVersion__c>();
//        for(KDCE_TnCVersion__c tncVersion : (List<KDCE_TnCVersion__c>) Trigger.new) {
//            versionMap.put(tncVersion.VersionNumber__c, tncVersion);
//        }
//
//        List<Decimal> versionOrdered = (List<Decimal>) versionMap.keySet();
//        versionOrdered.sort();

        // 가장 최신의 Active TnC 버전
        List<KDCE_TnCVersion__c> tncVersions = [SELECT Id, VersionNumber__c FROM KDCE_TnCVersion__c WHERE IsActive__c = TRUE ORDER BY VersionNumber__c DESC LIMIT 1];
        System.debug('=== tncVersions : ' + tncVersions);

        if(Trigger.new.size() > 1) {
            for (KDCE_TnCVersion__c tncNewVersionSetting : (List<KDCE_TnCVersion__c>) Trigger.new) {
                // custom validation error - trigger new에 여러개 레코드가 존재할 경우
                // 해당 레코드들에 대하여는 에러처리
                tncNewVersionSetting.addError(System.Label.KDCE_InvalidCreateMultipleRecord);
            }
        } else {
            for (KDCE_TnCVersion__c tncNewVersionSetting : (List<KDCE_TnCVersion__c>) Trigger.new) {
                // 기존에 TnC Version이 없을 경우 초기값은 0으로 설정
                tncNewVersionSetting.VersionNumber__c = tncVersions.isEmpty() ? 0 : tncVersions[0].VersionNumber__c + 1;
            }
        }
        // 다건처리 prevent
//        for(KDCE_TnCVersion__c retrievedTnCVersion : tncVersions) {
//            versionMap.put(retrievedTnCVersion.VersionNumber__c, retrievedTnCVersion.VersionNumber__c + 1);
//        }

//        for(KDCE_TnCVersion__c tncVersionNewSetting : (List<KDCE_TnCVersion__c>) Trigger.new) {
////            tncVersionNewSetting.VersionNumber__c = versionMap.get(tncVersionNewSetting.VersionNumber__c);
//        }
    }
}