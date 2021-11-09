/**
 * @description       : Model for Inbound message
 * @author            : Obidjon
 * @group             : Kakao Consult Chat
 * @last modified on  : 04-23-2021
 * @last modified by  : Obidjon
 * Modifications Log
 * Ver   Date         Author    Modification
 * 1.0   04-05-2021   Obidjon   Initial Version
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.CognitiveComplexity,PMD.ExcessivePublicCount')
public with sharing class InboundMessage {
    public String user_key { get; set; }
    public String sender_key { get; set; }
    public Long time_Z { get; set; } // in json: time
    public String serial_number { get; set; }
    public String type { get; set; }
    public String content { get; set; }
    public Attachment attachment { get; set; }
    public UrlContent urlContent { get; set; }
    public String extra { get; set; }

    private static String typeValue;

    @SuppressWarnings('PMD.NcssConstructorCount')
    public InboundMessage(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'user_key') {
                        user_key = parser.getText();
                    } else if (text == 'sender_key') {
                        sender_key = parser.getText();
                    } else if (text == 'time') {
                        time_Z = parser.getLongValue();
                    } else if (text == 'serial_number') {
                        serial_number = parser.getText();
                    } else if (text == 'type') {
                        type = parser.getText();
                        typeValue = parser.getText();
                    } else if (text == 'content' && typeValue == 'text') {
                        content = parser.getText();
                    } else if (text == 'content' && typeValue != 'text') {
                        urlContent = new UrlContent(parser);
                    } else if (text == 'attachment') {
                        attachment = new Attachment(parser);
                    } else if (text == 'extra') {
                        extra = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'InboundMessage consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Attachment {
        public String url { get; set; }

        public Attachment(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'url') {
                            url = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Attachment consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class UrlContent {
        public String url { get; set; }

        public UrlContent(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'url') {
                            url = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Attachment consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public static InboundMessage parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new InboundMessage(parser);
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