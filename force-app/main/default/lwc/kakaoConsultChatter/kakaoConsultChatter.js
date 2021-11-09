import { LightningElement, wire, api } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { subscribe, onError } from "lightning/empApi";
import KAKAOCHATFEED_OBJECT from "@salesforce/schema/Kakao_Chat_Feed__c";
import KAKAOCONSULTCHAT_FIELD from "@salesforce/schema/Kakao_Chat_Feed__c.Kakao_Consult_Chat__c";
import MESSAGE_FIELD from "@salesforce/schema/Kakao_Chat_Feed__c.Message__c";
import getKakaoChatFeeds from "@salesforce/apex/KakaoChatFeedController.getKakaoChatFeeds";
import sendTextMessage from "@salesforce/apex/OutboundMessageController.sendTextMessage";
import endSession from "@salesforce/apex/KakaoConsultSessionController.endSession";
import sendIdentifyLink from "@salesforce/apex/KakaoConsultSessionController.sendIdentifyLink";
import getKakaoQuickTexts from "@salesforce/apex/KakaoQuickTextController.getKakaoQuickTexts";

// Import message service features required for publishing and the message channel
import { publish, MessageContext } from "lightning/messageService";
import CONNECTOR_CHANNEL from "@salesforce/messageChannel/lmsConnector__c";

export default class KakaoConsultChatter extends LightningElement {
    @api recordId;
    messages;
    errors;

    kakaoConsultId;
    sessionLive;

    message;
    sendButton;

    wiredMessages;
    _componentInitialized;

    subscription = {};
    isSubscribed = false;

    quickTextMap;
    quickTextList;

    @wire(MessageContext)
    messageContext;

    // Get kakao chat feeds from Apex method
    @wire(getKakaoChatFeeds, { caseId: "$recordId" })
    getMessages(value) {
        this.wiredMessages = value;
        const { data, error } = value;

        const prepends = { Processing: "⌛", Success: "✓" };
        if (data) {
            this.kakaoConsultId = data[0].Kakao_Consult_Chat__c;
            this.sessionLive = data[0].Session_Live_fm__c;
            this.messages = [];
            data.forEach((item) => {
                item = { ...item };
                item.isAgent = item.Sender__c === "Agent";
                item.isCustomer = item.Sender__c === "Customer";
                item.isTextMessage = item.Type__c === "Text";
                item.isImageMessage = item.Type__c === "Image";
                item.isFileMessage = !["Text", "Image"].includes(item.Type__c);
                item.prepend = prepends[item.Status__c];
                this.messages.push(item);
            });
            this.error = undefined;

            // Register customer kakao chat feed event subscriber
            if (!this.isSubscribed) {
                this.registerErrorListener();
                this.handleSubscribe();

                this.isSubscribed = true;
            }
        } else if (error) {
            this.errors = error;
            this.messages = undefined;
        }
    }

    @wire(getKakaoQuickTexts)
    getQuickTextList(value) {
        const { data, error } = value;

        if (data) {
            this.quickTextMap = new Map();
            this.quickTextList = [];
            data.forEach((item) => {
                this.quickTextMap.set(item.Label__c, item.Content__c);
                this.quickTextList.push(item);
            });
            this.error = undefined;
        } else if (error) {
            this.errors = error;
            this.quickTextMap = undefined;
            this.quickTextList = undefined;
        }
    }

    renderedCallback() {
        if (this._componentInitialized) {
            return;
        }
        this._componentInitialized = true;
        this.initComponents();
    }

