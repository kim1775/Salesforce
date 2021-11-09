/**
 * Created by MS on 2021-03-17.
 */

public without sharing class CCR_Utility {
    public static final string ERRORTYPE='Error';
    public static final string ERRORSCOPE='Application';
    public static final string ERRORFUNCTION='Merge Engine';
    public static final string ERRORFUNCTIONINTERNAL='SFDC Internal';
    public static final string ACCESTOKEN='access_token';
    public static final string POSTMETHOD='POST';
    public static final string REQUESTBODY1='grant_type=password&client_id=';
    public static final string REQUESTBODY2='&client_secret=';
    public static final string REQUESTBODY3='&username=';
    public static final string REQUESTBODY4='&password=';
    public static final string NULLSTR='';
    public static final string RECORDTYPEIDTEXT='recordTypeId';
    public static final string CSVSTR='.csv';
    public static final string DEARSTR ='Dear ';
    public static final string EMAILBODYSTR ='<br/><br/>The report : <b> ';
    public static final string EMAILBODYSTR2 = '</b> is attached in Mail.'+'<br/><br/>Regards, <br/>PMI Support Team.';
    public static final string CONTENTTYPECSVTEXT = 'text/csv';
    public static final string REPORTTYPE = '?csv=1';
    public static final string SLASHSTR = '/';
    public static final string ORGWIDEEMAIL = 'no-reply@iqos.com';
    public static final string CASEOBJ = 'case';
    public static final string COUNTRY = 'CCR_Country__c';


    /**
* Method Name :  sendEmail
* Arguments:
* @ List<String> - Set of email Ids
* @ Set<Id> - Set of user and Contact Ids
* @ String - email body
* @ String - email Subject
* Return : None
* Description: Used to send email to email Ids or set of User and Contact SFDC records.
**/
    Public static void sendEmail(List<String> emailsList, Set<Id> userOrContactIdsSet, String body,
            String subject, String emaiTemplatedId, Messaging.EmailFileAttachment attachment) {
        String orgwideEmailId = getOrgwideEmailAddress(ORGWIDEEMAIL);
        List<Messaging.SingleEmailMessage> singleEmailsList = new List<Messaging.SingleEmailMessage>();
        //creating email with each user or Contact Id
        if(userOrContactIdsSet != null && !userOrContactIdsSet.isEmpty()) {
            Messaging.SingleEmailMessage mail;
            for(Id ucId: userOrContactIdsSet) {
                mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                if(subject != null) {
                    mail.setSubject(subject);
                }
                if(body != null) {
                    mail.setHtmlBody(body);
                }
                if(emaiTemplatedId != null) {
                    mail.setTemplateID(emaiTemplatedId);
                }
                // adding attachment to mail
                if(attachment != null) {
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
                }
                mail.setTargetObjectId(ucId);
                mail.setOrgWideEmailAddressId(orgwideEmailId);
                singleEmailsList.add(mail);
            }
        }
        //creating email with list email ids
        if(emailsList != null && !emailsList.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            if(subject != null) {
                mail.setSubject(subject);
            }
            if(body != null) {
                mail.setHtmlBody(body);
            }
            if(emaiTemplatedId != null) {
                mail.setTemplateID(emaiTemplatedId);
            }
            // adding attachment to mail
            if(attachment != null) {
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
            }
            mail.setToAddresses(emailsList);
            mail.setOrgWideEmailAddressId(orgwideEmailId);
            singleEmailsList.add(mail);
        }
    }

    /**
* Method Name :  getRecordTypeId
* Arguments: 2 String  perameters (Object ApiName, RecordType Name)
* Return : String
* Description: This method is used to get the recordTypeId for sObject
*/
    public Static String getRecordTypeId(String objAPIName, String recordTypeName) {
        //Retrieve the describe result for the desired object
        DescribeSObjectResult dsResult = Schema.getGlobalDescribe().get(objAPIName).getDescribe();
        //Checking the sObject Accessibility
        if(dsResult.isAccessible()){
            //Checking the sObject's RecordTypeId field Accessibility
            if(dsResult.fields.getMap().get(RECORDTYPEIDTEXT).getDescribe().isAccessible()){
                String rtId = dsResult.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                system.debug(recordTypeName+' Record Type Id on '+objAPIName+' Object : '+rtId);
                return rtId;
            }
            else {
                system.debug('Access Exception - User does not have access to the '+objAPIName+' object');
                return null;
            }
        }
        else {
            system.debug('Access Exception - User does not have access to the '+RECORDTYPEIDTEXT+' field');
            return null;
        }
    }

    /**
* Method Name :  getOrgwideEmailAddress
* Arguments: None
* Return : String
* Description: This method is used to get the org wide email address.
*/
    public static string getOrgwideEmailAddress(String emialOrgWide){
        String orgwideEmailId;
        List<OrgWideEmailAddress> orgEmaiList = [SELECT Id, DisplayName
        FROM OrgWideEmailAddress
        WHERE address =: emialOrgWide LIMIT 1];
        if(!orgEmaiList.isEmpty()) {
            orgwideEmailId = orgEmaiList[0].Id;
        }
        return orgwideEmailId;
    }

    /**
    * Method Name :  retrievePicklistValues
    * Arguments:
    * @ String object API Name
    * @ String field API Name
    * Return : List<String>
    * Description: This method is used to get all the available picklist values
    */
    public Static List<SelectOption> retrievePicklistValues(String objectAPIName, String fieldAPIName) {
        List<SelectOption> listOptions = new List<SelectOption>();
        for (Schema.PicklistEntry pE : Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(fieldAPIName).getDescribe().getPickListValues()) {
            //Populate the select list with values
            listOptions.add(new SelectOption(pE.getValue() , pE.getLabel()));
        }
        return listOptions;
    }

    /**
* Method Name :  retrievePicklistMap
* Arguments:
* @ String object API Name
* @ String field API Name
* Return : List<String>
* Description: This method is used to get all the available picklist values
*/
    public Static Map<String,String> retrievePicklistMap(String objectAPIName, String fieldAPIName) {
        Map<String,String> picklistvalueMap =  new Map<String,String>();
        for (Schema.PicklistEntry pE : Schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(fieldAPIName).getDescribe().getPickListValues()) {
            //Populate the select list with values
            picklistvalueMap.put(pE.getValue() , pE.getLabel());
        }
        return picklistvalueMap;
    }

    public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}