/****************************************************************************************
  * @filename      : KDCE_Case_tr
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-03-03 오후 3:33
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : KDCE_Contact_tr_Test.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-03-03 오후 3:33     i2max_Jihyun.Lee        Create
****************************************************************************************/ 

public without sharing class KDCE_Case_tr extends TriggerHandler {

    // Case RecordType 별 DeveloperName, Id의 Map
    private static Map<String, Id> caseRecordTypeMap = KDCE_Util.getRecordTypeBySObject('Case');
    // Contact RecordType 별 DeveloperName, Id의 Map
    private static Map<String, Id> contactRecordTypeMap = KDCE_Util.getRecordTypeBySObject('Contact');

    // Case RecordType Id
    private final static Id inquiryCriticalRTId = caseRecordTypeMap.get('CCR_InquiryCriticalInquiries');
    private final static Id adverseEventRTId    = caseRecordTypeMap.get('CCR_AdverseEvent');
    private final static Id heatStickRTId       = caseRecordTypeMap.get('CCR_NewHeatStick');
    private final static Id qoachProgramRTId    = caseRecordTypeMap.get('CCR_QoachProgram');
    private final static Id accessoryRTId       = caseRecordTypeMap.get('CCR_HolderChargerAccessory');
    private final static Id QURERTID            = caseRecordTypeMap.get('CCR_Qure');


    // 재귀 호출 방지 Flag
    public static Boolean isAlreadyExecuted = false;

    //SEND NPS
    private static List<String> currentClickCaseIds = new List<String>();

    public override void beforeInsert() {
        setRecordTypeByOrigin();    // Email To Case, Web To Case로 들어올경우, Case 필드 업데이트 (두가지로 들어올경우 Contact 생성 - createContactByOrigin)
        validationRtAE();           // Related Case에서 6번 레코드 생성 시, 저장 막기(AE 레코드 유형에서는 상위 사례를 가질 수 없다.)
        insertCaseField();
        checkOnlineCase();          // Case가 온라인인지 오프라인인지 체크
    }

    public override void beforeUpdate() {
        updateCaseField();          // Case 변경시, 필드 변경 or 동기화
        validationRtAE();           // Related Case에서 6번 레코드 생성 시, 저장 막기(AE 레코드 유형에서는 상위 사례를 가질 수 없다.)
    }

    public override void afterInsert() {
//        setContactRecord();       // Case 생성시, Contact 필드 업데이트
        setContactByInsert();       // Case 생성시, Contact 필드 업데이트
        parentCaseComplete();
        sendNPSSurveySMS();


    }

    public override void afterUpdate() {
//        setContactRecord();         // Case 업데이트시, Contact 필드 업데이트

        if (isAlreadyExecuted == false) {
            closeKakaoSession();
            setContactByUpdate();       // Case 업데이틔, Contact 필드 업데이트
            parentCaseComplete();       // 하위 Case 만료시, 상위 Case 만료
            setContactNullByRT();       // RT가 'AE'일 경우, Case 및 Task에서 ContactId Null 처리
            System.debug('currentClickCaseIds :::::::::::: ' + currentClickCaseIds);
            sendNPSSurveySMS();         // Case 종료후 Survey 발송
            isAlreadyExecuted = true;
        }
    }

    /**
     * Online / Offline Case 체크 ([Case] Owner의 [User] 정보 division과 일치하는 [Store] (CompanyCode__c) 가 있으면 오프라인 케이스라고 간주
     */
    private void checkOnlineCase() {
        System.debug('@@@@@@ checkOnlineCase @@@@@@');
        Set<Id> caseOwnerIds = new Set<Id>();
        Map<Id, String> divisionByUserIdMap = new Map<Id, String>();
        Set<String> offlineStore = new Set<String>();
        for (Case newCase : (List<Case>) Trigger.new) {
            caseOwnerIds.add(newCase.OwnerId);
        }

        for (User user : [SELECT Id, Division, Department FROM User WHERE Id IN :caseOwnerIds]) {
            if (user.Division != null) divisionByUserIdMap.put(user.Id, user.Division);
        }

        for (KDCE_Store__c store : [SELECT Id, CompanyCode__c FROM KDCE_Store__c WHERE CompanyCode__c IN :divisionByUserIdMap.values()]) {
            if (store.CompanyCode__c != null) offlineStore.add(store.CompanyCode__c);
        }
        for (Case newCase : (List<Case>) Trigger.new) {
            if (!offlineStore.contains(divisionByUserIdMap?.get(newCase.OwnerId))) newCase.KDCE_IsOnlineCase__c = true;
        }
    }

    /**
     * Case 값 동기화
     */
    private void insertCaseField() {

        Map<String, String> casePVMap = KDCE_Util.getPicklistValue('Case', 'CCR_SubjectCodeNew__c');

        // Case 값 동기화 + 온라인 값 넣어주기
        for (Case newCase : (List<Case>) Trigger.new) {

            //if(newCase.RecordTypeId == QURERTID){
                // Subject의 값이 없고, Subject Code에 값이 있을 때, Subject Code Label => Subject 동기화 (2021.03.08 이석호)
            if (newCase.Subject == null && newCase.CCR_SubjectCodeNew__c != null) {
                newCase.Subject = casePVMap.get(newCase.CCR_SubjectCodeNew__c);
            }
            //}
        }
    }

    /**
     * Case 값 동기화
     */
    private void updateCaseField() {
        System.debug('@@@@@@ updateCaseField @@@@@@');

        Map<String, String> casePVMap = KDCE_Util.getPicklistValue('Case', 'CCR_SubjectCodeNew__c');

        // Case 값 동기화 + 온라인 값 넣어주기
        for (Case newCase : (List<Case>) Trigger.new) {
            // Subject의 값이 없고, Subject Code에 값이 있을 때, Subject Code Label => Subject 동기화 (2021.03.08 이석호)
            if (newCase.Subject == null && newCase.CCR_SubjectCodeNew__c != null) {
                newCase.Subject = casePVMap.get(newCase.CCR_SubjectCodeNew__c);
            }

            // Record Type이 7번 히츠스틱인 경우, 필드 동기화
            if (newCase.RecordTypeId == heatStickRTId) {
                if (newCase.CCR_SubjectCodeNew__c != newCase.KDCE_HeetsSubjectCode__c) newCase.CCR_SubjectCodeNew__c = newCase.KDCE_HeetsSubjectCode__c;     // HeatsSubject Code -> Subject Code 동기화 (2021.03.04 이석호)
                if (newCase.CCR_Resolution__c != newCase.KDCE_HeetsResolution__c) newCase.CCR_Resolution__c = newCase.KDCE_HeetsResolution__c;
            }

            // Reocrd Type이 Adverse Event인 경우, 필드 변경
            if (newCase.RecordTypeId == adverseEventRTId) {
                newCase.KDCE_SendNPS__c = 'No';
                newCase.ContactId = null;
            }

        }
    }


    /**
     * Case 생성시, Contact 필드 업데이트 (2021.04.13 이지현)
     */
    private void setContactByInsert() {
        System.debug('@@@@@@ setContactByInsert @@@@@@');
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Contact updateContact;

        for (Case ca : (List<Case>) Trigger.new) {
            if (ca.ContactId != null) {

                // Web으로 Contact 생성시, CCR_SoftAgeVerifiedNew__c 필드 업데이트
                if (ca.Origin == 'Web' && ca.ContactId != null) {
                    if (contactMap.containsKey(ca.ContactId)) {
                        updateContact                               = contactMap.get(ca.ContactId);
                        updateContact.CCR_SoftAgeVerifiedNew__c     = 'Yes';
                        updateContact.CCR_SoftAgeVerifiedDate__c    = System.now();
                        contactMap.put(ca.ContactId, updateContact);
                    } else {
                        contactMap.put(ca.ContactId, new Contact(Id = ca.ContactId, CCR_SoftAgeVerifiedNew__c = 'Yes', CCR_SoftAgeVerifiedDate__c = System.now()));
                    }
                }

                // Qoach Program 안씀 (2021.07.24 삭제)
//                if (ca.RecordTypeId == qoachProgramRTId) {
//                    if (contactMap.containsKey(ca.ContactId)) {
//                        updateContact                       = contactMap.get(ca.ContactId);
//                        updateContact.CCR_QoachProgram__c   = true;
//                        contactMap.put(ca.ContactId, updateContact);
//                    } else {
//                        contactMap.put(ca.ContactId, new Contact(Id = ca.ContactId, CCR_QoachProgram__c = true));
//                    }
//                }

                // Case 생성시, KDCE_LastCaseDate__c(마지막 케이스 생성날짜) 필드 업데이트 (단, Inbound 및 온라인 케이스일때만)
                if (ca.CCR_Inbound_Outbound__c == 'Inbound' && ca.KDCE_IsOnlineCase__c == true) {
                    if (contactMap.containsKey(ca.ContactId)) {
                        updateContact                           = contactMap.get(ca.ContactId);
                        updateContact.KDCE_LastCaseDate__c      = ca.CreatedDate;
                        contactMap.put(ca.ContactId, updateContact);
                    } else {
                        contactMap.put(ca.ContactId, new Contact(Id = ca.ContactId, KDCE_LastCaseDate__c = ca.CreatedDate));
                    }

                }
            }
        }
        System.debug('=== contactMap : ' + contactMap);
        if (contactMap.size() > 0) update contactMap.values();
    }

    /**
     * Case 업데이트시, Contact 필드 업데이트 (2021.04.13 이지현)
     */
    private void setContactByUpdate() {
        System.debug('@@@@@@ setContactByUpdate @@@@@@');
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Contact updateContact;

        for (Case ca : (List<Case>) Trigger.new) {
            Case oldCase = (Case) Trigger.oldMap?.get(ca.Id);

            if (ca.ContactId != null) {

                // 마지막 Case Closed 된 날
                if (oldCase.Status <> ca.Status && ca.Status == 'Closed') {
                    if (ca.CCR_Inbound_Outbound__c == 'Inbound' && ca.KDCE_IsOnlineCase__c == true) {
                        if (contactMap.containsKey(ca.ContactId)) {
                            updateContact                           = contactMap.get(ca.ContactId);
                            updateContact.KDCE_LastCloseDate__c     = System.now();
                            contactMap.put(ca.ContactId, updateContact);
                        } else {
                            contactMap.put(ca.ContactId, new Contact(Id = ca.ContactId, KDCE_LastCloseDate__c = System.now()));
                        }
                    }
                }

                // RecordType 변경시
                if (oldCase.RecordTypeId <> ca.RecordTypeId && ca.RecordTypeId == qoachProgramRTId) {
                    if (contactMap.containsKey(ca.ContactId)) {
                        updateContact                       = contactMap.get(ca.ContactId);
                        updateContact.CCR_QoachProgram__c   = true;
                        contactMap.put(ca.ContactId, updateContact);
                    } else {
                        contactMap.put(ca.ContactId, new Contact(Id=ca.ContactId, CCR_QoachProgram__c = true));
//                        contactMap.put(ca.ContactId, new Contact(Id=ca.ContactId, CCR_SoftAgeVerifiedNew__c = 'Yes', CCR_SoftAgeVerifiedDate__c = System.now()));
                    }
                }
                System.debug('=== contactMap : ' + contactMap);
            }
        }
        if (contactMap.size() > 0) update contactMap.values();
    }


    /**
    *  - Record Type이 Email to Case / Web to Case로 들어올 경우 업데이트
     *      1.  RecordType : "1-Inquiry/Critical Inquiry" (2021.03.04 이석호)
     *          Email to Case는 Setup 에서 RecordType을 지정 함, Web에 대해서만 Setting
     *      2. Field Update : Case Channel Field 업데이트 (2021.04.02 이지현)
    */
    private void setRecordTypeByOrigin() {
        System.debug('@@@@@@ setRecordTypeByOrigin @@@@@@');

        List<Case> emailWebCaseList = new List<Case>();
        for (Case newCase : (List<Case>) Trigger.new) {
            System.debug('newCase ::' + newCase);
            System.debug('newCase ::' + JSON.serialize(newCase));

            // Test인 경우 이상한 값이 들어오는 경우 null 처리
            if (Test.isRunningTest()) {
                if (newCase.CCR_SubjectCodeNew__c == 'Remote Coach') newCase.CCR_SubjectCodeNew__c = null;
            }

            if (newCase.RecordTypeId == adverseEventRTId) newCase.ContactId = null;
            //if (newCase.ContactId != null) continue;

            System.debug('=== newCase.Origin : ' + newCase.Origin);
            if (newCase.Origin != null) {
                if (newCase.Origin.equalsIgnoreCase('Web')) {
                    System.debug('=== Web ===');
                    newCase.RecordTypeId        = inquiryCriticalRTId;
                    newCase.CCR_ContactType__c  = 'Webpage';
                    emailWebCaseList.add(newCase);
                }

                if (newCase.Origin.equalsIgnoreCase('Email')) {
                    newCase.RecordTypeId        = inquiryCriticalRTId;
                    newCase.CCR_ContactType__c  = 'Email';
                    emailWebCaseList.add(newCase);
                }

                if (newCase.Origin.equalsIgnoreCase('Chat')) {
                    if (newCase.ContactId != null) continue;
                    newCase.RecordTypeId        = inquiryCriticalRTId;
                    newCase.CCR_ContactType__c  = 'Chat';
                    emailWebCaseList.add(newCase);
                }
            }

            if(newCase.KDCE_SuppliedBirthdayText__c != null  && newCase.KDCE_SuppliedBirthday__c == null) newCase.KDCE_SuppliedBirthday__c = Util.str2Date(newCase.KDCE_SuppliedBirthdayText__c);


        }
        System.debug('=== emailWebCaseList : ' + emailWebCaseList);
        if (!emailWebCaseList.isEmpty()) {
            createContactByOrigin(emailWebCaseList);
        }
    }

    /**
     * Email to Case / Web to Case 로 들어온 Case 생성 시 Contact 생성(Name, Email로 Contact Duplicate Check) (2021.03.04 이석호)
     *  - Email to Case:    이메일 중복 체크
     *  - Web to Case:      이름 + 전화번호 중복 체크
     *  - Web Chat:         로그인시 - UUID or 이름 + 전화번호 / 비로그인시 - Contact 이름, 전화번호, 이메일
     *  - Kakao Chat:       // todo 어디서 일어나는지 확인해봐야함
     * (Case의 SuppliedName이 없을경우 Contact 생성 x)
     */
    private void createContactByOrigin(List<Case> newCaseList) {
        System.debug('@@@@@@ createContactByOrigin @@@@@@');

        // Unique Key, Case를 저장하기 위한 CaseMap
        Map<String, Case> caseMillisMap = new Map<String, Case>();
        // Unique Key, Contact를 저장하기 위한 ContactMap
        Map<String, Contact> contactMillsMap = new Map<String, Contact>();

        // 새로직 추가
        Set<String> contactEmailSet     = new Set<String>();    // Email (이메일)
        Set<String> contactNamePNSet    = new Set<String>();    // Web (이름 + 전화번호)
        Set<String> contactNameEMSet    = new Set<String>();    // Web (이름 + 이메일)
        Set<String> contactNamePNEMSet  = new Set<String>();    // Chat (이름 +전화번호 + 이메일)
        Map<String, Contact> contactEmailMap = new Map<String, Contact>();
        Map<String, Contact> contactNamePNMap = new Map<String, Contact>();
        Map<String, Contact> contactNameEMMap = new Map<String, Contact>();
        Map<String, Contact> contactNamePNEMMap = new Map<String, Contact>();
        String namePNEM;    // 이름_전화번호_이메일
        String casePhone;   // Phone에 '-'가 있으면 '-' 제외

        for (Case newCase : (List<Case>) newCaseList) {
            System.debug('=== newCase.Origin : ' + newCase.Origin);

            if (newCase.Origin.equalsIgnoreCase('Email'))   {
                if (newCase.SuppliedEmail != null) contactEmailSet.add(newCase.SuppliedEmail);
            }
            if (newCase.Origin.equalsIgnoreCase('Web'))     {
                if (newCase.SuppliedName != null && newCase.SuppliedPhone != null && newCase.SuppliedEmail != null) contactNamePNEMSet.add(getContactExtNamePNEMKey(newCase));

                if (newCase.SuppliedName != null && newCase.SuppliedEmail != null) contactNameEMSet.add(getContactExtNameEMKey(newCase));
            }
            if (newCase.Origin.equalsIgnoreCase('Chat')) {
                if (newCase.SuppliedName != null && newCase.SuppliedPhone != null && newCase.SuppliedEmail != null) contactNamePNEMSet.add(getContactExtNamePNEMKey(newCase));
            }
        }

        // Email
        for (Contact contact : [
                SELECT Id, KDCE_Name__c, Email, KDCE_NameEMKey__c, KDCE_RegistrationDate__c, RecordTypeId
                FROM Contact
                WHERE Email IN :contactEmailSet
        ]) {
            // 우선순위 1. Member, 2. Registration Date
            if (contactEmailMap.containsKey(contact.Email)) {
                if (contactEmailMap.get(contact.Email).RecordTypeId <> contact.RecordTypeId && contact.RecordTypeId == contactRecordTypeMap.get('Contact_Member')) {
                    contactEmailMap.put(contact.Email, contact);
                }
                else if (contactEmailMap.get(contact.Email).RecordTypeId == contact.RecordTypeId) {
                    // Registration Date 대로 값 비교
                    if (contact.KDCE_RegistrationDate__c != null && contactEmailMap.get(contact.Email).KDCE_RegistrationDate__c != null && contactEmailMap.get(contact.Email).KDCE_RegistrationDate__c < contact.KDCE_RegistrationDate__c) {
                        contactEmailMap.put(contact.Email, contact);
                    }
                    // 둘중에 하나가 Registration Date가 없을 경우 값 넣어줌
                    else {
                        if (contact.KDCE_RegistrationDate__c != null) contactEmailMap.put(contact.Email, contact);
                    }
                }
            } else {
                contactEmailMap.put(contact.Email, contact);
            }
        }

        // Web
        for (Contact contact : [
                SELECT Id, KDCE_Name__c, Email, KDCE_NamePNEMKey__c, KDCE_NameEMKey__c
                FROM Contact
                WHERE KDCE_NamePNEMKey__c IN :contactNamePNEMSet
                OR KDCE_NameEMKey__c IN :contactNameEMSet
        ]) {
            contactNamePNEMMap.put(contact.KDCE_NamePNEMKey__c, contact);
            contactNameEMMap.put(contact.KDCE_NameEMKey__c, contact);
        }

        // Chat
        for (Contact contact : [
                SELECT Id, KDCE_Name__c, Email, KDCE_PNKey__c, KDCE_NamePNEMKey__c
                FROM Contact
                WHERE KDCE_NamePNEMKey__c IN :contactNamePNEMSet
        ]) {
            contactNamePNEMMap.put(contact.KDCE_NamePNEMKey__c, contact);
        }


        // Before Trigger 에서 Case Id를 가져 올 수 없어 불가피 하게 Unique Key 생성
        String uniqueKey;
        Contact con;
        Contact updateCon;
        Map<String, Contact> insertContactMap = new Map<String, Contact>();
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();

        for (Case newCase : (List<Case>) newCaseList) {

//            if (newCase.ContactId != null) continue;    // TODO 확인필요 (2021-07-19 Chat to Case 확인하다가 추가)

            // Email의 경우, 이메일로 Contact 조회 및 생성
            if (newCase.Origin.equalsIgnoreCase('Email')) {

                // Email To Case 는 Email 필수기 때문에 누락되면 처리하지 않음
                if(newCase.SuppliedEmail == null) continue;

                uniqueKey = String.valueOf(System.currentTimeMillis() + Math.random() * 1000);

                if (contactEmailMap.containsKey(newCase.SuppliedEmail)) {
                    con = new Contact(Id = contactEmailMap.get(newCase.SuppliedEmail).Id);
                }
                else {
                    System.debug('=== contact생성 : ');
                    con = new Contact();
                    con.RecordTypeId                = contactRecordTypeMap.get('Contact_Prospect');
//                    con.KDCE_ConsumerType__c        = 'Prospect';
                    con.LastName                    = newCase.SuppliedName != null ? newCase.SuppliedName : newCase.SuppliedEmail.split('@')[0];
                    con.Phone                       = newCase.SuppliedPhone;
                    con.Email                       = newCase.SuppliedEmail;
                    con.Birthdate                   = newCase.KDCE_SuppliedBirthday__c;
                    con.KDCE_RegistrationChannel__c = 'SC'; // TODO Registration Channel 결정되면 고치기
                    con.KDCE_RegistrationDate__c    = System.now();
                    con.KDCE_RegistrationObject__c  = 'Case';
                    insertContactMap.put(uniqueKey, con);
                }
                caseMillisMap.put(uniqueKey, newCase);
                contactMillsMap.put(uniqueKey, con);
            }

            // Web의 경우, 1차로 전화번호로 Contact 조회 및 생성 2차로 이메일로 Contat 조회
            if (newCase.Origin.equalsIgnoreCase('Web')) {
                uniqueKey = String.valueOf(System.currentTimeMillis() + Math.random() * 1000);

                // Web To Case 는 세가지 모두 필수기 때문에 하나라도 누락되면 처리하지 않음
                if(newCase.SuppliedName == null) continue;
                if(newCase.SuppliedPhone == null) continue;
                if(newCase.SuppliedEmail == null) continue;

                System.debug('=== newCase : ' + newCase);

                if (contactNamePNEMMap.containsKey(getContactExtNamePNEMKey(newCase))) {
                    con = new Contact(Id = contactNamePNEMMap.get(getContactExtNamePNEMKey(newCase)).Id);
                }
                // 이름 + 전화번호가 없지만, 이름 + 이메일이 존재할 경우 (2021.06.07 이지현 추가)
                else if (contactNameEMMap.containsKey(getContactExtNameEMKey(newCase)) && newCase.SuppliedEmail != null) {
                    con = new Contact(Id = contactNameEMMap.get(getContactExtNameEMKey(newCase)).Id);
//                    updateContactMap.put(con.Id, con);
                }
                else {
                    con = new Contact();
                    con.RecordTypeId                = contactRecordTypeMap.get('Contact_Prospect');
//                    con.KDCE_ConsumerType__c        = 'Prospect';
                    con.LastName                    = newCase.SuppliedName;
                    con.Phone                       = newCase.SuppliedPhone;
                    con.Birthdate                   = newCase.KDCE_SuppliedBirthday__c;
                    con.Email                       = newCase.SuppliedEmail;
                    con.KDCE_RegistrationChannel__c = 'SC'; // TODO Registration Channel 결정되면 고치기
                    con.KDCE_RegistrationDate__c    = System.now();
                    con.KDCE_RegistrationObject__c  = 'Case';

                    // Web으로 Contact 생성시, CCR_SoftAgeVerifiedNew__c 필드 업데이트
                    con.CCR_SoftAgeVerifiedNew__c   = 'Yes';
                    con.CCR_SoftAgeVerifiedDate__c  = System.now();
                    insertContactMap.put(uniqueKey, con);
                }
                System.debug('=== con : ' + con);

                caseMillisMap.put(uniqueKey, newCase);
                contactMillsMap.put(uniqueKey, con);
                System.debug('=== caseMillisMap : ' + caseMillisMap);
                System.debug('=== contactMillsMap : ' + contactMillsMap);

            }

            // Chat의 경우, 이름 전화번호 이메일로 Contact 조회 및 생성   // todo NULL일 경우 잇나
            if (newCase.Origin.equalsIgnoreCase('Chat')) {
                System.debug('=== newCase.Origin : ' + newCase.Origin);
                System.debug('=== newCase.SuppliedPhone : ' + newCase.SuppliedPhone);
                uniqueKey = String.valueOf(System.currentTimeMillis() + Math.random() * 1000);

                if (contactNamePNEMMap.containsKey(getContactExtNamePNEMKey(newCase))) {
                    System.debug('=== 포함된다 : ');
                    con = new Contact(Id = contactNamePNEMMap.get(getContactExtNamePNEMKey(newCase)).Id);
                }
                // 이름 + 핸드폰만 있을 경우
                else if (contactNamePNMap.containsKey(getContactExtNamePNKey(newCase)) && newCase.SuppliedPhone != null) {
                    con = new Contact(Id = contactNamePNMap.get(getContactExtNamePNKey(newCase)).Id, Email = newCase.SuppliedEmail);
//                    updateContactMap.put(con.Id, con);
                }
                // 이름 + 이메일만 있을 경우
                else if (contactNameEMMap.containsKey(getContactExtNameEMKey(newCase)) && newCase.SuppliedEmail != null) {
                    con = new Contact(Id = contactNameEMMap.get(getContactExtNameEMKey(newCase)).Id, Phone = newCase.SuppliedPhone);
//                    updateContactMap.put(con.Id, con);
                }
                else {
                    if (newCase.SuppliedName == null || newCase.SuppliedPhone == null || newCase.SuppliedEmail == null) continue;
                    con = new Contact();
                    con.RecordTypeId                = contactRecordTypeMap.get('Contact_Prospect');
//                    con.KDCE_ConsumerType__c        = 'Prospect';
                    con.LastName                    = newCase.SuppliedName;
                    con.Phone                       = newCase.SuppliedPhone;
                    con.Email                       = newCase.SuppliedEmail;
                    con.Birthdate                   = newCase.KDCE_SuppliedBirthday__c;
                    con.KDCE_RegistrationChannel__c = 'SC';
                    con.KDCE_RegistrationDate__c    = System.now();
                    con.KDCE_RegistrationObject__c  = 'Case';
                    insertContactMap.put(uniqueKey, con);
                }

                caseMillisMap.put(uniqueKey, newCase);
                contactMillsMap.put(uniqueKey, con);

            }
        }

        System.debug('caseMillisMap => ' + caseMillisMap);
        System.debug('contactMillsMap => ' + contactMillsMap);
        System.debug('insertContactMap => ' + insertContactMap);
        System.debug('=== contactMillsMap.values() : ' + contactMillsMap.values());

        if (!contactMillsMap.values().isEmpty() && contactMillsMap.values() != null) {
            System.debug('=== contactMillsMap.values() : ' + contactMillsMap.values());
            if(!test.isRunningTest()) Database.insert(insertContactMap.values());

            // 기존에 Contact있으면 매핑
            for (String key : caseMillisMap.keySet()) {
                if (contactMillsMap.containsKey(key)) {
                    caseMillisMap.get(key).ContactId = contactMillsMap?.get(key).Id;
                }
            }
        }

//        if (!updateContactMap.values().isEmpty()) update updateContactMap.values(); // 기존에 있는 Contact 값 업데이트
    }

    //TODO Survey Template 키값
    final String SURVEY_NOTIFICATION_TEMEPLATE = 'NT-210507-00074';
    /**
     * Case 종료 후 고객 만족도 문자 발송(Survey Link) (2021.03.04 이석호)
     * TODO Subject type 별로 다른 Survey 전송
     */
//    private void sendSurveySMS() {
//        System.debug('@@@@@@ sendSurveySMS @@@@@@');
//        System.debug('=== isAlreadyExecuted : ' + isAlreadyExecuted);
//
//        if (!isAlreadyExecuted) {
//            // 일단 정상 발송만 되게 처리
//            // Survey Id Hard coding
//            final String SURVEY_ID = 'a0y1m000000ITdlAAG';
//
//            Map<String, NotificationTemplate__c> ntMap = new Map<String, NotificationTemplate__c>();
//            List<NotificationTemplate__c> notificationTemplateList = [
//                    SELECT Id, KDCE_ExternalId__c, Content__c
//                    FROM NotificationTemplate__c
//                    WHERE KDCE_ExternalId__c = :SURVEY_NOTIFICATION_TEMEPLATE // 임시 Survey용 Template
//            ];
//            for (NotificationTemplate__c nt : notificationTemplateList) {
//                ntMap.put(nt.KDCE_ExternalId__c, nt);
//            }
//
//            System.debug('ntMap => ' + ntMap);
//
//            NotificationGroup__c notificationGroup = new NotificationGroup__c();
//            List<Notification__c> notiList = new List<Notification__c>();
//            Set<Id> caseIdSet = new Set<Id>();
//            Notification__c noti;
//
//            for (Case newCase : (List<Case>) Trigger.new) {
//
//                // Case에 폰넘버가 없으면 넘어가도록
//                if (newCase.ContactPhone == null) continue;
//
//                // NPS 발송 여부 : false // true 일 경우 발송 이력이 있음
//                // 발송이 완료 된 후 KDCE_NPSSent__c = true
//                if (newCase.KDCE_NPSsent__c == true) continue;
//                System.debug('Status -> '+ newCase.Status);
//                System.debug('SendNPS -> '+ newCase.KDCE_SendNPS__c);
//                System.debug('NPSSent__c -> ' + newCase.KDCE_NPSsent__c);
//                if (newCase.Status == 'Closed' && newCase.KDCE_SendNPS__c == 'Yes' && newCase.KDCE_NPSSent__c == false) {
//                    noti = new Notification__c();
//                    noti.NotificationTemplate__c = ntMap.get(SURVEY_NOTIFICATION_TEMEPLATE)?.Id;
//                    noti.Channel__c = '0';
//                    noti.LABEL1__c = SURVEY_ID;
//                    noti.LABEL2__c = newCase?.ContactId;
//                    noti.LABEL3__c = newCase?.Id;
//                    noti.Type__c = '2'; // Information
//                    noti.RawContents__c = ntMap.get(SURVEY_NOTIFICATION_TEMEPLATE)?.Content__c;
//                    noti.Contact__c = newCase?.ContactId;
//                    notiList.add(noti);
//
//                    caseIdSet.add(newCase.Id);
//                }
//            }
//
//            System.debug('notiList size => ' + notiList.size());
//            if (!notiList.isEmpty()) {
//                insert notificationGroup;
//                for (Notification__c notification : notiList) {
//                    notification.NotificationGroup__c = notificationGroup.Id;
//                }
//                System.debug('notiList = >  ' + notiList);
////                insert notiList;  // TODO Case Status 종료시 오류남
//
//                // Case 서베이 시간 업데이트
//                List<Case> caseList = [SELECT Id, KDCE_SurveySentDateTime__c FROM Case WHERE Id IN :caseIdSet];
//                List<Case> updateCaseList = new List<Case>();
//                System.debug('=== caseList : ' + caseList);
//                for (Case ca : caseList) {
//                    if(ca.KDCE_SurveySentDateTime__c == null) {
//                        ca.KDCE_SurveySentDateTime__c = System.now();
//                        updateCaseList.add(ca);
//                    }
//                }
//                if (!updateCaseList.isEmpty()){
//                    isAlreadyExecuted = true;
//                    update updateCaseList;
//                    isAlreadyExecuted = false;
//                }
//
//                // Case.tr 에서 Survey SMS 발송을 위한 기존 NotiSend X / Custom i2SEMA_IFNotificationSend_qu 생성
//                // SMS Send and Chatter Post
//                if(!Test.isRunningTest()) {
//                    KDCE_i2SEMA_IFNotificationSendSMS_qu messageSendWholeQu = new KDCE_i2SEMA_IFNotificationSendSMS_qu(notiList);
//                    // TODO 문자 보내려면 주석 해제해야함
//                    //Id messageSendWholeJobId = System.enqueueJob(messageSendWholeQu);
//                }
//                System.debug('========== END ==========');
//            }
//        }
//    }





    /**
     *  하위 Case가 완료되면 상위 Case도 완료 처리
     *
     */
    private void parentCaseComplete() {
        System.debug('@@@@@@ parentCaseComplete @@@@@@');

        Set<String> parentSet = new Set<String>();
        Case oldCase;
        for (Case newCase : (List<Case>) Trigger.new) {
            currentClickCaseIds.add(newCase.Id);

            if(Trigger.isInsert){
                if (newCase.Status == 'Closed' && newCase.ParentId != null) parentSet.add(newCase.ParentId);

            }
            if (!Trigger.isUpdate) continue;
            oldCase = (Case) Trigger.oldMap.get(newCase.Id);
            if (oldCase.Status != 'Closed' && newCase.Status == 'Closed' && newCase.ParentId != null) parentSet.add(newCase.ParentId);
        }
        if (parentSet.isEmpty()) return;

        List<Case> parentCaseList = [
                SELECT Id,Status
                FROM Case
                WHERE Id IN:parentSet AND IsClosed = false
        ];

        for (Case parentCase : parentCaseList) {
            parentCase.Status = 'Closed';
        }

        //Case Owner가 아닌 사람이 Closed 처리하면 에러 (Validation Rule)
        //Case 종료되면 Survey가 나갈것으로 예상 여러 건  나가는게 맞는지 확인
        if (!parentCaseList.isEmpty()) update parentCaseList;

    }

    /**
     * @param newCase
     * @return Name+'_'+Phone
     */
    private String getContactExtNamePNKey(Case newCase) {
        System.debug('=== getContactExtNamePNKey ===');
        if (newCase.SuppliedPhone ==null) {
            return newCase.SuppliedName+''+math.random()*10000;
        }else{
            return newCase.SuppliedName + '_' + (newCase.SuppliedPhone != null ? newCase.SuppliedPhone.remove('-') : '');
        }

    } /**
     * @param newCase
     * @return Name+'_'+Email
     */
    private String getContactExtNameEMKey(Case newCase) {
        if (newCase.SuppliedEmail ==null) {
            return newCase.SuppliedName+''+math.random()*10000;
        }else{
            return newCase.SuppliedName + '_' +(newCase.SuppliedEmail != null ? newCase.SuppliedEmail : '');
        }
    }

    /**
     *
     */
    private String getContactExtNamePNEMKey(Case newCase) {
        String casePhone;
        String namePNEM;
        if (newCase.SuppliedPhone == null && newCase.SuppliedEmail == null) {
            return newCase.SuppliedName+''+math.random()*10000;
        } else {
            casePhone = newCase?.SuppliedPhone != null ? (newCase?.SuppliedPhone.contains('-') ? newCase?.SuppliedPhone.remove('-') : newCase?.SuppliedPhone) : '';
            namePNEM = newCase?.SuppliedName + '_' + casePhone + '_' + (newCase?.SuppliedEmail != null ? newCase?.SuppliedEmail : '');
            return namePNEM;
        }
//        String casePhone = newCase?.SuppliedPhone.contains('-') ? newCase?.SuppliedPhone.remove('-') : newCase?.SuppliedPhone;
//        String namePNEM = newCase?.SuppliedName + '_' + casePhone + '_' + newCase?.SuppliedEmail;
//        return namePNEM;
    }

    /**
     * Case 및 Task 관련 업데이트
     * 1. Case가 AE Record Type으로 변경되면, 관련 Case 및 Task에 Contact 필드 제거
     *      (Call Center에서 처음 Task 만들어질때 무조건 Profile에 존재하는 Case Record Type '1. Inquiry'로 생성됨
     * 2. Case가 Close 되면, 관련 Task도 Completed
    */
    private void setContactNullByRT() {
        System.debug('@@@@@@ setContactNullByRT @@@@@@');
        System.debug('=== isAlreadyExecuted : ' + isAlreadyExecuted);

        if (!isAlreadyExecuted) {
            Case oldCase;

            Set<Id> caseRecordTypeAEIds = new Set<Id>();
            Set<Id> caseStatusCloseIds = new Set<Id>();
            for (Case newCase : (List<Case>) Trigger.new) {
                oldCase = (Case) Trigger.oldMap.get(newCase.Id);

                // Task 업데이트를 위한 Case Id 값 저장
                if (oldCase.RecordTypeId != newCase.RecordTypeId && newCase.RecordTypeId == adverseEventRTId) caseRecordTypeAEIds.add(newCase.Id);
                System.debug('=== oldCase.Status : ' + oldCase.Status);
                System.debug('=== newCase.Status : ' + newCase.Status);

                // Case Close시, Task Status Close를 위한 Set
                if (oldCase.Status <> newCase.Status && newCase.Status == 'Closed') caseStatusCloseIds.add(newCase.Id);
            }
            System.debug('=== caseRecordTypeAEIds : ' + caseRecordTypeAEIds);
            System.debug('=== caseStatusCloseIds : ' + caseStatusCloseIds);

            Map<Id, Case> caseUpdateMap = new Map<Id, Case>();
            Map<Id, Task> taskUpdateMap = new Map<Id, Task>();

            // Case가 AE Record Type으로 변경되면, 관련 Case 및 Task에 Contact 필드 제거
            if (caseRecordTypeAEIds.size() > 0) {
                // Case update
                for (Case ca : [SELECT Id, ContactId FROM Case WHERE Id IN :caseRecordTypeAEIds]) {
                    ca.ContactId = null;
                    caseUpdateMap.put(ca.Id, ca);
                }

                // Task update
                for (Task task : [SELECT Id, WhatId, WhoId FROM Task WHERE WhatId IN :caseRecordTypeAEIds]) {
                    task.WhoId = null;
                    taskUpdateMap.put(task.Id, task);
                }
            }

            // Case Close시, 관련 Task Status Completed
            Task newTask = new Task();
            if (caseStatusCloseIds.size() > 0) {
                // Task update
                for (Task task : [SELECT Id, WhatId, WhoId FROM Task WHERE WhatId IN :caseStatusCloseIds]) {
                    if (taskUpdateMap.containsKey(task.Id)) newTask = taskUpdateMap.get(task.Id);
                    task.Status = 'Completed';
                    taskUpdateMap.put(task.Id, task);
                }
            }
            System.debug('=== caseUpdateMap : ' + caseUpdateMap);
            System.debug('=== taskUpdateMap : ' + taskUpdateMap);

            if (caseUpdateMap.size() > 0) update caseUpdateMap.values();
            if (taskUpdateMap.size() > 0) update taskUpdateMap.values();

        }

    }



    private void sendNPSSurveySMS() {
        System.debug('=============================START ::  Case_tr.sendNPSSurveySMS() ===================================');

        List<Case> closeCaseList = new List<Case>();
        if (Trigger.isInsert) {
            for (Case item : (List<Case>) Trigger.new) {
                if (item.Status == 'Closed' && item.KDCE_SendNPS__c == 'Yes' && item.KDCE_IsOnlineCase__c ) {
                    closeCaseList.add(item);
                    System.debug('Insert item'  + item);
                }
                if(!item.KDCE_IsOnlineCase__c )
                    System.debug('============================== Offline 생성 케이스입니다. =============================');
            }
            if (closeCaseList.isEmpty()) return;
        }

        if (Trigger.isUpdate) {
            for (Case item : (List<Case>) Trigger.new) {
                if (item.Status == 'Closed' && ((Case) Trigger.oldMap.get(item.Id)).Status != 'Closed'
                        && item.KDCE_SendNPS__c == 'Yes' && item.KDCE_IsOnlineCase__c) {
                    closeCaseList.add(item);
                    System.debug('Update item' + item);
                }
                if(!item.KDCE_IsOnlineCase__c )
                    System.debug('============================= Offline 생성 케이스입니다. =============================');
            }
            if (closeCaseList.isEmpty()) return;
        }

        System.debug('closeCaseList :: ' + closeCaseList);

        // 같이 Close된 건들 체크(상위 Case) // 룩업 안되니까 음....
        Set<Id> caseIds = new Set<Id>();
        for (Case caseItem : closeCaseList) {
            caseIds.add(caseItem.Id);
        }

        System.debug(currentClickCaseIds);
        System.debug('!caseIds.contains(currentClickCaseIds.get(0)) :: ' + caseIds.contains(currentClickCaseIds.get(0)));
        if(caseIds.contains(currentClickCaseIds.get(0)) == false) return;

        final String CaseRT3 = '3-홀더/충전기/액세서리 이슈';
        final String CaseRT7 = '7-히츠 스틱';


        /************************************************************************************************************
        Case.CCR_SubjectCodeNew__c(PickList)의 API와 KDCE_SurvyPerSubjectCode__c.SubjectCodeApi__c가 일치해야함.
        ***********************************************************************************************************/
        Map<String, KDCE_SurvyPerSubjectCode__c> surveySubjectCodeMap = new Map<String, KDCE_SurvyPerSubjectCode__c>();
        for (KDCE_SurvyPerSubjectCode__c item : [SELECT Id, Category__c, SubjectCodeApi__c, Survey__c, SendOutPriority__c FROM KDCE_SurvyPerSubjectCode__c]) {
            if (item.Category__c == caseRT3 || item.Category__c == caseRT7) {
                surveySubjectCodeMap.put(item.Category__c, item);
            }
            if (item.SubjectCodeApi__c <> null) surveySubjectCodeMap.put(item.SubjectCodeApi__c, item);

        }

        System.debug('@@@ surveySubjectCodeMap :: ' + surveySubjectCodeMap);


        Map<Id, Case> caseMapByIds = new Map<Id, Case>([
                SELECT
                        Id, Status, CCR_SubjectCodeNew__c, KDCE_NPSsent__c, KDCE_SendNPS__c, KDCE_SendNPSDateTime__c, CCR_SubType__c,
                        ContactId, Contact.KDCE_ExternalId__c, Contact.KDCE_LastNPSSendDate__c, RecordType.DeveloperName, RecordTypeId,
                        //Parent
                        ParentId, Parent.Status, Parent.CCR_SubjectCodeNew__c, Parent.KDCE_NPSsent__c,
                        Parent.KDCE_SendNPS__c, Parent.KDCE_SendNPSDateTime__c, Parent.RecordType.DeveloperName, Parent.RecordTypeId,
                        // Parent.Parent
                        Parent.ParentId, Parent.Parent.Status, Parent.Parent.CCR_SubjectCodeNew__c,
                        Parent.Parent.KDCE_NPSsent__c, Parent.Parent.KDCE_SendNPS__c, Parent.Parent.KDCE_SendNPSDateTime__c,
                        Parent.Parent.RecordType.DeveloperName, Parent.Parent.RecordTypeId
                FROM Case
                WHERE Id IN :caseIds
                AND Status = 'Closed' AND KDCE_SendNPS__c = 'Yes' AND KDCE_NPSSent__c = false
                ORDER BY ContactId
        ]);

        List<Case> caseList;
        //if (Trigger.isInsert)       caseList = (List<Case>) Trigger.new;
        if (Trigger.isInsert)       caseList = closeCaseList;
        else if (Trigger.isUpdate)  caseList = caseMapByIds.values();


//        Set<Id> totalIds = caseIds.clone();
//        Map<Id, Case> casesByIds = new Map<Id, Case>([SELECT Id, Status, CCR_SubjectCodeNew__c, ParentId FROM Case WHERE Id IN :caseIds]);

        Decimal currentPriority;
        Decimal parentPriority = 1000;
        Decimal parentOfParentPriority = 1000;
        KDCE_SurvyPerSubjectCode__c tempSurvey;

        List<i2SEMA_Util.Receiver> npsReceivers = new List<i2SEMA_Util.Receiver>();
        List<String> labels;
        i2SEMA_Util.Receiver receiver;
        i2SEMA_Util.I2Notification msg;

        KDCE_SurvyPerSubjectCode__c parentOfParentCase;
        KDCE_SurvyPerSubjectCode__c parentCase;
        KDCE_SurvyPerSubjectCode__c currentCase;


        List<SObject> updateSObjects = new List<SObject>();

        System.debug('!! caseList :: ' + caseList);
        System.debug('!! caseList.size :: ' + caseList.size());


        if (!caseList.isEmpty()) {
            Set<Id> contactIds = new Set<Id>();
            for (Case item : caseList) {
                if (item.ContactId <> null) contactIds.add(item.ContactId);
            }


            Boolean parentOfParentFlag = false;
            Boolean parentFlag = false;
            Boolean currentFlag = false;
            Map<Id, Contact> contactIdMap = new Map<Id, Contact>([SELECT Id, KDCE_ExternalId__c, KDCE_LastNPSSendDate__c FROM Contact WHERE Id IN :contactIds]);
            Set<String> exclusionSubType = new Set<String>{'Rental +21', 'Up / Cross Sell & Trade In'
            };
            System.debug('contactIdMap : ' + contactIdMap);
            System.debug('exclusionSubType : ' + exclusionSubType);
            for (Case item : caseList) {
                //if(item.CCR_SubjectCodeNew__c == null) continue;
                System.debug('subtype ' + item.CCR_SubType__c + ')');

                if(exclusionSubType.contains(item.CCR_SubType__c) ){
                    System.debug('=============================================================================================');
                    System.debug('해당 SubType은 NPS가 발송되지 않습니다. ( ' + item.CCR_SubType__c + ')');
                    System.debug('=============================================================================================');
                    continue;
                }

                // NPS 마지막 전송 일자 체크
                //todo map에서 가져오기
                if (contactIdMap?.get(item.ContactId)?.KDCE_LastNPSSendDate__c == System.today()) {
                    System.debug('=============================================================================================');
                    System.debug('오늘 해당 컨택에 NPS 설문 전송 내역이 있습니다. ( ' + item.Contact.KDCE_LastNPSSendDate__c + ')');
                    System.debug('=============================================================================================');
                } else {
                    labels = new List<String>();
                    receiver = new i2SEMA_Util.Receiver();
                    // 3 depth
                    System.debug(item.Parent.ParentId);
                    System.debug(item.Parent.Parent.Status);
                    System.debug(item.Parent.Parent.KDCE_SendNPS__c);
                    System.debug(item.Parent.Parent.KDCE_NPSSent__c);
                    if (item.Parent.ParentId <> null && item.Parent.Parent.Status == 'Closed' && item.Parent.Parent.KDCE_SendNPS__c == 'Yes' && item.Parent.Parent.KDCE_NPSSent__c == false) {
                        System.debug('surveySubjectCodeMap.containsKey(item.Parent.Parent.CCR_SubjectCodeNew__c)' + surveySubjectCodeMap.containsKey(item.Parent.Parent.CCR_SubjectCodeNew__c));
                        if (!surveySubjectCodeMap.containsKey(item.Parent.Parent.CCR_SubjectCodeNew__c)) {
                            System.debug('=============================================================================================');
                            System.debug('Survey per SubjectCode Obj에 해당하는 Subject Code가 없습니다 ( ' + item.Parent.Parent.CCR_SubjectCodeNew__c + ')');
                            System.debug('=============================================================================================');

                        } else {
                            parentOfParentCase = surveySubjectCodeMap.get(item.Parent.Parent.CCR_SubjectCodeNew__c);
                            if (item.Parent.Parent.RecordTypeId == accessoryRTId) parentOfParentCase = surveySubjectCodeMap.get(caseRT3);
                            if (item.Parent.Parent.RecordTypeId == heatStickRTId) parentOfParentCase = surveySubjectCodeMap.get(caseRT7);
                            parentOfParentPriority = parentOfParentCase.SendOutPriority__c;
                        }
                    }

                    //  2 depth
                    else if (item.ParentId <> null && item.Parent.Status == 'Closed' && item.Parent.KDCE_SendNPS__c == 'Yes' && item.Parent.KDCE_NPSSent__c == false) {
                        System.debug('2 depth');
                        if (item.Parent.RecordTypeId == accessoryRTId) parentCase = surveySubjectCodeMap.get(caseRT3);
                        if (item.Parent.RecordTypeId == heatStickRTId) parentCase = surveySubjectCodeMap.get(caseRT7);
                        if (parentCase == null) {
                            if (!surveySubjectCodeMap.containsKey(item.Parent.CCR_SubjectCodeNew__c)) {
                                System.debug('=============================================================================================');
                                System.debug('Survey per SubjectCode Obj에 해당하는 Subject Code가 없습니다 ( ' + item.Parent.CCR_SubjectCodeNew__c + ')');
                                System.debug('=============================================================================================');
                            } else {
                                parentCase = surveySubjectCodeMap.get(item.Parent.CCR_SubjectCodeNew__c);
                            }
                        }
                        parentPriority = parentCase ?.SendOutPriority__c;

                    }

                    // 1 depth
                    if (item.RecordTypeId == accessoryRTId) currentCase = surveySubjectCodeMap.get(caseRT3);
                    if (item.RecordTypeId == heatStickRTId) currentCase = surveySubjectCodeMap.get(caseRT7);
                    if (currentCase == null) {
                        if (!surveySubjectCodeMap.containsKey(item.CCR_SubjectCodeNew__c)) {
                            System.debug('=============================================================================================');
                            System.debug('Survey per SubjectCode Obj에 해당하는 Subject Code가 없습니다 ( ' + item.CCR_SubjectCodeNew__c + ')');
                            System.debug('=============================================================================================');
                        } else {
                            currentCase = surveySubjectCodeMap.get(item.CCR_SubjectCodeNew__c);
                        }
                    }
                    System.debug('currentCase :: ' + currentCase);
                    currentPriority = currentCase ?.SendOutPriority__c;

                    // priority 계산
                    System.debug('parentOfParentPriority :: ' + parentOfParentPriority);
                    System.debug('parentPriority :: ' + parentPriority);
                    System.debug('currentPriority :: ' + currentPriority);

                    String priorityCaseId = item.Id;
                    if (parentOfParentPriority < parentPriority) {
                        if (parentOfParentPriority < currentPriority) {
                            System.debug('parentOfParentPriority < currentPriority');
                            tempSurvey = parentOfParentCase;
                            parentOfParentFlag = true;
                            priorityCaseId = item.Parent.ParentId;


                        } else if (parentOfParentPriority >= currentPriority) {
                            System.debug('parentOfParentPriority >= currentPriority');
                            tempSurvey = currentCase;
                            currentFlag = true;
                        }
                    } else if (parentOfParentPriority >= parentPriority) {
                        if (parentPriority < currentPriority) {
                            System.debug('parentPriority < currentPriority');
                            tempSurvey = parentCase;
                            parentFlag = true;
                            priorityCaseId = item.ParentId;

                        } else if (parentPriority >= currentPriority) {
                            System.debug('parentPriority >= currentPriority');
                            tempSurvey = currentCase;
                            currentFlag = true;

                        }
                    }
                    /*
                    System.debug('currentCase ' + currentCase);
                    System.debug('tempSurvey ' + tempSurvey);
                    System.debug('priorityCaseId ' + priorityCaseId);

                    System.debug('::::::::::::::::::::::::::: 3 depth ::::::::::::::::::::::::::: ');
                    System.debug(item.Parent.Parent.Status);
                    System.debug(item.Parent.Parent.KDCE_SendNPS__c);
                    System.debug(item.Parent.Parent.KDCE_NPSSent__c);
                    System.debug(item.Parent.Parent.RecordType.DeveloperName);
                    System.debug(item.Parent.Parent.CCR_SubjectCodeNew__c);
                    System.debug(parentOfParentCase);
                    System.debug(parentOfParentPriority);

                    System.debug('::::::::::::::::::::::::::: 2 depth ::::::::::::::::::::::::::: ');
                    System.debug(item.Parent.Status);
                    System.debug(item.Parent.KDCE_SendNPS__c);
                    System.debug(item.Parent.KDCE_NPSSent__c);
                    System.debug(item.Parent.RecordType.DeveloperName);
                    System.debug(item.Parent.CCR_SubjectCodeNew__c);
                    System.debug(parentCase);
                    System.debug(parentPriority);

                    System.debug('::::::::::::::::::::::::::: 1 depth ::::::::::::::::::::::::::: ');
                    System.debug(item.Status);
                    System.debug(item.KDCE_SendNPS__c);
                    System.debug(item.KDCE_NPSsent__c);
                    System.debug(item.RecordType.DeveloperName);
                    System.debug(item.CCR_SubjectCodeNew__c);
                    System.debug(currentCase);
                    System.debug(currentPriority);
                    System.debug(item);
                    System.debug(item.ContactId);
                    */


                    // Notiforce 전송 라벨/수신자 설정
                    labels.add(tempSurvey ?.Survey__c);
                    labels.add(item.ContactId);
                    labels.add(priorityCaseId);

//                receiver.receiverExtId = item.Contact.KDCE_ExternalId__c;
                    receiver.receiverExtId = contactIdMap?.get(item.ContactId)?.KDCE_ExternalId__c;
                    receiver.labels = labels;
                    npsReceivers.add(receiver);
                }
            }

            // 전송하기 //KDCE_NotificationTemplate_NPS
            if(!npsReceivers.isEmpty()){
                msg = new i2SEMA_Util.I2Notification();
                msg.templateExtId = System.Label.KDCE_NotificationTemplate_NPS; //'NT-210517-00077';
                msg.receiverType = 'Contact';
                msg.receivers = npsReceivers;
                //todo 주석 풀기
                if(!Test.isRunningTest())i2SEMA_Util.sendNotification(msg);
            }

            System.debug('@@@ msg :: ' + msg);
            // msg.isSuccess=Y 인 경우 contact 업데이트하기(item.Contact.KDCE_LastNPSSendDate__c = System.today();)
            List<Contact> updateContacts = new List<Contact>();
            if(msg<>null && msg.receivers.get(0).isSuccess == 'Y' ){
                Id tmpContId = labels.get(1);
                Id tmpCaseId = labels.get(2);
                Contact tempContact = contactIdMap?.get(tmpContId);
                // Contact에 최신 NPS 전송일자 업데이트
                if(tempContact <> null) {
                    tempContact.KDCE_LastNPSSendDate__c = System.today();
                    updateContacts.add(tempContact);
                }

                Case tempCase = caseMapByIds?.get(tmpCaseId);
                System.debug('parentOfParentFlag ' + parentOfParentFlag);
                System.debug('parentFlag ' + parentFlag);
                System.debug('currentFlag ' + currentFlag);

                if(tempCase <> null){
                    tempCase.KDCE_NPSsent__c = true;
                    tempCase.KDCE_SendNPSDateTime__c = System.now();
                    updateSObjects.add(tempCase);
                }
            }


            System.debug('@@@ updateCases :: ' + updateSObjects);

            //case, contact update
            if(!updateContacts.isEmpty()) update updateContacts;

            if(!updateSObjects.isEmpty()) update updateSObjects;

            System.debug('============================= END ::  Case_tr.sendNPSSurveySMS() ===================================');
        }
    }

    //  Related Case에서 6번 레코드 생성 시, 저장 막기(AE 레코드 유형에서는 상위 사례를 가질 수 없다.)
    private void validationRtAE(){
        System.debug('validationRtAE');
        for(Case item : (List<Case>)Trigger.new){
            if(item.RecordTypeId == adverseEventRTId && item.ParentId <> null){
                item.addError(System.Label.KDCE_CannotHaveParentCaseAE);
            }
        }
    }

    // 카카오 상담톡 세션 종료. 업데이트 할 때만 처리됨
    private void closeKakaoSession() {

        // 카카오 세션 종료는 단건으로 밖에 처리가 되지 않기때문에 트리거지만 1건으로 처리되는 경우에만 처리되도록 하드코딩
        if(Trigger.new.size() == 1){

            Case closeCase = (Case)Trigger.new[0];
            Case oldCase = (Case)Trigger.oldMap.get(closeCase.Id);

            // 상태 값이 Closed 로 변경된 경우에만 처리
            if(closeCase.Status != oldCase.Status && closeCase.Status == 'Closed'){

                List<Kakao_Consult_Chat__c> consultList = [
                        SELECT Id, Case__c, Session_Live__c, User_Key__c
                        FROM Kakao_Consult_Chat__c
                        WHERE Case__c = :closeCase.Id
                ];

                if(consultList.size() == 1) {
                    // 세션이 살아있는 경우에만 처리
                    if(consultList[0].Session_Live__c == true) {

                        System.debug('=== consultList : ' + consultList);
                        KDCE_KakaoSession.closeSession(consultList[0].Id);
                        
                    }
                }
            }
        }

    }
}