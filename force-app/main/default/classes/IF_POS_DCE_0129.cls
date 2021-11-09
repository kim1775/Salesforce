/****************************************************************************************
  * File Name   : IF_POS_DCE_0129
  * Description : IF_POS_DCE_0129
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author     Modification
  * ===============================================================
    1.0  2021.03.12  ldb3100    Create
    1.1  2021.03.30 i2max_Sukun Update
****************************************************************************************/
@RestResource(UrlMapping='/IF_POS_DCE_0129/*')
global with sharing class IF_POS_DCE_0129 extends IF_KDCE_API_BizBase {
    private static String IFID = 'IF_POS_DCE_0129';

    public class InputData {
        public List<IF_KDCE_API_BizBase.T_Order> t_Orders;
    }

    public class OutputData{
         public List<Id> orderIds;
    }

    /*
     * Input Class
     */
    global class InputDIH {
        public Input request;
        public InputDIH() {
            request = new Input();
        }
    }

    global class Input extends Headers{
        public InputBody payload;
        public Input() {
            payload = new InputBody();
        }
    }

    public class InputBody {
        public String ifAggregation;
        public String ifTotCnt;
        public String ifSplitCnt;
        public String ifSplitSeq;
        public String ifDateTime;
        public List<InputData> t_data;
        public InputBody() {
            t_data = new List<InputData>();
        }
    }

    /*
     * Output Class
     */
    global class OutputDIH {
        public Output response;
        public OutputDIH() {
            response = new Output();
        }
    }

    global class Output extends Headers {
        public OutputBody payload;
        public Output() {
            payload = new OutputBody();
        }
    }

    public class OutputBody {
        public String ifAggregation;
        public String ifSplitCnt;
        public String ifRcvCnt;
        public List<OutputData> t_data;
        public OutputBody() {
            t_data = new List<OutputData>();
        }
    }

    @HttpPost
    global static OutputDIH doPost() {
        Savepoint sp = Database.setSavepoint();
        //Request Body
        String requestString = RestContext.request.requestBody.toString();

        InputDIH inputObj   = new InputDIH();
        OutputDIH outputObj = new OutputDIH();

        Input input;
        Output output = outputObj.response;

        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base.logInit('RCV');

            inputObj    = (InputDIH)JSON.deserialize(requestString, InputDIH.class);
            input       = inputObj.request;

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base.logStart(input.Header);
            // 로그 input, Request_Processing_Time 세팅
            IF_Base.logProcess('STEP1', requestString);

            output.header   = new IF_Base.InputHeader(IFID);
            // header value setup
            output.header = IF_Base.setOutputHeader(output.header, input.header);

            if(Test.isRunningTest() && IF_Base.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            input.payload.ifDateTime = IF_Comm.convertEmpty(input.header.ifDateTime);

            IF_POS_DCE_0129_BIZ bizInstance = IF_POS_DCE_0129_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            input.payload = bizInstance.pre(input.payload, output.payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            output.payload = bizInstance.post(input.payload, output.payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

            output.header.ifResult 		= 'S';
            output.header.ifFailMsg   	= '';
            output.header.ifFailCode  	= '';

        } catch(Exception e){
            Database.rollback(sp);
            IF_Comm.errorDebug(e);
            input  = inputObj.request;


            // 내부오류의 경우 ResultCode 'E'로
            output.header = new IF_Base.InputHeader(input.header.ifTrackingId, IFID, input.header.ifDateTime);

            // error header value setup
            output.header = IF_Base.setOutputHeader(output.header, input.header, e);
        }

        String response = JSON.serialize(output);

        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        IF_Base.logProcess('STEP2', response);
        // 로그 파일 및 row insert
        // IF_Base.logEnd(outputRes.Header);
        IF_Base.logEnd(output.header, input.payload.ifAggregation, input.payload.ifTotCnt, input.payload.ifSplitCnt, input.payload.ifSplitSeq, output.payload.ifRcvCnt);

        return outputObj;
    }

}