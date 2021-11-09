/****************************************************************************************
 * @filename      : KDCE_C360Controller
 * @projectname   : 
 * @author        : Donghu
 * @date          : 2021-04-28
 * @group         :
 * @group-content :
 * @description   :
 * @tester        : KDCE_C360Controller_ts
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1      2021-04-28                  Donghu          Create
 ****************************************************************************************/
public with sharing class KDCE_C360Controller {
    /**
        * @description C360 View
        * @param recordId (String)
        * @return response (KDCE_ComponentResponse)
        **/
    @AuraEnabled
    public static KDCE_ComponentResponse getContact(String recordId) {
        KDCE_ComponentResponse response = new KDCE_ComponentResponse();

        Contact contact;
        List<Contact> contactList = [
                SELECT Name,Phone,KDCE_fm_ConsumerType__c,KDCE_LASLAU__c,KDCE_ExternalId__c,Birthdate,Email,CCR_CarePlusStatus__c,KDCE_RentalConsumer__c,KDCE_MarketingOptIn__c,KDCE_KakaoId__c,KDCE_IqosON__c,KDCE_IqosUP__c,KDCE_MGMCode__c,CCR_ConsumerUID__c,CCR_AgeVerificationStatus__c,CCR_SmokerNew__c,CCR_SoftAgeVerifiedNew__c, KDCE_fm_POS_BirthdateMask__c
                FROM Contact
                WHERE Id = :recordId
                LIMIT 1
        ];
        contact = contactList[0];
        response.setData('contact', contact);

        if (contact.KDCE_RentalConsumer__c) {
            KDCE_OfflineProgram__c[] offlineRental = [
                    SELECT RentalStartDate__c, RentalEndDate__c
                    FROM KDCE_OfflineProgram__c
                    WHERE Contact__c = :recordId
                    AND Status__c =: KDCE_GlobalValue.OFF_PG_STATUS_RTNPROCESS
                    //ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            KDCE_Order__c[] onlineRental = [
                    SELECT RentalStartDate__c, RentalEndDate__c
                    FROM KDCE_Order__c
                    WHERE Contact__c = :recordId
                    AND OrderType__c = :KDCE_GlobalValue.ORDER_TYPE_RENTAL
                    AND RentalStatus__c = :KDCE_GlobalValue.ORDER_RNTSTATUS_RENTAL
                    LIMIT 1
            ];

            if(!offlineRental.isEmpty())    response.setData('offlineRental', offlineRental[0]);
            if(!onlineRental.isEmpty())     response.setData('onlineRental', onlineRental[0]);
        }

        System.debug('response :: ' + response);
        return response;
    }
}