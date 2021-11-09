/****************************************************************************************
 * @filename      : KDCE_TnCVersionSet_tr
 * @projectname   : PMK Local DCE
 * @author        : i2max_Sukun
 * @date          : 4/5/21 2:16 PM
 * @group         : Service
 * @group-content :
 * @description   : TnC Version Set Trigger Business Logic Class
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     4/5/21 2:16 PM            i2max_Sukun           Create
 0.2     5/21/21                   i2max_Sukun           Update
 ****************************************************************************************/
public with sharing class KDCE_TnCVersionSet_tr extends TriggerHandler {
    // 동일 TNC에 대하여 동일 버전 이미 존재할 경우
    private static final String LAB_TNC_VersionSet_ERR_SAMEVERSIONFORTNCEXISTS = System.Label.LAB_TNC_VersionSet_ERR_SAMEVERSIONFORTNCEXISTS;

    public override void beforeInsert() {
        confirmNoSameTnCMasterAndTnCVersion();
    }

    public override void beforeUpdate() {
        confirmNoSameTnCMasterAndTnCVersion();
    }

    private void confirmNoSameTnCMasterAndTnCVersion() {
        Map<Id, KDCE_TnCVersionSet__c> tncVersionSetOldMap = (Map<Id, KDCE_TnCVersionSet__c>) Trigger.oldMap;

        Map<String, String> tncMap = new Map<String, String>();
        for(KDCE_TnCVersionSet__c tncVersionSet : (List<KDCE_TnCVersionSet__c>) Trigger.new) {
            if(tncVersionSetOldMap != null && tncVersionSetOldMap.containsKey(tncVersionSet.Id)) {
                // 업데이트의 경우, TaC 버전 혹은 TnC Version을 변경하는 경우에만 적용
                if(tncVersionSetOldMap.get(tncVersionSet.Id).TnCVersion__c != tncVersionSet.TnCVersion__c ||
                        tncVersionSetOldMap.get(tncVersionSet.Id).TaC__c != tncVersionSet.Tac__c)
                    tncMap.put(tncVersionSet.TaC__c, tncVersionSet.TnCVersion__c);
            }

            // insert의 경우, 항상 validate
            else {
                tncMap.put(tncVersionSet.TaC__c, tncVersionSet.TnCVersion__c);
            }
        }

        List<KDCE_TnCVersionSet__c> tncVersionSets = [SELECT Id, TaC__c, TnCVersion__c FROM KDCE_TnCVersionSet__c WHERE TaC__c IN :tncMap.keySet()];

       Map<String, String> errorFlagMap = new Map<String, String>();
//20210915 Marcus Kim Block
//       if(tncVersionSets.size() > 0) {
//            for(KDCE_TnCVersionSet__c retrievedTnCVersionSet : tncVersionSets) {
//                if(tncMap.get(retrievedTnCVersionSet.TaC__c) == retrievedTnCVersionSet.TnCVersion__c)
//                    errorFlagMap.put(retrievedTnCVersionSet.TaC__c, LAB_TNC_VersionSet_ERR_SAMEVERSIONFORTNCEXISTS);
//            }
//        }

        for(KDCE_TnCVersionSet__c tncVersionSetNewSetting : (List<KDCE_TnCVersionSet__c>) Trigger.new) {
            if(errorFlagMap.containsKey(tncVersionSetNewSetting.TaC__c))
                tncVersionSetNewSetting.addError(errorFlagMap.get(tncVersionSetNewSetting.TaC__c));
        }
    }
}