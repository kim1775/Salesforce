/****************************************************************************************
  * @filename      : KDCE_Contact_tr_Test
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-30
  * @group         :
  * @description   : Contact 및 Case를 위한 Test Class
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-30          i2max_JE Yoon             Create
    0.2  2021-03-31          i2max_JE Yoon             Update
****************************************************************************************/

@IsTest
private class KDCE_Contact_tr_Test {

    static List<Contact> contacts;
    static List<KDCE_Coupon__c> coupons;
    static Contact contact_with_Coupon;
    static Contact contact_without_Coupon;
    static String developerName_Coupon_MGM = 'Coupon_MGM';
    static String couponStatus_Produce = 'Produce';
    static String couponStatus_Issue = 'Issue';
    static String KDCE_LAU = 'LAU';

    // Case
    static Map<String, Id> caseRecordTypeMap = KDCE_Util.getRecordTypeBySObject('Case');
    private final static Id qoachProgramRTId    = caseRecordTypeMap.get('CCR_QoachProgram');
    private final static Id adverseEventRTId    = caseRecordTypeMap.get('CCR_AdverseEvent');
    private final static Id heatStickRTId       = caseRecordTypeMap.get('CCR_NewHeatStick');
    private final static Id ecommerceOrder      = caseRecordTypeMap.get('CCR_ECommerceOrderOnBehalf');


    static void getData() {

        contacts = [SELECT KDCE_IsMGMIssue__c, KDCE_LASLAU__c, KDCE_MGMCode__c FROM Contact LIMIT 2];

        for (Contact contact : contacts) {
            contact.KDCE_LASLAU__c = KDCE_LAU;
        }

        update contacts;

        contacts = [SELECT KDCE_IsMGMIssue__c, KDCE_LASLAU__c, KDCE_MGMCode__c FROM Contact LIMIT 2];
        coupons = [SELECT Status__c, Contact__c, CouponCode__c FROM KDCE_Coupon__c LIMIT 1];

        for (Contact contact : contacts) {
            if (contact.KDCE_IsMGMIssue__c == true) contact_with_Coupon = contact;
            else if (contact.KDCE_IsMGMIssue__c == false) contact_without_Coupon = contact;
        }

    }

    /**
     * @description Contact의 subType이 LAU로 변경되는 케이스 및 KDCE_IsMGMIssue__c = true 되는 시나리오에서
     *             컨택에게 발급할 쿠폰이 있는 케이스 테스트
     * @author JE Yoon (2021.03.30)
     **/
    @IsTest
    static void testCase01 () {

        Test.startTest();

        CouponTestDataUtil.getCoupon(developerName_Coupon_MGM, couponStatus_Produce);
        if (contact_with_Coupon == null) getData();

//        System.assertEquals(KDCE_LAU, contact_with_Coupon.KDCE_LASLAU__c);
//        System.assertEquals(true, contact_with_Coupon.KDCE_IsMGMIssue__c);
//        System.assertEquals(coupons[0].Contact__c, contact_with_Coupon.Id);
//        System.assertEquals(coupons[0].CouponCode__c, contact_with_Coupon.KDCE_MGMCode__c);
//        System.assertEquals(couponStatus_Issue, coupons[0].Status__c);
//        System.assertEquals(false, contact_without_Coupon.KDCE_IsMGMIssue__c);
        Test.stopTest();
    }

    /**
     * @description Contact의 subType이 LAU로 변경되는 케이스 및 KDCE_IsMGMIssue__c = true 되는 시나리오에서
     *             컨택에게 발급할 쿠폰이 없는 케이스 테스트
     * @author JE Yoon (2021.03.30)
     **/
    @IsTest
    static void testCase02 () {

        Test.startTest();

        CouponTestDataUtil.getContacts(developerName_Coupon_MGM);
        if (contact_without_Coupon == null) getData();

        System.assertEquals(KDCE_LAU, contact_without_Coupon.KDCE_LASLAU__c);
        System.assertEquals(false, contact_without_Coupon.KDCE_IsMGMIssue__c);
        System.assertEquals(0, coupons.size());
        System.assertEquals(null, contact_with_Coupon);
        
        Test.stopTest();
    }

    @IsTest
    static void testRestore() {
        Contact contact = KDCE_TestUtil.contactMember;
        contact.KDCE_IsDormant__c = true;
        contact.KDCE_LASLAU__c = 'LAU';
        update contact;
    }

    @IsTest
    static void testreCalculateAssetCarePlusStatus() {
        Test.startTest();
        Contact contact = KDCE_TestUtil.contactMember;
        contact.CCR_CarePlusStatus__c = 'Not Enrolled';
        contact.CCR_CarePlusDueDate__c = null;
        update contact;

        Asset asset = KDCE_TestUtil.assetHolder.clone(true);
        asset.CCR_CarePlusStatus__c = 'Not Enrolled';
        asset.CCR_CarePlusDueDate__c = null;
        asset.ContactId = contact.Id;
        update asset;

        contact.CCR_CarePlusStatus__c = 'Enrolled';
        update contact;

        Test.stopTest();
    }

    /**
     * Case_tr Testcode
     *
     */
    @IsTest
    static void sendNPSSurveySMS() {
        Test.startTest();
        Case caseItem = KDCE_TestUtil.caseItem.clone(false);
        caseItem.Status = 'New';
        caseItem.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCR_HolderChargerAccessory').getRecordTypeId();
        insert caseItem;

        KDCE_SurvyPerSubjectCode__c subCode = new KDCE_SurvyPerSubjectCode__c(
                Category__c = '3-홀더/충전기/액세서리 이슈'
        );
        insert subCode;

        caseItem.Status = 'Closed';
        update caseItem;
        Test.stopTest();
    }

