/****************************************************************************************
  * @filename      : KDCE_Contact_tr
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-02-25 오전 9:01
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
    0.1     2021-02-25 오전 9:01     i2max_Jihyun.Lee        Create
****************************************************************************************/

public without sharing class KDCE_Contact_tr extends TriggerHandler {

    // 사용자 권한을 강제로 무시하기 위한 innerClass
    public without sharing class ignoreAuthorityInnerClass {
        public void forceDelete(List<KDCE_DormantContact__c> deleteList) {
            delete deleteList;
        }
    }

    public static Boolean isAlreadyExecuted = false;    // 재귀호출 방지 flag
    public static Boolean dormantContact = false;

    public override void beforeInsert() {
        setDefault();                       // Default 값 설정
        setMaskingField();                  // Contact LastName 마스킹처리
        setExtId();                         // External Id 설정
        checkDuplicate();                   // Contact 생성시, 전화번호나 이메일로 중복체크
        contactFieldUpdate();               // Contact 필드 업데이트
        createAccountRecord();              // Account 생성
    }

    public override void beforeUpdate() {
        preventNameChanges();               //
        setDefault();                       // Default 값 설정
        restoreContact();                   // 비활성 Contact을 활성 Contact으로 변경
        setMaskingField();                  // Contact LastName 마스킹처리
        setExtId();                         // External Id 설정
        checkDuplicate();                   // Contact 생성시, 전화번호나 이메일로 중복체크
        contactFieldUpdate();               // Contact 필드 업데이트
        updateIsMGMIssueUponUpdate();       // LAS -> Lau 업데이트시, 쿠폰 발급 체크
        issueMGMCoupon();                   // 쿠폰 발급 체크시, History 생성과 같은 데이터 생성
        updateAccountRecord();              // Contact Name 변경시, Account Name 변경
        recalculateAssetCarePlusStatus();   // Prospect에서 Member로 변경시, Asset.CarePlusStatus 변경
    }


    public override void afterInsert() {
//        createContactHistory();     // 필드변경시, Contact History 생성
        setKakaoMapping();  // 카카오 챗 연결을 위한 처리
        setDefaultStoreContact();           // Store Contact 생성시 store정보에 contact id 저장
    }

    public override void afterUpdate() {
//        createContactHistory();     // 필드변경시, Contact History 생성
        deleteDormantContact();         // 복구된 Contact에 대한 Dormant Contact 레코드 삭제
        if (isAlreadyExecuted == false) {
//            if(!Test.isRunningTest())restoreCaseOrder();     // 비활성 Contact을 활성 Contact으로 변경시, 관련된 Case 및 Order 값도 복구
            isAlreadyExecuted = true;
        }
        if (!Test.isRunningTest()) restoreRelatedObject();

        setKakaoMapping();  // 카카오 챗 연결을 위한 처리
    }

    // 쿠폰 RecordType 별 DeveloperName, Id의 Map
    private static Map<String, Id> rtNameMap_Coupon = KDCE_Util.getRecordTypeBySObject('KDCE_Coupon__c');

    // 쿠폰 RecordType 별 Id, DeveloperName의 Map
    private static Map<Id, String> rtIdMap_Coupon = KDCE_Util.getRecordNameBySObject('Contact');

    // Contact RecordType 별 Developer Name, Id의 Map
    private static Map<String, Id> rtNameMap_Contact = KDCE_Util.getRecordTypeBySObject('Contact');

    private final static Id RT_Contact_AnonymousId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Anonymous').getRecordTypeId();    // 고객 : Anonymous
    private final static Id RT_Contact_ProspectId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Prospect').getRecordTypeId();     // 고객 : Prospect
    private final static Id RT_Contact_MemberId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Member').getRecordTypeId();       // 고객 : iqos.com 회원 멤버

    /**
     * Store Contact 생성시, 해당 store에 contact Id 정보 저장
     */
    private void setDefaultStoreContact() {
        Map<String, String> contactByStore = new Map<String, String>();
        List<KDCE_Store__c> storeList = new List<KDCE_Store__c>();
        for (Contact contact : (List<Contact>) Trigger.new) {
            if (contact?.KDCE_IsStoreContact__c == true && contact?.KDCE_Store__c != null && contact.Name != null && contact.Name.contains('Rental')) {
                contactByStore.put(contact.KDCE_Store__c, contact.Id);
            }
        }

        for(KDCE_Store__c store : [SELECT Id, RentalContactId__c FROM KDCE_Store__c WHERE Id IN :contactByStore.keySet()]) {
            store.RentalContactId__c = contactByStore?.get(store.Id);
            storeList.add(store);
        }
        if (!storeList.isEmpty()) update storeList;
    }

    /**
     * Profile 기반 이름 수정 권한 있는지 없는지 확인
     */
    private void preventNameChanges() {
        Set<Id> userProfileId = new Set<Id>();
        for (Contact item : (List<Contact>) Trigger.new) {
            Contact oldContact = (Contact) Trigger.oldMap.get(item.id);
            if (item.RecordTypeId == RT_Contact_MemberId && item.LastName != oldContact.LastName) {
                userProfileId.add(UserInfo.getProfileId());
            }
        }
        if (!userProfileId.isEmpty()) {
            Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Id IN :userProfileId]);

            Id profileId;
            for (Contact item : (List<Contact>) Trigger.new) {
                profileId = UserInfo.getProfileId();
                System.debug(profileMap?.get(profileId).Name);
                if (profileMap?.get(profileId).Name.contains('Standard'))
                    item.addError(System.Label.KDCE_PreventEditName);
            }
        }
    }