    initComponents() {
        const sendButton = this.template.querySelector(".send_button");
        const messageInput = this.template.querySelector(".chatroom__input");

        messageInput.addEventListener("keyup", (event) => {
            if (messageInput.value.trim() && this.sessionLive) {
                this.setButtonDisabled(false);
            } else {
                this.setButtonDisabled();
            }
        });

        sendButton.addEventListener("click", (event) => {
            event.stopPropagation();
            event.preventDefault();

            const fields = {};
            fields[KAKAOCONSULTCHAT_FIELD.fieldApiName] = this.kakaoConsultId;
            fields[MESSAGE_FIELD.fieldApiName] = messageInput.value;
            const chatFeed = { apiName: KAKAOCHATFEED_OBJECT.objectApiName, fields };

            // eslint-disable-next-line no-unused-expressions
            messageInput.value.trim() &&
                createRecord(chatFeed)
                    .then((result) => sendTextMessage({ kakaoChatFeedId: result.id }))
                    .then(() => {
                        messageInput.value = "";
                        return refreshApex(this.wiredMessages);
                    })
                    .then(() => {
                        this.scrollChatroomPlace();
                        this.setButtonDisabled();
                    })
                    .catch((error) => {
                        console.error(error);
                        this.error = error;
                    });
        });
    }

    handleEndSession() {
        endSession({ kakaoConsultId: this.kakaoConsultId })
            .then((result) => {
                if (result) {
                    this.sessionLive = false;
                    this.template.querySelector(".chatroom__input").dispatchEvent(new Event("keyup"));
                }
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleIdentifyLink() {
        const fields = {};
        fields[KAKAOCONSULTCHAT_FIELD.fieldApiName] = this.kakaoConsultId;
        fields[MESSAGE_FIELD.fieldApiName] = "Sending identify link";
        const chatFeed = { apiName: KAKAOCHATFEED_OBJECT.objectApiName, fields };

        createRecord(chatFeed)
            .then((result) => sendIdentifyLink({ kakaoChatFeedId: result.id }))
            .then(() => {
                return refreshApex(this.wiredMessages);
            })
            .then(() => {
                this.scrollChatroomPlace();
                this.setButtonDisabled();
            })
            .catch((error) => {
                console.error(error);
                this.error = error;
            });
    }

    handleQuickText(event) {
        const messageInput = this.template.querySelector(".chatroom__input");
        messageInput.value += this.quickTextMap.get(event.target.value);
        messageInput.dispatchEvent(new Event("keyup"));
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        const channelName = `/topic/KakaoConsultChatCustomer`;
        subscribe(channelName, -1, (response) => {
            // console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received
            if (response.data.sobject.Kakao_Consult_Chat__c === this.kakaoConsultId)
                return refreshApex(this.wiredMessages).then(() => {
                    this.scrollChatroomPlace();
                    if (this.sessionLive) {
                        const payload = { recordId: this.recordId, message: "tab-hightlight" };
                        publish(this.messageContext, CONNECTOR_CHANNEL, payload);
                    }
                });
        })
            .then((response) => {
                // Response contains the subscription information on subscribe call
                this.subscription = response;
            })
            .then(() => this.scrollChatroomPlace());

        const expiredSessionChannel = `/topic/KakaoConsultChatExpired`;
        subscribe(expiredSessionChannel, -1, (response) => {
            // console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received
            if (response.data.sobject.Id === this.kakaoConsultId) {
                this.sessionLive = response.data.sobject.Session_Live__c;
            }
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            // Error contains the server-side error
            console.log("Received error from server: ", JSON.stringify(error));
        });
    }

    endSession() {}

    // Scroll chat feed to bottom
    scrollChatroomPlace() {
        const chatroomPlace = this.template.querySelector(".chatroom__placearea");
        chatroomPlace.scrollTop = chatroomPlace.scrollHeight;
    }

    setButtonDisabled(disabled = true) {
        const sendButton = this.template.querySelector(".send_button");

        if (!this.sessionLive || disabled) {
            sendButton.classList.remove("chatroom__sendbutton");
            sendButton.classList.add("chatroom__sendbutton_disabled");
            sendButton.disabled = true;
        } else {
            sendButton.classList.add("chatroom__sendbutton");
            sendButton.classList.remove("chatroom__sendbutton_disabled");
            sendButton.disabled = false;
        }
    }
}