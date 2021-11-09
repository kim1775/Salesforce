/****************************************************************************************
 * @filename      : KDCE_TaskRecordingDownload
 * @projectname   : 
 * @author        : Donghu
 * @date          : 2021/02/26
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1      2021/02/26                  Donghu          Create
 ****************************************************************************************/
public with sharing class KDCE_TaskRecordingDownload {

    @AuraEnabled
    public static Map<String, Object> getRecord(String recordId) {


        Task task = [SELECT Id,ConversationId__c FROM Task WHERE Id = :recordId];

        String cvId = task.ConversationId__c;
        /**
         *  1.Get Recording Id Call
         *  status 202 > 다시 콜
         */
        if (cvId == null) {
            throw new AuraHandledException('다운로드 불가');
        }
        Map<String, Object> retMap = getRecordingAPI(cvId);
        retMap.put('cvId', cvId);
        return retMap;
    }

    @AuraEnabled
    public static Map<String, Object> getRecording(String cvId, String recordingId) {
        /**
           *  2. Get Download URL
           *  status 202 > 다시 콜
           */
        Map<String, Object> retMap = getRecordingWrapper(cvId, recordingId);
        return retMap;
    }


    @AuraEnabled
    public static KDCE_GCAuditLog__c setAudit(RecordingWrapper rw) {
        /**
        *  Date, User, Recording, type  Audit 저장
        *
        */
        System.debug('===setAudit===');

        KDCE_GCAuditLog__c auditLog = new KDCE_GCAuditLog__c();
        auditLog.User__c = UserInfo.getUserId();
        if(!Test.isRunningTest()) auditLog.UserIP__c = Auth.SessionManagement.getCurrentSession().get('SourceIp');
        auditLog.ConversationId__c = rw.conversationId;
        auditLog.RecordingId__c = rw.recordingId;
        auditLog.LogDateTime__c = Datetime.now();

        
        insert auditLog;

        return auditLog;
    }
    public static Map<String, Object> getRecordingAPI(String cvId) {
        Map<String, Object> retMap = new Map<String, Object>();

        //Get Recording API 호출
        IF_DCE_GC_0001 ifInstance = IF_DCE_GC_0001.getInstance();
        IF_DCE_GC_0001.InputDIH ifInput = new IF_DCE_GC_0001.InputDIH();
        IF_DCE_GC_0001.INPUT_T_DATA tData = new IF_DCE_GC_0001.INPUT_T_DATA();
        tData.conversationId = cvId;
        ifInput.request.payload.t_data.add(tData);
        IF_DCE_GC_0001.OutputDIH outputDIH = ifInstance.execute(ifInput);
        System.debug('1 :: ' + outputDIH.response.header.ifFailCode);
        System.debug('1 :: ' + outputDIH.response.header.ifResult);
        //202 경우 aura로 return 후 다시 호출

        if (outputDIH.response.header.ifFailCode == '202') {
            retMap.put('ifCode', outputDIH.response.header.ifFailCode);
            return retMap;
        }
        if (outputDIH.response.header.ifResult == 'E') {
            retMap.put('noData', true);
            return retMap;
        }

        List<String> recordingIdList = new List<String>();

        //1개의 conversation => 여러개의 Recording이 존재 가능
        for (String str : outputDIH.response.payload.t_data) {
            List<Object> objList = (List<Object>) JSON.deserializeUntyped(str);
            for (Object obj : objList) {
                Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                recordingIdList.add((String) resMap.get('id'));
            }
        }

        retMap.put('recordingIdList', recordingIdList);

        return retMap;
    }

    public static Map<String, Object> getRecordingWrapper(String cvId, String recordingId) {
        Map<String, Object> retMap = new Map<String, Object>();


        List<KDCE_TaskRecordingDownload.RecordingWrapper> rwList = new List<KDCE_TaskRecordingDownload.RecordingWrapper>();
        RecordingWrapper rw;

        //Recording Download URL API 호출
        IF_DCE_GC_0002 ifInstance2 = IF_DCE_GC_0002.getInstance();
        IF_DCE_GC_0002.InputDIH ifInput2 = new IF_DCE_GC_0002.InputDIH();
        IF_DCE_GC_0002.INPUT_T_DATA tData2 = new IF_DCE_GC_0002.INPUT_T_DATA();
        tData2.conversationId = cvId;
        tData2.recordingId = recordingId;
        tData2.formatId = 'WAV';
        tData2.download = 'true';
        ifInput2.request.payload.t_data.add(tData2);
        IF_DCE_GC_0002.OutputDIH outputDIH2 = ifInstance2.execute(ifInput2);
        System.debug('2 :: ' + outputDIH2.response.header.ifFailCode);
        System.debug('2 :: ' + outputDIH2.response.header.ifResult);

        //202 경우 aura로 return 후 다시 호출
        if (outputDIH2.response.header.ifFailCode =='202') {
            retMap.put('ifCode', outputDIH2.response.header.ifFailCode);
            return retMap;
        }

        if (outputDIH2.response.header.ifResult == 'E') {
            retMap.put('noData', true);
            return retMap;
        }


        for (String str2 : outputDIH2.response.payload.t_data) {
            Map<String, Object> resMap2 = (Map<String, Object>) JSON.deserializeUntyped(str2);
            rw = new RecordingWrapper();
            rw.recordingId = (String) resMap2.get('id');
            rw.conversationId = (String) resMap2.get('conversationId');
            rw.startTime = Util.yyyy_mm_dd_T_hh_mm_ssToDateTime((String) resMap2.get('startTime'));
            rw.endTime = Util.yyyy_mm_dd_T_hh_mm_ssToDateTime((String) resMap2.get('endTime'));
            rw.media = (String) resMap2.get('media');
            rw.fileState = (String) resMap2.get('fileState');
            //> callback의 경우 배열의 맨 마지막 mediaUris 주소로 다운로드
            Map<String, Object> mediaMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(resMap2.get('mediaUris')));
            if (!mediaMap.isEmpty()) {
                Object mediaStr = mediaMap.values().get(mediaMap.size() - 1);
                Map<String, Object> mediaMap2 = (Map<String, Object>) JSON.deserializeUntyped(JSOn.serialize(mediaStr));
                if (!mediaMap2.isEmpty()) rw.downloadUrl = String.valueOf(mediaMap2.get('mediaUri'));
            }
            if (rw.downloadUrl != null) rwList.add(rw);
        }

        System.debug('rwList :: ' + rwList);
        if (!rwList.isEmpty()) retMap.put('rwList', rwList);


        return retMap;
    }
    public class RecordingWrapper {
        @AuraEnabled
        public String recordingId { get; set; }
        @AuraEnabled
        public String conversationId { get; set; }
        @AuraEnabled
        public Datetime startTime { get; set; }
        @AuraEnabled
        public Datetime endTime { get; set; }
        @AuraEnabled
        public String media { get; set; }
        @AuraEnabled
        public String fileState { get; set; }
        @AuraEnabled
        public String downloadUrl { get; set; }
    }
}