//    /**
//      * 중복체크 (2021.04.29)
//      * <<< Anonymous가 아닐 경우 >>>
//      * - 전화번호 + 이메일 둘 다 없는 경우 에러
//      * <<< Prospect가 들어왔을 경우 중복 체크 (우선순위별 체크) >>>
//      * - 이름 +
//      * - 우선순위별 체크
//      * 1. 이름 + 핸드폰 + 이메일
//      * 2. 이름 + 핸드폰
//      * 3. 이름 + 전화번호
//      */
//    private void checkDuplicate() {
//        System.debug('@@@@@@ checkDuplicate @@@@@@');
//        List<Contact> insertContacts = new List<Contact>();
//        Set<String> contactNamePNEMSet = new Set<String>(); // 이름 + 전화번호 + 이메일
//        Set<String> contactNamePNSet = new Set<String>();     // 이름 + 전화번호
//        Set<String> contactNameEMSet = new Set<String>();     // 이름 + 이메일
//
//        for (Contact newRecord : (List<Contact>) Trigger.new) {
//            if (newRecord.RecordTypeId != RT_Contact_AnonymousId && !newRecord.KDCE_IsStoreContact__c && !newRecord.KDCE_IsDormant__c && !newRecord.KDCE_IsDropout__c) {
//                if (newRecord.Phone == null && newRecord.Email == null) newRecord.addError(System.Label.KDCE_MustEnterEmailOrPhone);    // Phone & Email 둘다 없을 경우
//                if (newRecord.RecordTypeId == RT_Contact_ProspectId) {
//                    insertContacts.add(newRecord);
//                    if (newRecord.Phone != null && newRecord.Email != null) contactNamePNEMSet.add(newRecord.KDCE_NamePNEMKey__c);      // 이름 + Phone + Email
//                    else if (newRecord.Phone != null && newRecord.Email == null) contactNamePNSet.add(newRecord.KDCE_NamePNKey__c);     // 이름 + Phone
//                    else if (newRecord.Phone == null && newRecord.Email != null) contactNameEMSet.add(newRecord.KDCE_NameEMKey__c);     // 이름 + Email
//                }
//            }
//        }
//
//        // 일치하는 Contact 찾기
//        Map<String, Contact> dupCheck = new Map<String, Contact>();
//        Set<String> dupCheckSet = new Set<String>();
//        Map<String, List<Contact>> dupCheckMap = new Map<String, List<Contact>>();
//        List<Contact> contacts = new List<Contact>();
//        for (Contact contact : [
//                SELECT Id, KDCE_NamePNEMKey__c, KDCE_NamePNKey__c, KDCE_NameEMKey__c FROM Contact
//                WHERE KDCE_NamePNEMKey__c IN :contactNamePNEMSet
//                OR KDCE_NamePNKey__c IN :contactNamePNSet
//                OR KDCE_NameEMKey__c IN :contactNameEMSet]) {
//            if (contactNamePNEMSet.contains(contact.KDCE_NamePNEMKey__c)) {
//                if (dupCheckMap.containsKey(contact.KDCE_NamePNEMKey__c)) contacts = dupCheckMap.get(contact.KDCE_NamePNEMKey__c);
//                dupCheckSet.add(contact.KDCE_NamePNEMKey__c);
//                contacts.add(contact);
//                dupCheckMap.put(contact.KDCE_NamePNEMKey__c, contacts);
//            }
//            else if (contactNamePNSet.contains(contact.KDCE_NamePNKey__c)) {
//                if (dupCheckMap.containsKey(contact.KDCE_NamePNKey__c)) contacts = dupCheckMap.get(contact.KDCE_NamePNKey__c);
//                dupCheckSet.add(contact.KDCE_NamePNKey__c);
//                contacts.add(contact);
//                dupCheckMap.put(contact.KDCE_NamePNKey__c, contacts);
//            }
//            else if (contactNameEMSet.contains(contact.KDCE_NameEMKey__c)) {
//                if (dupCheckMap.containsKey(contact.KDCE_NameEMKey__c)) contacts = dupCheckMap.get(contact.KDCE_NameEMKey__c);
//                dupCheckSet.add(contact.KDCE_NameEMKey__c);
//                contacts.add(contact);
//                dupCheckMap.put(contact.KDCE_NameEMKey__c, contacts);
//            }
//        }
//        System.debug('=== dupCheckMap : ' + dupCheckMap);
//
//        // 중복되는지 확인
//        Contact oldRecord;
//        for (Contact newRecord : insertContacts) {
//            if (Trigger.isInsert) {
//                if (newRecord.KDCE_RegistrationObject__c == 'Contact') {
//                    if (dupCheckSet.contains(newRecord.KDCE_NamePNEMKey__c) || dupCheckSet.contains(newRecord.KDCE_NamePNKey__c) || dupCheckSet.contains(newRecord.KDCE_NameEMKey__c)) newRecord.addError(System.Label.KDCE_DuplicateContact);
//                }
//            }
//            else if (Trigger.isUpdate) {
//                if ((dupCheckMap.containsKey(newRecord.KDCE_NamePNEMKey__c) && dupCheckMap.get(newRecord.KDCE_NamePNEMKey__c).size() > 1)
//                        || (dupCheckMap.containsKey(newRecord.KDCE_NamePNKey__c) && dupCheckMap.get(newRecord.KDCE_NamePNKey__c).size() > 1)
//                        || (dupCheckMap.containsKey(newRecord.KDCE_NameEMKey__c) && dupCheckMap.get(newRecord.KDCE_NameEMKey__c).size() > 1)) {
//                    newRecord.addError(System.Label.KDCE_DuplicateContact);
//                }
//            }
//        }
//    }
    private void checkDuplicate() {
        System.debug('@@@@@@ checkDuplicate @@@@@@');
        Set<String> checkNameEMSet = new Set<String>();
        Set<String> checkNamePNSet = new Set<String>();
        List<Contact> contactList = new List<Contact>();
        for (Contact newRecord : (List<Contact>) Trigger.new) {
            if (newRecord.Email != null) checkNameEMSet.add(newRecord.KDCE_NameEMKey__c);
            if (newRecord.Phone != null) checkNamePNSet.add(newRecord.KDCE_NamePNKey__c);
        }

        Set<String> dupNameEMSet = new Set<String>();
        Set<String> dupNamePNSet = new Set<String>();
        Map<String, Set<Id>> contactsByDupName = new Map<String, Set<Id>>();
        Set<Id> contacts;
        for (Contact contact : [
                SELECT Id, KDCE_NameEMKey__c, KDCE_NamePNKey__c
                FROM Contact
                WHERE KDCE_NameEMKey__c IN :checkNameEMSet
                OR KDCE_NamePNKey__c IN :checkNamePNSet
        ]) {
            if (Trigger.isInsert) {
                if (contact.KDCE_NameEMKey__c != null) dupNameEMSet.add(contact.KDCE_NameEMKey__c);
                if (contact.KDCE_NamePNKey__c != null) dupNamePNSet.add(contact.KDCE_NamePNKey__c);
            } else if (Trigger.isUpdate) {
                if (contactsByDupName.containsKey(contact.KDCE_NamePNKey__c)) {
                    contacts = contactsByDupName.get(contact.KDCE_NamePNKey__c);
                    contactsByDupName.put(contact.KDCE_NamePNKey__c, contacts);
                }
                else if (contactsByDupName.containsKey(contact.KDCE_NameEMKey__c)) {
                    contacts = contactsByDupName.get(contact.KDCE_NameEMKey__c);
                    contactsByDupName.put(contact.KDCE_NameEMKey__c, contacts);
                } else {
                    contacts = new Set<Id>();
                    contacts.add(contact.Id);
                    if (contact.KDCE_NameEMKey__c != null) contactsByDupName.put(contact.KDCE_NameEMKey__c, contacts);
                    if (contact.KDCE_NamePNKey__c != null) contactsByDupName.put(contact.KDCE_NamePNKey__c, contacts);
                }
            }
        }

        for (Contact newRecord : (List<Contact>) Trigger.new) {
            /*
             * Contact 중복규칙 적용될 때
             * 1. RecordType이 Anonymous아닐 때
             * 2. 매뉴얼로 만들때 (Case 혹은 Coupon을 통해 들어오는 Contact이 아닐때)
             * 3. 렌탈 Contact이 아닐때
             */
            // Member 혹은 Prospect일 경우에만 + Case로 들어오는 경우가 아니라 Contact으로 들어오는 경우여야 함
            if (newRecord.RecordTypeId != RT_Contact_AnonymousId && !newRecord.KDCE_IsStoreContact__c && !newRecord.KDCE_IsDormant__c && !newRecord.KDCE_IsDropout__c) {

                // 이메일과 Phone 둘다 없을 경우
                if (newRecord.Email == null && newRecord.Phone == null) {
                    newRecord.addError(System.Label.KDCE_MustEnterEmailOrPhone);
                }

                // Prospect 일 경우에만 Phone 혹은 이메일 중에 중복될 경우
                if (newRecord.RecordTypeId == RT_Contact_ProspectId) {
                    // Phone, Email 둘다 있을 경우 무조건 Phone 먼저 체크
                    if (newRecord.Phone != null) {
                        if (Trigger.isInsert) {
                            if (newRecord.KDCE_RegistrationObject__c == 'Contact') {    // Contact 매뉴얼로 생성될때만 확인 (Case로 생성되는 경우는 체크 x)
                                if (dupNamePNSet.contains(newRecord.KDCE_NamePNKey__c)) newRecord.addError(System.Label.KDCE_DuplicateContact);
                            }
                        } else if (Trigger.isUpdate) {
                            if ((contactsByDupName.containsKey(newRecord.KDCE_NamePNKey__c) && contactsByDupName.get(newRecord.KDCE_NamePNKey__c).size() > 1)) {
                                newRecord.addError(System.Label.KDCE_DuplicateContact);
                            }
                        }
                    } else if (newRecord.Email != null) {
                        if (Trigger.isInsert) {
                            if (newRecord.KDCE_RegistrationObject__c == 'Contact') {    // Contact 매뉴얼로 생성될때만 확인 (Case로 생성되는 경우는 체크 x)
                                if (dupNameEMSet.contains(newRecord.KDCE_NameEMKey__c)) newRecord.addError(System.Label.KDCE_DuplicateContact);
                            }
                        } else if (Trigger.isUpdate) {
                            if ((contactsByDupName.containsKey(newRecord.KDCE_NameEMKey__c) && contactsByDupName.get(newRecord.KDCE_NameEMKey__c).size() > 1)) {
                                newRecord.addError(System.Label.KDCE_DuplicateContact);
                            }
                        }
                    }
//                    if (newRecord.Email != null || newRecord.Phone != null) {
//                        if (Trigger.isInsert) {
//                            if (newRecord.KDCE_RegistrationObject__c == 'Contact') {    // Contact 매뉴얼로 생성될때만 확인 (Case로 생성되는 경우는 체크 x)
//                                if (dupNameEMSet.contains(newRecord.KDCE_NameEMKey__c) || dupNamePNSet.contains(newRecord.KDCE_NamePNKey__c)) newRecord.addError(System.Label.KDCE_DuplicateContact);
//                            }
//                        }
//                        else if (Trigger.isUpdate) {
//                            if ((contactsByDupName.containsKey(newRecord.KDCE_NameEMKey__c) && contactsByDupName.get(newRecord.KDCE_NameEMKey__c).size() > 1) || (contactsByDupName.containsKey(newRecord.KDCE_NamePNKey__c) && contactsByDupName.get(newRecord.KDCE_NamePNKey__c).size() > 1)) {
//                                newRecord.addError(System.Label.KDCE_DuplicateContact);
//                            }
//                        }
//                    }
                }
            }

            // Prospect인 경우, Soft Av가 반드시 Yes or No
//                if(newRecord.RecordTypeId == RT_Contact_ProspectId ){
//                    System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
//                    System.debug(newRecord.RecordTypeId == RT_Contact_ProspectId);
//                    System.debug(newRecord.CCR_SoftAgeVerifiedNew__c	 );
//                    //if(newRecord.CCR_SoftAgeVerifiedNew__c	 == 'Not declared' || newRecord.CCR_SoftAgeVerifiedNew__c	 ==  null) newRecord.addError('소프트 성인 인증에 Yes/No로 선택해주세요');
//                }
//
        }
    }

    /**
     * Default 값 설정 (2021.03.11 이지현)
     */
    private void setDefault() {
        System.debug('@@@@@@ setDefault @@@@@@');
        Set<Id> contactsIds = new Set<Id>();
        Map<Id, Boolean> isContactHasDeal = new Map<Id, Boolean>();   // Contact의 Order, Case, OP를 확인하여 탈퇴처리를 못하게 하는 것을 CHECK 하는 Map
        Set<String> invalidOrderStatus = new Set<String>{
                KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY, KDCE_GlobalValue.ORDER_STATUS_COMPLETE
        };
        for (Contact newRecord : (List<Contact>) Trigger.new) {
            contactsIds.add(newRecord.Id);
            if (newRecord.KDCE_RentalConsumer__c) isContactHasDeal.put(newRecord.Id, TRUE); // 렌탈일 경우
        }
        // 업데이트일 경우만 확인
        if (Trigger.isUpdate) {
            for (Case conCase : [SELECT Id, ContactId FROM Case WHERE ContactId IN :contactsIds AND Status NOT IN :KDCE_GlobalValue.CASE_STATUS_NOT_INPROGRESS_SET]) {
                isContactHasDeal.put(conCase.ContactId, TRUE);
            }
            // 온라인 주문만 포함해야하기 때문에 ActionChannel__c = 'iqos.com' 조건 추가
            for (KDCE_Order__c conOrder : [
                    SELECT Id, Contact__c
                    FROM KDCE_Order__c
                    WHERE Contact__c IN :contactsIds
                    AND ActionChannel__c = 'iqos.com'
                    AND ((OrderStatus__c NOT IN :KDCE_GlobalValue.ORDER_STATUS_NOT_INPROGRESS_SET AND CollectionStatus__c = NULL)
                    OR CollectionStatus__c IN :KDCE_GlobalValue.ORDER_COL_STATUS_INPROGRESS_SET)
            ]) {
                isContactHasDeal.put(conOrder.Contact__c, TRUE);
            }
            for (KDCE_OfflineProgram__c conOP : [SELECT Id, Contact__c FROM KDCE_OfflineProgram__c WHERE Contact__c IN :contactsIds AND Status__c IN :KDCE_GlobalValue.OP_STATUS_INPROGRESS_SET]) {
                isContactHasDeal.put(conOP.Contact__c, TRUE);
            }
        }


        for (Contact newRecord : (List<Contact>) Trigger.new) {
            // FirstName이 null이 아닐 경우, LastName과 FirstName 병합
            if (newRecord.FirstName != null) {
                newRecord.LastName = newRecord.LastName + newRecord.FirstName;
                newRecord.FirstName = null;
            }

            // 주소 처리 (서울특별시 -> 서울)
            newRecord.MailingState = KDCE_Util.getShortKrState(newRecord.MailingState);
            newRecord.OtherState = KDCE_Util.getShortKrState(newRecord.OtherState);
//            newRecord.KDCE_ShippingState__c = KDCE_Util.getShortKrState(newRecord.KDCE_ShippingState__c);

            // 생성될 때
            if (Trigger.isInsert) {

                // RecordType 이 빈 값이면 Prospect 로 설정함. kakao 챗으로 인입될 때 레코드 타입을 설정 할 수 없다고 함. 2021.05.20 권준석
                if (newRecord.RecordTypeId == null) newRecord.RecordTypeId = RT_Contact_ProspectId;

                // Contact이 Case에서나 Coupon에서 생성되는 경우가 아닌, 매뉴얼로 생성될때만 해당 필드 업데이트
                if (newRecord.KDCE_RegistrationDate__c == null) {
                    newRecord.KDCE_RegistrationDate__c = System.now();
                    newRecord.KDCE_RegistrationObject__c = 'Contact';
                }
                if (newRecord.KDCE_LASLAU__c == null) newRecord.KDCE_LASLAU__c = 'LAS'; // 초기 Default 값 : LAS
            }

            // 업데이트일때, 필드 동기화
            if (Trigger.isUpdate) {
                Contact oldRecord = (Contact) Trigger.oldMap.get(newRecord.Id);

                if (newRecord.KDCE_IsDormant__c || newRecord.KDCE_IsDropout__c) continue;

                // 휴면계정을 복구처리할때는 해당 과정 안탐
                if (oldRecord.KDCE_IsDormant__c <> newRecord.KDCE_IsDormant__c && newRecord.KDCE_IsDormant__c == false) continue;
                else {
                    if (newRecord.KDCE_IsRequestDropout__c <> oldRecord.KDCE_IsRequestDropout__c) {
                        newRecord.CCR_DatabaseOptin__c = !newRecord.KDCE_IsRequestDropout__c;
                    }
                    if (newRecord.CCR_DatabaseOptin__c <> oldRecord.CCR_DatabaseOptin__c) {
                        /** 탈퇴처리 validation - 추심 혹은 Case/OP/Order가 있을 경우 탈퇴 x **/
                        if (!newRecord.CCR_DatabaseOptin__c) {
                            if (isContactHasDeal.containsKey(newRecord.Id) && isContactHasDeal?.get(newRecord.Id) == TRUE) newRecord.addError(System.Label.KDCE_NotPossibleWhenInProgress);
                        }
                        newRecord.KDCE_IsRequestDropout__c = !newRecord.CCR_DatabaseOptin__c;
                        newRecord.KDCE_DropoutRequestDate__c = newRecord.KDCE_IsRequestDropout__c ? System.now() : null;
                    }
                }
            }
        }
    }

    /**
     * External Key 설정 (2021.03.02 이지현)
     */
    private void setExtId() {
        System.debug('@@@@@@ setExtId @@@@@@');

        String ExtId = null;
        String hexDigest = null;
        String name;
        String birthdate;
        String phone;
        String email;

        for (Contact newRecord : (List<Contact>) Trigger.new) {
            System.debug('=== newRecord : ' + newRecord);

            name = newRecord.KDCE_Name__c;
            birthdate = newRecord.Birthdate != null ? Util.strYYYYMMDD(newRecord.Birthdate) : '';
            phone = newRecord.Phone != null ? newRecord.Phone : '';
            email = newRecord.Email != null ? newRecord.Email : '';

            if (phone != null) {
                if (phone.contains('-')) phone = phone.remove('-');     // Phone ('-') 하이픈 제거
            }

            newRecord.KDCE_PNKey__c = phone;
            newRecord.KDCE_NamePNKey__c = name + '_' + phone;
            newRecord.KDCE_NamePNBDKey__c = name + '_' + phone + '_' + birthdate;
            newRecord.KDCE_NameEMKey__c = name + '_' + email;
            newRecord.KDCE_NamePNEMKey__c = name + '_' + phone + '_' + email;

            /**
             * External ID 생성
             * 생성되면서 KDCE_ExternalId__c가 없을때만 형성 OR KDCE_ExternalId__c 가 32자리가 아닌 경우
            */
            if (Trigger.isInsert && (newRecord.KDCE_ExternalId__c == null || newRecord.KDCE_ExternalId__c.length() != 32)) {
                ExtId = newRecord.KDCE_NamePNBDKey__c + email;
                System.debug('=== ExtId : ' + ExtId);
                hexDigest = KDCE_Util.getHashString(ExtId);

                newRecord.KDCE_ExternalId__c = hexDigest;
            }
        }
    }

    /**
     * 휴면계정 복구처리 (2021.02.16 이지현)
     * Contact 휴면계정이 활성화계정으로 변경되면,
     * 1. Dormant Contact -> Contact 정보 넘어옴
     * 2. Dormant Contact 레코드 삭제
     */
    private void restoreContact() {
        System.debug('@@@@@@ restoreContact @@@@@@');
        List<Contact> contactList = new List<Contact>();
        List<SObject> SObjectList = new List<SObject>();
        Set<Id> contactIds = new Set<Id>();
        Contact oldContact;
        for (Contact contact : (List<Contact>) Trigger.new) {
            oldContact = (Contact) Trigger.oldMap.get(contact.Id);
            if (oldContact.KDCE_IsDormant__c == true && contact.KDCE_IsDormant__c == false) {
                SObjectList.add(contact);
                contactIds.add(contact.Id);
            }
        }

        /*
        if (contactIds.size() == 1) {
            KDCE_ContactSeparateService.restoreObject('Contact', 'KDCE_DormantContact__c', contactIds, SObjectList);
        }
        */

        if (!contactIds.isEmpty()) {
            KDCE_ContactSeparateService.restoreObject('Contact', 'KDCE_DormantContact__c', contactIds, SObjectList);
        }
    }

    /*
     * 비활성 Contact을 활성 Contact으로 변경시, 관련된 Case 및 Order 값도 복구
     */
    private void restoreRelatedObject() {
        System.debug('@@@@@@ restoreCaseOrder @@@@@@');

        List<SObject> SObjectList = new List<SObject>();
        Set<Id> contactIdSet = new Set<Id>();   // 복구된 고객
        Contact oldContact;
        // 휴면계정인 Contact이 휴면처리가 풀렸을때, Contact 정보 저장 (즉, 활성변경된 Contact 정보 저장)
        for (Contact newRecord : (List<Contact>) Trigger.new) {
            oldContact = (Contact) Trigger.oldMap.get(newRecord.Id);
            if (oldContact.KDCE_IsDormant__c == true && newRecord.KDCE_IsDormant__c == false) {
                contactIdSet.add(newRecord.Id);
                SObjectList.add(newRecord);
            }
        }

        /*
        if (contactIdSet.size() == 1) {
            KDCE_ContactSeparateService.restoreObject('KDCE_Order__c', 'KDCE_DormantOrder__c', contactIdSet, SObjectList);
            KDCE_ContactSeparateService.restoreObject('KDCE_OrderLineItem__c', 'KDCE_DormantOrderLineItem__c', contactIdSet, SObjectList);
            KDCE_ContactSeparateService.restoreObject('KDCE_OfflineProgram__c', 'KDCE_DormantOfflineProgram__c', contactIdSet, SObjectList);
            KDCE_ContactSeparateService.restoreObject('Case', 'KDCE_DormantCase__c', contactIdSet, SObjectList);
        }
        */

        if (!contactIdSet.isEmpty()) {
            KDCE_ContactSeparateService.restoreObject('KDCE_Order__c', 'KDCE_DormantOrder__c', contactIdSet, SObjectList);
            KDCE_ContactSeparateService.restoreObject('KDCE_OrderLineItem__c', 'KDCE_DormantOrderLineItem__c', contactIdSet, SObjectList);
            KDCE_ContactSeparateService.restoreObject('KDCE_OfflineProgram__c', 'KDCE_DormantOfflineProgram__c', contactIdSet, SObjectList);
            //KDCE_ContactSeparateService.restoreObject('Case', 'KDCE_DormantCase__c', contactIdSet, SObjectList);
        }
    }

    /*
     * Contact이 복구되었을시, 관련 Dormant Contact 레코드 삭제
     */
    private void deleteDormantContact() {
        System.debug('@@@@@@ deleteDormantContact @@@@@@');
        Set<Id> contactIdSet = new Set<Id>();   // 휴면계정 전환된 고객
        Contact oldContact;

        // 휴면계정인 Contact이 휴면처리가 풀렸을때, Contact 정보 저장 (즉, 활성변경된 Contact 정보 저장)
        for (Contact newRecord : (List<Contact>) Trigger.new) {
            oldContact = (Contact) Trigger.oldMap.get(newRecord.Id);
            if (oldContact.KDCE_IsDormant__c == true && newRecord.KDCE_IsDormant__c == false) {
                contactIdSet.add(newRecord.Id);
            }
        }

        if(!contactIdSet.isEmpty()) {
            List<KDCE_DormantContact__c> deleteDormantList = new List<KDCE_DormantContact__c>();
            for (KDCE_DormantContact__c dormant : [SELECT Id FROM KDCE_DormantContact__c WHERE ContactId__c IN :contactIdSet]) {
                deleteDormantList.add(dormant);
            }

            if (!deleteDormantList.isEmpty()) {
                ignoreAuthorityInnerClass innerClass = new ignoreAuthorityInnerClass();
                innerClass.forceDelete(deleteDormantList);
            }
        }
    }

    /*
    * Contact 생성 시, Account 자동 생성
    **/
    private void createAccountRecord() {
        System.debug('@@@@@@ createAccountRecord @@@@@@');

        List<Account> accountList = new List<Account>();
        Account tempAccount;
        Map<String, String> accountIdMap = new Map<String, String>();
        for (Contact contact : (List<Contact>) Trigger.new) {
            String accName = contact.LastName == null ? 'Null LastName Account' : contact.LastName;
            accName += ' ';
            accName += contact.FirstName == null ? '' : contact.FirstName;
            tempAccount = new Account(
                    Name = accName,
                    KDCE_ExternalId__c = contact.KDCE_ExternalId__c,
                    CCR_ConsumerUID__c = contact.CCR_ConsumerUID__c
            );
            accountList.add(tempAccount);
        }

        insert accountList;

        for (Account acc : accountList) {
            accountIdMap.put(acc.KDCE_ExternalId__c, acc.Id);
        }

        System.debug(accountList);
        for (Contact contact : (List<Contact>) Trigger.new) {
            String accName = contact.LastName == null ? '' : contact.LastName;
            accName += ' ';
            accName += contact.FirstName == null ? '' : contact.FirstName;
            contact.AccountId = accountIdMap.get(contact.KDCE_ExternalId__c);
        }
    }

    /**
     * @description :   Contact Last Name 수정 시, Account 자동 수정
     * @date        :   2021-03-08
 *                      0504 수정
     *
     */
    private void updateAccountRecord() {
        System.debug('@@@@@@ updateAccountRecord @@@@@@');

        Contact oldContact;
        List<Contact> newList = new List<Contact>();
        for (Contact item : (List<Contact>) Trigger.new) {
            oldContact = (Contact) Trigger.oldMap.get(item.Id);
            if (item.LastName != oldContact.LastName) {
                newList.add(item);
            }
        }

        List<Account> accountList = new List<Account>();
        Account tempAccount;
        List<Id> accIds = new List<Id>();
        if (!newList.isEmpty()) {
            for (Contact c : newList) {
                accIds.add(c.AccountId);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account>();
        if (!accIds.isEmpty()) {
            accountMap = new Map<Id, Account>([
                    SELECT Id, Name, Phone, KDCE_ExternalId__c, CCR_ConsumerUID__c
                    FROM Account
                    WHERE Id IN :accIds
            ]);
        }

        if (!newList.isEmpty()) {
            for (Contact contact : newList) {
                if (accountMap.containsKey(contact.AccountId)) {
                    tempAccount = accountMap.get(contact.AccountId);
                    tempAccount.Name = contact.LastName;
                    accountList.add(tempAccount);
                }
            }
        }
        if (!accountList.isEmpty()) update accountList;

    }

    /**
     * @description Contact subType이 LAS -> LAU로 변경되는 순간 Contact 필드 업데이트
     * @author JE Yoon
     * */
    private void updateIsMGMIssueUponUpdate() {
        System.debug('@@@@@@ updateIsMGMIssueUponUpdate @@@@@@');

        String recordTypeId_Contact = rtNameMap_Contact.get('Contact_Member');
        for (Contact contact : (List<Contact>) Trigger.new) {

            Contact oldContact = (Contact) Trigger.oldMap.get(contact.Id);
            if (oldContact != null && oldContact.KDCE_IsDormant__c == true && oldContact.KDCE_IsDormant__c == false) continue;  // 복구인경우 안타게

            if (oldContact.KDCE_LASLAU__c == 'LAS' && contact.KDCE_LASLAU__c == 'LAU') {
                contact.KDCE_LAUChangeDate__c = System.now();
            }

            // Member에 대해서만 처리
            if(contact.RecordTypeId == recordTypeId_Contact){

                // Member인 상태에서 LAS -> LAU 가 된 경우
                if(oldContact.KDCE_LASLAU__c == 'LAS' && contact.KDCE_LASLAU__c == 'LAU'){
                    contact.KDCE_IsMGMIssue__c = true;
                }

                // Prospect -> Member가 되었을 때 LAU인 경우
                if(oldContact.RecordTypeId != contact.RecordTypeId && contact.KDCE_LASLAU__c == 'LAU'){
                    contact.KDCE_IsMGMIssue__c = true;
                }

            }

            /*
            if (oldContact.KDCE_LASLAU__c == 'LAS' && contact.KDCE_LASLAU__c == 'LAU') {
                contact.KDCE_LAUChangeDate__c = System.now();

                if (contact.RecordTypeId == recordTypeId_Contact) {
                    contact.KDCE_IsMGMIssue__c = true;
                }
            }
            */

            System.debug('=== contact : ' + contact);
        }
    }

    /**
     * @description KDCE_IsMGMIssue__c가 false -> true일 때 KDCE_CouponService.issueCoupon 메소드 호출해서
     *              1. Coupon_MGM 타입의 쿠폰을 추출해 Contact에 쿠폰 발급
     *              2. 해당 쿠폰의 Contact__c 및 Status = Issue로 업데이트
      *             3. Contact의 KDCE_MGMCode__c를 쿠폰 번호로 업데이트
     * @author JE Yoon
     * */
    private void issueMGMCoupon() {
        System.debug('@@@@@@ issueMGMCoupon @@@@@@');

        Map<Id, Contact> oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
        List<Contact> contacts = new List<Contact>();
        Contact oldContact;

        for (Contact contact : (List<Contact>) Trigger.new) {
            oldContact = oldContactMap.get(contact.Id);
            if (oldContact.KDCE_IsDormant__c == true && contact.KDCE_IsDormant__c == false) continue;   // 휴면계정을 복구처리할때는 해당 과정 안탐
            else if (oldContact.KDCE_IsMGMIssue__c == false && contact.KDCE_IsMGMIssue__c == true) contacts.add(contact);
        }
        System.debug('=== contacts : ' + contacts);
        if (contacts.size() > 0) KDCE_CouponService.issueCoupon(contacts, 'Coupon_MGM');
    }

    /**
     * 개인정보필드 Masking 처리 (2021.03.08 이지현)
     */
    private void setMaskingField() {
        System.debug('@@@@@@ setMaskingField @@@@@@');

        String emailName;
        String emailDomain;
        String emailDomainStart;
        String emailDomainEnd;
        String middlePhoneNum;

        for (Contact con : (List<Contact>) Trigger.new) {

//            if (con.LastName == null) con.LastName = 'Temp Name';
            if (con.KDCE_IsDormant__c || con.KDCE_IsDropout__c) continue;
            // Store Dummy Contact일 경우, 마스킹 처리 제외
            if (!con.KDCE_IsStoreContact__c) {
                Integer textLength;
                String maskingField = '*';

                Contact oldCon = (Contact) Trigger.oldMap?.get(con.Id);
                if (oldCon != null && oldCon.KDCE_IsDormant__c == true && con.KDCE_IsDormant__c == false) continue;  // 복구인경우 안타게

                // 이름 마스킹 처리
                if ((con.LastName != null && oldCon == null) || (oldCon?.LastName != con.LastName)) {
                    // KDEC_Name__c에 LastName Full 정보 저장
                    con.KDCE_Name__c = con.LastName;

                    if (con.LastName == null) continue;
                    // LastName 마스킹처리
                    textLength = con.LastName.length();
                    for (Integer i = 0; i < textLength - 3; i++) {
                        maskingField = maskingField + '*';
                    }
                    if (textLength == 2) {
                        con.LastName = con.LastName.left(1) + maskingField;
                    } else {
                        con.LastName = con.LastName.left(1) + maskingField + con.LastName.right(1);
                    }
                }

                // Birthdate 마스킹 처리
                // 1. Mask Birthday 필드가 업데이트 된 경우
                if (((con.KDCE_BirthdateMask__c != null && oldCon == null) || (oldCon?.KDCE_BirthdateMask__c != con.KDCE_BirthdateMask__c)) && con.KDCE_BirthdateMask__c != null) {
                    if (con.KDCE_BirthdateMask__c.contains('-')) con.KDCE_BirthdateMask__c = con.KDCE_BirthdateMask__c.remove('-');
                    try {
                        con.Birthdate = Util.yymmddToDate(con.KDCE_BirthdateMask__c);
                        con.KDCE_BirthdateMask__c = con.Birthdate.year() + '-**-**';
                    } catch (Exception e) {
                        con.addError(System.Label.KDCE_BirthdayInputFormat);
                    }
                }
                // 2. 기본 Birthday 필드가 업데이트 된 경우
                else if (((con.Birthdate != null && oldCon == null) || (oldCon?.Birthdate != con.Birthdate)) && con.Birthdate != null) {
                    try {
                        con.KDCE_BirthdateMask__c = con.Birthdate.year() + '-**-**';
                    } catch (Exception e) {
                        con.addError(System.Label.KDCE_BirthdayInputFormat);
                    }
                }
                System.debug('=== con.KDCE_PhoneMask__c : ' + con.KDCE_PhoneMask__c);
                System.debug('=== con.Phone : ' + con.Phone);

                // Phone 마스킹 처리 (2021-07-06 지현 추가)
                if ((con.KDCE_PhoneMask__c != null && oldCon == null) || (oldCon?.KDCE_PhoneMask__c != con.KDCE_PhoneMask__c && con.KDCE_PhoneMask__c != null)) {
                    System.debug('=== con.KDCE_PhoneMask__c : ' + con.KDCE_PhoneMask__c);
                    System.debug('=== con.Phone : ' + con.Phone);

                    if (con.KDCE_PhoneMask__c.length() < 7) continue;   // TODO 이상한 Phone 번호를 위한 임시처리
                    maskingField = '*';
                    con.Phone = con.KDCE_PhoneMask__c.contains('-') ? con.KDCE_PhoneMask__c.remove('-') : con.KDCE_PhoneMask__c;
                    if (con.Phone != null && con.Phone.contains('*')) con.addError('올바른 번호 형식이 아닙니다.');
                    middlePhoneNum = con.Phone.substring(3, con.Phone.length() - 4); // 010으로 시작하고 마지막엔 4글자라는 가정
                    for (Integer i = 0; i < middlePhoneNum.length() - 1; i++) {
                        maskingField += '*';
                    }
                    con.KDCE_PhoneMask__c = con.Phone.substring(0, 3) + '-' + maskingField + '-' + con.Phone.substring(con.Phone.length() - 4, con.Phone.length());
                    System.debug('=== con.KDCE_PhoneMask__c : ' + con.KDCE_PhoneMask__c);
                    System.debug('=== con.Phone : ' + con.Phone);

                }
                // 다른 경우로 들어오는 경우 Case Supplied를 통해 기본값으로 넣어주기때문에 해당 처리
                else if ((con.Phone != null && oldCon == null) || (oldCon?.Phone != con.Phone && con.Phone != null)) {
                    System.debug('=== con.KDCE_PhoneMask__c : ' + con.KDCE_PhoneMask__c);
                    System.debug('=== con.Phone : ' + con.Phone);

                    if (con.Phone.length() < 7) continue;       // TODO 이상한 Phone 번호를 위한 임시처리
                    maskingField = '*';
                    con.Phone = con.Phone.contains('-') ? con.Phone.remove('-') : con.Phone;
                    if (con.Phone != null && con.Phone.contains('*')) con.addError('올바른 번호 형식이 아닙니다.');
                    middlePhoneNum = con.Phone.substring(3, con.Phone.length() - 4); // 010으로 시작하고 마지막엔 4글자라는 가정
                    for (Integer i = 0; i < middlePhoneNum.length() - 1; i++) {
                        maskingField += '*';
                    }
                    con.KDCE_PhoneMask__c = con.Phone.substring(0, 3) + '-' + maskingField + '-' + con.Phone.substring(con.Phone.length() - 4, con.Phone.length());
                    System.debug('=== con.KDCE_PhoneMask__c : ' + con.KDCE_PhoneMask__c);
                    System.debug('=== con.Phone : ' + con.Phone);

                }

                // Phone 필드 null 처리 동기화 (2021.07.28 이지현)
                if (Trigger.isUpdate) {
                    if (oldCon.KDCE_PhoneMask__c <> con.KDCE_PhoneMask__c && con.KDCE_PhoneMask__c == null) con.Phone = con.KDCE_PhoneMask__c;
                    if (oldCon.Phone <> con.Phone && con.Phone == null) con.KDCE_PhoneMask__c = con.Phone;
                }

                // Email 마스킹 처리 (test@gmail.co.kr -> t***@g****.co.kr)
                // 1. Email Mask가 업데이트 된 경우
                if (((con.KDCE_EmailMask__c != null && oldCon == null) || (oldCon?.KDCE_EmailMask__c != con.KDCE_EmailMask__c)) && con.KDCE_EmailMask__c != null) {
                    System.debug('=== 여기 : ');
                    if (!con.KDCE_EmailMask__c.contains('@')) continue;
                    con.Email = con.KDCE_EmailMask__c;
                    emailName = con.KDCE_EmailMask__c.split('@')[0];
                    emailDomain = con.KDCE_EmailMask__c.split('@')[1];
                    emailDomainStart = emailDomain.split('\\.')[0];
                    emailDomainEnd = emailDomain.remove(emailDomainStart);

                    // email 앞글자가 3글자 이상이면
                    if (con.KDCE_EmailMask__c.split('@')[0].length() > 3) {
                        con.KDCE_EmailMask__c = emailName.substring(0, 3).rightPad(emailName.length(), maskingField) + '@' +
                                emailDomainStart.substring(0, 1).rightPad(emailDomainStart.length(), maskingField) + emailDomainEnd;
                    } else {
                        con.KDCE_EmailMask__c = emailName.substring(0, 1).rightPad(emailName.length(), maskingField) + '@' +
                                emailDomainStart.substring(0, 1).rightPad(emailDomainStart.length(), maskingField) + emailDomainEnd;
                    }
                }

                // Email 마스킹 처리 (Web to Case와 같은 SC에서 들어오는 Contact이 아닐 경우) - 2021.07.05 로직 추가
                // 2. Email이 업데이트 된 경우
                else if (((con.Email != null && oldCon == null) || (oldCon?.Email != con.Email)) && con.Email != null) {
                    System.debug('=== 여기22 : ');
                    emailName = con.Email.split('@')[0];
                    emailDomain = con.Email.split('@')[1];
                    emailDomainStart = emailDomain.split('\\.')[0];
                    emailDomainEnd = emailDomain.remove(emailDomainStart);

                    // email 앞글자가 3글자 이상이면
                    if (con.Email.split('@')[0].length() > 3) {
                        con.KDCE_EmailMask__c = emailName.substring(0, 3).rightPad(emailName.length(), maskingField) + '@' +
                                emailDomainStart.substring(0, 1).rightPad(emailDomainStart.length(), maskingField) + emailDomainEnd;
                    } else {
                        con.KDCE_EmailMask__c = emailName.substring(0, 1).rightPad(emailName.length(), maskingField) + '@' +
                                emailDomainStart.substring(0, 1).rightPad(emailDomainStart.length(), maskingField) + emailDomainEnd;
                    }
                }
            }
        }
    }

    /**
     * Contact 생성 or 업데이트 시, 필드 업데이트
     */
    private void contactFieldUpdate() {
        System.debug('@@@@@@ contactFieldUpdate @@@@@@');

        for (Contact con : (List<Contact>) Trigger.new) {
            if (Trigger.isInsert) {
                // 데이터 생성될떄 무조건 값 들어감
                con.KDCE_MarketingOptInDate__c = System.now();
                con.KDCE_InformationOptInDate__c = System.now();
                if (con.KDCE_JoinedPMKChannel__c == true) con.KDCE_LastKakaoSyncDate__c = System.now();

                // 본인인증일이 있을시, 재인증 대상이 아니면 -> Age Verification Status 업데이트
                if (con.CCR_AVStatusDateChange__c != null && con.KDCE_fm_IsAgeReVerification__c == false) con.CCR_AgeVerificationStatus__c = 'Verified';
                if (con.CCR_SmokerNew__c == 'Yes') con.CCR_SmokerDeclarationDate__c = System.now();
            }

            else if (Trigger.isUpdate) {
                Contact oldCon = (Contact) Trigger.oldMap.get(con.Id);

                // 휴면계정을 복구처리할때는 해당 과정 안탐
                if (oldCon.KDCE_IsDormant__c == true && con.KDCE_IsDormant__c == false) continue; else {
                    if (oldCon.KDCE_MarketingOptIn__c <> con.KDCE_MarketingOptIn__c) {
                        con.KDCE_MarketingOptInDate__c = System.now();
                    }
                    // 회원으로 전환되었을 때 체크
                    if (oldCon.KDCE_ConvertedConsumer__c <> con.KDCE_ConvertedConsumer__c) {
                        con.KDCE_MarketingOptInDate__c = System.now();
                        con.KDCE_InformationOptInDate__c = System.now();
                    }
                    if (oldCon.KDCE_InformationOptIn__c <> con.KDCE_InformationOptIn__c) {
                        con.KDCE_InformationOptInDate__c = System.now();
                    }
                    if (oldCon.KDCE_JoinedPMKChannel__c <> con.KDCE_JoinedPMKChannel__c && con.KDCE_JoinedPMKChannel__c == true) {
                        con.KDCE_LastKakaoSyncDate__c = System.now();
                    }

                    // 본인인증일 업데이트시, 재인증 대상이 아니면 -> Age Verification Status를 Verified로 업데이트
                    //if (oldCon.CCR_AVStatusDateChange__c <> con.CCR_AVStatusDateChange__c && con.KDCE_fm_IsAgeReVerification__c == false) con.CCR_AgeVerificationStatus__c = 'Verified';

                    if (oldCon.CCR_SmokerNew__c <> con.CCR_SmokerNew__c && con.CCR_SmokerNew__c == 'Yes') {
                        con.CCR_SmokerDeclarationDate__c = System.now();
                    }
                }
            }
        }
    }

    /**
     * Member가 카카오로 가입 시 카카오 챗을 가능하도록 처리. 2021.07.11 권준석
     */
    private void setKakaoMapping() {

        Set<String> kakaoIds = new Set<String>();

        for (Contact con : (List<Contact>) Trigger.new) {

            if (Trigger.isInsert) {
                // 인서트 시에는 값이 들어오는 경우에만 처리
                if (con.KDCE_KakaoId__c != null) {
                    kakaoIds.add(con.KDCE_KakaoId__c);
                }
            } else if (Trigger.isUpdate) {
                Contact oldRecord = (Contact)Trigger.oldMap.get(con.Id);
                // 업데이트 시는 빈 값에서 값이 들어오는 경우에만 처리
                if(oldRecord.KDCE_KakaoId__c == null && con.KDCE_KakaoId__c != null){
                    kakaoIds.add(con.KDCE_KakaoId__c);
                }
            }
        }

        // 해당 Kakao Id 를 가진 다른 레코드가 있는지 확인 후 삭제
        List<Kakao_User_Mapping__c> kumList = [SELECT Id FROM Kakao_User_Mapping__c WHERE App_User_Id__c IN :kakaoIds];
        if(kumList.size() > 0) Database.delete(kumList, false);
        //if(kumList.size() > 0) delete kumList;

        List<Kakao_User_Mapping__c> mappingList = new List<Kakao_User_Mapping__c>();

        for (Contact con : (List<Contact>) Trigger.new) {

            if (Trigger.isInsert) {
                // 인서트 시에는 값이 들어오는 경우에만 처리
                if (con.KDCE_KakaoId__c != null) {
                    Kakao_User_Mapping__c mapping = new Kakao_User_Mapping__c();
                    mapping.Contact__c = con.Id;
                    mapping.App_User_Id__c = con.KDCE_KakaoId__c;
                    mapping.User_Key__c = con.KDCE_ExternalId__c;
                    mappingList.add(mapping);
                }
            } else if (Trigger.isUpdate) {

                Contact oldRecord = (Contact) Trigger.oldMap.get(con.Id);
                // 업데이트 시는 빈 값에서 값이 들어오는 경우에만 처리
                if (oldRecord.KDCE_KakaoId__c == null && con.KDCE_KakaoId__c != null) {
                    Kakao_User_Mapping__c mapping = new Kakao_User_Mapping__c();
                    mapping.Contact__c = con.Id;
                    mapping.App_User_Id__c = con.KDCE_KakaoId__c;
                    mapping.User_Key__c = con.KDCE_ExternalId__c;
                    mappingList.add(mapping);
                }
            }
        }

        if(mappingList.size() > 0) Database.insert(mappingList, false);
    }

    /**
     * 2021.07.19 박현은
     * Prospect가 Member로 바뀐 경우, Asset.CarePlusStatus 재계산
     */
    @SuppressWarnings('PMD')
    private void recalculateAssetCarePlusStatus() {
        final String notEnrolled = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_NOTENROLLED;
        final String enrolled = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_ENROLLED;
        final String expired = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_EXPIRED;
        Set<Id> contIds = new Set<Id>();
        Contact oldContact;
        for (Contact contact : (List<Contact>) Trigger.new) {
            oldContact = (Contact) Trigger.oldMap.get(contact.Id);
            if (contact.CCR_CarePlusStatus__c == enrolled && oldContact.CCR_CarePlusStatus__c == notEnrolled) {
                contIds.add(contact.Id);
            }
        }
        System.debug('=== contIds : ' + contIds);

        if (!contIds.isEmpty()) {

            List<Asset> assetList = [
                    SELECT
                            Id, ContactId, CCR_CarePlusStatus__c, CCR_CarePlusDueDate__c, KDCE_fm_WarrantyDate__c
                    FROM Asset
                    WHERE ContactId IN :contIds
            ];
            System.debug('=== assetList : ' + assetList.size());

            // Contact 별 소유 중인 Asset List
            Map<Id, List<Asset>> contactAssetMap = new Map<Id, List<Asset>>();
            for (Asset asset : assetList) {

                List<Asset> tempList = new List<Asset>();
                if(contactAssetMap.containsKey(asset.ContactId)) tempList = contactAssetMap.get(asset.ContactId);
                tempList.add(asset);
                contactAssetMap.put(asset.ContactId, tempList);
            }


            List<Asset> updateAssetList = new List<Asset>();
            for(Id contactId : contactAssetMap.keySet()){

                Datetime contactDT = null;

                for (Asset asset : contactAssetMap.get(contactId)) {

                    // Not Enrolled 기기 처리
                    if(asset.CCR_CarePlusStatus__c == notEnrolled) {
                        if (asset.CCR_CarePlusDueDate__c == null) asset.CCR_CarePlusDueDate__c = asset.KDCE_fm_WarrantyDate__c;

                        if (asset.CCR_CarePlusDueDate__c < System.today()) asset.CCR_CarePlusStatus__c = expired;
                        else asset.CCR_CarePlusStatus__c = enrolled;
                        updateAssetList.add(asset);
                    }

                    // Contact Care+ Date 처리
                    if(contactDT == null) contactDT = asset.CCR_CarePlusDueDate__c;
                    else if(asset.CCR_CarePlusDueDate__c == null) {}
                    else if(contactDT < asset.CCR_CarePlusDueDate__c) contactDT = asset.CCR_CarePlusDueDate__c;
                }
                Contact row = (Contact)Trigger.newMap.get(contactId);
                row.CCR_CarePlusDueDate__c = contactDT;
            }

            if (!updateAssetList.isEmpty()){

                // 트리거 재호출 이슈 때문에 Bypass 처리함
                TriggerHandler.bypass('KDCE_Asset_tr');
                update updateAssetList;
                TriggerHandler.clearBypass('KDCE_Asset_tr');
            }



            /*
            List<Asset> assetList = [
                    SELECT
                            Id, ContactId, CCR_CarePlusStatus__c, CCR_CarePlusDueDate__c, KDCE_fm_WarrantyDate__c
                    FROM Asset
                    WHERE ContactId IN :contIds AND CCR_CarePlusStatus__c = :notEnrolled
            ];
            System.debug('=== assetList : ' + assetList);

            for (Asset asset : assetList) {
                if (asset.CCR_CarePlusDueDate__c == null)
                    asset.CCR_CarePlusDueDate__c = asset.KDCE_fm_WarrantyDate__c;

                if (asset.CCR_CarePlusDueDate__c < System.today()) asset.CCR_CarePlusStatus__c = expired; else asset.CCR_CarePlusStatus__c = enrolled;
            }

            if (!assetList.isEmpty()){

                // 트리거 재호출 이슈 때문에 Bypass 처리함
                TriggerHandler.bypass('KDCE_Asset_tr');
                update assetList;
                TriggerHandler.clearBypass('KDCE_Asset_tr');
            }
            */
        }
    }
}