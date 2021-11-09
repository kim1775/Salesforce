/****************************************************************************************
  * File Name   : IF_Base_GC_TEST
  * Description : IF_Base_GC_TEST Class
  * Author      : lsol927
  * Modification Log
  * ===============================================================
  * Ver  Date        Author             Modification
  * ===============================================================
    1.0  2021.02.18  ldb3100            Create
****************************************************************************************/
@isTest(SeeAllData=true)
private class IF_Base_GC_TEST {

    private static void testInputHeader() {
        try {
            IF_Base_GC.InputHeader inputHeader;
            inputHeader = new IF_Base_GC.InputHeader();
            inputHeader = new IF_Base_GC.InputHeader('');
            inputHeader = new IF_Base_GC.InputHeader('', '');
            inputHeader = new IF_Base_GC.InputHeader('', '', '');
            inputHeader = new IF_Base_GC.InputHeader('', '', '', '');
            inputHeader = new IF_Base_GC.InputHeader('', '', '', '', '', '');
            inputHeader.genMsg();
            inputHeader.giveGUID();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testAggr() {
        try {
            IF_Base_GC.giveAGGR();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testHeader() {
        try {
            IF_Base_GC.Header Header = new IF_Base_GC.Header();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testHeaders() {
        try {
            IF_Base_GC.Headers header = new IF_Base_GC.Headers();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testLogInit( ) {
        try {
            IF_Base_GC.logInit('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogStart() {
        try {
            IF_Base_GC.logStart(new IF_Base_GC.InputHeader());
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogProcess() {
        try {
            IF_Base_GC.logProcess('STEP1', '');
            IF_Base_GC.logProcess('STEP1-1', '');
            IF_Base_GC.logProcess('STEP2', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogEnd() {
        try {
            IF_Base_GC.InputHeader inputHeader = new IF_Base_GC.InputHeader();
            inputHeader.ifResult='F';
            IF_Base_GC.logEnd(inputHeader);
            IF_Base_GC.logEnd(inputHeader, '', '', '', '', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }


    private static void testWebCallOut() {
        try {
            IF_Base_GC.webCallOut('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetIfinfo() {
        try {
            IF_Base_GC.getIfinfo('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static boolean testWebCallOutLog() {
        boolean isTrue = false;
        try {
            IF_Base_GC.webCallOutLog('');
            IF_Base_GC.crashTest = true;
            IF_Base_GC.webCallOutLog('');

            isTrue = true;
        } catch (Exception ex) {
            system.debug(ex);
        }

        return isTrue;
    }

    private static void testAuthEncLog() {
        try {
            IF_Base_GC.authEncLog();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testWebCallOutAsync() {
        try {
            IF_Base_GC.webCallOutAsync('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetDIHSessionId() {
        try {
            IF_Base_GC.getDIHSessionId();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncUpdate() {
        try {
            String msgguid = '0834e514-d2eb-42c3-b501-770f335dfdd5';
            IF_LOG__c log = new IF_LOG__c(MSGGUID__c = msgguid, OMSGGUID__c = '');
            insert log;
            IF_Base_GC.InputHeader inputHeaders = new IF_Base_GC.InputHeader();
            inputHeaders.ifTrackingId = MSGGUID;
            IF_Base_GC.logAsyncUpdate(inputHeaders);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncAttach() {
        try {
            IF_Base_GC.logAsyncAttach('aaa','aaa');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testSetOutputHeader() {
        IF_Base_GC.InputHeader inputHeader  = new IF_Base_GC.InputHeader();
        IF_Base_GC.InputHeader outputHeader = new IF_Base_GC.InputHeader();
        try {

            outputHeader = IF_Base_GC.setOutputHeader(outputHeader, inputHeader);

            if(true) {
                throw new DmlException('Exception');
            }
        } catch (Exception ex) {
            system.debug(ex);
            outputHeader = IF_Base_GC.setOutputHeader(outputHeader, inputHeader, ex);
        }
    }

    private static void testGetAccessToken() {
        try {
            IF_Base_GC.getAccessToken();
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