/****************************************************************************************
  * @filename      : IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/18 3:37 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/18 3:37 오후     i2max_shlee       Create
****************************************************************************************/
@RestResource(urlMapping='/IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL/*')
global with sharing class IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL extends IF_KDCE_API_BizBase {
    private static String IF_ID = 'IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL';

    public class T_DATA {
        public String DYNAMIC_SOQL;
        public String UN_ENCRYPT;
    }

    /**
     * inputBody / outputBody innerClass
     */
    public class InputBody {
        public String ifAggregation;
        public String ifTotCnt;
        public String ifSplitCnt;
        public String ifSplitSeq;

        public List<T_DATA> t_data;

        public InputBody() {
            t_data 		= new List<T_DATA>();
        }
    }
    public class OutputBody {
        public String ifAggregation	    = '';
        public String ifSplitCnt        = '';
        public String ifRcvCnt	        = '';
        public String ifRetnTotCnt      = '';
        public String ifRetnCnt         = '';

        public List<SObject> t_data;

        public OutputBody() {
            t_data = new List<SObject>();
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
    global static OutputDIH doPost() {
        RestRequest restReq = RestContext.request;
        String req = restReq.requestBody.toString();
        String res = null;

        InputDIH  inputObj  = new InputDIH() ;
        OutputDIH outputObj = new OutputDIH();

        Input  inputReq  = null              ;
        Output outputRes = outputObj.Response;

        Exception commException;

        try {
            IF_Base.logInit('RCV');

            inputObj = (InputDIH)JSON.deserialize(req, InputDIH.class);

            inputReq  = inputObj.Request;

            if(inputReq.header.ifId == null || ''.equals(inputReq.header.ifId)) {
                throw new IF_Base.IFException('ifId is required field.');
            } else {

                List<IF_INFO__c> ifInfoList = [SELECT IF_ID__c FROM IF_INFO__c];

                Boolean checkInterfaceId = false;

                for (IF_INFO__c ifInfo : ifInfoList) {
                    if (inputReq.header.ifId.equals(ifInfo.IF_ID__c)) {
                        checkInterfaceId = true;
                        break;
                    }
                }

                if (!checkInterfaceId) {
                    throw new IF_Base.IFException('IF_ID NOT SAVE');
                }

                IF_ID = inputReq.header.ifId;
            }

            // 로그 MSGGID, IF_ID, IFDATE 세팅
            IF_Base.logStart(inputReq.Header);
            // 로그 input, Request_Processing_Time 세팅
            IF_Base.logProcess('STEP1', req);

            outputRes.Header         = new IF_Base.InputHeader(IF_ID)   ;

            // header value setup
            outputRes.Header = IF_Base.setOutputHeader(outputRes.Header, inputReq.Header);

            crashTest();

            IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ bizInstance = IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

            outputRes.Header.ifResult 		= 'S';
            outputRes.Header.ifFailMsg   	= '';
            outputRes.Header.ifFailCode  	= '';

        } catch(DMLException e){
            commException = e;
        } catch(IFException e) {
            commException = e;
        } catch(SecurityException e) {
            commException = e;
        } catch(Exception e) {
            commException = e;
        } finally {
            if (commException != null) {
                // 에러내용 debug 출력
                IF_Comm.errorDebug(commException);

                // 오류 발생시 output 초기화
                outputRes.payload.T_DATA = new List<SObject>();

                // 내부오류의 경우 ResultCode 'E'로
                outputRes.Header = new IF_Base.InputHeader(inputReq.Header.ifTrackingId, IF_ID, inputReq.Header.ifDateTime);

                // error header value setup
                outputRes.Header = IF_Base.setOutputHeader(outputRes.Header, inputReq.Header, commException);
            }
        }

        res = JSON.serialize(outputObj);

        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        IF_Base.logProcess('STEP2', res);
        // 로그 파일 및 row insert
//        IF_Base.logEnd(outputRes.Header);
        IF_Base.logEnd(outputRes.header, inputReq.payload.ifAggregation, inputReq.payload.ifTotCnt, inputReq.payload.ifSplitCnt, inputReq.payload.ifSplitSeq, outputRes.payload.ifRcvCnt);

        return outputObj;
    }

    public static void crashTest() {
        if(Test.isRunningTest() && IF_Base.crashTest) {  // Purposely crash test.
            if (IF_Base.EXCEPTION_TYPE.DML_EXCEPTION.name().equals(IF_Base.exceptionType)) {
                throw new DmlException('DML Exception');
            } else if (IF_Base.EXCEPTION_TYPE.IF_EXCEPTION.name().equals(IF_Base.exceptionType)) {
                throw new IFException('IF Exception');
            } else if (IF_Base.EXCEPTION_TYPE.SECURITY_EXCEPTION.name().equals(IF_Base.exceptionType)) {
                throw new SecurityException('SECURITY Exception');
            }
        }
    }
}