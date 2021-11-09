/****************************************************************************************
  * @filename      : KDCE_TestUtil
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-02-10 오후 1:22
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
    0.1     2021-02-10 오후 1:22     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
public with sharing class KDCE_TestUtil {
    @SuppressWarnings('PMD')
    public static void init() {
    }

    public static Account account { get; set; }
    public static Contact contactAnonymous { get; set; }
    public static Contact contactMember { get; set; }
    public static Contact contactProspect { get; set; }

    public static Product2 product { get; set; }
    public static List<Asset> assetList;
//    public static Asset assetHolder{get; set;}
//    public static Asset assetCharger{get; set;}
    public static List<Case> caseList { get; set; }
    public static Case caseItem { get; set; }

    public static Case caseTest { get; set; }
    public static List<KDCE_Coupon__c> couponList { get; set; }
    public static KDCE_Coupon__c cpn { get; set; }

    public static Map<String, Id> recordTypeMap;

    public static void getRecordTypes() {
        recordTypeMap = new Map<String, Id>();
        List<RecordType> recordTypes = [SELECT Id, SobjectType, DeveloperName FROM RecordType];
        for (RecordType recordType : recordTypes) {
            recordTypeMap.put(recordType.SobjectType + '|' + recordType.DeveloperName, recordType.Id);
        }
    }

    public static Id getRecordTypeId(String sObjectName, String DeveloperName) {
        if (recordTypeMap == null) {
            getRecordTypes();
        }
        return recordTypeMap.get(sObjectName + '|' + DeveloperName);
    }

    /*
     * Account Data ==> Contact 만들 때 Account 자동 생성
     */
    public static Account getAccount() {
        if (account != null) return account;
        account = new Account(
                Name = 'Test Account'
        );
        insert account;
        return account;
    }

    static {
        if (account == null) {
            account = getAccount();
        }
    }
    /*
     * Contact Data 생성
     */

    public static Contact getContactMember() {

        if (contactMember != null) {
            System.debug('=== conatctMember : ' + contactMember);
            return contactMember;
        }
        System.debug('=== null이다 : ');
        Contact contactMember = new Contact(
                LastName = 'Contact Member',
                RecordTypeId = getRecordTypeId('Contact', 'Contact_Member'),
                MailingState = '서울특별시',
                OtherState = '서울특별시',
                KDCE_LASLAU__c = 'LAS',
                Birthdate = Date.newInstance(2021, 4, 27),
                KDCE_EmailMask__c = 'i2maxTest@i2max.co.kr',
                KDCE_BirthdateMask__c = '1995-03-21',
                Phone = '010999999999',
                Email = 'i2maxTest@i2max.co.kr',
                KDCE_MarketingOptIn__c = false,
                KDCE_InformationOptIn__c = false,
                KDCE_JoinedPMKChannel__c = false,
                KDCE_Name__c = 'Contact Member',
                KDCE_IsDormant__c = false,
                AccountId = account.Id,
                KDCE_IsStoreContact__c = false,
                KDCE_Store__c = null
        );
        System.debug('=== contactMember : ' + contactMember);
        insert contactMember;
        return contactMember;
    }

    public static Contact getContactAnonymous() {

        if (contactAnonymous != null) return contactAnonymous;
        Contact contactAnonymous = new Contact(
                LastName = 'Contact Anonymous',
                RecordTypeId = getRecordTypeId('Contact', 'Contact_Anonymous')
        );

        insert contactAnonymous;
        return contactAnonymous;
    }

    public static Contact getContactProspect() {

        System.debug('contactProspect : ' + contactProspect);
        if (contactProspect != null) return contactProspect;

        Contact contactProspect = new Contact(
                Email = 'test11@test.com',
                LastName = 'Contact Prospect',
                Phone = '0101241251',
                RecordTypeId = getRecordTypeId('Contact', 'Contact_Prospect')
        );

        System.debug('contactProspect : ' + contactProspect);
        

        insert contactProspect;
        return contactProspect;
    }

    static {
        if (contactAnonymous == null) {
            contactAnonymous = getContactAnonymous();
        }

        if (contactProspect == null) {
            List<Contact> contacts = [select Id, LastName From Contact];
            System.debug(contacts);
            contactProspect = getContactProspect();
        }

        if (contactMember == null) {
            contactMember = getContactMember();
        }
    }


    /*
     * Product - 제품 패키지
     */

    public static Product2 getProduct() {
        Product2 product = new Product2(
                Name = 'productCodeTest',
                ProductCode = 'productCodeTest',
                CCR_Category__c = 'M0401',
                CCR_OriginalDesignMarket__c = 'RU04',
                CCR_Version__c = '3.0M',
                KDCE_EANCode__c = 'eanCode'
        );
        insert product;
        return product;
    }

    static{
        if(product == null) product = getProduct();
    }


    /*
     * Asset Data
     * Codentify :: 새기기일 경우 - 12자리 / 반납할 경우 - 14자리
     * SerialNumber가 없다가 붙으면,
     */

