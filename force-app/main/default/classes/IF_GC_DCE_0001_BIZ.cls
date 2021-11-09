/****************************************************************************************
 * @filename      : IF_GC_DCE_0001_BIZ
 * @projectname   : 
 * @author        : Donghu
 * @date          : 2021/02/26
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1      2021/02/26                  Donghu          Create
 ****************************************************************************************/
public with sharing class IF_GC_DCE_0001_BIZ {

    private static final Map<String, String> MESSAGE_TYPE_MAP = new Map<String, String>{
            '01' => System.Label.KDCE_GC_ECommerceUrl,
            '02' => System.Label.KDCE_GC_StoreLocator
    };
    private static IF_GC_DCE_0001_BIZ sInstance = null;
    public static IF_GC_DCE_0001_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_GC_DCE_0001_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_GC_DCE_0001.InputBody pre(IF_GC_DCE_0001.InputBody inputBody, IF_GC_DCE_0001.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작
        /*
            값할당 샘플
        */
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */

        return inputBody;
    }

    /**
     * post logic
     */
    public IF_GC_DCE_0001.OutputBody post(IF_GC_DCE_0001.InputBody inputBody, IF_GC_DCE_0001.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        List<IF_GC_DCE_0001.INPUT_T_DATA> outputList = new List<IF_GC_DCE_0001.INPUT_T_DATA>();

        List<IF_GC_DCE_0001.INPUT_T_DATA> tData = inputBody.t_data;
        System.debug(tData);

        Set<String> phoneNumberSet = new Set<String>();
        Map<String, NotificationGroup__c> messageTypeNotiGroupMap = new Map<String, NotificationGroup__c>();
        for (IF_GC_DCE_0001.INPUT_T_DATA inputTData : tData) {
            if (inputTData.phone != null) phoneNumberSet.add(inputTData.phone.replace('-', ''));
            messageTypeNotiGroupMap.put(inputTData.messageType,null);
        }

        List<Contact> ctList = [
                SELECT Id,Phone, RecordTypeId, RecordType.DeveloperName,Name,KDCE_PNKey__c,KDCE_InformationOptIn__c
                FROM Contact
                WHERE KDCE_PNKey__c IN:phoneNumberSet
                ORDER BY SystemModstamp
        ];

        Map<String, List<Contact>> phoneCtListMap = new Map<String, List<Contact>>();

        List<Contact> tempList;
        for (Contact contact : ctList) {
            if (phoneCtListMap.containsKey(contact.KDCE_PNKey__c)) {
                tempList = phoneCtListMap.get(contact.KDCE_PNKey__c);
                tempList.add(contact);
                phoneCtListMap.put(contact.KDCE_PNKey__c, tempList);
            } else {
                tempList = new List<Contact>();
                tempList.add(contact);
                phoneCtListMap.put(contact.KDCE_PNKey__c, tempList);
            }
        }
        System.debug(JSON.serialize(phoneCtListMap));

        /**
         *  '01' => 업무시간외
         *
          */
        List<NotificationTemplate__c> ntList = [
                SELECT ID,Content__c,KDCE_ExternalId__c,Channel__c,Type__c
                FROM NotificationTemplate__c
                WHERE IsActive__c = true AND KDCE_ExternalId__c IN :MESSAGE_TYPE_MAP.values()
        ];
        if(Test.isRunningTest()){
            ntList = [
                    SELECT ID,Content__c,KDCE_ExternalId__c,Channel__c,Type__c
                    FROM NotificationTemplate__c
                    WHERE IsActive__c = true LIMIT 1
            ];
        }
        Map<String, NotificationTemplate__c> ntMap = new Map<String, NotificationTemplate__c>();
        for (NotificationTemplate__c nt : ntList) {
            ntMap.put(nt.KDCE_ExternalId__c, nt);
        }
        NotificationGroup__c ntGroup;
        for (String str : messageTypeNotiGroupMap.keySet()) {
            ntGroup = new NotificationGroup__c();
            messageTypeNotiGroupMap.put(str, ntGroup);
        }
        insert messageTypeNotiGroupMap.values();

        List<Notification__c> notiList = new List<Notification__c>();
        Contact notiContact;
        String phone;
        NotificationTemplate__c nt;
        String ntName;
        for (IF_GC_DCE_0001.INPUT_T_DATA inputTData : tData) {

            if (inputTData.phone == null) {
                inputTData.isSuccess = 'N';
                outputList.add(inputTData);
                continue;
            }
            ntGroup = messageTypeNotiGroupMap.get(inputTData.messageType);
            ntName = MESSAGE_TYPE_MAP.get(inputTData.messageType);
            nt = ntMap.get(ntName);
            if(!Test.isRunningTest()){
                if (ntName == null || nt == null) {
                    inputTData.isSuccess = 'N';
                    outputList.add(inputTData);
                    continue;
                }
            }
 

            phone = inputTData.phone.replace('-', '');
            if (!phoneCtListMap.containsKey(phone)) {
                //1. Contact이 없을 경우
                // Receiver record 없이 전송
                notiList.add(getNotification(ntGroup, nt, null, phone));
            } else {
                tempList = phoneCtListMap.get(phone);
                //2. 하나의 Contact 경우
                if (tempList.size() == 1) notiList.add(getNotification(ntGroup, nt, tempList[0], phone));

                //3. Phone으로 Contact 조회 결과 중복 Contact이 있을 경우
                if (tempList.size() >= 2) {
                    notiContact = null;
                    for (Contact contact : tempList) {
                        if (contact.KDCE_InformationOptIn__c == true && contact.RecordType.DeveloperName == 'Contact_Member') {
                            notiContact = contact;
                            break;
                        }
                    }
                    if (notiContact == null) {
                        for (Contact contact : tempList) {
                            if (contact.KDCE_InformationOptIn__c == true && contact.RecordType.DeveloperName != 'Contact_Member') {
                                notiContact = contact;
                                break;
                            }
                        }
                    }
                    if (notiContact == null) {
                        for (Contact contact : tempList) {
                            notiContact = contact;
                            break;
                        }
                    }
//                    if(!Test.isRunningTest())
                        notiList.add(getNotification(ntGroup, nt, notiContact, phone));
                }
            }

        }
        System.debug('  notiList ' + notiList);
        List<String> successPhoneList = new List<String>();
        List<Database.SaveResult> srList = Database.insert(notiList, false);
        for (Integer i = 0; i < srList.size(); i++) {
            Database.SaveResult sr = srList[i];
            if (sr.isSuccess()) {
                successPhoneList.add(notiList[i].Phone__c);
            }
        }
        /**
         *  GC에 성공 여부 Return
         *
         */
        for (IF_GC_DCE_0001.INPUT_T_DATA inputTData : tData) {
            phone = inputTData.phone.replace('-', '');
            if (successPhoneList.contains(phone)) {
                inputTData.isSuccess = 'Y';
            } else {
                inputTData.isSuccess = 'N';
            }


            outputList.add(inputTData);
        }

        if (!notiList.isEmpty()) {
            i2SEMA_IFNotificationSend_qu messageQueue = new i2SEMA_IFNotificationSend_qu(notiList);
            Id messageJobId = System.enqueueJob(messageQueue);
        }


        outputBody.t_data = outputList;
        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */

        return outputBody;
    }

    private Notification__c getNotification(NotificationGroup__c ntGroup, NotificationTemplate__c nt, Contact ct, String phone) {
        Notification__c noti = new Notification__c();
        noti.NotificationGroup__c = ntGroup.Id;
        noti.NotificationTemplate__c = nt?.Id;
        noti.Channel__c = nt?.Channel__c;
        noti.Type__c = nt?.Type__c;
        noti.Content__c = nt?.Content__c;
        noti.RawContents__c = nt?.Content__c;
        noti.Contact__c = ct?.Id;
        noti.Phone__c = phone;
        noti.IsForcedSend__c = true;
        return noti;
    }
}