/****************************************************************************************
  * @filename      : KDCE_TestBizUtil
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-27 오후 12:03
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
    0.1     2021-04-27 오후 12:03     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_TestBizUtil {
    public static void init() {
        KDCE_TestUtil.init();
    }


    public static Map<String, Id> recordTypeMap;

    /*
     * Record Type
     */
    public static void getRecordTypes () {
        recordTypeMap = new Map<String, Id>();
        List<RecordType> recordTypes = [SELECT Id, SobjectType, DeveloperName FROM RecordType];
        for (RecordType recordType : recordTypes) {
            recordTypeMap.put(recordType.SobjectType + '|' + recordType.DeveloperName, recordType.Id);
        }
    }

    public static Id getRecordTypeId (String sObjectName, String DeveloperName) {
        if (recordTypeMap == null) {
            getRecordTypes();
        }
        return recordTypeMap.get(sObjectName + '|' + DeveloperName);
    }
    /*
    * Contact
    */
   /* public static Contact getContact() {
        if (contMem != null) return contMem;
        contMem = new Contact(
                LastName = 'KimContact',
                RecordTypeId = getRecordTypeId('Contact', 'Contact_Member'),
                Email = 'test123@test.com',
                Phone = '01011111111'
        );
        insert contMem;
        return contMem;
    }

    public static Contact contMem{get; set;}

    static {
        if(contMem == null) {
            contMem = getContact();
        }
    }*/
    /*
     * Asset Data
     */
   /* public static Asset getAsset(){
       // if (asset != null) return asset;

        Asset asset = new Asset(
                Name = 'codentifyTest000',
                ContactId = contMem.Id,
                Status = '',
                CCR_CodentifyId__c = 'codentifyTest000',
                SerialNumber = 'parentCodentify000'

        );
        insert asset;
        return asset;
    }

    public static Asset asset {get; set;}

    static {
        if(asset == null) {
            asset = getAsset();
        }
    }

*/
    /*
     * Order Data
     */
    public static KDCE_Order__c getOrder(){
        //if (order != null) return order;
        KDCE_Order__c order = new KDCE_Order__c(
                Contact__c = KDCE_TestUtil.contactMember.Id,
                OrderStatus__c = '',
                OrderType__c = KDCE_GlobalValue.ORDER_TYPE_NORMAL
        );
        insert order;
        return order;
    }

    public static KDCE_Order__c order {get; set;}

    static {
        if(order == null) {
            order = getOrder();
        }
    }

    /*
     * Order Line Item Data
     */

    public static KDCE_OrderLineItem__c getOrderLineItem(Id orderId) {
        //if (orderLineItem != null) return orderLineItem;
        orderLineItem = new KDCE_OrderLineItem__c(
                Order__c = orderId == null? order.Id :orderId,
                Codentify__c = 'parentCodentify00'
        );
        insert orderLineItem;
        return orderLineItem;
    }
    public static KDCE_OrderLineItem__c orderLineItem {get; set;}

    static {
        if(orderLineItem == null) {
            orderLineItem = getOrderLineItem(null);
        }
    }


    /*
     * Material
     */
