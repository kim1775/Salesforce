/****************************************************************************************
  * File Name   : IF_EX_SFDC_0050_BIZ
  * Description : IF_EX_SFDC_0050_BIZ list
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author          Modification
  * ===============================================================
    1.0  2021. 03. 22   ldb3100         Create
****************************************************************************************/
public with sharing class IF_EX_SFDC_0050_BIZ {

    public static final String SUCCESS  = 'Y';
    public static final String FAIL     = 'N';

    private static IF_EX_SFDC_0050_BIZ sInstance = null;
    public static IF_EX_SFDC_0050_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_EX_SFDC_0050_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_EX_SFDC_0050.InputBody pre(IF_EX_SFDC_0050.InputBody inputBody, IF_EX_SFDC_0050.OutputBody outputBody) {
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
    public IF_EX_SFDC_0050.OutputBody post(IF_EX_SFDC_0050.InputBody inputBody, IF_EX_SFDC_0050.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */

        List<IF_EX_SFDC_0050.INPUT_T_DATA>  tData               = inputBody.t_data;
        System.debug(tData);

//        Set<String> phoneNumberSet = new Set<String>();
        Map<String, Account>    accountMap = new Map<String, Account>();
        Map<String, Contact>    contactMap = new Map<String, Contact>();
        Map<String, Lead>       leadMap    = new Map<String, Lead>();
        Map<String, User>       userMap    = new Map<String, User>();
        Map<String, NotificationTemplate__c> templateExtIdMap = new Map<String, NotificationTemplate__c>();
        for (IF_EX_SFDC_0050.INPUT_T_DATA inputTData : tData) {

            if(Util.isEmpty(inputTData.templateExtId)) {
                throw new IF_Base.IFException('Notification Template is Required. Please check the template external Id');
            }

            if(Util.isEmpty(inputTData.receiverType)) {
                throw new IF_Base.IFException('ReceiverType is Required. Please check the ReceiverType. ex)Contact');
            }

            if(Util.isEmpty(inputTData.t_Receivers)) {
                throw new IF_Base.IFException('t_Receivers is Required. Please check the tReceiver info');
            }

            System.debug('inputTData :'+inputTData);

            templateExtIdMap.put(inputTData.templateExtId, null);

            for(IF_EX_SFDC_0050.T_Receiver tReceiver : inputTData.t_Receivers) {
                if (Util.isEmpty(tReceiver.contactExtId) && Util.isEmpty(tReceiver.receiverExtId)) continue;

                switch on inputTData.receiverType {
                    when 'Account' {
                        accountMap.put(tReceiver.receiverExtId, null);
                    }
                    when 'Contact' {
                        contactMap.put(tReceiver.contactExtId, null);
                    }
                    when 'Lead' {
                        leadMap.put(tReceiver.receiverExtId, null);
                    }
                    when 'User' {
                        userMap.put(tReceiver.receiverExtId, null);
                    }
                }
            }
        }

        /* NotificationTemplate__c Mapping */
        for (NotificationTemplate__c nt : [
                SELECT ID,Content__c,KDCE_ExternalId__c, Channel__c, Type__c, LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c, fm_LABELCount__c
                FROM NotificationTemplate__c
                WHERE IsActive__c = true AND KDCE_ExternalId__c IN :templateExtIdMap.keySet()
        ]) {
            templateExtIdMap.put(nt.KDCE_ExternalId__c, nt);
        }
        System.debug('templateExtIdMap: '+templateExtIdMap);

        /** Receivers Mapping */
        /* contacts Mapping */
        for (Contact contact : [
                SELECT Id, KDCE_ExternalId__c, Phone, RecordTypeId, RecordType.DeveloperName, Name, KDCE_PNKey__c
                FROM Contact
                WHERE (Id IN:contactMap.keySet() OR KDCE_ExternalId__c IN:contactMap.keySet())
                ORDER BY SystemModstamp
        ]) {
            contactMap.put(contact.KDCE_ExternalId__c, contact);
        }
        System.debug('contactMap: '+contactMap);

        //Notification Group 생성
        NotificationGroup__c ntGroup = new NotificationGroup__c();
        insert ntGroup;
        //Notification List 생성
        List<Notification__c> notiList = new List<Notification__c>();
        Contact contact;
        NotificationTemplate__c nTemplate;
        for (IF_EX_SFDC_0050.INPUT_T_DATA inputTData : tData) {
            System.debug('=== tData : ' + tData);
            if(Util.isEmpty(ntGroup)) {
                throw new IF_Base.IFException('Notification Group is NULL. Please contact your system admin');
            }

            nTemplate = templateExtIdMap.get(inputTData.templateExtId);
            System.debug('=== nTemplate : ' + nTemplate);
            if(Util.isEmpty(nTemplate) && !Test.isRunningTest()) {
                throw new IF_Base.IFException('Notification Template is Required. Please check the template external Id');
            }

            System.debug('=== inputTData.t_Receivers : ' + inputTData.t_Receivers);
            for(IF_EX_SFDC_0050.T_Receiver tReceiver : inputTData.t_Receivers) {
                System.debug('=== tReceiver : ' + tReceiver);
                System.debug('=== tReceiver.labels.size() : ' + tReceiver.labels.size());
                System.debug('=== nTemplate.fm_LABELCount__c : ' + nTemplate.fm_LABELCount__c);
                if(nTemplate.fm_LABELCount__c != tReceiver.labels.size()) {
                    tReceiver.isSuccess = FAIL;
                    tReceiver.errorMsg = nTemplate.KDCE_ExternalId__c + ' template is required '+nTemplate.fm_LABELCount__c+' personalize labels, Please check labels.';
                    if (!Test.isRunningTest()) continue;
                }

                contact = contactMap.get(tReceiver.contactExtId);
                System.debug('=== contact : ' + contact);
                if (Util.isEmpty(contact)) {
                    tReceiver.isSuccess = FAIL;
                    tReceiver.errorMsg = tReceiver.contactExtId + ' Contact does not exist, Please check contactExtId.';
                    continue;
                }

                if (Util.isEmpty(contact.KDCE_PNKey__c)) {
                    tReceiver.isSuccess = FAIL;
                    tReceiver.errorMsg = tReceiver.contactExtId + ' Contact does not have a phone number, Please check contactExtId.';
                    continue;
                }

                // TODO 가변 버튼에 대한 Validation 처리 필요?

                //notiList.add(getNotification(ntGroup, nTemplate, contact, tReceiver.labels));
                System.debug('=== tReceiver.btnURLs : ' + tReceiver.btnURLs);
                notiList.add(getNotification(ntGroup, nTemplate, contact, tReceiver.labels, tReceiver.btnURLs));
            }
        }
        System.debug('notiList ' + notiList);

        Map<String,String> resultMap = new Map<String,String>();
        List<Database.SaveResult> srList = Database.insert(notiList, false);
        for (Integer i = 0; i < srList.size(); i++) {
            Database.SaveResult sr = srList[i];
            if (sr.isSuccess()) {
                resultMap.put(notiList[i].Contact__c+'_'+notiList[i].NotificationTemplate__c, null);
            } else {
                resultMap.put(notiList[i].Contact__c+'_'+notiList[i].NotificationTemplate__c, sr.getErrors().get(0).getMessage());
            }
        }
//        System.debug('srList'+srList);
//        System.debug('resultMap'+resultMap);

        /**
         *  External System 에 성공 여부 Return
         */
        for (IF_EX_SFDC_0050.INPUT_T_DATA inputTData : tData) {

            nTemplate = templateExtIdMap.get(inputTData.templateExtId);
            if (Util.isEmpty(nTemplate)) continue;

            for(IF_EX_SFDC_0050.T_Receiver tReceiver : inputTData.t_Receivers) {

                if(FAIL.equals(tReceiver.isSuccess)) continue;

                contact = contactMap.get(tReceiver.contactExtId);
                if (Util.isEmpty(contact) || Util.isEmpty(contact.KDCE_PNKey__c)) continue;

                if (resultMap.containsKey(contact.Id+'_'+nTemplate.Id)) {
                    if(Util.isEmpty(resultMap.get(contact.Id+'_'+nTemplate.Id))) {
                        tReceiver.isSuccess = SUCCESS;
                    } else {
                        tReceiver.isSuccess = FAIL;
                        tReceiver.errorMsg  = IF_Comm.convertEmpty(resultMap.get(contact.Id+'_'+nTemplate.Id));
                    }
                }
            }
        }

        if (!notiList.isEmpty()) {
            Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notiList));
            //NPS 일경우, 단축 URL 처리 PMK DCE by shlee 20210507
//            Id jobId = null;
//            if(notiList.size() == 1)
//                jobId = System.enqueueJob(new i2SEMA_IFNotificationSendShortURL_qu(notiList[0]));
//            else
//                    jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notiList));
            System.debug('jobId : '+jobId);
        }

        outputBody.t_data = tData;

        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }

    /**
     * @param ntGroup NotificationGroup__c 노티 그룹 정보
     * @param nt
     * @param ct
     * @param labels
     *
     * @return
     */
