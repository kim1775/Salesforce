/**
 * Created by MS on 2021-07-28.
 */

trigger KDCE_QualtricsResponseTrigger on KDCE_QualtricsResponse__c (before insert, before update) {
    new KDCE_QualtricsResponse_tr().run();
}