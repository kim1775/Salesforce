/****************************************************************************************
 * @filename      : KDCE_Store_tr
 * @projectname   : 
 * @author        : i2max_SeokHo
 * @date          : 2021-03-03 오후 1:33
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
 0.1     2021-03-03 오후 1:33      i2max_SeokHo         Create
 ****************************************************************************************/

public with sharing class KDCE_Store_tr extends TriggerHandler {

    // Object RecordType Id
    private final static Id RT_Contact_AnonymousId  = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Anonymous').getRecordTypeId();
    private final static Id RT_Contact_MemberId     = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Member').getRecordTypeId();
    private final static Id RT_Store_Direct         = Schema.SObjectType.KDCE_Store__c.getRecordTypeInfosByDeveloperName().get('Store_Direct').getRecordTypeId();
    private final static Id RT_Store_Indirect         = Schema.SObjectType.KDCE_Store__c.getRecordTypeInfosByDeveloperName().get('Store_Indirect').getRecordTypeId();
    private final static Id RT_Store_GetInfo       = Schema.SObjectType.KDCE_Store__c.getRecordTypeInfosByDeveloperName().get('Store_GetInfo').getRecordTypeId();


    public override void beforeInsert() {
        setExtId();
    }

    public override void beforeUpdate() {
        setExtId();
    }

    public override void afterInsert() {
        createContact();    // Store 생성시, Contact 생성
    }


    /**
     * ExtId 생성
     */
    private void setExtId() {
        for (KDCE_Store__c store : (List<KDCE_Store__c>) Trigger.new) {
            if(store.RecordTypeId == RT_Store_GetInfo) store.ExternalId__c = store.CampaignCode__c;
            else store.ExternalId__c = store.BizLOCCode__c;
            //else store.ExternalId__c = store.CompanyCode__c + '_' + store.OrgCode__c;
        }
    }

    /**
     * Store 별로 Anonymous LAU, LAS 생성
     * Fujitsu의 경우 추가로 Rental Dummy Contact 생성  (2021.04.05 이지현)
     */
    private void createContact() {
        System.debug('=== contact생성 : ');
        List<Contact> insertContacts = new List<Contact>();
        Map<Id, Contact> insertContactMap = new Map<Id, Contact>();
        List<Contact> insertContact = new List<Contact>();
        Contact newContact;
        String ExtId;
        Map<String, String> contactLASLAUPickVal = KDCE_Util.getPicklistValue('Contact', 'KDCE_LASLAU__c');

        for (KDCE_Store__c store : (List<KDCE_Store__c>) Trigger.new) {
            System.debug('=== store : ' + store);
            System.debug('=== store.Name : ' + store.Name);
            // 후지쯔의 경우 Rental Dummy Contact 생성
            if (store.RecordTypeId == RT_Store_Direct) {
                // Contact LAS, LAU 생성
                for (String LASLAU : contactLASLAUPickVal.keySet()) {
                    newContact = new Contact(
                            LastName                = store.Name + '(' + LASLAU + ')',
                            KDCE_Store__c           = store.Id,
                            KDCE_LASLAU__c          = LASLAU,
                            RecordTypeId            = RT_Contact_AnonymousId,
                            KDCE_IsStoreContact__c  = true,
                            KDCE_ExternalId__c      = KDCE_Util.getHashString(store.Name + '(' + LASLAU + ')'+RT_Contact_AnonymousId)
                    );
                    insertContact.add(newContact);
                }

                newContact = new Contact(
                        LastName                = store.Name + '(Rental)',
                        KDCE_Store__c           = store.Id,
                        KDCE_LASLAU__c          = 'LAS',
                        RecordTypeId            = RT_Contact_MemberId,
                        KDCE_IsStoreContact__c  = true,
                        KDCE_ExternalId__c      = KDCE_Util.getHashString(store.Name + '(Rental)'+RT_Contact_MemberId)
                );
                insertContact.add(newContact);
            }

        }
        System.debug('insertContact == ' + insertContact);
        if (!insertContact.isEmpty()) insert insertContact;
    }


}