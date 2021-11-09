/****************************************************************************************
  * @filename      : KDCE_ContactSeparateService_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-15 오후 2:31
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
    0.1     2021-06-15 오후 2:31     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_ContactSeparateService_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    private static void testBehavior01() {
        List<SObject> contactList = new List<SObject>();
        List<SObject> caseList = new List<SObject>();
        Set<Id> contactIds = new Set<Id>();
        Contact contact = KDCE_TestUtil.contactMember;
        contactList.add(contact);
        contactIds.add(contact.Id);

        Map<String, Schema.SObjectField> contactSchema = Schema.SObjectType.Contact.fields.getMap();
        Map<String, Schema.SObjectField> caseSchema = Schema.SObjectType.Case.fields.getMap();

        // Null처리하면 안되는 필드 저장
        Set<String> notNullField = new Set<String>{
                'id', 'ownerid', 'accountid', 'kdce_externalid__c', 'kdce_registrationchannel__c', 'kdce_registrationdate__c', 'kdce_registrationobject__c',
                'kdce_isdropout__c', 'kdce_dropoutdate__c', 'kdce_isrequestdropout__c', 'kdce_dropoutrequestdate__c',
                'kdce_isdormant__c', 'kdce_convertdormantdate__c', 'kdce_reactivatedormantdate__c'
        };

        // Contact
        KDCE_ContactSeparateService.separateObject('Dormant', 'Contact', 'KDCE_DormantContact__c', contactList);
        KDCE_ContactSeparateService.setNullField('Dormant', 'Contact', contactList, contactSchema, notNullField, null);
        KDCE_ContactSeparateService.setNullField('DropOut', 'Contact', contactList, contactSchema, notNullField, null);
        KDCE_ContactSeparateService.restoreObject('Contact', 'KDCE_DormantContact__c', contactIds, contactList);

        // Case
        Case case2 = KDCE_TestUtil.caseItem;
        caseList.add(case2);
        KDCE_ContactSeparateService.separateObject('Dormant', 'Case', 'KDCE_DormantCase__c', caseList);
        KDCE_ContactSeparateService.setNullField('Dormant', 'Case', caseList, caseSchema, null, null);
        KDCE_ContactSeparateService.restoreObject('Case', 'KDCE_DormantCase__c', contactIds, contactList);

    }
}