/****************************************************************************************
  * @filename      : KDCE_Asset_tr
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-03-03
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : KDCE_Asset_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-03-03             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_Asset_tr extends TriggerHandler {

    // 재귀 호출 방지 Flag
    public static Boolean isAlreadyExecuted = false;

    // Contact RecordType 별 DeveloperName, Id의 Map
    private static Map<String, Id> contactRTMap = KDCE_Util.getRecordTypeBySObject('Contact');

    public override void beforeInsert() {
        List<Asset> newList = new List<Asset>();
        for(Asset asset : (List<Asset>) Trigger.new){
            if(asset.ContactId <> null) newList.add(asset);
        }
        if(!newList.isEmpty())
            updateAssetCarePlusValues(newList); // 글로벌 디바이스 검색으로 생성된 어셋

    }

    public override void beforeUpdate() {
        System.debug('=== Check Point ===');
        preventNameChanges();
        setDefault();
        checkDisposalDevice();      // 렌탈 불용처리시, Deivce Labelling 업데이트
        beforeUpdateAssetRecord();
        updateFirstLinkDate();
        updateWarrantyDate();   //  TODO 마이그가 잘못된걸 위해서 있는 임의의 메서드
        //doManualFix();
    }

    public override void afterInsert() {
    }

    public override void afterUpdate() {
        //updateContactField();       // Asset과 Contact 연결시 Contact 필드 업데이트

        if (isAlreadyExecuted == false) {
            afterUpdateAssetRecord();
            syncAssetPurchaseDate();    // Asset Purchase Date 업데이트시, 일치하는 serialnum인 Asset Purchase 동기화

            if(!Test.isRunningTest())isAlreadyExecuted = true;
        }
    }

    private void preventNameChanges(){
        Set<Id> userProfileId = new Set<Id>();
        for (Asset item : (List<Asset>) Trigger.new) {
            Asset oldContact = (Asset) Trigger.oldMap.get(item.id);
            if(item.Name != oldContact.Name){
                userProfileId.add(UserInfo.getProfileId());
            }
        }

        if(!userProfileId.isEmpty()) {
            Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Id IN :userProfileId]);
            Id profileId;
            for (Asset item : (List<Asset>) Trigger.new) {
                profileId = UserInfo.getProfileId();
                System.debug(profileMap?.get(profileId).Name);
                if (profileMap?.get(profileId).Name.contains('Standard'))
                    item.addError(System.Label.KDCE_PreventEditName);
            }
        }
    }

    private void setDefault() {

        for (Asset item : (List<Asset>) Trigger.new) {

            if(item.ContactId != null && item.AccountId != null) item.AccountId = null;
        }
    }

    // TODO 마이그가 잘못된걸 위해서 있는 임의의 메서드
    private void updateWarrantyDate() {
        Set<String> codentifyId = new Set<String>();
        Map<String, Asset> contactBySerialNum = new Map<String, Asset>();
        for (Asset asset : (List<Asset>)Trigger.new) {
            Asset oldAsset = (Asset) Trigger.oldMap.get(asset.Id);
            if (asset.PurchaseDate <> oldAsset.PurchaseDate && asset.Status == 'Active') {
                if (asset.KDCE_OriginalWarrantyDate__c != null) asset.KDCE_OriginalWarrantyDate__c = null;
            }
        }
    }

    /**
     * 렌탈 불용 기기 처리를 위한 메서드
     * @author 이지현 (2021.07.02)
     */
    private void checkDisposalDevice() {
        Asset oldAsset;
        for (Asset newAsset : (List<Asset>) Trigger.new) {
            oldAsset = (Asset) Trigger.oldMap.get(newAsset.Id);
            if (oldAsset.KDCE_DisposalDevice__c <> newAsset.KDCE_DisposalDevice__c) {
                if (newAsset.KDCE_DisposalDevice__c == true) {
                    newAsset.Status = 'Locked';
                    newAsset.KDCE_DeviceLabelling__c = 'To be disposed';
                }
                else newAsset.addError(System.Label.KDCE_CannotChangeDeviceDisposal);
            }
        }
    }


    /**
     * @author Park He
     * @description beforeupdate에서 수행해야 하는 조건들
     */
    private void beforeUpdateAssetRecord() {
        System.debug('@@@@@@ beforeUpdateAssetRecord @@@@@@');
        List<Asset> newList;
        List<Asset> newList2;


        // XXX -> Produced로 값 변경된 경우만 메서드 보내기
        newList = new List<Asset>();
        for (Asset item : (List<Asset>) Trigger.new) {
            if ((item.Status == KDCE_GlobalValue.ASSET_STATUS_PRODUCED
                    && ((Asset) Trigger.oldMap.get(item.Id)).Status != KDCE_GlobalValue.ASSET_STATUS_PRODUCED)) {
                newList.add(item);
            }
        }
        if (!newList.isEmpty()) this.restoreAssetState(newList);

        // Asset 기준, Care + 로직
        newList = new List<Asset>();
        newList2 = new List<Asset>();
        Asset oldAsset;
        for (Asset item : (List<Asset>) Trigger.new) {
            oldAsset = (Asset)(Trigger.oldMap).get(item.Id);
            if ((item.ContactId != oldAsset.ContactId)){// && item.ContactId <> null) {
                newList.add(item);
                newList2.add(item);
            }else if (item.KDCE_fm_WarrantyDate__c != oldAsset.KDCE_fm_WarrantyDate__c) {
                newList2.add(item);
            }

        }
        if (!newList2.isEmpty())    this.updateAssetCarePlusValues(newList2);

    }

    /**
     * @author Park He
     * @description afterupdate에서 수행해야 하는 조건들
     */
    private void afterUpdateAssetRecord() {
        System.debug('@@@@@@ afterUpdateAssetRecord @@@@@@');

        System.debug('new ' + (List<Asset>) Trigger.new);
        System.debug('old ' + (List<Asset>) Trigger.old);

        List<Asset> newList;
        List<Asset> newList2;
        Asset oldAsset;

        //Asset Life Cycle 생성
        newList = new List<Asset>();
        newList2 = new List<Asset>();
        for (Asset item : (List<Asset>) Trigger.new) {
            oldAsset = (Asset) Trigger.oldMap.get(item.Id);
            if ((item.ContactId != oldAsset.ContactId)) {
                newList.add(item);
            }
            if(item.CCR_CarePlusDueDate__c <> oldAsset.CCR_CarePlusDueDate__c) newList2.add(item);


        }
        if (!newList.isEmpty()) {
            this.createAssetLifeCycle(newList);
            this.calculateDeviceCount(newList);
        }

        newList2.addAll(newList);
        if(!newList2.isEmpty())     updateContactCarePlusField(newList2);

        // History LifeCycle 삭제
        newList = new List<Asset>();
        for (Asset item : (List<Asset>) Trigger.new) {
            if ((item.Status == KDCE_GlobalValue.ASSET_STATUS_PRODUCED && ((Asset) Trigger.oldMap.get(item.Id)).Status != KDCE_GlobalValue.ASSET_STATUS_PRODUCED)) {
                newList.add(item);
            }
        }
        if (!newList.isEmpty()) this.deleteRelatedAsset(newList);
    }

    /**
     * @date 21-03-15
     * @description  Asset Life Cycle 로그 생성- Link/Unlink
     * @author Park HE
     *
     * @param newList
     */
    private void createAssetLifeCycle(List<Asset> newList) {
        System.debug('@@@@@@ createAssetLifeCycle @@@@@@');
        if (!isAlreadyExecuted) {
            CCR_AssetLifeCycle__c tempCycle;
            List<CCR_AssetLifeCycle__c> insertLifeCycles = new List<CCR_AssetLifeCycle__c>();
            for (Asset asset : newList) {
                if (asset.ContactId != null) {
                    if (((Map<Id, Asset>) Trigger.oldMap).get(asset.Id).ContactId != null) {
                        tempCycle = KDCE_AssetService.returnAssetLifeCycleValue(asset, KDCE_GlobalValue.ASSETLIFECYCLE_ACTION_UNLINK, ((Map<Id, Asset>) Trigger.oldMap).get(asset.Id).ContactId);
                        if (tempCycle != null) insertLifeCycles.add(tempCycle);
                    }
                    tempCycle = KDCE_AssetService.returnAssetLifeCycleValue(asset, KDCE_GlobalValue.ASSETLIFECYCLE_ACTION_LINK, asset.ContactId);
                } else tempCycle = KDCE_AssetService.returnAssetLifeCycleValue(asset, KDCE_GlobalValue.ASSETLIFECYCLE_ACTION_UNLINK, ((Map<Id, Asset>) Trigger.oldMap).get(asset.Id).ContactId);

                if (tempCycle != null) insertLifeCycles.add(tempCycle);
            }

            System.debug(insertLifeCycles);
            if (!insertLifeCycles.isEmpty()) insert insertLifeCycles;

        }
    }
    /**
     * @date 21-03-17
     * @author Park He
     * @description Asset Status가 활성상태였다가 Produced(판매가능상태)로 변경된 경우, 관련 기록들을 클렌징한다 - Asset Field 클렌징
     *
     * @param newList
     */
    private void restoreAssetState(List<Asset> newList) {
        System.debug('@@@@@@ restoreAssetState @@@@@@');
        System.debug('START :: ===== restoreAssetState == :: ' + newList);

        // Asset 초기화
        for (Asset asset : newList) {
            asset.KDCE_DeviceLabelling__c = null;
            asset.KDCE_DeviceType__c = null;
            asset.PurchaseDate = null;
            asset.KDCE_ShipmentDate__c = null;
            asset.ContactId = null;
            asset.AccountId = System.Label.KDCE_DefaultAccount;
            asset.CCR_PurchaseChannel__c = null;
            asset.CCR_FirstLinkDatetoCurrentContact__c = null;
            asset.CCR_CarePlusDueDate__c = null;
            asset.CCR_CarePlusStatus__c = null;
            asset.CCR_Replaces__c = null;
            asset.CCR_ReplacedBy__c = null;
            asset.CCR_ReplacementDate__c = null;
            asset.CCR_ReplacementReason__c = null;
            asset.CCR_OriginalAsset__c = null;
            asset.CCR_ReplacementChannelNew__c = null;
            asset.CCR_OriginalBox__c = null;
            asset.KDCE_ReplacementCount__c = null;
            asset.KDCE_OriginalWarrantyDate__c = null;
            asset.KDCE_ReplacementSource__c = null;
            asset.CCR_ReplacementDoneBy__c = null;
            asset.CCR_ReplacementSponsored_By__c = null;
            asset.CCR_ReplacementExternalReference__c = null;
            asset.CCR_Override__c = false;
            asset.CCR_OverrideReason__c = null;
            asset.CCR_AccidentalDamageCounter__c = null;
            asset.KDCE_IsCarePlusHistory__c = false;
        }

        System.debug('END :: ===== restoreAssetState == :: ' + newList);

    }

    /**
     * @author Park He
     * @description Asset에 연결된 Contact의 값이 변경되면, Contact의 Device Count 값을 업데이트한다.
     * @date 21-04-27
     * @param newList
     */
    private void calculateDeviceCount(List<Asset> newList) {
        System.debug('@@@@@@ calculateDeviceCount @@@@@@');

        Set<Id> contIds = new Set<Id>();
        for(Asset asset : newList){
            // 예전 Contact Id
            Id oldContId = ((Asset)Trigger.oldMap.get(asset.Id)).ContactId;
            if(asset.ContactId <> null)
                contIds.add(asset.ContactId);
            //Unlink 시,
            if(oldContId <> null)
                contIds.add(oldContId);
        }

        List<AggregateResult> ars = [
                SELECT count(Id) cnt, ContactId contId, CCR_DeviceProductCode__r.CCR_GroupDescription__r.Name contents, Product2.CCR_Version__c version
                FROM Asset
                WHERE ContactId IN :contIds AND Status = 'Active'  AND Product2.CCR_Version__c <> NULL
                GROUP BY CCR_DeviceProductCode__r.CCR_GroupDescription__r.Name, ContactId, Product2.CCR_Version__c
        ];

        Map<String, Map<String, Map<String, Decimal>>> cntMap = new Map<String, Map<String, Map<String, Decimal>>>();
        String contId;
        String version;
        String content;
        Decimal deviceCnt;
        for(AggregateResult ar : ars){

            contId      = (String)ar.get('contId');
            version     = (String)ar.get('version') ;
            content     = (String)ar.get('contents');
            deviceCnt   = (Decimal)ar.get('cnt');

            if(cntMap.containsKey(contId)) {
                if(cntMap.get(contId).containsKey(version)){
                    cntMap.get(contId).get(version).put(content, deviceCnt);
                }else {
                    cntMap.get(contId).put(version,new Map<String, Decimal>{ content => deviceCnt});
                }

            }else {
                cntMap.put(contId, new Map<String, Map<String, Decimal>>{version => new Map<String, Decimal>{content => deviceCnt}});
            }

            contId      = null;
            version     = null;
            content     = null;
            deviceCnt   = null;
        }

        System.debug('========== Contact 별 Device Version 및 구성품 :: ' + cntMap);

        String  charger = KDCE_GlobalValue.ASSET_MATERIALGROUPDESC_CHARGER;
        String  holder  =  KDCE_GlobalValue.ASSET_MATERIALGROUPDESC_HOLDER;
        Decimal totalDeviceCnt;
        Decimal tempTotalDeviceCnt;
        Decimal totalHolderCnt;

        List<Contact> contactList       = [SELECT Id, KDCE_DeviceSetCount__c, KDCE_DeviceHolderCount__c FROM Contact WHERE Id IN : contIds];
        List<Contact> updateContactList = new List<Contact>();

        for(Contact c : contactList){
            // 초기화
            totalDeviceCnt      = 0;
            tempTotalDeviceCnt  = 0;
            totalHolderCnt      = 0;

            // contact Id로 찾아오기
            if(cntMap.containsKey(c.Id)){
                //contact가 갖고 있는 제품의 version 불러오기
                for(String str : cntMap.get(c.Id).keySet()){

                    //contact가 갖고 있는 제품의 version 별 holder/charger 조회해서 holder, charger 모두 소지 시, 세트로 취급
                    if(cntMap.get(c.Id).get(str).containsKey(holder) && cntMap.get(c.Id).get(str).containsKey(charger)){
                        Decimal tempHolderCnt   = cntMap.get(c.Id).get(str).get(holder);
                        Decimal tempChargerCnt  = cntMap.get(c.Id).get(str).get(charger);

                        //holder 수, charger 수 비교해서 적은 쪽을 세트 개수로 취급(ex. holder:2/charger:1 이면 세트는 1)
                        tempTotalDeviceCnt = tempHolderCnt >= tempChargerCnt ? tempChargerCnt : tempHolderCnt ;
                        totalDeviceCnt += tempTotalDeviceCnt;
                    }

                    //holder 개수 따로 카운팅
                    if(cntMap.get(c.Id).get(str).containsKey(holder)) {
                        totalHolderCnt += cntMap.get(c.Id).get(str).get(holder);
                    }
                }
            }

            //contact의 필드 업데이트
            c.KDCE_DeviceSetCount__c    = totalDeviceCnt;
            c.KDCE_DeviceHolderCount__c = totalHolderCnt;

            updateContactList.add(c);
        }

        if(!updateContactList.isEmpty() && !Test.isRunningTest()) update updateContactList;
    }


    /**
     * @date 21-03-24
     * @author Park He
     * @description Asset Status가 활성상태였다가 Produced(판매가능상태)로 변경된 경우, 관련 기록들을 클렌징한다 - Asset의 Related
     *
     * @param newList
     */
    private void deleteRelatedAsset(List<Asset> newList) {
        System.debug('@@@@@@ deleteRelatedAsset @@@@@@');
        System.debug('START :: ===== deleteRelatedAsset == :: ' + newList);

        Set<Id> assetIds = new Set<Id>();
        for (Asset item : newList) {
            assetIds.add(item.Id);
        }
        Map<Id, KDCE_AssetHistory__c> assetHistoryMap = new Map<Id, KDCE_AssetHistory__c>([
                SELECT Id, Asset__c
                FROM KDCE_AssetHistory__c
                WHERE Asset__c IN :assetIds
        ]);
        Map<Id, CCR_AssetLifeCycle__c> assetLifeCycleMap = new Map<Id, CCR_AssetLifeCycle__c>([
                SELECT Id, CCR_Asset__c
                FROM CCR_AssetLifeCycle__c
                WHERE CCR_Asset__c IN :assetIds
        ]);

        Asset tempAsset;
        List<Asset> tempAssetList = new List<Asset>();
        for (Asset asset : newList) {
            if (asset.ContactId == null) {
                tempAsset = new Asset(Id = asset.Id, CCR_FirstLinkDatetoCurrentContact__c = null);
                tempAssetList.add(tempAsset);
            }
        }

        if (!assetHistoryMap.values().isEmpty()) delete assetHistoryMap.values();
        if (!assetLifeCycleMap.values().isEmpty()) delete assetLifeCycleMap.values();
        if (!tempAssetList.isEmpty()  && !Test.isRunningTest()) update tempAssetList;

        System.debug('END :: ===== deleteRelatedAsset == :: ');

    }


    /**
     * Asset과 Contact 연결시, Contact Field 업데이트 (2021-04-01 이지현)
     * TODO Asset 생성시 Contact이 바로 연결될 경우는 없으니까 고려안해도되나???
    */
    private void updateContactCarePlusField(List<Asset> newList) {
        System.debug('@@@@@@ updateContactCarePlusField @@@@@@');

        Asset oldAsset;
        Datetime latestExpirationDate;
        String isEnrolled;

        // Asset의 Contact 가져옴
        Set<Id> conIdSet = new Set<Id>();
        for (Asset asset : newList) {
            if(Trigger.isUpdate){
                oldAsset = (Asset) Trigger.oldMap.get(asset.Id);
                conIdSet.add(oldAsset.ContactId);
            }
            conIdSet.add(asset.ContactId);
        }
        System.debug('conIdSet ' + conIdSet);

        // Contact 정보 및 연결 Asset 정보들 가져옴
        List<Contact> conList = [
                SELECT Id, CCR_CarePlusDueDate__c, CCR_CarePlusStatus__c, RecordType.DeveloperName, (
                        SELECT Id, CCR_CarePlusDueDate__c, CCR_CarePlusStatus__c
                        FROM Assets WHERE Status = : KDCE_GlobalValue.ASSET_STATUS_ACTIVE
                )
                FROM Contact
                WHERE Id IN :conIdSet
        ];

        System.debug('conList ' + conList);

        List<Contact> updateConList = new List<Contact>();

        if (!conIdSet.isEmpty()) {
            for (Contact con : conList) {
                latestExpirationDate = null;
                isEnrolled = 'Not Enrolled';

                // 소유한 Asset이 없으면 null 처리 한다.
                if(con.Assets.size() == 0) {
                    con.CCR_CarePlusDueDate__c = null;
                    isEnrolled = null;
                }
                for (Asset asset : con.Assets) {

                    // 고객이 소유한 기기중 가장 늦은 일자
                    if (latestExpirationDate == null) {
                        latestExpirationDate = asset.CCR_CarePlusDueDate__c;
                        System.debug('latestExpirationDate ' + latestExpirationDate);
                    }
                    else if (asset.CCR_CarePlusDueDate__c == null) {

                    }
                    else if (latestExpirationDate < asset.CCR_CarePlusDueDate__c) latestExpirationDate = asset.CCR_CarePlusDueDate__c;

                    // 고객이 소유한 기기중 하나라도 유효하면 'Enrolled' 아니면 NotEnrolled'
                    //if (asset.CCR_CarePlusDueDate__c != null && asset.CCR_CarePlusDueDate__c > System.today()
                    //        && con.RecordType.DeveloperName == 'Contact_Member') isEnrolled = 'Enrolled';
                    if (con.RecordType.DeveloperName == 'Contact_Member' && asset.CCR_CarePlusStatus__c == 'Enrolled') isEnrolled = 'Enrolled';
                }
                if (latestExpirationDate != null) con.CCR_CarePlusDueDate__c = latestExpirationDate;
                //con.CCR_CarePlusStatus__c = isEnrolled;
                updateConList.add(con);
            }
        }

        if( !Test.isRunningTest()) update updateConList;
    }

    /**
     * @author Park He
     * @description Care+ 로직
     * @date 21-04-22
     * @param newList
     */
    private void updateAssetCarePlusValues(List<Asset> newList) {
        System.debug('@@@@@@ updateAssetCarePlusValues @@@@@@');

        Set<Id> contactIds = new Set<Id>();
        List<Asset> linkAssetList = new List<Asset>();
        for (Asset asset : newList) {
            // 기기 해제한 경우, 케어플러스 null 처리
            if (asset.ContactId == null) {
                return;
            }

            // 기기 등록한 경우, linkAssetList에 담아 따로 처리
            if (asset.ContactId != null) {
                contactIds.add(asset.ContactId);
                linkAssetList.add(asset);
            }
        }

        List<Contact> contactList = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Contact WHERE Id IN :contactIds];
        Map<String, String> contactRt = new Map<String, String>();

        // contact의 레코드 타입 저장하기
        for (Contact con : contactList) {
            contactRt.put(con.Id, con.RecordType.DeveloperName);
        }

        Set<Id> oldReplacesAssetIds = new Set<Id>();
        String disEnroll    = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_DISENROLLED;
        String enrolled     = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_ENROLLED;
        String notEnrolled  = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_NOTENROLLED;
        String expired      = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_EXPIRED;

        for (Asset asset : linkAssetList) {
            if(asset.CCR_CarePlusStatus__c == disEnroll) continue;

            if(!asset.CCR_Override__c) asset.CCR_CarePlusDueDate__c = asset.KDCE_fm_WarrantyDate__c;
            // CCR_CarePlusDueDate__c가 지난 경우
            if(asset.CCR_CarePlusDueDate__c < System.today()){
                asset.CCR_CarePlusStatus__c = expired;
            }
            else{ //CCR_CarePlusDueDate__c가 남은 경우
                // Enrolled :: Contact의 RecordType이 Member 이고 Due Date가 남아 있을 때,
                if (contactRt.get(asset.ContactId) == 'Contact_Member') {
                    asset.CCR_CarePlusStatus__c = enrolled;
                }
                //Not enroll :: Contact의 RecordType이 Prospect 이고 Due date가 남아 있을 때
                else if (contactRt.get(asset.ContactId) == 'Contact_Prospect') {
                        asset.CCR_CarePlusStatus__c = notEnrolled;
                }
            }

            // 교체 기기인 경우, 교체 이전 기기 조회하기 위해 Id 저장
            if (asset.CCR_Replaces__c != null) {
                oldReplacesAssetIds.add(asset.CCR_Replaces__c);
            }
        }
        System.debug('linkAssetList ' + linkAssetList);
        System.debug('oldReplacesAssetIds ' + oldReplacesAssetIds);

        if(Trigger.isBefore) {
            Map<Id, Asset> oldReplacesCarePlusValues = new Map<Id, Asset>();
            // 이전 기기의 CCR_ReplacementSponsored_By__c == 'IQOS CARE PLUS'면 careplusStatus 변경
            if (!oldReplacesAssetIds.isEmpty()) {
                for (Asset asset : [
                        SELECT Id, CCR_ReplacementSponsored_By__c, CCR_CarePlusStatus__c, CCR_Replaces__c, CCR_CarePlusDueDate__c, KDCE_IsCarePlusHistory__c
                        FROM Asset
                        WHERE Id IN :oldReplacesAssetIds
                ]) {
                    oldReplacesCarePlusValues.put(asset.Id, asset);

                }
            }
            System.debug('oldReplacesCarePlusValues ' + oldReplacesCarePlusValues);

            Asset tempOldAsset;
            for (Asset asset : linkAssetList) {
                if (oldReplacesCarePlusValues.containsKey(asset.CCR_Replaces__c)) {
                    tempOldAsset = oldReplacesCarePlusValues.get(asset.CCR_Replaces__c);
                    asset.CCR_CarePlusStatus__c = tempOldAsset.CCR_CarePlusStatus__c;
                    System.debug(' tempOldAsset ' + tempOldAsset);
                    System.debug(tempOldAsset.CCR_CarePlusStatus__c);

                    // disEnrolled 인 경우에는 True 처리
                    if (asset.CCR_CarePlusStatus__c == disEnroll) asset.KDCE_IsCarePlusHistory__c = true;

                    //이전 기기의 KDCE_IsCarePlusHistory__c 가 true이면 새 기기도 KDCE_IsCarePlusHistory__c = true
                    if (tempOldAsset.KDCE_IsCarePlusHistory__c) asset.KDCE_IsCarePlusHistory__c = true;

                    // KDCE_IsCarePlusHistory__c 가 트루라면 CCR_CarePlusDueDate__c는 이전 값을 사용한다.(교체일 오늘날 X)
                    if (asset.KDCE_IsCarePlusHistory__c) {
                        asset.CCR_CarePlusDueDate__c = tempOldAsset.CCR_CarePlusDueDate__c;
                    }
                }
            }
            System.debug('linkAssetList ' + linkAssetList);
            System.debug('END :: updateCarePlusValues');
        }
    }

    /**
     * 매뉴얼로 Asset purchase date 업데이트시, 동일한 parent codentify Asset도 구매일도 업데이트 (2021.07.15 이지현 추가)
     */
    private void syncAssetPurchaseDate() {
        Set<String> codentifyId = new Set<String>();
        Map<String, Asset> contactBySerialNum = new Map<String, Asset>();
        for (Asset asset : (List<Asset>)Trigger.new) {
            Asset oldAsset = (Asset) Trigger.oldMap.get(asset.Id);
            if (asset.PurchaseDate <> oldAsset.PurchaseDate) {
                contactBySerialNum.put(asset.SerialNumber, asset);
                codentifyId.add(asset.CCR_CodentifyId__c);
            }
        }
        System.debug('codentifyId ' + codentifyId);
        System.debug('contactBySerialNum ' + contactBySerialNum);
        if(codentifyId.isEmpty() || contactBySerialNum.keySet().contains(null)) return;

        Map<Id, Asset> updateAsset = new Map<Id, Asset>();
        for (Asset asset : [
                SELECT Id, ContactId, PurchaseDate, SerialNumber
                FROM Asset
                WHERE SerialNumber IN :contactBySerialNum.keySet()
                AND CCR_CodentifyId__c NOT IN :codentifyId]) {
            if (contactBySerialNum.get(asset.SerialNumber).ContactId == asset.ContactId) {
                asset.PurchaseDate = contactBySerialNum.get(asset.SerialNumber).PurchaseDate;
                updateAsset.put(asset.Id, asset);
            }
        }
        if (!updateAsset.isEmpty() && !Test.isRunningTest()) update updateAsset.values();
    }


    /**
     * Asset First Link Date 넣기
     * - 가장 최근에 연결되었던 contact과 똑같은 contact이 연결되었을시, 업데이트 x
     * - 다른 contact 혹은 처음 contact 연결시, 업데이트 o
    */
    private void updateFirstLinkDate() {
        Set<Id> assetIds = new Set<Id>();
//        Map<Id, Id> contactByAsset = new Map<Id, Id>();
        Map<Id, Id> LastContactIdByAsset = new Map<Id, Id>();

        List<Asset> assetList = new List<Asset>();
        for (Asset asset : (List<Asset>) Trigger.new) {
            Asset oldAsset = (Asset) Trigger.oldMap.get(asset.Id);
            if (oldAsset.ContactId <> asset.ContactId && asset.ContactId != null && asset.ContactId != System.Label.KDCE_DefaultContactRental) {
                assetIds.add(asset.Id);
                assetList.add(asset);
//                contactByAsset.put(asset.Id, asset.ContactId);
            }
        }

        // Asset Life Cycle을 통해 이전에 연결을 한 Contact을 확인함
        for (CCR_AssetLifeCycle__c assetLifeCycle : [
                SELECT Id, CCR_Asset__c, CCR_Consumer__c, CCR_ActionDate__c FROM CCR_AssetLifeCycle__c
                WHERE CCR_Asset__c IN :assetIds AND CCR_Action__c = 'Link'
                ORDER BY CCR_ActionDate__c DESC ]) {
            if (!LastContactIdByAsset.containsKey(assetLifeCycle.CCR_Asset__c)) {
                LastContactIdByAsset.put(assetLifeCycle.CCR_Asset__c, assetLifeCycle.CCR_Consumer__c);
            }
        }

        for (Asset asset : assetList) {
            if (LastContactIdByAsset.containsKey(asset.Id) && LastContactIdByAsset.get(asset.Id) == asset.ContactId && asset.CCR_FirstLinkDatetoCurrentContact__c != null) continue;
            else asset.CCR_FirstLinkDatetoCurrentContact__c = System.today();    // TODO Today로 해도 맞는지 확인
        }
        System.debug('=== assetList : ' + assetList);
    }


}