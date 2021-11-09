/****************************************************************************************
  * @filename      : CouponTestDataUtil
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-26
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-26          i2max_JE Yoon             Create
****************************************************************************************/
@IsTest
public without sharing class CouponTestDataUtil {

    public static Map<String, Id> recordTypeMap;
    public static Datetime now = System.now();
    public static List<Contact> contacts;
    public static Account account;
    public static KDCE_Order__c order;
    public static KDCE_OrderLineItem__c orderLineItem;
    public static KDCE_Coupon__c coupon;
    public static IF_XP_SFDC_001__c ifXpSfdc001;
    public static Task task;
    public static Integer recordCount;
    public static String developerName_Coupon_MGM = 'Coupon_MGM';
    public static String developerName_Coupon_CVS = 'Coupon_CVS';
    public static String couponStatus_Produce = 'Produce';


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

    public static Account getAccount() {
        if (account == null) {
            account = new Account(
                    Name = 'test ' + now
            );
        }

        return account;
    }

    public static List<Contact> getContacts(String couponDeveloperName) {
        if (contacts == null) {
            contacts = new List<Contact>();
            recordCount = couponDeveloperName == developerName_Coupon_MGM ? 2 : 1;

            for (Integer i = 0; i < recordCount; i++) {
                contacts.add(new Contact(
                        LastName = couponDeveloperName + i,
                        RecordTypeId = getRecordTypeId('Contact', 'Contact_Member'),
                        KDCE_LASLAU__c = 'LAS',
                        KDCE_IsMGMIssue__c = false,
                        Email = 'test' + i + '@test.com'
                ));
            }

            insert contacts;
        }

        return contacts;
    }

    public static KDCE_Coupon__c getCoupon(String developerName, String status) {
        //String type = developerName.contains('cvs') ? 'CVS' : 'GetInfo';
        if (coupon == null) {
            if (contacts == null) getContacts(developerName);
            coupon = new KDCE_Coupon__c(
                    RecordTypeId = getRecordTypeId('KDCE_Coupon__c', developerName),
                    Contact__c = status != couponStatus_Produce ? contacts[0].Id : null,
                    CouponCode__c = 'Test ' + developerName,
                    Status__c = status,
                    Type__c = 'MGM'
          //          Type__c = type
            );
            insert coupon;
        }

        return coupon;
    }

    public static KDCE_Order__c getOrder(String coupon_developerName, Boolean couponExists) {
        if (order == null) {
            if (coupon == null) getCoupon(coupon_developerName, 'Issue');
            order = new KDCE_Order__c(
                    CustomerId__c = coupon_developerName == developerName_Coupon_MGM ? contacts[1].Id : contacts[0].Id,
                    Contact__c = coupon_developerName == developerName_Coupon_MGM ? contacts[1].Id : contacts[0].Id,
                    Coupon__c = couponExists ? coupon.Id : null
            );
            insert order;
        }

        return order;
    }

    public static KDCE_OrderLineItem__c getOrderLineItem(String coupon_developerName, Boolean couponExists) {

        if (orderLineItem == null) {
            if (order == null) getOrder(coupon_developerName, couponExists);
            orderLineItem = new KDCE_OrderLineItem__c(
                    //Name = 'test ' + now,
                    Order__c = order.Id
            );
            insert orderLineItem;
        }

        return orderLineItem;
    }

    public static IF_XP_SFDC_001__c getIfXpSfdc001() {
        if (ifXpSfdc001 == null) {
            if (coupon == null) getCoupon(developerName_Coupon_CVS, 'Produce');
            ifXpSfdc001 = new IF_XP_SFDC_001__c(
                    BurnoutChannel__c = 'CVS',
                    CVSChainCode__c = '24',
                    CVSChainName__c = 'GS',
                    CouponId__c = 'Test ' + developerName_Coupon_CVS,
                    CouponIssueDate__c = '2019-11-21',
                    CouponExpiryDate__c = '2021-06-30',
                    CouponStatus__c = '1',
                    CouponStatusDate__c = '20190329155801',
                    CouponAmount__c = '31000',
                    CouponName__c = '[GS25] 할인권)아이코스',
                    CouponOltCode__c = '1234',
                    CouponOltName__c = '공덕점',
                    CouponModDate__c = '20190329155801'
            );

        }

        return ifXpSfdc001;
    }

}