/**
 * @description       : Customer Identity link response rest service
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 07-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-12-2021   Obidjon   Initial Version
 **/

@RestResource(urlMapping='/kakaoConsultCustomerIdentify')
global without sharing class KakaoConsultCustomerIdentify {
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @HttpPost
    global static void doPostCustomerInformation() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String requestBody = request.requestBody.toString();
        KakaoConsultCustomerInformation customerInformation = KakaoConsultCustomerInformation.parse(requestBody);

        Case kakaoCase = [SELECT Id FROM Case WHERE Id = :customerInformation.cid];
        Contact contact;
        try {
            contact = [
                SELECT Id
                FROM Contact
                WHERE KDCE_Name__c = :customerInformation.lastName.trim() AND Phone = :customerInformation.phone
                LIMIT 1
            ];
            kakaoCase.ContactId = contact.Id;
        } catch (QueryException e) {
            contact = new Contact();
            contact.LastName = customerInformation.lastName;
            contact.Phone = customerInformation.phone;
            contact.Email = customerInformation.email;
            // if (String.isNotBlank(customerInformation.birthdate)) {
            //     List<String> birthdates = customerInformation.birthdate.split('-');
            //     contact.Birthdate = Date.newInstance(
            //         Integer.valueOf(birthdates[0]),
            //         Integer.valueOf(birthdates[1]),
            //         Integer.valueOf(birthdates[2])
            //     );
            // }
            insert contact;
            kakaoCase.ContactId = contact.id;
        }

        update kakaoCase;
        Kakao_Consult_Chat__c kakaoChat = [
            SELECT Id, User_Key__c
            FROM Kakao_Consult_Chat__c
            WHERE Case__c = :kakaoCase.Id
            LIMIT 1
        ];
        Kakao_User_Mapping__c kakaoUserMapping = new Kakao_User_Mapping__c();
        kakaoUserMapping.User_Key__c = kakaoChat.User_Key__c;
        kakaoUserMapping.Contact__c = contact.Id;
        Database.upsert(kakaoUserMapping, Kakao_User_Mapping__c.User_Key__c);

        response.statusCode = 200;
    }
}