/****************************************************************************************
* @filename      : LookupFieldController
* @projectname   : PMK LocalDCE QA
* @author        : Javier Chaos
* @date          : 2/22/21 3:51 PM
* @group         : Common
* @group-content :
* @description   : Custom Lookup Field enabling users to add a new record when referencing lookup field
* @tester        : i2max_Sukun
* @reference     :
* @copyright     : Copyright @ Javier Chaos https://github.com/Chaos-Tech-Corp/Input-Field-Lookup/blob/master/src/lookupField.cmp
* @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2/22/21 3:51 PM            i2max_Sukun           Create
 0.2     3/2/21                     i2max_Sukun           Update
 0.3     3/9/21                     i2max_Sukun           Update
 ****************************************************************************************/
public with Sharing class LookupFieldController {
    @AuraEnabled
    public static List<sObject> GetRecentRecords(String ObjectName, List<String> ReturnFields, Integer MaxResults) {

        List<Id> recentIds = new List<Id>();
        for(RecentlyViewed recent : [SELECT Id FROM RecentlyViewed WHERE Type = :ObjectName ORDER BY LastViewedDate DESC LIMIT :MaxResults]) {
            recentIds.add(recent.Id);
        }

        String sQUERY = 'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE Id IN :recentIds';

        List<sObject> searchResult = Database.query(sQuery);

        System.debug('query : ' + sQUERY);
        System.debug('results : ' + searchResult);

        return searchResult;
    }

    @AuraEnabled
    public static List<sObject> SearchRecordsSOQL(String ObjectName, List<String> ReturnFields, List<String> QueryFields, String SearchText, String SortColumn, String SortOrder, Integer MaxResults, String Filter) {

        //always put a limit on the results
        if (MaxResults == null || MaxResults == 0) {
            MaxResults = 5;
        }

        SearchText = '%' + SearchText + '%';

        List <sObject > returnList = new List < sObject > ();

        String sQuery =  'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE ';

        if (QueryFields == null || QueryFields.isEmpty()) {
            sQuery += ' Name LIKE :SearchText ';
        } else {
            string likeField = '';
            for(string field : QueryFields) {
                likeField += ' OR ' + field + ' LIKE :SearchText ';
            }
            sQuery += ' (' + likeField.removeStart(' OR ') + ') ';
        }

        if (Filter != null) {
            sQuery += ' AND (' + Filter + ')'; // filter Usage: 'fieldAPI=#somethingConditionValue'
        }

        if(string.isNotBlank(SortColumn) && string.isNotBlank(SortOrder)) {
            sQuery += ' ORDER BY ' + SortColumn + ' ' + SortOrder;
        }

        sQuery += ' LIMIT ' + MaxResults;

        System.debug(sQuery);

        List <sObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static List<SObject> SearchRecordsSOSL(String ObjectName, List<String> ReturnFields, String Filter, String SearchText, String SortColumn, String SortOrder, Integer MaxResults) {

        //always put a limit on the results
        if (MaxResults == null || MaxResults == 0) {
            MaxResults = 5;
        }


        List<SObject> returnList = new List<SObject> ();

        String sQuery = 'FIND :SearchText IN ALL FIELDS RETURNING ' + ObjectName;
        sQuery += ' (';
        sQuery += Util.isNotEmpty(ReturnFields) ? String.join(ReturnFields, ', ') + ', Id' : 'Id';
        sQuery += String.isNotBlank(Filter)? ' WHERE ' + Filter : '';

        if(string.isNotBlank(SortColumn) && string.isNotBlank(SortOrder)) {
            sQuery += ' ORDER BY ' + SortColumn + ' ' + SortOrder;
        }
        sQuery += ')';


        sQuery += ' LIMIT ' + MaxResults;

        System.debug(sQuery);

        List<List<SObject>> searchResult = Search.query(sQuery);

        for(List<SObject> objList : searchResult){
            returnList.addAll(objList);
        }

        return returnList;
    }

    @AuraEnabled
    public static List<sObject> GetRecord(String ObjectName, List<String> ReturnFields, String Id) {
        String sQUERY = 'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE Id = :Id';

        List<sObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static string findObjectIcon(String ObjectName) {
        String u;
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult describeTabSetResult : Schema.describeTabs()) {
            for(Schema.DescribeTabResult describeTabResult : describeTabSetResult.getTabs()) {
                if(describeTabResult.getSobjectName() == ObjectName) {
                    if( describeTabResult.isCustom() == true ) {
                        for (Schema.DescribeIconResult describeIcon : describeTabResult.getIcons()) {
                            if (describeIcon.getContentType() == 'image/svg+xml'){
                                return 'custom:' + describeIcon.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                            }
                        }
                    } else {
                        return getIconLocationParamForStandardObj(ObjectName);
                    }
                }
            }
        }

        return 'standard:default';
    }

    @AuraEnabled
    public static objectDetails getObjectDetails(String ObjectName) {

        objectDetails details = new objectDetails();

        Schema.DescribeSObjectResult describeSobjectsResult = Schema.describeSObjects(new List<String>{ObjectName})[0];

        details.label = describeSobjectsResult.getLabel();
        details.pluralLabel = describeSobjectsResult.getLabelPlural();

        details.iconName = findObjectIcon(ObjectName);

        return details;
    }

    public class objectDetails {
        @AuraEnabled
        public string iconName;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string pluralLabel;
    }

    @AuraEnabled
    public static Map<String, List<String>> getEncryptedFieldsMap(){
        Map<String, List<String>> returnMap = new Map<String, List<String>>();
        List<String> encryptedFields;
        String objName;
        for (Schema.SObjectType object_i : Schema.getGlobalDescribe().values()) {
            objName = object_i.getDescribe().getName();
            for (Schema.SObjectField field_i : object_i.getDescribe().fields.getMap().values()) {
                if (field_i.getDescribe().isEncrypted()) {
                    encryptedFields = returnMap.containsKey(objName) ? returnMap.get(objName) : new List<String>();
                    encryptedFields.add(field_i.getDescribe().getName());
                    returnMap.put(objName, encryptedFields);
                }
            }
        }
        return returnMap;
    }

    @AuraEnabled
    public static string getIconLocationparamForStandardObj(String objName){
        String iconLocationParam;
        try {
            Map<List<String>, Integer> abnormalObjListFilterMap = new Map<List<String>, Integer>();
            // genrally iconLocationParam should be standard:somethingobjectname
            // if icon location param should be differentiated, put new objectname list key and filter number to generate the correct param
            List<String> firstFilterString = new List<String>();
            firstFilterString.add('asset');

            abnormalObjListFilterMap.put(firstFilterString,1);

            Integer filterCategory;
            for(List<String> objectListKey : abnormalObjListFilterMap.keySet()) {
                filterCategory = objectListKey.contains(objName.toLowerCase()) ? abnormalObjListFilterMap.get(objectListKey) : 0;
            }

            switch on filterCategory {
                when  1 {
                    iconLocationParam = 'standard:'+objName.toLowerCase()+'_object';
                }
                // when 2, 3...
                when else {
                    iconLocationParam = 'standard:' + objName.toLowerCase();  
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return iconLocationParam;
    }
}