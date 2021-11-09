/**
 * Created by MS on 2021-02-19.
 */

trigger KDCE_OrderTrigger on KDCE_Order__c (before insert, before update, before delete, after insert, after update, after delete) {
    new KDCE_Order_tr().run();
}