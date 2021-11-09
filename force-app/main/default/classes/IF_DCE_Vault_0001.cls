/****************************************************************************************
  * File Name   : IF_DCE_Vault_0001
  * Description : IF_DCE_Vault_0001 IF Class (Heets(Serial Number) 정보 조회)
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021. 02. 19.  ldb3100    Create
***************************************************************************************/
public with sharing class IF_DCE_Vault_0001 extends IF_Base_Vault {
    private static final String IFID = 'IF_DCE_Vault_0001'; // External interface id
 
    private static String IFURL;

    public class INPUT_T_DATA  {
        public List<String> Codes = new List<String>();
    }

    /**
     * inputBody / outputBody innerClass
     */
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

    public String jsonToXml(INPUT_T_DATA tData) {
        String result = '';
        for(String value : tData.Codes){
            result += '<b:string>'+value+'</b:string>';
        }
        return result;
    }

    /**
     * constructor
     * (endpoint URL setting)
     */
    private IF_DCE_Vault_0001() {
        System.debug(IFID+' call');
        IF_INFO__c ifInfo = getIfinfo(IFID);  // DML
        IFURL = ifInfo.URL__c;
        System.debug(ifInfo.TITLE__c+' call start');
    }

    /**
     * singleton
     */
    private static IF_DCE_Vault_0001 sInstance = null;
    public static IF_DCE_Vault_0001 getInstance() {
        if (sInstance == null) {
            sInstance = new IF_DCE_Vault_0001();
        }
        return sInstance;
    }


    /**
     * JSON
     * Schedulable
     */
    public OutputDIH execute(InputDIH inputObj) {
        OutputDIH outputObj = new OutputDIH();

        String resJson = '';
        String req = null;
        String res = null;

        IF_DCE_Vault_0001_BIZ bizInstance = null;

        Input  inputReq  = inputObj.Request  ;
        Output outputRes = outputObj.Response  ;
        System.debug('=== inputReq : ' + inputReq);
        System.debug('=== outputRes : ' + outputRes);

        try {
            // 로그 timeTemp, Request_to_DIH_Time 세팅
            IF_Base_Vault.logInit('SND');

            inputReq.Header = new IF_Base_Vault.InputHeader(IFID);

            inputReq.Header.ifSenderGp      = 'PMK';
            inputReq.Header.ifSender        = 'SFDC';
            inputReq.Header.ifReceiverGp    = 'PMK';
            inputReq.Header.ifReceiver      = 'Vault';

            // 로그 MSGGID, IFID, IFDATE 세팅
            IF_Base_Vault.logStart(inputReq.Header);

            bizInstance = IF_DCE_Vault_0001_BIZ.getInstance();

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(선행) */
            inputReq.Payload = bizInstance.pre(inputReq.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(선행) */

            // JSON TO STRING
            req = JSON.serialize(inputObj);

            // 로그 input, Request_Processing_Time 세팅
            IF_Base_Vault.logProcess('STEP1', req);

            if(Test.isRunningTest() && IF_Base_Vault.crashTest) {  // Purposely crash test.
                throw new DmlException('Dml Exception');
            }

            // 파라미터 세팅
            String xmlParam = jsonToXml(inputObj.request.payload.t_data.get(0));
            System.debug('=== xmlParam : ' + xmlParam);
            String xmlReq = IF_Base_Vault.xmlFormat(xmlParam);

            // RESPONSE SET
            res = webCallOut(xmlReq, IFURL);

            // XML TO Json
            resJson = IF_Base_Vault.xmlToJson(res);

            // RESPONSE header value setup
            outputRes.Header = new IF_Base_Vault.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);
            outputRes.Header = IF_Base_Vault.setOutputHeader(outputRes.Header, inputReq.Header);
            outputRes.Payload.t_data.add(resJson);

            /* 업무 개발자에 의해 변경되어야 하는 부분 시작(후행) */
            outputRes.Payload = bizInstance.post(inputReq.Payload, outputRes.Payload);
            /* 업무 개발자에 의해 변경되어야 하는 부분 끝(후행) */

        } catch(Exception e) {
            // 에러내용 debug 출력
            IF_Comm.errorDebug(e);

            // 내부오류의 경우 ResultCode 'E'로
            outputRes.Header = new IF_Base_Vault.InputHeader(inputReq.Header.ifTrackingId, IFID, inputReq.Header.ifDateTime);

            // error header value setup
            outputRes.Header = IF_Base_Vault.setOutputHeader(outputRes.Header, inputReq.Header, e);
        }
        // 로그 Response_Processing_Time, Respone_from_DIH_Time 세팅
        outputObj.response = outputRes;
        IF_Base_Vault.logProcess('STEP2', JSON.serialize(outputObj));

        // 로그 파일 및 row insert
        IF_Base_Vault.logEnd(outputRes.Header);

        return outputObj;
    }

}