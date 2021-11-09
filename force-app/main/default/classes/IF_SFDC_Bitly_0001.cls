/****************************************************************************************
  * @filename      : IF_SFDC_Bitly_0001
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/04/08 8:52 오전
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_SFDC_Bitly_0001_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/04/08 8:52 오전     i2max_shlee       Create
****************************************************************************************/
public with sharing class IF_SFDC_Bitly_0001 extends IF_Base_Bitly {
    private static final String IFID = 'IF_Base_Bitly_0001'; // External interface id

    private static String IFURL;
    private static String accessToken;

    public class INPUT_T_DATA {
        public String group_guid    ;  // Mapping column :
        public String domain        ;  // Mapping column :
        public String long_url      ;  // Mapping column :
    }

    public class OUTPUT_T_DATA {
        public String created_at    ;  // Mapping column :
        public String id            ;  // Mapping column :
        public String link          ;  // Mapping column :
        public String long_url      ;  // Mapping column :
        public String archived      ;  // Mapping column :
    }

    public class InputBody {
        public List<INPUT_T_DATA> t_data;
        public InputBody() {
            t_data = new List<INPUT_T_DATA>();
        }
    }

    public class OutputBody {
        public List<OUTPUT_T_DATA> t_data;
        public OutputBody() {
            t_data = new List<OUTPUT_T_DATA>();
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
    private IF_SFDC_Bitly_0001() {
        // IF INFO Setting
        System.debug(IFID+' call');
        IF_INFO__c ifInfo = getIfinfo(IFID);  // DML
        IFURL = ifInfo.URL__c;
        accessToken = ifInfo.TargetAccessToken__c;
        System.debug(ifInfo.TITLE__c+' call start');
    }

    /**
     * singleton
     */
    private static IF_SFDC_Bitly_0001 sInstance = null;
    public static IF_SFDC_Bitly_0001 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SFDC_Bitly_0001();
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

        IF_SFDC_Bitly_0001_BIZ bizInstance = null;

        Input  inputReq  = inputObj.Request    ;
        Output outputRes = outputObj.Response  ;
        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base_Bitly.logInit('SND');

            inputReq.Header = new IF_Base_Bitly.InputHeader(IFID);

            inputReq.Header.ifSenderGp      = 'KR';
            inputReq.Header.ifSender        = 'DCE';
            inputReq.Header.ifReceiverGp    = 'KR';
            inputReq.Header.ifReceiver      = 'Bitly';

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base_Bitly.logStart(inputReq.Header);

            bizInstance = IF_SFDC_Bitly_0001_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            // JSON TO STRING
            req = JSON.serialize(inputObj);
            reqBody = JSON.serialize(inputObj.request.payload.t_data.get(0));

            // 로그 input, Request_Processing_Time 세팅
            IF_Base_Bitly.logProcess('STEP1', req);

            if(Test.isRunningTest() && IF_Base_Bitly.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            // WebCallout
            res = webCallOut(reqBody, IFURL, accessToken);

            // RESPONSE header value setup
            outputRes.Header = new IF_Base_Bitly.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);
            outputRes.Header = IF_Base_Bitly.setOutputHeader(outputRes.Header, inputReq.Header);
            OUTPUT_T_DATA outputTData = (OUTPUT_T_DATA)JSON.deserialize(res,OUTPUT_T_DATA.class);
            outputRes.Payload.t_data.add(outputTData);

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

        } catch(Exception e) {
            // 에러내용 debug 출력
            IF_Comm.errorDebug(e);

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_Base_Bitly.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_Base_Bitly.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        outputObj.response = outputRes;
        IF_Base_Bitly.logProcess('STEP2', JSON.serialize(outputObj));

        // 로그 파일 및 row insert
        IF_Base_Bitly.logEnd(outputRes.Header);

        return outputObj;
    }

}