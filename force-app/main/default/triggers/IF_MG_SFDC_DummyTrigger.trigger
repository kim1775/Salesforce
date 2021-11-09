/**
 * Created by MS on 2021-05-20.
 */

trigger IF_MG_SFDC_DummyTrigger on IF_MG_SFDC_Dummy__c (before insert, before update, after insert, after update) {
    new IF_MG_SFDC_Dummy_tr().run();
}