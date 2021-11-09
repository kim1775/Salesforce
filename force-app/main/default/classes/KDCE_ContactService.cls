/****************************************************************************************
  * @filename      : KDCE_ContactService
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-04-26 오전 10:32
  * @group         : 
  * @group-content : 
  * @description   : Contact 관련된 공통 비지니스 로직
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-04-26 오전 10:32     i2max_Jihyun.Lee        Create
****************************************************************************************/

public with sharing class KDCE_ContactService {

    // Contact별로 Purchase Date를 지정해주기 위해선 각각 Order, Offline, Coupon가 완료된 경우에만 가져올 수 있다. 이때의 Status
    final static String completeOrderStatus         = KDCE_GlobalValue.ORDER_STATUS_COMPLETE;
    final static String completeDeliveryOrderStatus = KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY;
    final static String completeOPStatus            = KDCE_GlobalValue.OFF_PG_STATUS_COMPLETE;
    final static String completeCouponStatus        = KDCE_GlobalValue.COUPON_STATUS_USE;

    /**
     * @param orderStatus
     * @param contacts
     * @param orders
     *
     * @return Map<Id, List<KDCE_Order__c>>
     * @description Contact별, 조건에 맞는 Order Map 반환
     * @author 이지현 (2021.04.26)
     */
    public static Map<Id, List<KDCE_Order__c>> getOrderByContactMap(Set<Id> contacts, Set<Id> orders) {

        System.debug('=== completeOrderStatus : ' + completeOrderStatus);
        System.debug('=== contacts : ' + contacts);
        System.debug('=== orders : ' + orders);
        
        Map<Id, List<KDCE_Order__c>> orderListByCon = new Map<Id, List<KDCE_Order__c>>();
        List<KDCE_Order__c> checkOrderList;

        String query = '';
        query += ' SELECT Id, Contact__c,ShippingStartDate__c, OrderDate__c, OrderType__c, OrderReason__c, OriginOrder__c ';
        query += ' FROM KDCE_Order__c ';
        query += ' WHERE Contact__c IN :contacts ';
        query += ' AND ( OrderStatus__c = :completeOrderStatus OR OrderStatus__c = :completeDeliveryOrderStatus) ';
        if (orders != null) query += ' AND Id NOT IN :orders AND ru_ValidProductCount__c > 0';      // ru_ValidProductCount__c	악세서리 오더는 대상에서 제외
        System.debug('=== query : ' + query);
        List<KDCE_Order__c> orderList = Database.query(query);
        System.debug('=== orderList : ' + orderList);

        for (KDCE_Order__c order : orderList) {
            if (orderListByCon.containsKey(order.Contact__c)) checkOrderList = orderListByCon.get(order.Contact__c);
             else checkOrderList = new List<KDCE_Order__c>();

            checkOrderList.add(order);
            orderListByCon.put(order.Contact__c, checkOrderList);
        }

        return orderListByCon;
    }

    /**
     * @param programStatus
     * @param contacts
     * @param programs
     *
     * @return Map<Id, List<KDCE_OfflineProgram__c>>
     * @description Contact별 조건에 맞는 Offline Program Map 반환
     * @author 이지현 (2021.04.26)
     */
    public static Map<Id, List<KDCE_OfflineProgram__c>> getProgramByContactMap(Set<Id> contacts) {
        System.debug('=== contacts : ' + contacts);
        Map<Id, List<KDCE_OfflineProgram__c>> programListByCon = new Map<Id, List<KDCE_OfflineProgram__c>>();
        List<KDCE_OfflineProgram__c> checkProgramList;

        String query = '';
        query += ' SELECT Id, Contact__c, PurchaseDate__c, ProgramType__c ';
        query += ' FROM KDCE_OfflineProgram__c ';
        query += ' WHERE Contact__c IN :contacts ';
        query += ' AND Status__c = :completeOPStatus ';
        System.debug('=== query : ' + query);
        List<KDCE_OfflineProgram__c> programList = Database.query(query);
        System.debug('=== programList : ' + programList);

        for (KDCE_OfflineProgram__c program : programList) {
            if (programListByCon.containsKey(program.Contact__c)) {
                checkProgramList = programListByCon.get(program.Contact__c);
            } else {
                checkProgramList = new List<KDCE_OfflineProgram__c>();
            }
            checkProgramList.add(program);
            programListByCon.put(program.Contact__c, checkProgramList);
        }

        return programListByCon;
    }

    /**
     * @param programStatus
     * @param contacts
     * @param programs
     *
     * @return Map<Id, List<KDCE_Coupon__c>>
     * @description Contact별 조건에 맞는 Coupon Map 반환
     * @author 이지현 (2021.04.26)
     */
    public static Map<Id, List<KDCE_Coupon__c>> getCouponByContactMap(Set<Id> contacts) {

        Map<Id, List<KDCE_Coupon__c>> couponListByCon = new Map<Id, List<KDCE_Coupon__c>>();
        List<KDCE_Coupon__c> checkCouponList;
        String availCouponType      = KDCE_GlobalValue.CONTACT_CHANNEL_CVS;

        String query = '';
        query += ' SELECT Id, Contact__c, UsedDate__c, Type__c ';
        query += ' FROM KDCE_Coupon__c ';
        query += ' WHERE Contact__c IN :contacts ';
        query += ' AND Status__c = :completeCouponStatus ';
        query += ' AND Type__c = :availCouponType';     // TODO CVS 쿠폰 사용만 해당되는게 맞나?
        System.debug('=== query : ' + query);

        List<KDCE_Coupon__c> couponList = Database.query(query);

        System.debug('=== couponList : ' + couponList);
        for (KDCE_Coupon__c coupon : couponList) {
            if (couponListByCon.containsKey(coupon.Contact__c)) checkCouponList = couponListByCon.get(coupon.Contact__c);
            else checkCouponList = new List<KDCE_Coupon__c>();

            checkCouponList.add(coupon);
            couponListByCon.put(coupon.Contact__c, checkCouponList);
        }

        return couponListByCon;
    }

    public static Map<Id, Map<String, Object>> purchaseOrderMap (Map<Id, Map<String, Object>> purchaseByContact, Map<Id, List<KDCE_Order__c>> orderListByCon, Id contactId) {

        Map<String, String> contactChannelByOrderType = new Map<String, String>{                    // Order Type별 Contact Channel Map
                KDCE_GlobalValue.ORDER_TYPE_NORMAL + KDCE_GlobalValue.ORDER_REASON_FORWARD => KDCE_GlobalValue.CONTACT_CHANNEL_ECOMMERCE,
                KDCE_GlobalValue.ORDER_TYPE_RTLBUY + KDCE_GlobalValue.ORDER_REASON_RTLFORWARD => KDCE_GlobalValue.CONTACT_CHANNEL_RENTAL,
                KDCE_GlobalValue.ORDER_TYPE_TRADEIN + KDCE_GlobalValue.ORDER_REASON_FORWARD => KDCE_GlobalValue.CONTACT_CHANNEL_TRADEIN
        };
        Map<String, Object> purchaseMap;

        if (orderListByCon.get(contactId) != null) {
            for (KDCE_Order__c order : orderListByCon?.get(contactId)) {
                System.debug('=== order : ' + order);
                System.debug('=== purchaseByContact.get(order.Contact__c) : ' + purchaseByContact.get(order.Contact__c));

                if (purchaseByContact.get(order.Contact__c) == null) {
                    purchaseMap = new Map<String, Object>();
                    purchaseMap.put('FirstPurchaseDate', order.ShippingStartDate__c);
                    purchaseMap.put('FirstPurchaseChannel', contactChannelByOrderType.get(order.OrderType__c + order.OrderReason__c));
                    purchaseMap.put('FirstPurchaseId', String.valueOf(order.Id));
                    purchaseMap.put('LastPurchaseDate', order.ShippingStartDate__c);
                    purchaseMap.put('LastPurchaseChannel', contactChannelByOrderType.get(order.OrderType__c + order.OrderReason__c));
                    purchaseMap.put('LastPurchaseId', String.valueOf(order.Id));
                    purchaseByContact.put(contactId, purchaseMap);
                }
                else {
                    System.debug('=== purchaseByContact.get(order.Contact__c).get(\'FirstPurchaseDate\') : ' + purchaseByContact.get(order.Contact__c).get('FirstPurchaseDate'));
                    // First Purchase Date 값 비교. Contact의 FPD가 Order의 FPD보다 크면 -> Order의 OrderDate 값 저장
                    if ((Datetime)(purchaseByContact.get(order.Contact__c).get('FirstPurchaseDate')) > order.ShippingStartDate__c) {
                        purchaseMap = purchaseByContact.get(order.Contact__c);
                        purchaseMap.put('FirstPurchaseDate', order.ShippingStartDate__c);
                        purchaseMap.put('FirstPurchaseChannel', contactChannelByOrderType.get(order.OrderType__c + order.OrderReason__c));
                        purchaseMap.put('FirstPurchaseId', String.valueOf(order.Id));
                        purchaseByContact.put(contactId, purchaseMap);
                    }

                    // Last Purchase Date 값 비교. Contact의 LPD가 Order의 LPD보다 크면 -> Order의 OrderDate 값 저장
                    if ((Datetime)(purchaseByContact.get(order.Contact__c).get('LastPurchaseDate')) < order.ShippingStartDate__c) {
                        purchaseMap = purchaseByContact.get(order.Contact__c);
                        purchaseMap.put('LastPurchaseDate', order.ShippingStartDate__c);
                        purchaseMap.put('LastPurchaseChannel', contactChannelByOrderType.get(order.OrderType__c + order.OrderReason__c));
                        purchaseMap.put('LastPurchaseId', String.valueOf(order.Id));
                        purchaseByContact.put(contactId, purchaseMap);
                    }
                }
            }
        }
        System.debug('=== purchaseByContact : ' + purchaseByContact);
        return purchaseByContact;

    }

    public static Map<Id, Map<String, Object>> purchaseProgramMap (Map<Id, Map<String, Object>> purchaseByContact, Map<Id, List<KDCE_OfflineProgram__c>> programListByCon, Id contactId) {
        Map<String, String> contactChannelByOPType = new Map<String, String>{
                KDCE_GlobalValue.ORDER_TYPE_NORMAL => KDCE_GlobalValue.CONTACT_CHANNEL_MANNED,
                KDCE_GlobalValue.OFF_PG_TYPE_UPGRADE => KDCE_GlobalValue.CONTACT_CHANNEL_MANNED,
                KDCE_GlobalValue.OFF_PG_TYPE_RTLBUY => KDCE_GlobalValue.CONTACT_CHANNEL_RENTAL,
                KDCE_GlobalValue.ORDER_TYPE_TRADEIN => KDCE_GlobalValue.CONTACT_CHANNEL_TRADEIN
        };

        Map<String, Object> purchaseMap;

        System.debug('=== programListByCon : ' + programListByCon);
        System.debug('=== purchaseByContact : ' + purchaseByContact);
        if (programListByCon.get(contactId) != null) {
            for (KDCE_OfflineProgram__c program : programListByCon?.get(contactId)) {
                System.debug('=== program : ' + program);
                System.debug('=== purchaseByContact.get(program.Contact__c) : ' + purchaseByContact.get(program.Contact__c));
                if (purchaseByContact.get(program.Contact__c) == null) {
                    purchaseMap = new Map<String, Object>();
                    purchaseMap.put('FirstPurchaseDate', program.PurchaseDate__c);
                    purchaseMap.put('FirstPurchaseChannel', contactChannelByOPType.get(program.ProgramType__c));
                    purchaseMap.put('FirstPurchaseId', String.valueOf(program.Id));
                    purchaseMap.put('LastPurchaseDate', program.PurchaseDate__c);
                    purchaseMap.put('LastPurchaseChannel', contactChannelByOPType.get(program.ProgramType__c));
                    purchaseMap.put('LastPurchaseId', String.valueOf(program.Id));
                    purchaseByContact.put(contactId, purchaseMap);
                }
                else {
                    // First Purchase Date 값 비교. Contact의 FPD가 Order의 FPD보다 크면 -> Order의 OrderDate 값 저장
                    if (purchaseByContact.get(program.Contact__c)?.get('FirstPurchaseDate') != null) {
                        if ((Datetime)(purchaseByContact.get(program.Contact__c).get('FirstPurchaseDate')) > program.PurchaseDate__c) {
                            purchaseMap = purchaseByContact.get(program.Contact__c);
                            purchaseMap.put('FirstPurchaseDate', program.PurchaseDate__c);
                            purchaseMap.put('FirstPurchaseChannel', contactChannelByOPType.get(program.ProgramType__c));
                            purchaseMap.put('FirstPurchaseId', String.valueOf(program.Id));
                            purchaseByContact.put(contactId, purchaseMap);
                        }
                    }

                    // Last Purchase Date 값 비교. Contact의 LPD가 Order의 LPD보다 크면 -> Order의 OrderDate 값 저장
                    if (purchaseByContact.get(program.Contact__c)?.get('LastPurchaseDate') != null) {
                        if ((Datetime)(purchaseByContact.get(program.Contact__c).get('LastPurchaseDate')) < program.PurchaseDate__c) {
                            purchaseMap = purchaseByContact.get(program.Contact__c);
                            purchaseMap.put('LastPurchaseDate', program.PurchaseDate__c);
                            purchaseMap.put('LastPurchaseChannel', contactChannelByOPType.get(program.ProgramType__c));
                            purchaseMap.put('LastPurchaseId', String.valueOf(program.Id));
                            purchaseByContact.put(contactId, purchaseMap);
                        }
                    }
                }
            }
        }
        System.debug('=== purchaseByContact : ' + purchaseByContact);
        return purchaseByContact;
    }

    public static Map<Id, Map<String, Object>> purchaseCouponMap (Map<Id, Map<String, Object>> purchaseByContact, Map<Id, List<KDCE_Coupon__c>> couponListByCon, Id contactId) {

        //String completeCouponStatus = KDCE_GlobalValue.COUPON_STATUS_USE;
        String completeCouponStatus = 'CVS';

        Map<String, Object> purchaseMap;

        if (couponListByCon.get(contactId) != null) {
            for (KDCE_Coupon__c coupon : couponListByCon.get(contactId)) {
                System.debug('=== coupon : ' + coupon);
                System.debug('=== purchaseByContact.get(coupon.Contact__c) : ' + purchaseByContact.get(coupon.Contact__c));

                if (purchaseByContact.get(coupon.Contact__c) == null) {
                    purchaseMap = new Map<String, Object>();
                    purchaseMap.put('FirstPurchaseDate', coupon.UsedDate__c);
                    purchaseMap.put('FirstPurchaseChannel', completeCouponStatus);
                    purchaseMap.put('FirstPurchaseId', coupon.Id);
                    purchaseMap.put('LastPurchaseDate', coupon.UsedDate__c);
                    purchaseMap.put('LastPurchaseChannel', completeCouponStatus);
                    purchaseMap.put('LastPurchaseId', String.valueOf(coupon.Id));
                    purchaseByContact.put(contactId, purchaseMap);
                }
                else {
                    // First Purchase Date 값 비교. Contact의 FPD가 Order의 FPD보다 크면 -> Order의 OrderDate 값 저장
                    if (purchaseByContact.get(coupon.Contact__c)?.get('FirstPurchaseDate') != null) {
                        if ((Datetime)(purchaseByContact.get(coupon.Contact__c).get('FirstPurchaseDate')) > coupon.UsedDate__c) {
                            purchaseMap = purchaseByContact.get(coupon.Contact__c);
                            purchaseMap.put('FirstPurchaseDate', coupon.UsedDate__c);
                            purchaseMap.put('FirstPurchaseChannel', completeCouponStatus);
                            purchaseMap.put('FirstPurchaseId', String.valueOf(coupon.Id));
                            purchaseByContact.put(contactId, purchaseMap);
                        }
                    }

                    // Last Purchase Date 값 비교. Contact의 LPD가 Order의 LPD보다 크면 -> Order의 OrderDate 값 저장
                    if (purchaseByContact.get(coupon.Contact__c)?.get('LastPurchaseDate') != null) {
                        if ((Datetime)(purchaseByContact.get(coupon.Contact__c).get('LastPurchaseDate')) < coupon.UsedDate__c) {
                            purchaseMap = purchaseByContact.get(coupon.Contact__c);
                            purchaseMap.put('LastPurchaseDate', coupon.UsedDate__c);
                            purchaseMap.put('LastPurchaseChannel', completeCouponStatus);
                            purchaseMap.put('LastPurchaseId', String.valueOf(coupon.Id));
                            purchaseByContact.put(contactId, purchaseMap);
                        }
                    }
                }
            }
        }
        System.debug('=== purchaseByContact : ' + purchaseByContact);
        return purchaseByContact;
    }

    public static Map<Id, Contact> getPurchaseResult(Map<Id, Map<String, Object>> purchaseByContact) {

        Contact updateContact;
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();

        for (Id contactId : purchaseByContact.keySet()) {
            if (purchaseByContact.get(contactId) != null) {
                updateContact = new Contact();
                updateContact.Id = contactId;
                if (purchaseByContact?.get(contactId)?.get('FirstPurchaseDate') != null) {
                    updateContact.KDCE_FirstPurchaseDate__c = (Datetime) purchaseByContact.get(contactId).get('FirstPurchaseDate');
                    updateContact.KDCE_FirstPurchaseChannel__c = String.valueOf(purchaseByContact.get(contactId).get('FirstPurchaseChannel'));
                    updateContact.KDCE_FirstPurchaseId__c = String.valueOf(purchaseByContact.get(contactId).get('FirstPurchaseId'));
                    updateContactMap.put(contactId, updateContact);
                }
                if (purchaseByContact?.get(contactId)?.get('LastPurchaseDate') != null) {
                    if (updateContactMap.containsKey(contactId)) updateContact = updateContactMap.get(contactId);
                    updateContact.KDCE_LastPurchaseDate__c = (Datetime) purchaseByContact.get(contactId).get('LastPurchaseDate');
                    updateContact.KDCE_LastPurchaseChannel__c = String.valueOf(purchaseByContact.get(contactId).get('LastPurchaseChannel'));
                    updateContact.KDCE_LastPurchaseId__c = String.valueOf(purchaseByContact.get(contactId).get('LastPurchaseId'));
                }
                if (purchaseByContact?.get(contactId)?.get('FirstPurchaseDate') == null && purchaseByContact?.get(contactId)?.get('LastPurchaseDate') == null) {
                    updateContact.KDCE_FirstPurchaseDate__c     = null;
                    updateContact.KDCE_FirstPurchaseChannel__c  = null;
                    updateContact.KDCE_FirstPurchaseId__c       = null;
                    updateContact.KDCE_LastPurchaseDate__c      = null;
                    updateContact.KDCE_LastPurchaseChannel__c   = null;
                    updateContact.KDCE_LastPurchaseId__c       = null;
                }
                updateContactMap.put(contactId, updateContact);
            }
        }

        return updateContactMap;
    }



}