//    public static Asset getAsset() {
//        Asset asset = new Asset(
//                Name = 'codentifyTest00',
//                AccountId = account.Id,
//                Status = 'Produced',
//                CCR_CodentifyId__c = 'codentifyTest00',
//                SerialNumber = 'parentCondentify00'
//
//        );
//
//        return asset;
//    }

    /*
     * Material
     */
    public static CCR_Material__c getMaterial() {
        System.debug('@@ CCR_Material__c @@');
        if(materialHolder != null) return materialHolder;
        // Holder
        CCR_Material__c materialHolder = new CCR_Material__c(
                Name = 'Holder /S',
                CCR_Group__c = 'D0101',
                CCR_Material__c = 'Holder /S',
                CCR_MaterialType__c = 'Material Group Description',
                CCR_Version__c = '3.0'
        );

        insert materialHolder;
        return materialHolder;
    }


    public static CCR_Material__c materialHolder {get; set;}
    public static CCR_Material__c materialCharger {get; set;}
    public static CCR_Material__c materialholderChild {get; set;}
    public static CCR_Material__c materialchargerChild {get; set;}

    static {
        if(materialHolder == null) {
            materialHolder = getMaterial();
        }

        if(materialCharger == null){
            materialCharger = materialHolder.clone(false, true);
            materialCharger.Name = 'Pocket Charger /S';
            materialCharger.CCR_Group__c = 'D0201';
            materialCharger.CCR_Material__c = 'Pocket Charger /S';
            materialCharger.CCR_MaterialType__c = 'Material Group Description';

            insert materialCharger;
        }

        if(materialholderChild == null){
            materialholderChild = materialHolder.clone(false, true);
            materialholderChild.Name = 'DVC11781';
            materialholderChild.CCR_Group__c = 'D0101';
            materialholderChild.CCR_Material__c = 'DVC11781';
            materialholderChild.CCR_GroupDescription__c = materialholder.Id;
            materialholderChild.CCR_Description__c = 'HTP Holder IQOS 3 DUO GOLD A1406 - A1406 RND BRG3.1 Korea Holder (NB) - FL';

            insert materialholderChild;
        }

        if(materialchargerChild == null){
            materialchargerChild = materialHolder.clone(false, true);
            materialchargerChild.Name = 'DVC11782';
            materialchargerChild.CCR_Group__c = 'D0101';
            materialchargerChild.CCR_Material__c = 'DVC11782';
            materialchargerChild.CCR_GroupDescription__c = materialcharger.Id;
            materialchargerChild.CCR_Description__c = 'Pocket Charger IQOS A1503 - A1503 RND NAV2.4 PLUS';


            insert materialchargerChild;
        }

        System.debug('materialHolder: '  + materialHolder);
        System.debug('materialCharger: ' + materialCharger);
        System.debug('materialholderChild: ' + materialholderChild);
        System.debug('materialchargerChild: ' + materialchargerChild);
    }


    public static Asset getAssetHolder() {
        System.debug('assetHolder@@' + assetHolder);

        Asset asset = new Asset (
                Name = 'codentifyTest00',
                AccountId = account.Id,
                Status = 'Produced',
                CCR_CodentifyId__c = 'codentifyTest0',
                SerialNumber = 'parentCodent',
                CCR_DeviceProductCode__c = materialHolderChild.Id,
                CCR_ProductionDateTime__c = System.today(),
                Product2Id = product.Id
        );
        System.debug('assetHolder@@' + assetHolder);

        insert asset;
        System.debug('assetHolder@@' + assetHolder);

        return asset;
    }

    public static Asset getAssetCharger() {
        Asset asset = new Asset (
                Name = 'codentifyTest01',
                AccountId = account.Id,
                Status = 'Produced',
                CCR_CodentifyId__c = 'codentifyTest01',
                SerialNumber = 'parentCondentify00',
                CCR_DeviceProductCode__c = materialChargerChild.Id,
                CCR_ProductionDateTime__c = System.today(),
                Product2Id = product.Id
        );
        insert asset;
        return asset;
    }
    public static Asset assetHolder { get; set; }
    public static Asset assetCharger { get; set; }

    static {
        if (assetHolder == null) {
            assetHolder = getAssetHolder();
        }


        if (assetCharger == null) {
            assetCharger = getAssetCharger();
            System.debug('assetCharger : ' + assetCharger.CCR_MaterialGroupDescription__c);
        }
    }


    /*
     * Case
     */
