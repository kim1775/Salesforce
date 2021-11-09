/****************************************************************************************
  * @filename      : KDCE_ContactLinkAssetController
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-02-19 오전 9:24
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
    0.1     2021-02-19 오전 9:24     i2max_Jihyun.Lee        Create
****************************************************************************************/

public without sharing class KDCE_ContactLinkAssetController {

    // 검색 가능한 Asset Status
    final static Set<String> availStatus = new Set<String>{
            'Produced', 'Active'
    };

    /**
     * @param recordId
     *
     * @return Boolean
     * @description 휴면고객이거나 탈퇴 고객인 경우, Asset 연결 불가
     */
    @AuraEnabled
    public static Boolean getInvalidContact(Id recordId) {
        Boolean invalidContact = false;
        Contact con = [SELECT Id, KDCE_IsDropout__c, KDCE_IsDormant__c FROM Contact WHERE Id = :recordId];
        if (con.KDCE_IsDropout__c || con.KDCE_IsDormant__c) invalidContact = true;
        System.debug('=== invalidContact : ' + invalidContact);
        return invalidContact;
    }

    /**
     * @param recordId
     *
     * @return String
     * @description Asset의 ContactId 존재 -> Unlink만 가능    / ContactId 존재x -> Link만 가능
     * @author 이지현
     */
    @AuraEnabled
    public static ReturnClass getInvalidStatus(Id recordId) {

        Asset ass = [SELECT Id, ContactId, Status FROM Asset WHERE Id = :recordId];
        System.debug('=== ass.ContactId : ' + ass.ContactId);

        ReturnClass rtn = new ReturnClass();
        rtn.contactLink = 'false';
        if (ass.ContactId != null) rtn.contactLink = 'true';
        rtn.assetStatus = ass.Status;

        return rtn;
    }

    /**
     * @author
     * @param lookupId
     *
     * @return ReturnClass
     * @description Contact 오브젝트에서 Asset Link 검색시, 데이터테이블에 대한 내역 반환
     */
    @AuraEnabled
    public static ReturnClass getAssetList(Id lookupId) {
        System.debug('=== getAssetList===');

        // 해당 Asset의 Parent Codentify 찾기
        String parentCodentify;
        String query = '';
        query += ' SELECT Id, SerialNumber FROM Asset ';
        if (lookupId != null) query += ' WHERE Id =:lookupId ';     // 기본값으로 DataTable의 Header값 반환할땐 구성 x
        query += ' LIMIT 5000';
        List<Asset> targetAsset = Database.query(query);
        parentCodentify = targetAsset[0]?.SerialNumber;

        List<Asset> assetList = [
                SELECT Id, Name, SerialNumber, CCR_CodentifyId__c, Status, CCR_MaterialGroupDescription__c, PurchaseDate,
                        CCR_PurchaseChannel__c, CCR_Version__c, CCR_MaterialDescription__c
                FROM Asset
                WHERE SerialNumber = :parentCodentify
                AND ContactId = NULL
                AND Status IN :availStatus
        ];
        System.debug('=== assetList : ' + assetList);

        // DataTable 값 만들기
        ReturnClass rtn = new ReturnClass();
        // DataTable Header 값 생성
        rtn.headerList.add(new HeaderColumn('Parent Codentify', 'SerialNumber', 'String'));                     // Parent Codentify
        rtn.headerList.add(new HeaderColumn('Codentify', 'CCR_CodentifyId__c', 'String'));                      // Codentify
        rtn.headerList.add(new HeaderColumn('Status', 'Status', 'String'));                                     // Status
        rtn.headerList.add(new HeaderColumn('Version', 'CCR_Version__c', 'String', 100));                            // Version
        rtn.headerList.add(new HeaderColumn('Material Type', 'CCR_MaterialGroupDescription__c', 'String'));     // Material Group
        rtn.headerList.add(new HeaderColumn('Material Description', 'CCR_MaterialDescription__c', 'String', 600));   // Material Description
        rtn.headerList.add(new HeaderColumn('Purchase Date', 'PurchaseDate', 'Date'));                          // Purchase Date
        rtn.headerList.add(new HeaderColumn('Purchase Channel', 'CCR_PurchaseChannel__c', 'String'));           // Purchase Channel

        // DataTable Data 값 생성
        rtn.assetList = assetList;
        System.debug('=== rtn : ' + rtn);
        return rtn;
    }

    /**
     * @param lookupId
     * @param recordId
     * @param sObjectName
     *
     * @description Asset 오브젝트에서 Link버튼 클릭시, Asset과 Contact 연결
     *              - Asset Type != Rental => 동일한 Parent Codentify인 나머지 Asset 다 연결
     * @author 이지현
     */
    @AuraEnabled
    public static void createContactLink(Id lookupId, Id recordId) {

        Contact con = [SELECT Id FROM Contact WHERE Id = :lookupId LIMIT 1];
        Asset asset = [SELECT Id, Name, Status, AccountId, ContactId, SerialNumber FROM Asset WHERE Id = :recordId LIMIT 1];
        if (asset.Status == KDCE_GlobalValue.ASSET_STATUS_LOCKED || asset.Status == null) throw new AuraHandledException(System.Label.KDCE_InvalidUnlinkStatus);

        List<Asset> updateAssetList = new List<Asset>();    // 업데이트할 Asset List

        String parentCodentify = asset.SerialNumber;  // 검색한 Asset의 Parent Codentify

        List<Asset> searchAssetList = [
                SELECT Id, Status, ContactId, AccountId, CCR_CodentifyId__c, SerialNumber, CCR_OriginalAsset__c, CCR_OriginalBox__c
                FROM Asset
                WHERE SerialNumber = :parentCodentify
                AND ContactId = NULL
                AND Status IN :availStatus
        ];

        // TODO 해당 Asset은 조건이 적합한데,, Parent Codentify가 일치하는 다른 Asset의 조건이 적합하지 않을때
        System.debug('=== searchAssetList : ' + searchAssetList);

        for (Asset searchAsset : searchAssetList) {
            searchAsset.Status      = 'Active';
            searchAsset.ContactId   = con.Id;
            searchAsset.AccountId   = null;   // Asset과 Contact 연결시, Account 연결은 해제
            if (searchAsset.CCR_OriginalAsset__c == null) searchAsset.CCR_OriginalAsset__c   = String.valueOf(searchAsset.CCR_CodentifyId__c);
            if (searchAsset.CCR_OriginalBox__c == null) searchAsset.CCR_OriginalBox__c     = String.valueOf(searchAsset.SerialNumber);
            updateAssetList.add(searchAsset) ;
        }

        try {
            if (updateAssetList.size() > 0) update updateAssetList;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e);
        }
    }

    /**
     * @param selectedList
     * @param recordId
     *
     * @description Contact 오브젝트에서 Link 버튼 클릭시, Contact과 Asset 연결
     * @author 이지현
     */
    @AuraEnabled
    public static void createAssetLink(List<Map<String, String>> selectedList, Id recordId) {
        System.debug('=== selectedList : ' + selectedList);
        Set<Id> recordIdSet = new Set<Id>();    // 선택된 Asset 데이터 값 Id 저장

        for (Map<String, String> ass : selectedList) {
            recordIdSet.add(ass.get('Id'));
        }

        // Asset Link시, 필드 업데이트
        List<Asset> assList = [
                SELECT Id, Name, Status, AccountId, ContactId, CCR_CodentifyId__c, SerialNumber, CCR_OriginalAsset__c, CCR_OriginalBox__c
                FROM Asset
                WHERE Id IN :recordIdSet
        ];
        for (Asset asset : assList) {
            asset.ContactId     = recordId;
            asset.Status        = 'Active';
            asset.AccountId     = null;
            if (asset.CCR_OriginalAsset__c == null) asset.CCR_OriginalAsset__c   = String.valueOf(asset.CCR_CodentifyId__c);
            if (asset.CCR_OriginalBox__c == null) asset.CCR_OriginalBox__c     = String.valueOf(asset.SerialNumber);
        }
        System.debug('=== assList : ' + assList);


        try {
            update assList;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e);
        }
    }

    /**
     * @param recordId
     *
     * @description Asset 오브젝트에서 Unlink 버튼 클릭시, Asset과 Contact 연결 해제 (해당 Asset만 연결해제)
     * @author 이지현
     */
    @AuraEnabled
    public static void createAssetUnlink(Id recordId) {

        Map<String, String> resultMap = new Map<String, String>();

        String defaultAccId = Label.KDCE_DefaultAccount;    // Contact연결 해제시, 연결할 Account Id

        // Asset 검색
        Asset asset = [SELECT Id, ContactId, AccountId, Status, KDCE_DeviceType__c, SerialNumber, CCR_Version__c, CCR_MaterialGroupDescription__c FROM Asset WHERE Id = :recordId];
        // 해당 Asset이 Rental일 경우 Unlink 불가
        if (asset.Status == KDCE_GlobalValue.ASSET_STATUS_LOCKED) throw new AuraHandledException('Rental 기기는 Unlink가 불가능합니다.');

        List<Asset> updateAssetList = new List<Asset>();    // 업데이트할 Asset List
        // Asset 필드 업데이트
        asset.AccountId = defaultAccId;
        asset.ContactId = null;
        updateAssetList.add(asset);


        try {
            if (!updateAssetList.isEmpty()) update updateAssetList;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e);
        }

    }

    /*
     * DataTable을 위한 Return Class
     */
    public class ReturnClass {

        @AuraEnabled public String result { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public List<HeaderColumn> headerList { get; set; }
        @AuraEnabled public List<Asset> assetList { get; set; }
        @AuraEnabled public Map<String, String> parameter { get; set; }
        @AuraEnabled public Boolean invalidStatus {get; set;}
        @AuraEnabled public String notAvailReason {get; set;}
        @AuraEnabled public String contactLink {get; set;}
        @AuraEnabled public String assetStatus {get; set;}

        public ReturnClass() {
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

        public HeaderColumn(String label, String fieldName, String type) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.initialWidth = 160;
        }

        public HeaderColumn(String label, String fieldName, String type, Integer initialWidth) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.initialWidth = initialWidth;
        }
    }

}