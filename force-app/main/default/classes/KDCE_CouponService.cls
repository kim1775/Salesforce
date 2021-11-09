/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-03-05 오전 8:17
  * @group         : 
  * @group-content : 
  * @description   : Coupon 관련 비지니스 로직 정리
  *                 * Coupon History 생성:
  *                     - 쿠폰 주문 취소시, 쿠폰 히스토리 생성
  *                     - IF_XP_SFDC_001__c에 레코드 생성되면 쿠폰 상태값 'Use'로 업데이트하고 쿠폰 히스토리 생성
  * @tester        :
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-03-05 오전 8:17     i2max_Junseok.Kwon        Create
****************************************************************************************/

public without sharing class KDCE_CouponService {

    private static Map<String, Id> rtMap_Coupon = KDCE_Util.getRecordTypeBySObject('KDCE_Coupon__c');
    private static Map<String, Id> rtMap_Task = KDCE_Util.getRecordTypeBySObject('Task');
    private static Map<String, String> pvMap_CouponHistory_ActionChannel = KDCE_Util.getPicklistValue('KDCE_CouponHistory__c', 'ActionChannel__c');
    private static Map<String, String> pvMap_CouponHistory_ActionType = KDCE_Util.getPicklistValue('KDCE_CouponHistory__c', 'ActionType__c');
    private static Map<String, String> pvMap_CouponHistory_Gifticon = KDCE_Util.getPicklistValue('KDCE_CouponHistory__c', 'Gifticon__c');
    private static Map<String, String> pvMap_Coupon_Status = KDCE_Util.getPicklistValue('KDCE_Coupon__c', 'Status__c');
    private static Map<String, String> pvMap_Coupon_IssueChannel = KDCE_Util.getPicklistValue('KDCE_Coupon__c', 'IssueChannel__c');


    public class CouponWrapper {
        public Id couponId { get; set; }
        public Id contactId { get; set; }
        public Id orderContactId { get; set;}
        public Id orderId { get; set;}
        public Datetime actionDate { get; set; }
        public String actionType { get; set; }
        public String gifticon { get; set; }
    }

    /**
     * @description 쿠폰 history 레코드 만들어 반환.
     *              ActionChannel, Gificon__c, Contact__c 값은 메소드 호출부에서 정의해서 사용
     * @param couponId (String)
     * @param couponStatus (String)
     * @return history (KDCE_CouponHistory__c)
     * @author JE Yoon
     */
    public static KDCE_CouponHistory__c createCouponHistory(String couponId, String couponStatus) {
        System.debug('@@@@@@ createCouponHistory @@@@@@');

        String coupon_Status = pvMap_CouponHistory_ActionType.get(couponStatus);

        KDCE_CouponHistory__c history = new KDCE_CouponHistory__c();
        history.Coupon__c       = couponId;
        history.ActionType__c   = coupon_Status;
        history.ActionDate__c   = Datetime.now();
        history.Gifticon__c     = null;
        
        return history;
    }

    /**
     * @description Coupon 생성/발급 시 쿠폰 히스토리 레코드 bulk 생성.
     * @param couponMap (Map<Id, KDCE_Coupon__c>)
     * @return histories (List<KDCE_CouponHistory__c>)
     * @author JE Yoon
     */
    public static List<KDCE_CouponHistory__c> createCouponHistories(Map<Id, KDCE_Coupon__c> couponMap) {
        System.debug('@@@@@@ createCouponHistories @@@@@@');

        String mgmCouponRecordTypeId    = rtMap_Coupon.get('Coupon_MGM');
        String gifticon                 = pvMap_CouponHistory_Gifticon.get('Starbucks');  // todo 오프라인일 때는 화면에서 직접 들어가는 케이스 + 기타 쿠폰 레코드 타입 고려 필요
        String issueStatus              = pvMap_Coupon_Status.get('Issue');
        String useStatus                = pvMap_Coupon_Status.get('Use');

        List<KDCE_CouponHistory__c> histories = new List<KDCE_CouponHistory__c>();
        KDCE_CouponHistory__c history;

        for (Id couponId : couponMap.keySet()) {
            history = new KDCE_CouponHistory__c();
            history.Coupon__c = couponId;
            history.ActionDate__c       = Datetime.now();
            history.ActionType__c       = couponMap.get(couponId)?.Status__c;
            history.ActionChannel__c    = couponMap.get(couponId)?.IssueChannel__c;

            // 쿠폰 상태가 Produce나 Issue이고 쿠폰의 Contact__c이 null 아닐 때만 CouponHistory 레코드의 Contact__c 값 정의 그외의 경우에는 null 처리 후 메소드 호출하는 곳에서 Contact__c 값 따로 정의
            history.Contact__c          = couponMap.get(couponId)?.Status__c == issueStatus && couponMap.get(couponId)?.Contact__c != null ? couponMap.get(couponId)?.Contact__c : null;
            // MGM 쿠폰이며, 쿠폰 상태가 Use이며, 쿠폰 사용횟수가 5회 미만일때 기프티콘 발급
            //history.Gifticon__c         = couponMap.get(couponId)?.RecordTypeId == mgmCouponRecordTypeId && couponMap.get(couponId)?.Status__c == useStatus && couponMap.get(couponId)?.ru_UseCount__c < 5 ? gifticon : null;
            history.Gifticon__c         = couponMap.get(couponId)?.RecordTypeId == mgmCouponRecordTypeId && couponMap.get(couponId)?.Status__c == useStatus ? gifticon : null;
            histories.add(history);
        }

        return histories;
    }


    /**
     * @description 쿠폰이 사용될 때 해당 쿠폰에 대한 쿠폰 사용 히스토리 생성.
     *              MGM Coupon 타입이 있을 경우 createMGMCouponTask 메소드를 호출해 Task 생성 및 contact의 godFather 필드 업데이트
     * @param CouponWrappers (List<CouponWrapper)
     * @param actionChannel (String)
     * @author JE Yoon
     * */
    public static void createCouponUseHistory(List<CouponWrapper> CouponWrappers, String actionChannel) {
        System.debug('@@@@@@ createCouponUseHistory @@@@@@');

        System.debug('=== CouponWrappers : ' + CouponWrappers);
        String channel                  = pvMap_CouponHistory_ActionChannel.get(actionChannel);
        String channel_online           = pvMap_CouponHistory_ActionChannel.get('Online');
        String mgmCouponRecordTypeId    = rtMap_Coupon.get('Coupon_MGM');

        List<KDCE_CouponHistory__c> histories = new List<KDCE_CouponHistory__c>();
        List<KDCE_CouponHistory__c> mgmCouponHistories = new List<KDCE_CouponHistory__c>();
        Map<Id, KDCE_Coupon__c> couponMap = new Map<Id, KDCE_Coupon__c>();
        Set<Id> couponIds = new Set<Id>();

        KDCE_CouponHistory__c history;

        for (CouponWrapper ow : CouponWrappers) {
            history = new KDCE_CouponHistory__c();
            history.Coupon__c           = ow.couponId;
            history.Contact__c          = ow.contactId;
            history.ActionType__c       = ow.actionType;
            history.ActionDate__c       = ow.actionDate;
            history.Gifticon__c         = ow.gifticon;
            history.ActionChannel__c    = channel;
            if (channel == channel_online) history.Order__c = ow.orderId;
            histories.add(history);
            couponIds.add(ow.couponId);
        }
        System.debug('=== histories : ' + histories);

        Database.SaveResult[] historyResults = Database.insert(histories);

        // createMGMCouponTask 메소드 호출 시 이 메소드에서 사용되는 필드 조회
        couponMap = new Map<Id, KDCE_Coupon__c>([
                SELECT Name, Contact__r.Name, ru_GifticonReceivedHistoryCount__c, RecordTypeId
                FROM KDCE_Coupon__c
                WHERE Id IN :couponIds
        ]);
        System.debug('=== couponMap : ' + couponMap);

        for (KDCE_CouponHistory__c couponHistory : histories) {
            if (couponMap.get(couponHistory.Coupon__c)?.RecordTypeId == mgmCouponRecordTypeId) mgmCouponHistories.add(couponHistory);
        }
        System.debug('=== mgmCouponHistories : ' + mgmCouponHistories);

        if (mgmCouponHistories.size() > 0) createMGMCouponTask(mgmCouponHistories, couponMap);
    }

    /**
     * @description MGM Coupon 사용 시 해당 직원 task 등록.
     *              MGM Coupon 쿠폰 사용한 Contact.KDCE_gotfather__c을 MGM 쿠폰 발급인의 Contact로 업데이트
     * @param histories (List<KDCE_CouponHistory__c>)
     * @param couponMap (Map<Id, KDCE_Coupon__c>)
     * @author JE Yoon
     * */
    public static void createMGMCouponTask(List<KDCE_CouponHistory__c> histories, Map<Id, KDCE_Coupon__c> couponMap) {
        System.debug('@@@@@@ createMGMCouponTask @@@@@@');

        List<Task> tasks = new List<Task>();
        List<Contact> sonContacts = new List<Contact>();
        Map<Id, Id> sonFatherMap = new Map<Id, Id>();
        Task task;
        String offlineTaskRecordTypeId = rtMap_Task.get('KDCE_OfflineTask');
        String taskSubject = 'MGM Coupon Use';
        Decimal historyCount;

        System.debug('=== histories : ' + histories);
        System.debug('=== couponMap : ' + couponMap);
        for (KDCE_CouponHistory__c hist : histories) {
            task = new Task();
//            task.RecordTypeId = offlineTaskRecordTypeId;  // TODO 여기서 오류나는데 확인해보니까 Task Record Type 없음
            task.WhoId = couponMap.get(hist.Coupon__c).Contact__c;
            task.OwnerId = UserInfo.getUserId();
            task.Subject = taskSubject;
            task.WhatId = hist.Id;
            task.Gifticon__c = hist.Gifticon__c;
            historyCount = couponMap.get(hist.Coupon__c)?.ru_GifticonReceivedHistoryCount__c;
            task.Description = couponMap.get(hist.Coupon__c)?.Contact__r.Name + ' received ' + historyCount + ' gifticon: ' + hist.Gifticon__c;
            tasks.add(task);

            // sonFatherMap : (쿠폰 사용한 사람, MGM 발급한 사람 = GodFather) 해당 사람이 다를 경우에만 God Father 업데이트
            if (hist.Contact__c != couponMap.get(hist.Coupon__c).Contact__c) {
                sonFatherMap.put(hist.Contact__c, couponMap.get(hist.Coupon__c).Contact__c);
            }
        }
        System.debug('=== sonFatherMap : ' + sonFatherMap);
        System.debug('=== couponMap : ' + couponMap);

        sonContacts = [SELECT Id, KDCE_GodFather__c FROM Contact WHERE Id IN :sonFatherMap.keySet()];
        System.debug('=== sonContacts : ' + sonContacts);

        for (Contact son : sonContacts) {
            son.KDCE_GodFather__c = sonFatherMap.get(son.Id);
        }

        Database.SaveResult[] taskResults = Database.insert(tasks);
        Database.SaveResult[] contactResults = Database.update(sonContacts);
    }



    /**
     * @description  파라미터 couponRecordTypeName 레코드 타입의 쿠폰을 조회해 List<contact>에 쿠폰 발급 처리
     *              MGM 쿠폰 발급 시에는 해당 Contact의 KDCE_MGMCode__c를 쿠폰 번호로 업데이트 및
     *              쿠폰의 IssueChannel__c = Online으로 업데이트
     * @param contacts (List<Contact>)
     * @param couponRecordTypeName (String)
     * @author JE Yoon
     * */
    public static void issueCoupon(List<Contact> contacts, String couponRecordTypeName) {
        System.debug('@@@@@@ issueCoupon @@@@@@');
        System.debug('=== contacts : ' + contacts.size());
        System.debug('=== couponRecordTypeName : ' + couponRecordTypeName);

        List< KDCE_Coupon__c> coupons = new List< KDCE_Coupon__c>();
        Contact contact;
        KDCE_Coupon__c coupon;
        String couponStatus_Issue   = pvMap_Coupon_Status.get('Issue');
        String couponStatus_Produce = pvMap_Coupon_Status.get('Produce');
        String couponTypeId         = rtMap_Coupon.get(couponRecordTypeName);
        String mgmCouponDevName     = 'Coupon_MGM';
        //String onlineIssueChannel   = pvMap_Coupon_IssueChannel.get('Online');
        Integer sizeGap;

        // Non-selective query 에러 (데이터가 너무 많아서) 떄문에 Limit 강제 할당
        /*
        coupons = [
                SELECT Id, RecordTypeId, CouponCode__c, Status__c, Contact__c
                FROM KDCE_Coupon__c
                WHERE ExternalType__c = 'MGMCode'
                 AND RecordTypeId = :couponTypeId
                AND Status__c = :couponStatus_Produce
                LIMIT :contacts.size()
        ];
        */
        Integer rand = Math.floor(Math.random() * 1000).intValue();

        if(System.isBatch()){
            coupons = [
                    SELECT Id, RecordTypeId, CouponCode__c, Status__c, Contact__c
                    FROM KDCE_Coupon__c
                    WHERE ExternalType__c = 'MGM'
                    AND RecordTypeId = :couponTypeId
                    AND Status__c = :couponStatus_Produce
                    ORDER BY CouponCode__c ASC
                    LIMIT :contacts.size()
                    //OFFSET :rand
            ];
        } else {
            coupons = [
                    SELECT Id, RecordTypeId, CouponCode__c, Status__c, Contact__c
                    FROM KDCE_Coupon__c
                    WHERE ExternalType__c = 'MGM'
                    AND RecordTypeId = :couponTypeId
                    AND Status__c = :couponStatus_Produce
                    ORDER BY CouponCode__c DESC
                    LIMIT :contacts.size()
                    OFFSET :rand
            ];
        }

        System.debug('=== coupons : ' + coupons.size());

        if (coupons.size() > 0) {
            for (Integer i = 0; i < contacts.size(); i++) {
                coupon = coupons[i];
                contact = contacts[i];
                coupon.Status__c = couponStatus_Issue;
                coupon.Contact__c = contact.Id;
                if (coupon.RecordTypeId == rtMap_Coupon.get(mgmCouponDevName) && contact.KDCE_IsMGMIssue__c == true && contact.KDCE_MGMCode__c == null) {
                    contact.KDCE_MGMCode__c = coupon.CouponCode__c;
                    //coupon.IssueChannel__c = onlineIssueChannel;
                }
            }

            sizeGap = contacts.size() - coupons.size();

            // 발급해야 할 MGM 쿠폰 수 < 컨택 수일 경우 발급할 쿠폰이 없는 컨택의 KDCE_IsMGMIssue__c = false 처리
            if (sizeGap > 0 && couponRecordTypeName == mgmCouponDevName) {
                for (Integer i = coupons.size() ; i < contacts.size() ; i++) { //todo mgm 외에 다른 쿠폰의 경우 어떻게 처리??
                    contact = contacts[i];
                    contact.KDCE_IsMGMIssue__c = false;
                }
            }

            Database.SaveResult[] sr_coupon = Database.update(coupons);

        } else {
            if (couponRecordTypeName == mgmCouponDevName) {
                for (Contact con : contacts) {
                    con.KDCE_IsMGMIssue__c = false;
                }
            }
        }
    }

    /**
     * @description MGM 쿠폰 사용/사용취소 히스토리 생성 시 MGM 쿠폰이 발급된 Contact의 KDCE_MGMUseCount__c 값 업데이트
     * @param couponHistories (List<KDCE_CouponHistory__c>)
     * @author JE Yoon
     * TODO 현재는 Contact.KDCE_MGMUseCount__c = [MGM 쿠폰 사용 히스토리 수]로 업데이트하는 처리함. 쿠폰 사용 취소된 건도 KDCE_MGMUseCount에 카운트 돼야 하면 주석 부분으로 로직 대체
     **/
    public static void updateContactMGMUseCount(List<KDCE_CouponHistory__c> couponHistories) {
        System.debug('@@@@@@ KDCE_CouponService - updateContactMGMUseCount @@@@@@');

        Map<Id, Decimal> contactMap_MGMUseCount = new Map<Id, Decimal>();
        Map<Id, Decimal> contactMap_MGMCancelCount = new Map<Id, Decimal>();
        Map<Id, Id> coupon_contact_Map = new Map<Id, Id>(); // <coupon Id, contact Id> map
        List<AggregateResult> useResultList_history;
        List<AggregateResult> cancelResultList_history;
        List<KDCE_Coupon__c> couponList = new List<KDCE_Coupon__c>();
        List<Contact> contactList = new List<Contact>();
        Set<Id> couponIds = new Set<Id>();
        String recordTypeId_Coupon_MGM = rtMap_Coupon.get('Coupon_MGM');
        String actionType_Use = pvMap_CouponHistory_ActionType.get('Use');
        Id couponId;
        Id contactId;
        Decimal coupon_Count;

        for (KDCE_CouponHistory__c couponHistory : couponHistories) {
            if (couponHistory.ActionType__c == KDCE_GlobalValue.COUPON_HISTORY_TYPE_USE || couponHistory.ActionType__c == KDCE_GlobalValue.COUPON_HISTORY_TYPE_CANCEL) {
                couponIds.add(couponHistory.Coupon__c);
            }
        }
        System.debug('=== couponIds : ' + couponIds);

        if (couponIds.size() > 0) {
            couponList = [SELECT Id, Contact__c FROM KDCE_Coupon__c WHERE Id IN :couponIds AND RecordTypeId = :recordTypeId_Coupon_MGM];
            System.debug('=== couponList : ' + couponList);
            if (couponList.size() > 0) {
                for (KDCE_Coupon__c coupon : couponList) {
                    coupon_contact_Map.put(coupon.Id, coupon.Contact__c);
                    contactMap_MGMUseCount.put(coupon.Contact__c, 0);
                    contactMap_MGMCancelCount.put(coupon.Contact__c, 0);
                }

                // 쿠폰 사용시 +1
                useResultList_history = [
                        SELECT      COUNT(Id) cnt, Coupon__c, ActionType__c
                        FROM        KDCE_CouponHistory__c
                        WHERE       Coupon__c = :coupon_contact_Map.keySet() AND ActionType__c = :KDCE_GlobalValue.COUPON_HISTORY_TYPE_USE
                        GROUP BY    Coupon__c, ActionType__c
                ];
                System.debug('=== resultList_history : ' + useResultList_history);

                if (useResultList_history.size() > 0) {
                    for (AggregateResult result : useResultList_history) {
                        couponId = String.valueOf(result.get('Coupon__c'));
                        contactId = String.valueOf(coupon_contact_Map.get(couponId));
                        coupon_Count = (Decimal) result.get('cnt');
                        contactMap_MGMUseCount.put(contactId, coupon_Count);
                    }

                }

                // 쿠폰 취소시 -1
                cancelResultList_history = [
                        SELECT      COUNT(Id) cnt, Coupon__c, ActionType__c
                        FROM        KDCE_CouponHistory__c
                        WHERE       Coupon__c = :coupon_contact_Map.keySet() AND ActionType__c = :KDCE_GlobalValue.COUPON_HISTORY_TYPE_CANCEL
                        GROUP BY    Coupon__c, ActionType__c
                ];
                System.debug('=== cancelResultList_history : ' + cancelResultList_history);

                if (cancelResultList_history.size() > 0) {
                    for (AggregateResult result : cancelResultList_history) {
                        couponId = String.valueOf(result.get('Coupon__c'));
                        contactId = String.valueOf(coupon_contact_Map.get(couponId));
                        coupon_Count = (Decimal) result.get('cnt');
                        contactMap_MGMCancelCount.put(contactId, coupon_Count);
                    }
                }

                System.debug('=== contactMap_MGMUseCount : ' + contactMap_MGMUseCount);
                System.debug('=== contactMap_MGMCancelCount : ' + contactMap_MGMCancelCount);
                contactList = [SELECT KDCE_MGMUseCount__c FROM Contact WHERE Id = :contactMap_MGMUseCount.keySet() OR Id = :contactMap_MGMCancelCount.keySet()];
                System.debug('=== contactList : ' + contactList);
                for (Contact contact : contactList) {
                    if (contactMap_MGMUseCount.get(contact.Id) != null && contactMap_MGMCancelCount.get(contact.Id) != null) {
                        contact.KDCE_MGMUseCount__c = contactMap_MGMUseCount.get(contact.Id) - contactMap_MGMCancelCount.get(contact.Id);
                    }
                    else if (contactMap_MGMUseCount.get(contact.Id) != null && contactMap_MGMCancelCount.get(contact.Id) == null) {
                        contact.KDCE_MGMUseCount__c = contactMap_MGMUseCount.get(contact.Id);
                    }
                    else contact.KDCE_MGMUseCount__c = contactMap_MGMCancelCount.get(contact.Id);
                }
            }
        }
        System.debug('=== contactList : ' + contactList);
        if (!contactList.isEmpty()) update contactList;

    }




    /**
     * @description 온라인에서 쿠폰 사용 시 쿠폰 Status__c = Use로 업데이트.
     *              List<KDCE_Order__c>를 createCouponUseHistory 메소드(온라인/오프라인 쿠폰 사용을 처리하기 위한 공통 메소드)에서 사용할
     *              파라미터(List<CouponWrapper>)로 바꿔주는 처리
     * @param orders (List<KDCE_Order__c>)
     * @author JE Yoon
     * */
    public static void createOnlineCouponUseHistory(List<KDCE_Order__c> orders) {
        System.debug('@@@@@@ createOnlineCouponUseHistory @@@@@@');

        List<CouponWrapper> CouponWrappers = new List<CouponWrapper>();
        Map<Id, KDCE_Coupon__c> couponMap = new Map<Id, KDCE_Coupon__c>();
        CouponWrapper ow;
        KDCE_Coupon__c coupon;
        String actionType_Use = pvMap_Coupon_Status.get('Use');
        String gifticon = pvMap_CouponHistory_Gifticon.get('Starbucks');
        String mgmCouponRecordTypeId = rtMap_Coupon.get('Coupon_MGM');
        String actionChannel_Online = pvMap_CouponHistory_ActionChannel.get('Online');

        // Order에 쓰인 Coupon 저장
        for (KDCE_Order__c order : orders) {
            if (order.Coupon__c != null) {
                couponMap.put(order.Coupon__c, null);
            }
        }
        System.debug('=== couponMap : ' + couponMap);

        if (!couponMap.isEmpty()) {
            couponMap = new Map<Id, KDCE_Coupon__c>([
                    SELECT Id, Status__c, ru_UseCount__c, RecordTypeId, Contact__c
                    FROM KDCE_Coupon__c WHERE Id IN :couponMap.keySet()]);

            for (Id couponId : couponMap.keySet()) {
                coupon = couponMap.get(couponId);
                coupon.Status__c = actionType_Use;
            }

            Database.SaveResult[] sv_coupon = Database.update(couponMap.values());

            // Coupon History 생성을 위한 Coupon Wrapper 데이터 생성
            for (KDCE_Order__c order : orders) {
                ow = new CouponWrapper();
                ow.orderId          = order.Id;
                ow.couponId         = order.Coupon__c;
                ow.contactId        = order.Contact__c;
                ow.actionDate       = Datetime.now();
                ow.actionType       = actionType_Use;
                ow.gifticon         = couponMap.get(order.Coupon__c)?.RecordTypeId == mgmCouponRecordTypeId && couponMap.get(order.Coupon__c)?.Status__c == actionType_Use  ? gifticon : null;
                CouponWrappers.add(ow);
            }
            System.debug('=== CouponWrappers : ' + CouponWrappers);

            createCouponUseHistory(CouponWrappers, actionChannel_Online);
        }
    }

    /**
     * @description 오프라인에서 쿠폰 사용 시 쿠폰 Status__c = Use로 업데이트.
     *              createCouponUseHistory 메소드(온라인/오프라인 쿠폰 사용을 처리하기 위한 공통 메소드)에서 사용할
     *              파라미터(List<CouponWrapper>)로 바꿔주는 처리
     * @param couponId (String)
     * @param contactId (String)
     * @param gifticon (String)
     * @author JE Yoon
     * */
    public static void createOfflineCouponUseHistory(String couponId, String contactId, String gifticon) {
        System.debug('@@@@@@ createOfflineCouponUseHistory @@@@@@');

        System.debug('=== couponId : ' + couponId);
        System.debug('=== contactId : ' + contactId);
        System.debug('=== gifticon : ' + gifticon);
        List<CouponWrapper> CouponWrappers = new List<CouponWrapper>();
        Map<Id, KDCE_Coupon__c> couponMap = new Map<Id, KDCE_Coupon__c>();
        CouponWrapper ow;
        KDCE_Coupon__c coupon;
        String actionType_Use = pvMap_CouponHistory_ActionType.get('Use');
        String mgmCouponRecordTypeId = rtMap_Coupon.get('Coupon_MGM');
        String actionChannel = pvMap_CouponHistory_ActionChannel.get('Offline');

        couponMap = new Map<Id, KDCE_Coupon__c>([SELECT Id, Status__c, ru_UseCount__c, RecordTypeId FROM KDCE_Coupon__c WHERE Id = :couponId]);

        for (Id id : couponMap.keySet()) {
            coupon = couponMap.get(id);
            coupon.Status__c = actionType_Use;
            couponMap.put(id, coupon);
        }

        Database.SaveResult[] sv_coupon = Database.update(couponMap.values());

        ow = new CouponWrapper();
        ow.couponId = couponId;
        ow.contactId = contactId;
        ow.actionDate = Datetime.now();
        ow.actionType = actionType_Use;
        ow.gifticon = couponMap.get(couponId)?.RecordTypeId == mgmCouponRecordTypeId ? gifticon : null;
        CouponWrappers.add(ow);
        System.debug('=== CouponWrappers : ' + CouponWrappers);

        createCouponUseHistory(CouponWrappers, actionChannel);
    }

}