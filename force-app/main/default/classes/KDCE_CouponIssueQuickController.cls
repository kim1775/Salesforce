/****************************************************************************************
  * @filename      : KDCE_CouponIssueQuickController
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-03-16 오전 10:56
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
    0.1     2021-03-16 오전 10:56     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_CouponIssueQuickController {

    private final static Id RT_Coupon_CVSId             = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_CVS').getRecordTypeId();
    private final static Id RT_Coupon_CVSTr             = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_CVS_Trade_In').getRecordTypeId(); // 21.08.31 'CVS trade in Purchase coupon' 레코드 유형 추가
    private final static Id RT_Coupon_GetInfo           = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_GetInfo').getRecordTypeId();
    private final static Id RT_Coupon_MGM               = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_MGM').getRecordTypeId();

    // Coupon Record Type Name 별 Id
    private final static Map<String, Id> couponRtNameId = KDCE_Util.getRecordTypeNameBySObject('KDCE_Coupon__c');
    private final static Map<String, Id> couponRtDevNameId = KDCE_Util.getRecordTypeBySObject('KDCE_Coupon__c');

    @AuraEnabled
    public static Boolean getInvalidContact(Id recordId) {
        Boolean invalidContact = false;
        Contact con = [SELECT Id, KDCE_IsDropout__c, KDCE_IsDormant__c FROM Contact WHERE Id = :recordId];
        if (con.KDCE_IsDropout__c == true || con.KDCE_IsDormant__c) invalidContact = true;

        System.debug('=== invalidContact : ' + invalidContact);
        return invalidContact;
    }

    // Picklist Value 값 가져옴
    @AuraEnabled
    public static Map<String, List<String>> getPickListValuesList() {

        System.debug('=== getPickListValuesList : ');
        Map<String, List<String>> returnValueMap    = new Map<String, List<String>>(); // Return Value Map
        List<String> couponRecordTypeList           = new List<String>();   // Coupon Record Type
        List<String> couponCVSList                  = new List<String>();   // Coupon CVS

        // Channel Record Type
        for (String rtName : couponRtNameId.keySet()) {
            if(rtName.contains('Purchase')) couponRecordTypeList.add(rtName); // Record Type Name
        }
        returnValueMap.put('couponType', couponRecordTypeList);

        // Channel Detail (CVS) -> CVS 일 경우에만
        SObjectField picklistUsingGlobal    = SObjectType.KDCE_Coupon__c.fields.ChannelDetails__c.getSObjectField();
        List<PicklistEntry> entries         = picklistUsingGlobal.getDescribe().getPicklistValues();
        for (PicklistEntry entry : entries) {
            couponCVSList.add(String.valueOf(entry.label));
        }
        returnValueMap.put('channelCVS', couponCVSList);
        System.debug('=== returnValueMap : ' + returnValueMap);

        return returnValueMap;
    }

    // Coupon Record Type이 'CVS'인 경우에만 Channel CVS 선택가능

    @AuraEnabled
    public static Map<String, Object> checkValidChannelCVS(String selectedCouponType) {
        Map<String, Object> returnValueMap = new Map<String, Object>(); 
        Boolean checkValid = false;
        List<String> couponCVSList = new List<String>();
        Id couponTypeId = couponRtNameId.get(selectedCouponType);
        SObjectField picklistUsingGlobal    = SObjectType.KDCE_Coupon__c.fields.ChannelDetails__c.getSObjectField();
        List<PicklistEntry> entries         = picklistUsingGlobal.getDescribe().getPicklistValues();

        if (selectedCouponType == 'CVS trade in Purchase coupon') {
            for (PicklistEntry entry : entries) {
                if(String.valueOf(entry.label).contains('GS25')) couponCVSList.add(String.valueOf(entry.label));
            }
        }else{
            for (PicklistEntry entry : entries) {
               couponCVSList.add(String.valueOf(entry.label));
            }
        }
        returnValueMap.put('channelCVS', couponCVSList);
        System.debug('=== returnValueMap : ' + returnValueMap);

        if (couponTypeId == RT_Coupon_CVSId || couponTypeId == RT_Coupon_CVSTr) checkValid = true; // 21.08.31 couponTypeId == RT_Coupon_CVSTr 추가 ('CVS trade in Purchase coupon')
        returnValueMap.put('checkValid', checkValid);
        return returnValueMap;
    }
/*
    @AuraEnabled
    public static Boolean checkValidChannelCVS(String selectedCouponType) {
        Boolean checkValid = false;
        Id couponTypeId = couponRtNameId.get(selectedCouponType);

        if (couponTypeId == RT_Coupon_CVSId) checkValid = true;
        return checkValid;
    }

    @AuraEnabled
    public static Map<String, List<String>> checkCouponType(String selectedCouponType) {
        Map<String, List<String>> returnValueMap = new Map<String, List<String>>(); 
        Boolean checkValid = false;
        List<String> couponCVSList = new List<String>();
        Id couponTypeId = couponRtNameId.get(selectedCouponType);
        if (couponTypeId == RT_Coupon_CVSTr) {
            SObjectField picklistUsingGlobal    = SObjectType.KDCE_Coupon__c.fields.ChannelDetails__c.getSObjectField();
            List<PicklistEntry> entries         = picklistUsingGlobal.getDescribe().getPicklistValues();

            for (PicklistEntry entry : entries) {
                if(String.valueOf(entry.label).contains('GS25')) couponCVSList.add(String.valueOf(entry.label));
            }
            returnValueMap.put('channelCVS', couponCVSList);
            System.debug('=== returnValueMap : ' + returnValueMap);
            return returnValueMap;
        }
*/
    // 쿠폰 리스트 반환
    @AuraEnabled
    public static List<KDCE_Coupon__c> getCouponList(Id recordId, String selectedCouponType, String selectedChannelCVS) {

        System.debug('=== selectedCouponType : ' + selectedCouponType);
        System.debug('=== selectedChannelCVS : ' + selectedChannelCVS);
        Id couponTypeId;
        String channelCVS;
        String channelTypeAPIName;

        // 쿠폰 유형 Id
        couponTypeId = couponRtNameId.get(selectedCouponType);

        // 쿠폰 Channel CVS Id
        SObjectField picklistUsingGlobal    = SObjectType.KDCE_Coupon__c.fields.ChannelDetails__c.getSObjectField();
        List<PicklistEntry> entries         = picklistUsingGlobal.getDescribe().getPicklistValues();
        for (PicklistEntry entry : entries) {
            if (String.valueOf(entry.label) == selectedChannelCVS) channelCVS = String.valueOf(entry.value);
        }

        // 쿠폰 Type Development Name
        SObjectField picklistTypeObjectField = SObjectType.KDCE_Coupon__c.fields.Type__c.getSObjectField();
        List<PicklistEntry> entriesTypeEntries = picklistTypeObjectField.getDescribe().getPicklistValues();
        for (PicklistEntry entry : entriesTypeEntries) {
            if (String.valueOf(entry.label) == selectedCouponType) channelTypeAPIName = String.valueOf(entry.value);
        }

        // 발급가능한 쿠폰 검색  // TODO 가장 먼저 발급할 쿠폰을 어떤 기준으로 뽑을지 정의 필요
        String query = '';
        query += ' SELECT   CouponCode__c, Status__c, ExpiryDate__c, Contact__c, Amount__c  ';
        query += ' FROM     KDCE_Coupon__c                                                  ';
        query += ' WHERE    Contact__c = NULL                                               ';
        query += ' AND      ExternalType__c = :channelTypeAPIName                           ';
        query += ' AND      RecordTypeId = :couponTypeId                                    ';
        query += ' AND      Status__c = \'Produce\'                                         ';
        if (couponTypeId == RT_Coupon_CVSId){
            query += ' AND ChannelDetails__c = :channelCVS ';
            query += ' AND IssuableDate__c >= TODAY ';
        }
        query += ' LIMIT    1                                                               ';
        List<KDCE_Coupon__c> couponList = Database.query(query);
        System.debug('=== query : ' + query);
        System.debug('=== couponList : ' + couponList);

        return couponList;
    }

    @AuraEnabled
    public static Boolean saveCouponList(Id recordId, List<KDCE_Coupon__c> couponList) {
        System.debug('=== couponList : ' + couponList);

        Boolean contactLink = false;

        // Contact 연결 재확인
        Set<Id> couponIds = new Set<Id>();
        for (KDCE_Coupon__c coupon : couponList) couponIds.add(coupon.Id);
        List<KDCE_Coupon__c> saveCouponList = [
                SELECT Id, Contact__c, Status__c, IssueChannel__c, IssueDate__c
                FROM KDCE_Coupon__c WHERE Id IN :couponIds];

        for (KDCE_Coupon__c coupon : saveCouponList) {
            System.debug('=== coupon.Contact__c : ' + coupon.Contact__c);
            if (coupon.Contact__c != null) {
                contactLink = true;
                return contactLink;
            }
            coupon.Status__c        = KDCE_GlobalValue.COUPON_STATUS_ISSUE;
            coupon.Contact__c       = recordId;
            coupon.IssueChannel__c  = 'Call Center';
            coupon.IssueDate__c     = System.now();
        }

        update saveCouponList;
        return contactLink;
    }

}