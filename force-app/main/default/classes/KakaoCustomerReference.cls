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
public class KakaoCustomerReference {
    public class Last_reference {
        public String extra { get; set; }
        public String bot { get; set; }
        public String bot_event { get; set; }
        public String created_at { get; set; }

        public Last_reference(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'extra') {
                            extra = parser.getText();
                        } else if (text == 'bot') {
                            bot = parser.getText();
                        } else if (text == 'bot_event') {
                            bot_event = parser.getText();
                        } else if (text == 'created_at') {
                            created_at = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Last_reference consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Reference {
        public String extra { get; set; }
        public String text { get; set; }
        public String lastText { get; set; }
        public String lastTextDate { get; set; }
        public String appUserId { get; set; }

        public Reference(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'extra') {
                            extra = parser.getText();
                        } else if (text == 'text') {
                            text = parser.getText();
                        } else if (text == 'lastText') {
                            lastText = parser.getText();
                        } else if (text == 'lastTextDate') {
                            lastTextDate = parser.getText();
                        } else if (text == 'appUserId') {
                            appUserId = parser.getDecimalValue().toPlainString();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Reference consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public String user_key { get; set; }
    public String sender_key { get; set; }
    public String app_user_id { get; set; }
    public Double time_Z { get; set; } // in json: time
    public Reference reference { get; set; }
    public Last_reference last_reference { get; set; }

    public KakaoCustomerReference(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'user_key') {
                        user_key = parser.getText();
                    } else if (text == 'sender_key') {
                        sender_key = parser.getText();
                    } else if (text == 'app_user_id') {
                        app_user_id = parser.getDecimalValue().toPlainString();
                    } else if (text == 'time') {
                        time_Z = parser.getDoubleValue();
                    } else if (text == 'reference') {
                        reference = new Reference(parser);
                    } else if (text == 'last_reference') {
                        last_reference = new Last_reference(parser);
                    } else {
                        System.debug(
                            LoggingLevel.WARN,
                            'KakaoCustomerReference consuming unrecognized property: ' + text
                        );
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public static KakaoCustomerReference parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new KakaoCustomerReference(parser);
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