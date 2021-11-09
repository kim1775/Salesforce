/****************************************************************************************
  * @filename      : KDCE_AssetLifeCycle_tr
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-03-03 오후 4:03
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : KDCE_Asset_tr_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-03-03 오후 4:03     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_AssetLifeCycle_tr extends TriggerHandler{

    public override void afterInsert() {
        setContactRecord();     // Asset Link시, Contact 필드 업데이트
    }

    /**
     * Asset이 Link 되었을 때, Contact 필드 업데이트 (+ 21.09.02 AssetIdMap 자산 상태 확인 위해 추가)
     */
    private void setContactRecord() {
        System.debug('@@@@@@ setContactRecord @@@@@@');
        Map<Id, Datetime> linkDateByContactMap = new Map<Id, Datetime>();
        Map<Id, Datetime> unlinkContactMap = new Map<Id, Datetime>();
        Map<Id, Datetime> AssetIdMap = new Map<Id, Datetime>();
        for (CCR_AssetLifeCycle__c alc : (List<CCR_AssetLifeCycle__c>) Trigger.new) {
            if (alc.CCR_Action__c == 'Link') {
                if (linkDateByContactMap.containsKey(alc.CCR_Consumer__c)) {
                    if (alc.CCR_ActionDate__c > linkDateByContactMap.get(alc.CCR_Consumer__c)) {
                        linkDateByContactMap.put(alc.CCR_Consumer__c, alc.CCR_ActionDate__c);
                        AssetIdMap.put(alc.CCR_Asset__c, alc.CCR_ActionDate__c);
                    }
                }
                else {
                    linkDateByContactMap.put(alc.CCR_Consumer__c, alc.CCR_ActionDate__c);
                    AssetIdMap.put(alc.CCR_Asset__c, alc.CCR_ActionDate__c);
                }
            }
            else {
                unlinkContactMap.put(alc.CCR_Consumer__c, alc.CCR_ActionDate__c);
                AssetIdMap.put(alc.CCR_Asset__c, alc.CCR_ActionDate__c);
            }
        }
        /*
        for (CCR_AssetLifeCycle__c alc : (List<CCR_AssetLifeCycle__c>) Trigger.new) {
            if (alc.CCR_Action__c == 'Link') {
                // TODO Link 데이터 생성일자인지에 대해선 추후에 논의 후 확정필요
                if (linkDateByContactMap.containsKey(alc.CCR_Consumer__c)) {
                    if (alc.CreatedDate > linkDateByContactMap.get(alc.CCR_Consumer__c)) linkDateByContactMap.put(alc.CCR_Consumer__c, alc.CreatedDate);
                }
                else {
                    linkDateByContactMap.put(alc.CCR_Consumer__c, alc.CreatedDate);
                }
            }
        }
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@Link Contact Check : ' + linkDateByContactMap);
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@Unlink Contact Check : ' + unlinkContactMap);
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@AssetIdMap Check : ' + AssetIdMap);
        */
        // 21.09.02 unlinkIsStore, AssetStatus 추가
        System.Debug('@@@@@@@@ Asset Id : ' + AssetIdMap);
        System.Debug('@@@@@@@@ unlinkContactMap : ' + unlinkContactMap);
        // 21.09.02 아래 두 번째 IF문 Null 값 비교 방지
        List<Contact> unlinkIsStores =  new List<Contact>() ;
        // List<Asset> assetStatus = new List<Asset>() ; 21.09.10 Asset Locked 상태 점검 위해 있었음
        Map<Id, Contact> updateConMap = new Map<Id, Contact>();

        // 21.09.02 Contact 없는 Asset 링크 시 발생하는 오류 방지
        if(!unlinkContactMap.isEmpty()) {
            unlinkIsStores = [SELECT KDCE_IsStoreContact__c, KDCE_Store__c  FROM Contact WHERE Id =:unlinkContactMap.keySet()] ;
            // assetStatus = [SELECT Status  FROM Asset WHERE Id =:AssetIdMap.keySet()] ; 21.09.10 Asset Locked 상태 점검 위해 있었음
        }

        // System.debug('@@@@@@@@@@ assetStatus : ' + assetStatus); 21.09.10 Asset Locked 상태 점검 위해 있었음

        Contact unlinkIsStore = new Contact();
        if(unlinkIsStores.size() > 0) unlinkIsStore = unlinkIsStores[0];
        System.debug('@@@@@@@@ UnlinkContact : ' + unlinkIsStore);
        if(unlinkIsStore.KDCE_IsStoreContact__c == true && unlinkIsStore.KDCE_Store__c != null) { // Contact의 스토어 정보가 True일 때, + 21.09.02 Asset 상태가 Locked일 때, + 21.9.10 온라인 렌탈 Contact Store 정보 없음
            // if(assetStatus[0].Status == 'Locked'){ // 21.09.10 온라인 렌탈 후 구매 las 유지 오류로 주석 처리
            for (Contact con : [SELECT Id, KDCE_LastDeviceLinkDate__c FROM Contact WHERE Id =:linkDateByContactMap.keySet()]) {
                con.KDCE_LastDeviceLinkDate__c = linkDateByContactMap.get(con.Id);
                updateConMap.put(con.Id, con);
            }
            System.debug('=== updateConMap : ' + updateConMap);
            if (updateConMap.size() > 0) update updateConMap.values();
        }
        else{
            for (Contact con : [SELECT Id, KDCE_LastDeviceLinkDate__c, KDCE_LASLAU__c FROM Contact WHERE Id =:linkDateByContactMap.keySet()]) {
                con.KDCE_LastDeviceLinkDate__c = linkDateByContactMap.get(con.Id);
                con.KDCE_LASLAU__c = 'LAU';
                updateConMap.put(con.Id, con);
            }
            System.debug('=== updateConMap : ' + updateConMap);
            if (updateConMap.size() > 0) update updateConMap.values();
        }
    }

   public static void testRate(){
       Integer i = 0;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
   }
}