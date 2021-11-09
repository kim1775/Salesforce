/**
 * Created by I2MAX on 2021-07-20.
 */

@IsTest(seealldata=false)
private class CCR_ErrorLogUtility_ts {
    static final string SCOPE='Integration';
    static final string FUNCTION='Linking Engine';
    static final string TESTFUNCTION='test Engine';
    static final string ERRORTYPE='Error';
    static final string ERRORMSG='Error Message';
    static final string METHODNAME='Test Method';
    static final string CLASSNAME='Test Class';

    static final String APPVERSION = '0.0.00';
    /* Method Name: testErrorLogUtility;
* Arguments :
* Return :
* Description : method testing whole CCR_testErrorLogUtility class
*/
    static testMethod void testErrorLogUtility() {

        String invalidContactIdString = 'this is too long string and invalid contact Id that will throw exception while trying to save this record';

        try{
            Integer.valueOf('error');
        }catch(Exception ex){
            CCR_ErrorLogUtility.createExceptionLog(ex, ERRORTYPE, SCOPE, FUNCTION);
            CCR_ErrorLogUtility.createErrorLog(ERRORMSG, CLASSNAME, METHODNAME, ERRORTYPE, SCOPE, FUNCTION);
            CCR_ErrorLogUtility.createErrorLog(ERRORMSG, CLASSNAME, METHODNAME, ERRORTYPE, SCOPE, FUNCTION, null,
                    'country', 'shift', 'type', 'spiceId', null, 'internalErrorCode', 'internalRequests');
            CCR_ErrorLogUtility.errorLogParameters(ERRORMSG, CLASSNAME, METHODNAME, ERRORTYPE, SCOPE, FUNCTION);
            CCR_ErrorLogUtility.createExceptionLog(ex, ERRORTYPE, SCOPE, FUNCTION, null, APPVERSION, 'interactionId');
            CCR_ErrorLogUtility.createErrorLog(ERRORMSG, CLASSNAME, METHODNAME, ERRORTYPE, SCOPE, FUNCTION, null,'country', 'shift', 'type',
                    'spiceId', null, 'internalErrorCode', 'internalRequests', APPVERSION, 'interactionId');
            integer numberOfLogs = [SELECT count() FROM DTE_ErrorLog__c];
            System.assert(numberOfLogs != 0);
            CCR_ErrorLogUtility.createErrorLog(ERRORMSG, CLASSNAME, METHODNAME, ERRORTYPE, SCOPE, FUNCTION, invalidContactIdString);
            integer numberOfLogsAfterException = [SELECT count() FROM DTE_ErrorLog__c];
            System.assert(numberOfLogs == numberOfLogsAfterException);
        }
        List<DTE_ErrorLog__c> errorLogList = new List<DTE_ErrorLog__c>();
        errorLogList.add(new DTE_ErrorLog__c());
        CCR_ErrorLogUtility.createErrorLog(errorLogList);

        DTE_ErrorLog__c errorLog = new DTE_ErrorLog__c();
        errorLog.CCR_ContactId__c = invalidContactIdString;
        List<DTE_ErrorLog__c> invalidErrorLogList = new List<DTE_ErrorLog__c>();
        invalidErrorLogList.add(errorLog);
        Database.SaveResult[] insertResults = Database.insert(invalidErrorLogList, false);
        CCR_ErrorLogUtility.createErrorLog (insertResults, CLASSNAME, METHODNAME, ERRORTYPE, SCOPE, FUNCTION);

        errorLog.CCR_ContactId__c = null;
        insert errorLog;
        delete errorLog;
        invalidErrorLogList = new List<DTE_ErrorLog__c>();
        invalidErrorLogList.add(errorLog);
        Database.DeleteResult[] deleteResults = Database.delete(invalidErrorLogList, false);
        CCR_ErrorLogUtility.createErrorLog (deleteResults, CLASSNAME, METHODNAME, ERRORTYPE, SCOPE, FUNCTION);
        List<String> emList = new List<String>();
        emList.add('test@email.com');
        Set<Id> ids = new Set<Id>();
        CCR_Utility.sendEmail(emList, ids, 'testBody', 'Title', null, null);
        CCR_Utility.testRun();
    }
}