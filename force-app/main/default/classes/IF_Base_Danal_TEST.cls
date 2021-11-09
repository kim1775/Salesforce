/****************************************************************************************
  * File Name   : IF_Base_Danal_TEST
  * Description : IF_Base_Danal_TEST Class
  * Author      : lsol927
  * Modification Log
  * ===============================================================
  * Ver  Date        Author             Modification
  * ===============================================================
    1.0  2021.02.18  ldb3100            Create
****************************************************************************************/
@isTest(SeeAllData=true)
private class IF_Base_Danal_TEST {

    private static void testInputHeader() {
        try {
            IF_Base_Danal.InputHeader inputHeader;
            inputHeader = new IF_Base_Danal.InputHeader();
            inputHeader = new IF_Base_Danal.InputHeader('');
            inputHeader = new IF_Base_Danal.InputHeader('', '');
            inputHeader = new IF_Base_Danal.InputHeader('', '', '');
            inputHeader = new IF_Base_Danal.InputHeader('', '', '', '');
            inputHeader = new IF_Base_Danal.InputHeader('', '', '', '', '', '');
            inputHeader.genMsg();
            inputHeader.giveGUID();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testAggr() {
        try {
            IF_Base_Danal.giveAGGR();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testHeader() {
        try {
            IF_Base_Danal.Header Header = new IF_Base_Danal.Header();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testHeaders() {
        try {
            IF_Base_Danal.Headers header = new IF_Base_Danal.Headers();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testLogInit( ) {
        try {
            IF_Base_Danal.logInit('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogStart() {
        try {
            IF_Base_Danal.logStart(new IF_Base_Danal.InputHeader());
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogProcess() {
        try {
            IF_Base_Danal.logProcess('STEP1', '');
            IF_Base_Danal.logProcess('STEP1-1', '');
            IF_Base_Danal.logProcess('STEP2', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogEnd() {
        try {
            IF_Base_Danal.InputHeader inputHeader = new IF_Base_Danal.InputHeader();
            inputHeader.ifResult='F';
            IF_Base_Danal.logEnd(inputHeader);
            IF_Base_Danal.logEnd(inputHeader, '', '', '', '', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }


    private static void testWebCallOut() {
        try {
            IF_Base_Danal.webCallOut('', '', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetIfinfo() {
        try {
            IF_Base_Danal.getIfinfo('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static boolean testWebCallOutLog() {
        boolean isTrue = false;
        try {
            IF_Base_Danal.webCallOutLog('');
            IF_Base_Danal.crashTest = true;
            IF_Base_Danal.webCallOutLog('');

            isTrue = true;
        } catch (Exception ex) {
            system.debug(ex);
        }

        return isTrue;
    }

    private static void testAuthEncLog() {
        try {
            IF_Base_Danal.authEncLog();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testWebCallOutAsync() {
        try {
            IF_Base_Danal.webCallOutAsync('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetDIHSessionId() {
        try {
            IF_Base_Danal.getDIHSessionId();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncUpdate() {
        try {
            String msgguid = '0834e514-d2eb-42c3-b501-770f335dfdd5';
            IF_LOG__c log = new IF_LOG__c(MSGGUID__c = msgguid, OMSGGUID__c = '');
            insert log;
            IF_Base_Danal.InputHeader inputHeaders = new IF_Base_Danal.InputHeader();
            inputHeaders.ifTrackingId = MSGGUID;
            IF_Base_Danal.logAsyncUpdate(inputHeaders);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncAttach() {
        try {
            IF_Base_Danal.logAsyncAttach('aaa','aaa');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testSetOutputHeader() {
        IF_Base_Danal.InputHeader inputHeader  = new IF_Base_Danal.InputHeader();
        IF_Base_Danal.InputHeader outputHeader = new IF_Base_Danal.InputHeader();
        try {

            outputHeader = IF_Base_Danal.setOutputHeader(outputHeader, inputHeader);

            if(true) {
                throw new DmlException('Exception');
            }
        } catch (Exception ex) {
            system.debug(ex);
            outputHeader = IF_Base_Danal.setOutputHeader(outputHeader, inputHeader, ex);
        }
    }

    private static void testGetAccessToken() {
        try {
            IF_Base_Danal.getAccessToken();
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