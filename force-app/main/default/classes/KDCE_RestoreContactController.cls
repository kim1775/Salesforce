/****************************************************************************************
  * @filename      : KDCE_RestoreContactController
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-29 오후 3:26
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
    0.1     2021-04-29 오후 3:26     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_RestoreContactController {

    // Contact 휴면 계정 복원 (IsDormant true -> false)
    @AuraEnabled
    public static void convertDormant(Id recordId) {
        System.debug('=== convertDormant : ');
        KDCE_DormantContact__c dormantContact = [SELECT Id, ContactId__c FROM KDCE_DormantContact__c WHERE Id = :recordId];
        String contactId = dormantContact.ContactId__c;

        List<Contact> contactList = [SELECT Id, KDCE_IsDormant__c FROM Contact WHERE Id = :dormantContact.ContactId__c];
        for (Contact con : contactList) {
            con.KDCE_IsDormant__c = false;
        }
        System.debug('=== contactList : ' + contactList);
        update contactList;

        String url = '/lightning/r/Contact/' + contactId + '/view';
        ApexPages.PageReference redirectPage = new PageReference(url);
        aura.redirect(redirectPage);
    }


}