//    public static List<Case> getCaseList() {
//        if (caseList != null) return caseList;
//        caseList = new List<Case>();
//
//        Case defaultCase = new Case (
//                Subject = 'Test Case',
//                Description = 'This is Test Case',
//                SuppliedName = contactMember.LastName,
//                Origin = 'Web',
//                CCR_ContactType__c = 'Webpage',
//                ContactId = contactMember.Id,
//                Status = 'New',
//                KDCE_SendNPS__c = 'Yes',
//                SuppliedPhone = '0101231231'
//        );
//        System.debug('=== defaultCase : ' + defaultCase);
//        caseList.add(defaultCase);
//
//        Case noContactCase = defaultCase.clone(false, true);
//        noContactCase.ContactId = null;
//        caseList.add(noContactCase);
//
//        Case chatCase = defaultCase.clone(false, true);
//        chatCase.Origin = 'Chat';
//        caseList.add(chatCase);
//
//        Case sendSMSCase = defaultCase.clone(false, true);
//        sendSMSCase.KDCE_SendNPS__c = 'Yes';
//        sendSMSCase.KDCE_NPSsent__c = false;
////        sendSMSCase.ParentId = defaultCase.Id;
//        caseList.add(sendSMSCase);
//
//        insert caseList; //case_tr시 오류 --> 주석(0531)
//
//        sendSMSCase.ParentId = defaultCase.Id;
//        caseList.add(sendSMSCase);
//        update sendSMSCase; //case_tr시 오류 --> 주석(0531)
//        return caseList;
//    }
    static {
//        if (caseList == null) {
//            caseList = getCaseList();
//        }
        if (caseItem == null) {
            caseItem = getCaseItem();
        }
    }

    public static Case getCaseItem() {
        if (caseItem != null) return caseItem;
        caseItem = new Case (
                Subject = 'Test Case',
                Description = 'This is Test Case',
                SuppliedName = contactMember.LastName,
                Origin = 'Web',
                CCR_ContactType__c = 'Webpage',
                ContactId = contactMember.Id,
                Status = 'New',
                KDCE_SendNPS__c = 'Yes',
                SuppliedPhone = '0101231231'
        );
        insert caseItem; //case_tr시 오류 --> 주석(0531)

        return caseItem;
    }


    public static List<KDCE_Coupon__c> getCouponList() {
        System.debug('=== contactMember : ' + contactMember);
        if (couponList != null) return couponList;
        if (contactMember == null) {
            contactMember = getContactMember();
            insert contactMember;
        }

        couponList = new List<KDCE_Coupon__c>();

        // MGM Coupon (List index [0])
        KDCE_Coupon__c mgmCoupon = new KDCE_Coupon__c(
                CouponCode__c = 'TestCouponMgm',
                Contact__c = contactMember.Id,
                RecordTypeId = getRecordTypeId('KDCE_Coupon__c', 'Coupon_MGM'),
                Type__c = 'MGM'
        );
        couponList.add(mgmCoupon);

        insert couponList;
        return couponList;
    }

    static {
        if (couponList == null)
            couponList = getCouponList();
    }

    /*
       * Offline Program
       */
    public static KDCE_OfflineProgram__c getOfflineProgram() {
        if (offlineProgram != null) return offlineProgram;
        System.debug('assetHolder :: ' + assetHolder);
        offlineProgram = new KDCE_OfflineProgram__c(
                Contact__c = contactMember.Id,
                ProgramType__c = 'ZTA',
//                Status__c = 'Complete',
                NewHolder__c = assetHolder.Id,
                NewCharger__c = assetCharger.Id
        );
        insert offlineProgram;
        return offlineProgram;
    }

    public static KDCE_OfflineProgram__c offlineProgram{get; set;}

    static {
        if(offlineProgram == null) {
            offlineProgram = getOfflineProgram();
        }
    }
        /*
       * Asset Life Cycle
       */
    public static CCR_AssetLifeCycle__c getAssetLifeCycle() {
        if (assetLifeCycle != null) return assetLifeCycle;
        System.debug('assetHolder :: ' + assetHolder);
        CCR_AssetLifeCycle__c alc = new CCR_AssetLifeCycle__c(
                CCR_Asset__c = assetHolder.Id,
                CCR_Action__c = 'Link',
                CCR_ActionDate__c = System.now(),
                CCR_Consumer__c = contactMember.Id
        );
        insert alc;
        return alc;
    }

    public static CCR_AssetLifeCycle__c assetLifeCycle { get; set; }

    static {
        if (assetLifeCycle == null) {
            assetLifeCycle = getAssetLifeCycle();
        }
    }


}