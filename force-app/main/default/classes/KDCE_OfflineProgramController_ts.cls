/****************************************************************************************
  * @filename      : KDCE_OfflineProgramController_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-05-26 오후 3:28
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
    0.1     2021-05-26 오후 3:28     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_OfflineProgramController_ts {

    static Contact contact = KDCE_TestUtil.contactMember;
    static KDCE_Coupon__c coupon = KDCE_TestBizUtil.coupon;
    static KDCE_Coupon__c selectCoupon = [SELECT Id, Status__c, Contact__c, UsedDate__c FROM KDCE_Coupon__c WHERE Id = :coupon.Id];
    static KDCE_Store__c store = KDCE_TestBizUtil.store;
    static Asset holder = KDCE_TestUtil.assetHolder;
    static Asset charger = KDCE_TestUtil.assetCharger;
    static String assetVersion = holder.CCR_Version__c == null ? '3.0' : holder.CCR_Version__c;


    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    private static Map<String, List<Asset>> createRecordForTest() {
        Map<String, List<Asset>> assetMap = new Map<String, List<Asset>>();

        // Asset Select List
        Asset selectHolder = [SELECT Id, CCR_ReplacedBy__c, AccountId, ContactId, Status, CCR_OriginalAsset__c, CCR_CodentifyId__c, SerialNumber, CCR_DeviceProductCode__c, CCR_MaterialGroupDescription__c, CCR_Version__c, PurchaseDate, KDCE_DeviceLabelling__c, KDCE_RentalCount__c FROM Asset WHERE Id = :holder.Id];
        Asset selectCharger = [SELECT Id, CCR_ReplacedBy__c, AccountId, ContactId, Status, CCR_OriginalAsset__c, CCR_CodentifyId__c, SerialNumber, CCR_DeviceProductCode__c, CCR_MaterialGroupDescription__c, CCR_Version__c, PurchaseDate, KDCE_DeviceLabelling__c, KDCE_RentalCount__c FROM Asset WHERE Id = :charger.Id];
        List<Asset> selectList = new List<Asset>();
        selectList.add(selectHolder);
        selectList.add(selectCharger);

        // Contact Asset 연결 생성
        List<Asset> insertAssetList = new List<Asset>();
        Asset conHolder = selectHolder.clone(false, true);
        conHolder.Name = 'AssetHolder2';
        conHolder.CCR_CodentifyId__c = 'ContactHolder';
        conHolder.ContactId = contact.Id;
        Asset conCharger = selectCharger.clone(false, true);
        conCharger.Name = 'AssetCharger2';
        conCharger.CCR_CodentifyId__c = 'ContactCharger';
        conCharger.ContactId = contact.Id;
        insertAssetList.add(conHolder);
        insertAssetList.add(conCharger);
        insert insertAssetList;

        assetMap.put('selectList', selectList);
        assetMap.put('insertAssetList', insertAssetList);

        return assetMap;
    }

    @IsTest
    static void testBehavior01() {
        Test.startTest();
        KDCE_OfflineProgramController.getInvalidContact(contact.Id);
        KDCE_OfflineProgramController.getTypeList();
        KDCE_OfflineProgramController.getDefaultStore();
        Test.stopTest();
    }

    @IsTest
    static void testBehavior02() {
        Test.startTest();
        Asset asset = [SELECT Id, ContactId, Status, CCR_Version__c FROM Asset WHERE Id = :holder.Id];
        asset.Status = 'Active';
        asset.ContactId = contact.Id;
        KDCE_OfflineProgramController.checkValidKitToKiT(asset.Id);
        Test.stopTest();
    }

//    @IsTest
//    static void testBehavior03() {
//    }

    @IsTest
    static void testBehavior04() {
        Test.startTest();
        KDCE_OfflineProgramController.getDataTableHeader(contact.Id, 'ZTA');
        Test.stopTest();
    }

    @IsTest
    static void testBehavior05() {
        Test.startTest();
        KDCE_OfflineProgramController.getAssetList(holder.Id, 'ZTA', store.Id);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior06() {
        Test.startTest();
        KDCE_OfflineProgramController.checkCouponCount(coupon.Id);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior07() {
        Test.startTest();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZTAR', null, selectList, selectList, store.Id, store.Id, selectCoupon.Id, 'Starbucks', assetVersion, 'Reason1','Reason2', 'Sponsor', 'Sponsor', System.now(), 'Reference', 'Channel');
        Test.stopTest();
    }

    @IsTest
    static void testBehavior08() {
        Test.startTest();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZTI', insertAssetList, selectList, selectList, store.Id, store.Id, null, 'Starbucks', assetVersion, '', 'Reason', 'Sponsor', 'Sponsor',  System.now(), 'Reference', 'Channel');
//        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZTU', insertAssetList, selectList, selectList, store.Id, store.Id, null, 'Starbucks', assetVersion, '', 'Reason', 'Sponsor', System.now(), 'Reference', 'Channel');
        Test.stopTest();
    }

    @IsTest
    static void testBehavior09() {
        Test.startTest();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZTA', null, selectList, selectList, store.Id, store.Id, selectCoupon.Id, 'Starbucks', assetVersion, '', 'Reason', 'Sponsor', 'Sponsor', System.now(), 'Reference', 'Channel');
        Test.stopTest();
    }

    @IsTest
    static void testBehavior10() {
        Test.startTest();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZTA', null, selectList, selectList, store.Id, store.Id, null, 'Starbucks', assetVersion, '', 'Reason', 'Sponsor', 'Sponsor', System.now(), 'Reference', 'Channel');
        Test.stopTest();
    }

    @IsTest
    static void testBehavior11() {
        Test.startTest();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZTA', null, selectList, selectList, store.Id, store.Id, null, 'Starbucks', assetVersion, '', 'Reason', 'Sponsor', 'Sponsor', System.now(), 'Reference', 'Channel');
        Test.stopTest();
    }

    @IsTest
    static void testBehavior12() {
        Test.startTest();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZRN', null, selectList, selectList, store.Id, store.Id, null, null, null, null, null, null, null, System.now(), null, null);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior13() {
        Test.startTest();
        Id rt_Rental = Schema.SObjectType.KDCE_OfflineProgram__c.getRecordTypeInfosByDeveloperName().get('OfflineProgram_ZRN').getRecordTypeId();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        // 고객이 렌탈중인 기기가 있을때
        KDCE_OfflineProgram__c newOp = new KDCE_OfflineProgram__c(
                Contact__c = contact.Id,
                Status__c = 'Rental Process',
                RecordTypeId = rt_Rental
        );
        insert newOp;
        KDCE_OfflineProgramController.swapAsset(contact.Id, System.today(), System.today(), 'ZRN', null, selectList, selectList, store.Id, store.Id, null, null, null, null, null, null, null, System.now(), null, null);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior14() {
        Test.startTest();
        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');
        Asset asset = [SELECT Id, ContactId, CCR_Version__c FROM Asset WHERE Id = :holder.Id];
        asset.ContactId = contact.Id;
        update asset;
        System.debug('=== asset.CCR_Version__c : ' + asset.CCR_Version__c);

        KDCE_OfflineProgramController.swapAsset(asset.Id, System.today(), System.today(), 'ZRT', insertAssetList, selectList, selectList, store.Id, store.Id, coupon.Id, 'Starbucks', assetVersion, 'Other Software Malfunction', 'Other Software Malfunction', 'Sponsor', 'Sponsor', System.now(), 'Reference', 'Channel');
        Test.stopTest();
    }

    @IsTest
    static void testBehavior15() {
        Test.startTest();

        Map<String, List<Asset>> assetMap = createRecordForTest();
        List<Asset> selectList = assetMap.get('selectList');
        List<Asset> insertAssetList = assetMap.get('insertAssetList');

        // Material M으로 업데이트
        CCR_Material__c material = KDCE_TestUtil.materialHolder;
        material = [SELECT Id, Name, CCR_Group__c, CCR_Material__c, CCR_MaterialType__c, CCR_Version__c FROM CCR_Material__c WHERE Id = :material.Id];
        material.CCR_Version__c = '3.0M';
        update material;

        Asset asset = [SELECT Id, ContactId, CCR_Version__c FROM Asset WHERE Id = :holder.Id];
        asset.ContactId = contact.Id;
        update asset;
        System.debug('=== asset.CCR_Version__c : ' + asset.CCR_Version__c);

        KDCE_OfflineProgramController.swapAsset(asset.Id, System.today(), System.today(), 'ZRT', insertAssetList, selectList, selectList, store.Id, store.Id, coupon.Id, 'Starbucks', assetVersion, 'Other Software Malfunction', 'Other Software Malfunction', 'Sponsor', 'Sponsor', System.now(), 'Reference', null);
        Test.stopTest();
    }



}