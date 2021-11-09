/****************************************************************************************
  * @filename       : i2SEMA_ManualSendReceiverSearch
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-09 오후 4:51
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_ManualSendReceiverSearch_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-09 오후 4:51     i2max_byeon.jw       Create
****************************************************************************************/
@SuppressWarnings('PMD.ApexSOQLInjection')
public with sharing class i2SEMA_ManualSendReceiverSearch {

    /**
     * @description 특정 Record 에서 하위 Object 목록을 추출. Table 로 표현하기 위해 Header,Value 분리
     *
     * @param reqData {Object} RequestData Object (Managed Package 에서 Inner Class 타입으로 캐스팅 불가)
     *
     * @return {i2SEMA_ComponentResponse}
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse initialize(Object reqData){
        i2SEMA_ComponentResponse response   = new i2SEMA_ComponentResponse();
        ReferenceData referenceData         = new ReferenceData();

        RequestData requestData = (RequestData)JSON.deserialize(JSON.serialize(reqData),RequestData.class);

        String recordObjectType                     = i2SEMA_Util.isNotEmpty(requestData.recordId) ? Id.valueOf(requestData.recordId).getSobjectType().getDescribe().getName() : null;
        List<DescribeSObjectResult> objectDescribes = Schema.describeSObjects(new List<String>{requestData.searchObjectType});

        // 검색 Object 의 Field Set 항목 추출
        List<String> recordFields   = new List<String>{'Id'};
        List<String> queryFields    = new List<String>{'Id'};       // picklist 의 Tolabel 별도 처리를 위함
        {
            for( DescribeSObjectResult dsr : objectDescribes){
                Schema.FieldSet fs = dsr.fieldSets.getMap().get('i2SEMA_FieldReference');
                for( Schema.FieldSetMember fsMember : fs.getFields()){
                    Schema.DescribeFieldResult dfr = fsMember.getSObjectField().getDescribe();
                    // 기본 추출하는 ID 는 FieldSet 에 포함되더라도 처리제외
                    if( 'Id'.equalsIgnoreCase(dfr.getName())) continue;

                    // Table Header 항목
                    referenceData.tableHeader.add(dfr.getLabel());

                    // Table Body 항목 - Picklist 항목은 필드값의 Label 을 뽑도록 분리
                    if( dfr.getType().equals(Schema.DisplayType.PICKLIST) || dfr.getType().equals(Schema.DisplayType.MULTIPICKLIST) ){
                        queryFields.add( 'ToLabel(' + dfr.getName() + ')');
                        recordFields.add(dfr.getName());
                    }else{
                        queryFields.add(dfr.getName());
                        recordFields.add(dfr.getName());
                    }
                }
            }
        }

        // 검색 Object 에서 Reference 하는 필드목록 추출
        List<String> referenceFields = new List<String>();
        {
            for( DescribeSObjectResult dsr : objectDescribes ){
                Map<String,SObjectField> fieldMap = dsr.fields.getMap();
                for( SObjectField field : fieldMap.values()){
                    DescribeFieldResult dfr = field.getDescribe();

                    // Field 타입이 Reference 이며, 참조하는 Object 가 현재 Record 와 동일한 경우에 관련목록에 추가
                    if((dfr.getType() == Schema.DisplayType.REFERENCE)){
                        Set<String> referenceTypes = new Set<String>();
                        for( SObjectType referenceType : dfr.getReferenceTo()){
                            referenceTypes.add(referenceType.getDescribe().getName());
                        }
                        if( referenceTypes.contains( recordObjectType )){
                            referenceFields.add(dfr.getName());
                        }
                    }
                }
            }
        }

        // 참조값이 Record ID 와 동일한 데이터 조회. 참조필드는 OR 로 모두 조인
        List<SObject> relatedRecords;
        if( !referenceFields.isEmpty() ){

            String selectStatement  = ' SELECT ' + String.join(queryFields,',');
            String fromStatement    = ' FROM ' + requestData.searchObjectType;
            String whereStatement   = ' WHERE ' + String.join(referenceFields,'= \'' + requestData.recordId + '\' OR ' )  + '= \'' + requestData.recordId + '\'';
            String orderStatement   = ' ORDER BY Name ASC NULLS LAST';
            String limitStatement   = ' LIMIT 2000';

            String queryString      = selectStatement + fromStatement + whereStatement + orderStatement + limitStatement;
            relatedRecords = Database.query(queryString);
        }

        // 조회된 결과 처리
        if( relatedRecords != null ){
            Set<String> selectedIdSet = new Set<String>(requestData.selectedIds);
            Record record;

            for( SObject sObj : relatedRecords ){
                record = new Record();
                for( String recordField : recordFields ){
                    String fieldValue = i2SEMA_Util.isNotEmpty(sObj.get(recordField)) ? String.valueOf(sObj.get(recordField)) : '-';

                    // ID 를 제외하고 조회값을 Table Body 로 설정
                    if( 'Id'.equalsIgnoreCase(recordField)){
                        record.Id       = fieldValue;
                        record.selected = selectedIdSet.contains(fieldValue);
                    }else{
                        record.fieldValues.add( fieldValue );
                    }
                }
                referenceData.records.add(record);
            }
        }


        response.setData('referenceData',referenceData);
        return response;
    }

    public class ReferenceData {
        @AuraEnabled public List<String> tableHeader    {get;set;}  // Table 헤더 필드
        @AuraEnabled public List<Record> records        {get;set;}  // Table 본문 레코드

        public ReferenceData(){
            tableHeader = new List<String>();
            records     = new List<Record>();
        }
    }
    public class Record {
        @AuraEnabled public String Id                   {get;set;}
        @AuraEnabled public List<String> fieldValues    {get;set;}
        @AuraEnabled public Boolean selected            {get;set;}

        public Record(){
            this.fieldValues = new List<String>();
        }
    }
    public class RequestData {
        @AuraEnabled public String recordId             {get;set;}
        @AuraEnabled public String searchObjectType     {get;set;}
        @AuraEnabled public List<String> selectedIds    {get;set;}
    }
}