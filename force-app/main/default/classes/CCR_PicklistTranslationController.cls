/**
 * Created by I2MAX on 2021-04-28.
 */

public without sharing class CCR_PicklistTranslationController {
    public String picklistValue {get; private set;}

    /*Constructor*/
    public CCR_PicklistTranslationController(){
        try{
            String objectName = ApexPages.currentPage().getParameters().get('object').escapeHtml4();
            String fieldName = ApexPages.currentPage().getParameters().get('field').escapeHtml4();
            String picklistApiName = ApexPages.currentPage().getParameters().get('value').escapeHtml4();
            picklistValue = CCR_Utility.retrievePicklistMap(objectName, fieldName).get(picklistApiName);
        }catch(Exception ex){
            System.debug('Error == ' + ex);
        }
    }

    /**
    * @ Method Name :  getEnglishValue
    * @ Arguments:
    * @ Param 1: String Object API Name
    * @ Param 2: Field API Name
    * @ Param 3: Piclist Value API name
    * @ Description: Method to get the english version of the picklist value.
    **/
    public Static String getEnglishValue(String objectName, String fieldName, String picklistApiName){
        try{
            PageReference translation = Page.CCR_PicklistTranslations;
            translation.getParameters().put('object', objectName).escapeHtml4();
            translation.getParameters().put('field', fieldName).escapeHtml4();
            translation.getParameters().put('value', picklistApiName).escapeHtml4();
            return translation.getContent().toString().stripHtmlTags();
        }catch(Exception ex){
            return null;
        }
    }
}