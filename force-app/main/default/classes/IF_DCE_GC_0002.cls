/****************************************************************************************
  * File Name   : IF_DCE_GC_0002
  * Description : IF_DCE_GC_0002 IF Class (GC-Get Recording Download URL)
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.03.02.    ldb3100    Create
***************************************************************************************/
public with sharing class IF_DCE_GC_0002 extends IF_Base_GC {
    private static final String IFID = 'IF_DCE_GC_0002'; // External interface id

    private static String IFURL;
    private static String accessToken;

    public class INPUT_T_DATA {
        public String conversationId   ;  // Mapping column :
        public String recordingId      ;  // Mapping column :
        public String formatId         ;  // Mapping column :
        public String emailFormatId    ;  // Mapping column :
        public String chatFormatId     ;  // Mapping column :
        public String messageFormatId  ;  // Mapping column :
        public String download         ;  // Mapping column :
        public String fileName         ;  // Mapping column :
        public String locale           ;  // Mapping column :
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
    private IF_DCE_GC_0002() {
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
    private static IF_DCE_GC_0002 sInstance = null;
    public static IF_DCE_GC_0002 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_DCE_GC_0002();
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

        IF_DCE_GC_0002_BIZ bizInstance = null;

        Input  inputReq  = inputObj.Request    ;
        Output outputRes = outputObj.Response  ;
        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base_GC.logInit('SND');

            inputReq.Header = new IF_Base_GC.InputHeader(IFID);

            inputReq.Header.ifSenderGp      = 'KR';
            inputReq.Header.ifSender        = 'DCE';
            inputReq.Header.ifReceiverGp    = 'KR';
            inputReq.Header.ifReceiver      = 'GC';

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base_GC.logStart(inputReq.Header);

            bizInstance = IF_DCE_GC_0002_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            // JSON TO STRING
            req = JSON.serialize(inputObj);
            //reqBody = JSON.serialize(inputObj.request.payload.t_data.get(0));

            // 로그 input, Request_Processing_Time 세팅
            IF_Base_GC.logProcess('STEP1', req);

            if(Test.isRunningTest() && IF_Base_GC.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            // 파라미터 세팅 & WebCallout
            INPUT_T_DATA tData = inputObj.request.payload.t_data.get(0);
            IFURL += '/conversations/'+ tData.conversationId;
            IFURL += '/recordings/'   + tData.recordingId + '?';

            Map<String, Object> inputMap = (Map<String,Object>)Json.deserializeUntyped(Json.serialize(tData));
            for (String key : inputMap.keySet()){
                if(inputMap.get(key) != null){
                    if((!'conversationId'.equals(key)) && (!'recordingId'.equals(key))){
                        IFURL += key + '=' + inputMap.get(key) + '&';
                    }
                }
            }
            res = webCallOut(IFURL, accessToken);

            // RESPONSE header value setup
            outputRes.Header = new IF_Base_GC.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);
            outputRes.Header = IF_Base_GC.setOutputHeader(outputRes.Header, inputReq.Header);
            outputRes.Payload.t_data.add(res);

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

        } catch(Exception e) {
            // 에러내용 debug 출력
            IF_Comm.errorDebug(e);

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_Base_GC.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_Base_GC.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        outputObj.response = outputRes;
        IF_Base_GC.logProcess('STEP2', JSON.serialize(outputObj));

        // 로그 파일 및 row insert
        IF_Base_GC.logEnd(outputRes.Header);

        return outputObj;
    }
}