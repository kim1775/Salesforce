/**
 * @description       :
 * @author            : Obidjon
 * @group             :
 * @last modified on  : 04-25-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-25-2021   Obidjon   Initial Version
 **/
public class KakaoConsult_JWT {
    private String alg;
    private String typ;
    private String jwtToken;
    private String signingKey;

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public KakaoConsult_JWT(String alg, String typ, String jwtToken, String signingKey) {
        this.alg = alg;
        this.typ = typ;
        this.jwtToken = jwtToken;
        this.signingKey = signingKey;
    }

    public Boolean verify(String headerSignature) {
        String jwt = '';

        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('typ', this.typ);
        header.writeStringField('alg', this.alg);
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));

        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('jwtToken', this.jwtToken);
        body.writeEndObject();

        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        Blob signature = Crypto.generateMac('hmacSHA256', Blob.valueof(jwt), Blob.valueOf(signingKey));
        jwt += '.' + base64URLencode(signature);
        return jwt == headerSignature;
    }

    private String base64URLencode(Blob input) {
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.subString(0, output.length() - 1);
        }
        return output;
    }
}