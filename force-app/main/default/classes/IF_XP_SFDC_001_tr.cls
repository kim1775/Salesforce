/****************************************************************************************
  * @filename      : IF_XP_SFDC_001_tr
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-03-22
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-03-22          i2max_JE Yoon             Create
****************************************************************************************/
public without sharing class IF_XP_SFDC_001_tr extends TriggerHandler {

    private static Map<String, String> pvMap_CouponHistory_ActionType = KDCE_Util.getPicklistValue('KDCE_CouponHistory__c', 'ActionType__c');
    private static Map<String, String> pvMap_CouponHistory_ActionChannel = KDCE_Util.getPicklistValue('KDCE_CouponHistory__c', 'ActionChannel__c');
    private static Map<String, String> pvMap_Coupon_Status = KDCE_Util.getPicklistValue('KDCE_Coupon__c', 'Status__c');

    public override void beforeInsert() {
//        this.createCouponHistory(); // 인터페이스가 제대로 처리 되었는지 여부 및 쿠폰 Status__c 업데이트, 쿠폰 히스토리 레코드 생성
        convertStatusDate();    // Coupon Status Date를 Datetime으로 변환
    }

    /**
     * @description IF_XP_SFDC_001__c에 레코드가 생성되면 쿠폰코드(CouponId__c) 값으로 쿠폰을 조회해
     *              1. 쿠폰의 Status__c = Use로 업데이트
     *              2. 쿠폰 히스토리 레코드 생성
     *              3. IF_XP_SFDC_001__c.IsProcess__c = true 처리
     *              (해당하는 쿠폰이 없을 시에는 IsError__c = false 및 ErrorContent__c = 'Coupon Id does not exist.' 처리)
     * @author JE Yoon (2021.03.22)
     **/
//    private void createCouponHistory() {
//        Map<String, KDCE_Coupon__c> couponCodeMap   = new Map<String, KDCE_Coupon__c>();
//        Map<String, Datetime> couponCode_Date_Map   = new Map<String, Datetime>();
//        List<KDCE_Coupon__c> coupons                = new List<KDCE_Coupon__c>();
//
//        List<KDCE_CouponHistory__c> histories       = new List<KDCE_CouponHistory__c>();
//        Map<Id, KDCE_CouponHistory__c> insertUseHistoryMap = new Map<Id, KDCE_CouponHistory__c>();
//        Map<Id, KDCE_CouponHistory__c> insertIssueHistoryMap = new Map<Id, KDCE_CouponHistory__c>();
//        KDCE_Coupon__c coupon;
//        KDCE_CouponHistory__c history;
//
//        Datetime dt;
//        String actionChannel_Offline                 = pvMap_CouponHistory_ActionChannel.get('Offline');
//        String couponStatus_Use                      = pvMap_Coupon_Status.get('Use');
//        String couponStatus_Issue                    = pvMap_Coupon_Status.get('Issue');
//        String actionType_Use                        = pvMap_CouponHistory_ActionType.get('Use');
//        String actionType_Cancel                     = pvMap_CouponHistory_ActionType.get('Cancel');
//        String couponHistoryStatus;
//        String ifxp_date;
//        String date_converted;
//
//        // 텍스트 타입의 쿠폰 사용일을 Datetime 형태로 변환 처리
//        for (IF_XP_SFDC_001__c ifxp : (List<IF_XP_SFDC_001__c>) Trigger.new) {
//            ifxp_date = ifxp.CouponStatusDate__c; // 인터페이스로 들어오는 날짜/시간 형식: 20190329155801
//            if (ifxp_date.length() == 14) {
//                date_converted = ifxp_date.substring(0,4) + '-' + ifxp_date.substring(4,6) + '-' + ifxp_date.substring(6,8) + ' ';
//                date_converted += ifxp_date.substring(8,10) + ':' + ifxp_date.substring(10,12) + ':' + ifxp_date.substring(12,14);
//                dt = Datetime.valueOf(date_converted);
//            }
//            couponCode_Date_Map.put(ifxp.CouponId__c, dt);
//        }
//
//        coupons = [SELECT Contact__c, Status__c, CouponCode__c FROM KDCE_Coupon__c WHERE CouponCode__c = :couponCode_Date_Map.keySet()];
//
//        if (!coupons.isEmpty()) {
//            for (KDCE_Coupon__c kdceCoupon : coupons) {
//                couponCodeMap.put(kdceCoupon.CouponCode__c, kdceCoupon);
//            }
//        }
//
//        // 각 더미 데이터에 대해 쿠폰 상태를 사용으로 업데이트하고 쿠폰 히스토리 데이터 생성
//        for (IF_XP_SFDC_001__c ifxp : (List<IF_XP_SFDC_001__c>) Trigger.new) {
//            coupon = couponCodeMap.get(ifxp.CouponId__c);
//            if (coupon == null) {
//                ifxp.IsProcess__c = true;
//                ifxp.IsError__c = true;
//                ifxp.ErrorContent__c = 'Coupon Id does not exist.';
//            }
//            else {
//                ifxp.IsProcess__c = true;
//                if (ifxp.CouponStatus__c == '1') {
//                    coupon.Status__c    = KDCE_GlobalValue.COUPON_STATUS_USE;
//                    coupon.UsedDate__c  = couponCode_Date_Map.get(coupon.CouponCode__c);
//                    couponHistoryStatus = actionType_Use;
//                }
//                else if (ifxp.CouponStatus__c == '-1') {
//                    coupon.Status__c    = KDCE_GlobalValue.COUPON_STATUS_ISSUE;
//                    coupon.UsedDate__c  = null;
//                    couponHistoryStatus = actionType_Cancel;
//                }
//
//                // Coupon Action 별
//                history                     = KDCE_CouponService.createCouponHistory(coupon.Id, couponHistoryStatus);
//                history.Contact__c          = coupon.Contact__c;
//                history.ActionDate__c       = couponCode_Date_Map.get(coupon.CouponCode__c);
//                history.ActionChannel__c    = actionChannel_Offline;
//                history.StoreCode__c        = ifxp.CouponOltCode__c;
//                history.StoreName__c        = ifxp.CouponOltName__c;
//
//                // Use, Cancel 동시에 들어올 경우 Use 먼저 처리하고 Cancel 처리하도록
//                if (ifxp.CouponStatus__c == '1') insertUseHistoryMap.put(history.Id, history);
//                else if (ifxp.CouponStatus__c == '-1') insertIssueHistoryMap.put(history.Id, history);
//
//                System.debug('=== insertUseHistoryMap : ' + insertUseHistoryMap);
//                System.debug('=== insertIssueHistoryMap : ' + insertIssueHistoryMap);
//            }
//        }
//
//        if (!insertUseHistoryMap.isEmpty()) insert insertUseHistoryMap.values();
//        if (!insertIssueHistoryMap.isEmpty()) insert insertIssueHistoryMap.values();
//        if (!couponCodeMap.isEmpty()) update couponCodeMap.values();
//    }

    /**
     * Text인 CouponStatusDate__c 값을 Datetime 필드로 변환
     */
    private void convertStatusDate() {
        System.debug('@@@@@@ convertStatusDate @@@@@@');
        Datetime dt;
        String ifxp_date;
        String date_converted;

        for (IF_XP_SFDC_001__c ifxp : (List<IF_XP_SFDC_001__c>) Trigger.new) {
            if (ifxp.CouponStatusDate__c != null) {
                ifxp_date = ifxp.CouponStatusDate__c; // 인터페이스로 들어오는 날짜/시간 형식: 20190329155801
                if (ifxp_date.length() == 14) {
                    date_converted = ifxp_date.substring(0,4) + '-' + ifxp_date.substring(4,6) + '-' + ifxp_date.substring(6,8) + ' ';
                    date_converted += ifxp_date.substring(8,10) + ':' + ifxp_date.substring(10,12) + ':' + ifxp_date.substring(12,14);
                    dt = Datetime.valueOf(date_converted);
                }
                ifxp.CouponStatusDatetime__c = dt;
            }
        }
    }

}