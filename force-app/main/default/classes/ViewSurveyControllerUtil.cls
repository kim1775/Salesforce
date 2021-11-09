/****************************************************************************************
  * @filename      : ViewSurveyControllerUtil
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-07-25 오후 4:45
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-07-25 오후 4:45     i2max_Jihyun.Lee        Create
****************************************************************************************/

global virtual without sharing class ViewSurveyControllerUtil {

    public static Boolean checkDuplicate(Id surveyId, Id caseId, Id contactId) {
        System.debug('=== surveyId : ' + surveyId);
        System.debug('=== caseId : ' + caseId);
        System.debug('=== contactId : ' + contactId);
        Boolean checkDuplicate = false;
        List<SurveyTaker__c> st = [
                SELECT Id, Survey__c, Case__c, Contact__c FROM SurveyTaker__c
                WHERE Survey__c = :surveyId
                AND   Case__c = :caseId
                AND   Contact__c = :contactId
        ];
        System.debug('=== st : ' + st);
        if (st.size() > 0 && caseId != null) checkDuplicate = true;

        return checkDuplicate;
    }
}