/*    public static CCR_Material__c getMaterial() {
        if(materialHolder != null) return materialHolder;
        // Holder
        //CCR_Material__c materialHolderLv0 = new CCR_Material__c(
        materialHolder = new CCR_Material__c(
                Name = 'Holder /S',
                CCR_Group__c = 'D0101',
                CCR_Material__c = 'Holder /S',
                CCR_MaterialType__c = 'Material Group Description'
        );
        //materialList.add(materialHolderLv0);

//        CCR_Material__c materialHolderLv1 = materialHolderLv0.clone();
//        materialHolderLv1.Name = 'DVC2191C';
//        materialList.add(materialHolderLv1);
//
//        CCR_Material__c materialHolderLv2 = materialHolderLv1.clone();
//        materialHolderLv2.Name = 'DVC0463';
//        materialHolderLv2.CCR_BrandFamily__c = 'IQOS';
//        materialHolderLv2.CCR_Description__c = 'Holder /S IQOS A1402 - A1402 RND SLT';
//        materialHolderLv2.CCR_Material__c = 'DVC0463';
//        materialHolderLv2.CCR_ModelNumber__c = 'A1402';
//        materialHolderLv2.CCR_Version__c = '2.4';
//        materialList.add(materialHolderLv2);

        // Charger
//        CCR_Material__c materialChargerLv0 = new CCR_Material__c(
//                Name = 'Pocket Charger /S',
//                CCR_Group__c = 'D0201',
//                CCR_Material__c = 'Pocket Charger /S',
//                CCR_MaterialType__c = 'Material Group Description'
//        );
//        materialList.add(materialChargerLv0);
//
//        CCR_Material__c materialChargerLv1 = materialChargerLv0.clone();
//        materialChargerLv1.Name = 'DVC.000034';
//        materialChargerLv1.CCR_BrandFamily__c = 'IQOS';
//        materialChargerLv1.CCR_Description__c = 'Pocket Charger /S IQOS A1502 RND WHT';
//        materialChargerLv1.CCR_Material__c = 'DVC.000034';
//        materialChargerLv1.CCR_ModelNumber__c = 'A1502';
//        materialList.add(materialChargerLv1);

//        insert materialList;

        // Group Description 연결
//        materialHolderLv1.CCR_GroupDescription__r = materialHolderLv0;
//        materialHolderLv2.CCR_GroupDescription__r = materialHolderLv1;
//        materialChargerLv1.CCR_GroupDescription__r = materialChargerLv0;
//
//        materialList.add(materialHolderLv1);
//        materialList.add(materialHolderLv2);
//        materialList.add(materialChargerLv1);
//
//        update materialList;

        return materialHolder;
    }


    public static CCR_Material__c materialHolder {get; set;}
    public static CCR_Material__c materialCharger {get; set;}

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
    }*/

    /*
     * Coupon Data
     */

    public static KDCE_Coupon__c getCoupon() {
        if (coupon != null) return coupon;
        coupon = new KDCE_Coupon__c (
                Name = 'coupon Name',
                Contact__c = null,
                Status__c = KDCE_GlobalValue.COUPON_STATUS_ISSUE,
                Type__c = 'MGM'
        );
        insert coupon;
        return coupon;
    }

    public static KDCE_Coupon__c coupon{get; set;}

    static {
        if (coupon == null) {
            coupon = getCoupon();
        }
    }

    /*
     * Offline Program
     */
    public static KDCE_OfflineProgram__c getOfflineProgram() {
        if (offlineProgram != null) return offlineProgram;
        System.debug('assetHolder :: ' + KDCE_TestUtil.assetHolder);
        offlineProgram = new KDCE_OfflineProgram__c(
                Contact__c = KDCE_TestUtil.getContactMember().Id,
                ProgramType__c = 'ZTA',
                Status__c = 'Complete',
                NewHolder__c = KDCE_TestUtil.assetHolder.Id,
                NewCharger__c = KDCE_TestUtil.assetCharger.Id
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
     * Store
     */
    public static KDCE_Store__c getStore() {
        if (store != null) return store;
        store = new KDCE_Store__c(
                Name = 'Store Direct',
                RecordTypeId = getRecordTypeId('KDCE_Store__c', 'Store_Direct'),
                BizNum__c = '1108120980',
                CompanyCode__c = '1761',
                BizLOCCode__c = '00007',
                OpenDate__c = Date.newInstance(2018, 12, 18),
                CloseDate__c = Date.newInstance(2999, 12, 31)
        );
        insert store;
        return store;
    }

    public static KDCE_Store__c store{get; set;}

    static {
        if(store == null) {
            store = getStore();
        }
    }

    /*
     * Term and Condition
     */
    public static TermsandConditions__c getTermsAndConditions(){
        if (tnC != null) return tnC;
        TermsandConditions__c tnC = new TermsandConditions__c(
                Approval_Status__c = 'Pending',
                Approved__c = false,
                CAA_isRequired__c = false,
                CCR_Language__c = 'ko',
                CCR_TACCountry__c = 'KR',
                DTE_StartDate__c = Datetime.newInstance(2021, 2, 25),
                DTE_TermsAndConditions__c = '<h1>5.개인정보 국외이전에 대해 동의합니다.</h1>',
                DTE_Version__c = 1.0,
                KDCE_Active__c = true,
                KDCE_Channel__c = 'iqos.com',
                KDCE_ChannelOrder__c = 5.0,
                KDCE_TnCVersionSet__c = '1.0',
                KDCE_VersionName__c = '1',
                KDCE_VersionNumber__c = 1.0,
                Title__c = '(필수) 개인정보 수집 및 이용',
                X_KDCE_Group__c = 'Sign up',
                KDCE_SubGroup__c = 'PMPO'
        );
        insert tnC;
        System.debug('=== tnc : ' + tnC);
        return tnC;
    }

    public static TermsandConditions__c tnC {get; set;}

    static {
        if(tnC == null) {
            tnC = getTermsAndConditions();
        }
    }


    /*
    * Terms and Conditions Version
    */
    public static KDCE_TnCVersion__c getTnCVersion(){
        if (tnCVersion != null) return tnCVersion;
        KDCE_TnCVersion__c tnCVersion = new KDCE_TnCVersion__c(
                EndDate__c = Date.newInstance(2020, 9, 16),
                IsActive__c = true,
                Name = 'IQOS.com version 2',
                StartDate__c = Date.newInstance(2000, 9, 16),
                VersionNumber__c = 2.0
        );
        System.debug('=== tnCVersion : ' + tnCVersion);
        insert tnCVersion;
        return tnCVersion;
    }

    public static KDCE_TnCVersion__c tnCVersion {get; set;}

    static {
        if(tnCVersion == null) {
            tnCVersion = getTnCVersion();
        }
    }

    /*
    * Terms and Conditions Version
    */
    public static KDCE_TnCVersionSet__c	getTnCVersionSet(){
        if (tnCVersionSet != null) return tnCVersionSet;
        KDCE_TnCVersionSet__c tncVersionSet = new KDCE_TnCVersionSet__c(
                Channel__c = 'iqos.com',
                ChannelNo__c = 4.0,
                InfomationOptin__c = false,
                MarketingOptin__c = false,
                TaC__c = tnc.Id,
                TnCVersion__c = tnCVersion.Id

        );
        insert tnCVersionSet;
        return tnCVersionSet;
    }

    public static KDCE_TnCVersionSet__c tnCVersionSet {get; set;}

    static {
        if(tnCVersionSet == null) {
            tnCVersionSet = getTnCVersionSet();
        }
    }

    /*
     * Terms and Conditions Accepted
     */
    public static KDCE_TnCAccepted__c getTnCAccepted(){
        if (tnCAccepted != null) return tnCAccepted;
        KDCE_TnCAccepted__c tncAccepted = new KDCE_TnCAccepted__c(
                Accepted__c = true,
                Contact__c = KDCE_TestUtil.contactMember.Id,
                ExternalId__c = 'KDCE_TnCAcceptedExternalId',
                TnC__c = tnC.Id,
                TnCVersionSet__c = tnCVersionSet.Id
        );
        insert tncAccepted;
        return tncAccepted;
    }

    public static KDCE_TnCAccepted__c tnCAccepted {get; set;}

    static {
        if(tnCAccepted == null) {
            tnCAccepted = getTnCAccepted();
        }
    }


    /*
     * Terms and Conditions History
     */
    public static KDCE_TnCHistory__c getTnCHistory(){
        if (tnCHistory != null) return tnCHistory;
        KDCE_TnCHistory__c tncHistory = new KDCE_TnCHistory__c(
                CCR_Acceptance_Date__c = Datetime.newInstance(2021, 3, 21),
                DTE_Contact__c = KDCE_TestUtil.contactMember.Id,
                KDCE_Accepted__c = true,
                KDCE_Channel__c = 'iqos.com',
                KDCE_TnCVersionSet__c = tnCVersionSet.Id
        );
        insert tncHistory;
        return tncHistory;
    }

    public static KDCE_TnCHistory__c tnCHistory {get; set;}

    static {
        if(tnCHistory == null) {
            tnCHistory = getTnCHistory();
        }
    }


    /*
     * Survey
     */
    public static Survey__c	 getSurvey(){
        if (survey != null) return survey;
        Survey__c survey = new Survey__c	(
                Name = 'Test Survey',
                Thank_You_Text__c = 'empty'
        );
        insert survey;
        return survey;
    }

    public static Survey__c	 survey {get; set;}

    static {
        if(survey == null) {
            survey = getSurvey();
        }
    }


    /*
     * Survey
     */
    public static SurveyTaker__c getSurveyTaker(){
        if (surveyTaker != null) return surveyTaker;
        SurveyTaker__c surveyTaker = new SurveyTaker__c(
                Survey__c = survey.Id,
                Contact__c = KDCE_TestUtil.contactMember.Id
        );
        insert surveyTaker;
        return surveyTaker;
    }

    public static SurveyTaker__c surveyTaker {get; set;}

    static {
        if(surveyTaker == null) {
            surveyTaker = getSurveyTaker();
        }
    }

    /*
     * Task
     */
    public static Task getTask(){
        if (testTask != null) return testTask;
        Task testTask = new Task(
                WhoId = KDCE_TestUtil.getContactMember().Id,
                ConversationId__c = 'Test Conversation Id'
        );
        insert testTask;
        return testTask;
    }

    public static Task testTask {get; set;}

    static {
        if(testTask == null) {
            testTask = getTask();
        }
    }

    /*
     * Notification Temp
     */
    public static NotificationTemplate__c getNotiTemp(){
        if (notiTemp != null) return notiTemp;
        NotificationTemplate__c notiTemp = new NotificationTemplate__c(
                Name = 'Noti',
                Channel__c = '0',
                Content__c = 'Content',
                LABEL1__c = true,
                IsActive__c = true,
                IF_Status__c = 'Completed',
                LABEL2__c = false,
                LABEL3__c = false,
                LABEL4__c = false,
                LABEL5__c = false

        );
        insert notiTemp;
        return notiTemp;
    }

    public static NotificationTemplate__c notiTemp {get; set;}

    static {
        if(notiTemp == null) {
            notiTemp = getNotiTemp();
        }
    }
}