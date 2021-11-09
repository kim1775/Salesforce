/****************************************************************************************
  * @filename      :
  * @projectname   :
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-02-08 오후 3:34
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
    0.1     2021-02-08 오후 3:34     i2max_Junseok.Kwon        Create
    0.2     2021-03-03              i2max_Sukun               Update
****************************************************************************************/

global abstract class KDCE_Util extends Util {

    /**
     * @description 긴 한국 시도명을 단축 한국 시도명(카카오 주소API기준)으로 반환한다. 예)서울특별시 > 서울
     * @param krStateName 한국 시도명 (특별시,광역시,특별자치시,도)
     * @return 단축 시도명
     */
    public static String getShortKrState(String krStateName) {
        Map<String, String> KR_ADDRESS_STATE = new Map<String, String>
        {
                '서울특별시'     => '서울',
                '부산광역시'     => '부산',
                '대구광역시'     => '대구',
                '인천광역시'     => '인천',
                '광주광역시'     => '광주',
                '대전광역시'     => '대전',
                '울산광역시'     => '울산',
                '세종특별자치시'  => '세종특별자치시',
                '경기도'       => '경기',
                '강원도'       => '강원',
                '충청북도'      => '충북',
                '충청남도'      => '충남',
                '전라북도'      => '전북',
                '전라남도'      => '전남',
                '경상북도'      => '경북',
                '경상남도'      => '경남',
                '제주특별자치도'  => '제주특별자치도'
        };

        return KR_ADDRESS_STATE.containsKey(krStateName)?KR_ADDRESS_STATE.get(krStateName):krStateName;
    }

    /**
     * @param objName
     *
     * @return Map<String, Id> RecordType Id 별 RecordType DeveloperName
     */
    public static Map<String, Id> getRecordTypeBySObject(String objName) {

        List<RecordType> rtList = [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE SobjectType = :objName
                AND IsActive = TRUE
        ];

        Map<String, Id> rtnMap = new Map<String, Id>();

        for(RecordType rt : rtList){
            rtnMap.put(rt.DeveloperName, rt.Id);
        }

        return rtnMap;
    }

    /**
     * @param objName
     *
     * @return Map<String, Id> RecordType Name별 Id
     */
    public static Map<String, Id> getRecordTypeNameBySObject(String objName) {

        List<RecordType> rtList = [
                SELECT Id, Name, DeveloperName
                FROM RecordType
                WHERE SobjectType = :objName
                AND IsActive = TRUE
        ];

        Map<String, Id> rtnMap = new Map<String, Id>();

        for(RecordType rt : rtList){
            rtnMap.put(rt.Name, rt.Id);
        }

        return rtnMap;
    }

    /**
     * @param objName
     *
     * @return Map<Id, String> RecordType Name 별 RecordType Id
     */
    public static Map<Id, String> getRecordNameBySObject(String objName) {

        List<RecordType> rtList = [
                SELECT Id, DeveloperName, Name
                FROM RecordType
                WHERE SobjectType = :objName
                AND IsActive = TRUE
        ];

        Map<Id, String> rtnMap = new Map<Id, String>();

        for(RecordType rt : rtList){
            rtnMap.put(rt.Id, rt.Name);
        }

        return rtnMap;

    }

    /**
     * @param objName
     *
     * @return Map<String, String> RecordType DeveloperName 별 RecordType Label Name
     */
    public static Map<String, String> getRecordDeveloperNameBySObject(String objName) {

        List<RecordType> rtList = [
                SELECT DeveloperName, toLabel(Name)
                FROM RecordType
                WHERE SobjectType = :objName
                AND IsActive = TRUE
        ];

        Map<String, String> rtnMap = new Map<String, String>();

        for(RecordType rt : rtList){
            rtnMap.put(rt.DeveloperName, rt.Name);
        }

        return rtnMap;

    }

    /**
     * @param objAPIName
     *
     * @return
     */
    public static SObject getSObjectByName(String objAPIName) {
        return (SObject) Type.forName(objAPIName).newInstance();
    }


    /**
     * @param objAPIName
     *
     * @return
     */
   /* public static Map<String, Schema.SObjectField> getSObjectAllFields(String objAPIName) {
        //return Schema.getGlobalDescribe().get(objAPIName).getDescribe().fields.getMap();
        return getSObjectAllFields(objAPIName, true);
    }*/

    /**
     * @param objAPIName
     * @param isIncludeReadOnly
     *
     * @return
     */
    /*public static Map<String, Schema.SObjectField> getSObjectAllFields(String objAPIName, Boolean isIncludeReadOnly) {

        Map<String, Schema.SObjectField> objFieldMap = getSObjectAllFields(objAPIName);
        Set<String> fieldNameSet = objFieldMap.keySet();

        for(String fieldName : fieldNameSet){

            Schema.DescribeFieldResult fr = objFieldMap.get(fieldName).getDescribe();

            if(fieldName == 'Id') {}
            else if(!isIncludeReadOnly && !fr.isUpdateable()) objFieldMap.remove(fieldName);
        }

        return objFieldMap;
    }*/

    /**
     * @param objAPIName
     *
     * @return
     */
    /*public static String getSObjectAllFieldsForQuery(String objAPIName) {

        return getSObjectAllFieldsForQuery(objAPIName, true);
    }*/

    /**
     * @param objAPIName
     * @param isIncludeCalculated Formula, Roll-Up Summary Field 포함 여부
     *
     * @return
     */
   /* public static String getSObjectAllFieldsForQuery(String objAPIName, Boolean isIncludeReadOnly) {

        String fieldString = '';

        Map<String, Schema.SObjectField> objFieldMap = getSObjectAllFields(objAPIName);

        for(String fieldName : objFieldMap.keySet()){

            Schema.DescribeFieldResult fr = objFieldMap.get(fieldName).getDescribe();

            if(fieldName == 'Id') {}
            // 포함하지 않는 경우 Read Only 필드는 제외함
            else if(!isIncludeReadOnly && !fr.isUpdateable()) continue;

            if(fieldString == '') fieldString += fieldName;
            else fieldString += ', ' + fieldName;
        }

        return fieldString;
    }*/


    public Set<String> excludeFieldSet = new Set<String>{
            'isdeleted', 'createddate',  'lastmodifiedbyid', 'createdbyid', 'lastmodifieddate', 'systemmodstamp', 'lastvieweddate', 'lastreferenceddate', 'id'
    };

    /**
     * ddmmyyyyhmsToDate : ex) 17/12/2020 17:51:00.0000000 -> DateTime 변환
     * @param d (DateTime String)
     * @return Datetime
     */
    public static Datetime ddmmyyyyhmsToDate(String d) {
        List<String> result = d.split(' ');
        Integer day = Integer.valueOf(result[0].substring(0, 2));
        Integer month = Integer.valueOf(result[0].substring(3, 5));
        Integer year = Integer.valueOf(result[0].substring(6, 10));

        String timeZoneRemovedString = result[1].substringBetween('', '.');

        List<String> hms = timeZoneRemovedString.split(':');
        Integer h = Integer.valueOf(hms[0]);
        Integer m = Integer.valueOf(hms[1]);
        Integer s = Integer.valueOf(hms[2]);

        return Datetime.newInstance(year, month, day, h, m, s);
    }

    /**
     * findObjectNameFromRecordIdPrefix : Record ID로 Object명 조회
     * @param recordIdOrPrefix : Record ID
     * @return String
     */
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix) {
        String objectName = '';
        try {
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);

            //Get schema information
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

            //Loop through all the sObject types returned by Schema
            for (Schema.SObjectType stype : gd.values()) {
                //if (!sObj.contains('__')) to exclude managed package objects
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);

                //Check if the prefix matches with requested prefix
                if (prefix != null && prefix.equals(myIdPrefix)) {
                    objectName = r.getName();
                    //System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return objectName;
    }

    /**
     * @description Picklist Value 조회
     * @param objectName {String} Object API
     * @param fieldName {String} Field API
     * @return {Map<String,String>} K: Value , V: Label
     */
    global static Map<String,String> getPicklistValue(String objectName, String fieldName ){
        Map<String, String> values = new Map<String, String>{};
        List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(new List<String>{objectName});

        for(Schema.DescribeSObjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        return values;
    }

    /**
     * @description Field Name 으로 Field Label 조회
     * @param objectName {String} Object API
     * @param targetFieldName {String} Field API
     * @return String
     */
    public static String getFieldLabel(String objectName, String targetFieldName){
        String targetFieldLabel;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();

        for (String fieldName : fieldMap.keySet()) {
            if (fieldName == targetFieldName) {
                targetFieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            }
        }
        return targetFieldLabel;
    }

    /**
     * @description secure, one-way hash (e.g. External Id)
     * @param targetValue {String}
     *
     * @return String
     */
    public static String getHashString(String value) {
        String hashString   = String.valueOf(Datetime.now().formatGmt('yyyy-MM-dd HH:mm:ss.SSS'));
        String targetValue  = value != null ? hashString + value : hashString;
        Blob hash           = Crypto.generateDigest('MD5', Blob.valueOf(targetValue));
        String hexDigest    = EncodingUtil.convertToHex(hash);

        return hexDigest;
    }

}