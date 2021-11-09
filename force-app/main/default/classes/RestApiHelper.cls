/**
 * @description       : Rest Api call helper
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-05-2021   Obidjon   Initial Version
 **/
public virtual with sharing class RestApiHelper {
    public enum RestMethod {
        GET,
        POST,
        PUT,
        PATCH,
        DEL
    }

    @testVisible
    private static Map<String, String> defaultHeaders = new Map<String, String>{
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
    };

    @testVisible
    protected String namedCredentialName { get; set; }

    public RestApiHelper(String namedCredentialName) {
        this.namedCredentialName = namedCredentialName;
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected RestApiHelper() {
    }

    @testVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    protected HttpResponse makeApiCall(
        RestMethod method,
        String path,
        String query,
        Map<String, Object> bodyMap,
        Map<String, String> headers,
        String userKey
    ) {
        KakaoConsultDealerCredentials__c dealerCredentials = KakaoConsultDealerCredentials__c.getOrgDefaults();
        String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');

        HttpRequest apiRequest = new HttpRequest();
        if (method == RestMethod.PATCH) {
            method = RestMethod.POST;
            encodedQuery += '?_HttpMethod=PATCH';
        } else if (method == RestMethod.DEL) {
            apiRequest.setMethod('DELETE');
        } else {
            apiRequest.setMethod(String.valueOf(method));
        }
        Map<String, String> functionalHeaders = (headers != null) ? headers : RestApiHelper.defaultHeaders;

        functionalHeaders.put('X-UserKey', userKey);
        functionalHeaders.put('X-SenderKey', dealerCredentials.Sender_Key__c);
        functionalHeaders.put('X-JwtToken', dealerCredentials.JWT_Token__c);
        for (String header : functionalHeaders.keySet()) {
            apiRequest.setHeader(header, functionalHeaders.get(header));
        }
        if (bodyMap != null && (method == RestMethod.POST || method == RestMethod.PUT || method == RestMethod.PATCH)) {
            bodyMap.put('sender_key', dealerCredentials.Sender_Key__c);
            bodyMap.put('user_key', userKey);
            String body = JSON.serialize(bodyMap);
            apiRequest.setBody(body);
        }
        apiRequest.setEndpoint(path + encodedQuery);
        System.debug(apiRequest);
        System.debug(apiRequest.getBody());
        Http http = new Http();
        HttpResponse toReturn = http.send(apiRequest);
        return toReturn;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static HttpResponse makeApiCall(
        String namedCredential,
        RestMethod method,
        String path,
        Map<String, Object> bodyMap,
        Map<String, String> headers,
        String userKey
    ) {
        return new RestApiHelper(namedCredential).makeApiCall(method, path, '', bodyMap, headers, userKey);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static HttpResponse makeApiCall(
        String namedCredential,
        RestMethod method,
        String path,
        Map<String, Object> bodyMap,
        String userKey
    ) {
        return new RestApiHelper(namedCredential).makeApiCall(method, path, '', bodyMap, null, userKey);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static HttpResponse makeApiCall(
        String namedCredential,
        RestMethod method,
        String path,
        String query,
        Map<String, Object> bodyMap,
        Map<String, String> headers,
        String userKey
    ) {
        return new RestApiHelper(namedCredential).makeApiCall(method, path, query, bodyMap, headers, userKey);
    }

    // @SuppressWarnings('PMD.ExcessiveParameterList')
    // public static HttpResponse makeApiCall(
    //     String namedCredential,
    //     RestMethod method,
    //     String path,
    //     String query,
    //     String userKey
    // ) {
    //     return new RestApiHelper(namedCredential)
    //         .makeApiCall(method, path, query, null, RestApiHelper.defaultHeaders, userKey);
    // }
}