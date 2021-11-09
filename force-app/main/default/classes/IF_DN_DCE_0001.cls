/****************************************************************************************
  * File Name   : IF_DN_DCE_0001
  * Description : IF_DN_DCE_0001 (Danal-쿠폰 사용 결과 및 기기 교환 정보 전송)
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.15  ldb3100    Create
****************************************************************************************/
@RestResource(UrlMapping='/AssetReplace/*')
global with sharing class IF_DN_DCE_0001 extends IF_Base_Danal {
    private static String IFID = 'IF_DN_DCE_0001';

    public class INPUT_T_DATA {
        public String ReplacementType   ;
        public List<Requests> Requests  ;
    }

    public class Requests {
        public String requestId ;
        public device device    ;
        public AddDetails AddDetails;
    }

    public class device {
        public String ToReplaceCodentify    ;
        public String Parentcodentify       ;
    }

    public class AddDetails {
        public String Reason     ;
        public String Channel    ;
        public String Channel_v2 ;
        public String Ext_Ref    ;
        public String ReplacementDate    ;
        public String ReplacementCountry ;
    }

    global class OUTPUT_T_DATA {
        public List<responses> responses;
        public OUTPUT_T_DATA() {
            responses = new List<responses>();
        }
    }

    public class responses {
        public String resultcode           ;
        public String result               ;
        public String requestId            ;
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

    @HttpPost
    global static OUTPUT_T_DATA doPost() {
        RestRequest restReq = RestContext.request;
        String req = restReq.requestBody.toString();
        String res = null;

        InputDIH  inputObj  = new InputDIH() ;
        OutputDIH outputObj = new OutputDIH();

        Input  inputReq  = inputObj.Request;
        Output outputRes = outputObj.Response;

        OUTPUT_T_DATA outputTdata = new OUTPUT_T_DATA();

        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base_Danal.logInit('RCV');

            // log를 위한 DIH Header 생성
            inputReq.Header = new IF_Base_Danal.InputHeader(IFID);

            inputReq.Header.ifSenderGp      = 'KR';
            inputReq.Header.ifSender        = 'DN';
            inputReq.Header.ifReceiverGp    = 'KR';
            inputReq.Header.ifReceiver      = 'DCE';
            inputReq.Payload.t_data.add((INPUT_T_DATA)JSON.deserialize(req, INPUT_T_DATA.class));

            inputObj.request = inputReq;

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base_Danal.logStart(inputReq.Header);
            // 로그 input, Request_Processing_Time 세팅
            IF_Base_Danal.logProcess('STEP1', JSON.serialize(inputObj));

            outputRes.Header = new IF_Base_Danal.InputHeader(IFID)   ;

            // header value setup
            outputRes.Header = IF_Base_Danal.setOutputHeader(outputRes.Header, inputReq.Header);

            if(Test.isRunningTest() && IF_Base_Danal.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            IF_DN_DCE_0001_BIZ bizInstance = IF_DN_DCE_0001_BIZ.getInstance();

            /*  업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            /*  업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

            outputRes.Header.ifResult       = 'S';
            outputRes.Header.ifFailMsg      = '';
            outputRes.Header.ifFailCode     = '';

            // Response 세팅
            responses vo = new responses();
            vo.resultcode = IF_Base_Danal.API_RES_SUCCESS_CODE;
            vo.result     = IF_Base_Danal.API_RES_SUCCESS_MSG;
            vo.requestId  = inputReq.Payload.t_data.get(0).Requests.get(0).requestId;
            outputTdata.responses.add(vo);

            outputRes.Payload.t_data.add(outputTdata);

        } catch(Exception e){
            // 에러내용 debug 출력
            IF_Comm.errorDebug(e);

            inputReq  = inputObj.Request;

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_Base_Danal.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_Base_Danal.setOutputHeader(outputRes.Header, inputReq.Header, e);

            responses vo = new responses();
            vo.resultcode = '500';
            vo.result     = e.getMessage();
            if(!Test.isRunningTest())vo.requestId  = inputReq.Payload.t_data.get(0).Requests.get(0).requestId;
            outputTdata.responses.add(vo);

            outputRes.Payload.t_data.add(outputTdata);

        }
        outputObj.response = outputRes;

        System.debug('test called !!!!!! ' + outputTdata);
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        System.debug('outputObj : ' + JSON.serialize(outputObj));
        IF_Base_Danal.logProcess('STEP2', JSON.serialize(outputObj));
        // 로그 파일 및 row insert
        // IF_Base.logEnd(outputRes.Header);
        IF_Base_Danal.logEnd(outputRes.Header);

        return outputTdata;
    }

}