    @IsTest
    static void testCaseBehavior01() {

        List<Case> insertCases = new List<Case>();

        Case webToCase = new Case(
                SuppliedEmail = 'test@email.com', SuppliedName = 'Nme', SuppliedPhone = '0102838291727', Origin = 'Web',
                ContactId = KDCE_TestUtil.getContactMember().Id
        );
        insertCases.add(webToCase);

        Case emailToCase = webToCase.clone(false, true);
        emailToCase.Origin = 'Email';
        insertCases.add(emailToCase);

        Case chatToCase = webToCase.clone(false, true);
        chatToCase.Origin = 'Chat';
        insertCases.add(chatToCase);

        Case webToCase2 = webToCase.clone(false, true);
        webToCase2.ContactId = KDCE_TestUtil.getContactMember().Id;
        webToCase2.CCR_Inbound_Outbound__c = 'Inbound';
        webToCase2.KDCE_IsOnlineCase__c = true;
        insertCases.add(webToCase2);

        insert insertCases;

        webToCase2.RecordTypeId = KDCE_Util.getRecordTypeBySObject('Case').get('CCR_QoachProgram');
//        webToCase2.CCR_SubjectCodeNew__c = 'Remote Coach';

        update webToCase2;
    }

    @IsTest
    static void testCaseBehavior02() {

        NotificationTemplate__c notificationTemplate = new NotificationTemplate__c();
        notificationTemplate.Content__c = '';
        notificationTemplate.Channel__c = '0';
        notificationTemplate.ExternalId__c = 'Survey';
        insert notificationTemplate;
        System.debug('=== notificationTemplate : ' + notificationTemplate);

        NotificationGroup__c notificationGroup = new NotificationGroup__c();
        insert notificationGroup;
        System.debug('=== notificationGroup : ' + notificationGroup);

        Notification__c notification = new Notification__c();
        notification.Channel__c = '0';
        notification.NotificationTemplate__c = notificationTemplate.Id;
        notification.NotificationGroup__c = notificationGroup.Id;
        notification.Contact__c = KDCE_TestUtil.contactMember.Id;
        notification.Channel__c = '0';
        insert notification;
    }

    @IsTest
    static void testCaseBehavior03() {

        Case caseItem = KDCE_TestUtil.caseItem;
        caseItem.Status = 'Closed';
        caseItem.RecordTypeId = qoachProgramRTId;
        update caseItem;

        caseItem.RecordTypeId = adverseEventRTId;
        update caseItem;

        caseItem.RecordTypeId = heatStickRTId;
        update caseItem;
    }

    @IsTest
    static void testCaseBehavior04() {

        List<Case> insertCases = new List<Case>();
        Case webCase = new Case();
        webCase.Origin = 'Web';
        webCase.SuppliedPhone = '01029382949';
        webCase.SuppliedEmail = 'test321@naver.com';
        webCase.SuppliedName = 'testtest';
        webCase.ContactId = KDCE_TestUtil.contactMember.Id;

        Case emailCase = webCase.clone(false);
        emailCase.Origin = 'Email';
//        emailCase.RecordTypeId = qoachProgramRTId;

        Case chatCase = webCase.clone(false);
        webCase.SuppliedEmail = 'test32221@naver.com';
        webCase.SuppliedName = 'testtest22';
        chatCase.SuppliedPhone = '0102039299';
        chatCase.Origin = 'Chat';

        Case chatCase2 = new Case();
        chatCase2.Origin = 'Chat';
        chatCase2.SuppliedName = KDCE_TestUtil.contactMember.LastName;
        chatCase2.SuppliedEmail = KDCE_TestUtil.contactMember.Email;
        chatCase2.SuppliedPhone = KDCE_TestUtil.contactMember.Phone;

        insertCases.add(webCase);
        insertCases.add(emailCase);
        insertCases.add(chatCase);
        insertCases.add(chatCase2);

        insert insertCases;
    }

    @IsTest
    static void testCaseBehavior05() {
        List<Case> insertCases = new List<Case>();
        List<Case> updateCases = new List<Case>();
        Case webCase = new Case();
        webCase.Origin = 'Web';
        webCase.SuppliedPhone = '01029382949';
        webCase.SuppliedEmail = 'test321@naver.com';
        webCase.SuppliedName = 'testtest';

        Case newCase = new Case();
        newCase.ContactId = KDCE_TestUtil.contactMember.Id;
        newCase.RecordTypeId = heatStickRTId;
        newCase.Status = 'New';
        newCase.CCR_Inbound_Outbound__c = 'Inbound';
        newCase.KDCE_IsOnlineCase__c = true;

        insertCases.add(webCase);
        insertCases.add(newCase);
        insert insertCases;

        newCase.Status = 'Closed';
        newCase.RecordTypeId = ecommerceOrder;
        updateCases.add(webCase);
        updateCases.add(newCase);

        update updateCases;
    }

    @IsTest
    static void testCaseBehavior06() {
        List<Case> insertCases = new List<Case>();
        List<Case> updateCases = new List<Case>();
        Case emailCase = new Case();
        emailCase.Origin = 'Email';
        emailCase.SuppliedEmail = KDCE_TestUtil.contactMember.Email;

        Case emailCase2 = new Case();
        emailCase2.Origin = 'Email';
        emailCase2.SuppliedEmail = 'kdescemail@test.com';

        Case chatCase = new Case();
        chatCase.Origin = 'Chat';
        chatCase.SuppliedPhone = '01029382942319';
        chatCase.SuppliedEmail = 'test322131@naver.com';
        chatCase.SuppliedName = 'testtest232';

        insertCases.add(emailCase);
        insertCases.add(emailCase2);
        insertCases.add(chatCase);
        System.debug('=== insertCases : ' + insertCases);
        insert insertCases;

    }

}