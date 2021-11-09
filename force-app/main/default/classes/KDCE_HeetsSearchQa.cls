/****************************************************************************************
 * @filename      : KDCE_HeetsSearchQa
 * @projectname   : PMK LocalDCE QA
 * @author        : i2max_Sukun
 * @date          : 2/23/21 6:15 PM
 * @group         : Service
 * @group-content :
 * @description   : Server-Side Controller for KDCE_HeetsSearchQa Component.
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2/23/21 6:15 PM            i2max_Sukun           Create
 0.2     2/26/21                    i2max_Sukun           Update
 0.3     5/21/21                    i2max_Sukun           Update
 ****************************************************************************************/
public with sharing class
KDCE_HeetsSearchQa {
    // 데이터 반환 타입
    private static final String RETURN_TYPE = 'json';
    // 검색결과 에러 메시지
    private static final String COM_ERR_VALID_SEARCH = System.Label.COM_ERR_VALID_SEARCH;

    /**
    * validate : 생성 시 레코드 아이디 이용 기능 활성화 판별(Device Heets Search 컴포넌트)
    * @param recordId : 레코드 Id
    * @return
    */
    @AuraEnabled
    public static PageInfoWrapper validate(String recordId) {
        String sObjectName = KDCE_Util.findObjectNameFromRecordIdPrefix(recordId);
        PageInfoWrapper piw = new PageInfoWrapper(); // Aura Return Wrapper

        piw.sObjectName = sObjectName;

        return piw;
    }

    /**
    * search : 제품검색
    * @param searchTerm : 검색어
    * @return Object
    */
    @AuraEnabled
    public static Object search(String searchTerm) {
        // 12자리 혹은 14자리 시리얼 번호가 아닐 경우 검색 x
        if(searchTerm.length() == 12 || searchTerm.length() == 14) {
            return call(searchTerm);
        } else {
            return COM_ERR_VALID_SEARCH;
        }
    }

    /**
    * save : Case 수정
    * @param contactId
    * @param longName
    * @param brandCode
    * @param brandDesc
    * @param generationDate
    * @param factorycode // 21.10.19 팩토리 코드 추가
    */
    @AuraEnabled
    public static Boolean save(String recordId, String productPackCodentifyId, String longName, String brandCode, String brandDesc, String generationDate, String factorycode, String factorycodeCheck) {
        System.debug('recordId ' + recordId);
        System.debug('productPackCodentifyId ' + productPackCodentifyId);
        System.debug('longName ' + longName);
        System.debug('brandCode ' + brandCode);
        System.debug('brandDesc ' + brandDesc);
        System.debug('generationDate ' + generationDate);
        System.debug('factorycode ' + factorycode); // 21.10.19 팩토리 코드 추가
        // 21.10.20 유형 추가로 케이스 조건문 추가
        Case updateCase = [
                SELECT CCR_FactoryNameFromPack__c,
                        CCR_PackCodentify__c,
                        CCR_ProductVariant__c,
                        CCR_ProductionDateTime__c,
                        CCR_ProductDescriptionAIT__c,
                        CCR_FactoryCodeFromPack__c,
                        RecordTypeId
                FROM Case
                WHERE Id = :recordId
        ];


        System.debug(updateCase);


        //if(updateCase.RecordTypeId == Util.getRecordTypeId(KDCE_Util.findObjectNameFromRecordIdPrefix(recordId), 'CCR_HeatStick') || // 운영에서 CCR_HeatStick 사용 안함
          if(updateCase.RecordTypeId == Util.getRecordTypeId(KDCE_Util.findObjectNameFromRecordIdPrefix(recordId), 'CCR_NewHeatStick')) {
            // Product2의 Name은 제품의 brandCode 사용
            Product2 prod = [SELECT Id, Name FROM Product2 WHERE Name = :brandCode LIMIT 1];

            // 21.10.20 마지막 조건문 추가 (해당 값일 때만 업데이트)
            updateCase.CCR_PackCodentify__c = productPackCodentifyId;
            updateCase.CCR_ProductionDateTime__c = KDCE_Util.ddmmyyyyhmsToDate(generationDate);
            updateCase.CCR_FactoryNameFromPack__c = longName;
            updateCase.CCR_ProductVariant__c = prod?.Id;
            updateCase.CCR_ProductDescriptionAIT__c = brandDesc;
            updateCase.CCR_FactoryCodeFromPack__c = factorycode;
            //Brand Differentiator updateCase.CCR_BrandDifferentiatorAIT__c = LAB_COM_HEETS_BRANDDIFFERENTIATORAIT;
            //Brand Family updateCase.CCR_BrandFamilyAIT__c = LAB_COM_HEETS_BRANDFAMILYAIT;

            update updateCase;
            return true;
        } else {
            return false;
        }
    }

    /**
    * call : Interface 호출
    * @param searchTerm : 검색어
    * @return Object
    */
    private static Object call(String searchTerm) {
        String result;
        try {
            IF_DCE_Vault_0001.OutputDIH jsonObj = IF_KDCE_CallOutController.getHeetsInfo(searchTerm);
            System.debug('=== jsonObj : ' + jsonObj);
            List<String> tData = jsonObj.response.payload.t_data;
            System.debug('=== tData : ' + tData);
            Map<String, Object> parsedObject = (!Test.isRunningTest())? (Map<String, Object>) JSON.deserializeUntyped(tData[0]) : new Map<String, Object>();

            Map<String, Object> finalParseBeforeObj;
            Map<String, Object> parsingObj;

            Boolean foundAdequateJSON = false;
            while (foundAdequateJSON == false) {
                try {
                    parsingObj = (Map<String, Object>) parsedObject.values()[0];
                    finalParseBeforeObj = parsedObject;
                    parsedObject = parsingObj;
                } catch (Exception e) {
                    // 최종 parsed Object 확인 용도
                    System.debug('Final Parsed Object Result' + parsedObject);
                    foundAdequateJSON = true;
                }
            }

            result = JSON.serialize(parsedObject);
system.debug('ttt:'+result);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.deserializeUntyped(result);
    }

    /**
    * PageInfoWrapper : Object Name
    */
    public class PageInfoWrapper {
        @AuraEnabled public String sObjectName { get; set; }
    }
}