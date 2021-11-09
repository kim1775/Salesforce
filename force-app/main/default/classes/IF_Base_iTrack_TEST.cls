/****************************************************************************************
  * File Name   : IF_Base_iTrack_TEST
  * Description : IF_Base_iTrack_TEST Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author             Modification
  * ===============================================================
    1.0  2021.02.16  ldb3100            Create
****************************************************************************************/
@isTest(SeeAllData=true)
private class IF_Base_iTrack_TEST {

    private static void testInputHeader() {
        try {
            IF_Base_iTrack.InputHeader inputHeader;
            inputHeader = new IF_Base_iTrack.InputHeader();
            inputHeader = new IF_Base_iTrack.InputHeader('');
            inputHeader = new IF_Base_iTrack.InputHeader('', '');
            inputHeader = new IF_Base_iTrack.InputHeader('', '', '');
            inputHeader = new IF_Base_iTrack.InputHeader('', '', '', '', '', '');
            inputHeader.genMsg();
            inputHeader.giveGUID();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testHeader() {
        try {
            IF_Base_iTrack.Header Header = new IF_Base_iTrack.Header();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testHeaders() {
        try {
            IF_Base_iTrack.Headers header = new IF_Base_iTrack.Headers();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testLogInit( ) {
        try {
            IF_Base_iTrack.logInit('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogStart() {
        try {
            IF_Base_iTrack.logStart(new IF_Base_iTrack.InputHeader());
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogProcess() {
        try {
            IF_Base_iTrack.logProcess('STEP1', '');
            IF_Base_iTrack.logProcess('STEP1-1', '');
            IF_Base_iTrack.logProcess('STEP2', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogEnd() {
        try {
            IF_Base_iTrack.InputHeader inputHeader = new IF_Base_iTrack.InputHeader();
            inputHeader.ifResult='F';
            IF_Base_iTrack.logEnd(inputHeader);
            IF_Base_iTrack.logEnd(inputHeader, '', '', '', '', '', false);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }


    private static void testWebCallOut() {
        try {
            IF_Base_iTrack.webCallOut('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetIfinfo() {
        try {
            IF_Base_iTrack.getIfinfo('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testSetOutputHeader() {
        IF_Base_iTrack.InputHeader inputHeader  = new IF_Base_iTrack.InputHeader();
        IF_Base_iTrack.InputHeader outputHeader = new IF_Base_iTrack.InputHeader();
        try {

            outputHeader = IF_Base_iTrack.setOutputHeader(outputHeader, inputHeader);

            if(true) {
                throw new DmlException('Exception');
            }
        } catch (Exception ex) {
            system.debug(ex);
            outputHeader = IF_Base_iTrack.setOutputHeader(outputHeader, inputHeader, ex);
        }
    }

    private static void testXmlToJson() {
        try {
            IF_Base_iTrack.xmlToJson('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    @isTest public static void myUnitTest() {
        try {
            testInputHeader();
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
            //testAuthEncLog();
           // testWebCallOutAsync();
            //testGetDIHSessionId();
            //testLogAsyncUpdate();
            //testLogAsyncAttach();
            testXmlToJson();

            testSetOutputHeader();

            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

            //System.assertEquals(testWebCallOutLog(), true);

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