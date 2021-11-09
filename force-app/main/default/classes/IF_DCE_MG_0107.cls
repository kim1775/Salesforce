/****************************************************************************************
  * File Name   : IF_DCE_MG_0107
  * Description : IF_DCE_MG_0107 IF Class (SC에서 주문(QURE)주문정보를 Ecommerce로 전송한다.)
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.03.15.    ldb3100    Create
***************************************************************************************/
public with sharing class IF_DCE_MG_0107 extends IF_Base {
    private static final String IFID = 'IF_DCE_MG_0107'; // External interface id

    private static String IFURL;
    private static String accessToken;

    public class INPUT_T_DATA {
        public String CustomerName             ; // Mapping column : CustomerName__c
        public String CustomerEmail            ; // Mapping column : CustomerEmail__c
        public String CreatedDate              ; // Mapping column : CreatedDate__c
        public String ContactExtId             ; // Mapping column : ContactExtId__c
        public String CaseNo                   ; // Mapping column : CaseNo__c
        public String reason                   ; // Mapping column : reason__c
        public String ordertype                ; // Mapping column : ordertype__c
        public String ShippingPhone            ; // Mapping column : ShippingPhone__c
        public String ShippingAddress1         ; // Mapping column : ShippingAddress1__c
        public String ShippingAddress2         ; // Mapping column : ShippingAddress2__c
        public String ShippingCity             ; // Mapping column : ShippingCity__c
        public String ShippingStreet           ; // Mapping column : ShippingStreet__c
        public String ShippingPostalCode       ; // Mapping column : ShippingPostalCode__c
        public String ShippingCountry          ; // Mapping column : ShippingCountry__c
        public t_OrderItems t_OrderItems       ; // Mapping column :
    }

    public class t_OrderItems {
        public String KDCE_EANCode      ;
        public String Codentify         ;
        public String FullProductId     ;
        public String ProductCode       ;
        public String Name              ;
    }

    public class InputBody {
        public List<INPUT_T_DATA> t_data;
        public InputBody() {
            t_data = new List<INPUT_T_DATA>();
        }
    }

    public class OutputBody {
        public List<String> t_data;
        public OutputBody() {
            t_data = new List<String>();
        }
    }

    /**
     * Input / Output innerClass
     */
    public class Input extends Headers{
        public InputBody payload;
        public Input(){
            payload = new InputBody();
        }
    }
    public class Output extends Headers{
        public OutputBody payload;
        public Output(){
            payload = new OutputBody();
        }
    }
    /**
     * DIH
     * Input / Output innerClass
     */
    public class InputDIH {
        public Input request;
        public InputDIH(){
            request = new Input();
        }
    }
    public class OutputDIH {
        public Output response;
        public OutputDIH(){
            response = new Output();
        }
    }

    /**
     * constructor
     * (endpoint URL setting)
     */
    private IF_DCE_MG_0107() {
        // IF INFO Setting
        System.debug(IFID+' call');
        IF_INFO__c ifInfo = getIfinfo(IFID);  // DML
        accessToken = ifInfo.TargetAccessToken__c;
        IFURL = ifInfo.URL__c;
        System.debug(ifInfo.TITLE__c+' call start');
    }

    /**
     * singleton
     */
    private static IF_DCE_MG_0107 sInstance = null;
    public static IF_DCE_MG_0107 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_DCE_MG_0107();
        }
        return sInstance;
    }


    /**
     * JSON
     * Schedulable
     */
    public OutputDIH execute(InputDIH inputObj) {
        OutputDIH outputObj = new OutputDIH();

        String req = null;
        String res = null;
        String reqBody = null;

        IF_DCE_MG_0107_BIZ bizInstance = null;

        Input  inputReq  = inputObj.Request    ;
        Output outputRes = outputObj.Response  ;
        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base.logInit('SND');

            inputReq.Header = new IF_Base.InputHeader(IFID);

            inputReq.Header.ifSenderGp      = 'KR';
            inputReq.Header.ifSender        = 'DCE';
            inputReq.Header.ifReceiverGp    = 'KR';
            inputReq.Header.ifReceiver      = 'MG';

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base.logStart(inputReq.Header);

            bizInstance = IF_DCE_MG_0107_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            // JSON TO STRING
            req = JSON.serialize(inputObj);
            reqBody = JSON.serialize(inputObj.request.payload.t_data);

            // 로그 input, Request_Processing_Time 세팅
            IF_Base.logProcess('STEP1', req);

            if(Test.isRunningTest() && IF_Base.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            // WebCallout
            System.debug('IFURL == ' + IFURL);
            res = webCallOut(reqBody, IFURL, accessToken);

            // RESPONSE header value setup
            outputRes.Header = new IF_Base.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);
            outputRes.Header = IF_Base.setOutputHeader(outputRes.Header, inputReq.Header);
            outputRes.Payload.t_data.add(res);

            System.debug('debug called payload ==== ' + outputRes);

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

        } catch(Exception e) {
            // 에러내용 debug 출력
            IF_Comm.errorDebug(e);

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_Base.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_Base.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        outputObj.response = outputRes;
        IF_Base.logProcess('STEP2', JSON.serialize(outputObj));

        // 로그 파일 및 row insert
        IF_Base.logEnd(outputRes.Header);

        return outputObj;
    }
}