/****************************************************************************************
  * @filename      : i2SEMA_ManualSendRetry
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/03/06 9:51 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_ManualSendRetry_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author              description
  * ===============================================================
    0.1     2020/03/06 9:51 AM     i2max_ys.seo         Create
    0.2     2020/04/14 9:51 AM     i2max_shlee          Rename NotificationSendRetry->i2SEMA_ManualSendRetry
    0.3     2020/05/14 9:51 AM     i2max_shlee          미리보기 추가
****************************************************************************************/

public with sharing class i2SEMA_ManualSendRetry {
    /**
     * @description Notification Retry init
     *                해당 Notification Id, Notification Group Id일 때 Notification Template을 가져와서 I/F호출
     * @param param {Map<String,Object>} 전체 Parameter Wrapper
     * @return {Util_ComponentResponse} 통신 결과 Wrapper
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse initialize(String recordId) {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        /*
         * Validation : Is the record Available ?
         */
        if(i2SEMA_Util.isEmpty(recordId)) {
            throw new AuraHandledException(LABEL.i2SEMA_MSG_NO_EXIST_ID);
        }
        String idPrefix = recordId.left(3);
        if( !(Schema.SObjectType.Notification__c.getKeyPrefix().equals(idPrefix)
                || Schema.SObjectType.NotificationGroup__c.getKeyPrefix().equals(idPrefix))) {
            throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_NOTI_OR_NOTIGROUP_ID);
        }

        //Notification Id일 경우 (Notification 상세화면에서 Retry 버튼 누를 때)
        if(Schema.SObjectType.Notification__c.getKeyPrefix().equals(idPrefix)){
            Notification__c notification = [
                    SELECT Id, Contact__c, Title__c, Channel__c, Content__c, NotificationGroup__c
                            , NotificationTemplate__c, NotificationTemplate__r.Channel__c, NotificationTemplate__r.Title__c, NotificationTemplate__r.KakaoImgUrl__c, Validity__c, msg_status__c, ErrorMessage__c
                    FROM Notification__c
                    WHERE Id = :recordId AND Validity__c = TRUE
            ];
            if(i2SEMA_Util.isEmpty(notification)) {
                throw new AuraHandledException(LABEL.i2SEMA_MSG_VALIDATION_FAILED + notification.ErrorMessage__c);
            }
            RequestData requestData     = new RequestData();
            requestData.templateId      = notification.NotificationTemplate__c;
            requestData.channel         = notification.Channel__c;
            requestData.Title           = notification.Title__c;
            requestData.content         = notification.Content__c;
            requestData.contentLength   = i2SEMA_Util.getContentLength(notification.Content__c);
//            response.setData('referenceData', notification);
            response.setData('reqData', requestData);
        //NotificationGroup Id일 경우 (Notification Group 상세화면에서 Retry 버튼 누를 때)
        } else if(Schema.SObjectType.NotificationGroup__c.getKeyPrefix().equals(idPrefix)){
            List<Notification__c> notifications = [SELECT Id, NotificationGroup__c, NotificationGroup__r.IF_Status__c
                                                            , NotificationTemplate__c, Validity__c, msg_status__c, ErrorMessage__c
                                                    FROM Notification__c
                                                    WHERE NotificationGroup__c = :recordId
                                                    AND Validity__c = TRUE];
//                                                    AND NotificationGroup__r.IF_Status__c IN ('Canceled', 'Failed','Failed request to send','Failed request to cancel')];

            if(i2SEMA_Util.isEmpty(notifications) || notifications.size() < 1) {
                throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_NOTI_ID);
            }

            Integer retryCnt = 0;
            Integer errCnt = 0;
            String errMSG = null;
            Notification__c samppleNotification;
            for(Notification__c noti : notifications) {
                if(noti.Validity__c) {
                    retryCnt++;
                    samppleNotification = noti;
                }
                else {
                    errCnt++;
                    errMSG = noti.ErrorMessage__c;
                }
            }

            response.setData('referenceData', samppleNotification);
        }

        return response;
    }
    /**
     * @description Notification Re Send
     *                해당 Notification Id, Notification Group Id일 때 Notification Template을 가져와서 I/F호출
     * @param param {Map<String,Object>} 전체 Parameter Wrapper
     * @return {Util_ComponentResponse} 통신 결과 Wrapper
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse resend(String recordId) {
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        String idPrefix = recordId.left(3);

        //Notification Id일 경우 (Notification 상세화면에서 Retry 버튼 누를 때)
        if(Schema.SObjectType.Notification__c.getKeyPrefix().equals(idPrefix)){
            Notification__c notification = [
                    SELECT Id, NotificationTemplate__c, Validity__c, msg_status__c, ErrorMessage__c
                    FROM Notification__c
                    WHERE Id = :recordId AND Validity__c = TRUE
            ];
            if(i2SEMA_Util.isEmpty(notification)) {
                throw new AuraHandledException(LABEL.i2SEMA_MSG_VALIDATION_FAILED + notification.ErrorMessage__c);
            }
            update notification;
            System.debug('notification :'+notification);
            Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notification));
            //NPS 일경우, 단축 URL 처리 PMK DCE by shlee 20210507
//            Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSendShortURL_qu(notification));

        //NotificationGroup Id일 경우 (Notification Group 상세화면에서 Retry 버튼 누를 때)
        } else if(Schema.SObjectType.NotificationGroup__c.getKeyPrefix().equals(idPrefix)){
            List<Notification__c> notifications = [
                    SELECT Id, NotificationGroup__c, NotificationGroup__r.IF_Status__c, NotificationTemplate__c, Validity__c, msg_status__c, ErrorMessage__c
                    FROM Notification__c
                    WHERE NotificationGroup__c = :recordId
//                    AND Validity__c = TRUE
            ];
//                                                    AND NotificationGroup__r.IF_Status__c IN ('Canceled', 'Failed','Failed request to send','Failed request to cancel')];

            if(i2SEMA_Util.isEmpty(notifications) || notifications.size() < 1) {
                throw new AuraHandledException(LABEL.i2SEMA_MSG_INVALID_NOTI_ID);
            }

            Integer retryCnt = 0;
            Integer errCnt = 0;
            String errMSG = null;
            for(Notification__c noti : notifications) {
                if(noti.Validity__c) retryCnt++;
                else {
                    errCnt++;
                    errMSG = noti.ErrorMessage__c;
                }
            }
            update notifications;
            System.debug('notifications :'+notifications);
            //메세지 발송 queue
            Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(notifications));
            System.debug('jobId : '+jobId);



        }

        return response;
    }

//    public class ReferenceData {
//        @AuraEnabled public String recordId                             {get;set;}      // Record ID
//        @AuraEnabled public String recordType                           {get;set;}      // Record SObject Type
//        @AuraEnabled public List<Option> channelOptions                 {get;set;}      // 채널 선택목록
//        // 수신자 관련 참조정보
//        @AuraEnabled public List<Option> receiverOptions                {get;set;}      // 수신자 선택목록
//        @AuraEnabled public List<Option> referenceFieldOptions          {get;set;}      // Look-up 필드 목록
//        @AuraEnabled public Map<String,String> referenceFieldTypes      {get;set;}      // Look-up 필드의 SObject Type
//        @AuraEnabled public List<Option> receiverTypeOptions            {get;set;}      // Child SObject 목록
//        @AuraEnabled public List<Option> specificTypeOptions            {get;set;}      // 특정타입 수신자 선택목록
//        // 템플릿 관련 참조정보
//        @AuraEnabled public NotificationTemplate__c template            {get;set;}      // 선택한 Template 상세정보
//        @AuraEnabled public TemplateOption templateOption               {get;set;}      // 템플릿 Label 가용정보
//        @AuraEnabled public List<Option> typeOptions                    {get;set;}      // 타입(광고성,정보성) 선택목록
//
//        public ReferenceData(){
//            this.channelOptions         = new List<Option>();
//            this.receiverOptions        = new List<Option>();
//            this.receiverTypeOptions    = new List<Option>();
//            this.typeOptions            = new List<Option>();
//            this.templateOption         = new TemplateOption();
//        }
//        public ReferenceData(String recordId){
//            if( i2SEMA_Util.isNotEmpty(recordId)){
//                this.recordId       = recordId;
//                this.recordType     = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
//            }
//            this.channelOptions         = new List<Option>();
//            this.receiverOptions        = new List<Option>();
//            this.receiverTypeOptions    = new List<Option>();
//            this.typeOptions            = new List<Option>();
//            this.templateOption         = new TemplateOption();
//        }
//    }
    public class RequestData {
//        @AuraEnabled public String recordId                             {get;set;}      // Record ID
//        @AuraEnabled public String recordType                           {get;set;}      // Record SObject Type
        @AuraEnabled public String channel                              {get;set;}      // Channel
        // 수신자 관련
//        @AuraEnabled public String receiverOption                       {get;set;}      // 수신자 옵션
//        @AuraEnabled public String receiverType                         {get;set;}      // (하위,특정) 레코드 Object Type
        @AuraEnabled public List<String> receiverIds                    {get;set;}      // (하위) 수신자 ID 목록
        @AuraEnabled public List<Receiver> specificReceivers            {get;set;}      // (특정) 수신자 목록
//        @AuraEnabled public String referenceField                       {get;set;}      // (상위) Look-up 필드
//        @AuraEnabled public String referenceFieldType                   {get;set;}      // (상위) Look-up 필드의 Object Type
        // 템플릿 관련
        @AuraEnabled public String templateId                           {get;set;}
        @AuraEnabled public List<TemplateSetting> templateSettings      {get;set;}
//        @AuraEnabled public String type                                 {get;set;}      // 1: 광고성 , 2: 정보성
//        @AuraEnabled public String arsPhone                             {get;set;}      // 080 수신거부 번호
        // 본문 관련
        @AuraEnabled public String title                                {get;set;}
        @AuraEnabled public String content                              {get;set;}
        @AuraEnabled public Integer contentLength                       {get;set;}
        @AuraEnabled public List<FileData> files                        {get;set;}
//        @AuraEnabled public Boolean scheduled                           {get;set;}
//        @AuraEnabled public Datetime scheduledTime                      {get;set;}

        public RequestData(){
            this.receiverIds        = new List<String>();
            this.templateSettings   = new List<TemplateSetting>();
            this.files              = new List<FileData>();
            this.specificReceivers  = new List<Receiver>();
        }
//        public RequestData(String recordId){
//            if( i2SEMA_Util.isNotEmpty(recordId)){
//                this.recordId       = recordId;
//                this.recordType     = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
//            }
//            this.receiverIds        = new List<String>();
//            this.templateSettings   = new List<TemplateSetting>();
//            this.files              = new List<FileData>();
//            this.specificReceivers  = new List<Receiver>();
//        }

//        public Boolean hasEmptyProperty(){
//            Boolean requiredFieldEmpty = i2SEMA_Util.isEmpty(this.channel) || i2SEMA_Util.isEmpty(this.receiverOption) || i2SEMA_Util.isEmpty(this.content)
//                    || (i2SEMA_Util.isEmpty(this.type) || ('1'.equals(this.type) && i2SEMA_Util.isEmpty(this.arsPhone)))
//                    || (this.scheduled == true && i2SEMA_Util.isEmpty(this.scheduledTime));
//            Boolean receiverFieldEmpty = (this.receiverOption == Label.i2SEMA_LAB_CURRENT_RECORD && i2SEMA_Util.isEmpty(this.recordId))
//                    || (this.receiverOption == Label.i2SEMA_LAB_RELATED_RECORD && i2SEMA_Util.isEmpty(this.receiverType))
//                    || (this.receiverOption == Label.i2SEMA_LAB_REFERENCE_FIELD && i2SEMA_Util.isEmpty(this.referenceField))
//                    || (this.receiverOption == Label.i2SEMA_LAB_SPECIFIC_RECORD && i2SEMA_Util.isEmpty(this.specificReceivers));
//
//            return requiredFieldEmpty || receiverFieldEmpty;
//        }

    }

    public class Receiver {
        @AuraEnabled public String Id               {get;set;}
    }

    public class TemplateOption {
//        @AuraEnabled public List<Option> wholeSObjectTypes                  {get;set;}      // 현재 레코드와 모든 수신자 SObject 타입
//        @AuraEnabled public List<Option> availableSObjectTypes              {get;set;}      // 현재 레코드 + 선택된 수신자 SObject 타입
//        @AuraEnabled public Map<String,List<Option>> wholeSObjectFields     {get;set;}      // SObject 타입별 필드목록 (현재 Record, 수신자 타입 > Template Label 설정용도)
//        @AuraEnabled public List<Option> availableSObjectFields             {get;set;}      // 선택된 SObject 의 필드목록

//        public TemplateOption(){
//            this.wholeSObjectTypes      = new List<Option>();
//            this.availableSObjectTypes  = new List<Option>();
//            this.wholeSObjectFields     = new Map<String,List<Option>>();
//            this.availableSObjectFields = new List<Option>();
//        }
    }

    public class TemplateSetting {
        @AuraEnabled public String label                    {get;set;}
//        @AuraEnabled public String sObjectType              {get;set;}
//        @AuraEnabled public String sObjectField             {get;set;}
        @AuraEnabled public TemplateOption templateOption   {get;set;}

//        public TemplateSetting(){}
//        public TemplateSetting(String label, TemplateOption templateOption){
//            this.label          = label;
//            this.templateOption = templateOption;
//        }
    }

    public class FileData {
        @AuraEnabled public String fileName         {get;set;}
//        @AuraEnabled public String blobData         {get;set;}
    }
    public class Option {
        @AuraEnabled public String label            {get;set;}
        @AuraEnabled public String value            {get;set;}

//        public Option(){}
//        public Option( String label, String value ){
//            this.label = label;
//            this.value = value;
//        }
    }
}