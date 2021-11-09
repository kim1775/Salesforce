/**
 * @description       : Callout Utils for Mock
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-23-2021   Obidjon   Initial Version
 **/
@isTest
public class CalloutUtilsMock implements HttpCalloutMock {
    private Map<String, String> headers;
    private String body;
    private Integer statusCode;

    public CalloutUtilsMock(Map<String, String> headers, String body, Integer statusCode) {
        this.headers = headers;
        this.body = body;
        this.statusCode = statusCode;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        for (String key : headers.keySet()) {
            res.setHeader(key, headers.get(key));
        }
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}