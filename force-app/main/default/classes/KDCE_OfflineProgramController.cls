/****************************************************************************************
  * @filename      : KDCE_OfflineProgramController
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-06 오전 10:14
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
    0.1     2021-04-06 오전 10:14     i2max_Jihyun.Lee        Create
****************************************************************************************/

public without sharing class KDCE_OfflineProgramController {

    public static Map<String, String> pickVal = KDCE_Util.getPicklistValue('KDCE_OfflineProgram__c', 'ProgramType__c');
    public static Map<String, String> replaceReasonPickVal = KDCE_Util.getPicklistValue('KDCE_TempObjectForLookupField__c', 'CCR_ReplacementReasonHolder__c');

    /**
     * @param recordId
     *
     * @return Boolean
     * @description 휴면고객이나 탈퇴고객일 경우, Offline Program 불가
     */
    @AuraEnabled
    public static Boolean getInvalidContact(Id recordId) {
        System.debug('@@@@@@ getInvalidContact @@@@@@');
        Boolean invalidContact = false;
        Contact con = [SELECT Id, KDCE_IsDropout__c, KDCE_IsDormant__c FROM Contact WHERE Id = :recordId];
        if (con.KDCE_IsDropout__c == true || con.KDCE_IsDormant__c) invalidContact = true;

        System.debug('=== invalidContact : ' + invalidContact);
        return invalidContact;
    }

    /**
     * @return Offline Program Option Picklist
     */
    @AuraEnabled
    public static List<Map<String, String>> getTypeList() {
        System.debug('@@@@@@ getTypeList @@@@@@');

        List<Map<String, String>> options = new List<Map<String, String>>();

        for (String pick : pickVal.keySet()) {
            options.add(new Map<String, String> {
                    'label' => pickVal.get(pick), 'value' => pick
            });
        }
        System.debug('=== options : ' + options);
        return options;
    }

    @AuraEnabled
    public static Id getDefaultStore() {
        System.debug('@@@@@@ getDefaultStore @@@@@@');

        Id defaultStore = null;
        String userDivision;
        User user = [SELECT Id, Name, Department, Division FROM User WHERE Id =: UserInfo.getUserId()];
        userDivision = user.Division;
        System.debug('=== userDivision : ' + userDivision);

        if (userDivision != null) {
            List<KDCE_Store__c> store = [SELECT Id FROM KDCE_Store__c WHERE CompanyCode__c = :userDivision];
            if (!store.isEmpty()) defaultStore = store[0].Id;
        }
        System.debug('=== defaultStore : ' + defaultStore);
        return defaultStore;
    }

    /**
     * @param recordId
     *
     * @return ReturnClass
     * @description 해당 Asset이 Kit to Kit이 가능한지 체크
     */
    @AuraEnabled
    public static ReturnClass checkValidKitToKiT(Id recordId) {
        ReturnClass rtClass = new ReturnClass();

        Asset asset = [SELECT Id, ContactId, Status, CCR_Version__c FROM Asset WHERE Id = :recordId];
        Contact contact;
        if (asset.Status != KDCE_GlobalValue.ASSET_STATUS_ACTIVE) {
            rtClass.result = 'error';
            rtClass.errorMessage = System.Label.KDCE_AssetNotActiveStatus;
        }
        if (asset.ContactId == null) {
            rtClass.result = 'error';
            rtClass.errorMessage = System.Label.KDCE_AssetNotConnectedWithContact;
        }
        else {
            contact = [SELECT Id, KDCE_IsDormant__c, KDCE_IsDropout__c, KDCE_IsStoreContact__c FROM Contact WHERE Id = :asset.ContactId];
            if (contact.KDCE_IsDropout__c || contact.KDCE_IsDormant__c || contact.KDCE_IsStoreContact__c) {
                rtClass.result = 'error';
                rtClass.errorMessage = System.Label.KDCE_NotKitToKitDormantAndDropContact;
//                if (contact.KDCE_IsStoreContact__c) rtClass.errorMessage = 'Store Dummy는 Kit to Kit 프로그램을 진행할 수 없습니다.';
            }
        }

        if (rtClass.result != 'error') {
            rtClass.assetVersion = asset.CCR_Version__c;
        }

        return rtClass;
    }


    /**
     * @param recordId
     * @param value
     *
     * @return Return Class
     * @description Contact과 연결된 Asset List, DataTable의 Header 정보 반환
     *              Offline Program은 Contact에 버튼, Kit to Kit은 Asset에서 버튼을 누름
     */
    @AuraEnabled
    public static ReturnClass getDataTableHeader(Id recordId, String value) {
        System.debug('@@@@@@ getDataTableHeader @@@@@@');

        ReturnClass rtnClass = new ReturnClass();

        // Value 별 Label 값 생성
        String selectValue = pickVal.get(value);
        rtnClass.selectValue = selectValue;

        // Header 값 생성 (Default로 보여줌)
        rtnClass.headerList.add(new HeaderColumn('Parent Codentify', 'SerialNumber', 'String'));                    // Parent Codentify
        rtnClass.headerList.add(new HeaderColumn('Codentify', 'CCR_CodentifyId__c', 'String'));                     // Codentify
        rtnClass.headerList.add(new HeaderColumn('Status', 'Status', 'String'));                                    // Status
        rtnClass.headerList.add(new HeaderColumn('Version', 'CCR_Version__c', 'String'));                           // Version
        rtnClass.headerList.add(new HeaderColumn('Material Type', 'CCR_MaterialGroupDescription__c', 'String'));    // Material Group Description
        rtnClass.headerList.add(new HeaderColumn('Purchase Date', 'PurchaseDate', 'Date'));                         // Purchase Date
        rtnClass.headerList.add(new HeaderColumn('Purchase Channel', 'CCR_PurchaseChannel__c', 'String'));          // Purchase Channel

        /**
         * Offline Program - Contact 기반 검색
        */
        Contact contact;
        // Rental 중인 고객일 경우, Offline Program Rental 불가
        if (value != KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {
            contact = [SELECT Id, KDCE_RentalConsumer__c, KDCE_LASLAU__c FROM Contact WHERE Id = :recordId];
            rtnClass.isLAU = contact.KDCE_LASLAU__c == 'LAU' ? true : false;
        }

        /**
         * Kit to Kit - Asset 기반 검색
         * 해당 Asset에서 연결된 Contact기준으로, 일치하는 Parent Codentify Asset 같이 찾아줌
        */
        String serialNumber;
        Id contactId;
        if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {
            Asset contactAsset = [SELECT Id, SerialNumber, CCR_Version__c, ContactId FROM Asset WHERE Id = :recordId];
            serialNumber = contactAsset.SerialNumber;
            contactId = contactAsset.ContactId;
        }


        // 해당 Contact이 소유하고 있는 Asset List
        System.debug('=== value : ' + value);
        List<Asset> assetList;
        String query = '';
        query += ' SELECT  Id, Name, SerialNumber, CCR_CodentifyId__c, Status, PurchaseDate, CCR_MaterialGroupDescription__c ';
        query += ' ,KDCE_DeviceLabelling__c, CCR_PurchaseChannel__c, KDCE_RentalCount__c, CCR_Version__c ';
        query += ' FROM Asset ';
        query += ' WHERE Status = \'Active\' ';
        if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) query += ' AND SerialNumber = :serialNumber AND ContactId = :contactId ';
        else query += ' AND ContactId = :recordId ';
        query += ' ORDER BY SerialNumber ASC ';
        assetList = Database.query(query);
        System.debug('=== query : ' + query);

        rtnClass.assetList = assetList;
        System.debug('=== rtnClass.assetList : ' + rtnClass.assetList);
        return rtnClass;
    }

    /**
     * @param lookupId
     * @param value
     *
     * @return Return Class
     * @description 변경할 Asset 검색 (Rental의 경우 Store 검색)
     */
    @AuraEnabled
    public static ReturnClass getAssetList(Id lookupId, String value, Id storeLookupId) {
        System.debug('@@@@@@ getAssetList @@@@@@');
        System.debug('=== lookupId : ' + lookupId);
        System.debug('=== value : ' + value);
        System.debug('=== storeLookupId : ' + storeLookupId);

        String parentCodentify;
        List<Asset> searchAsset;
        List<Contact> contactList;
        Set<Id> contactIdSet = new Set<Id>();

        // Rental 진행시, 초기에 Default로 설정되어 있는 Store 기반 Asset 목록을 나타내기 위한 로직
        if (value == KDCE_GlobalValue.ORDER_TYPE_RENTAL && lookupId == NULL) lookupId = storeLookupId;

        // Rental이 아닐 경우, 검색한 Asset Parent Codentify 가져옴
        if (value != KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
            searchAsset = [SELECT Id, SerialNumber, ContactId FROM Asset WHERE Id = :lookupId];
            parentCodentify = !searchAsset.isEmpty() ? searchAsset[0]?.SerialNumber : null;
        }
        // Rental의 경우 Store 기반 검색이기 때문에, 해당 Store와 연결된 Rental Dummy Contact 가져옴
        else {
            contactList = [SELECT Id, KDCE_Store__c FROM Contact WHERE KDCE_Store__c = :lookupId];
            System.debug('=== contactList : ' + contactList);
            for (Contact con : contactList) contactIdSet.add(con.Id);
        }
        System.debug('=== contactIdSet : ' + contactIdSet);

        String query = '';
        query += '  SELECT  Id, Name, SerialNumber, CCR_CodentifyId__c, Status, PurchaseDate, CCR_MaterialGroupDescription__c, ';
        query += '  CCR_PurchaseChannel__c, KDCE_DeviceLabelling__c, KDCE_RentalCount__c, CCR_Version__c    ';
        query += '  FROM    Asset ';
        if (value != KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
            query += ' WHERE    (Status = \'Active\' OR Status = \'Produced\') ';
            query += ' AND      ContactId = NULL  AND SerialNumber = :parentCodentify ';
        }
        else {
            query += ' WHERE    ContactId IN :contactIdSet ';
            query += ' AND      (CCR_Version__c = \'3.0M\' OR CCR_Version__c = \'3.1\') ';   // Rental일 경우 3.0M, 3.1 버전만 가능함
            query += ' AND      KDCE_DisposalDevice__c = false ';                           // 불용처리된 기기는 제외하도록 함 (2021.07.06 지현 추가)
        }
        List<Asset> assetList = Database.query(query);
        System.debug('=== assetList : ' + assetList);
        // Contact Asset DataTable 값 만들기
        ReturnClass rtnClass = new ReturnClass();
        rtnClass.assetList = assetList;
        if (assetList.isEmpty()) rtnClass.result = 'error';
        return rtnClass;
    }

    // Coupon 유효한지 확인
    @AuraEnabled
    public static ReturnClass checkCouponCount(Id couponLookupId) {
        System.debug('@@@@@@ checkCouponCount @@@@@@');

        // Coupon이 유효한 Coupon인지 Check (Purchase 경의 MGM 쿠폰과 같이 구매할 수 있다.) Coupon Lookup 필드에 MGM 조건이 걸려져있어서 MGM 조건은 생략하기로 한다.
        KDCE_Coupon__c coupon;
        if (couponLookupId != null) {
            coupon = [SELECT Id, fm_UseCount__c FROM KDCE_Coupon__c WHERE Id = :couponLookupId];
        }
        ReturnClass rtnClass = new ReturnClass();
        rtnClass.mgmCount = (Integer) coupon.fm_UseCount__c;
        return rtnClass;
    }

    /*
     * Trade-In, Upgrade, Kit to Kit: 기존 고객 소유 Device 및 대체할 Device 선택. 홀더, 차저 두개씩 선택해야함 (두개의 Parent Codentify는 일치해야함)
     * Replacement: 홀더, 차저 각각 교환가능하기때문에 단건 처리해야함
     * Rental: 대체할 Device만 선택. 홀더, 차저 두개씩
     * Purchase, Rental Purchase: 홀더, 차저 링크
     */
    @SuppressWarnings('PMD')
    @AuraEnabled
    public static Map<String, String> swapAsset(Id recordId, Date selectedDate, Date selectedRentalStartDate, String value, List<Asset> selectedConAsset, List<Asset> assetData, List<Asset> selectedAsset, Id storeLookupId, Id lookupId, Id couponLookupId, String selectGifticon,
            String assetVersion, String replacementReasonHolder, String replacementReasonCharger, String replacementSponsoredByHolder, String replacementSponsoredByCharger, Datetime replacementDate, String replacementExternalReference, String replacementChannel) {
        System.debug('@@@@@@ swapAsset @@@@@@');
        System.debug('=== value : ' + value);
        System.debug('=== storeLookupId : ' + storeLookupId);
        System.debug('=== selectedConAsset : ' + selectedConAsset);

        Map<String, String> resultMap = new Map<String, String>();  // 결과값 반환

        // 고객의 Asset을 선택하지 않는 Offline Program 유형 (일반주문, Rental, 렌탈 후 구매)
        Set<String> notSelectOldAsset = new Set<String>{
                KDCE_GlobalValue.ORDER_TYPE_NORMAL, KDCE_GlobalValue.ORDER_TYPE_RENTAL, KDCE_GlobalValue.OFF_PG_TYPE_RTLBUY
        };

        List<Asset> updateAssetList = new List<Asset>();
        Map<Id, Contact> updateContact = new Map<Id, Contact>();
        Contact contact;
        Asset searchAsset;
        Contact searchContact;
        // Kit to Kit - Asset / 나머지 - Contact
        if (value != KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {
            contact = [SELECT Id, KDCE_RentalConsumer__c, KDCE_MGMUseCount__c FROM Contact WHERE Id = :recordId];
        } else {
            searchAsset = [SELECT Id, ContactId, CCR_Version__c FROM Asset WHERE Id = :recordId];
            System.debug('=== searchAsset : ' + searchAsset);
            searchContact = [SELECT Id FROM Contact WHERE Id = :searchAsset.ContactId];
            contact = searchContact;
            /**VALIDATION**/
            // 해당 Asset의 버전과 선택과 asset의 Version이 일치하지 않으면 안됨
            if (searchAsset.CCR_Version__c <> assetVersion) {
                resultMap.put('error', '버전 일치 안함');
                return resultMap;
            }
        }

        Asset oldCharger;
        Asset oldHolder;
        Asset newCharger;
        Asset newHolder;

        String originAssetCharger; // 가장 최초로 교환된 Asset의 Codentify Id
        String originBoxCharger;   // 가장 최초로 교환된 Asset의 Parent Codentify Id
        String originAssetHolder;
        String originBoxHolder;

        String newChargerVersion;
        String newHolderVersion;

        // 고객이 소유한 Asset -> oldAsset으로 저장
        // Rental, 구매, Rental 후 구매일 경우 해당없음

        if (!notSelectOldAsset.contains(value)) {
            for (Asset oldAsset : selectedConAsset) {

                if (value == KDCE_GlobalValue.ORDER_TYPE_TRADEIN) {
                    oldAsset.Status                     = KDCE_GlobalValue.ASSET_STATUS_RETURNED;
                    oldAsset.KDCE_DeviceLabelling__c    = KDCE_GlobalValue.ASSET_LABEL_OFFTRADEINR;
                }
                else if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {
                    oldAsset.Status = KDCE_GlobalValue.ASSET_STATUS_REPLACED;
                    oldAsset.CCR_ReplacementDate__c                 = selectedDate;
                    oldAsset.CCR_ReplacementDoneBy__c               = UserInfo.getUserId();
                    oldAsset.CCR_ReplacementDate__c                 = replacementDate;
                    oldAsset.CCR_ReplacementExternalReference__c    = replacementExternalReference;
                    oldAsset.CCR_ReplacementChannelNew__c           = replacementChannel;
                }

                /**
                 * Holder, Charger에 각각 연결
                 * Origin 데이터 입력
                 * (교체 기기의 CCR_OriginalAsset__c 가 null => originAssetHolder - CCR_CodentifyId__c, originBoxHolder - SerialNumber)
                */
                if (oldAsset.CCR_MaterialGroupDescription__c?.contains('Holder')) {
                    oldAsset.CCR_ReplacementReason__c = replaceReasonPickVal.containsKey(replacementReasonHolder) ? replaceReasonPickVal.get(replacementReasonHolder) : replacementReasonHolder;
                    oldAsset.CCR_ReplacementSponsored_By__c = replacementSponsoredByHolder;
                    oldHolder = oldAsset;
                    if (oldAsset.CCR_OriginalAsset__c == null) {
                        originAssetHolder   = String.valueOf(oldAsset.CCR_CodentifyId__c);
                        originBoxHolder     = String.valueOf(oldAsset.SerialNumber);
                    } else {
                        originAssetHolder   = String.valueOf(oldAsset.CCR_OriginalAsset__c);
                        originBoxHolder     = String.valueOf(oldAsset.CCR_OriginalBox__c);
                    }
                }
                else if (oldAsset.CCR_MaterialGroupDescription__c?.contains('Charger')) {
                    oldAsset.CCR_ReplacementReason__c = replaceReasonPickVal.containsKey(replacementReasonCharger) ? replaceReasonPickVal.get(replacementReasonCharger) : replacementReasonCharger;
                    oldAsset.CCR_ReplacementSponsored_By__c = replacementSponsoredByCharger;
                    oldCharger = oldAsset;
                    if (oldAsset.CCR_OriginalAsset__c == null) {
                        originAssetCharger   = String.valueOf(oldAsset.CCR_CodentifyId__c);
                        originBoxCharger     = String.valueOf(oldAsset.SerialNumber);
                    } else {
                        originAssetCharger   = String.valueOf(oldAsset.CCR_OriginalAsset__c);
                        originBoxCharger     = String.valueOf(oldAsset.CCR_OriginalBox__c);
                    }
                }
            }
        }


        /*
         * 교체할 신규 Asset -> newAsset으로 저장 , 신규 Asset 필드 업데이트
         */
        if (value == KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
            for (Asset newAsset : selectedAsset) {
                System.debug('=== 여기탄다 : ');
                newAsset.Status                     = KDCE_GlobalValue.ASSET_STATUS_LOCKED;
                newAsset.ContactId                  = contact.Id;
                newAsset.AccountId                  = null;
                newAsset.KDCE_DeviceLabelling__c    = KDCE_GlobalValue.ASSET_LABEL_RENTING;
                newAsset.KDCE_RentalCount__c        = newAsset.KDCE_RentalCount__c + 1;
                newAsset.CCR_PurchaseChannel__c     = null;

                // Contact Update
                contact.KDCE_RentalConsumer__c = true;
                updateContact.put(contact.Id, contact); // Contact Rental 필드 업데이트

                if (newAsset.CCR_MaterialGroupDescription__c?.contains('Holder')) {
                    newHolder = newAsset;
                    newHolderVersion = newAsset.CCR_Version__c;
                }
                else if (newAsset.CCR_MaterialGroupDescription__c?.contains('Charger')) {
                    newCharger = newAsset;
                    newChargerVersion = newAsset.CCR_Version__c;
                }
            }
        }
        // Rental을 제외하곤, 신규기기 검색후 선택하지 않고 해당하는 Asset List 반환 (assetData)
        else {
            for (Asset newAsset : assetData) {
                newAsset.Status                     = KDCE_GlobalValue.ASSET_STATUS_ACTIVE;
                newAsset.ContactId                  = contact.Id;
                newAsset.AccountId                  = null;
                newAsset.CCR_PurchaseChannel__c     = KDCE_GlobalValue.ASSET_PURCHASE_CHANNEL_DIRECT;
                newAsset.PurchaseDate               = selectedDate;
                newAsset.CCR_OriginalAsset__c       = String.valueOf(newAsset.CCR_CodentifyId__c);
                newAsset.CCR_OriginalBox__c         = String.valueOf(newAsset.SerialNumber);

                if (value == KDCE_GlobalValue.ORDER_TYPE_NORMAL) {                  // 일반주문
                }
                else if (value == KDCE_GlobalValue.ORDER_TYPE_TRADEIN) {            // 트레이드인 주문
                    newAsset.KDCE_DeviceLabelling__c    = KDCE_GlobalValue.ASSET_LABEL_OFFTRADEIN;
                }
                else if (value == KDCE_GlobalValue.OFF_PG_TYPE_RTLBUY) {            // 렌탈 후 구매 주문
                    newAsset.KDCE_DeviceLabelling__c    = KDCE_GlobalValue.ASSET_LABEL_OFFRENTAL;
                }
                else if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {          // Kit to Kit 주문 (Replacement)

                    newAsset.KDCE_ReplacementSource__c              = 'KIT TO KIT';
                    // 다른 value와는 다른 값 설정
                    newAsset.PurchaseDate = null;
                    newAsset.CCR_PurchaseChannel__c = null;
                }
                else if (value == KDCE_GlobalValue.OFF_PG_TYPE_UPGRADE) {           // Upgrade 주문
                    newAsset.KDCE_DeviceLabelling__c    = KDCE_GlobalValue.ASSET_LABEL_UPGRADE;
                }

                if (newAsset?.CCR_MaterialGroupDescription__c?.contains('Holder')) {
                    newHolder = newAsset;
                    newHolderVersion = newAsset.CCR_Version__c;
                    if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {
                        newHolder.CCR_OriginalAsset__c  = originAssetHolder;
                        newHolder.CCR_OriginalBox__c    = originBoxHolder;
                    }

                }
                else if (newAsset?.CCR_MaterialGroupDescription__c?.contains('Charger')) {
                    newCharger = newAsset;
                    newChargerVersion = newAsset.CCR_Version__c;
                    if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {
                        newCharger.CCR_OriginalAsset__c = originAssetCharger;
                        newCharger.CCR_OriginalBox__c   = originBoxCharger;
                    }
                }
            }
        }
        System.debug('=== newCharger : ' + newCharger);
        System.debug('=== newHolder : ' + newHolder);
        System.debug('=== oldCharger : ' + oldCharger);
        System.debug('=== oldHolder : ' + oldHolder);



        /**
         * Validation Rule 처리
        */
        System.debug('=== validation 처리 ===');
        System.debug('=== storeLookupId : ' + storeLookupId);
        // Rental을 제외한 나머지 유형일 경우, Store 입력 필수
        if (value != KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
            if (storeLookupId == null) {
                resultMap.put('error', System.Label.KDCE_MustEnterStore);
                return resultMap;
            }
        }

        // KIT TO KIT, Trade-in, Upgrade
        System.debug('=== value : ' + value);
        Map<String, Integer> versionCountMap = new Map<String, Integer>();
        Integer count;
        if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT || value == KDCE_GlobalValue.ORDER_TYPE_TRADEIN || value == KDCE_GlobalValue.OFF_PG_TYPE_UPGRADE) {


            // Version에 M이 들어간건 멀티이기 때문에 Charger를 선택안하지만, M이 아닌 경우엔 두개를 선택해야한다.
            if ((oldHolder.CCR_Version__c.contains('M') && oldCharger != null) || (!oldHolder.CCR_Version__c.contains('M') && oldCharger == null)) {
                if (oldHolder.CCR_Version__c.contains('M')) resultMap.put('error', System.Label.KDCE_MustChoiceHolder);
                else resultMap.put('error', System.Label.KDCE_MustSelectHolderCharger);
                return resultMap;
            }

            // 두개 선택시, 똑같은 버전만 교환가능하다
            if (oldHolder != null && oldCharger != null && oldHolder.CCR_Version__c != oldCharger.CCR_Version__c) {
                resultMap.put('error', System.Label.KDCE_MustSelectSameVersion);
                return resultMap;
            }

            // KITTOKIT일 경우 따로 처리
            if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {
                // Parent Codentify가 일치해야함
                if (oldHolder.SerialNumber <> oldCharger.SerialNumber) {
                    resultMap.put('error', System.Label.KDCE_MustMatchHolderCharger);
                    return resultMap;
                }

            }
            else {
                // 반납기기 선택시, 3.1버전은 반납 불가
                if (oldHolder?.CCR_Version__c == '3.1' || oldCharger?.CCR_Version__c == '3.1') {
                    resultMap.put('error', System.Label.KDCE_InvalidReturnVersion);
                    return resultMap;
                }
            }

            // Trade-in일 경우 따로 처리 (무조건 버전 별로 2회까지만 가능하도록 해야함)
            if (value == KDCE_GlobalValue.ORDER_TYPE_TRADEIN) {
                for (KDCE_OfflineProgram__c op : [
                        SELECT Id, NewHolder__r.CCR_Version__c, NewCharger__r.CCR_Version__c, OldHolder__r.CCR_Version__c, OldCharger__r.CCR_Version__c
                        FROM KDCE_OfflineProgram__c
                        WHERE   Contact__c = :contact.Id
                        AND ProgramType__c = :KDCE_GlobalValue.ORDER_TYPE_TRADEIN
                        AND Status__c != :KDCE_GlobalValue.OFF_PG_STATUS_CANCEL
                ]) {
                    if (op.NewHolder__c != null) {
                        if (versionCountMap.containsKey(op.NewHolder__r?.CCR_Version__c)) {
                            versionCountMap.put(op.NewHolder__r?.CCR_Version__c, versionCountMap.get(op.NewHolder__r?.CCR_Version__c) + 1);
                        } else versionCountMap.put(op.NewHolder__r?.CCR_Version__c, 1);
                    }
                }
                System.debug('=== versionCountMap : ' + versionCountMap);
                if (versionCountMap.containsKey(newHolder.CCR_Version__c) && versionCountMap.get(newHolder.CCR_Version__c) > 1) {
                    resultMap.put('error', System.Label.KDCE_TradeinCanVersionTwice);
                    return resultMap;
                }
            }
        }
        // selectedDate Validation
        if (selectedDate != null) {
            if (selectedDate > System.today()) {
                resultMap.put('error', System.Label.KDCE_PurchaseCanOnlyTodayOrPastDay);
                return resultMap;
            }
        }




        /*
         * Rental의 경우 Validation Rule 추가
         * 1) 추심중인 고객
         * 2) 렌탈중인 기기 (version이 같지 않아도 불가)
         * 3) 동일 모델 구매이력 / 동일 모델 렌탈이력 불가 :: 온라인 렌탈 (Order), 오프라인 프로그램
         * 4) 동일 모델 Active한 기기가 있으면 렌탈 불가
         */
        List<Contact> checkCurrentRentalContact;
        List<KDCE_OfflineProgram__c> checkCurrentRentalOPList = new List<KDCE_OfflineProgram__c>();
        Set<String> notAvailOPStatus = new Set<String>{
                KDCE_GlobalValue.OFF_PG_STATUS_CANCEL, KDCE_GlobalValue.OFF_PG_STATUS_RTNCANCEL, KDCE_GlobalValue.OFF_PG_STATUS_RTNREFUND
        };
        Set<String> contactPurchaseVersion = new Set<String>();
        Set<String> contactActiveVersion = new Set<String>();

        List<KDCE_Order__c> checkCollectOrderList;
        if (value == KDCE_GlobalValue.ORDER_TYPE_RENTAL) {

            // 1) 추심 중인지 확인
            checkCollectOrderList = [
                    SELECT  Id FROM KDCE_Order__c
                    WHERE   Contact__c = :contact.Id
                    AND     CollectionStatus__c IN :KDCE_GlobalValue.ORDER_COL_STATUS_INPROGRESS_SET
            ];

            // 2) 렌탈 중인 고객인지 확인
            checkCurrentRentalContact = [
                    SELECT  Id, KDCE_RentalConsumer__c FROM Contact
                    WHERE   Id = :contact.Id
                    AND     KDCE_RentalConsumer__c = TRUE
            ];
//            checkCurrentRentalOPList = [
//                    SELECT  Id FROM KDCE_OfflineProgram__c
//                    WHERE   Contact__c = :contact.Id
//                    AND     Status__c = :KDCE_GlobalValue.OFF_PG_STATUS_RTNPROCESS
//            ];
//            System.debug('=== checkCurrentRentalOrderList : ' + checkCurrentRentalOrderList);
//            System.debug('=== checkCurrentRentalOPList : ' + checkCurrentRentalOPList);

            // 3) 동일 모델 구매/ 렌탈 이력이 있는지 -> 동일 모델 렌탈 이력이 있는지로 수정 (07.13)
            for (KDCE_OrderLineItem__c oli : [
                    SELECT  Id, Product__r.CCR_Version__c FROM KDCE_OrderLineItem__c
                    WHERE   Order__r.Contact__c = :contact.Id
                    AND     ( OrderType__c = :KDCE_GlobalValue.ORDER_TYPE_RENTAL OR OrderType__c = :KDCE_GlobalValue.ORDER_TYPE_RENTALNEW )
                    AND     OrderStatus__c = :KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED
//                    AND     Order__r.OrderStatus__c != :KDCE_GlobalValue.ORDER_STATUS_CLOSE     // TODO Order Status 조건 확인
            ]) {
                System.debug('=== oli : ' + oli);
                if (oli.Product__c != null) contactPurchaseVersion.add(oli.Product__r?.CCR_Version__c);
            }
            for (KDCE_OfflineProgram__c op : [
                    SELECT Id, NewHolder__r.CCR_Version__c, NewCharger__r.CCR_Version__c, OldHolder__r.CCR_Version__c, OldCharger__r.CCR_Version__c
                    FROM KDCE_OfflineProgram__c
                    WHERE   Contact__c = :contact.Id
                    AND     ( ProgramType__c = :KDCE_GlobalValue.ORDER_TYPE_RENTAL OR ProgramType__c = :KDCE_GlobalValue.ORDER_TYPE_RENTALNEW )
                    AND     Status__c = :KDCE_GlobalValue.OFF_PG_STATUS_RTNCLOSED
//                    AND Status__c != :KDCE_GlobalValue.OFF_PG_STATUS_CANCEL
//                    AND Status__c != :KDCE_GlobalValue.OFF_PG_STATUS_RTNCANCEL
            ]) {
                System.debug('=== op : ' + op);
                if (op.NewHolder__c != null) contactPurchaseVersion.add(op.NewHolder__r?.CCR_Version__c);
                if (op.NewCharger__r != null) contactPurchaseVersion.add(op.NewCharger__r?.CCR_Version__c);
                if (op.OldHolder__r != null) contactPurchaseVersion.add(op.OldHolder__r?.CCR_Version__c);
                if (op.OldCharger__r != null) contactPurchaseVersion.add(op.OldCharger__r?.CCR_Version__c);
            }
            System.debug('=== contactUseVersion : ' + contactPurchaseVersion);

            // 4) 동일 모델 Active한 기기가 있으면 렌탈 불가 -> 안하도록 수정 (07.13)
//            for (Asset asset : [
//                    SELECT Id, CCR_Version__c FROM Asset WHERE ContactId = :contact.Id AND Status = :KDCE_GlobalValue.ASSET_STATUS_ACTIVE
//            ]) {
//                System.debug('=== asset : ' + asset);
//                if (asset.CCR_Version__c != null) contactActiveVersion.add(asset.CCR_Version__c);
//            }
//            System.debug('=== contactActiveVersion : ' + contactActiveVersion);
//            System.debug('=== newChargerVersion : ' + newChargerVersion);
//            System.debug('=== newHolderVersion : ' + newHolderVersion);

            /** Rental Validation **/
            // 추심중이면 에러
            if (!checkCollectOrderList.isEmpty()) {
                resultMap.put('error', System.Label.KDCE_NotPossibleWhenCollectProgress);
                return resultMap;
            }
            // 렌탈중인 고객이면 에러
            if (!checkCurrentRentalContact.isEmpty() && checkCurrentRentalContact[0].KDCE_RentalConsumer__c) {
                resultMap.put('error', System.Label.KDCE_ContactCurrentRental);
                return resultMap;
            }
            // 똑같은 버전 렌탈 이력이 있으면 에러
            if (contactPurchaseVersion.contains(newChargerVersion) || contactPurchaseVersion.contains(newHolderVersion)) {
                resultMap.put('error', System.Label.KDCE_ContactPurchaseHistorySameVersion);
                return resultMap;
            }
            // 똑같은 버전 소유하고 있으면 에러
//            if (contactActiveVersion.contains(newChargerVersion) || contactActiveVersion.contains(newHolderVersion)) {
//                resultMap.put('error', System.Label.KDCE_ContactHaveSameVersion);
//                return resultMap;
//            }
            // Version에 M이 들어간건 멀티이기 때문에 Charger를 선택안하지만, M이 아닌 경우엔 두개를 선택해야한다.
            if ((newHolder.CCR_Version__c?.contains('M') && newCharger != null) || (!newHolder.CCR_Version__c?.contains('M') && newCharger == null)) {
                if (newHolder.CCR_Version__c?.contains('M')) resultMap.put('error','멀티 제품 구매시, Holder 한가지만 선택가능합니다.');
                else resultMap.put('error', System.Label.KDCE_MustSelectHolderCharger);
                return resultMap;
            }
        }

        System.debug('=== validation 처리 끝 ===');

        if (value == KDCE_GlobalValue.OFF_PG_TYPE_KITTOKIT) {       // 2021.06.25 Trade-in 로직 넣었다가 제거

            if (newCharger != null && oldCharger != null) {
                oldCharger.CCR_ReplacedBy__c    = newCharger.Id;
                newCharger.CCR_Replaces__c      = oldCharger.Id;
            }
            if (newHolder != null && oldHolder != null) {
                oldHolder.CCR_ReplacedBy__c      = newHolder.Id;
                newHolder.CCR_Replaces__c        = oldHolder.Id;
            }
        }

        // Asset 업데이트
        if (newCharger != null) updateAssetList.add(newCharger);
        if (newHolder != null) updateAssetList.add(newHolder);
        if (oldCharger != null) updateAssetList.add(oldCharger);
        if (oldHolder != null) updateAssetList.add(oldHolder);


        // Offline Program 생성
        KDCE_OfflineProgram__c op = new KDCE_OfflineProgram__c();
        //op.ActionDate__c    = System.today();
        op.ActionDate__c    = System.now();
        op.Contact__c       = contact.Id;
        op.NewCharger__c    = newCharger?.Id;
        op.NewHolder__c     = newHolder?.Id;
        op.OldCharger__c    = oldCharger?.Id;
        op.OldHolder__c     = oldHolder?.Id;
        op.ProgramType__c   = value;
        op.Coupon__c        = couponLookupId;

        if (value == KDCE_GlobalValue.ORDER_TYPE_RENTAL) {
//            contact.KDCE_RentalConsumer__c = true;
            op.RentalStartDate__c	= selectedRentalStartDate;
            op.RentalEndDate__c     = selectedRentalStartDate.addDays(14);
            //op.Store__c             = lookupId;
            op.Store__c             = storeLookupId;
            op.Status__c            = KDCE_GlobalValue.OFF_PG_STATUS_RTNPROCESS;
        }
        else {
            op.Store__c             = storeLookupId;
            op.Status__c            = KDCE_GlobalValue.OFF_PG_STATUS_COMPLETE;
            op.PurchaseDate__c      = selectedDate;
        }

        // Coupon 상태 업데이트
        // TODO 만약 Coupon은 선택했는데 Gifticon은 선택안했으면?
        KDCE_Coupon__c mgmCoupon;
        KDCE_CouponHistory__c mgmCouponHistory;
        Map<Id, KDCE_Coupon__c> mgmCouponMap = new Map<Id, KDCE_Coupon__c>();
        List<KDCE_CouponService.CouponWrapper> CouponWrappers = new List<KDCE_CouponService.CouponWrapper>();
        KDCE_CouponService.CouponWrapper ow = new KDCE_CouponService.CouponWrapper();

        if (couponLookupId != null) {
            // Contact MGM Count 업데이트
//            contact.KDCE_MGMUseCount__c = contact.KDCE_MGMUseCount__c + 1;

            // Coupon 값 업데이트
            mgmCoupon = [SELECT Id, Status__c, Contact__c, UsedDate__c  FROM KDCE_Coupon__c WHERE Id = :couponLookupId];
            mgmCoupon.Status__c = KDCE_GlobalValue.COUPON_STATUS_USE; // Use로 변환
            mgmCoupon.UsedDate__c = selectedDate;   // TODO Used Date 안쓴다고?
            mgmCouponMap.put(mgmCoupon.Id, mgmCoupon);

            // Coupon History 생성
            ow.couponId = mgmCoupon.Id;
            ow.contactId = contact.Id;
            ow.actionDate = Datetime.now();
            ow.actionType = KDCE_GlobalValue.COUPON_STATUS_USE;
            ow.gifticon = selectGifticon != null ? selectGifticon : null;

            CouponWrappers.add(ow);
        }

        Savepoint sp = Database.setSavepoint();

        System.debug('=== updateAssetList : ' + updateAssetList);
        System.debug('=== op : ' + op);
        try {
            if (!updateAssetList.isEmpty()) update updateAssetList;
            if (op != null)                 insert op;
            if (!updateContact.isEmpty())   update updateContact.values();
            if (mgmCoupon != null) {
                update mgmCoupon;
                KDCE_CouponService.createCouponUseHistory(CouponWrappers, 'Offline');    // Coupon Use History 생성
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('=== e : ' + e.getMessage());
            resultMap.put('error', e.getMessage());
            return resultMap;
        }
        resultMap.put('success', 'success!');
        return  resultMap;
    }


    /*
     * DataTable을 위한 Return Class
     */
    public class ReturnClass {

        @AuraEnabled public String result {get; set;}
        @AuraEnabled public String errorMessage {get; set;}
        @AuraEnabled public String recordId {get; set;}
        @AuraEnabled public List<HeaderColumn> headerList {get; set;}
        @AuraEnabled public List<Asset> assetList {get; set;}
        @AuraEnabled public Map<String, String> parameter {get; set;}
        @AuraEnabled public String selectValue {get; set;}
        @AuraEnabled public Integer mgmCount {get; set;}
        @AuraEnabled public Boolean isLAU {get; set;}
        @AuraEnabled public String assetVersion {get; set;}

        public ReturnClass(){
            this.result = 'Success';
            this.errorMessage = '';
            this.headerList = new List<HeaderColumn>();
            this.parameter = new Map<String, String>();
        }
    }

    /*
     * DataTable 구성하는 값 Inner Class
     */
    public class HeaderColumn {

        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Integer initialWidth { get; set; }

        public HeaderColumn(String label, String fieldName, String type){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.initialWidth = 160;
        }

    }
}