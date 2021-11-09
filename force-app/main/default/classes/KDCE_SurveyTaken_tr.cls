/****************************************************************************************
  * @filename      : KDCE_SurveyTaken_tr
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-05-06 오후 2:35
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
    0.1     2021-05-06 오후 2:35     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_SurveyTaken_tr extends TriggerHandler {

    public override void beforeInsert() {
    }

    public override void afterInsert() {
        updateContactWhenResponse();    // 서베이 답변시, Contact 서베이 답변 일자 업데이트
    }


    /**
     * 서베이 답변시, Contact 서베이 답변 일자 업데이트
     */
    private void updateContactWhenResponse() {
        Map<Id, Datetime> createDateByContact = new Map<Id, Datetime>();
        for (SurveyTaker__c survey : (List<SurveyTaker__c>) Trigger.new) {
            if (createDateByContact.containsKey(survey.Contact__c)) {
                if (survey.CreatedDate > createDateByContact.get(survey.Contact__c)) createDateByContact.put(survey.Contact__c, survey.CreatedDate);
            }
            else createDateByContact.put(survey.Contact__c, survey.CreatedDate);
        }
        System.debug('=== createDateByContact : ' + createDateByContact);

        Map<Id, Contact> updateContact = new Map<Id, Contact>();
        for (Contact contact : [SELECT Id, KDCE_LastCRMResponseDate__c FROM Contact WHERE Id IN :createDateByContact.keySet()]) {
            updateContact.put(Contact.Id, new Contact(
                    Id = contact.Id,
                    KDCE_LastCRMResponseDate__c = createDateByContact.get(contact.Id)
            ));
        }
        System.debug('=== updateContact : ' + updateContact);

        if (!updateContact.isEmpty()) update updateContact.values();
    }
}