/**
 * Created by MS on 2021-03-17.
 */

Public without sharing class CCR_ErrorLogUtility { 
    private static String emailBody = 'Hi, <br/><br/> System is failed to insert Error Log record, please see the issue below.<br/>';
    private static final String EMAILSUBJECT ='Error Record insertion Failed.';
    private static final String REGARDS= 'Regards<br/>PMI Support Team.';
    private static final String DESCRIPTION = '<br/>Description: ';
    private static final String CLASSNAME = '<br/>Class name: ';
    private static final String SEVERITY = '<br/>Severity: ';
    private static final String FUNCTIONCC = '<br/>Function: ';
    private static final String SCOPECC = '<br/>Scope: ';
    private static final String LINEBREAK = '<br/><br/>';
    private static final String BLANKTEXT = '';
    private static final String EMAILID = 'test@email.com';
    private static final String ORGID = '<br/>Organization ID: ';
    private static final String USERID = '<br/>User ID: ';
    private static final String USERNAME = '<br/>User Name: ';
    public static final string NEWLINETEXT='\\n';
    public static final String BRAKETTEXT='()';

    /**
* Method Name :  createErrorLogRecord
* Arguments:
@ Exception - exception referance
@ String - Error Type like Information, Error, Fatal
@ String - scope like Integration and Application
@ String - function like Linking Engine, Replacement Engine, SPICE Integration
* Return : None
* Description: Used to insert the Error Log type record.
**/
    Public static void createExceptionLog(Exception excRef, String errorType, String scope, String function) {
        DTE_ErrorLog__c objRef =new DTE_ErrorLog__c();
        try {
            if(excRef != null) {
                //Description modified by Samanway to get stack trace
                objRef.DTE_Description__c=excRef.getMessage() + excRef.getStackTraceString();
                List<String> stackString = excRef.getStackTraceString().split(CCR_Constants.COLAN)[0].split(CCR_Constants.DOT);
                If (excRef.getStackTraceString().replaceall(NEWLINETEXT,BLANKTEXT)!=BRAKETTEXT) {
                    objRef.CCR_ClassName__c = stackString[1];
                    objRef.DTE_Method__c = stackString[2];
                }
                objRef.CCR_Severity__c=errorType;
                objRef.CCR_Function__c=function;
                objRef.CCR_Scope__c=scope;
                Database.insert(objRef );
            }
        }
        catch(Exception exp) {
            emailBody += buildMailBody(objRef);
            emailBody += exp.getMessage();
            emailBody += REGARDS;
            CCR_Utility.sendEmail(new List<String> {EMAILID},new Set<Id> {}, emailBody,EMAILSUBJECT, null, null);
        }
    }

    /**
* Method Name :  createErrorLogRecord
* Arguments: Exception
@ String - Error Message
@ String - Class Name
@ String - Method Name
@ String - Error Type
@ String - Scope like Integration and Application
@ String - Function like Linking Engine, Replacement Engine, SPICE Integration
* Return : None
* Description: Used to insert the Error Log type record.
**/
    Public static void createErrorLog(String errorMsg, String clsName, String methodName,String errorType, String scope, String function){
        System.debug('CCR_ErrorLogUtility createErrorLog Start');
        createErrorLog(errorMsg, clsName, methodName, errorType, scope, function, null);
        System.debug('CCR_ErrorLogUtility createErrorLog End');
    }
    /**
* Method Name :  buildMailBody
* Arguments: DTE_ErrorLog__c - custom object
* Return : String
* Description: Used to set the data in to DTE_ErrorLog__c.
**/
    Private static String buildMailBody(DTE_ErrorLog__c objRef) {
        String ebody = BLANKTEXT;
        ebody += ORGID+userInfo.getOrganizationId();
        ebody += USERID+userInfo.getUserId();
        ebody += USERNAME+userInfo.getUserName();
        ebody += DESCRIPTION+objRef.DTE_Description__c;
        ebody += +objRef.CCR_ClassName__c;
        ebody += CLASSNAME+objRef.DTE_Method__c;
        ebody += SEVERITY+objRef.CCR_Severity__c;
        ebody += FUNCTIONCC+objRef.CCR_Function__c;
        ebody += SCOPECC+objRef.CCR_Scope__c+LINEBREAK;
        return ebody;
    }


    /**
* Method Name :  createErrorLogRecord
* Arguments: Exception
@ String - Error Message
@ String - Class Name
@ String - Method Name
@ String - Error Type
@ String - Scope like Integration and Application
@ String - Function like Linking Engine, Replacement Engine, SPICE Integration
@ String - Id of contact if any
* Return : None
* Description: Used to insert the Error Log type record.
**/
    Public static void createErrorLog(String errorMsg, String clsName, String methodName,String errorType, String scope, String function, String contactId){
        System.debug('CCR_ErrorLogUtility createErrorLog Start');
        DTE_ErrorLog__c objRef =new DTE_ErrorLog__c();
        try {
            objRef.DTE_Description__c=errorMsg;
            objRef.CCR_ClassName__c = clsName;
            objRef.DTE_Method__c = methodName;
            objRef.CCR_Severity__c=errorType;
            objRef.CCR_Function__c=function;
            objRef.CCR_Scope__c=scope;
            objRef.CCR_ContactId__c=contactId;
            insert objRef;
        }
        catch(DmlException exp) {
            emailBody += buildMailBody(objRef);
            emailBody += REGARDS;
            CCR_Utility.sendEmail(new List<String> {EMAILID},Null, emailBody,emailSubject, null, null);
        }
        System.debug('CCR_ErrorLogUtility createErrorLog End');
    }

    /**
* Method Name :  createErrorLogRecord
* Arguments: Exception
@ String - Error Message
@ String - Class Name
@ String - Method Name
@ String - Error Type
@ String - Scope like Integration and Application
@ String - Function like Linking Engine, Replacement Engine, SPICE Integration
@ String - Id of contact if any
* Return : None
* Description: Used to insert the Error Log type record.
**/
    public static void createErrorLog(String errorMsg, String clsName, String methodName,String severity, String scope, String function, String contactId,
            String country, String shiftCode, String errorType, String spiceId, String logId, String internalErrorCode,
            String internalRequests) {

        DTE_ErrorLog__c objRef =new DTE_ErrorLog__c();
        try {
            objRef.DTE_Description__c=errorMsg;
            objRef.CCR_ClassName__c = clsName;
            objRef.DTE_Method__c = methodName;
            objRef.CCR_Severity__c=severity;
            objRef.CCR_Function__c=function;
            objRef.CCR_Scope__c=scope;
            objRef.CCR_ContactId__c=contactId;
            objRef.CAA_Country__c = country;
            objRef.CAA_Error_Type__c = errorType;
            objRef.CAA_Shift_Code__c = shiftCode;
            objRef.CAA_Contact_SPICE_ID__c = spiceId;
            objRef.Log_Id__c = logId;
            objRef.CAA_Internal_Error_Code__c = internalErrorCode;
            objRef.CAA_Outbound_API_Request_Response_RAW__c = internalRequests;
            insert objRef;
        }
        catch(DmlException exp) {
            System.debug('Exception in createErrorLog: ' + exp.getMessage() + ' | ' + exp.getLineNumber());
            //emailBody += buildMailBody(objRef);
            //emailBody += REGARDS;
            //CCR_Utility.sendEmail(new List<String> {EMAILID},Null, emailBody,emailSubject);
        }

    }

    /**
* Method Name :  errorLogParameters
* Arguments: Exception
@ String - Error Message
@ String - Class Name
@ String - Method Name
@ String - Error Type
@ String - Scope like Integration and Application
@ String - Function like Linking Engine, Replacement Engine, SPICE Integration
* Return : None
* Description: Used to insert the Error Log type record.
**/
    Public static DTE_ErrorLog__c errorLogParameters(String errorMsg, String clsName, String methodName,String errorType, String scope, String function){
        DTE_ErrorLog__c objRef = new DTE_ErrorLog__c();
        objRef.DTE_Description__c = errorMsg;
        objRef.CCR_ClassName__c = clsName;
        objRef.DTE_Method__c = methodName;
        objRef.CCR_Severity__c = errorType;
        objRef.CCR_Function__c = function;
        objRef.CCR_Scope__c = scope;
        return objRef;
    }

    /**
* Method Name :  createErrorLog
* Arguments: List<DTE_ErrorLog__c>
* Return : None
* Description: Used to insert the Error Log type record.
**/
    Public static void createErrorLog(list<DTE_ErrorLog__c> errorLogList){
        try {
            if(errorLogList != null && !errorLogList.isEmpty()) {
                insert errorLogList;
            }
        } catch(Exception exp) {
            System.debug('Exception in createErrorLog: ' + exp.getMessage() + ' | ' + exp.getLineNumber());
        }
    }

    /**
    * Method Name :  createExceptionLog
    * Arguments:
      @ Exception - exception referance
      @ String - Error Type like Information, Error, Fatal
      @ String - scope like Integration and Application
      @ String - function like Linking Engine, Replacement Engine, SPICE Integration
    * Return : None
    * Description: Used to insert the Error Log type record.
    **/
    Public static void createExceptionLog(Exception excRef, String errorType, String scope, String function, String logId, String appVersion, String interactionId) {
        DTE_ErrorLog__c objRef =new DTE_ErrorLog__c();
        try {
            if(excRef != null) {
                objRef.DTE_Description__c=excRef.getMessage();
                List<String> stackString = excRef.getStackTraceString().split(CCR_Constants.COLAN)[0].split(CCR_Constants.DOT);
                If (excRef.getStackTraceString().replaceall(NEWLINETEXT,BLANKTEXT)!=BRAKETTEXT) {
                    objRef.CCR_ClassName__c = stackString[1];
                    objRef.DTE_Method__c = stackString[2];
                }
                objRef.CCR_Severity__c=errorType;
                objRef.CCR_Function__c=function;
                objRef.CCR_Scope__c=scope;

                objRef.Log_Id__c = logId;
                objRef.CAA_App_Version__c = appVersion;
                objRef.CAA_Interaction_Id__c = interactionId;

                Database.insert(objRef );
            }
        }
        catch(DMLException exp) {
            emailBody += buildMailBody(objRef);
            emailBody += exp.getMessage();
            emailBody += REGARDS;
            CCR_Utility.sendEmail(new List<String> {EMAILID},new Set<Id> {}, emailBody,EMAILSUBJECT, null, null);
        }catch(Exception exp) {
            emailBody += buildMailBody(objRef);
            emailBody += exp.getMessage();
            emailBody += REGARDS;
            CCR_Utility.sendEmail(new List<String> {EMAILID},new Set<Id> {}, emailBody,EMAILSUBJECT, null, null);
        }
    }

    /**
    * Method Name :  createErrorLog
    * Arguments: Exception
      @ String - Error Message
      @ String - Class Name
      @ String - Method Name
      @ String - Error Type
      @ String - Scope like Integration and Application
      @ String - Function like Linking Engine, Replacement Engine, SPICE Integration
      @ String - Id of contact if any
    * Return : None
    * Description: Used to insert the Error Log type record.
    **/
    public static void createErrorLog(String errorMsg, String clsName, String methodName,String severity, String scope, String function, String contactId,
            String country, String shiftCode, String errorType, String spiceId, String logId, String internalErrorCode,
            String internalRequests, String appVersion, String interactionId) {

        DTE_ErrorLog__c objRef =new DTE_ErrorLog__c();
        try {
            objRef.DTE_Description__c=errorMsg;
            objRef.CCR_ClassName__c = clsName;
            objRef.DTE_Method__c = methodName;
            objRef.CCR_Severity__c=severity;
            objRef.CCR_Function__c=function;
            objRef.CCR_Scope__c=scope;
            objRef.CCR_ContactId__c=contactId;
            objRef.CAA_Country__c = country;
            objRef.CAA_Error_Type__c = errorType;
            objRef.CAA_Shift_Code__c = shiftCode;
            objRef.CAA_Contact_SPICE_ID__c = spiceId;
            objRef.Log_Id__c = logId;
            objRef.CAA_Internal_Error_Code__c = internalErrorCode;
            objRef.CAA_Outbound_API_Request_Response_RAW__c = internalRequests;
            objRef.CAA_App_Version__c = appVersion;
            objRef.CAA_Interaction_Id__c = interactionId;

            insert objRef;
        }
        catch(DmlException exp) {
            System.debug('Exception in createErrorLog: ' + exp.getMessage() + ' | ' + exp.getLineNumber());
            //emailBody += buildMailBody(objRef);
            //emailBody += REGARDS;
            //CCR_Utility.sendEmail(new List<String> {EMAILID},Null, emailBody,emailSubject);
        }catch(Exception exp) {
            System.debug('Exception in createErrorLog: ' + exp.getMessage() + ' | ' + exp.getLineNumber());
            //emailBody += buildMailBody(objRef);
            //emailBody += REGARDS;
            //CCR_Utility.sendEmail(new List<String> {EMAILID},Null, emailBody,emailSubject);
        }

    }
    /**
* Method Name :  createErrorLog
* Arguments: Database.SaveResult[] results, String clsName, String methodName, String errorType, String scope, String function
* Return : None
* Description: Used to insert the Error Log type record.
**/
    Public static void createErrorLog (Database.SaveResult[] results, String clsName, String methodName, String errorType, String scope, String function){
        List<DTE_ErrorLog__c> objRefList =new List<DTE_ErrorLog__c>();
        try{
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {

                    for(Database.Error err : sr.getErrors()) {
                        DTE_ErrorLog__c objRef =new DTE_ErrorLog__c();
                        objRef.DTE_Description__c = String.valueOf(err.getMessage());
                        objRef.CCR_ClassName__c = clsName;
                        objRef.DTE_Method__c = methodName;
                        objRef.CCR_Severity__c=errorType;
                        objRef.CCR_Function__c=function;
                        objRef.CCR_Scope__c=scope;
                        objRefList.add(objRef);
                        System.debug(err.getMessage());

                    }
                }
            }
            insert objRefList;
        }
        catch(DmlException exp) {
            for(DTE_ErrorLog__c objRefRec:objRefList) {
                emailBody += buildMailBody(objRefRec); }
            emailBody += REGARDS;
            CCR_Utility.sendEmail(new List<String> {EMAILID},Null, emailBody,emailSubject, null, null);
        }
    }
    /**
* Method Name :  createErrorLog
* Arguments: Database.DeleteResult[] results, String clsName, String methodName, String errorType, String scope, String function
* Return : None
* Description: Used to insert the Error Log type record.
**/
    Public static void createErrorLog (Database.DeleteResult[] results, String clsName, String methodName, String errorType, String scope, String function){
        List<DTE_ErrorLog__c> objRefList =new List<DTE_ErrorLog__c>();
        try{
            for (Database.DeleteResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        DTE_ErrorLog__c objRef =new DTE_ErrorLog__c();
                        objRef.DTE_Description__c = String.valueOf(err.getMessage());
                        objRef.CCR_ClassName__c = clsName;
                        objRef.DTE_Method__c = methodName;
                        objRef.CCR_Severity__c=errorType;
                        objRef.CCR_Function__c=function;
                        objRef.CCR_Scope__c=scope;
                        objRefList.add(objRef);
                        System.debug(err.getMessage());

                    }
                }
            }
            insert objRefList;
        }
        catch(DmlException exp) {
            for(DTE_ErrorLog__c objRefRec:objRefList) {
                emailBody += buildMailBody(objRefRec); }
            emailBody += REGARDS;
            CCR_Utility.sendEmail(new List<String> {EMAILID},Null, emailBody,emailSubject, null, null);
        }

    }

    /**
* Method Name :  createDeviceErrorLog
* Arguments:
* Return : None
* Description: Used to insert the Device Error Log type record.
**/
    public static void createDeviceErrorLog(String className, String methodName, String codentify, String errorMsg, String newCodentify,
            String requestString, String responseString, String contactExternalId, ID integrationUser) {
        CCR_DeviceError__c log = new CCR_DeviceError__c();
        log.CCR_ClassName__c = className;
        log.CCR_MethodName__c = methodName;
        log.CCR_Codentify__c = codentify;
        log.CCR_NewDeviceCodentify__c = newCodentify;
        log.CCR_Contact_SPICE_ID__c = contactExternalId;
        log.CCR_Error_Message__c = errorMsg;
        log.CCR_IntegrationUser__c = integrationUser;
        log.CCR_Request_JSON__c = requestString;
        log.CCR_Response_JSON__c = responseString;
        try {
            insert log;
        } catch(DmlException e) {
            System.debug(e.getMessage());
        }
    }
}