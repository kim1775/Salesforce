/**
 * @description       : Model of customer information from identify link
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 05-20-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-12-2021   Obidjon   Initial Version
 **/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssConstructorCount')
public class KakaoConsultCustomerInformation {
    public String cid { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String phone { get; set; }
    public String birthdate { get; set; }

    public KakaoConsultCustomerInformation(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'cid') {
                        cid = parser.getText();
                    } else if (text == 'lastName') {
                        lastName = parser.getText();
                    } else if (text == 'email') {
                        email = parser.getText();
                    } else if (text == 'phone') {
                        phone = parser.getText();
                    } else if (text == 'birthdate') {
                        birthdate = parser.getText();
                    } else {
                        System.debug(
                            LoggingLevel.WARN,
                            'KakaoConsultCustomerInformation consuming unrecognized property: ' + text
                        );
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public static KakaoConsultCustomerInformation parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new KakaoConsultCustomerInformation(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}