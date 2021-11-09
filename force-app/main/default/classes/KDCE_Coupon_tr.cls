/****************************************************************************************
  * @filename      : KDCE_Coupon_tr
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-03
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-03          i2max_JE Yoon             Create
    0.2  2021-03-30          i2max_JE Yoon             Update
    0.2  2021-04-26          i2max_He Park             Update
****************************************************************************************/

public without sharing class KDCE_Coupon_tr extends TriggerHandler {

    public static Boolean isAlreadyExecuted = false;    // 재귀호출 방지 flag

    // 쿠폰 RecordType 별 DeveloperName, Id의 Map
    private static Map<String, Id> rtMap_Coupon = KDCE_Util.getRecordTypeBySObject('KDCE_Coupon__c');
    // Task RecordType 별 DeveloperName, Id의 Map
    private static Map<String, String> pvMap_Coupon_Status = KDCE_Util.getPicklistValue('KDCE_Coupon__c', 'Status__c');

    private static Map<String, String> pvMap_Coupon_channel = KDCE_Util.getPicklistValue('KDCE_Coupon__c', 'ChannelDetails__c');


    // 쿠폰의 RecordType 별 Default Amount 정의   // TODO Coupon 별 Default Amount 필요한지 확인
    private static Map<String, Decimal> couponPriceMap = new Map <String, Decimal>{
            rtMap_Coupon.get('Coupon_CVS') => 31000,
            rtMap_Coupon.get('Coupon_GetInfo') => 10000,
            rtMap_Coupon.get('Coupon_MGM') => 25000
    };


    public override void beforeInsert() {
        this.setDefault(); //Default 값 설정
    }
    public override void beforeUpdate() {
        this.sendNoti();
    }
    public override void afterInsert() {
        this.createCouponHistory();         // Coupon 생성/발급 시 CouponHistory 데이터 생성
    }
    public override void afterUpdate() {
        if (isAlreadyExecuted == false) {
            this.createCouponHistory();         // Coupon 생성/발급 시 CouponHistory 데이터 생성
            this.countCVSCouponIssue();         // 컨택에게 CVS 쿠폰 발급 시 Contact.KDCE_DCIssueCount__c += 1 & Contact.KDCE_DCIssueCumulative__c = [Contact의 CVS 쿠폰 발급 히스토리 수] 업데이트
            this.updateContactWhenReturn();     // Coupon 취소시, Roll Back
            updateContactWhenUse();             // Coupon 사용시, Contact 업데이트
//            updateMGMCountInContact();          // MGM Coupon Count 업데이트시, Contact 업데이트
            isAlreadyExecuted = true;
        }
    }


    /**
     * @description Coupon Insert 될 때 기본 값
     * @author JE Yoon
     */
    private void setDefault() {
        System.debug('@@@@@@ setDefault @@@@@@');

        for (KDCE_Coupon__c coupon : (List<KDCE_Coupon__c>) Trigger.new) {

            coupon.Name = coupon.CouponCode__c;

            if (coupon.Type__c == null) coupon.addError('Type__c 필드는 필수 입력 입니다.');
            else if (coupon.Type__c == 'CVS'){

                if (coupon.ExpiryDate__c == null) coupon.addError('CVS 쿠폰은 ExpiryDate__c 필드가 필수 입력 입니다.');
                if (coupon.IssuableDate__c == null) coupon.addError('CVS 쿠폰은 IssuableDate__c 필드가 필수 입력 입니다.');
                if (coupon.ChannelDetails__c == null) coupon.addError('CVS 쿠폰은 ChannelDetails__c 필드가 필수 입력 입니다.');
            }

            // Coupon Data Load 업로드일때를 대비한 Record Type Id 처리
            if (coupon.Type__c != null) {
                coupon.RecordTypeId = rtMap_Coupon.get('Coupon_' + coupon.Type__c);
                coupon.Amount__c = couponPriceMap?.get(coupon.RecordTypeId);
                if(coupon.Type__c != 'MGM' && coupon.Type__c != 'CVS') coupon.ExternalType__c = coupon.Type__c;
            }
        }
    }

    /**
     * @description Coupon 생성/발급 시 CouponHistory 데이터 생성
     * @author JE Yoon
     * */
    private void createCouponHistory() {
        System.debug('@@@@@@ createCouponHistory @@@@@@');

        List<KDCE_CouponHistory__c> histories = new List<KDCE_CouponHistory__c>();
        Map<Id, KDCE_Coupon__c> couponMap = new Map<Id, KDCE_Coupon__c>();
        String issueStatus = pvMap_Coupon_Status.get(KDCE_GlobalValue.COUPON_STATUS_ISSUE);
        String produceStatus = pvMap_Coupon_Status.get(KDCE_GlobalValue.COUPON_STATUS_PRODUCE);
        KDCE_Coupon__c oldCoupon;

        for (KDCE_Coupon__c coupon : (List<KDCE_Coupon__c>) Trigger.new) {
            if (Trigger.isInsert) couponMap.put(coupon.Id, coupon);
            if (Trigger.isUpdate) {
                oldCoupon = (KDCE_Coupon__c) Trigger.oldMap.get(coupon.Id);
                if (oldCoupon?.Status__c == produceStatus && coupon.Status__c == issueStatus) {
                    couponMap.put(coupon.Id, coupon);
                }
            }
        }

        if (couponMap.size() > 0) {
            histories = KDCE_CouponService.createCouponHistories(couponMap);
        }
        if (!histories.isEmpty()) Database.SaveResult[] sr_history = Database.insert(histories);
    }

    /**
     * @description Contact에게 CVS 쿠폰 발급 시
     *              해당 Contact.KDCE_DCIssueCount__c += 1 업데이트 및
     *              Contact.KDCE_DCIssueCumulative__c = [해당 Contact의 CVS 쿠폰 발급 히스토리 수] 업데이트
     * @author JE Yoon (2021. 03. 30)
     * */
    private void countCVSCouponIssue() {
        System.debug('@@@@@@ countCVSCouponIssue @@@@@@');

        Set<Id> contactIds = new Set<Id>();
        Map<Id, Integer> contactHistoryCountMap = new Map<Id, Integer>(); // contact에 발급된 CVS 쿠폰 히스토리 수를 담을 맵
        Map<Id, Decimal> contactIssueCountMap = new Map<Id, Decimal>(); // contact에 발급된 CVS 쿠폰 수를 담을 맵
        List<Contact> contacts = new List<Contact>();
        Contact contact;
        KDCE_Coupon__c oldCoupon;
        String recordTypeId_Coupon_CVS = rtMap_Coupon.get('Coupon_CVS');
        String couponStatus_Issue = pvMap_Coupon_Status.get(KDCE_GlobalValue.COUPON_STATUS_ISSUE);
        String couponStatus_Produce = pvMap_Coupon_Status.get(KDCE_GlobalValue.COUPON_STATUS_PRODUCE);
        Integer recordCount;

        for (KDCE_Coupon__c coupon : (List<KDCE_Coupon__c>) Trigger.new) {
            oldCoupon = (KDCE_Coupon__c) Trigger.oldMap.get(coupon.Id);
            if (coupon.RecordTypeId == recordTypeId_Coupon_CVS && oldCoupon.Status__c == couponStatus_Produce && coupon.Status__c == couponStatus_Issue && coupon.Contact__c != null) contactIds.add(coupon.Contact__c);
        }

        if (!contactIds.isEmpty()) {
            for (KDCE_CouponHistory__c history : [
                    SELECT Contact__r.KDCE_DCIssueCount__c
                    FROM KDCE_CouponHistory__c
                    WHERE Contact__c IN :contactIds
                    AND Coupon__r.RecordTypeId = :recordTypeId_Coupon_CVS
                    AND ActionType__c = :KDCE_GlobalValue.COUPON_STATUS_ISSUE
            ]) {
                if (contactHistoryCountMap.get(history.Contact__c) == null) contactHistoryCountMap.put(history.Contact__c, 0);
                recordCount = contactHistoryCountMap.get(history.Contact__c);
                contactHistoryCountMap.put(history.Contact__c, recordCount + 1);
                // NULL 포인트 익셉션 발생해서 추가함. 2021.05.04 권준석
                Decimal issueCount = Util.nvlDec(history.Contact__r.KDCE_DCIssueCount__c);
                if (contactIssueCountMap.get(history.Contact__c) == null) contactIssueCountMap.put(history.Contact__c, issueCount + 1);
            }

            for (Id contactId : contactHistoryCountMap.keySet()) {
                contact = new Contact(Id = contactId, KDCE_DCIssueCount__c = contactIssueCountMap.get(contactId), KDCE_DCIssueCumulative__c = contactHistoryCountMap.get(contactId));
                contacts.add(contact);
            }

            if (!contacts.isEmpty()) update contacts;

        }
    }

    private void sendNoti() {
        System.debug('@@@@@@ sendNoti @@@@@@');

        List<KDCE_Coupon__c> newList;
        newList = new List<KDCE_Coupon__c>();
        for (KDCE_Coupon__c item : (List<KDCE_Coupon__c>) Trigger.new) {
            KDCE_Coupon__c oldItem = (KDCE_Coupon__c) Trigger.oldMap.get(item.Id);

            // MIG 임시처리
//            if(oldItem.Contact__c != null && oldItem.Contact__c != item.Contact__c){
//                item.addError('Contact of already issued coupon cannot be changed.');
//            }

            if (item.Status__c == pvMap_Coupon_Status.get(KDCE_GlobalValue.COUPON_STATUS_ISSUE) && oldItem.Status__c == pvMap_Coupon_Status.get(KDCE_GlobalValue.COUPON_STATUS_PRODUCE)) {// || item.Contact__c == '0031m00000Cg6LuAAJ')){ // 변경될때만으로 수정하기 old가 produce -> issue

//                if(item.Status__c == pvMap_Coupon_Status.get(KDCE_GlobalValue.COUPON_STATUS_ISSUE)){// || item.Contact__c == '0031m00000Cg6LuAAJ')){
                newList.add(item);
            }
        }
        if (!newList.isEmpty() ) this.sendCouponSMSNoti(newList);
    }

    private void sendCouponSMSNoti(List<KDCE_Coupon__c> newList) {
        System.debug('@@@@@@ sendCouponSMSNoti @@@@@@');

        /*List<i2SEMA_Util.Receiver> receivers = new List<i2SEMA_Util.Receiver>();
        List<String> labels = new List<String>{'공덕 아이코스점','서울 마포구 마포대로 137','09:00~18:00'};
        i2SEMA_Util.Receiver receiver = new i2SEMA_Util.Receiver();
        receiver.receiverExtId = '955422917652724fc7de308965f00c5f';
        receiver.labels = labels;
        receivers.add(receiver);

        i2SEMA_Util.I2Notification msg = new i2SEMA_Util.I2Notification();
        msg.templateExtId = 'SC_SMS_0003';
        msg.receiverType = 'Contact';
        msg.receivers = receivers;

        i2SEMA_Util.sendNotification(msg);*/

        Set<Id> conIds = new Set<Id>();
        for (KDCE_Coupon__c coupon : newList) {
            conIds.add(coupon.Contact__c);
        }
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Phone, KDCE_Name__c, KDCE_ExternalId__c, KDCE_MarketingOptInDate__c FROM Contact WHERE Id IN :conIds]);

        List<i2SEMA_Util.Receiver> cvsReceivers = new List<i2SEMA_Util.Receiver>();
        List<i2SEMA_Util.Receiver> getInfoReceivers = new List<i2SEMA_Util.Receiver>();
        List<String> labels;
        List<String> btnURLs;
        i2SEMA_Util.Receiver receiver;
        i2SEMA_Util.I2Notification msg;

        for (KDCE_Coupon__c coupon : newList) {
            if (coupon.Contact__c == null) continue;
            labels = new List<String>();
            receiver = new i2SEMA_Util.Receiver();

            if (coupon.Type__c == KDCE_GlobalValue.COUPON_TYPE_CVS) {

                labels.add(contactMap.get(coupon.Contact__c).KDCE_Name__c);
                labels.add(pvMap_Coupon_channel?.get(coupon ?.ChannelDetails__c));
                labels.add('31,000'); // coupon.amount
                labels.add(coupon?.ExpiryDate__c?.format());

                String btnURL = 'kr.iqos.com/easyiqos?code=' + coupon?.CouponCode__c;
                btnURLs = new List<String>();
                btnURLs.add(btnURL);

                receiver.receiverExtId = contactMap.get(coupon.Contact__c).KDCE_ExternalId__c; // consumer Id
                receiver.labels = labels;
                receiver.btnURLs = btnURLs;
                cvsReceivers.add(receiver);

            } else if (coupon.Type__c == KDCE_GlobalValue.COUPON_TYPE_GETINFO) {
//                labels.add(coupon.CouponCode__c);
//                labels.add(String.valueOf(coupon.ExpiryDate__c));
                labels.add(String.valueOf(contactMap.get(coupon.Contact__c).KDCE_MarketingOptInDate__c));

                receiver.receiverExtId = contactMap.get(coupon.Contact__c).KDCE_ExternalId__c;
                receiver.labels = labels;
                getInfoReceivers.add(receiver);
            }
        }

        // cvs 전송 //KDCE_NotificationTemplate_Coupon_CSV
        if (!cvsReceivers.isEmpty()) {
            msg = new i2SEMA_Util.I2Notification();
//            msg.templateExtId = System.Label.KDCE_NotificationTemplate_Coupon_CVS; //'NT-210504-00013';
            msg.templateExtId = System.Label.KDCE_KakaoTemplate_Coupon_CVS; //'NT-210504-00013';
            msg.receiverType = 'Contact';
            msg.receivers = cvsReceivers;
            if( !Test.isRunningTest() ) i2SEMA_Util.sendNotification(msg);
        }


        // getInfo 전송 
        if (!getInfoReceivers.isEmpty()) {
            msg = new i2SEMA_Util.I2Notification();
            msg.templateExtId = System.Label.KDCE_NotificationTemplate_Coupon_GetInfo; //'NT-210504-00070';
            msg.receiverType = 'Contact';
            msg.receivers = getInfoReceivers;
            if( !Test.isRunningTest() ) i2SEMA_Util.sendNotification(msg);
        }

        //Coupon Master Sending 여부 Y 업데이트
        for (KDCE_Coupon__c coupon : newList) {
            coupon.IsSend__c = true;
        }

    }

    /*
     * 쿠폰이 캔슬이 될 경우, Contact 필드 업데이트 - 2021.04.26 이지현
     *  - Contact에 있던 First Purchase Date/Last Purchase Date에 해당하는 주문이 사라질 경우, 그 이전 주문의 Purchase Date 넣어줌
     *  - MGM 쿠폰 캔슬일 경우, Contact MGM Count 필드 -1 및
     */
    private void updateContactWhenReturn() {
        System.debug('@@@@@@ updateContactWhenCancel @@@@@@');

        Map<Id, List<KDCE_Coupon__c>> contactByCoupon = new Map<Id, List<KDCE_Coupon__c>>();   // Contact별 취소된 주문일자

        List<KDCE_Coupon__c> couponList;
        for (KDCE_Coupon__c coupon : (List<KDCE_Coupon__c>) Trigger.new) {
            KDCE_Coupon__c oldCoupon = (KDCE_Coupon__c) Trigger.oldMap.get(coupon.Id);
            if (oldCoupon?.Status__c == KDCE_GlobalValue.COUPON_STATUS_USE && coupon.Status__c == KDCE_GlobalValue.COUPON_STATUS_ISSUE) {
                if (contactByCoupon.containsKey(coupon.Contact__c)) {
                    couponList = contactByCoupon.get(coupon.Contact__c);
                } else {
                    couponList = new List<KDCE_Coupon__c>();
                }
                couponList.add(coupon);
                contactByCoupon.put(coupon.Contact__c, couponList);
            }
        }

        Map<Id, Map<String, Object>> purchaseByContact = new Map<Id, Map<String, Object>>();
        Map<String, Object> purchaseMap = new Map<String, Object>();

        List<Contact> contactList = [
                SELECT Id, KDCE_FirstPurchaseDate__c, KDCE_FirstPurchaseChannel__c, KDCE_FirstPurchaseId__c,
                        KDCE_LastPurchaseDate__c, KDCE_LastPurchaseChannel__c, KDCE_LastPurchaseId__c
                FROM Contact
                WHERE Id IN :contactByCoupon.keySet()
        ];

        // 새로 들어온 취소 주문중에, Contact의 Purchase Date와 일치하는 값이 있는지 확인
        for (Contact contact : contactList) {
            for (KDCE_Coupon__c coupon : contactByCoupon.get(contact.Id)) {
                if (String.valueOf(coupon.Id) == contact.KDCE_FirstPurchaseId__c || String.valueOf(coupon.Id) == contact.KDCE_LastPurchaseId__c) {
                    purchaseByContact.put(contact.Id, null);
                }
            }
        }

        // Contact과 관련된 연결된 Order, Offline Program, Coupon 가져오기 (Order 주문 취소의 경우니까, Order의 경우만 제외할 Id set 넣어줌)
        Set<Id> contactIds = purchaseByContact.keySet();
        Map<Id, List<KDCE_Order__c>> orderListByCon = KDCE_ContactService.getOrderByContactMap(contactIds, null);
        Map<Id, List<KDCE_OfflineProgram__c>> programListByCon = KDCE_ContactService.getProgramByContactMap(contactIds);
        Map<Id, List<KDCE_Coupon__c>> couponListByCon = KDCE_ContactService.getCouponByContactMap(contactIds);

        for (Id contactId : purchaseByContact.keySet()) {
            purchaseMap = new Map<String, Object>();

            // Order 값 비교
            purchaseByContact = KDCE_ContactService.purchaseOrderMap(purchaseByContact, orderListByCon, contactId);
            purchaseByContact = KDCE_ContactService.purchaseProgramMap(purchaseByContact, programListByCon, contactId);
            purchaseByContact = KDCE_ContactService.purchaseCouponMap(purchaseByContact, couponListByCon, contactId);

        }

        // Contact과 연결되어 있는 값 비교
        Map<Id, Contact> updateContactMap = KDCE_ContactService.getPurchaseResult(purchaseByContact);

        if (updateContactMap.size() > 0) update updateContactMap.values();
    }

    // CVS Coupon 사용시, Contact 날짜 업데이트 (LAU, Purchase Date)
    private void updateContactWhenUse() {
        System.debug('@@@@@@ updateContactWhenUse @@@@@@');

        String recordTypeId_Coupon_CVS = rtMap_Coupon.get('Coupon_CVS');
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        Set<Id> contacts = new Set<Id>();


        // TODO 이지현 확인
        List<KDCE_Coupon__c> targetCouponList = new List<KDCE_Coupon__c>();
        for (KDCE_Coupon__c coupon : (List<KDCE_Coupon__c>) Trigger.new) {
            KDCE_Coupon__c oldCoupon = (KDCE_Coupon__c) Trigger.oldMap.get(coupon.Id);
            if (coupon.Contact__c != null) {
                if (oldCoupon?.Status__c <> coupon?.Status__c && coupon?.Status__c == KDCE_GlobalValue.COUPON_STATUS_USE && coupon.RecordTypeId == recordTypeId_Coupon_CVS) {
                    targetCouponList.add(coupon);
                    contacts.add(coupon.Contact__c);
                }
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact contact : [
                SELECT Id, KDCE_LASLAU__c, KDCE_FirstPurchaseChannel__c, KDCE_FirstPurchaseDate__c, KDCE_LastPurchaseDate__c
                FROM Contact
                WHERE Id IN :contacts
        ]) {
            contactMap.put(contact.Id, contact);
        }

        Contact updateContact;
        for (KDCE_Coupon__c coupon : targetCouponList) {

            updateContact = contactMap.get(coupon.Contact__c);
            updateContact.KDCE_LASLAU__c = 'LAU';

            // 업데이트 하려는 값과 비교
            if (contactMap.get(updateContact.Id).KDCE_FirstPurchaseDate__c == null || coupon.UsedDate__c < contactMap.get(updateContact.Id).KDCE_FirstPurchaseDate__c) {
                updateContact.KDCE_FirstPurchaseChannel__c  = KDCE_GlobalValue.CONTACT_CHANNEL_CVS;
                updateContact.KDCE_FirstPurchaseDate__c     = coupon.UsedDate__c;
                updateContact.KDCE_FirstPurchaseId__c       = String.valueOf(coupon.Contact__c);
            }
            if (contactMap.get(updateContact.Id).KDCE_LastPurchaseDate__c == null || coupon.UsedDate__c > contactMap.get(updateContact.Id).KDCE_LastPurchaseDate__c) {
                updateContact.KDCE_LastPurchaseChannel__c   = KDCE_GlobalValue.CONTACT_CHANNEL_CVS;
                updateContact.KDCE_LastPurchaseDate__c      = coupon.UsedDate__c;
                updateContact.KDCE_LastPurchaseId__c        = String.valueOf(coupon.Contact__c);
                updateContact.KDCE_LastCouponUsedDate__c    = coupon.UsedDate__c;
            }
            contactMap.put(updateContact.Id, updateContact);
        }
        System.debug('=== contactMap : ' + contactMap);
        if (!contactMap.isEmpty()) update contactMap.values();
    }


}