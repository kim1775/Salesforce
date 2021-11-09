/****************************************************************************************
  * @filename      : KDCE_QualtricsResponse_tr
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-07-28
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-07-28             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_QualtricsResponse_tr extends TriggerHandler{
    public override void beforeInsert() {
        mappingContact();
    }
    public override void beforeUpdate() {
        mappingContact();
    }

    private void mappingContact(){
        Set<String> contExt = new Set<String>();
        for(KDCE_QualtricsResponse__c item : (List<KDCE_QualtricsResponse__c>)Trigger.new){
            if(item.Consumer_ID__c <> null )    contExt.add(item.Consumer_ID__c);
        }

        Map<String, Contact> contactMap = new Map<String, Contact>();
        for(Contact contact : [ SELECT Id, KDCE_ExternalId__c, KDCE_LastNPSResponseDate__c
                                FROM Contact
                                WHERE KDCE_ExternalId__c IN : contExt]){
            contactMap.put(contact.KDCE_ExternalId__c, contact);
        }

        Contact tempContact;
        List<Contact> updateContacts = new List<Contact>();
        Map<String, String> recordDateByIdMap = new Map<String, String>();
        String tempDate;

        for(KDCE_QualtricsResponse__c item : (List<KDCE_QualtricsResponse__c>)Trigger.new){
            tempContact = contactMap?.get(item.Consumer_ID__c);
            if(tempContact <> null){
                item.Contact__c = tempContact.Id;

                if(recordDateByIdMap.containsKey(item.Consumer_ID__c)){
                    // 이전 recordDate 가져오기
                    tempDate = recordDateByIdMap.get(item.Consumer_ID__c);

                    //이전 recordDate가 더 최신이면 continue, 현재 item이 더 최신이면 map 덮어쓰기
                    if(tempDate > item.recordeddate__c){
                        continue;
                    }else{
                        recordDateByIdMap.put(item.Consumer_ID__c, item.recordeddate__c);
                    }
                }
                else{
                    recordDateByIdMap.put(item.Consumer_ID__c, item.recordeddate__c);
                }
            }
        }

        for(String externalId : recordDateByIdMap.keySet()){
            tempContact = contactMap?.get(externalId);
            if(tempContact <> null){
                tempContact.KDCE_LastNPSResponseDate__c = yyyy_mm_dd_T_hh_mm_ssToDateTimeGmt(recordDateByIdMap.get(externalId));
                updateContacts.add(tempContact);
            }

        }

        if(! updateContacts.isEmpty()) update updateContacts;
    }

    private static Datetime yyyy_mm_dd_T_hh_mm_ssToDateTimeGmt(String d) {
        if (d.length() != 28 && d.length() != 24) return null;
        List<String> result = d.split('T')[0].split('-');
        Integer year = Integer.valueOf(result[0].substring(0, 4));
        Integer month = Integer.valueOf(result[1].substring(0, 2));
        Integer day = Integer.valueOf(result[2].substring(0, 2));

        List<String> hms = d.split('T')[1].substring(0, 8).split(':');
        Integer h = Integer.valueOf(hms[0]);
        Integer m = Integer.valueOf(hms[1]);
        Integer s = Integer.valueOf(hms[2]);

        return Datetime.newInstanceGmt(year, month, day, h, m, s);
    }
}