/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 07-14-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   06-03-2021   Obidjon   Initial Version
 **/
@RestResource(urlMapping='/reference')
global without sharing class InboundReferenceRestService {
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @HttpPost
    global static void doPostReference() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        System.debug('REQUEST: ' + request.requestBody.toString());
        KakaoCustomerReference customerReference = KakaoCustomerReference.parse(request.requestBody.toString());

        KakaoConsultDealerCredentials__c dealerCredentials = KakaoConsultDealerCredentials__c.getOrgDefaults();
        String jwtToken = dealerCredentials.JWT_Token__c;
        String secret = dealerCredentials.Channel_Secret__c;
        String headerSignature = request.headers.get('X-Signature');

        KakaoConsult_JWT jwt = new KakaoConsult_JWT('HS256', 'JWT', jwtToken, secret);
        if (!Test.isRunningTest() && !jwt.verify(headerSignature)) {
            response.statusCode = 401;
            return;
        }

        Kakao_User_Mapping__c userMapping = new Kakao_User_Mapping__c();
        if (String.isNotBlank(customerReference.app_user_id)) {
            userMapping.App_User_Id__c = customerReference.app_user_id;
            userMapping.User_Key__c = customerReference.user_key;

            upsert userMapping Kakao_User_Mapping__c.App_User_Id__c;
        }

        response.statusCode = 200;
    }
}