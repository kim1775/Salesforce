/****************************************************************************************
  * @filename      : KDCE_MCEmailLog_tr
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-22 오후 3:10
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
    0.1     2021-06-22 오후 3:10     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_MCEmailLog_tr extends TriggerHandler {

    public override void beforeInsert() {
        updateField();  // EmailOptout 필드 업데이트시, 해당 TnC Acceopted를 False로 업데이트
    }

    public override void beforeUpdate() {
        updateField();  // EmailOptout 필드 업데이트시, 해당 TnC Acceopted를 False로 업데이트
    }

    private void updateField() {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, KDCE_TnCAccepted__c> tnCAcceptedMap = new Map<Id, KDCE_TnCAccepted__c>();
        if (Trigger.isInsert) {
            for (KDCE_MCEmailLog__c mcLog : (List<KDCE_MCEmailLog__c>) Trigger.new) {
                if (mcLog.KDCE_EmailOptout__c == true) contactIds.add(mcLog.KDCE_SubscriberKey__c);
            }
        }
        else if (Trigger.isUpdate) {
            for (KDCE_MCEmailLog__c mcLog : (List<KDCE_MCEmailLog__c>) Trigger.new) {
                KDCE_MCEmailLog__c oldMCEmailLog = (KDCE_MCEmailLog__c) Trigger.oldMap.get(mcLog.Id);
                if (oldMCEmailLog.KDCE_EmailOptout__c == false && mcLog.KDCE_EmailOptout__c == true) contactIds.add(mcLog.KDCE_SubscriberKey__c);
            }

        }
        System.debug('=== contactIds : ' + contactIds);
        // TnCAccepted 중 global TnC와 연결되어 있는 6번만 것만 연결해제해야함.
        for (KDCE_TnCAccepted__c tnCAccepted : [
                SELECT Id, Accepted__c, TnC__r.fm_TnCId__c
                FROM KDCE_TnCAccepted__c
                WHERE Contact__c IN :contactIds
                AND TnC__r.fm_TnCId__c = 'globaloptin'
        ]) {
            tnCAccepted.Accepted__c = false;
            tnCAcceptedMap.put(tnCAccepted.Id, tnCAccepted);
        }
        System.debug('=== tnCAcceptedMap : ' + tnCAcceptedMap);
        if (!tnCAcceptedMap.isEmpty()) update tnCAcceptedMap.values();
    }
}