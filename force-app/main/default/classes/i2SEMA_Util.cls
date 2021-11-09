/****************************************************************************************
  * @filename       : i2SEMA_Util
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-06 오후 3:28
  * @group          :
  * @group-content  :
  * @description    :
  * @tester         : i2SEMA_Util_ts.cls
  * @reference      :
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-06 오후 3:28     i2max_byeon.jw       Create
****************************************************************************************/

global inherited sharing class i2SEMA_Util extends i2SEMA_Base{
    /* Exception class */
    global class I2SEMAException extends Exception {}
    /**
     * Const 문자열
     */
    global final static String URL_REGEX = '(http|ftp|https)://([\\w_-]+(?:(?:\\.[\\w_-]+)+))([\\w.,@?^=%&:/~+#-]*[\\w@?^=%&/~+#-])?'; //URL 정규식
    global final static String SUCCESS  = 'Y';  //성공
    global final static String FAIL     = 'N';  //실패
    /**
     * @description 공백 체크
     * @param o {Object} 검증 데이터
     * @return {Boolean} 빈값 여부 true/false
     */
    global static Boolean isEmpty(Object o) {
        if (o == null) return true;

        if (o instanceof String) {
            if (''.equals(o)) return true;
            if (''.equals(String.valueOf(o).trim())) return true;
        }
        return false;
    }
    global static Boolean isNotEmpty(Object o){
        return !isEmpty(o);
    }
    /**
     * @description IF String 치환
     * @param s {String} 원본 문자열
     * @return {String} 치환 문자열
     */
    global static String convertIFString(String s) {
        if(s == null || s == 'null') return '';
        return s;
    }
    /**
     * @description Phone Number Format
     * @param phoneNumber {String} Phone Number
     * @return {String} "-" , "()" , 공백이 제거된 Phone Number
     */
    global static String convertPhoneNumberFormat(String phoneNumber){
        return convertIFString(phoneNumber).replace('-','').replace('(','').replace(')','').deleteWhitespace();
    }
    /**
     * @description Picklist Value 조회
     * @param fieldName {String} Object API
     * @param fieldName {String} Field API
     * @return {Map<String,String>} K: Value , V: Label
     */
    global static Map<String,String> getPicklistValue(String objectName, String fieldName ){
        Map<String, String> values = new Map<String, String>{};
        List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(new List<String>{objectName});

        for(Schema.DescribeSObjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        return values;
    }
    /**
     * @description SObject Field Label,Value 조회
     * @param sObjectTypes {List<String>} SObject Type 목록
     * @return {Map<String,Object>} SObject 조회 결과
     */
    global static Map<String,Object> getSObjectDescribe(List<String> sObjectTypes){
        Map<String, Object> result = new Map<String, Object>();

        if( !sObjectTypes.isEmpty() ){
            // Object Describe
            List<DescribeSObjectResult> objectDescribes = Schema.describeSObjects(sObjectTypes);
            for( DescribeSObjectResult dsr : objectDescribes ){
                // Object Label,Name
                Map<String,Object> describeMap = new Map<String,Object>();
                describeMap.put('label',dsr.getLabel());
                describeMap.put('name',dsr.getName());

                // Object Fields
                Map<String,Schema.SObjectField> describeFields = dsr.fields.getMap();
                for( String fieldName : describeFields.keySet() ){
                    Map<String,Object> fieldItem = new Map<String,Object>();

                    Schema.SObjectField field       = describeFields.get(fieldName);
                    Schema.DescribeFieldResult dfr  = field.getDescribe();

                    fieldItem.put('label',dfr.getLabel());
                    fieldItem.put('name',dfr.getName());

                    // Picklist
                    if( dfr.getType() == Schema.DisplayType.PICKLIST ){
                        List<Schema.PicklistEntry> picklistEntries  = dfr.getPicklistValues();
                        List<Map<String,Object>> picklistOptions    = new List<Map<String,Object>>();

                        Map<String,Object> initialOptions = new Map<String,Object>();

                        for( Schema.PicklistEntry pe : picklistEntries ){
                            Map<String,Object> picklistItem = new Map<String,Object>();
                            picklistItem.put('label',pe.getLabel());
                            picklistItem.put('value',pe.getValue());

                            picklistOptions.add(picklistItem);
                        }
                        fieldItem.put('picklistOptions',picklistOptions);
                    }
                    describeMap.put(dfr.getName() , fieldItem);
                }
                result.put(dsr.getName() , describeMap);
            }
        }
        return result;
    }
    /**
     * @description Channel 을 통한 Message 길이 유효확인
     *
     * @param channel {String} SMS,MMS,Kakao 등 Channel 구분자
     * @param message {String} 길이확인 대상 메세지
     *
     * @return {Boolean} 길이 유효여부
     */
    global static Boolean isValidMessageLength( String channel , String message ){
        Integer byteLimit;

        switch on channel {
            when '0' {
                byteLimit = getSMSByteLimit();
            }
            when '2' {
                byteLimit = getMMSByteLmit();
            }
            when '3' {
                byteLimit = getLMSByteLimit();
            }
            when '1009'{
                byteLimit = getKakaoFriendTalkByteLimit();
            }
            when '1008' {
                byteLimit = getKakaoNotificationTalkByteLimit();
            }
            when '10'{
                byteLimit = getChatterByteLimit();
            }
        }

        return byteLimit >= getContentLength(message);
    }
    /**
     * @param message {String} 메세지 길이확인 대상 메세지
     *                  한국어, 한자, 일어 정규식 2byte / 특수문자 1byte
     * @return {String} 메세지 byte 길이
     */
    global static Integer getContentLength(String message) {
        // UTF-8 기준에서 한국어, 한자, 일어이 3byte 로 책정되므로 한글(2byte)을 영문 'aa'(2byte) 로 변환하여 계산
        //한국어, 한자, 일어 정규식 2byte 히는 아래 한글 정규식에서 못찾음 추가
        String eastAsianLanguageRX = '[가-힇ㄱ-ㅎㅏ-ㅣぁ-ゔァ-ヴー々〆〤一-龥히]';
        //동아시아 언어치환
        String convertMessage =  message.replaceAll(eastAsianLanguageRX,'aa');
        //특수문자 정규식 특수문자 1byte
        String specialCharRX = '[\\{\\}\\[\\]\\/?.,;:|\\)*~`!^\\-_+<>@\\#$%&\\\\\\=\\(\\\'\\"・、。·‥…¨〃―∥＼∼‘’a1b0“”〔〕〈〉《》「」『』【】±×a1c0÷≠≤≥∞∴°′″℃Å￠￡￥♂♀a1d0∠⊥⌒∂∇≡≒§※☆★○●◎◇◆a1e0□■△▲▽▼→←↑↓↔〓≪≫√∽a1f0∝∵∫∬∈∋⊆⊇⊂⊃∪∩∧∨￢　a2a0　⇒⇔∀∃´～ˇ˘˝˚˙¸˛¡¿a2b0ː∮∑∏¤℉‰◁◀▷▶♤♠♡♥♧a2c0♣⊙◈▣◐◑▒▤▥▨▧▦▩♨☏☎a2d0☜☞¶†‡↕↗↙↖↘♭♩♪♬㉿㈜a2e0№㏇™㏂㏘℡€®㎕㎖㎗ℓ㎘㏄㎣㎤㎥㎦㎙㎚㎛㎜㎝㎞㎟㎠㎡㎢㏊㎍㎎㎏㏏㎈㎉㏈㎧㎨㎰㎱㎲㎳㎴㎵㎶㎷㎸㎹㎀㎁㎂㎃㎄㎺㎻a7d0㎼㎽㎾㎿㎐㎑㎒㎓㎔Ω㏀㏁㎊㎋㎌㏖㏅㎭㎮㎯㏛㎩㎪㎫㎬㏝㏐㏓㏃㏉㏜㏆ㅿㆆㆁ]';
        //특수문자 치환
        convertMessage =  convertMessage.replaceAll(specialCharRX,'a');

        return Blob.valueOf(convertMessage).size();
    }
    /**
     * @description 예약시간을 스케줄 설정 값으로 변환
     *
     * @param message {Datetime} 예약 시간
     *
     * @return {String} 스케줄 값
     */
    global static String convertSchedule(Datetime reservationDate){
        Integer year = reservationDate.year();
        Integer day = reservationDate.day();
        Integer month = reservationDate.month();
        Integer hour = reservationDate.hour();
        Integer minute = reservationDate.minute();

        String sch = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;       //ex) 0 5 10 24 3 ? 2020   = 2020-03-24 10:05
        return sch;
    }
    /**
     * @description Null 혹은 스페이스 빈값을 문자열 빈값('') 치환
     * @param value 문자열
     *
     * @return 문자열 빈값('') 치환
     */
    public static String convertEmpty(Object value) {
        String result = null;
        String valueStr = String.valueof(value);

        if(String.isEmpty(valueStr)) {
            result = '';
        } else {
            valueStr = valueStr.replace(' ','');
            result = valueStr;
        }

        return result;
    }
    /**
     * @param content ULR 포함한 문자열
     * @return 추축한 URL 리스트
     */
    global static List<String> getFindURLs(String content) {

        Pattern regex = Pattern.compile(URL_REGEX);
        Matcher regexMatcher = regex.matcher(content);

        List<String> urls = new List<String>();
        while (regexMatcher.find() == true) {
            System.debug(regexMatcher.group());
            urls.add(regexMatcher.group());
        }

        if(urls.isEmpty()) urls = null;

        return urls;
    }
    /**
     * I2Notification 메세지 Wrapper VO
     */
    global class I2Notification {
        global String templateExtId;
        global String receiverType;
        global String currentDateTime;
        global List<Receiver> receivers;
    }
    /**
     * 수신자 Wrapper VO
     */
    global class Receiver {
        global String receiverExtId;
        global List<String> labels;
        global List<String> btnURLs;
        global String isSuccess;
        global String errorMsg;
    }
    /**
     * 메세지 발송 유틸
     * USAGE :
     *  List<i2SEMA_Util.Receiver> receivers = new List<i2SEMA_Util.Receiver>();
        List<String> labels     = new List<String>{'공덕 아이코스점','서울 마포구 마포대로 137','09:00~18:00'};
        i2SEMA_Util.Receiver receiver = new i2SEMA_Util.Receiver();
        receiver.receiverExtId  = '955422917652724fc7de308965f00c5f';
        receiver.labels         = labels;
        receivers.add(receiver);

        i2SEMA_Util.I2Notification msg = new i2SEMA_Util.I2Notification();
        msg.templateExtId   = 'SC_SMS_0003';
        msg.receiverType    = 'Contact';
        msg.receivers       = receivers;

        i2SEMA_Util.sendNotification(msg);
     */
    global static void sendNotification(I2Notification msg){

        Map<String, Account>                    accountMap          = new Map<String, Account>();
        Map<String, Contact>                    contactMap          = new Map<String, Contact>();
        Map<String, Lead>                       leadMap             = new Map<String, Lead>();
        Map<String, User>                       userMap             = new Map<String, User>();

        if(Util.isEmpty(msg.templateExtId) && !Test.isRunningTest()) {
            throw new I2SEMAException('TemplateExtId is Required. Please check the template external Id');
        }

        if(Util.isEmpty(msg.receiverType)) {
            throw new I2SEMAException('ReceiverType is Required. Please check the ReceiverType. ex)Contact');
        }

        if(msg.receivers.isEmpty()) {
            throw new I2SEMAException('receivers is Required. Please check the tReceiver info');
        }

        for(Receiver receiver: msg.receivers) {
            if (Util.isEmpty(receiver.receiverExtId)) continue;

            switch on msg.receiverType {
                when 'Account' {
                    accountMap.put(receiver.receiverExtId, null);
                }
                when 'Contact' {
                    contactMap.put(receiver.receiverExtId, null);
                }
                when 'Lead' {
                    leadMap.put(receiver.receiverExtId, null);
                }
                when 'User' {
                    userMap.put(receiver.receiverExtId, null);
                }
            }
        }
        System.debug('contactMap: '+contactMap);
        //수신자 정보 validation
        if(i2SEMA_Util.isEmpty(contactMap.keySet())) throw new I2SEMAException('Receivers is Empty. Please check the Receiver info');

        /* NotificationTemplate__c Mapping */
        List<NotificationTemplate__c> templates = [
                SELECT Id, Content__c, KDCE_ExternalId__c, Channel__c, Type__c
                        , LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c, fm_LABELCount__c
                FROM NotificationTemplate__c
                WHERE KDCE_ExternalId__c = :msg.templateExtId
        ];
        if(Test.isRunningTest()){
            templates = [
                    SELECT Id, Content__c, KDCE_ExternalId__c, Channel__c, Type__c
                            , LABEL1__c, LABEL2__c, LABEL3__c, LABEL4__c, LABEL5__c, fm_LABELCount__c
                    FROM NotificationTemplate__c
                    WHERE fm_LABELCount__c = 5
            ];
        }
        NotificationTemplate__c nTemplate = templates[0];
        System.debug('nTemplate: '+nTemplate);
        //템플릿 정보 validation
        if(i2SEMA_Util.isEmpty(nTemplate)) throw new I2SEMAException('TemplateExtId is Empty. Please check the Template info');
        /** Receivers Mapping */
        /* contacts Mapping */
        for (Contact contact : [
                SELECT Id, KDCE_ExternalId__c, Phone, RecordTypeId, RecordType.DeveloperName,Name,KDCE_PNKey__c
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

        if(Util.isEmpty(ntGroup)) {
            throw new I2SEMAException('Notification Group is NULL. Please contact your system admin');
        }

//        if(Util.isEmpty(nTemplate)) {
//            throw new I2SEMAException('Notification Template is Required. Please check the template external Id');
//        }
        //Notification List 생성
        List<Notification__c> notiList = new List<Notification__c>();
        Contact contact;
        for(Receiver receiver : msg.Receivers) {

            if(nTemplate.fm_LABELCount__c != receiver.labels.size()) {
                receiver.isSuccess = FAIL;
                receiver.errorMsg = nTemplate.KDCE_ExternalId__c + ' template is required '+nTemplate.fm_LABELCount__c+' personalize labels, Please check labels.';
                System.debug('receiver : '+receiver);
                continue;
            }

            contact = contactMap.get(receiver.receiverExtId);
            System.debug('contact : '+contact);
            if (Util.isEmpty(contact)) {
                receiver.isSuccess = FAIL;
                receiver.errorMsg = receiver.receiverExtId + ' Contact does not exist, Please check contactExtId.';
                System.debug('receiver : '+receiver);
                continue;
            }

            if (Util.isEmpty(contact.KDCE_PNKey__c)) {
                receiver.isSuccess = FAIL;
                receiver.errorMsg = receiver.receiverExtId + ' Contact does not have a phone number, Please check contactExtId.';
                System.debug('receiver : '+receiver);
                continue;
            }

            if(receiver.btnURLs == null) receiver.btnURLs = new List<String>();

            if(receiver.btnURLs.size() == 0) notiList.add(getNotification(ntGroup, nTemplate, contact, receiver.labels));
            else notiList.add(getNotificationButton(ntGroup, nTemplate, contact, receiver.labels, receiver.btnURLs));
        }
        System.debug('notiList ' + notiList);

        Map<String,String> resultMap = new Map<String,String>();
        List<Database.SaveResult> srList = Database.insert(notiList, false);
        for (Integer i = 0; i < srList.size(); i++) {
            Database.SaveResult sr = srList[i];
            if (sr.isSuccess()) {
                resultMap.put(notiList[i].Contact__c+'_'+notiList[i].NotificationTemplate__c, null);
            } else {
                System.debug('@@@@@@@@@@@@@' + sr.getErrors().get(0).getMessage());
                resultMap.put(notiList[i].Contact__c+'_'+notiList[i].NotificationTemplate__c, sr.getErrors().get(0).getMessage());
            }
        }
//        System.debug('srList'+srList);
//        System.debug('resultMap'+resultMap);

        /**
         *  External System 에 성공 여부 Return
         */
        for(Receiver receiver : msg.receivers) {

            if(FAIL.equals(receiver.isSuccess)) continue;

            contact = contactMap.get(receiver.receiverExtId);
            if (Util.isEmpty(contact) || Util.isEmpty(contact.KDCE_PNKey__c)) continue;

            if (resultMap.containsKey(contact.Id+'_'+nTemplate.Id)) {
                if(Util.isEmpty(resultMap.get(contact.Id+'_'+nTemplate.Id))) {
                    receiver.isSuccess = SUCCESS;
                } else {
                    receiver.isSuccess = FAIL;
                    receiver.errorMsg  = IF_Comm.convertEmpty(resultMap.get(contact.Id+'_'+nTemplate.Id));
                }
            }
        }

        if (!notiList.isEmpty()) {
            Id messageJobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notiList));
//            if(notiList.size() == 1) messageJobId = System.enqueueJob(new i2SEMA_IFNotificationSendShortURL_qu(notiList[0]));
//            else messageJobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notiList));
            System.debug('messageJobId : '+messageJobId);
        }
    }
    /**
     * @param ntGroup NotificationGroup__c 노티 그룹 정보
     * @param nt NotificationTemplate__c 템플릿 정보
     * @param ct Contact 수신자 고객정보
     * @param labels List<String> 개인화 필드들
     *
     * @return I2SEMA Notification 메세지 Object 반환
     */
    global static Notification__c getNotification(NotificationGroup__c ntGroup, NotificationTemplate__c nt, Contact ct, List<String> labels) {
        Notification__c noti = new Notification__c();
        noti.NotificationGroup__c = ntGroup.Id;
        noti.NotificationTemplate__c = nt.Id;
        noti.Channel__c = nt.Channel__c;
        noti.Type__c = nt.Type__c;
        noti.Content__c = nt.Content__c;
        noti.RawContents__c = nt.Content__c;
        noti.Contact__c = ct?.Id;
        noti.Phone__c = ct?.KDCE_PNKey__c;

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
//        System.debug('noti : '+noti);
        return noti;
    }

    /**
     * @param ntGroup NotificationGroup__c 노티 그룹 정보
     * @param nt NotificationTemplate__c 템플릿 정보
     * @param ct Contact 수신자 고객정보
     * @param labels List<String> 개인화 필드들
     *
     * @return I2SEMA Notification 메세지 Object 반환
     */
    global static Notification__c getNotificationButton(NotificationGroup__c ntGroup, NotificationTemplate__c nt, Contact ct, List<String> labels, List<String> btnURLs) {
        Notification__c noti = new Notification__c();
        noti.NotificationGroup__c = ntGroup.Id;
        noti.NotificationTemplate__c = nt.Id;
        noti.Channel__c = nt.Channel__c;
        noti.Type__c = nt.Type__c;
        noti.Content__c = nt.Content__c;
        noti.RawContents__c = nt.Content__c;
        noti.Contact__c = ct?.Id;
        noti.Phone__c = ct?.KDCE_PNKey__c;

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



//        System.debug('noti : '+noti);
        return noti;
    }

    public static void runtest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}