/****************************************************************************************
  * @filename      : AddressSearchQa
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-03-14 오전 10:01
  * @group         : 
  * @group-content : 
  * @description   : 행안부 대한민국 주소 API 이용 주소검색 Lightning Component
  * @tester        : AddressSearchQa_ts.cls
  * @reference     : juso.go.kr Korean Address Open API
  * @copyright     : Copyright © I2max. All Rights Reserved.
  *                  Copyright © Ministry of the Interior and Safety. All Rights reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-14 오전 10:01       i2max_ss               Create
    0.2     2021-02-17                 i2max_Sukun            Update
    0.3     2021-03-03                 i2max_Sukun            Update
    0.4     2021-05-21                 i2max_Sukun            Update
****************************************************************************************/
public with sharing class
AddressSearchQa {
    // 키값
    private static final String KEY = System.Label.AddressSearch_ApiKeySet;
    // url
    private static final String URL = System.Label.AddressSearch_ApiUrlSet;
    // Account Address 체계 관련 주소
    private static final String LAB_COM_I2ADDRESS_ACC_BILLINGADDREESS = System.Label.LAB_COM_I2ADDRESS_ACC_BILLINGADDREESS;
    private static final String LAB_COM_I2ADDRESS_ACC_SHIPPINGADDRESS = System.Label.LAB_COM_I2ADDRESS_ACC_SHIPPINGADDRESS;
    // Contact Address 체계 관련 주소
    private static final String LAB_COM_I2ADDRESS_CON_FIRSTADDRESS = System.Label.LAB_COM_I2ADDRESS_CON_FIRSTADDRESS;
    private static final String LAB_COM_I2ADDRESS_CON_OTHERADDRESS = System.Label.LAB_COM_I2ADDRESS_CON_OTHERADDRESS;

    // 데이터 반환 타입
    private static final String RETURN_TYPE = 'json';

    /**
    * init : 최초호출(주소 검색 쿼리)
    * @param recordId : 레코드 ID
    * @return
    */
    @AuraEnabled
    public static AddressInfoWrapper init(String recordId){
        String sObjectName = findObjectNameFromRecordIdPrefix(recordId);
        List<String> sobjectTypeKeys = new List<String>{sObjectName};
        AddressInfoWrapper bw = new AddressInfoWrapper(); // Aura Return Wrapper

        bw.sObjectName = sObjectName;
        bw.sobjectTypeLabelMap = getLabels(sobjectTypeKeys, true, '\\(.*\\)');

        return bw;
    }

    /**
    * search : 주소검색
    * @param pageSize : 출력 할 페이지의 사이즈
    * @param pageNumber : 페이지 번호
    * @param searchTerm : 검색어
    * @return Object
    */
    @AuraEnabled
    public static Object search(Integer pageSize, Integer pageNumber, String searchTerm){
        return call(pageSize, pageNumber, searchTerm);
    }

    /**
    * save : 주소 저장
    * @param i2_Address
    * @param sObjectName
    * @param recordId
    * @param state
    * @param city
    * @param street
    * @param postCode
    * @param address1
    * @param address2
    */
    @AuraEnabled
    public static void save(String i2_Address, String sObjectName, String recordId, String state, String city, String street, String postCode, String address1, String address2) {
        System.debug('i2_Address : '+i2_Address);
        if(sObjectName.equals('Account')) {
            Account recordData = [
                    SELECT Id, BillingCountry, BillingCity, BillingPostalCode, BillingStreet, BillingState, ShippingCountry, ShippingCity, ShippingPostalCode, ShippingStreet, ShippingState
                    FROM Account
                    WHERE id = :recordId
            ];
            if (i2_Address.equals(LAB_COM_I2ADDRESS_ACC_BILLINGADDREESS)) {
                recordData.BillingState = KDCE_Util.getShortKrState(state);
                recordData.BillingCity = KDCE_Util.getShortKrState(city);
                recordData.BillingStreet = street;
                recordData.BillingPostalCode = postCode;
                update recordData;
            } else if (i2_Address.equals(LAB_COM_I2ADDRESS_ACC_SHIPPINGADDRESS)) {
                recordData.ShippingState = KDCE_Util.getShortKrState(state);
                recordData.ShippingCity = KDCE_Util.getShortKrState(city);
                recordData.ShippingStreet = street;
                recordData.ShippingPostalCode = postCode;
                update recordData;
            }
        }else if(sObjectName.equals('Contact')) {
            Contact recordData = [
                    SELECT Id,
                            MailingCountry, MailingCity, MailingPostalCode, MailingStreet, MailingState,
                            OtherCountry, OtherCity, OtherPostalCode, OtherStreet, OtherState,
                            KDCE_FirstAddressLv1__c, KDCE_FirstAddressLv2__c, KDCE_FirstAddressPostal__c
                    FROM Contact
                    WHERE Id = :recordId
            ];
            if (i2_Address.equals(LAB_COM_I2ADDRESS_CON_FIRSTADDRESS)) {
                recordData.MailingState = KDCE_Util.getShortKrState(state);
                recordData.MailingCity = KDCE_Util.getShortKrState(city);
                recordData.MailingStreet = street;
                recordData.MailingPostalCode = postCode;
                recordData.KDCE_FirstAddressLv1__c = address1;
                recordData.KDCE_FirstAddressLv2__c = address2;
                recordData.KDCE_FirstAddressPostal__c = postCode;

//                recordData.KDCE_ShippingState__c = KDCE_Util.getShortKrState(state);
//                recordData.KDCE_ShippingCity__c = KDCE_Util.getShortKrState(city);
//                recordData.KDCE_ShippingStreet__c = street;
//                recordData.KDCE_ShippingPostalCode__c = postCode;

                update recordData;
            }
            else if (i2_Address.equals(LAB_COM_I2ADDRESS_CON_OTHERADDRESS)) {
                recordData.OtherState = KDCE_Util.getShortKrState(state);
                recordData.OtherCity = KDCE_Util.getShortKrState(city);
                recordData.OtherStreet = street;
                recordData.OtherPostalCode = postCode;
                recordData.KDCE_FirstAddressLv1__c = address1;
                recordData.KDCE_FirstAddressLv2__c = address2;
                recordData.KDCE_FirstAddressPostal__c = postCode;
                update recordData;
            }
        } else {
            Lead recordData = [
                    SELECT Id, Street, City, State, Country, PostalCode
                    FROM Lead
                    WHERE id = :recordId
            ];
            recordData.State = KDCE_Util.getShortKrState(state);
            recordData.City = KDCE_Util.getShortKrState(city);
            recordData.Street = street;
            recordData.PostalCode = postCode;
            update recordData;
        }
    }

    /**
    * call : API 호출
    * @param pageSize : 출력 할 페이지의 사이즈
    * @param pageNumber : 페이지 번호
    * @param searchTerm : 검색어
    * @return Object
    */
    private static Object call(Integer pageSize, Integer pageNumber, String searchTerm){
        String pSize = String.valueOf(Integer.valueOf(pageSize));
        String pNumber = String.valueOf(Integer.valueOf(pageNumber));
        String result;
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(makeUrl(pSize, pNumber, searchTerm));
            req.setMethod('GET');
            req.setHeader('Accept', '*/*');
            HTTPResponse res = http.send(req);
            result = res.getBody();
            System.debug('result : '+result);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.deserializeUntyped(result);
    }

    /**
    * makeUrl : 최종 URL을 생성한다
    * @param pageSize : 출력 할 페이지의 사이즈
    * @param pageNumber : 페이지 번호
    * @param searchTerm : 검색어
    * @return String
    */
    private static String makeUrl(String pageSize, String pageNumber, String searchTerm){
        String resultUrl = URL + '?currentPage=' + pageNumber + '&countPerPage='+pageSize+'&keyword='+EncodingUtil.urlEncode(searchTerm,'UTF-8')+'&confmKey='+EncodingUtil.urlEncode(KEY,'UTF-8')+'&resultType='+RETURN_TYPE;
        System.debug('address api resultUrl :' +resultUrl);
        return resultUrl;
    }

    /**
    * findObjectNameFromRecordIdPrefix : Record ID로 Object명 조회
    * @param recordIdOrPrefix : Record ID
    * @return String
    */
    private static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);

            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                //if (!sObj.contains('__')) to exclude managed package objects
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);

                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    //System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }

    /**
    * getLabels : Object & Field Label 가져오기
    * @param sobjectTypeKeys : Object API Name(List<String>)
    * @param patternYn : Replace Pattern 적용 여부
    * @param patternType : Replace Pattern 정규식
    * @return Map
    */
    private static Map<String, Object> getLabels(List<String> sobjectTypeKeys, boolean patternYn, String patternType) {
        Map<String, SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType sobjType;
        Map<String, SObjectField> fieldMap;
        Map<String, String> fieldLabelMap = new Map<String, String>();
        Map<String, Object> sobjectTypeLabelMap = new Map<String, Object>();
        Pattern nonWordChar = Pattern.compile(patternType);

        for(Object key : sobjectTypeKeys) {
            sobjType = schemaMap.get((String)key);
            fieldMap = sobjType.getDescribe().fields.getMap();
            for (String fieldName: fieldMap.keySet()) {
                System.debug((String)key+':'+fieldName+':'+nonWordChar.matcher(fieldMap.get(fieldName).getDescribe().getLabel()).replaceAll(''));
                if(patternYn) fieldLabelMap.put(fieldName,nonWordChar.matcher(fieldMap.get(fieldName).getDescribe().getLabel()).replaceAll(''));
                else fieldLabelMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
            }
            sobjectTypeLabelMap.put((String)key, fieldLabelMap);
        }
        return sobjectTypeLabelMap;
    }

    /**
    * AddressInfoWrapper : Object Name, Record, Label Map
    */
    public class AddressInfoWrapper {
        @AuraEnabled public String sObjectName {get;set;}
        @AuraEnabled public SObject data {get;set;}
        @AuraEnabled public Map<String, Object> sobjectTypeLabelMap  {get;set;}
    }
}