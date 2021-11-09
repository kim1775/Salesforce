/****************************************************************************************
  * @filename      : IF_MG_SFDC_Dummy_tr
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-05-20
  * @group         :
  * @group-content :
  * @description   : Qure 더미
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-05-20             Park HE         Create
****************************************************************************************/
public with sharing class IF_MG_SFDC_Dummy_tr extends TriggerHandler{
    public override void beforeInsert() {
        connectAsset();
    }
     
    private void connectAsset(){

        List<IF_MG_SFDC_Dummy__c> dummyList = (List<IF_MG_SFDC_Dummy__c>)Trigger.new;
        Set<String> newAssetCodentify = new Set<String>();
        Set<String> oldAssetCodentify = new Set<String>();
        Set<String> caseNo = new Set<String>();
        for(IF_MG_SFDC_Dummy__c dummy : dummyList) {
            newAssetCodentify.add(dummy.Parentcodentify__c);
            oldAssetCodentify.add(dummy.ToReplaceCodentify__c);
            // requestId__c = CaseNumber로 예상(Case Id 아님)
            caseNo.add(dummy.requestId__c);
        }
        // IF_MG_SFDC_Dummy__c.requestId__c에 해당하는 Case Id 가져오기
        Map<String, Id> caseNoById = new Map<String, Id>();
        for(Case item : [
                SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN :caseNo
        ]){
            caseNoById.put(item.CaseNumber, item.Id);
        }

        // CaseId를 키값으로 Qure History 저장
        Map<Id, CCR_QureHistory__c> qureHistoryByCaseIds = new Map<Id, CCR_QureHistory__c>();
        for(CCR_QureHistory__c qureHistory : [
                SELECT  Id, KDCE_OtherReason__c, CCR_ReplacementChannelSelectedBy__c, CCR_QureReplacementChannel__c,
                        CCR_Override__c, CCR_OverrideReason__c, CCR_Case__c, CCR_DiagnosticDescription__c
                FROM CCR_QureHistory__c
                WHERE CCR_Case__c IN : caseNoById.values()
        ]){
            qureHistoryByCaseIds.put(qureHistory.CCR_Case__c, qureHistory);
        }
        System.debug(qureHistoryByCaseIds.size());

        List<Asset> assetList = [
                SELECT Id, SerialNumber, CCR_CodentifyId__c,CCR_MaterialGroupDescription__c,
                        CCR_ReplacedBy__c,CCR_ReplacementChannelNew__c,CCR_ReplacementDate__c, Status, CCR_CarePlusDueDate__c, CCR_CarePlusStatus__c,
                        KDCE_DeviceType__c, ContactId, AccountId, CCR_Replaces__c, CCR_OriginalBox__c, CCR_OriginalAsset__c, KDCE_OriginalWarrantyDate__c,
                        KDCE_ReplacementCount__c, KDCE_ReplacementSource__c, KDCE_fm_WarrantyDate__c, CCR_ReplacementSponsored_By__c, CCR_Override__c,
                        CCR_OverrideReason__c, CCR_ReplacementReason__c, KDCE_IsCarePlusHistory__c
                FROM Asset
                WHERE SerialNumber IN : newAssetCodentify OR CCR_CodentifyId__c IN : oldAssetCodentify
        ];

        Map<String, Asset> tempOldAssetMap = new Map<String, Asset>();
        Map<String, Asset> tempNewAssetMap = new Map<String, Asset>();
        String contents;
        for(Asset asset : assetList){
            if(oldAssetCodentify.contains(asset.CCR_CodentifyId__c)){
                //contents = asset.CCR_MaterialGroupDescription__c.contains('holder')? 'holder' : 'charger' ;
                tempOldAssetMap.put(asset.CCR_CodentifyId__c, asset);
            }
            if(newAssetCodentify.contains(asset.SerialNumber)){
                tempNewAssetMap.put(asset.SerialNumber, asset);
            }
        }

        Asset tempOldAsset;
        Asset tempNewAsset;
        contents = null;
        Date criteria;
        Date originalDate;
        final String replacementReasonKr  = '히터 블레이드 파손';
        final String replacementReasonEn  = 'Broken Heating Blade';
        final String careplus             = 'Care+';
        String sponsoredBy ='';


        List<Asset> updateAssets = new List<Asset>();
        List<Asset> updateAssetsOld = new List<Asset>();
        List<Asset> updateAssetsNew = new List<Asset>();
        CCR_QureHistory__c tempQureHistory;


        for(IF_MG_SFDC_Dummy__c dummy : dummyList) {
            dummy.IsProcess__c = true;

            if(tempOldAssetMap.containsKey(dummy.ToReplaceCodentify__c) && tempNewAssetMap.containsKey(dummy.Parentcodentify__c)){
                tempNewAsset = tempNewAssetMap.get(dummy.Parentcodentify__c);
                tempOldAsset = tempOldAssetMap.get(dummy.ToReplaceCodentify__c);
            }else {
                dummy.IsError__c = true;
                dummy.ErrorContent__c  = '새 기기(Parentcodentify__c) 혹은 반납 기기(ToReplaceCodentify__c)의 Codentify가 Asset에 없습니다.';
                continue;
            }

            // 이전 기기 Asset 정보 업데이트
            tempOldAsset.CCR_ReplacedBy__c              = tempNewAsset.Id;
            tempOldAsset.CCR_ReplacementChannelNew__c   = dummy.Channel_v2__c; //KDCE_GlobalValue.ASSET_REPLACEMENT_CHANNEL_PICKUP;
            tempOldAsset.CCR_ReplacementDate__c         = dummy.ReplacementDate__c == null ? System.now() : Datetime.valueOf(dummy.ReplacementDate__c);
//            tempOldAsset.CCR_ReplacementDate__c = dummy.ReplacementDate__c == null ? System.now() :(DateTime)JSON.deserialize('"' + dummy.ReplacementDate__c + '"', DateTime.class);
//            tempOldAsset.CCR_ReplacementDate__c = dummy.ReplacementDate__c == null ? System.now() : Datetime.parse(dummy.ReplacementDate__c);
            tempOldAsset.Status                         = KDCE_GlobalValue.ASSET_STATUS_REPLACED;
            tempOldAsset.CCR_CarePlusDueDate__c         = tempOldAsset.CCR_ReplacementDate__c;

            // qure history 찾아서 매핑
            String caseId = caseNoById?.get(dummy.requestId__c);
            if(qureHistoryByCaseIds.containsKey(caseId) && caseId <> null){
                tempQureHistory = qureHistoryByCaseIds.get(caseId);
                //tempOldAsset.CCR_ReplacementDoneBy__c = tempQureHistory.CCR_ReplacementChannelSelectedBy__c;
                tempOldAsset.CCR_Override__c = tempQureHistory.CCR_Override__c;
                tempOldAsset.CCR_OverrideReason__c = tempQureHistory.CCR_OverrideReason__c;
                tempOldAsset.CCR_ReplacementReason__c = tempQureHistory.CCR_DiagnosticDescription__c;

                if(tempOldAsset.CCR_Override__c)
                    sponsoredBy = KDCE_GlobalValue.ASSET_REPLACE_SPONSOREDBY_GOODWILL;
                else if(tempOldAsset.CCR_ReplacementReason__c == replacementReasonEn)
                    sponsoredBy = KDCE_GlobalValue.ASSET_REPLACE_SPONSOREDBY_IQOSCARE;
                else
                    sponsoredBy = KDCE_GlobalValue.ASSET_REPLACE_SPONSOREDBY_WARRANTY;

                tempOldAsset.CCR_ReplacementSponsored_By__c = sponsoredBy;
            }

            // 4. 스폰서바이가 Iqos Care Plus 이거나 Override+히터블레이드 파손인 경우에는 Disenrolled 처리.
            if(tempOldAsset.CCR_ReplacementSponsored_By__c == careplus
                    || (tempOldAsset.CCR_Override__c && (tempOldAsset.CCR_ReplacementReason__c == replacementReasonKr || tempOldAsset.CCR_ReplacementReason__c == replacementReasonEn))
                ){
                tempOldAsset.CCR_CarePlusStatus__c = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_DISENROLLED;
                tempOldAsset.KDCE_IsCarePlusHistory__c = true;
            }

            // Override 교환이 아닌 경우에만 오늘 날짜로부터 3개월 추가하기
            if(!tempOldAsset.CCR_Override__c) {
                criteria = tempOldAsset.KDCE_fm_WarrantyDate__c <> null ? tempOldAsset.KDCE_fm_WarrantyDate__c.addMonths(-3) : null;
                if (criteria <> null)
                    originalDate = criteria <= System.today() ? System.today().addMonths(+3) : tempOldAsset.KDCE_fm_WarrantyDate__c;
            }
            else{ // Override 교환인 경우 이전 기기의 Original Warrnaty Date 그대로 사용하기
                originalDate = tempOldAsset.KDCE_fm_WarrantyDate__c;
            }

            // 새 기기 Asset 정보 업데이트
//            tempNewAsset.KDCE_DeviceType__c             = 'Standard'; // Device Type 삭제 예정
            tempNewAsset.Status                         = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
            tempNewAsset.ContactId                      = tempOldAsset.ContactId;
            tempNewAsset.AccountId                      = null;

            tempNewAsset.CCR_Replaces__c                = tempOldAsset.Id;
            tempNewAsset.CCR_OriginalAsset__c           = tempOldAsset.CCR_OriginalAsset__c;
            tempNewAsset.CCR_OriginalBox__c             = tempOldAsset.CCR_OriginalBox__c;
            tempNewAsset.KDCE_OriginalWarrantyDate__c   = tempOldAsset.KDCE_OriginalWarrantyDate__c <> null? tempOldAsset.KDCE_OriginalWarrantyDate__c : tempOldAsset.KDCE_fm_WarrantyDate__c;
            tempNewAsset.KDCE_ReplacementCount__c       = tempOldAsset.KDCE_ReplacementCount__c == null ? 1 : (tempOldAsset.KDCE_ReplacementCount__c + 1);
            tempNewAsset.KDCE_ReplacementSource__c      = 'Qure';
            tempNewAsset.KDCE_IsCarePlusHistory__c = tempOldAsset.KDCE_IsCarePlusHistory__c;

            updateAssets.add(tempOldAsset);
            updateAssets.add(tempNewAsset);
            updateAssetsOld.add(tempOldAsset);
            updateAssetsNew.add(tempNewAsset);
            System.debug('tempNewAsset : ' + tempNewAsset);
            System.debug('tempOldAsset : ' + tempOldAsset);
        }

//        if(!updateAssets.isEmpty()) update updateAssets;
        if(!updateAssetsOld.isEmpty() && !Test.isRunningTest()) {
            update updateAssetsOld;
            KDCE_Asset_tr.isAlreadyExecuted = false;
        }
        if(!updateAssetsNew.isEmpty() && !Test.isRunningTest()) {
            update updateAssetsNew;
            KDCE_Asset_tr.isAlreadyExecuted = false;
        }

    }

}