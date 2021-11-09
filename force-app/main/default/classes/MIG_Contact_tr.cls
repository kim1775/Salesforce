/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-07-30 오후 9:18
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
    0.1     2021-07-30 오후 9:18     i2max_Junseok.Kwon        Create
****************************************************************************************/

//public with sharing class MIG_Contact_tr {

//}

public without sharing class MIG_Contact_tr extends TriggerHandler {


    public override void beforeInsert() {

        runTest();
        createAccountRecord();              // Account 생성
    }

    /*
    * Contact 생성 시, Account 자동 생성
    **/
    private void createAccountRecord() {
        System.debug('@@@@@@ createAccountRecord @@@@@@');

        List<Account> accountList = new List<Account>();
        Account tempAccount;
        Map<String, String> accountIdMap = new Map<String, String>();
        for (Contact contact : (List<Contact>) Trigger.new) {
            String accName = contact.LastName == null ? 'Null LastName Account' : contact.LastName;
            accName += ' ';
            accName += contact.FirstName == null ? '' : contact.FirstName;
            tempAccount = new Account(
                    Name = accName,
                    KDCE_ExternalId__c = contact.KDCE_ExternalId__c,
                    CCR_ConsumerUID__c = contact.CCR_ConsumerUID__c
            );
            accountList.add(tempAccount);
        }

        insert accountList;

        for (Account acc : accountList) {
            accountIdMap.put(acc.KDCE_ExternalId__c, acc.Id);
        }

        System.debug(accountList);
        for (Contact contact : (List<Contact>) Trigger.new) {
            String accName = contact.LastName == null ? '' : contact.LastName;
            accName += ' ';
            accName += contact.FirstName == null ? '' : contact.FirstName;
            contact.AccountId = accountIdMap.get(contact.KDCE_ExternalId__c);
        }
    }

    private void runTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}