/****************************************************************************************
  * @filename      : KDCE_ContactSeparateService
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-10 오후 2:33
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
    0.1     2021-06-10 오후 2:33     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_ContactSeparateService {

    // 사용자 권한을 강제로 두기 위한 innerClass
    public without sharing class ignoreAuthorityInnerClass {

        public void forceDelete(List<SObject> deleteList){
            delete deleteList;
        }

        public void forceUpdate(List<SObject> updateList) {
            update updateList;
        }

    }

    public static void separateObject (String separateType, String originObject, String separateObject, List<SObject> originObjectList) {
        System.debug('START :: KDCE_ContactSeparateService.separateObject');
        System.debug('separateType :: ' + separateType);
        System.debug('originObject :: ' + originObject);
        System.debug('separateObject :: ' + separateObject);
        System.debug('originObjectList :: ' + originObjectList);

        /**
         *  Origin Object Field Map
        */
        Map<String, Schema.SObjectField> originFieldMap = Schema.getGlobalDescribe().get(originObject).getDescribe().fields.getMap();
//        Map<String, Object> originValueMap = new Map<String, Object>();    // 필드별 value Map
        Map<String, Object> tempMap;    // 필드별 value Map
        Map<Id, Map<String, Object>> originValueMap = new Map<Id, Map<String, Object>>();    // 필드별 value Map
        String keyStr;
        for (SObject obj : originObjectList) {
            keyStr = (String)obj.get('id');
            System.debug((String)obj.get('id'));
            tempMap = new Map<String, Object>();
            originValueMap.put(keyStr, tempMap );
            // 필드별 값 집어넣음
            for (String origin : originFieldMap.keySet()) {
//                originValueMap.put(origin, obj.get(origin));
                originValueMap.get(keyStr).put(origin, obj.get(origin));
            }
        }

        System.debug('originValueMap :: ' + originValueMap);

        /**
         * Dormant / DropOut List 생성`
        */
        String standField;
        String originObjectId = originObject.contains('__c') ? originObject.remove('__c') + 'Id__c' : originObject + 'Id__c';
        originObjectId = originObjectId.toLowerCase();

        Map<String, Schema.SObjectField> dormantFieldMap = Schema.getGlobalDescribe().get(separateObject).getDescribe().fields.getMap();
        List<SObject> dormantList = new List<SObject>();   // 복구처리해야하는 Dormant List
        for (SObject obj : originObjectList) {

            // Dormant 생성
            SObject newDormantObject = Schema.getGlobalDescribe().get(separateObject).newSObject();
//            newDormantObject.put(originObjectId, originValueMap.get('id'));     // Origin Object Lookup 필드 연결
            keyStr = (String)obj.get('id');
            newDormantObject.put(originObjectId, originValueMap.get(keyStr).get('id'));     // Origin Object Lookup 필드 연결
            tempMap = null;
            tempMap = originValueMap.get(keyStr);

            // 기존에 넣었던 Original Object의 필드값들을 Dormant로 옮기기
//            for (String originField : originValueMap.keySet()) {
            for (String originField : tempMap.keySet()) {
                try {
                    // 바꿀 수 없는 필드 넘기기
                    if (originField == 'ownerid' || originField == 'id') continue;

                    // Standard Field 설정
                    if (!originField.contains('__c')) standField = originField + '__c';     // Standard 필드 맵핑을 위한 정의

                    if (dormantFieldMap?.containsKey(originField) || dormantFieldMap?.containsKey(standField)) {
                        // Custom 필드 맵핑
//                        if (dormantFieldMap.containsKey(originField)) newDormantObject.put(originField, originValueMap?.get(originField));
                        if (dormantFieldMap.containsKey(originField)) newDormantObject.put(originField, tempMap?.get(originField));
                        // Standard 필드 맵핑
                        else if (dormantFieldMap.containsKey(standField)) {
//                            newDormantObject.put(standField, originValueMap?.get(originField));
                            newDormantObject.put(standField, tempMap?.get(originField));
                        }
                    }
                } catch (Exception e) {
                    System.debug('=== originField : ' + originField);
                    System.debug('=== Error Message : ' + e.getMessage());
                }
            }

            // 기타 강제로 값 넣어주기
//            if (originObject == 'Contact') newDormantObject?.put('name', originValueMap.get('name'));   // Contact일 경우에만 Name 값 넣어줌
//            if (originObject == 'KDCE_OrderLineItem__c') newDormantObject?.put('contact__c', originValueMap.get('kdce_fm_ordercontactid__c'));
//            if (dormantFieldMap.containsKey('createddate__c')) newDormantObject?.put('createddate__c', originValueMap.get('createddate'));
//            if (separateType == 'DropOut' && dormantFieldMap.containsKey('kdce_externalid__c')) newDormantObject?.put('kdce_externalid__c', originValueMap.get(null));
            if (originObject == 'Contact') { 
                newDormantObject?.put('name', tempMap.get('name'));// Contact일 경우에만 Name 값 넣어줌
                newDormantObject?.put('kdce_convertdormantdate__c', system.now());//Contact과 같이 현재시간 넣어줌 20210823 Marcus Kim 추가
            }   
            if (originObject == 'KDCE_OrderLineItem__c') newDormantObject?.put('contact__c', tempMap.get('kdce_fm_ordercontactid__c'));
            if (dormantFieldMap.containsKey('createddate__c')) newDormantObject?.put('createddate__c', tempMap.get('createddate'));
            if (separateType == 'DropOut' && dormantFieldMap.containsKey('kdce_externalid__c')) newDormantObject?.put('kdce_externalid__c', tempMap.get(null));
            dormantList.add(newDormantObject);
            System.debug('newDormantObject ::' + newDormantObject);
        }

        System.debug('dormantList :: ' + dormantList);
        List<Database.SaveResult> newDormantList = Database.insert(dormantList, false);

    }

    public static void setNullField(String separateType,String originObject, List<SObject> originObjectList, Map<String, Schema.SObjectField> objectSchema, Set<String> notNullField, Set<String> nullField) {
        System.debug('@@@@@@ setNullField @@@@@@');
        System.debug('=== separateType : ' + separateType);
        System.debug('=== originObject : ' + originObject);
        System.debug('=== originObjectList : ' + originObjectList);
        System.debug('=== objectSchema : ' + objectSchema);
        System.debug('=== notNullField : ' + notNullField);

        /**
         *  Origin Object Field Map
        */
        Map<String, Schema.SObjectField> originFieldMap = Schema.getGlobalDescribe().get(originObject).getDescribe().fields.getMap();
        Map<String, Object> originValueMap = new Map<String, Object>();    // 필드별 value Map
        for (SObject obj : originObjectList) {
            // 필드별 값 집어넣음
            for (String origin : originFieldMap.keySet()) {
                originValueMap.put(origin, obj.get(origin));
            }
        }

        /**
         * Origin Object 필드 Null 처리
        */
        Date d = System.today();
        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
        String contLastName;

        List<SObject> updateList = new List<SObject>();

        String originObjectId = originObject.contains('__c') ? originObject.remove('__c') + 'Id__c' : originObject + 'Id__c';
        originObjectId = originObjectId.toLowerCase();
        String originContactId;

        for (SObject obj : originObjectList) {
            System.debug('=== obj : ' + obj);
            for (String originField : originValueMap.keySet()) {
                // 필드별 타입
                Schema.SObjectField field = objectSchema.get(originField);
                Schema.DisplayType fieldType = field.getDescribe().getType();
                Schema.DescribeFieldResult fieldResult = field.getDescribe();

                try {
                    // Contact의 경우는 해당정보 다 null 처리
                    if (originObject == 'Contact') {
                        if (!objectSchema.get(originField).getDescribe().isUpdateable()) continue;       // 업데이트가 되지 않는 필드 null 처리 예외
                        if (notNullField.contains(originField)) continue;                             // 필수로 들어가야하는 경우엔 null 처리 예외
                        if (String.valueOf(fieldType) == 'BOOLEAN') obj.put(originField, false);   // Checkbox일 경우 false
                        else obj.put(originField, null);                                           // 아닐 경우 null
                    }
                    // 나머지의 경우 지정된 필드만 null 처리
                    else {
                        if (nullField.contains(originField)) {
                            if (!objectSchema.get(originField).getDescribe().isUpdateable()) continue;       // 업데이트가 되지 않는 필드 null 처리 예외
                            if (notNullField.contains(originField)) continue;                             // 필수로 들어가야하는 경우엔 null 처리 예외
                            if (String.valueOf(fieldType) == 'BOOLEAN') obj.put(originField, false);   // Checkbox일 경우 false
                            else obj.put(originField, null);                                           // 아닐 경우 null
                        }
                    }

                } catch (Exception e) {
                    System.debug('=== Contact Field : ' + originField);
                    System.debug('=== Error Message : ' + e);
                }
            }

            if (originObject == 'Contact') {
                if (separateType == 'Dormant') {
                    contLastName = '[INACTIVE]_' + dt.format('yyMMdd');
                    obj.put('kdce_reactivatedormantdate__c', null);
                    obj.put('kdce_isdormant__c', true);
                    obj.put('kdce_convertdormantdate__c', System.now());
                    obj.put('lastname', contLastName);
                }
                else if (separateType == 'DropOut') {
                    contLastName = '[DELETED]_' + dt.format('yyMMdd');
                    obj.put('kdce_dropoutdate__c',System.now() );
                    obj.put('kdce_isdropout__c', true);
                    obj.put('lastname', contLastName);

                }
            }

            if(originObject == 'Case'){
                System.debug('obj.get(\'ccr_subjectcodenew__c\');' + obj.get('ccr_subjectcodenew__c'));
                System.debug('obj.get(\'KDCE_HeetsSubjectCode__c\');' + obj.get('kdce_heetssubjectcode__c'));

            }
            updateList.add(obj);
        }
        System.debug('=== updateList : ' + updateList);
        ignoreAuthorityInnerClass innerClass = new ignoreAuthorityInnerClass();
        if (!updateList.isEmpty()) innerClass.forceUpdate(updateList);
    }

    /**
     * Contact Trigger를 통해 다시 복구하는 메서드
     * @param originObject
     * @param dormantObject
     * @param contactIds
     * @param originContactList
     */
    @SuppressWarnings('PMD')
    public static void restoreObject(String originObject, String dormantObject, Set<Id> contactIds, List<SObject> originContactList) {
        System.debug('@@@@@@ restoreObject @@@@@@');
        System.debug('=== originObject : ' + originObject);
        System.debug('=== dormantObject : ' + dormantObject);
        System.debug('=== contactIds : ' + contactIds);
        System.debug('=== originContactList : ' + originContactList);

        Map<String, Schema.SObjectField> dormantFieldMap = Schema.getGlobalDescribe().get(dormantObject).getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> originFieldMap = Schema.getGlobalDescribe().get(originObject).getDescribe().fields.getMap();
        List<SObject> dormantList;   // 복구처리해야하는 Dormant List
        String contactCondition;
        String dormantContactCondition;

        // Object별, Contact 필드가 다르므로 설정해놈
        if (dormantObject == 'KDCE_DormantContact__c' || dormantObject == 'KDCE_DormantCase__c') {
            contactCondition = 'ContactId__c';
            dormantContactCondition = 'contactid__c';
        }
        else {
            contactCondition = 'Contact__c';
            dormantContactCondition = 'contact__c';
        }
        System.debug('=== contactCondition : ' + contactCondition);
        System.debug('=== dormantContactCondition : ' + dormantContactCondition);

        /**
         * Dormant List 생성
        */
        String query = 'SELECT ';
        for (String fieldName : dormantFieldMap.keySet()) {
            // 첫번째 필드가 아닐 경우 , 붙이기
            if (query != 'SELECT ') query += ' , ';
            query += fieldName;
        }
        query += ' FROM ' + dormantObject;
        query += ' WHERE ' + contactCondition + ' IN :contactIds ';
        query += ' ORDER BY CreatedDate DESC ';
        dormantList = (List<sObject>) Database.query(query);


        /**
         * Origin Object에 담아줄 Dormant 값들 담아놓음
         * Dormant Contact별, Dormant Field Label 별 Value
        */
        String originObjectId;
        originObjectId = originObject.contains('__c') ? originObject.remove('__c') + 'Id__c' : originObject + 'Id__c';
        originObjectId = originObjectId.toLowerCase();
        Map<String, Object> dorFieldMap;
        Map<Id, Map<String, Object>> dormantMapByOriginId = new Map<Id, Map<String, Object>>();
        Set<Id> originIds = new Set<Id>();
        for (SObject obj : dormantList) {
            dorFieldMap = new Map<String, Object>();
            for (String dorField : dormantFieldMap.keySet()) {
                dorFieldMap.put(dorField, obj.get(dorField));

                // 기존 Object List를 쿼리하기위한 Id Set 설정
                if (dorField == originObjectId) {
                    originIds.add((Id)obj.get(originObjectId));
                }
            }
            dormantMapByOriginId.put((Id)obj.get(originObjectId), dorFieldMap);
        }
        /**
         * Contact이 아닐경우 기존 List 생성
        */
        String originQuery = 'SELECT ';
        List<SObject> originList;
        if (dormantObject == 'KDCE_DormantContact__c') {
            originList = originContactList;
        }
        else {
            if (originObject == 'KDCE_OrderLineItem__c') contactCondition = 'KDCE_fm_OrderContactId__c';
            else if (originObject == 'Case') contactCondition = 'ContactId';

            for (String fieldName : originFieldMap.keySet()) {
                // 첫번째 필드가 아닐 경우 , 붙이기
                if (originQuery != 'SELECT ') originQuery += ' , ';
                originQuery += fieldName;
            }
            originQuery += ' FROM ' + originObject;

            if (originObject == 'Contact') originQuery += ' WHERE ' + contactCondition + ' IN :contactIds ';
            else originQuery += ' WHERE Id IN :originIds ';
            originQuery += ' ORDER BY CreatedDate DESC ';
            originList = (List<sObject>) Database.query(originQuery);
        }


        /**
         * 기존값에 Dormant Contact 필드별 값 넣어줌
        */
        String standardField;
        String originId;
        List<SObject> newUpdateList = new List<SObject>();
        for (SObject obj : originList) {
            originId = (String) obj.get('Id');
            if (dormantMapByOriginId?.containsKey(obj.id)) {
                for (String dormantField : dormantMapByOriginId.get(originId).keySet()) {
                    if (dormantField == 'ownerid' || dormantField == 'id' || dormantField == 'ownerid__c') continue;

                    // 필드가 일치하는 경우에만 값 할당
                    try {

                        if (originFieldMap?.containsKey(dormantField)) {
                            if (!originFieldMap.get(dormantField).getDescribe().isUpdateable()) continue;
                            obj.put(dormantField, dormantMapByOriginId.get(originId)?.get(dormantField));
                        }

                        // Dormant Contact 필드 API명에서 '__c' 제거했을 경우, 일치하는 경우가 있나 확인
                        if (originFieldMap?.containsKey(dormantField.split('_')[0])) {
                            standardField = dormantField.split('_')[0];
                            if (!originFieldMap.get(standardField).getDescribe().isUpdateable()) continue;
                            obj.put(standardField, dormantMapByOriginId.get(originId)?.get(dormantField));

                            if (dormantField == 'ownerid' || dormantField == 'id') {
                                System.debug('=== dormantField : ' + dormantField);
                                System.debug('=== dormantMapByOriginId.get(originId) : ' + dormantMapByOriginId.get(originId)?.get(standardField));

                            }
                        }
                    }
                    catch (Exception e) {
                        System.debug('=== conField : ' + dormantField);
                        System.debug('=== Error Message : ' + e);
                    }
                }
            }
            // Contact일 경우
            if (originObject == 'Contact') {
                //obj.put('lastname', dormantMapByOriginId.get(originId)?.get('kdce_name__c'));
                //obj.put('kdce_birthdatemask__c', String.valueOf(dormantMapByOriginId.get(obj.id)?.get('kdce_birthdatemask__c')));
                //obj.put('kdce_emailmask__c', dormantMapByOriginId.get(originId)?.get('kdce_emailmask__c'));
                obj.put('kdce_isdormant__c', false);
                obj.put('kdce_convertdormantdate__c', null);
                obj.put('kdce_reactivatedormantdate__c', System.now());
                //20210901 Restore시 DB Optin True로 변경하도록 추가.
                obj.put('CCR_DatabaseOptin__c', TRUE);
            }
        }

        if (originObject != 'Contact') {
            System.debug('=== originList : ' + originList);
            System.debug('=== dormantList : ' + dormantList);

            ignoreAuthorityInnerClass innerClass = new ignoreAuthorityInnerClass();
            if (!originList.isEmpty()) innerClass.forceUpdate(originList);
            if (!dormantList.isEmpty()) innerClass.forceDelete(dormantList);
        }
    }
}