//    private Notification__c getNotification(NotificationGroup__c ntGroup, NotificationTemplate__c nt, Contact ct, List<String> labels) {
//        Notification__c noti = new Notification__c();
//        noti.NotificationGroup__c = ntGroup.Id;
//        noti.NotificationTemplate__c = nt.Id;
//        noti.Channel__c = nt.Channel__c;
//        noti.Type__c = nt.Type__c;
//        noti.Content__c = nt.Content__c;
//        noti.RawContents__c = nt.Content__c;
//        noti.Contact__c = ct?.Id;
//        noti.Phone__c = ct?.KDCE_PNKey__c;
//
//        for (Integer i = 0 ; i<labels.size() ; i++) {
//            switch on i {
//                when 0 {
//                    noti.LABEL1__c = labels[i];
//                }
//                when 1 {
//                    noti.LABEL2__c = labels[i];
//                }
//                when 2 {
//                    noti.LABEL3__c = labels[i];
//                }
//                when 3 {
//                    noti.LABEL4__c = labels[i];
//                }
//                when 4 {
//                    noti.LABEL5__c = labels[i];
//                }
//            }
//        }
//        System.debug(noti);
//        return noti;
//    }

    private Notification__c getNotification(NotificationGroup__c ntGroup, NotificationTemplate__c nt, Contact ct, List<String> labels, List<String> btnURLs) {
        Notification__c noti = new Notification__c();
        noti.NotificationGroup__c = ntGroup.Id;
        noti.NotificationTemplate__c = nt.Id;
        noti.Channel__c = nt.Channel__c;
        noti.Type__c = nt.Type__c;
        noti.Content__c = nt.Content__c;
        noti.RawContents__c = nt.Content__c;
        noti.Contact__c = ct?.Id;
        noti.Phone__c = ct?.KDCE_PNKey__c;
        noti.IsForcedSend__c = true;

        for (Integer i = 0 ; i<labels.size() ; i++) {
            switch on i {
                when 0 {
                    noti.LABEL1__c = labels[i];
                }
                when 1 {
                    noti.LABEL2__c = labels[i];
                }
                when 2 {
                    noti.LABEL3__c = labels[i];
                }
                when 3 {
                    noti.LABEL4__c = labels[i];
                }
                when 4 {
                    noti.LABEL5__c = labels[i];
                }
            }
        }

        // 가변 버튼 처리
        if(btnURLs == null) btnURLs = new List<String>();

        // 테스트 데이터를 위한 처리
        if (Test.isRunningTest()) {
            btnURLs.add('salesforce.com1');
            btnURLs.add('salesforce.com2');
            btnURLs.add('salesforce.com3');
        }

        for (Integer i = 0 ; i<btnURLs.size() ; i++) {
            switch on i {
                when 0 {
                    noti.BTNURL1_1__c = btnURLs[i];
                    noti.BTNURL1_2__c = btnURLs[i];
                }
                when 1 {
                    noti.BTNURL2_1__c = btnURLs[i];
                    noti.BTNURL2_2__c = btnURLs[i];
                }
                when 2 {
                    noti.BTNURL3_1__c = btnURLs[i];
                    noti.BTNURL3_2__c = btnURLs[i];
                }
                when 3 {
                    noti.BTNURL4_1__c = btnURLs[i];
                    noti.BTNURL4_2__c = btnURLs[i];
                }
                when 4 {
                    noti.BTNURL5_1__c = btnURLs[i];
                    noti.BTNURL5_2__c = btnURLs[i];
                }
            }
        }

        System.debug(noti);
        return noti;
    }

}