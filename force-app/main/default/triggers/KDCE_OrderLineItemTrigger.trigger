/**
 * Created by MS on 2021-02-22.
 */

trigger KDCE_OrderLineItemTrigger on KDCE_OrderLineItem__c (before insert, before update, before delete, after insert, after update, after delete) {
    new KDCE_OrderLineItem_tr().run();
}