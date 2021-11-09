/****************************************************************************************
 * @filename      : KDCE_CouponResendQa
 * @projectname   : PMK Local DCE QA
 * @author        : i2max_Sukun
 * @date          : 4/9/21 1:45 PM
 * @group         : Service
 * @group-content :
 * @description   : Server-Side Controller for KDCE_CouponResendQa Component.
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     4/9/21 1:45 PM            i2max_Sukun           Create
 ****************************************************************************************/
public with sharing class KDCE_CouponResendQa {

    //     재전송 쿠폰 Template External Id
    private static final String TEMPLATE_EXTERNAL_ID = System.Label.KDCE_CPN_TEMPLT_RESEND;
    private static final String CVS_TEMPL       = System.Label.KDCE_NotificationTemplate_Coupon_CVS;
    private static final String GETINFO_TEMPL   = System.Label.KDCE_NotificationTemplate_Coupon_GetInfo;
    private static final String MGM_TEMPL       = System.Label.KDCE_NotificationTemplate_Coupon_MGM;
    //public static String testNotificationTemplateId;

    private static Map<String, String> pvMap_Coupon_channel = KDCE_Util.getPicklistValue('KDCE_Coupon__c', 'ChannelDetails__c');


    /**
    * init
    * @param recordId
    * @return KDCE_ComponentResponse 
    */
    @AuraEnabled
    public static KDCE_ComponentResponse init(String recordId) {
        system.debug('[KDCE_CouponResendQa] - initialize');
        KDCE_ComponentResponse response = new KDCE_ComponentResponse();

        System.debug('initialize recordId : ' + recordId); // template notification이 아닌, Coupon 의 record Id

        // Ref, Req Data
        ReferenceData refData = new ReferenceData(recordId);
        RequestData reqData = new RequestData(recordId);

        // Notification Template External Id 하드코딩
        //NotificationTemplate__c notificationTemplate = !Test.isRunningTest() ? [SELECT Id, Content__c FROM NotificationTemplate__c WHERE KDCE_ExternalId__c = :TEMPLATE_EXTERNAL_ID LIMIT 1] :
         //       [SELECT Id, Content__c FROM NotificationTemplate__c WHERE Id =:testNotificationTemplateId];

        KDCE_Coupon__c currentCouponInfo = [
                SELECT Id, CouponCode__c, ExpiryDate__c, Contact__c, Contact__r.KDCE_Name__c, Contact__r.KDCE_PNKey__c, Type__c, ChannelDetails__c,
                        Contact__r.KDCE_MarketingOptInDate__c, IsAvailable__c
                FROM KDCE_Coupon__c
                WHERE Id = :recordId LIMIT 1];

        String templateExtId = currentCouponInfo.Type__c == KDCE_GlobalValue.COUPON_TYPE_CVS ? CVS_TEMPL : currentCouponInfo.Type__c == KDCE_GlobalValue.COUPON_TYPE_GETINFO ? GETINFO_TEMPL :
                currentCouponInfo.Type__c == KDCE_GlobalValue.COUPON_TYPE_MGM ? MGM_TEMPL :null;
        NotificationTemplate__c notificationTemplate;
        System.debug('templateExtId' + templateExtId);
        if(templateExtId <> null && !Test.isRunningTest())
        notificationTemplate = [
                SELECT Id, Content__c, KDCE_ExternalId__c FROM NotificationTemplate__c WHERE KDCE_ExternalId__c = :templateExtId LIMIT 1
        ];
        if(Test.isRunningTest())  notificationTemplate = [SELECT Id, Content__c, KDCE_ExternalId__c FROM NotificationTemplate__c Limit 1];

        System.debug('notificationTemplate ' + notificationTemplate);

        try {

            if(currentCouponInfo.Type__c == KDCE_GlobalValue.COUPON_TYPE_CVS) {
                String displayText = notificationTemplate.Content__c;
                displayText = displayText.replace('%%LABEL1%%', currentCouponInfo.Contact__r ?.KDCE_Name__c);
                displayText = displayText.replace('%%LABEL2%%', pvMap_Coupon_channel?.get(currentCouponInfo ?.ChannelDetails__c)); // 구입처 참조 가능시 변경
                displayText = displayText.replace('%%LABEL3%%', currentCouponInfo ?.CouponCode__c);
                if (currentCouponInfo.ExpiryDate__c != null) {
                    displayText = displayText.replace('%%LABEL4%%', '~' + currentCouponInfo.ExpiryDate__c);
                    reqData.notification.LABEL4__c = String.valueOf(currentCouponInfo ?.ExpiryDate__c);
                } else {
                    displayText = displayText.replace('%%LABEL4%%', '');
                    reqData.notification.LABEL4__c = '';

                }
                System.debug(displayText);
                // set ReferenceData
                refData.content = displayText;
                // set default RequestData
                reqData.rawContent = displayText;
                reqData.templateId = notificationTemplate.Id;
                reqData.contactId = currentCouponInfo.Contact__c;
                reqData.notification.LABEL1__c = currentCouponInfo.Contact__r ?.KDCE_Name__c;
                reqData.notification.LABEL2__c =  pvMap_Coupon_channel?.get(currentCouponInfo ?.ChannelDetails__c); //currentCouponInfo ?.ChannelDetails__c; //'unknown'; // 구입처 참조 가능시 변경
                reqData.notification.LABEL3__c = currentCouponInfo ?.CouponCode__c;
            }

            else if(currentCouponInfo.Type__c == KDCE_GlobalValue.COUPON_TYPE_GETINFO) {
                String displayText = notificationTemplate.Content__c;
                displayText = displayText.replace('%%LABEL1%%', currentCouponInfo ?.CouponCode__c);
                String expiexpiryD = currentCouponInfo.ExpiryDate__c == null ? '' : String.valueOf(currentCouponInfo.ExpiryDate__c);
                String optInD = currentCouponInfo.Contact__r.KDCE_MarketingOptInDate__c == null ? '' : String.valueOf(currentCouponInfo.Contact__r.KDCE_MarketingOptInDate__c);
                displayText = displayText.replace('%%LABEL2%%', expiexpiryD);
                displayText = displayText.replace('%%LABEL3%%', optInD);

                System.debug('displayText :: ' + displayText);
                // set ReferenceData
                refData.content = displayText;
                // set default RequestData
                reqData.rawContent = displayText;
                reqData.templateId = notificationTemplate.Id;
                reqData.contactId = currentCouponInfo.Contact__c;
                reqData.notification.LABEL1__c = currentCouponInfo ?.CouponCode__c;
                reqData.notification.LABEL2__c =  expiexpiryD;
                reqData.notification.LABEL3__c =  optInD;
            }

            else if(currentCouponInfo.Type__c == KDCE_GlobalValue.COUPON_TYPE_MGM) {
                String displayText = notificationTemplate.Content__c;
                displayText = displayText.replace('%%LABEL1%%', currentCouponInfo ?.CouponCode__c);

                System.debug(displayText);
                // set ReferenceData
                refData.content = displayText;
                // set default RequestData
                reqData.rawContent = displayText;
                reqData.templateId = notificationTemplate.Id;
                reqData.contactId = currentCouponInfo.Contact__c;
                reqData.notification.LABEL1__c = currentCouponInfo ?.CouponCode__c;
            }

        } catch (Exception e) {
            System.debug('Retrieval Failure >> ' + e.getMessage());
        } finally {
            response.setData('refData', refData);
            response.setData('reqData', reqData);
            response.setData('available', currentCouponInfo.IsAvailable__c);
        }

        return response;
    }

    /**
     * save
     * @param recordId
     * @param reqData
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean save(String recordId, Object reqData) {
        System.debug('coupon resend start');
        Boolean allDmlResult = false;

        RequestData requestData = (RequestData)JSON.deserialize(JSON.serialize(reqData), RequestData.class);
        System.debug(requestData);

//        try {
        NotificationGroup__c notificationGroup = new NotificationGroup__c();
        insert notificationGroup;

        NotificationTemplate__c template = [
          SELECT Id, Channel__c, Content__c, Type__c, KDCE_ExternalId__c FROM NotificationTemplate__c WHERE Id = :requestData.templateId LIMIT 1
        ];

        if(Util.isEmpty(template)) throw new AuraHandledException('Template is empty.');

        Notification__c notification = new Notification__c();
        notification.NotificationGroup__c = notificationGroup.Id;
        notification.NotificationTemplate__c = template.Id;
        notification.RawContents__c = template.Content__c;
        notification.Contact__c = requestData.contactId;
        notification.Channel__c = template.Channel__c;
        notification.Type__c = template.Type__c; // 정보성 Noti 타입의 경우

        if (template.KDCE_ExternalId__c == CVS_TEMPL) {
            notification.LABEL1__c = requestData.notification.LABEL1__c;
            notification.LABEL2__c = requestData.notification.LABEL2__c;
            notification.LABEL3__c = requestData.notification.LABEL3__c;
            notification.LABEL4__c = requestData.notification.LABEL4__c;
        }
        else if (template.KDCE_ExternalId__c == GETINFO_TEMPL) {
            notification.LABEL1__c = requestData.notification.LABEL1__c;
            notification.LABEL2__c = requestData.notification.LABEL2__c;
            notification.LABEL3__c = requestData.notification.LABEL3__c;
        }
        else if (template.KDCE_ExternalId__c == MGM_TEMPL) {
            notification.LABEL1__c = requestData.notification.LABEL1__c;
        }

        if (notification <> null) {
            insert notification;
            allDmlResult = TRUE;
        }

        if(!Test.isRunningTest()) {
            i2SEMA_IFNotificationSend_qu messageSendQu = new i2SEMA_IFNotificationSend_qu(notification);
            Id messageSendJobId = System.enqueueJob(messageSendQu);
        }
//        } catch (Exception e) {
//            System.debug('Resend Coupone Notification error >> ' + e.getMessage());
//        }
        System.debug('allDmlResult : '+allDmlResult);
        System.debug('notification : ' + notification);

        return allDmlResult;
    }

    public class ReferenceData {
        @AuraEnabled public String recordId                 { get; set; }
        @AuraEnabled public String content                  { get; set; }

        public ReferenceData() { }
        public ReferenceData(String recordId) {
            this.recordId = recordId;
        }
    }

    public class RequestData {
        @AuraEnabled public String recordId                 { get; set; }
        @AuraEnabled public String templateId               { get; set; }
        @AuraEnabled public String contactId                { get; set; }
        @AuraEnabled public String rawContent               { get; set; }
        @AuraEnabled public Notification__c notification    { get; set; }

        public RequestData() {
            notification = new Notification__c();
        }
        public RequestData(String recordId) {
            this.recordId = recordId;
            notification = new Notification__c();
        }
    }
}