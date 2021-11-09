/****************************************************************************************
  * @filename      : IF_Base_Bitly_TEST
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/04/07 7:26 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_Base_Bitly_TEST_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/04/07 7:26 오후     i2max_shlee       Create
****************************************************************************************/
@isTest(SeeAllData=true)
private class IF_Base_Bitly_TEST {

    private static void testInputHeader() {
        try {
            IF_Base_Bitly.InputHeader inputHeader;
            inputHeader = new IF_Base_Bitly.InputHeader();
            inputHeader = new IF_Base_Bitly.InputHeader('');
            inputHeader = new IF_Base_Bitly.InputHeader('', '');
            inputHeader = new IF_Base_Bitly.InputHeader('', '', '');
            inputHeader = new IF_Base_Bitly.InputHeader('', '', '', '');
            inputHeader = new IF_Base_Bitly.InputHeader('', '', '', '', '', '');
            inputHeader.genMsg();
            inputHeader.giveGUID();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testAggr() {
        try {
            IF_Base_Bitly.giveAGGR();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testHeader() {
        try {
            IF_Base_Bitly.Header Header = new IF_Base_Bitly.Header();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testHeaders() {
        try {
            IF_Base_Bitly.Headers header = new IF_Base_Bitly.Headers();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testLogInit( ) {
        try {
            IF_Base_Bitly.logInit('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogStart() {
        try {
            IF_Base_Bitly.logStart(new IF_Base_Bitly.InputHeader());
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogProcess() {
        try {
            IF_Base_Bitly.logProcess('STEP1', '');
            IF_Base_Bitly.logProcess('STEP1-1', '');
            IF_Base_Bitly.logProcess('STEP2', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogEnd() {
        try {
            IF_Base_Bitly.InputHeader inputHeader = new IF_Base_Bitly.InputHeader();
            inputHeader.ifResult='F';
            IF_Base_Bitly.logEnd(inputHeader);
            IF_Base_Bitly.logEnd(inputHeader, '', '', '', '', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }


    private static void testWebCallOut() {
        try {
            IF_Base_Bitly.webCallOut('', '', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetIfinfo() {
        try {
            IF_Base_Bitly.getIfinfo('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static boolean testWebCallOutLog() {
        boolean isTrue = false;
        try {
            IF_Base_Bitly.webCallOutLog('');
            IF_Base_Bitly.crashTest = true;
            IF_Base_Bitly.webCallOutLog('');

            isTrue = true;
        } catch (Exception ex) {
            system.debug(ex);
        }

        return isTrue;
    }

    private static void testAuthEncLog() {
        try {
            IF_Base_Bitly.authEncLog();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testWebCallOutAsync() {
        try {
            IF_Base_Bitly.webCallOutAsync('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetDIHSessionId() {
        try {
            IF_Base_Bitly.getDIHSessionId();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncUpdate() {
        try {
            String msgguid = '0834e514-d2eb-42c3-b501-770f335dfdd5';
            IF_LOG__c log = new IF_LOG__c(MSGGUID__c = msgguid, OMSGGUID__c = '');
            insert log;
            IF_Base_Bitly.InputHeader inputHeaders = new IF_Base_Bitly.InputHeader();
            inputHeaders.ifTrackingId = MSGGUID;
            IF_Base_Bitly.logAsyncUpdate(inputHeaders);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncAttach() {
        try {
            IF_Base_Bitly.logAsyncAttach('aaa','aaa');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testSetOutputHeader() {
        IF_Base_Bitly.InputHeader inputHeader  = new IF_Base_Bitly.InputHeader();
        IF_Base_Bitly.InputHeader outputHeader = new IF_Base_Bitly.InputHeader();
        try {

            outputHeader = IF_Base_Bitly.setOutputHeader(outputHeader, inputHeader);

            if(true) {
                throw new DmlException('Exception');
            }
        } catch (Exception ex) {
            system.debug(ex);
            outputHeader = IF_Base_Bitly.setOutputHeader(outputHeader, inputHeader, ex);
        }
    }

    private static void testGetAccessToken() {
        try {
            IF_Base_Bitly.getAccessToken();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    @isTest public static void myUnitTest() {
        try {
            testInputHeader();
            testAggr();
            testHeader();
            testHeaders();
            testLogInit();
            testLogStart();
            testLogProcess();
            testLogEnd();
            testWebCallOut();
            testGetIfinfo();
            //testAuthEnc();
            //testWebCallOutLog();
            testAuthEncLog();
            testWebCallOutAsync();
            testGetDIHSessionId();
            testLogAsyncUpdate();
            testLogAsyncAttach();
            testGetAccessToken();

            testSetOutputHeader();

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

            System.assertEquals(testWebCallOutLog(), true);

        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('');
        return res;
    }

    // StatusCode=200 Mock
    public class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }
}