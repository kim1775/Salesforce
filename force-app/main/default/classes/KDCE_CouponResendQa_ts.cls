/****************************************************************************************
 * @filename      : KDCE_CouponResendQa_ts
 * @projectname   : PMK Local DCE
 * @author        : i2max_ehlee 
 * @date          : 2021-05-03 오후 1:01
 * @group         : Service 
 * @group-content :
 * @description   : 
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2021-05-03 오후 1:01      i2max_ehlee          Create
 ****************************************************************************************/

@IsTest
public with sharing class KDCE_CouponResendQa_ts {
    @TestSetup
    static void setData(){
        NotificationTemplate__c notificationTemplate = i2SEMA_TestDataUtil.getMMSTemplate();
        notificationTemplate.Title__c = '1.GetInfo Test';
        update notificationTemplate;

        NotificationTemplate__c n1 =notificationTemplate.clone(false);
        n1.LABEL2__c = false;
        n1.LABEL3__c = false;
        n1.Title__c = '2.MGM Test';

        NotificationTemplate__c n2 =notificationTemplate.clone(false);
        n2.LABEL2__c = true;
        n2.LABEL3__c = true;
        n2.LABEL4__c = true;
        n2.Title__c = '3.CVS Test';
        n2.Content__c = '%%LABEL1%% %%LABEL2%% %%LABEL3%% %%LABEL4%%';

        List<NotificationTemplate__c> notificationTemplates = new List<NotificationTemplate__c>();
        notificationTemplates.add(n1);
        notificationTemplates.add(n2);
        insert notificationTemplates;

        System.debug('notification template: '+notificationTemplate);
    }
    static {
    }

    static testMethod void couponResendTest(){
        Test.startTest();

//        KDCE_Coupon__c resendingCoupon = [SELECT Id FROM KDCE_Coupon__c WHERE RecordTypeId =: KDCE_TestUtil.getRecordTypeId('KDCE_Coupon__c', 'Coupon_MGM') LIMIT 1];
        KDCE_Coupon__c resendingCoupon = KDCE_TestBizUtil.coupon.clone(true);
        resendingCoupon.Type__c = 'GetInfo';
        resendingCoupon.Contact__c = KDCE_TestUtil.contactMember.Id;
        resendingCoupon.CouponCode__c = 'GetInfo_couponCodeTest00';
        update resendingCoupon;

        KDCE_TestUtil.contactMember.KDCE_MarketingOptInDate__c = System.today();
        update KDCE_TestUtil.contactMember;

        KDCE_Coupon__c resendingCoupon2 = resendingCoupon.clone(false);
        resendingCoupon2.Type__c = 'MGM';
        resendingCoupon2.CouponCode__c = 'MGM_couponCodeTest01';
        insert resendingCoupon2;

        KDCE_Coupon__c resendingCoupon3 = resendingCoupon.clone(false);
        resendingCoupon3.Type__c = 'CVS';
        resendingCoupon3.CouponCode__c = 'CVS_couponCodeTest01';
        resendingCoupon3.ChannelDetails__c = 'CU';
        resendingCoupon3.ExpiryDate__c = System.today();
        insert resendingCoupon3;

        System.debug(resendingCoupon);
        System.debug(resendingCoupon2);
        System.debug(resendingCoupon3);

        List<NotificationTemplate__c> notificationTemplate = [SELECT Id FROM NotificationTemplate__c ORDER BY Title__c];
        system.debug('=== notificationTemplate : ' + notificationTemplate);

        KDCE_CouponResendQa.RequestData testClass = new KDCE_CouponResendQa.RequestData();
//        KDCE_CouponResendQa.testNotificationTemplateId = notificationTemplate.Id;
        testClass.templateId = notificationTemplate[0].Id;
        KDCE_CouponResendQa.init(resendingCoupon.Id);
        KDCE_CouponResendQa.save(resendingCoupon.Id, testClass);

        testClass.templateId = notificationTemplate[1].Id;
        KDCE_CouponResendQa.init(resendingCoupon2.Id);
        KDCE_CouponResendQa.save(resendingCoupon2.Id, testClass);

        testClass.templateId = notificationTemplate[2].Id;
        KDCE_CouponResendQa.init(resendingCoupon3.Id);
        KDCE_CouponResendQa.save(resendingCoupon3.Id, testClass);

        Test.stopTest();
    }

//    public static boolean updateCustomLabel(string csname,string description,string language,string value, boolean isProtected){
//        List<Metadata> allMetadataList = new List<Metadata>();
//        Metadata.CustomMetadataValue
//        MetadataService.MetadataPort service = createService();
//        MetadataService.CustomLabel csLabel = new MetadataService.CustomLabel();
//        csLabel.fullName = csname;
//        csLabel.language = language;
//        csLabel.protected_x  = isProtected;
//        csLabel.shortDescription  = description;
//        csLabel.value=value;
//        allMetadataList.add(csLabel);
//        List<MetadataService.SaveResult> results = service.updateMetadata(allMetadataList);
//        for(MetadataService.SaveResult result: results){
//            system.debug('update custom label results success='+result.success);
//        }
//        return results[0].success;
//    }
}