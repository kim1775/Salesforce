/****************************************************************************************
  * @filename      : IF_EX_SFDC_0050
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/03/11 2:50 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_EX_SFDC_0050_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/03/11 2:50 오후     i2max_shlee       Create
****************************************************************************************/
@RestResource(urlMapping='/IF_EX_SFDC_0050/*') // External interface id
global with sharing class IF_EX_SFDC_0050 extends IF_BaseNotiforce {
    private static final String IFID = 'IF_EX_SFDC_0050'; // External interface id

    public class INPUT_T_DATA {

        public String receiverType          ; //receiver Type 수신자 타입 : account, contact, lead, user
        public String templateExtId         ; //메세지 템플릿 Ext Id
        public List<T_Receiver> t_Receivers ; //수신자 정보 리스트
        public String currentDateTime       ; //발송 날짜
    }

    public class T_Receiver {
        public String receiverExtId     ; //receiver Ext Id
        public String userId            ; //User SFDC Id
        public String userExtId         ; //User Ext Id
        public String leadId            ; //lead SFDC Id
        public String leadExtId         ; //lead Ext Id
        public String accountId         ; //Account SFDC Id
        public String accountExtId      ; //Contact Ext Id
        public String contactId         ; //Contact SFDC Id
        public String contactExtId      ; //Contact Ext Id
        public List<String> labels      ; //개인화 라벨 리스트
        public String isSuccess         ; //메세지 전달 여부
        public String errorMsg          ; //실패 메세지
        public List<String> btnURLs     ;
        //public List<String> btnURL2     ;
    }

    public class InputBody {
        public List<INPUT_T_DATA> t_data;
        public InputBody() {
            t_data = new List<INPUT_T_DATA>();
        }
    }

    public class OutputBody {
        public List<INPUT_T_DATA> t_data;
        public OutputBody() {
            t_data = new List<INPUT_T_DATA>();
        }
    }

    /**
     * Input / Output innerClass
     */
    global class Input extends Headers{
        public InputBody payload;
        public Input(){
            payload = new InputBody();
        }
    }
    global class Output extends Headers{
        public OutputBody payload;
        public Output(){
            payload = new OutputBody();
        }
    }
    /**
     * DIH 
     * Input / Output innerClass
     */
    global class InputDIH {
        public Input request;
        public InputDIH(){
            request = new Input();
        }
    }
    global class OutputDIH {
        public Output response;
        public OutputDIH(){
            response = new Output();
        }
    }

    /**
     * doPost
     * interface call
     */
    @HttpPost
    global static OutputDIH doPost() {
        RestRequest restReq = RestContext.request;
        String req = restReq.requestBody.toString();
        String res = null;

        InputDIH  inputObj  = new InputDIH() ;
        OutputDIH outputObj = new OutputDIH();

        Input  inputReq  = null              ;
        Output outputRes = outputObj.Response;
        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_BaseNotiforce.logInit('RCV');

            inputObj = (InputDIH)JSON.deserialize(req, InputDIH.class);

            inputReq  = inputObj.Request  ;

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_BaseNotiforce.logStart(inputReq.Header);
            // 로그 input, Request_Processing_Time 세팅
            IF_BaseNotiforce.logProcess('STEP1', req);

            outputRes.Header = new IF_BaseNotiforce.InputHeader(IFID)   ;

            // header value setup
            outputRes.Header = IF_BaseNotiforce.setOutputHeader(outputRes.Header, inputReq.Header);

            if(Test.isRunningTest() && IF_BaseNotiforce.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            IF_EX_SFDC_0050_BIZ bizInstance = IF_EX_SFDC_0050_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

            outputRes.Header.ifResult       = 'S';
            outputRes.Header.ifFailMsg      = '';
            outputRes.Header.ifFailCode     = '';

        } catch (Exception e) {
            // 에러내용 debug 출력
            IF_CommNotiforce.errorDebug(e);

            inputReq  = inputObj.Request;

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_BaseNotiforce.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_BaseNotiforce.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        res = JSON.serialize(outputObj);

        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        IF_BaseNotiforce.logProcess('STEP2', res);
        // 로그 파일 및 row insert 
        IF_BaseNotiforce.logEnd(outputRes.Header);

        return outputObj;
    }

}