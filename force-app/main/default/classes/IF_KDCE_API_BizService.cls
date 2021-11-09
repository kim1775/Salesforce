/****************************************************************************************
  * @filename      : IF_KDCE_API_BizService
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/19 3:35 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   :
  * @tester        : IF_KDCE_API_BizService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/19 3:35 오후     i2max_shlee       Create
    0.2     2021/03/08              i2max_Sukun       Update
    0.3     2021/03/16              i2max_Sukun       Update
    0.4     2021/05/24              i2max_Sukun       Update
****************************************************************************************/
public without sharing class IF_KDCE_API_BizService {
    private enum SourceSystem { 
        Magento, POS
    }
    /*
        Validation MSG 정의
        final String 변수명 명명규칙 : LAB_IF_ERR_[Module Name]_[Message Descripiton]
        custom label 명명규칙 : LAB_IF_ERR_[Module Name]_[Message Descripiton]
     */
    // Contact
    private static final String LAB_IF_ERR_CONTACT_MOBILEPHONE_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_MOBILEPHONE_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_DOES_NOT_EXIST = System.Label.LAB_IF_ERR_CONTACT_DOES_NOT_EXIST;
    private static final String LAB_IF_ERR_CONTACT_EXTERNALID_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_EXTERNALID_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_NAME_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_NAME_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_MOBILECARRIER_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_MOBILECARRIER_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_REGISTRATIONCHANNEL_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_REGISTRATIONCHANNEL_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_REGISTRATIONCHANNEL_INVALID = System.Label.LAB_IF_ERR_CONTACT_REGISTRATIONCHANNEL_INVALID;
    private static final String LAB_IF_ERR_CONTACT_HARDAGEVERIFICATION_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_HARDAGEVERIFICATION_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_HARDAVSTATUSDATECHANGE_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_HARDAVSTATUSDATECHANGE_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_ISDORMANT_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_ISDORMANT_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_RESTOREDORMANTDATE_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_RESTOREDORMANTDATE_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_DROPOUTREQUEST_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_DROPOUTREQUEST_REQUIRED;
    private static final String LAB_IF_ERR_CONTACT_DROPOUTREQUESTDATE_REQUIRED = System.Label.LAB_IF_ERR_CONTACT_DROPOUTREQUESTDATE_REQUIRED;
    // Product
    private static final String LAB_IF_ERR_PRODUCT_EANCODE_REQUIRED = System.Label.LAB_IF_ERR_PRODUCT_EANCODE_REQUIRED;
    private static final String LAB_IF_ERR_PRODUCT_EANCODE_LIST_EMPTY = System.Label.LAB_IF_ERR_PRODUCT_EANCODE_LIST_EMPTY;
    private static final String LAB_IF_ERR_PRODUCT_EANCODE_LIST_DO_NOT_EXIST = System.Label.LAB_IF_ERR_PRODUCT_EANCODE_LIST_DO_NOT_EXIST;
    // Order
    private static final String LAB_IF_ERR_ORDER_ACTIONCHANNEL_REQUIRED = System.Label.LAB_IF_ERR_ORDER_ACTIONCHANNEL_REQUIRED;
    private static final String LAB_IF_ERR_ORDER_ACTIONTYPE_REQUIRED = System.Label.LAB_IF_ERR_ORDER_ACTIONTYPE_REQUIRED;
    private static final String LAB_IF_ERR_ORDER_ORDERNO_REQUIRED = System.Label.LAB_IF_ERR_ORDER_ORDERNO_REQUIRED;
    private static final String LAB_IF_ERR_ORDER_ORDERTYPE_REQUIRED = System.Label.LAB_IF_ERR_ORDER_ORDERTYPE_REQUIRED;
    private static final String LAB_IF_ERR_ORDER_CONTACTEXTID_REQUIRED = System.Label.LAB_IF_ERR_ORDER_CONTACTEXTID_REQUIRED;
    private static final String LAB_IF_ERR_ORDER_ORDERTYPE_INVALID = System.Label.LAB_IF_ERR_ORDER_ORDERTYPE_INVALID;
    // Order Line Item
    private static final String LAB_IF_ERR_ORDERLINEITEM_ORDERITEMNO_REQUIRED = System.Label.LAB_IF_ERR_ORDERLINEITEM_ORDERITEMNO_REQUIRED;
    // Asset
    private static final String LAB_IF_ERR_ASSET_SERIALNUMBER_CONDENTIFYID_REQUIRED = System.Label.LAB_IF_ERR_ASSET_SERIALNUMBER_CONDENTIFYID_REQUIRED;
    private static final String LAB_IF_ERR_ASSET_CONTACTEXTID_REQUIRED = System.Label.LAB_IF_ERR_ASSET_CONTACTEXTID_REQUIRED;
    private static final String LAB_IF_ERR_ASSET_ACTIONTYPE_REQUIRED = System.Label.LAB_IF_ERR_ASSET_ACTIONTYPE_REQUIRED;
    private static final String LAB_IF_ERR_ASSET_ACTIONDATE_REQUIRED = System.Label.LAB_IF_ERR_ASSET_ACTIONDATE_REQUIRED;
    // TnC
    private static final String LAB_TNC_HISTORY_DESC_DECLINE_MARKETING = System.Label.LAB_TNC_HISTORY_DESC_DECLINE_MARKETING;
    private static final String LAB_TNC_HISTORY_DESC_DECLINE_INFORMATION = System.Label.LAB_TNC_HISTORY_DESC_DECLINE_INFORMATION;
    private static final String LAB_TNC_HISTORY_DESC_DECLINE_MARKETINGANDINFORMATION = System.Label.LAB_TNC_HISTORY_DESC_DECLINE_MARKETINGANDINFORMATION;


    //Object's RecordType
    private final static Id RT_Contact_AnonymousId      = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Anonymous').getRecordTypeId();    // 고객 : Anonymous
    private final static Id RT_Contact_ProspectId       = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Prospect').getRecordTypeId();     // 고객 : Prospect
    private final static Id RT_Contact_MemberId         = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_Member').getRecordTypeId();       // 고객 : iqos.com 회원 멤버
    private final static Id RT_Coupon_CVSId             = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_CVS').getRecordTypeId();    // 쿠폰 : 편의점
    private final static Id RT_Coupon_GetInfo           = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_GetInfo').getRecordTypeId();// 쿠폰 : Getinfo
    private final static Id RT_Coupon_MGM               = Schema.SObjectType.KDCE_Coupon__c.getRecordTypeInfosByDeveloperName().get('Coupon_MGM').getRecordTypeId();    // 쿠폰 : MGM
    private final static Id RT_Order_Normal             = Schema.SObjectType.KDCE_Order__c.getRecordTypeInfosByDeveloperName().get('Order_NORMAL').getRecordTypeId();   // 주문 : 일반주문
    private final static Id RT_Order_Rental             = Schema.SObjectType.KDCE_Order__c.getRecordTypeInfosByDeveloperName().get('Order_RENTAL').getRecordTypeId();   // 주문 : 렌탈
    private final static Id RT_Order_Replace            = Schema.SObjectType.KDCE_Order__c.getRecordTypeInfosByDeveloperName().get('Order_REPLACE').getRecordTypeId();  // 주문 : QURE
    private final static Id RT_Order_TradeIn            = Schema.SObjectType.KDCE_Order__c.getRecordTypeInfosByDeveloperName().get('Order_TRADEIN').getRecordTypeId();  // 주문 : 보상판매
    private final static Id RT_Order_Upgrade            = Schema.SObjectType.KDCE_Order__c.getRecordTypeInfosByDeveloperName().get('Order_UPGRADE').getRecordTypeId();  // 주문 : 업그레이드 : 회수X

    /* POS IF Service */
    /**
     * @description POS시스템에서 EANCode(88코드) 기준 Product Master 필드 업데이트
     * @param (List<IF_KDCE_API_BizBase.T_Product>) tProducts
     * @return : 반환값에 생성,업데이트된 Record 정보 매핑
     */
    public static List<IF_KDCE_API_BizBase.T_Product> setProductsByPOS(List<IF_KDCE_API_BizBase.T_Product> tProducts) {

        System.debug('List<IF_KDCE_API_BizBase.T_Product> tProducts : ' + tProducts);

        /* Validation */
        Map<String, IF_KDCE_API_BizBase.T_Product> tProductMap = new Map<String, IF_KDCE_API_BizBase.T_Product>();
        for (IF_KDCE_API_BizBase.T_Product tProduct : tProducts) {
            // T_Product 의 KDCE_EANCode 는 update key 값임
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tProduct.KDCE_EANCode), LAB_IF_ERR_PRODUCT_EANCODE_REQUIRED);
            tProductMap.put(tProduct.KDCE_EANCode, tProduct);
        }

        IF_KDCE_API_BizBase.validate(false, tProductMap.keySet().isEmpty(), LAB_IF_ERR_PRODUCT_EANCODE_LIST_EMPTY);

        List<Product2> products = [SELECT Id, KDCE_EANCode__c FROM Product2 WHERE KDCE_EANCode__c IN :tProductMap.keySet()];

        IF_KDCE_API_BizBase.validate(false, products.isEmpty(), LAB_IF_ERR_PRODUCT_EANCODE_LIST_DO_NOT_EXIST);

        //Product 레코드 맵핑 Product (*Version) : EANCode 1:N 관계임.
        IF_KDCE_API_BizBase.T_Product tProduct;
        for (Product2 product : products) {
            if (tProductMap.containsKey(product.KDCE_EANCode__c))
                tProduct = tProductMap.get(product.KDCE_EANCode__c);

            product.KDEC_POS_ProductName__c         = tProduct.KDEC_POS_ProductName;
            product.KDEC_POS_ProductDescription__c  = tProduct.KDEC_POS_ProductDescription;
            product.KDEC_POS_ProductCategory__c     = tProduct.KDEC_POS_ProductCategory;
        }
        update products;

        // 업데이트 결과 매핑
        tProducts = new List<IF_KDCE_API_BizBase.T_Product>();
        for (Product2 product : products) {
            tProduct = new IF_KDCE_API_BizBase.T_Product();
            tProduct.Id = product.Id;
            tProduct.KDCE_EANCode = product.KDCE_EANCode__c;
            tProducts.add(tProduct);
        }

        return tProducts;

    }

    /**
     * @description POS Contact 조회 IF_POS_DCE_0143
     * @param IF_KDCE_API_BizBase.T_Contact tContact (Phone 4digit Number)
     * @return : 반환값에 Retrieve된 Contact List
     */
    public static List<IF_KDCE_API_BizBase.T_POS_Contact> getContactsByPOS(IF_KDCE_API_BizBase.T_POS_Contact tContact) {
        List<IF_KDCE_API_BizBase.T_POS_Contact> tContacts = null;

        IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.Mobile4Digit), LAB_IF_ERR_CONTACT_MOBILEPHONE_REQUIRED);
        String searchPhone = '%' + tContact.Mobile4Digit;

        String query = 'SELECT ';
        query += '   Id,KDCE_ExternalId__c,KDCE_fm_POS_NameMask__c,KDCE_fm_POS_BirthdateMask__c,KDCE_fm_POS_PhoneMask__c,CCR_Gender__c,KDCE_fm_ConsumerType__c,KDCE_LASLAU__c, ';
        query += '   LastModifiedDate,CreatedDate ';
        query += 'FROM Contact ';
        query += 'WHERE KDCE_IsDormant__c = false AND KDCE_IsDropout__c = false ' ;
        if (!Test.isRunningTest()) query += 'AND KDCE_PNKey__c LIKE :searchPhone ' ;
        query += 'ORDER BY KDCE_Name__c ';
        List<Contact> contacts = database.query(query);
        IF_KDCE_API_BizBase.validate(false, contacts.isEmpty(), LAB_IF_ERR_CONTACT_DOES_NOT_EXIST);

        //Mapping
        tContacts = new List<IF_KDCE_API_BizBase.T_POS_Contact>();
        IF_KDCE_API_BizBase.T_POS_Contact tCon;
        for (Contact contact : contacts) {
            tCon = new IF_KDCE_API_BizBase.T_POS_Contact();
//            tCon.Id                         = contact.Id;
            tCon.ContactExtId       = contact.KDCE_ExternalId__c;
            tCon.Mobile4Digit       = '';
            tCon.NameMask           = IF_Comm.convertEmpty(contact.KDCE_fm_POS_NameMask__c);
            tCon.MobilePhoneMask    = IF_Comm.convertEmpty(contact.KDCE_fm_POS_PhoneMask__c);
            tCon.ConsumerType       = IF_Comm.convertEmpty(contact.KDCE_fm_ConsumerType__c)+'-'+IF_Comm.convertEmpty(contact.KDCE_LASLAU__c);
//            tCon.Gender             = IF_Comm.convertEmpty(contact.CCR_Gender__c);
            tCon.BirthDateMask      = IF_Comm.convertEmpty(contact.KDCE_fm_POS_BirthdateMask__c);
            tCon.CreatedDate        = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.CreatedDate);
            tCon.LastModifiedDate   = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.LastModifiedDate);
            tContacts.add(tCon);
        }

        return tContacts;
    }

    /**
     * @description POS시스템에서 주문 정보 전송 생성 IF_POS_DCE_0129
     * @param (List<IF_KDCE_API_BizBase.T_Order>) tOrders
     * @return : 반환값에 생성된 Order Record 정보 매핑
     */
    public static List<IF_KDCE_API_BizBase.T_Order> setOrdersByPOS(List<IF_KDCE_API_BizBase.T_Order> tOrders) {

        Map<String, Contact>                contactExtIdMap  = new Map<String, Contact>();
        Map<String, KDCE_Order__c>          orderMap         = new Map<String, KDCE_Order__c>();
        Map<String, KDCE_OrderLineItem__c>  orderLineItemMap = new Map<String, KDCE_OrderLineItem__c>();
        Map<String, KDCE_Coupon__c>         couponMap        = new Map<String, KDCE_Coupon__c>();
        Map<String, Product2>               productEANMap    = new Map<String, Product2>();
        Map<String, KDCE_Store__c>          storeMap         = new Map<String, KDCE_Store__c>();
        Map<String, KDCE_Order__c>          originOrderMap   = new Map<String, KDCE_Order__c>();

//        // Store Search
//        Id storeId = null;
//        List<KDCE_Store__c> store = [SELECT Id FROM KDCE_Store__c WHERE OrgCode__c = :storeCode LIMIT 1];
//        if (store.size() > 0) storeId = store[0].Id;

        /* Validation */
        for (IF_KDCE_API_BizBase.T_Order tOrder : tOrders) {
            if(Util.isEmpty(tOrder.ActionChannel)) tOrder.ActionChannel = 'POS';
            if(Util.isEmpty(tOrder.ActionType)) tOrder.ActionType = 'C';
            // TODO Validation 최종협의 후 반영할 것
//            if(tOrder.OrderStatus == 'cancel_order') IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.OriginOrderNo) , '[tOrders.OriginOrderNo] is Required when it comes to Cancellation Order.');
//            if(!Util.isEmpty(tOrder.OriginOrderNo)) IF_KDCE_API_BizBase.validate(true, tOrder.OrderStatus == 'cancel_order', '[tOrders.OrderStatus] must be [cancel_order] once [tOrders.OriginOrderNo] is provided.');
            // T_TermsAndConditionsHistory Validation
            //tTnCHistories.ContactId required
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ActionChannel), LAB_IF_ERR_ORDER_ACTIONCHANNEL_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ActionType), LAB_IF_ERR_ORDER_ACTIONTYPE_REQUIRED);
//            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ContactExtId), '[tOrders.ContactExtId] is Required.');
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.OrderNo), LAB_IF_ERR_ORDER_ORDERNO_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.OrderType), LAB_IF_ERR_ORDER_ORDERTYPE_REQUIRED);
//            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ExtOrderId), '[tOrders.ExtOrderId] is Required.');
//            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tTncHistory.KDCE_TnCId), '[tTncHistory.KDCE_TnCId] is Required.');
            contactExtIdMap.put(tOrder.ContactExtId, null);
            orderMap.put(tOrder.OrderNo, null);
            couponMap.put(tOrder.CouponCode, null);
            storeMap.put(tOrder.StoreCode, null);
            originOrderMap.put(tOrder.OriginOrderNo, null);

            if(tOrder?.t_OrderItems != null) {
                for (IF_KDCE_API_BizBase.T_OrderLineItem tOrderLineItem : tOrder.t_OrderItems) {
                    productEANMap.put(tOrderLineItem.KDCE_EANCode, null);
                    IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrderLineItem.OrderItemNo), LAB_IF_ERR_ORDERLINEITEM_ORDERITEMNO_REQUIRED);
                }
            }
        }
        //get Contacts by contactExtIds
        if (contactExtIdMap.keySet().size() > 0) {
            for (Contact con : [SELECT Id,RecordTypeId, KDCE_ExternalId__c, KDCE_fm_ConsumerType__c, KDCE_TnCVersion__c FROM Contact WHERE KDCE_ExternalId__c IN :contactExtIdMap.keySet()]) {
                contactExtIdMap.put(con.KDCE_ExternalId__c, con);
            }
        }
        //get Coupon by CouponCode
        if (couponMap.keySet().size() > 0) {
            for (KDCE_Coupon__c coupon : [SELECT Id, Name, RecordTypeId, CouponCode__c FROM KDCE_Coupon__c WHERE CouponCode__c IN :couponMap.keySet()]) {
                couponMap.put(coupon.CouponCode__c, coupon);
            }
        }
        // get Product by ProductCode
        if (productEANMap.keySet().size() > 0) {
            for (Product2 prod : [SELECT Id, Name, KDCE_EANCode__c FROM Product2 WHERE KDCE_EANCode__c IN :productEANMap.keySet() ORDER BY CreatedDate]) {
                productEANMap.put(prod.KDCE_EANCode__c, prod);
            }
        }

        if (storeMap.keySet().size() > 0) {
            // TODO Store Code 확인 필요
            for (KDCE_Store__c store : [SELECT Id, Name, BizLOCCode__c FROM KDCE_Store__c WHERE BizLOCCode__c IN :storeMap.keySet()]) {
                storeMap.put(store.BizLOCCode__c, store);
            }
        }

        /*
        // get Origin Order by OriginOrderNo
        if (originOrderMap.keySet().size() > 0) {
            for (KDCE_Order__c originOrder : [ SELECT Id, Name, OrderNo__c FROM KDCE_Order__c WHERE OrderNo__c IN :originOrderMap.keySet()]) {
                originOrderMap.put(originOrder.OrderNo__c, originOrder);
            }
        }
        */

        KDCE_Order__c   order               = null;
        KDCE_OrderLineItem__c orderLineItem = null;
        for (IF_KDCE_API_BizBase.T_Order tOrder : tOrders) {

//            IF_KDCE_API_BizBase.validate(TRUE, contactExtIdMap.containsKey(tOrder.ContactExtId) && Util.isNotEmpty(contactExtIdMap.get(tOrder.ContactExtId)), '[tOrders.ContactExtId] does not match or exist. please check ContactExtId.');

            order = new KDCE_Order__c(
                    OrderNo__c = tOrder.OrderNo
            );
            if (Util.isNotEmpty(tOrder.ContactExtId)) order.Contact__c = contactExtIdMap.get(tOrder.ContactExtId)?.Id;
            if (Util.isNotEmpty(tOrder.ContactExtId)) order.CustomerId__c = tOrder.ContactExtId;
            order.ActionChannel__c = tOrder.ActionChannel;
            order.ActionType__c = tOrder.ActionType;
            order.OrderType__c = tOrder.OrderType; // PickList Validation
            // POS Order Type 확정 시 변경
            order.RecordTypeId = RT_Order_Normal;

            /*
            switch on tOrder.OrderType {
                when 'ZTA' {
                    order.RecordTypeId = RT_Order_Normal;
                }
                when 'ZTI' {
                    order.RecordTypeId = RT_Order_TRADEIN;
                }
                when 'ZRNNEW' {
                    order.RecordTypeId = RT_Order_Rental;
                }
                when 'ZRN' {
                    order.RecordTypeId = RT_Order_Rental;
                }
                when 'ZRA' {
                    order.RecordTypeId = RT_Order_Replace;
                }
//                // POS용
//                when somethingPOS {
//                    order.RecordTypeId = RT_Order_Upgrade;
//                }
                when else {
                    IF_KDCE_API_BizBase.validate(true, true, '[tOrders.OrderType] is not valid.');
                }
            }
            */

            if (Util.isNotEmpty(tOrder.OrderDate)) order.OrderDate__c = IF_KDCE_API_BizBase.convertStringToDatetime(tOrder.OrderDate);
            if (Util.isNotEmpty(tOrder.OriginOrderNo)) order.OriginOrderNo__c = tOrder.OriginOrderNo;
            //if (Util.isNotEmpty(tOrder.OriginOrderNo)) order.OriginOrder__c = originOrderMap.get(tOrder.OriginOrderNo)?.Id;
            if (Util.isNotEmpty(tOrder.OrderReason)) order.OrderReason__c = tOrder.OrderReason;
            if (Util.isNotEmpty(tOrder.OrderCurrency)) order.Currency__c = tOrder.OrderCurrency;
//            if (Util.isNotEmpty(tOrder.CustomerName)) order.CustomerName__c = tOrder.CustomerName;
//            if (Util.isNotEmpty(tOrder.CustomerEmail)) order.CustomerEmail__c = tOrder.CustomerEmail;
            if (Util.isNotEmpty(tOrder.OrderStatus)) order.OrderStatus__c = tOrder.OrderStatus;
            if (Util.isNotEmpty(tOrder.OrderState)) order.OrderState__c = tOrder.OrderState;
//            if (Util.isNotEmpty(tOrder.ShippingAddressName)) order.ShippingAddressName__c = tOrder.ShippingAddressName;
//            if (Util.isNotEmpty(tOrder.ShippingState)) order.ShippingState__c = tOrder.ShippingState;
//            if (Util.isNotEmpty(tOrder.ShippingCity)) order.ShippingCity__c = tOrder.ShippingCity;
//            if (Util.isNotEmpty(tOrder.ShippingStreet)) order.ShippingStreet__c = tOrder.ShippingStreet;
//            if (Util.isNotEmpty(tOrder.ShippingPostalCode)) order.ShippingPostalCode__c = tOrder.ShippingPostalCode;
//            if (Util.isNotEmpty(tOrder.ShippingCountry)) order.ShippingCountryCode__c = tOrder.ShippingCountry;
//            if (Util.isNotEmpty(tOrder.ShippingPhone)) order.ShippingPhone__c = tOrder.ShippingPhone;
//            if (Util.isNotEmpty(tOrder.ShippingTax)) order.ShippingTax__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.ShippingTax);
//            if (Util.isNotEmpty(tOrder.ShippingGrossPrice)) order.ShippingGrossPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.ShippingGrossPrice);
//            if (Util.isNotEmpty(tOrder.ShippingItemId)) order.ShippingItemId__c = tOrder.ShippingItemId;
//            if (Util.isNotEmpty(tOrder.ShippingMethod)) order.ShippingMethod__c = tOrder.ShippingMethod;
            if (Util.isNotEmpty(tOrder.GrossPrice)) order.GrossPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.GrossPrice);
            if (Util.isNotEmpty(tOrder.Discount)) order.Discount__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.Discount);
//            if (Util.isNotEmpty(tOrder.TaxBasis)) order.TaxBasis__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.TaxBasis);
//            if (Util.isNotEmpty(tOrder.Tax)) order.Tax__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.Tax);
            if (Util.isNotEmpty(tOrder.NetPrice)) order.NetPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.NetPrice);
            if (Util.isNotEmpty(tOrder.PaymentAmount)) order.PaymentAmount__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.PaymentAmount);
            if (Util.isNotEmpty(tOrder.PaymentMethod)) order.PaymentMethod__c = tOrder.PaymentMethod;
//            if (Util.isNotEmpty(tOrder.PaymentProcessorId)) order.PaymentProcessorId__c = tOrder.PaymentProcessorId;
            if (Util.isNotEmpty(tOrder.PaymentTransactionId)) order.PaymentTransactionId__c = tOrder.PaymentTransactionId;
            if (Util.isNotEmpty(tOrder.PromotionId)) order.PromotionId__c = tOrder.PromotionId;
            if (Util.isNotEmpty(tOrder.PromotionName)) order.PromotionName__c = tOrder.PromotionName;
            if (Util.isNotEmpty(tOrder.CouponCode)) order.CouponCode__c = tOrder.CouponCode;
            if (Util.isNotEmpty(tOrder.CouponCode)) order.Coupon__c = couponMap.get(tOrder.CouponCode)?.Id;
            if (Util.isNotEmpty(tOrder.StoreCode)) order.Store__c = storeMap.get(tOrder.StoreCode)?.Id;
            if (Util.isNotEmpty(tOrder.ExtOrderId)) order.EntityId__c = tOrder.ExtOrderId;

            orderMap.put(order.OrderNo__c, order);
        }

        upsert orderMap.values() OrderNo__c;

        // get Origin Order by OriginOrderNo
        if (originOrderMap.keySet().size() > 0) {
            for (KDCE_Order__c originOrder : [
                    SELECT Id, OrderNo__c
                    FROM KDCE_Order__c
                    WHERE OrderNo__c IN :originOrderMap.keySet()
            ])
            {
                originOrderMap.put(originOrder.OrderNo__c, originOrder);
            }
        }

        // Original Order 처리
        for(KDCE_Order__c header : orderMap.values()){
            if(header.OriginOrderNo__c != null) header.OriginOrder__c = originOrderMap.get(header.OriginOrderNo__c)?.Id;
        }

        KDCE_Order__c header = null;
        Decimal headerTax;
        Decimal headerSupply;

        for (IF_KDCE_API_BizBase.T_Order tOrd : tOrders) {
            if(tOrd?.t_OrderItems != null) {

                header = orderMap.get(tOrd.OrderNo);
                headerTax = 0;
                headerSupply = 0;

                for (IF_KDCE_API_BizBase.T_OrderLineItem tOrderLineItem : tOrd.t_OrderItems) {
                    /*
                    orderLineItem = new KDCE_OrderLineItem__c(
                            Order__c = orderMap.get(tOrd.OrderNo).Id
                    );
                    */

                    orderLineItem = new KDCE_OrderLineItem__c(
                            Order__c = header.Id
                    );

                    // Order Line Item 에서 로직 처리를 위해 Header에 있는 필드와 동기화 시켜줌
                    orderLineItem.OrderType__c = header.OrderType__c;
                    orderLineItem.OrderReason__c = header.OrderReason__c;
                    orderLineItem.OrderStatus__c = header.OrderStatus__c;

                    if (Util.isNotEmpty(tOrderLineItem.OrderItemNo)) orderLineItem.EntityId__c = tOrderLineItem.OrderItemNo;
                    if (Util.isNotEmpty(tOrderLineItem.ProductQuantity)) orderLineItem.ProductQuantity__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductQuantity);
                    if (Util.isNotEmpty(tOrderLineItem.ProductIGrossPrice)) orderLineItem.ProductGrossPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductIGrossPrice);
                    if (Util.isNotEmpty(tOrderLineItem.ProductItemDiscount)) orderLineItem.ProductItemDiscount__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductItemDiscount);
                    if (Util.isNotEmpty(tOrderLineItem.ProductTaxBasis)) orderLineItem.ProductTaxBasis__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductTaxBasis);
                    if (Util.isNotEmpty(tOrderLineItem.ProductTaxRate)) orderLineItem.ProductTaxRate__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductTaxRate);
                    if (Util.isNotEmpty(tOrderLineItem.ProductTax)) orderLineItem.ProductTax__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductTax);
                    if (Util.isNotEmpty(tOrderLineItem.ProductNetPrice)) orderLineItem.ProductNetPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductNetPrice);
//                if (Util.isNotEmpty(tOrderLineItem.ShipStatus)) orderLineItem.ShipStatus__c = tOrderLineItem.ShipStatus; // 제외검토
//                if (Util.isNotEmpty(tOrderLineItem.ShipStatusDate)) orderLineItem.ShipStatusDate__c = IF_KDCE_API_BizBase.convertStringToDatetime(tOrderLineItem.ShipStatusDate); // 변경검토
//                if (Util.isNotEmpty(tOrderLineItem.ShipQuantity)) orderLineItem.ShipQuantity__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ShipQuantity); // 변경검토
//                if (Util.isNotEmpty(tOrderLineItem.TrackingNo)) orderLineItem.TrackingNo__c = tOrderLineItem.TrackingNo; // 변경검토
//                if (Util.isNotEmpty(tOrderLineItem.TrackingUrl)) orderLineItem.TrackingUrl__c = tOrderLineItem.TrackingUrl; // 변경검토
//                if (Util.isNotEmpty(tOrderLineItem.FullProductId)) orderLineItem.FullProductId__c = tOrderLineItem.FullProductId;
//                if (Util.isNotEmpty(tOrderLineItem.Codentify)) orderLineItem.Codentify__c = tOrderLineItem.Codentify; // Codentify 있을 경우 Product 매핑은 정확한 Product 및 Asset으로 OrderItem Trigger에서 진행
                    if (Util.isNotEmpty(tOrderLineItem.KDCE_EANCode)) orderLineItem.Product__c = productEANMap.get(tOrderLineItem.KDCE_EANCode)?.Id;
                    if (Util.isNotEmpty(tOrderLineItem.KDCE_EANCode)) orderLineItem.EANCode__c = tOrderLineItem.KDCE_EANCode;

                    // 공급가액, 부가세 계산
                    orderLineItem.ProductTax__c = 0;
                    orderLineItem.ProductSupplyPrice__c = 0;

                    if(orderLineItem.ProductNetPrice__c != null){
                        orderLineItem.ProductTax__c = Math.round(orderLineItem.ProductNetPrice__c / 11);
                        orderLineItem.ProductSupplyPrice__c = orderLineItem.ProductNetPrice__c - orderLineItem.ProductTax__c;
                    }

                    headerTax += orderLineItem.ProductTax__c;
                    headerSupply += orderLineItem.ProductSupplyPrice__c;

                    orderLineItemMap.put(orderLineItem.EntityId__c, orderLineItem);
                }

                header.Tax__c = headerTax;
                header.SupplyPrice__c = headerSupply;
            }
        }

        upsert orderLineItemMap.values() EntityId__c;

        upsert orderMap.values() OrderNo__c;

        // 업데이트 결과 매핑
        Id currentOrderId;
        Map<Id, List<Id>> orderIdMap = new Map<Id, List<Id>>();
        List<Id> orderLineItemIds;
        if (orderMap.values().size() > 0) {
            for (KDCE_Order__c sOrder : orderMap.values()) {
                currentOrderId = sOrder.Id;
                orderLineItemIds = new List<Id>();
                for (KDCE_OrderLineItem__c sOrderLineItem : orderLineItemMap.values()) {
                    if(sOrderLineItem.Order__c == currentOrderId) orderLineItemIds.add(sOrderLineItem.Id);
                }
                orderIdMap.put(sOrder.Id, orderLineItemIds);
            }
        }

        List<IF_KDCE_API_BizBase.T_Order> tOrderList = new List<IF_KDCE_API_BizBase.T_Order>();
        IF_KDCE_API_BizBase.T_Order tOrder;
        List<IF_KDCE_API_BizBase.T_OrderLineItem> tOrderLineItems;
        IF_KDCE_API_BizBase.T_OrderLineItem tOrderLineItem;

        for (Id id : orderIdMap.keySet()) {
            tOrder = new IF_KDCE_API_BizBase.T_Order();
            tOrder.Id = id;
            tOrderLineItems = new List<IF_KDCE_API_BizBase.T_OrderLineItem>();
            for (Id orderLineItemId : orderIdMap.get(id)) {
                tOrderLineItem = new IF_KDCE_API_BizBase.T_OrderLineItem();
                tOrderLineItem.Id = orderLineItemId;
            }
            tOrder.t_OrderItems = tOrderLineItems;

            tOrderList.add(tOrder);
        }

        return tOrderList;
    }

    /* Ecommerce - Magento IF Service  */
    /**
     * @description Magento시스템에서 EANCode(88코드) 기준 Product Master 필드 업데이트
     * @param (List<IF_KDCE_API_BizBase.T_Product>) tProducts
     * @return : 반환값에 생성,업데이트된 Record 정보 매핑
     */
    public static List<IF_KDCE_API_BizBase.T_Product> setProductsByMagento(List<IF_KDCE_API_BizBase.T_Product> tProducts) {

        System.debug('List<IF_KDCE_API_BizBase.T_Product> tProducts : ' + tProducts);

        /* Validation */
        Map<String, IF_KDCE_API_BizBase.T_Product> tProductMap = new Map<String, IF_KDCE_API_BizBase.T_Product>();
        Set<String> productSKUSet = new Set<String>();
        for (IF_KDCE_API_BizBase.T_Product tProduct : tProducts) {
            // T_Product 의 KDCE_EANCode 는 update key 값임
            //IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tProduct.KDCE_EANCode), LAB_IF_ERR_PRODUCT_EANCODE_REQUIRED);
            //tProductMap.put(tProduct.KDCE_EANCode, tProduct);

            // 2021.07.08 T_Product 의 KDCE_EANCode 는 update key 값
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tProduct.KDCE_MG_SKU), LAB_IF_ERR_PRODUCT_EANCODE_REQUIRED);
            tProductMap.put(tProduct.KDCE_MG_SKU, tProduct);
            productSKUSet.add(tProduct.KDCE_MG_SKU);
        }

        IF_KDCE_API_BizBase.validate(false, tProductMap.keySet().isEmpty(), LAB_IF_ERR_PRODUCT_EANCODE_LIST_EMPTY);

        //List<Product2> products = [SELECT Id, KDCE_EANCode__c FROM Product2 WHERE KDCE_EANCode__c IN :tProductMap.keySet()];
        String productQuery = '';
        productQuery += ' SELECT Id, ProductCode, KDCE_EANCode__c, KDCE_MG_Material__c FROM Product2 ';
        if (!Test.isRunningTest()) productQuery += ' WHERE ProductCode IN :productSKUSet ';
        System.debug('=== productQuery : ' + productQuery);
        List<Product2> products = Database.query(productQuery);
        System.debug('=== products : ' + products);
//        List<Product2> products = [SELECT Id, ProductCode, KDCE_EANCode__c FROM Product2 WHERE ProductCode IN :tProductMap.keySet()];

        IF_KDCE_API_BizBase.validate(false, products.isEmpty(), LAB_IF_ERR_PRODUCT_EANCODE_LIST_DO_NOT_EXIST);

        //Product 레코드 맵핑 Product (*Version) : EANCode 1:N 관계임.
        IF_KDCE_API_BizBase.T_Product tProduct;
        for (Product2 product : products) {
            //if (tProductMap.containsKey(product.KDCE_EANCode__c)) tProduct = tProductMap.get(product.KDCE_EANCode__c);
            if (tProductMap.containsKey(product.ProductCode)) {
                tProduct = tProductMap.get(product.ProductCode);
                product.KDCE_MG_Id__c = tProduct?.KDCE_MG_Id;
                product.KDCE_MG_SKU__c = tProduct?.KDCE_MG_SKU;
                product.KDCE_MG_ProductName_ko__c = tProduct?.KDCE_MG_ProductName_ko;
                product.KDCE_MG_Price__c = IF_KDCE_API_BizBase.convertStringToDecimal(tProduct?.KDCE_MG_Price);
                product.KDCE_MG_TaxClass__c = tProduct?.KDCE_MG_TaxClass;
                product.KDCE_MG_Visibility__c = tProduct?.KDCE_MG_Visiblity;
                product.KDCE_MG_ManufactureCountry__c = tProduct?.KDCE_MG_ManufactureCountry;
                product.KDCE_MG_Color__c = tProduct?.KDCE_MG_Color;
                product.KDCE_MG_Weight__c = IF_KDCE_API_BizBase.convertStringToDecimal(tProduct.KDCE_MG_Weight);
                product.KDCE_MG_Material__c = tProduct?.KDCE_MG_Material;
                product.KDCE_MG_Image__c = tProduct?.KDCE_MG_Image;
                product.KDCE_MG_VideoURL__c = tProduct?.KDCE_MG_VideoURL;
                product.KDCE_MG_VideoTitle__c = tProduct?.KDCE_MG_VideoTitle;
                product.KDCE_MG_VideoDescription__c = tProduct?.KDCE_MG_VideoDescription;
                product.KDCE_MG_VideoPreviewImage__c = tProduct?.KDCE_MG_VideoPreviewImage;
                product.KDCE_MG_MasterProductId__c = tProduct?.KDCE_MG_MasterProductId;
                product.KDCE_MG_ModelName_en__c = tProduct?.KDCE_MG_ModelName_en;
                product.KDCE_MG_Content__c = tProduct?.KDCE_MG_Content;
                product.KDCE_MG_Description__c = tProduct?.KDCE_MG_Description;
                product.KDCE_MG_Category__c = tProduct?.KDCE_MG_Category;
                product.KDCE_MG_Unit__c = tProduct?.KDCE_MG_Unit;
                product.KDCE_MG_ModelGroup__c = tProduct?.KDCE_MG_ModelGroup;
                product.KDCE_MG_Type__c = tProduct?.KDCE_MG_Type;
                product.KDCE_MG_Version__c = tProduct?.KDCE_MG_Version;
            }
        }

        if (!products.isEmpty()) update products;

        // 업데이트 결과 매핑
        tProducts = new List<IF_KDCE_API_BizBase.T_Product>();
        for (Product2 product : products) {
            tProduct = new IF_KDCE_API_BizBase.T_Product();
            tProduct.Id = product.Id;
            tProduct.KDCE_EANCode = product.KDCE_EANCode__c;
            tProducts.add(tProduct);
        }
        return tProducts;

    }

//    public static List<KDCE_Coupon__c> checkCoupon(String couponCode, String ContactExtId) {
//        Contact searchContact = [SELECT Id, KDCE_LASLAU__c FROM Contact WHERE KDCE_ExternalId__c = :ContactExtId];
//        KDCE_Coupon__c searchCoupon = [
//                SELECT Id, Name, Amount__c, CouponCode__c, IsAvailable__c, IsSend__c, Contact__c, fm_ContactExtId__c, ru_UseCount__c, Status__c
//                FROM KDCE_Coupon__c WHERE CouponCode__c = :couponCode
//        ];
//        if (searchContact.KDCE_LASLAU__c == 'LAU') searchCoupon.IsAvailable__c = false;
//
//        List<KDCE_Coupon__c> couponList = new List<KDCE_Coupon__c>();
//        couponList.add(searchCoupon);
//
//        return couponList;
//    }

    /**
     * @description Coupon 발급 및 고객정보 없을시, Prospect Contact 정보 생성 IF_MG_DCE_0079
     * @param IF_KDCE_API_BizBase.T_Contact tContact
     * @return IF_MG_DCE_0079 / CouponType에 따른 Coupon 발급로직 (Coupon, CouponHistory, Contact 생성)
     */
    public static IF_KDCE_API_BizBase.T_Coupon setCoupon(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {

        // 들어오는 형태는 List지만, 실제론 단건처리
        System.debug('===================== issue Coupon =====================');

        // Contact Info
//        String registrationChannel  = tContacts[0].RegistrationChannel  ;
        String contactExtId         = tContacts[0].ContactExtId         ;
        String name                 = tContacts[0].Name                 ;
        String storeCode            = tContacts[0].StoreCode            ;
        String mobilePhone          = tContacts[0].MobilePhone          ;
        if (mobilePhone != null) {
            if (mobilePhone.contains('-')) mobilePhone = mobilePhone.remove('-');     // Phone ('-') 하이픈 제거
        }
        // Coupon Detail
        IF_KDCE_API_BizBase.T_Coupon tCoupon    = tContacts[0].t_Coupons[0] ;
        String couponType                       = tCoupon.CouponType        ;
        String ChannelDetails                   = tCoupon.ChannelDetails    ;

        /**validation**/
        // 이미 가입해서 getInfo 쿠폰 발급이 불가능할 경우 (ContactExtId 값이 존재하고, couponType = GetInfo 이면 에러)
//        IF_KDCE_API_BizBase.validate(FALSE,Util.isNotEmpty(contactExtId) && 'GetInfo'.equals(couponType), 'The customer is not eligible for a GetInfo coupon. Customer information exists.');
        if (contactExtId != null && String.isNotEmpty(contactExtId) && couponType == 'GetInfo') {
            tCoupon.IssuanceStatus = 'Error';
            tCoupon.JobResult = '0103';
            return tCoupon;
        }

        // Contact Search
        String conListQuery = '';
        conListQuery += ' SELECT  Id, Phone, KDCE_fm_DCPossibility__c, KDCE_NamePNKey__c, KDCE_PNKey__c, KDCE_DCIssueCount__c, KDCE_fm_ConsumerType__c, KDCE_RegistrationDate__c, CCR_AgeVerificationStatus__c, CCR_AVStatusDateChange__c             ';
        conListQuery += ' FROM    Contact                                                                           ';
        if (contactExtId != null && contactExtId != '') conListQuery += ' WHERE KDCE_ExternalId__c = :contactExtId  ';  // KDCE_ExternalId__c가 동일한 Contact 찾는 것이 우선적임
        else conListQuery += ' WHERE KDCE_PNKey__c = :mobilePhone ';
        List<Contact> conList = Database.query(conListQuery);
        System.debug('=== conList : ' + conList);
        /*
         * 조건에 맞는 Contact 추출
         * 우선순위 1. Member > Prospect
         *        2. 같은 Member일 땐,
         *          2-1. CCR_AgeVerificationStatus__c가 'Verified'인 경우
         *          2.2. CCR_AgeVerificationStatus__c가 같을 땐, CCR_AVStatusDateChange__c 더 최근인 경우
         *        3. 같은 Prospect일 땐,
         *          3-1. KDCE_RegistrationDate__c가 더 먼저인 경우
         */
        Contact contact;
        Decimal deviceCouponCount = 0;
        for(Contact oldCon : conList) {
            deviceCouponCount = deviceCouponCount + Util.nvlDec(oldCon.KDCE_DCIssueCount__c);

            if (oldCon.CCR_AgeVerificationStatus__c == null) oldCon.CCR_AgeVerificationStatus__c = 'Expired'; // CCR_AgeVerificationStatus__c가 null이면 'Expired'라고 가정

            if (contact == null) contact = oldCon;
            else if (contact.KDCE_fm_ConsumerType__c <> oldCon.KDCE_fm_ConsumerType__c && oldCon.KDCE_fm_ConsumerType__c == 'Member') contact = oldCon;
            else if (contact.KDCE_fm_ConsumerType__c == oldCon.KDCE_fm_ConsumerType__c) {
                if (contact.KDCE_fm_ConsumerType__c == 'Member') {
                    if (contact.CCR_AgeVerificationStatus__c <> oldCon.CCR_AgeVerificationStatus__c && oldCon.CCR_AgeVerificationStatus__c == 'Verified') contact = oldCon;
                    else if ((contact.CCR_AgeVerificationStatus__c == oldCon.CCR_AgeVerificationStatus__c || oldCon.CCR_AgeVerificationStatus__c == null) && contact.CCR_AVStatusDateChange__c < oldCon.CCR_AVStatusDateChange__c)  contact = oldCon;
                }
                else if (contact.KDCE_fm_ConsumerType__c == 'Prospect') {
                    if (contact.KDCE_RegistrationDate__c > oldCon.KDCE_RegistrationDate__c) contact = oldCon;
                }
            }
        }
        System.debug('=== conList : ' + conList);

        /**validation**/
        // Contact이 없을 경우, 들어온 phone이 Dormant Contact이 존재하는지 확인
        // IF_KDCE_API_BizBase.validate(FALSE, !dormantList.isEmpty(), 'This Contact is dormant Contact. So it is impossible to issue a coupon.');
        List<KDCE_DormantContact__c> dormantList;
        if (conList.isEmpty()) {
            dormantList = [SELECT Id FROM KDCE_DormantContact__c WHERE KDCE_PNKey__c = :mobilePhone];
            if (!dormantList.isEmpty()) {
                tCoupon.IssuanceStatus = 'Error';
                tCoupon.JobResult = '0102';
                return tCoupon;
            }
        }


        // 발급가능한 쿠폰검색
        // TODO 가능한 쿠폰이 없을 경우 에러나도록 처리 해놓음 나중에 확인 필요. + 발급가능한 쿠폰 발생일자로 DESC 해서 뽑는게 좋을거같음
        Id couponRTId = null;
        if ('CVS'.equalsIgnoreCase(couponType)) couponRTId = RT_Coupon_CVSId;
        else if ('GetInfo'.equalsIgnoreCase(couponType)) couponRTId = RT_Coupon_GetInfo;

        Integer rand = Math.floor(Math.random() * 300).intValue();

        // CVS일 때만 쿠폰 발급. GetInfo는 발급 x
        String couponQuery = '';
        List<KDCE_Coupon__c> availCoupon = new List<KDCE_Coupon__c>();
        if ('CVS'.equalsIgnoreCase(couponType)) {
            couponQuery += ' SELECT  Id, CouponCode__c, ChannelDetails__c, Amount__c, Type__c, RecordTypeId, RecordType.DeveloperName, Status__c, ExpiryDate__c  ';
            couponQuery += ' FROM KDCE_Coupon__c                                                                ';
            couponQuery += ' WHERE Contact__c = NULL                                                            ';
            couponQuery += ' AND ExternalType__c = :couponType                                                  ';
            couponQuery += ' AND RecordTypeId = :couponRTId                                                     ';
            couponQuery += ' AND Status__c = \'Produce\'                                                        ';
            if ('CVS'.equalsIgnoreCase(couponType)){
                couponQuery += ' AND ChannelDetails__c = :ChannelDetails ';
                couponQuery += ' AND IssuableDate__c >= TODAY ';
            }
            couponQuery += ' LIMIT 1';
            String tempQuery = couponQuery;
            couponQuery += ' OFFSET :rand ';

            System.debug('=== couponQuery : ' + couponQuery);
            System.debug('=== tempQuery : ' + tempQuery);
            availCoupon = Database.query(couponQuery);
            System.debug('=== availCoupon : ' + availCoupon);

            if(availCoupon.size() == 0) {
                availCoupon = Database.query(tempQuery);
                System.debug('=== noOffset : ' + availCoupon);
            }
        }

        // Store Search
        Id storeId = null;
        List<KDCE_Store__c> store = [SELECT Id FROM KDCE_Store__c WHERE CampaignCode__c = :storeCode LIMIT 1];
        if (storeCode != null && storeCode != '' && store.size() > 0) storeId = store[0].Id;

        /** Validation */
        /*
         * Issue Validation 발급불가능한 경우
         * 발급 가능 쿠폰이 없을 경우
         * GetInfo: 일치하는 Contact 존재
         * CVS : EasyIQOS 발급이력조회 횟수가 2번이상
         */

        // 발급가능한 쿠폰이 없을 경우
        if (availCoupon.isEmpty() && 'CVS'.equalsIgnoreCase(couponType)) {
//            IF_KDCE_API_BizBase.validate(FALSE, availCoupon.isEmpty(), 'A coupon that can be issued does not exist. Please contact your administrator.'); // 발급가능한 쿠폰이 0개면 처리 x
            tCoupon.IssuanceStatus = 'Error';
            tCoupon.JobResult = '0104';
            return tCoupon;
        }

        // GetInfo 발급시, 일치하는 Contact이 있을 경우
        if (!conList.isEmpty() && 'GetInfo'.equalsIgnoreCase(couponType)) {
            tCoupon.IssuanceStatus = 'Error';
            tCoupon.JobResult = '0103';
            return tCoupon;
        }

        // 이미 쿠폰 발급이 가능한 모든 횟수를 모두 소진함
        //        IF_KDCE_API_BizBase.validate(FALSE,conList.size() > 0 && 'CVS'.equals(couponType) && !conList[0].KDCE_fm_DCPossibility__c, 'The customer is not eligible for a coupon. The coupon has already been issued twice.');
//        if (conList.size() > 0 && couponType == 'CVS' && !conList[0].KDCE_fm_DCPossibility__c) {
//            tCoupon.IssuanceStatus   = 'Error';
//            tCoupon.JobResult = '0101';
//            return tCoupon;
//        }
        if ('CVS'.equalsIgnoreCase(couponType) && (deviceCouponCount > 2 || deviceCouponCount == 2)) {
            tCoupon.IssuanceStatus   = 'Error';
            tCoupon.JobResult = '0101';
            return tCoupon;
        }

        IF_KDCE_API_BizBase.T_Coupon coupon = null;     // OutPut Data
        Contact targetCon = null;                       // 쿠폰 발급된 대상 (TnC History 생성을 위함)
        /* 고객 생성 및 업데이트 */
        if (conList.isEmpty()) { // 신규 Prospect 고객 생성 : 일치하는 Contact이 존재하지 않을때
            // 고객 등록
            targetCon                               = new Contact()         ;
            targetCon.LastName                      = name                  ;
            targetCon.Phone                         = mobilePhone           ;
            targetCon.RecordTypeId                  = RT_Contact_ProspectId ;
            targetCon.KDCE_RegistrationDate__c      = System.now()          ;
            targetCon.KDCE_RegistrationObject__c    = 'Interface'           ;
            targetCon.CCR_SmokerNew__c              = 'Yes'                 ;
            targetCon.CCR_SmokerDeclarationDate__c  = System.now()          ;

            if (storeId != null) targetCon.KDCE_Store__c = storeId;
            if ('CVS'.equalsIgnoreCase(couponType))targetCon.KDCE_RegistrationChannel__c = 'EasyIqos';
            else if ('GetInfo'.equalsIgnoreCase(couponType)) targetCon.KDCE_RegistrationChannel__c = 'GetInfo'; // TODO 어떻게?
            //targetCon.KDCE_RegistrationChannel__c   = 'EasyIqos'            ;
            //KDCE_RegistrationChannel__c = targetCon.RegistrationChannel,
            insert targetCon;
        } else { // Coupon Type = CVS, 일치하는 Contact 존재, KDCE_fm_DCPossibility__c = true
            // Contact 연결
            targetCon = contact;
            if (storeId != null) targetCon.KDCE_Store__c = storeId;
            update targetCon;
        }

        /* CVS 쿠폰 발급  */
        if ('CVS'.equalsIgnoreCase(couponType)) {
            availCoupon[0].Contact__c       = targetCon.Id ;
            availCoupon[0].Status__c        = 'Issue'   ;
            availCoupon[0].IssueChannel__c  = 'Online'  ;
            availCoupon[0].IssueDate__c     = System.now();
        }
        // if (couponType == 'GetInfo') availCoupon[0].ExpiryDate__c = System.today().addMonths(3);

        //update availCoupon;

        // 업데이트할 Contact SOQL
        Contact updateContact = [
                SELECT  Id, KDCE_InformationOptIn__c, KDCE_MarketingOptIn__c, KDCE_TnCVersion__c, RecordTypeId, KDCE_ExternalId__c, KDCE_MarketingOptInDate__c
                FROM    Contact
                WHERE   Id = :targetCon.Id
        ];

        // Output Data 생성
        tCoupon.IssuanceStatus   = 'Success'                         ;
        tCoupon.JobResult        = '0000';
        tCoupon.IssueChannel     = 'Online'                          ;

        if ('CVS'.equalsIgnoreCase(couponType)) {
            tCoupon.CouponCode       = availCoupon[0].CouponCode__c      ;
            //tCoupon.Channel          = availCoupon[0].Channel__c         ;
            tCoupon.ChannelDetails   = availCoupon[0].ChannelDetails__c  ;
            tCoupon.Amount           = availCoupon[0].Amount__c          ;
            tCoupon.CouponType       = couponType                        ;
        }
        // 신규 컨택이 생성되는 케이스에 널포인트 에러나서 컨택 쿼리 후 값 넣어주도록 로직 수정. 2021.05.04
        tCoupon.ContactExtId     = updateContact.KDCE_ExternalId__c      ;
//        tCoupon.ExpiryDate       = String.valueOf(availCoupon[0].ExpiryDate__c);      // TODO Expiry Date 안넣어주나

        /* TnC History Create */
        // TnC Version Info Map
        // 들어오는 History Data KDCE_TnCVersionSetId에 일치하는 데이터는 안뽑나??? 왜 다 가져오지 > Active 값이 몇개 없어서 by shlee
        Map<String, KDCE_TnCVersionSet__c> tncVersionSetMap = new Map<String, KDCE_TnCVersionSet__c>([
                SELECT  Id, TnCVersion__c, TaC__c, Channel__c, MarketingOptin__c, InfomationOptin__c, TaC__r.fm_TnCId__c
                FROM    KDCE_TnCVersionSet__c
                WHERE   TnCVersion__r.IsActive__c = TRUE
        ]);

        // 이미 해당 고객이 동의 한 내역
        Map<String, KDCE_TnCAccepted__c> contactAcceptedMap = new Map<String, KDCE_TnCAccepted__c>();

        for(KDCE_TnCAccepted__c row : [
                SELECT Id, Accepted__c, TnC__r.fm_TnCId__c, ExternalId__c
                FROM KDCE_TnCAccepted__c
                WHERE Contact__c = :targetCon.Id
        ]){
            contactAcceptedMap.put(row.TnC__r.fm_TnCId__c, row);
        }

        // Terms and Conditions History Create
        KDCE_TnCVersionSet__c   tnCVersionSet   = null;
        KDCE_TnCHistory__c      tncHistory      = null;
        KDCE_TnCAccepted__c     tnCAccepted     = null;
        Boolean                 Accepted        = false;

        Set<String> contactIds                          = new Set<String>();
        List<KDCE_TnCAccepted__c> tnCAccepteds          = new List<KDCE_TnCAccepted__c>();
        Map<String, KDCE_TnCHistory__c> tncHistoryMap   = new Map<String, KDCE_TnCHistory__c>();
        Map<Id, Contact> contactMap                     = new Map<Id, Contact>();


        //T&C 존재하면 초기화
        if(tncVersionSetMap.size() > 0) {
            updateContact.KDCE_InformationOptIn__c = true;
            updateContact.KDCE_MarketingOptIn__c   = true;
        }

        for (IF_KDCE_API_BizBase.T_TnCHistory tTnCHistory : tContacts[0].t_TnCHistories) {

            if (tncVersionSetMap.size() > 0 && tncVersionSetMap.containsKey(tTnCHistory.KDCE_TnCVersionSetId)) {

                tnCVersionSet   = tncVersionSetMap.get(tTnCHistory.KDCE_TnCVersionSetId);
                Accepted        = IF_KDCE_API_BizBase.getValidBoolean(tTncHistory.KDCE_Accepted);

                tncHistory                          = new KDCE_TnCHistory__c();
                tncHistory.DTE_Contact__c           = updateContact.Id;
                tncHistory.KDCE_TnCVersionSet__c    = tnCVersionSet.Id;
                tncHistory.KDCE_TnC__c              = tnCVersionSet.TaC__c;
                tncHistory.KDCE_Channel__c          = tnCVersionSet.Channel__c;
                tnCHistory.CCR_Acceptance_Date__c   = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tTncHistory.CCR_Acceptance_Date);
                tncHistory.KDCE_Accepted__c         = Accepted;

                // TnC 동의에 따른 Contact Information / Marketing Opt In 변경
                if (Accepted == false) {
                    if(tnCVersionSet.InfomationOptin__c == TRUE) {
                        updateContact.KDCE_InformationOptIn__c = false;
                        tnCHistory.KDCE_Description__c = LAB_TNC_HISTORY_DESC_DECLINE_INFORMATION;
                    }
                    if(tnCVersionSet.MarketingOptin__c == TRUE) {
                        updateContact.KDCE_MarketingOptIn__c = false;
                        if(Util.isNotEmpty(tnCHistory.KDCE_Description__c)) tnCHistory.KDCE_Description__c = LAB_TNC_HISTORY_DESC_DECLINE_MARKETINGANDINFORMATION;
                        else tnCHistory.KDCE_Description__c = LAB_TNC_HISTORY_DESC_DECLINE_MARKETING;
                    }
                }

                tncHistoryMap.put(updateContact.KDCE_ExternalId__c + tTncHistory.KDCE_TnCVersionSetId, tncHistory);
                System.debug('=== tncHistoryMap : ' + tncHistoryMap);

                // Set TnC Accepted: Contact이 멤버(iqos.com)일 경우만 관리 > 무시
//                if (RT_Contact_MemberId.equals(updateContact.RecordTypeId)) {
//                    tnCAccepted = new KDCE_TnCAccepted__c();
//                    //KDCE_TnCAccepted__c ExternalId : ContactId + TaCId (T&C Master)
//                    tnCAccepted.ExternalId__c       = updateContact.Id +''+ tnCVersionSet.Id;
//                    tnCAccepted.Contact__c          = updateContact.Id;
//                    tnCAccepted.TnCVersionSet__c    = tTncHistory.KDCE_TnCVersionSetId;
//                    tnCAccepted.TnC__c              = tnCVersionSet.TaC__c;
//                    tnCAccepted.Accepted__c         = Accepted;
//                    tnCAccepteds.add(tnCAccepted);
//                } else
                //Set TnC Accepted: Contact이 Prospect일 경우만 관리
                if(RT_Contact_ProspectId.equals(updateContact.RecordTypeId)) {
                    tnCAccepted = new KDCE_TnCAccepted__c();
                    //KDCE_TnCAccepted__c ExternalId : ContactId + TaCId (T&C Master)
                    tnCAccepted.ExternalId__c       = updateContact.Id +''+ tnCVersionSet.Id;
                    tnCAccepted.Contact__c          = updateContact.Id;
                    tnCAccepted.TnCVersionSet__c    = tTncHistory.KDCE_TnCVersionSetId;
                    tnCAccepted.TnC__c              = tnCVersionSet.TaC__c;
                    tnCAccepted.Accepted__c         = Accepted;
                    tnCAccepteds.add(tnCAccepted);
                }

                else if(RT_Contact_MemberId.equals(updateContact.RecordTypeId)) {

                    if(contactAcceptedMap.containsKey(tnCVersionSet.TaC__r.fm_TnCId__c)){
                        tnCAccepted = contactAcceptedMap.get(tnCVersionSet.TaC__r.fm_TnCId__c);
                        tnCAccepted.Accepted__c = true;
                        tnCAccepteds.add(tnCAccepted);
                    }

                }

                //고객의 T&C Version 정보가 다르면, Contact T&C Version Id 정보 업데이트, 기존 T&C Accepted 정보 삭제.
//                    if(!tnCVersionSet.TnCVersion__c.equals(updateContact.KDCE_TnCVersion__c)) {
//                        updateContact.KDCE_TnCVersion__c = tnCVersionSet.TnCVersion__c;
//                    }
                //전체 삭제할 Contact Id
//                    contactIds.add(updateContact.Id);
                //변경 업데이트할 Contact Id
                contactMap.put(updateContact.Id, updateContact);
            }
        }
        // Contact 최신 동의한 T&C Version(Id) 정보 업데이트
        if(contactMap.values().size() > 0) update contactMap.values();
        //이전 T&C Version의 T&C Accepted 정보 삭제.
//            delete [SELECT Id FROM KDCE_TnCAccepted__c WHERE Contact__c IN :contactIds];

        if(tncHistoryMap.values().size() > 0) insert tncHistoryMap.values(); //T&C History 생성
        //T&C Accepted upsert
        if(tnCAccepteds.size() > 0) {
            //KDCE_TnCAccepted_tr bypass 처리 : TnC History 생성 및 COntact Opt-in 제어 처리 bypass
            TriggerHandler.bypass('KDCE_TnCAccepted_tr');
            upsert tnCAccepteds ExternalId__c;
            TriggerHandler.clearBypass('KDCE_TnCAccepted_tr');
        }

        if ('CVS'.equalsIgnoreCase(couponType)) update availCoupon;
        /*
        GetInfo 인 경우에만 LMS 나갈수 있도록 수정.
        Contact = targetCon
        */
        if('GetInfo'.equalsIgnoreCase(couponType)) {
            Contact getInfoContact = [SELECT Id, KDCE_MarketingOptInDate__c, KDCE_ExternalId__c FROM Contact WHERE Id =:targetCon.Id];
            List<i2SEMA_Util.Receiver> getInfoReceivers = new List<i2SEMA_Util.Receiver>();
            List<String> labels = new List<String>();
            i2SEMA_Util.Receiver receiver = new i2SEMA_Util.Receiver();

            System.debug(' getInfoContact : ' + getInfoContact);
            labels.add(String.valueOf(getInfoContact?.KDCE_MarketingOptInDate__c));

            receiver.receiverExtId = getInfoContact.KDCE_ExternalId__c;
            receiver.labels = labels;
            getInfoReceivers.add(receiver);

            i2SEMA_Util.I2Notification msg = new i2SEMA_Util.I2Notification();
            msg.templateExtId = System.Label.KDCE_NotificationTemplate_Coupon_GetInfo; //'NT-210504-00070';
            msg.receiverType = 'Contact';
            msg.receivers = getInfoReceivers;
            if( !Test.isRunningTest() ) i2SEMA_Util.sendNotification(msg);

        }

//        IF_KDCE_API_BizBase.T_Contact tContact = tContacts.get(0);
//        tContact.ContactExtId = updateContact.KDCE_ExternalId__c;
//        tContact.t_Coupons = new List<IF_KDCE_API_BizBase.T_Coupon>();
//        tContact.t_Coupons.add(tCoupon);

        return tCoupon;
    }

    /**
     * @description Magento Contact 조회 IF_MG_DCE_0097
     * @param IF_KDCE_API_BizBase.T_Contact tContact (Name + Phone Combination OR external ID)
     * @return : 반환값에 Retrieve된 Contact List
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> getContactsByMagento(IF_KDCE_API_BizBase.T_Contact tContact) {
        List<IF_KDCE_API_BizBase.T_Contact> tContacts = null;

        String searchPhone = null;
        String contactExtId = null;
        String searchName = null;
        String loginType = null;
        List<String> assetStatusCriteria = new List<String>{    // , 'Locked'
                'Active'
        };
        Map<String, List<KDCE_OrderLineItem__c>> orderMap = new Map<String, List<KDCE_OrderLineItem__c>>();
        Set<String> orderMapKeySet;
        if (Util.isNotEmpty(tContact.ContactExtId)) {
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.ContactExtId), LAB_IF_ERR_CONTACT_EXTERNALID_REQUIRED);
            contactExtId = tContact.ContactExtId;
        } else {
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.Name), LAB_IF_ERR_CONTACT_NAME_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.MobilePhone), LAB_IF_ERR_CONTACT_MOBILEPHONE_REQUIRED);
            searchName = tContact.Name;
            searchPhone = tContact.MobilePhone;
        }

        // Login History 를 쌓기 위한 Login Type 설정. 빈값인 경우는 'N(Search)' = 단순검색으로 처리
        if(tContact.LoginType == NULL || tContact.LoginType == '') loginType = 'N';
        else loginType = tContact.LoginType;

//        System.debug('tContact.ContactExtId: ' + tContact.ContactExtId);
//        System.debug('tContact.Name: ' + tContact.Name);
//        System.debug('tContact.Mobile4Digit: ' + tContact.Mobile4Digit);
//        System.debug('searchPhone: ' + searchPhone);

        List<String> queryList = new List<String>();
        queryList.add('SELECT');
        // Contact
        queryList.add('Id,');
        queryList.add('KDCE_ExternalId__c,');
        queryList.add('CCR_ConsumerUID__c,');
        queryList.add('KDCE_NamePNKey__c,');
        queryList.add('Salutation,');
        queryList.add('KDCE_Name__c,');
        queryList.add('LastName,');
        queryList.add('CCR_Gender__c,');
        queryList.add('BirthDate,');
        queryList.add('KDCE_MobileCarrier__c,');
        queryList.add('Phone,');
        queryList.add('KDCE_PNKey__c,');
//        queryList.add('KDCE_PhoneMask__c,');
        queryList.add('Email,');
        //queryList.add('KDCE_EmailMask__c,');
        queryList.add('MailingState,');
        queryList.add('MailingCity,');
//        queryList.add('MailingStreet,');
        queryList.add('MailingPostalCode,');
        queryList.add('KDCE_FirstAddressPostal__c,');
        queryList.add('KDCE_FirstAddressLv1__c,');
        queryList.add('KDCE_FirstAddressLv2__c,');
//        queryList.add('MailingCountry,');
        queryList.add('KDCE_RegistrationChannel__c,');
        queryList.add('KDCE_HasRegistedUsingKakaoId__c,');
        queryList.add('KDCE_JoinedPMKChannel__c,');
        queryList.add('KDCE_KakaoId__c,');
        queryList.add('CCR_DatabaseOptIn__c,');
        queryList.add('KDCE_InformationOptIn__c,');
        queryList.add('KDCE_MarketingOptIn__c,');
        queryList.add('CCR_CarePlusStatus__c,');
        queryList.add('CCR_CarePlusDueDate__c,');
        queryList.add('CCR_QoachProgram__c,');
        queryList.add('KDCE_fm_ConsumerType__c,');
        queryList.add('KDCE_LASLAU__c,');
//        queryList.add('CAA_SubType__c,');
//        queryList.add('CAA_Stage__c,');
        queryList.add('CCR_SmokerNew__c,');
        queryList.add('CCR_SmokerDeclarationDate__c,');
        queryList.add('CCR_GlobalAgeVerification__c,');
        queryList.add('CCR_AgeVerificationStatus__c,');
        queryList.add('CCR_AVStatusDateChange__c,');
        queryList.add('KDCE_HardAgeVerifiedDate__c,');
        queryList.add('KDCE_IsDormant__c,');
        queryList.add('KDCE_fm_IsAgeReVerification__c,');
        queryList.add('CCR_SoftAgeVerifiedNew__c,');
        queryList.add('CCR_SoftAgeVerifiedDate__c,');
        queryList.add('KDCE_MGMCode__c,');
        queryList.add('KDCE_MGMUseCount__c,');
        queryList.add('KDCE_fm_IsDormantMailSend__c,');
//        queryList.add('KDCE_fm_IsTargetDormant__c,');
        queryList.add('KDCE_ConvertDormantDate__c,');
        queryList.add('KDCE_fm_AvailDropout__c,');
        queryList.add('KDCE_DropoutRequestDate__c,');
        queryList.add('KDCE_IsRequestDropout__c,');
        queryList.add('KDCE_DropoutDate__c,');
        queryList.add('KDCE_IsDropout__c,');
        queryList.add('CCR_BlockedContact__c,');
        queryList.add('CCR_BockingReason__c,');
        queryList.add('CreatedDate,');
        queryList.add('LastModifiedDate,');
        queryList.add('KDCE_PersonalInfoValidityPeriod__c,');
        queryList.add('KDCE_QUREAccessToken__c,');
        queryList.add('KDCE_TokenExpireTime__c,');
        queryList.add('KDCE_ECLoginEmail__c,');

        // ContactHistory
        //queryList.add('(SELECT Id, Name, Contact__c, HistoryType__c, ActionDate__c, ActionType__c, Log__c, CreatedDate, LastModifiedDate FROM ContactHistories__r ORDER BY LastModifiedDate),');
        // Order
        queryList.add('(SELECT');
        queryList.add('Id,');
        queryList.add('OrderNo__c,');
        queryList.add('OriginOrderNo__c,');
        queryList.add('OrderReason__c,');
        queryList.add('EntityId__c,');
        queryList.add('Name,');
        queryList.add('ActionChannel__c,');
        queryList.add('ActionType__c,');
        queryList.add('OrderDate__c,');
        queryList.add('OrderType__c,');
        queryList.add('Currency__c,');
//        queryList.add('CustomerLocale__c');
//        queryList.add('PreferredLocale__c,');
        queryList.add('Contact__r.KDCE_ExternalId__c,');
        queryList.add('CustomerName__c,');
        queryList.add('CustomerEmail__c,');
        queryList.add('OrderStatus__c,');
        queryList.add('NetPrice__c,');
        queryList.add('PaymentAmount__c,');
        queryList.add('PaymentMethod__c,');
        queryList.add('ShippingStreet__c,');
        queryList.add('ShippingCity__c,');
        queryList.add('ShippingState__c,');
        queryList.add('ShippingCountryCode__c,');
        queryList.add('ShippingMethod__c,');
        queryList.add('ShippingPostalCode__c,');
//        queryList.add('shipping_status__c,');
//        queryList.add('Channel__c,');
        queryList.add('CreatedDate,');
        queryList.add('LastModifiedDate');
        queryList.add('FROM Orders__r');
        queryList.add('WHERE ActionChannel__c = \'iqos.com\'');
        queryList.add('ORDER BY LastModifiedDate),');
        // Asset
        queryList.add('(SELECT Id, Name, PurchaseDate, CCR_CarePlusDueDate__c, CCR_CarePlusStatus__c, KDCE_ShipmentDate__c, CCR_ReplacementDate__c, ContactId, CCR_CodentifyId__c, SerialNumber, Status, KDCE_DeviceLabelling__c, Product2.Name, CCR_DeviceProductCode__r.Name, CCR_ParentProductionDateTime__c, CCR_ProductionDateTime__c, KDCE_fm_WarrantyDate__c, CCR_MaterialGroupDescription__c, KDCE_fm_ProductEAN__c, CCR_Version__c, CreatedDate, LastModifiedDate FROM Assets WHERE Status IN :assetStatusCriteria ORDER BY LastModifiedDate),');
        // AssetLifeCycle
        queryList.add('(SELECT Id, Name, CCR_Consumer__c, CCR_Asset__c, CCR_Asset__r.CCR_CodentifyId__c, CCR_Action__c, CCR_ActionDate__c, KDCE_DeviceType__c, CreatedDate, LastModifiedDate  FROM AssetLifeCycles__r ORDER BY LastModifiedDate),');
        // AssetHistory
        //queryList.add('(SELECT Id,Name,Asset__c,Asset__r.CCR_CodentifyId__c,ActionDate__c,ActionType__c,OrderLineItem__c,OrderLineItem__r.Order__r.Name,CreatedDate,LastModifiedDate FROM AssetHistories__r ORDER BY LastModifiedDate),');
        // Coupon
        queryList.add('(SELECT Id, Name, Contact__c, CouponCode__c, Status__c, IssueDate__c, UsedDate__c, Type__c, CreatedDate, LastModifiedDate FROM Coupons__r ORDER BY LastModifiedDate),');
        // CouponHistory
        queryList.add('(SELECT Id, Name, Contact__c, Coupon__c, ActionType__c, ActionDate__c, ActionChannel__c, Gifticon__c, CreatedDate, LastModifiedDate  FROM CouponHistories__r ORDER BY LastModifiedDate),');
        // TnCAccepted
        queryList.add('(SELECT Id, Name, fm_TnC__c, ExternalId__c, Contact__c, TnCVersionSet__c, Accepted__c, TnCVersionSet__r.TaC__r.KDCE_SubGroup__c, CreatedDate, LastModifiedDate  FROM TnCAccepted__r ORDER BY LastModifiedDate)'); // TODO 수정시 - 아래 추가될 시 해당 행에 콤마 붙여주시고, 마지막행은 콤마 빼주셔야 합니다.
        // TnCHistory
        //queryList.add('(SELECT Id, Name, DTE_Contact__c, KDCE_TnCVersionSet__c, KDCE_Accepted__c, CCR_Acceptance_Channel__c, CreatedDate, LastModifiedDate  FROM TnCHistories__r ORDER BY LastModifiedDate),');
        queryList.add('FROM Contact');
        //Where
        if (Util.isNotEmpty(tContact.ContactExtId)) {
            queryList.add('WHERE KDCE_ExternalId__c = :contactExtId');
        } else {
            queryList.add('WHERE KDCE_Name__c = :searchName AND KDCE_PNKey__c = :searchPhone');
        }
        // Member 타입의 고객만 가져갈 수 있도록 추가. 2021.05.04 권준석
        queryList.add('AND RecordTypeId = :RT_Contact_MemberId');
        queryList.add('ORDER BY KDCE_Name__c');

        System.debug(queryList);
        List<Contact> contacts = database.query(String.join(queryList, '\n'));
        // IF_KDCE_API_BizBase.validate(false, contacts.isEmpty(), 'Search Result does not exist.');

        //Mapping
        tContacts = new List<IF_KDCE_API_BizBase.T_Contact>();
        IF_KDCE_API_BizBase.T_Contact tCon;
        IF_KDCE_API_BizBase.T_ContactHistory tContactHistory;
        IF_KDCE_API_BizBase.T_Order tOrder;
        IF_KDCE_API_BizBase.T_OrderLineItem tOrderLineItem;
        IF_KDCE_API_BizBase.T_Asset tAsset;
        IF_KDCE_API_BizBase.T_AssetLifecycle tAssetLifecycle;
        IF_KDCE_API_BizBase.T_AssetHistory tAssetHistory;
        IF_KDCE_API_BizBase.T_Coupon tCoupon;
        IF_KDCE_API_BizBase.T_CouponHistory tCouponHistory;
        IF_KDCE_API_BizBase.T_TnCAccepted tTnCAccepted;
//        IF_KDCE_API_BizBase.T_TnCHistory tTncHistory;
        IF_KDCE_API_BizBase.T_DormantContact tDormantContact;

        // TODO 휴면 고객에 대한 처리 필요
        // 검색 된 연락처가 없는 경우에 휴면 처리 되어있는 고객이 있는지 확인하는 로직 추가
        if(contacts.size() == 0){

            List<KDCE_DormantContact__c> dcList = [
                    SELECT Id, KDCE_ExternalId__c, KDCE_IsDormant__c, KDCE_Name__c, KDCE_PNKey__c, Birthdate__c
                    FROM KDCE_DormantContact__c
                    WHERE KDCE_Name__c = :searchName AND KDCE_PNKey__c = :searchPhone
                    LIMIT 1
            ];

            if(dcList.size() == 1) {
                tCon = new IF_KDCE_API_BizBase.T_Contact();
                tCon.ContactExtId = dcList[0].KDCE_ExternalId__c;
                //tCon.IsDormant    = String.valueOf(dcList[0].KDCE_IsDormant__c);
                // Dormant Contact 개체에 값이 있다는 것은 휴면 이라는 의미임
                tCon.IsDormant    = 'true';
                tCon.Name         = dcList[0].KDCE_Name__c;
                tCon.MobilePhone  = dcList[0].KDCE_PNKey__c;
                tCon.Birthdate    = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(dcList[0].Birthdate__c);
                tContacts.add(tCon);
            }
            
        }

        Set<String> contactIds = new Set<String>();
        for (Contact contact : contacts) {
            for (KDCE_Order__c order : contact.Orders__r) {
                orderMap.put(order.OrderNo__c, null);
            }
            contactIds.add(contact.Id);
        }

        // 탈퇴 가능여부에 해당하는 것 체크 (Case, Order, Offline Program이 있으면 해당x)
        Map<String, Boolean> notAvailDropoutContactMap = new Map<String, Boolean>();

        /*
         * Case Check
         */
        List<Case> openCaseList = [
                SELECT Id, Contact.KDCE_ExternalId__c
                FROM Case
                WHERE Status != 'Closed'
                AND Contact.Id IN :contactIds
        ];
        for(Case c : openCaseList){
            notAvailDropoutContactMap.put(c.Contact.Id, TRUE);
        }

        /*
         * Order Check
         */
        // TODO 여기 Status가 'Complete'인것도 추가해야하나?? - 권책임님 확인필요
        Set<String> invalidOrderStatus = new Set<String>{
                KDCE_GlobalValue.ORDER_STATUS_COMPLETE_DELIVERY, KDCE_GlobalValue.ORDER_STATUS_PROCESSED_CLOSED,
                KDCE_GlobalValue.ORDER_STATUS_CLOSE
        };
        List<KDCE_Order__c> openOrderList = [
                SELECT Id, Contact__r.KDCE_ExternalId__c
                FROM KDCE_Order__c
                WHERE OrderStatus__c NOT IN :invalidOrderStatus
                AND Contact__r.Id IN :contactIds
        ];
        for (KDCE_Order__c order : openOrderList) {
            notAvailDropoutContactMap.put(order.Contact__r.Id, TRUE);
        }

        /*
         * Rental Check
         */
        List<KDCE_OfflineProgram__c> rentalCheckList = [
                SELECT Id, Contact__r.KDCE_ExternalId__c
                FROM KDCE_OfflineProgram__c
                WHERE Status__c = :KDCE_GlobalValue.OFF_PG_STATUS_RTNPROCESS
                AND Contact__r.Id IN :contactIds
        ];
        for (KDCE_OfflineProgram__c program : rentalCheckList) {
            notAvailDropoutContactMap.put(program.Contact__r.Id, TRUE);
        }

        orderMapKeySet = orderMap.keySet();
        List<String> queryListOrderItem = new List<String>();
        queryListOrderItem.add('SELECT');
        // Order Line Item
        queryListOrderItem.add('Id,');
//        queryListOrderItem.add('Name,');
        queryListOrderItem.add('Order__r.OrderNo__c,');
        queryListOrderItem.add('EntityId__c,');
        queryListOrderItem.add('Codentify__c,');
        queryListOrderItem.add('Product__r.KDCE_EANCode__c');
        queryListOrderItem.add('FROM KDCE_OrderLineItem__c');
        queryListOrderItem.add('WHERE Order__r.OrderNo__c IN :orderMapKeySet');

        List<KDCE_OrderLineItem__c> orderLineItems = database.query(String.join(queryListOrderItem, '\n'));
        List<KDCE_OrderLineItem__c> orderLineItemsForOrder;
        if (orderLineItems.size() > 0) {
            for (String orderKey : orderMap.keySet()) {
                orderLineItemsForOrder = new List<KDCE_OrderLineItem__c>();
                for (KDCE_OrderLineItem__c oli : orderLineItems) {
                    if (oli.Order__r.OrderNo__c == orderKey) orderLineItemsForOrder.add(oli);
                }
                orderMap.put(orderKey, orderLineItemsForOrder);
            }
        }

        // Login History
        List<KDCE_ConsumerLoginHistory__c> clhList = new List<KDCE_ConsumerLoginHistory__c>();
        KDCE_ConsumerLoginHistory__c clh = null;

        for (Contact contact : contacts) {
            tCon = new IF_KDCE_API_BizBase.T_Contact();
            tCon.Id                         = contact.Id;
            tCon.ContactExtId               = contact.KDCE_ExternalId__c;
            tCon.Name                       = contact.KDCE_Name__c;
            tCon.ConsumerUID                = contact.CCR_ConsumerUID__c;
            tCon.NamePNKey                  = contact.KDCE_NamePNKey__c;
            tCon.Salutation                 = contact.Salutation;
            tCon.LastName                   = contact.LastName;
            tCon.Mobile4Digit               = null;
            tCon.Gender                     = contact.CCR_Gender__c;
            tCon.Birthdate                  = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.Birthdate);
            tCon.MobileCarrier              = contact.KDCE_MobileCarrier__c;
            tCon.MobilePhone                = contact.KDCE_PNKey__c;//
//            tCon.MobilePhoneMask            = contact.KDCE_PhoneMask__c;
            tCon.Email                      = contact.Email;
            //tCon.EmailMask                  = contact.KDCE_EmailMask__c;
            tCon.State                      = contact.MailingState;
            tCon.City                       = contact.MailingCity;
//            tCon.Street              = contact.MailingStreet;
            tCon.PostalCode                 = contact.KDCE_FirstAddressPostal__c;
            tCon.Address1                   = contact.KDCE_FirstAddressLv1__c;
            tCon.Address2                   = contact.KDCE_FirstAddressLv2__c;
//            tCon.MailingCountry             = contact.MailingCountry;
            tCon.RegistrationChannel        = contact.KDCE_RegistrationChannel__c;
//            tCon.RegistrationDate           = IF_KDCE_API_BizBase.convertDateAndDateToString(contact.KDCE_RegistrationDate__c);
            //Kakao
            tCon.HasRegistedUsingKakaoId    = String.valueOf(contact.KDCE_HasRegistedUsingKakaoId__c);
            tCon.JoinedPMKChannel           = String.valueOf(contact.KDCE_JoinedPMKChannel__c);
            tCon.KakaoId                    = contact.KDCE_KakaoId__c;
            tCon.DatabaseOptin              = String.valueOf(contact.CCR_DatabaseOptin__c);
            tCon.InformationOptIn           = String.valueOf(contact.KDCE_InformationOptIn__c);
            tCon.MarketingOptIn             = String.valueOf(contact.KDCE_MarketingOptIn__c);
            tCon.CarePlusStatus             = contact.CCR_CarePlusStatus__c;
            tCon.CarePlusDueDate            = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.CCR_CarePlusDueDate__c);
            tCon.QoachProgram               = String.valueOf(contact.CCR_QoachProgram__c);
            tCon.ConsumerType               = contact.KDCE_fm_ConsumerType__c;
            tCon.LASLAU                     = contact.KDCE_LASLAU__c;
//            tCon.Subtype                    = contact.CAA_SubType__c;
//            tCon.Stage                      = contact.CAA_Stage__c;
            tCon.Smoker                     = contact.CCR_SmokerNew__c;
            tCon.SmokerDeclarationDate      = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.CCR_SmokerDeclarationDate__c);
            tCon.HardAgeVerification        = String.valueOf(contact.CCR_GlobalAgeVerification__c);
            tCon.HardAgeVerificationStatus  = contact.CCR_AgeVerificationStatus__c;
            tCon.HardAVStatusDateChange     = String.valueOf(contact.CCR_AVStatusDateChange__c);
            tCon.HardAgeVerifiedDate        = String.valueOf(contact.KDCE_HardAgeVerifiedDate__c);
            tCon.IsHardAgeReVerification    = String.valueOf(contact.KDCE_fm_IsAgeReVerification__c);
            tCon.SoftAgeVerified            = contact.CCR_SoftAgeVerifiedNew__c;
            tCon.SoftAgeVerifiedDate        = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.CCR_SoftAgeVerifiedDate__c);
            tCon.MGMCode                    = contact.KDCE_MGMCode__c;
            tCon.IsDormantMailSend          = String.valueOf(contact.KDCE_fm_IsDormantMailSend__c);
            tCon.IsDormant                  = String.valueOf(contact.KDCE_IsDormant__c);
            tCon.ConvertDormantDate         = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.KDCE_ConvertDormantDate__c);
            tCon.AvailDropout               = notAvailDropoutContactMap.containsKey(contact.Id) ? 'false' : 'true';
            tCon.DropOutRequestDate         = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.KDCE_DropoutRequestDate__c);
            tCon.DropOutRequest             = String.valueOf(contact.KDCE_IsRequestDropout__c);
            tCon.DropOutDate                = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.KDCE_DropoutDate__c);
            tCon.DropOutContact             = String.valueOf(contact.KDCE_IsDropout__c);
            tCon.BlockedContact             = String.valueOf(contact.CCR_BlockedContact__c);
            tCon.BockingReason              = contact.CCR_BockingReason__c;
            tCon.CreatedDate                = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.CreatedDate);
            tCon.LastModifiedDate           = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.LastModifiedDate);
            tCon.PersonalInfoValidityPeriod = contact.KDCE_PersonalInfoValidityPeriod__c;
            tCon.MGMUseCount                = String.valueOf(contact.KDCE_MGMUseCount__c);
            tCon.QUREAccessToken            = contact.KDCE_QUREAccessToken__c;
            tCon.QUREAccessTokenExpireTime  = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contact.KDCE_TokenExpireTime__c);
            tCon.ECLoginEmail               = contact.KDCE_ECLoginEmail__c;

            //Child List
            tCon.t_ContactHistories         = new List<IF_KDCE_API_BizBase.T_ContactHistory>();
            tCon.t_Orders                   = new List<IF_KDCE_API_BizBase.T_Order>();
            tCon.t_Assets                   = new List<IF_KDCE_API_BizBase.T_Asset>();
            tCon.t_AssetLifecycles          = new List<IF_KDCE_API_BizBase.T_AssetLifecycle>();
            tCon.t_AssetHistories           = new List<IF_KDCE_API_BizBase.T_AssetHistory>();
            tCon.t_Coupons                  = new List<IF_KDCE_API_BizBase.T_Coupon>();
            tCon.t_CouponHistories          = new List<IF_KDCE_API_BizBase.T_CouponHistory>();
            tCon.t_TnCAccepteds             = new List<IF_KDCE_API_BizBase.T_TnCAccepted>();
//            tCon.t_TnCHistories = new List<IF_KDCE_API_BizBase.T_TnCHistory>();
            tCon.t_DormantContacts          = new List<IF_KDCE_API_BizBase.T_DormantContact>();

            /*
            for (KDCE_ContactHistory__c contactHistory : contact.ContactHistories__r) {
                tContactHistory             = new IF_KDCE_API_BizBase.T_ContactHistory();
                tContactHistory.Id          = contactHistory.Id;
                tContactHistory.RecordNumber= contactHistory.Name;
                tContactHistory.ContactId   = contactHistory.Contact__c;
                tContactHistory.HistoryType = contactHistory.HistoryType__c;
                tContactHistory.ActionType  = contactHistory.ActionType__c;
                tContactHistory.ActionDate  = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contactHistory.ActionDate__c);
                tContactHistory.Log         = contactHistory.Log__c;
                tContactHistory.CreatedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contactHistory.CreatedDate);
                tContactHistory.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(contactHistory.LastModifiedDate);
                tCon.t_ContactHistories.add(tContactHistory);
            }
            */

            for (KDCE_Order__c order : contact.Orders__r) {
                tOrder                      = new IF_KDCE_API_BizBase.T_Order();
                tOrder.Id                   = order.Id;
                tOrder.OrderNo              = order.OrderNo__c;
                tOrder.OriginOrderNo        = order.OriginOrderNo__c;
                tOrder.OrderReason          = order.OrderReason__c;
                tOrder.ExtOrderId           = order.EntityId__c;
                tOrder.Name                 = order.Name;
                tOrder.ActionChannel        = order.ActionChannel__c;
                tOrder.ActionType           = order.ActionType__c;
                tOrder.OrderDate            = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(order.OrderDate__c);
                tOrder.OrderType            = order.OrderType__c;
                tOrder.OrderCurrency        = order.Currency__c;
//                tOrder.CustomerLocale       = order.CustomerLocale__c;
//                tOrder.PreferredLocale      = order.PreferredLocale__c;
                tOrder.ContactExtId         = order.Contact__r.KDCE_ExternalId__c;
                tOrder.CustomerName         = order.CustomerName__c;
                tOrder.CustomerEmail        = order.CustomerEmail__c;
                tOrder.OrderStatus          = order.OrderStatus__c;
                tOrder.NetPrice             = String.valueOf(order.NetPrice__c);
                tOrder.PaymentAmount        = String.valueOf(order.PaymentAmount__c);
                tOrder.PaymentMethod        = order.PaymentMethod__c;
                tOrder.ShippingStreet       = order.ShippingStreet__c;
                tOrder.ShippingCity         = order.ShippingCity__c;
                tOrder.ShippingState        = order.ShippingState__c;
                tOrder.ShippingCountry      = order.ShippingCountryCode__c;
                tOrder.ShippingMethod       = order.ShippingMethod__c;
                tOrder.ShippingPostalCode   = order.ShippingPostalCode__c;
//                tOrder.Status               = order.shipping_status__c;
//                tOrder.Channel              = order.Channel__c;
                tOrder.CreatedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(order.CreatedDate);
                tOrder.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(order.LastModifiedDate);

                tOrder.t_OrderItems = new List<IF_KDCE_API_BizBase.T_OrderLineItem>();
                if(orderMap.containsKey(order.OrderNo__c) && (orderMap?.get(order.OrderNo__c) != null)) {
                    for (KDCE_OrderLineItem__c orderLineItem : orderMap?.get(order.OrderNo__c)) {
                        tOrderLineItem = new IF_KDCE_API_BizBase.T_OrderLineItem();
                        tOrderLineItem.Id = orderLineItem?.Id;
//                        tOrderLineItem.Name = orderLineItem?.Name;
                        tOrderLineItem.OrderNo = orderLineItem?.Order__r?.OrderNo__c;
                        tOrderLineItem.OrderItemNo = orderLineItem?.EntityId__c;
                        tOrderLineItem.Codentify = orderLineItem?.Codentify__c;
                        tOrderLineItem.KDCE_EANCode = orderLineItem?.Product__r?.KDCE_EANCode__c;
                        tOrder.t_OrderItems.add(tOrderLineItem);
                    }
                }

                tCon.t_Orders.add(tOrder);
            }

            for (Asset asset : contact.Assets) {
                tAsset                              = new IF_KDCE_API_BizBase.T_Asset();
                tAsset.Id                           = asset.Id;
                tAsset.ContactExtId                 = contact.KDCE_ExternalId__c;
                tAsset.CCR_CodentifyId              = asset.CCR_CodentifyId__c; // Codentify ID
                tAsset.SerialNumber                 = asset.SerialNumber;       // Parent Codentify ID
                tAsset.Status                       = asset.Status;
                tAsset.ProductCode                  = asset.Product2.Name;      // Product Code
                tAsset.CCR_DeviceProductCode        = asset.CCR_DeviceProductCode__r.Name;  // Material Code
                tAsset.CCR_MaterialGroupDescription = asset.CCR_MaterialGroupDescription__c;    // Material Group Description
                tAsset.KDCE_fm_ProductEAN           = asset.KDCE_fm_ProductEAN__c;    // Product EAN Code
                tAsset.CCR_Version                  = asset.CCR_Version__c;   // Material Version

                tAsset.CCR_ProductionDateTime       = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(asset.CCR_ProductionDateTime__c);
                tAsset.CCR_ParentProductionDateTime = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(asset.CCR_ParentProductionDateTime__c);
                tAsset.CCR_WarrantyDueDate          = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(asset.KDCE_fm_WarrantyDate__c);
                tAsset.CCR_CarePlusDueDate          = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(asset.CCR_CarePlusDueDate__c);
                tAsset.PurchaseDate                 = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(asset.PurchaseDate);

                tAsset.CreatedDate                  = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(asset.CreatedDate);
                tAsset.LastModifiedDate             = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(asset.LastModifiedDate);
                tCon.t_Assets.add(tAsset);
            }

            for (CCR_AssetLifeCycle__c assetLifeCycle : contact.AssetLifeCycles__r) {
                tAssetLifecycle = new IF_KDCE_API_BizBase.T_AssetLifecycle();
                tAssetLifecycle.Id = assetLifeCycle.Id;
                tAssetLifecycle.RecordNumber = assetLifeCycle.Name;
                tAssetLifecycle.ContactExtId = contact.KDCE_ExternalId__c;
                tAssetLifecycle.AssetId = assetLifeCycle.CCR_Asset__c;
                tAssetLifecycle.CodentifyId = assetLifeCycle.CCR_Asset__r.CCR_CodentifyId__c;
                tAssetLifecycle.KDCE_DeviceType = assetLifeCycle.KDCE_DeviceType__c;
                tAssetLifecycle.CCR_Action = assetLifeCycle.CCR_Action__c;
                tAssetLifecycle.CCR_ActionDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(assetLifeCycle.CCR_ActionDate__c);
                tAssetLifecycle.CreatedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(assetLifeCycle.CreatedDate);
                tAssetLifecycle.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(assetLifeCycle.LastModifiedDate);
                tCon.t_AssetLifecycles.add(tAssetLifecycle);
            }

            /*
            for (KDCE_AssetHistory__c assetHistory : contact.AssetHistories__r) {
                tAssetHistory = new IF_KDCE_API_BizBase.T_AssetHistory();
                tAssetHistory.Id = assetHistory.Id;
                tAssetHistory.ContactExtId = contact.KDCE_ExternalId__c;
                tAssetHistory.AssetId = assetHistory.Asset__c;
                tAssetHistory.CodentifyId = assetHistory.Asset__r.CCR_CodentifyId__c;
                tAssetHistory.OrderId = assetHistory.OrderLineItem__r.Order__c;
                tAssetHistory.OrderNumber = assetHistory.OrderLineItem__r.Order__r.Name;
                tAssetHistory.OrderLineItemId = assetHistory.OrderLineItem__c;
                tAssetHistory.CreatedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(assetHistory.CreatedDate);
                tAssetHistory.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(assetHistory.LastModifiedDate);
                tCon.t_AssetHistories.add(tAssetHistory);
            }
            */

            for (KDCE_Coupon__c coupon : contact.Coupons__r) {
                tCoupon = new IF_KDCE_API_BizBase.T_Coupon();
                tCoupon.Id = coupon.Id;
//                tCoupon.ContactExtId = contact.KDCE_ExternalId__c;
//                tCoupon.CouponCode = coupon.CouponCode__c;
//                tCoupon.CategoryName = coupon.CategoryName__c;
//                tCoupon.ModfiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.ModfiedDate__c);
//                tCoupon.CVSChainCode = coupon.CVSChainCode__c;
//                tCoupon.CVSChainName = coupon.CVSChainName__c;
//                tCoupon.OrderIdx = String.valueOf(coupon.OrderIdx__c);
//                tCoupon.OrderType = coupon.OrderType__c;
//                tCoupon.OriginType = coupon.OriginType__c;
//                tCoupon.SendEndDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.SendEndDate__c);
//                tCoupon.UsedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.UsedDate__c);
//                tCoupon.Channel = coupon.Channel__c;
//                tCoupon.ChannelDetails = coupon.ChannelDetails__c;
//                tCoupon.ConsumerId = coupon.ConsumerId__c;
//                tCoupon.Amount = coupon.Amount__c;
//                tCoupon.ExpiryDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.ExpiryDate__c);
//                tCoupon.CouponName = coupon.CouponName__c;
//                tCoupon.Status = coupon.Status__c;
//                tCoupon.ru_UseCount = String.valueOf(coupon.ru_UseCount__c);
//                tCoupon.Datasource = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.Datasource__c);
//                tCoupon.Email = coupon.Email__c;
//                tCoupon.EndDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.EndDate__c);
//                tCoupon.GifticonIssuedCount = String.valueOf(coupon.ru_GifticonReceivedHistoryCount__c);
//                tCoupon.Idx = String.valueOf(coupon.Idx__c);
                tCoupon.CreatedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.CreatedDate);
                tCoupon.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(coupon.LastModifiedDate);
                tCon.t_Coupons.add(tCoupon);
            }

            for (KDCE_CouponHistory__c couponHistory : contact.CouponHistories__r) {
                tCouponHistory = new IF_KDCE_API_BizBase.T_CouponHistory();
                tCouponHistory.Id = couponHistory.Id;
//                tCouponHistory.ContactExtId = contact.KDCE_ExternalId__c;
//                tCouponHistory.CouponId = couponHistory.Coupon__c;
//                tCouponHistory.ActionChannel = couponHistory.ActionChannel__c;
//                tCouponHistory.ActionType = couponHistory.ActionType__c;
//                tCouponHistory.ActionDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(couponHistory.ActionDate__c);
//                tCouponHistory.Gifticon = couponHistory.Gifticon__c;
                tCouponHistory.CreatedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(couponHistory.CreatedDate);
                tCouponHistory.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(couponHistory.LastModifiedDate);
                tCon.t_CouponHistories.add(tCouponHistory);
            }

            for (KDCE_TnCAccepted__c tncAccepted : contact.TnCAccepted__r) {
                tTnCAccepted = new IF_KDCE_API_BizBase.T_TnCAccepted();
                tTnCAccepted.Id             = tncAccepted.Id;
                tTnCAccepted.Name           = tncAccepted.Name;
                tTnCAccepted.ContactExtId   = contact.KDCE_ExternalId__c;
                tTnCAccepted.TnCVersionSetId= tncAccepted.TnCVersionSet__c;
                tTnCAccepted.TnCName        = tncAccepted.fm_TnC__c;
                tTnCAccepted.SubGroup       = tncAccepted.TnCVersionSet__r.TaC__r.KDCE_SubGroup__c;
                tTnCAccepted.Accepted       = String.valueOf(tncAccepted.Accepted__c);
                tTnCAccepted.CreatedDate    = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(tncAccepted.CreatedDate);
                tTnCAccepted.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(tncAccepted.LastModifiedDate);
                tCon.t_TnCAccepteds.add(tTnCAccepted);
            }

//            for (KDCE_TnCHistory__c tncHistory : contact.TnCHistories__r) {
//                tTncHistory = new IF_KDCE_API_BizBase.T_TnCHistory();
//                tTncHistory.Id = tncHistory.Id;
//                tTncHistory.ContactExtId = contact.KDCE_ExternalId__c;
//                tTncHistory.KDCE_TnCVersionSetId = tncHistory.KDCE_TnCVersionSet__c;
//                tTncHistory.KDCE_TnCId = tncHistory.KDCE_TnC__c;
//                tTncHistory.KDCE_Channel = tncHistory.KDCE_Channel__c;
//                tTncHistory.CCR_Acceptance_Date = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(tncHistory.CCR_Acceptance_Date__c);
//                tTncHistory.KDCE_Accepted = String.valueOf(tncHistory.KDCE_Accepted__c);
//                tTncHistory.KDCE_AcceptanceResponse = tncHistory.KDCE_AcceptanceResponse__c;
//                tTncHistory.CreatedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(tncHistory.CreatedDate);
//                tTncHistory.LastModifiedDate = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(tncHistory.LastModifiedDate);
//                tCon.t_TnCHistories.add(tTncHistory);
//            }
            tContacts.add(tCon);

            /**
             * Login History 처리 영역
             */
            // loginType 이 N이 아닌 경우에 대해서만 로그인 히스토리를 쌓음
            if(loginType != 'N'){

                clh = new KDCE_ConsumerLoginHistory__c();
                clh.Contact__c = contact.Id;
                clh.LoginDate__c = System.now();
                if(loginType == 'K') clh.IsKakaoLogin__c = true;
                // Contact에 최종 로그인 시간 처리
                contact.KDCE_LastLoginDate__c = System.now();

                // QURE Access Token 처리, 로그인 할 때 값이 생성됨. 권준석 2021.05.17
                // Consumer Id + Login Time 을 MD5 로 처리함
                String accessToken = KDCE_Util.getHashString(contact.KDCE_ExternalId__c);
                clh.AccessToken__c = accessToken;
                clh.TokenExpireTime__c = System.now().addHours(3);
                tCon.QUREAccessToken = accessToken;
                tCon.QUREAccessTokenExpireTime = IF_KDCE_API_BizBase.convertDateAndDateTimeToString(clh.TokenExpireTime__c);
                contact.KDCE_QUREAccessToken__c = accessToken;
                contact.KDCE_TokenExpireTime__c = clh.TokenExpireTime__c;
                
                clhList.add(clh);
            }
        }

        // Login History Insert
        if(clhList.size() > 0){
            insert clhList;
            // Contact의 Last Login Date 업데이트
            update contacts;
        }

        return tContacts;
    }

    /**
     * @description Ecommerce Contact Member 생성/수정 인터페이스 / 생성 IF_MG_DCE_0096
     * @param (List<IF_KDCE_API_BizBase.T_Contact>) tContacts
     *
     * @return : 반환값에 생성,업데이트된 Record 정보 매핑
     */
    @SuppressWarnings('PMD')
    public static List<IF_KDCE_API_BizBase.T_Contact> setContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {

        System.debug('List<IF_KDCE_API_BizBase.T_Contact> tContacts : ' + tContacts);
        Map<String, Contact> contactExtIdMap = new Map<String, Contact>();
        // SC 에 Consumer ID 가 없는 케이스에 대한 처리를 위한 맵. Name_Phone 구조
        Map<String, Contact> contactNamePNMap = new Map<String, Contact>();

        // Set<String> contactNamePNKeySet = new Set<String>();

        String phone = null;

        /* Validation */
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.RegistrationChannel), LAB_IF_ERR_CONTACT_REGISTRATIONCHANNEL_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, 'iqos.com'.equals(tContact.RegistrationChannel), LAB_IF_ERR_CONTACT_REGISTRATIONCHANNEL_INVALID);
            // insert 시 고객명, 핸드폰 번호 필수 값 | update 시 external Id 필수값 -> external Id 기준 upsert
            // Edit 수정. 마젠토로 부터 받은 정보에 Consumer ID 가 있음
            if (Util.isNotEmpty(tContact.ContactExtId)) {
                IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.ContactExtId), 'Update Error: '+LAB_IF_ERR_CONTACT_EXTERNALID_REQUIRED);
//                updatingTContactMap.put(tContact.ContactExtId, tContact);
                contactExtIdMap.put(tContact.ContactExtId, null);
            }
            // New 신규 (Prospect)
            else {
                IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.Name), 'Insertion Error: '+LAB_IF_ERR_CONTACT_NAME_REQUIRED);
                IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.MobilePhone), 'Insertion Error: '+LAB_IF_ERR_CONTACT_MOBILEPHONE_REQUIRED);
                IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.MobileCarrier), 'Insertion Error: '+LAB_IF_ERR_CONTACT_MOBILECARRIER_REQUIRED);

                phone = tContact.MobilePhone.contains('-') ? tContact.MobilePhone.remove('-') : tContact.MobilePhone; // Phone ('-') 하이픈 제거
                contactNamePNMap.put(IF_KDCE_API_BizBase.getExtForNotHavingExternal(tContact.Name, phone), null);
            }
        }

        // Contact Mapping
        // KDCE_ExternalId__c 를 기준으로 검색
        if (contactExtIdMap.keySet().size() > 0)  {
            for (Contact con : [
                    SELECT Id, KDCE_Name__c, KDCE_ExternalId__c, KDCE_NamePNKey__c, KDCE_fm_ConsumerType__c, KDCE_TnCVersion__c, KDCE_PNKey__c,
                            KDCE_ECJoinDate__c, KDCE_IsDormant__c
                    FROM Contact
                    WHERE KDCE_ExternalId__c IN :contactExtIdMap.keySet()
//                    OR KDCE_NamePNKey__c IN :externalKeys
            ]) {
                if(Util.isNotEmpty(con.KDCE_ExternalId__c)) contactExtIdMap.put(con.KDCE_ExternalId__c, con);
            }
        }
        // KDCE_NamePNKey__c 를 기준으로 검색
        else if (contactNamePNMap.keySet().size() > 0) {
            Contact tempCon;
            for (Contact conNameMatch : [
                    SELECT Id, KDCE_Name__c, KDCE_ExternalId__c, KDCE_NamePNKey__c, KDCE_fm_ConsumerType__c, KDCE_TnCVersion__c, KDCE_PNKey__c,
                            RecordTypeId, KDCE_ECJoinDate__c, KDCE_RegistrationDate__c, KDCE_IsDormant__c
                    FROM Contact
                    WHERE KDCE_NamePNKey__c IN :contactNamePNMap.keySet()
            ]) {

                tempCon = contactNamePNMap.get(conNameMatch.KDCE_NamePNKey__c);
                if(tempCon != null){
                    // 우선순위 1. Member
                    if (tempCon.RecordTypeId != conNameMatch.RecordTypeId && conNameMatch.RecordTypeId == RT_Contact_MemberId) contactNamePNMap.put(conNameMatch.KDCE_NamePNKey__c, conNameMatch);

                    // 우선순위 2. RegistrationDate
                    else if (tempCon.RecordTypeId == conNameMatch.RecordTypeId) {
                        if(conNameMatch.KDCE_RegistrationDate__c != null && conNameMatch.KDCE_RegistrationDate__c > tempCon.KDCE_RegistrationDate__c) contactNamePNMap.put(conNameMatch.KDCE_NamePNKey__c, conNameMatch);
                    }
                }
                else contactNamePNMap.put(conNameMatch.KDCE_NamePNKey__c, conNameMatch);


                /*
                if(contactNamePNMap.containsKey(conNameMatch.KDCE_NamePNKey__c)) {
                    tempCon = contactNamePNMap.get(conNameMatch.KDCE_NamePNKey__c);
                    if(conNameMatch.KDCE_RegistrationDate__c != null && conNameMatch.KDCE_RegistrationDate__c > tempCon.KDCE_RegistrationDate__c) contactNamePNMap.put(conNameMatch.KDCE_NamePNKey__c, conNameMatch);
                }
                else contactNamePNMap.put(conNameMatch.KDCE_NamePNKey__c, conNameMatch);
                */
            }
            System.debug('contactNamePNMap : '+contactNamePNMap);
        }

        //TnC Version Info Map : Active T&C 몇개 안되니..그냥 호출함.
        Map<String, KDCE_TnCVersionSet__c> tncVersionSetMap = new Map<String, KDCE_TnCVersionSet__c>([
                SELECT  Id, TnCVersion__c, TaC__c, Channel__c, MarketingOptin__c, InfomationOptin__c
                FROM    KDCE_TnCVersionSet__c
                WHERE   TnCVersion__r.IsActive__c = TRUE
        ]);

        List<Contact>                   upsertingContacts   = new List<Contact>();
        Contact                         contact             = null;
        Map<String,List<KDCE_TnCHistory__c>>  tncHistoryMap = new Map<String,List<KDCE_TnCHistory__c>>();
        Map<String,List<KDCE_TnCAccepted__c>> tncAcceptedMap= new Map<String,List<KDCE_TnCAccepted__c>>();
        List<KDCE_TnCHistory__c>        tncHistories        = new List<KDCE_TnCHistory__c>();
        List<KDCE_TnCAccepted__c>       tncAccepteds        = new List<KDCE_TnCAccepted__c>();
        KDCE_TnCVersionSet__c           tncVersionSet       = null;
        KDCE_TnCHistory__c              tncHistory          = null;
        KDCE_TnCAccepted__c             tncAccepted         = null;

        Boolean Accepted = false;
        Datetime now = Datetime.now();
        Integer idx = 0;
        String contactExtKey = null;
        String birthdate = null;
        String contactNamePNKey = null;
        phone = null;

        // 휴면회원 복구를 위한 처리
        List<Contact> dormantContactList = new List<Contact>();
        Contact dormantContact;
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            // Update Case by ContactExtId
            if (contactExtIdMap.containsKey(tContact.ContactExtId) && Util.isNotEmpty(contactExtIdMap.get(tContact.ContactExtId))) {
                dormantContact = contactExtIdMap.get(tContact.ContactExtId);

                if(dormantContact.KDCE_IsDormant__c == true){
                    dormantContact.KDCE_IsDormant__c = false;
                    dormantContactList.add(dormantContact);
                }
            }
        }
        if(dormantContactList.size() > 0){
            update dormantContactList;

            for(Contact row : [
                    SELECT Id, KDCE_Name__c, KDCE_ExternalId__c, KDCE_NamePNKey__c, KDCE_fm_ConsumerType__c, KDCE_TnCVersion__c, KDCE_PNKey__c,
                            KDCE_ECJoinDate__c, KDCE_IsDormant__c
                    FROM Contact
                    WHERE Id IN :dormantContactList
            ]){
                contactExtIdMap.put(row.KDCE_ExternalId__c, row);
            }
        }

        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {

            if(Util.isNotEmpty(tContact.MobilePhone)) phone = tContact.MobilePhone.contains('-') ? tContact.MobilePhone.remove('-') : tContact.MobilePhone; // Phone ('-') 하이픈 제거
            contactNamePNKey = IF_KDCE_API_BizBase.getExtForNotHavingExternal(tContact.Name, phone);

            // Update Case by ContactExtId
            if (contactExtIdMap.containsKey(tContact.ContactExtId) && Util.isNotEmpty(contactExtIdMap.get(tContact.ContactExtId))) {
                contact = contactExtIdMap.get(tContact.ContactExtId);
                if (Util.isNotEmpty(tContact.MobilePhone) && !tContact.MobilePhone.equals(contact.KDCE_PNKey__c)) {

                    //고객 전화번호 수정시 필수값
                    //IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.HardAgeVerification), LAB_IF_ERR_CONTACT_HARDAGEVERIFICATION_REQUIRED);
                    //IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.HardAVStatusDateChange), LAB_IF_ERR_CONTACT_HARDAVSTATUSDATECHANGE_REQUIRED);

                    //phone = tContact.MobilePhone.contains('-') ? tContact.MobilePhone.remove('-') : tContact.MobilePhone; // Phone ('-') 하이픈 제거
//                    birthdate = contact.Birthdate != null ? Util.strYYYYMMDD(contact.Birthdate) : '';
//
//                    contact.KDCE_PNKey__c       = phone;
//                    contact.KDCE_NamePNKey__c   = contact.KDCE_Name__c + '_' + phone;
//                    contact.KDCE_NamePNBDKey__c = contact.KDCE_Name__c + '_' + phone + '_' + birthdate;
                }
            }
            // Update Case by Name PhoneNumber
            else if (contactNamePNMap.containsKey(contactNamePNKey) && contactNamePNMap.get(contactNamePNKey) != null) {

                contact = contactNamePNMap.get(contactNamePNKey);
                if (Util.isNotEmpty(tContact.MobilePhone) && !tContact.MobilePhone.equals(contact.KDCE_PNKey__c)) {

                    //고객 전화번호 수정시 필수값
                    //IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.HardAgeVerification), LAB_IF_ERR_CONTACT_HARDAGEVERIFICATION_REQUIRED);
                    //IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.HardAVStatusDateChange), LAB_IF_ERR_CONTACT_HARDAVSTATUSDATECHANGE_REQUIRED);

                    //phone = tContact.MobilePhone.contains('-') ? tContact.MobilePhone.remove('-') : tContact.MobilePhone; // Phone ('-') 하이픈 제거
                    birthdate = contact.Birthdate != null ? Util.strYYYYMMDD(contact.Birthdate) : '';

                    contact.KDCE_PNKey__c       = phone;
                    contact.KDCE_NamePNKey__c   = contact.KDCE_Name__c + '_' + phone;
                    contact.KDCE_NamePNBDKey__c = contact.KDCE_Name__c + '_' + phone + '_' + birthdate;
                }

            }
            //신규 가입 New Contact
            else {
                contact = new Contact(
                        KDCE_RegistrationChannel__c = tContact.RegistrationChannel,
                        KDCE_RegistrationDate__c    = System.now()
                );
                if (Util.isNotEmpty(tContact.Name)) {
                    contact.KDCE_Name__c        = tContact.Name;
                    contact.LastName            = tContact.Name;
                    //Trigger 생성 타이밍과 안맞음. 직접 처리 
                    contact.KDCE_PNKey__c       = phone;
                    contact.KDCE_NamePNKey__c   = tContact.Name + '_' + phone;
                    contact.KDCE_NamePNBDKey__c = tContact.Name + '_' + phone + '_' + birthdate;
                }
            }
            {
                //RecordType
                switch on tContact.RegistrationChannel {
                    when 'iqos.com' { //문자열 변수 처리 안됨;;
                        contact.RecordTypeId = RT_Contact_MemberId;
                        // Member로 가입 하는 모든 고객은 Care+ Status Enrolled 처리함
                        contact.CCR_CarePlusStatus__c = 'Enrolled';
                        // 마젠토를 통해 업데이트 되는 모든 Member는 KDCE_ConvertedConsumer__c 을 true로 처리함. 2021.05.04 권준석
                        contact.KDCE_ConvertedConsumer__c = true;
                        if(contact.KDCE_ECJoinDate__c == null) contact.KDCE_ECJoinDate__c = System.now();
                    }
                }

//                contact.KDCE_LASLAU__c = 'LAS'; //Default
                if (Util.isNotEmpty(tContact.MobilePhone)) contact.Phone = tContact.MobilePhone;
                if (Util.isNotEmpty(tContact.DropOutRequest)) contact.KDCE_IsRequestDropout__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.DropOutRequest);
                if (Util.isNotEmpty(tContact.LastLoginDate)) contact.KDCE_LastLoginDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.LastLoginDate);
                if (Util.isNotEmpty(tContact.Gender)) contact.CCR_Gender__c = tContact.Gender;
                if (Util.isNotEmpty(tContact.Birthdate)) contact.Birthdate = IF_KDCE_API_BizBase.convertStringToDate(tContact.Birthdate);
                if (Util.isNotEmpty(tContact.Email)) contact.Email = tContact.Email;
                if (Util.isNotEmpty(tContact.PostalCode)) contact.KDCE_FirstAddressPostal__c = tContact.PostalCode;
                if (Util.isNotEmpty(tContact.Address1)) contact.KDCE_FirstAddressLv1__c = tContact.Address1;
                if (Util.isNotEmpty(tContact.Address2)) contact.KDCE_FirstAddressLv2__c = tContact.Address2;
                if (Util.isNotEmpty(tContact.State)) contact.MailingState = tContact.State;
                if (Util.isNotEmpty(tContact.City)) contact.MailingCity = tContact.City;
                if (Util.isNotEmpty(tContact.PostalCode)) contact.MailingPostalCode = tContact.PostalCode;
                if (Util.isNotEmpty(tContact.HasRegistedUsingKakaoId)) contact.KDCE_HasRegistedUsingKakaoId__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.HasRegistedUsingKakaoId);
                if (Util.isNotEmpty(tContact.JoinedPMKChannel)) contact.KDCE_JoinedPMKChannel__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.JoinedPMKChannel);
                if (Util.isNotEmpty(tContact.KakaoId)) contact.KDCE_KakaoId__c = tContact.KakaoId;
                // Information Optin
                if (Util.isNotEmpty(tContact.MarketingOptIn)) contact.KDCE_MarketingOptIn__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.MarketingOptIn);
                if (Util.isNotEmpty(tContact.CarePlusStatus)) contact.CCR_CarePlusStatus__c = tContact.CarePlusStatus;
                if (Util.isNotEmpty(tContact.CarePlusDueDate)) contact.CCR_CarePlusDueDate__c = IF_KDCE_API_BizBase.convertStringToDate(tContact.CarePlusDueDate);
                if (Util.isNotEmpty(tContact.QoachProgram)) contact.CCR_QoachProgram__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.QoachProgram);
//                if (Util.isNotEmpty(tContact?.ConsumerType))  //KDCE_fm_ConsumerType__c
//                if (Util.isNotEmpty(tContact?.LASLAU)) contact.KDCE_LASLAU__c = tContact.LASLAU;
                if (Util.isNotEmpty(tContact.Smoker)) contact.CCR_SmokerNew__c = tContact.Smoker;
                if (Util.isNotEmpty(tContact.SmokerDeclarationDate)) contact.CCR_SmokerDeclarationDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.SmokerDeclarationDate);
                // Hard Age Verification
                if (Util.isNotEmpty(tContact.HardAgeVerification)) contact.CCR_GlobalAgeVerification__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.HardAgeVerification);
                // Hard Age Verification Status
                if (Util.isNotEmpty(tContact.HardAgeVerificationStatus)) contact.CCR_AgeVerificationStatus__c = tContact.HardAgeVerificationStatus;
                // Hard Av Status Date Change
                if (Util.isNotEmpty(tContact.HardAVStatusDateChange)) contact.CCR_AVStatusDateChange__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.HardAVStatusDateChange);
                if (Util.isNotEmpty(tContact.HardAgeVerifiedDate)) contact.KDCE_HardAgeVerifiedDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.HardAgeVerifiedDate);
                // IsHard Age Verification
                if (Util.isNotEmpty(tContact.SoftAgeVerified)) contact.CCR_SoftAgeVerifiedNew__c = tContact.SoftAgeVerified;
                if (Util.isNotEmpty(tContact.SoftAgeVerifiedDate)) contact.CCR_SoftAgeVerifiedDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.SoftAgeVerifiedDate);
                if (Util.isNotEmpty(tContact.MGMCode)) contact.KDCE_MGMCode__c = tContact.MGMCode;
                if (Util.isNotEmpty(tContact.IsDormant)) contact.KDCE_IsDormant__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.IsDormant);
                if (Util.isNotEmpty(tContact.ConvertDormantDate)) contact.KDCE_ConvertDormantDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.ConvertDormantDate);
                // 개인정보 보유기간
                if (Util.isNotEmpty(tContact.PersonalInfoValidityPeriod)) contact.KDCE_PersonalInfoValidityPeriod__c = tContact.PersonalInfoValidityPeriod; //PersonalInfoValidityPeriod
                // Drop out Available
                if (Util.isNotEmpty(tContact.DropOutRequestDate)) contact.KDCE_DropoutRequestDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.DropOutRequestDate);
//                    KDCE_IsRequestDropout__c = IF_KDCE_API_BizBase.getValidBoolean(tContact?.DropOutRequest),
                if (Util.isNotEmpty(tContact.DropOutDate)) contact.KDCE_DropoutDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.DropOutDate);
                // Dropout Contact
                if (Util.isNotEmpty(tContact.BlockedContact)) contact.CCR_BlockedContact__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.BlockedContact);
                if (Util.isNotEmpty(tContact.BockingReason)) contact.CCR_BockingReason__c = tContact.BockingReason;
                if (Util.isNotEmpty(tContact.MobileCarrier)) contact.KDCE_MobileCarrier__c = tContact.MobileCarrier;
                if (Util.isNotEmpty(tContact.ECLoginEmail)) contact.KDCE_ECLoginEmail__c = tContact.ECLoginEmail;
//                    CreatedDate = IF_KDCE_API_BizBase.convertStringToDatetime(tContact?.CreatedDate),
//                    LastModifiedDate = IF_KDCE_API_BizBase.convertStringToDatetime(tContact?.LastModifiedDate)
                //강제 값 셋팅
                if (Util.isEmpty(contact.KDCE_ExternalId__c)) {
                    contact.KDCE_ExternalId__c = String.valueOf(now) + ''+ String.valueOf(idx++);
                }
            }
            upsertingContacts.add(contact);

            //Opt-in Default values are True.
            contactExtKey = contact.KDCE_NamePNKey__c;//IF_KDCE_API_BizBase.getExtForNotHavingExternal(tContact.Name,tContact.MobilePhone);
            tncHistories = tncHistoryMap.containsKey(contactExtKey)?tncHistoryMap.get(contactExtKey):new List<KDCE_TnCHistory__c>();
            tncAccepteds = tncAcceptedMap.containsKey(contactExtKey)?tncAcceptedMap.get(contactExtKey):new List<KDCE_TnCAccepted__c>();
            //동의처리
            if(!Util.isEmpty(tContact.t_TnCHistories) && !tContact.t_TnCHistories.isEmpty()) {

                // TNC가 하나도 변경되지 않은 케이스로 호출되면 무조건 true로 업데이트 시켜버리는 현상이 있어서 수정함. 2021.04.29 권준석
                contact.KDCE_InformationOptIn__c    = true;
                contact.KDCE_MarketingOptIn__c      = true;

                for(IF_KDCE_API_BizBase.T_TnCHistory tTnCHistory :  tContact.t_TnCHistories) {
                    Accepted                            = IF_KDCE_API_BizBase.getValidBoolean(tTncHistory.KDCE_Accepted);
                    // TODO UAT 단계 임시 처리
                    //Active T&C Version Set에 존재하지 않으면,
                    if(!tncVersionSetMap.containsKey(tTncHistory.KDCE_TnCVersionSetId)) continue;
                    tncVersionSet                       = tncVersionSetMap.get(tTncHistory.KDCE_TnCVersionSetId);
                    //Set T&C Version Id to KDCE_TnCVersion__c of Contact
//                    contact.KDCE_TnCVersion__c          = tncVersionSet.TnCVersion__c;
                    //Set tncHistory
                    tncHistory                          = new KDCE_TnCHistory__c();
    //                tncHistory.DTE_Contact__c           = contactExtKey;
                    tncHistory.KDCE_TnCVersionSet__c    = tncVersionSet.Id;
                    tncHistory.KDCE_TnC__c              = tncVersionSet.TaC__c;
                    tncHistory.KDCE_Channel__c          = tnCVersionSet.Channel__c;
                    tncHistory.CCR_Acceptance_Date__c   = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tTncHistory.CCR_Acceptance_Date);
                    tncHistory.KDCE_Accepted__c         = Accepted;
                    //T&C동의에 따른 Contact Information/Marketing Opt In 변경
                    if(Accepted == FALSE) {
                        if(tncVersionSet.InfomationOptin__c == TRUE) {
                            contact.KDCE_InformationOptIn__c = false;
                            tncHistory.KDCE_Description__c = LAB_TNC_HISTORY_DESC_DECLINE_INFORMATION;
                        }
                        if(tncVersionSet.MarketingOptin__c == TRUE) {
                            contact.KDCE_MarketingOptIn__c = false;
                            if(Util.isNotEmpty(tncHistory.KDCE_Description__c)) tncHistory.KDCE_Description__c = LAB_TNC_HISTORY_DESC_DECLINE_MARKETINGANDINFORMATION;
                            else tncHistory.KDCE_Description__c = LAB_TNC_HISTORY_DESC_DECLINE_MARKETING;
                        }
                    }
                    tncHistories.add(tncHistory);

                    //Contact이 멤버(iqos.com)일 경우만 관리
                    if(contact.KDCE_ConvertedConsumer__c) {
                        if(RT_Contact_MemberId.equals(contact.RecordTypeId)) {
                            tncAccepted = new KDCE_TnCAccepted__c();
                            //KDCE_TnCAccepted__c ExternalId : ContactId + TaCVersionSetId
                            tnCAccepted.ExternalId__c       = contactExtKey+''+tncVersionSet.Id;
                            tncAccepted.Contact__c          = Util.isNotEmpty(contact.Id)?contact.Id:null;
                            tncAccepted.TnCVersionSet__c    = tncVersionSet.Id;
                            tncAccepted.TnC__c              = tncVersionSet.TaC__c;
                            tncAccepted.Accepted__c         = Boolean.valueOf(tTncHistory.KDCE_Accepted);
                            tncAccepteds.add(tncAccepted);
                        }
                    }
                }

                //고객의 T&C Version 정보가 다르면, Contact T&C Version Id 정보 업데이트, 기존 T&C Accepted 정보 삭제.
                if(!tnCVersionSet.TnCVersion__c.equals(contact.KDCE_TnCVersion__c)) {
                    contact.KDCE_TnCVersion__c = tnCVersionSet.TnCVersion__c;
                    //이전 T&C Version의 T&C Accepted 정보 삭제.
                    delete [SELECT Id FROM KDCE_TnCAccepted__c WHERE Contact__c = :contact.Id];
                }

                tncHistoryMap.put(contactExtKey, tncHistories);
                tncAcceptedMap.put(contactExtKey, tncAccepteds);
            }
        }
        //upsert
        upsert upsertingContacts KDCE_ExternalId__c;

        // 업데이트 결과 매핑
        Set<Id> contactIds = new Set<Id>();
        if (upsertingContacts.size() > 0) {
            for (Contact sContact : upsertingContacts) {
                contactIds.add(sContact.Id);
            }
        }
        //ContactExtId 취득 맵핑
        tncHistories = new List<KDCE_TnCHistory__c>();
        tncAccepteds = new List<KDCE_TnCAccepted__c>();
        tContacts = new List<IF_KDCE_API_BizBase.T_Contact>();
        IF_KDCE_API_BizBase.T_Contact tContact = null;
        IF_KDCE_API_BizBase.T_TnCHistory tTnCHistory = null;
        IF_KDCE_API_BizBase.T_TnCAccepted tTnCAccepted = null;
        for(Contact cont : [SELECT Id, KDCE_ExternalId__c, KDCE_Name__c, Phone, KDCE_NamePNKey__c FROM Contact WHERE Id IN :contactIds]) {
            tContact                = new IF_KDCE_API_BizBase.T_Contact();
            tContact.Id             = cont.Id;
            tContact.ContactExtId   = cont.KDCE_ExternalId__c;
            tContact.Name           = cont.KDCE_Name__c;
            tContact.MobilePhone    = cont.Phone;
            tContacts.add(tContact);

            contactExtKey           = IF_KDCE_API_BizBase.getExtForNotHavingExternal(cont.KDCE_Name__c, cont.Phone);

            if(!tncHistoryMap.isEmpty()) {
                if(tncHistoryMap.containsKey(contactExtKey) && tncHistoryMap.get(contactExtKey).size() > 0) {
                    for(KDCE_TnCHistory__c tncHistory2 : tncHistoryMap.get(contactExtKey)) {
                        tncHistory2.DTE_Contact__c  = cont.Id;
                    }
                    tncHistories.addAll(tncHistoryMap.get(contactExtKey));
                }
            }

            if(!tncAcceptedMap.isEmpty()) {
                if(tncAcceptedMap.containsKey(contactExtKey) && tncAcceptedMap.get(contactExtKey).size() > 0) {
                    for(KDCE_TnCAccepted__c tnCAccepted2 : tncAcceptedMap.get(contactExtKey)) {
                        tnCAccepted2.Contact__c     = cont.Id;
                        tnCAccepted2.ExternalId__c   = cont.Id+''+tnCAccepted2.TnCVersionSet__c;
                    }
                    tncAccepteds.addAll(tncAcceptedMap.get(contactExtKey));
                }
            }
        }

        if(tncHistories.size() > 0) insert tncHistories;
        //T&C Accepted upsert
        if(tnCAccepteds.size() > 0) {
            //KDCE_TnCAccepted_tr bypass 처리 : TnC History 생성 및 COntact Opt-in 제어 처리 bypass
            TriggerHandler.bypass('KDCE_TnCAccepted_tr');
            upsert tnCAccepteds ExternalId__c;
            TriggerHandler.clearBypass('KDCE_TnCAccepted_tr');
        }

        return tContacts;
    }

    /**
     * @param ConsumerType
     *
     * @return
     */
    public static String getConsumerRecordTypeId(String ConsumerType) {
        String recordTypeId = null;

        switch on (ConsumerType) {
            when 'Anonymous' {
                recordTypeId = RT_Contact_AnonymousId;
            }
            when 'Prospect' {
                recordTypeId = RT_Contact_ProspectId;
            }
            when 'Member' {
                recordTypeId = RT_Contact_MemberId;
            }
        }

        return recordTypeId;
    }

    /**
     * @description 휴면고객 복구 IF_MG_DCE_0101
     * @param (List<IF_KDCE_API_BizBase.T_Contact>) tContacts
     *
     * @return : 반환값에 업데이트된 Record 정보 매핑
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> restoreDormantContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {

        System.debug('List<IF_KDCE_API_BizBase.T_Contact> tContacts : ' + tContacts);

        /* Validation */
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.ContactExtId), LAB_IF_ERR_CONTACT_EXTERNALID_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.IsDormant), LAB_IF_ERR_CONTACT_ISDORMANT_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.RestoreDormantDate), LAB_IF_ERR_CONTACT_RESTOREDORMANTDATE_REQUIRED);
        }

        List<Contact> contacts = new List<Contact>();
        Contact contact = null;
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            contact = new Contact(
                    KDCE_ExternalId__c = tContact.ContactExtId,
                    KDCE_IsDormant__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.IsDormant),
                    KDCE_ReactivateDormantDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.RestoreDormantDate)
            );

            contacts.add(contact);
        }

        upsert contacts KDCE_ExternalId__c;

        // 업데이트 결과 매핑
        Map<String, Id> results = new Map<String, Id>();
        for (Contact sContact : contacts) {
            results.put(sContact.KDCE_ExternalId__c, sContact.Id);
        }

        String contactId = null;
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            contactId = results.get(tContact.ContactExtId);
            tContact.Id = contactId;
        }
        return tContacts;
    }

    /**
     * @description 탈퇴고객 처리정보 설정 IF_MG_DCE_0103
     * @param (List<IF_KDCE_API_BizBase.T_Contact>) tContacts
     *
     * @return : 반환값에 업데이트된 Record 정보 매핑
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> setDropoutContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {

        System.debug('List<IF_KDCE_API_BizBase.T_Contact> tContacts : ' + tContacts);

        Map<String, IF_KDCE_API_BizBase.T_Contact> updatingTContactMap = new Map<String, IF_KDCE_API_BizBase.T_Contact>();

        // 진행중인 Order/Rental/OfflineProgra/Case 혹은 추심이 있는지 확인
        // Open 된 Case 있는지 체크
        Map<String, Boolean> isInvalidDropOutContact = new Map<String, Boolean>();
//        // 배송 중인 주문이 있는지 체크
//        Map<String, Boolean> orderCheckMap = new Map<String, Boolean>();
//        // 진행 중인 Rental이 있는지 체크
//        Map<String, Boolean> rentalCheckMap = new Map<String, Boolean>();

        /* Validation */
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.ContactExtId), LAB_IF_ERR_CONTACT_EXTERNALID_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.DropOutRequest), LAB_IF_ERR_CONTACT_DROPOUTREQUEST_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.DropOutRequestDate), LAB_IF_ERR_CONTACT_DROPOUTREQUESTDATE_REQUIRED);
            updatingTContactMap.put(tContact.ContactExtId, tContact);
            // 탈퇴 유효성을 체크하기 위한 Map 모두 false 처리 (Default)
            isInvalidDropOutContact.put(tContact.ContactExtId, false);
//            orderCheckMap.put(tContact.ContactExtId, false);
//            rentalCheckMap.put(tContact.ContactExtId, false);
        }
        List<Contact> contacts = [
                SELECT KDCE_ExternalId__c,
                        KDCE_IsRequestDropout__c,
                        KDCE_DropoutRequestDate__c,
                        KDCE_fm_AvailDropout__c,
                        CCR_DatabaseOptin__c,
                        KDCE_RentalConsumer__c
                FROM Contact
                WHERE KDCE_ExternalId__c IN :updatingTContactMap.keySet()
        ];

        List<Case> openCaseList = [
                SELECT Id, Contact.KDCE_ExternalId__c
                FROM Case
                WHERE Status NOT IN :KDCE_GlobalValue.CASE_STATUS_NOT_INPROGRESS_SET
                AND Contact.KDCE_ExternalId__c IN :updatingTContactMap.keySet()
        ];
        for(Case c : openCaseList){
            isInvalidDropOutContact.put(c.Contact.KDCE_ExternalId__c, TRUE);
        }

        /*
         * orderCheckMap
         */
        // Complete의 경우, 배송중이므로 포함 x
        // 온라인 주문만 포함해야하기 때문에 ActionChannel__c = 'iqos.com' 조건 추가

        List<KDCE_Order__c> openOrderList = [
                SELECT Id, Contact__r.KDCE_ExternalId__c
                FROM KDCE_Order__c
                WHERE Contact__r.KDCE_ExternalId__c IN :updatingTContactMap.keySet()
                AND ActionChannel__c = 'iqos.com'
                AND ((OrderStatus__c NOT IN :KDCE_GlobalValue.ORDER_STATUS_NOT_INPROGRESS_SET AND CollectionStatus__c = NULL)
                OR CollectionStatus__c IN :KDCE_GlobalValue.ORDER_COL_STATUS_INPROGRESS_SET)
        ];
        for (KDCE_Order__c order : openOrderList) {
            isInvalidDropOutContact.put(order.Contact__r.KDCE_ExternalId__c, TRUE);
        }

        /*
         * rentalCheckMap
         */
        List<KDCE_OfflineProgram__c> rentalCheckList = [
                SELECT Id, Contact__r.KDCE_ExternalId__c
                FROM KDCE_OfflineProgram__c
                WHERE Status__c IN :KDCE_GlobalValue.OP_STATUS_INPROGRESS_SET
                AND Contact__r.KDCE_ExternalId__c IN :updatingTContactMap.keySet()
        ];
        for (KDCE_OfflineProgram__c program : rentalCheckList) {
            isInvalidDropOutContact.put(program.Contact__r.KDCE_ExternalId__c, TRUE);
        }

        Map<Id, Contact> updateContact = new Map<Id, Contact>();
        for (Contact contact : contacts) {

            contact.KDCE_ExternalId__c = updatingTContactMap.get(contact.KDCE_ExternalId__c).ContactExtId;
            if (contact.KDCE_RentalConsumer__c) isInvalidDropOutContact.put(contact.KDCE_ExternalId__c, TRUE); // 렌탈 진행중일땐, 탈퇴 불가
            if (isInvalidDropOutContact.containsKey(contact.KDCE_ExternalId__c) && isInvalidDropOutContact.get(contact.KDCE_ExternalId__c) == TRUE) continue;

            contact.KDCE_IsRequestDropout__c = IF_KDCE_API_BizBase.getValidBoolean(updatingTContactMap.get(contact.KDCE_ExternalId__c).DropOutRequest);
            // KST
            contact.KDCE_DropoutRequestDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(updatingTContactMap.get(contact.KDCE_ExternalId__c).DropOutRequestDate);
            // MG 요청으로 탈퇴 사유 추가. 2021.05.17 권준석
            contact.KDCE_DropOutReason__c = updatingTContactMap.get(contact.KDCE_ExternalId__c).DropOutReason;
            updateContact.put(contact.Id, contact);
        }
        update updateContact.values();


        // 업데이트 결과 매핑
        Map<String, Id> results = new Map<String, Id>();
        for (Contact sContact : contacts) {
            results.put(sContact.KDCE_ExternalId__c, sContact.Id);
        }

        String contactId = null;
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            contactId = results.get(tContact.ContactExtId);
            tContact.Id = contactId;

            if (isInvalidDropOutContact.containsKey(tContact.ContactExtId) && isInvalidDropOutContact.get(tContact.ContactExtId)) {
                tContact.JobResult = '0301';
            } else tContact.JobResult = '0000';

        }
        return tContacts;
    }

    /**
     * @description IF_MG_DCE_0098 고객 성인인증여부 업데이트
     * @param (List<IF_KDCE_API_BizBase.T_Contact>) tContacts
     *
     * @return : 반환값에 업데이트된 Record 정보 매핑
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> setHAVContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {

        System.debug('List<IF_KDCE_API_BizBase.T_Contact> tContacts : ' + tContacts);

        /* Validation */
        Set<String> contactExtIds = new Set<String>();
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.ContactExtId), LAB_IF_ERR_CONTACT_EXTERNALID_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.HardAgeVerification), LAB_IF_ERR_CONTACT_HARDAGEVERIFICATION_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.HardAVStatusDateChange), LAB_IF_ERR_CONTACT_HARDAVSTATUSDATECHANGE_REQUIRED);
//            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tContact.HardAgeVerificationStatus), '[T_Contact.HardAgeVerificationStatus] is Required');
            contactExtIds.add(tContact.ContactExtId);
        }

        Set<String> validContactExtIds = new Set<String>();
        for (Contact con : [SELECT Id, KDCE_ExternalId__c FROM Contact WHERE KDCE_ExternalId__c IN :contactExtIds]) {
            validContactExtIds.add(con.KDCE_ExternalId__c);
        }

        List<Contact> contacts = new List<Contact>();
        Contact contact = null;

        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            // false로 오면 expired처리
            String avStatus = IF_KDCE_API_BizBase.getValidBoolean(tContact.HardAgeVerification)? 'Verified' : 'Expired';
            if (!validContactExtIds.contains(tContact.ContactExtId)) continue;      // SC에 존재하지 않는 External Id가 들어올 경우 처리
            contact = new Contact(
                    KDCE_ExternalId__c = tContact.ContactExtId,
                    CCR_GlobalAgeVerification__c = IF_KDCE_API_BizBase.getValidBoolean(tContact.HardAgeVerification),
                    CCR_AVStatusDateChange__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.HardAVStatusDateChange),
                    KDCE_HardAgeVerifiedDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tContact.HardAVStatusDateChange),
                    CCR_AgeVerificationStatus__c = avStatus // main flag field
            );

            // 흡연자 확인 여부
            contact.CCR_SmokerNew__c = 'Yes';
            contact.CCR_SmokerDeclarationDate__c = contact.CCR_AVStatusDateChange__c;

            contacts.add(contact);

        }

        if (!contacts.isEmpty()) upsert contacts KDCE_ExternalId__c;

        // 업데이트 결과 매핑
        Map<String, Id> results = new Map<String, Id>();
        for (Contact sContact : contacts) {
            results.put(sContact.KDCE_ExternalId__c, sContact.Id);
        }

        String contactId = null;
        for (IF_KDCE_API_BizBase.T_Contact tContact : tContacts) {
            contactId = results.get(tContact.ContactExtId);
            tContact.Id = contactId;
        }
        return tContacts;
    }

    /**
     * @description Asset Key 기준 Asset 필드 업데이트 IF_MG_DCE_0106
     * @param (List<IF_KDCE_API_BizBase.T_Asset>) tAssets
     *
     * @return : 반환값에 생성,업데이트된 Record 정보 매핑
     */
    public static List<IF_KDCE_API_BizBase.T_Asset> setAssets(List<IF_KDCE_API_BizBase.T_Asset> tAssets) {

        System.debug('List<IF_KDCE_API_BizBase.T_Asset> tAssets : ' + tAssets);

        Map<String, IF_KDCE_API_BizBase.T_Asset> codentiTAssetMap = new Map<String, IF_KDCE_API_BizBase.T_Asset>();
        Map<String, IF_KDCE_API_BizBase.T_Asset> serialTAssetMap = new Map<String, IF_KDCE_API_BizBase.T_Asset>();
        Set<String> registeringContactExtIds = new Set<String>();
        Map<String, Contact> registeringContactMap;
        /* Validation */
        for (IF_KDCE_API_BizBase.T_Asset tAsset : tAssets) {
            // T_Asset 의  는 update key 값임
            IF_KDCE_API_BizBase.validate(false, (Util.isEmpty(tAsset.SerialNumber) &&
                    Util.isEmpty(tAsset.CCR_CodentifyId)), LAB_IF_ERR_ASSET_SERIALNUMBER_CONDENTIFYID_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tAsset.ContactExtId), LAB_IF_ERR_ASSET_CONTACTEXTID_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tAsset.KDCE_ActionType), LAB_IF_ERR_ASSET_ACTIONTYPE_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tAsset.KDCE_ActionDate), LAB_IF_ERR_ASSET_ACTIONDATE_REQUIRED);
            // TODO 해지시에는 단건 해지 할지 권준석 책임 확인후 validation 추가

            if (Util.isNotEmpty(tAsset.SerialNumber)) serialTAssetMap.put(tAsset.SerialNumber.toUpperCase(), tAsset);         // 12자리 Parent Codentify로 들어왔을때
            if (Util.isNotEmpty(tAsset.CCR_CodentifyId)) codentiTAssetMap.put(tAsset.CCR_CodentifyId.toUpperCase(), tAsset);  // 14자리 Codentify로 들어왔을때
            if (tAsset.KDCE_ActionType == 'R') registeringContactExtIds.add(tAsset.ContactExtId);   // 고객 External Id 저장
        }

        if (registeringContactExtIds.size() > 0) {
            List<Contact> registeringContactList = [SELECT Id, KDCE_ExternalId__c FROM Contact WHERE KDCE_ExternalId__c IN :registeringContactExtIds];
            registeringContactMap = new Map<String, Contact>();
            for (Contact con : registeringContactList) {
                registeringContactMap.put(con.KDCE_ExternalId__c, con);
            }
        }

        System.debug('=== serialTAssetMap : ' + serialTAssetMap);
        System.debug('=== codentiTAssetMap : ' + codentiTAssetMap);
        Set<String> availAssetStatus = new Set<String>{'Produced', 'Active'};
        Map<Id, Asset> assetMap = new Map<Id, Asset>([
                SELECT Id, AccountId, ContactId, CCR_CodentifyId__c, SerialNumber, Status, CCR_OriginalAsset__c, CCR_OriginalBox__c
                FROM Asset
                WHERE (SerialNumber IN :serialTAssetMap.keySet() OR CCR_CodentifyId__c IN :codentiTAssetMap.keySet())
                AND SerialNumber != NULL
                AND CCR_CodentifyId__c != NULL
        ]);
        System.debug('=== assetMap : ' + assetMap);
        System.debug('=== serialTAssetMap : ' + serialTAssetMap);

        IF_KDCE_API_BizBase.T_Asset tAsset;
        List<IF_KDCE_API_BizBase.T_Asset> invalidAssetList = new List<IF_KDCE_API_BizBase.T_Asset>();

        // Codentify로만 들어올때 (Serial Number가 안들어올때), Asset Status가 Produced면 해당 Asset과 일치하는 Serial 값을 찾아서 같이 연결시켜줘야한다.
        Set<String> addParentCodentify = new Set<String>();
        Map<String, IF_KDCE_API_BizBase.T_Asset> assetBySerialNum = new Map<String, IF_KDCE_API_BizBase.T_Asset>();
        for (Asset asset : assetMap.values()) {
            System.debug('=== asset.SerialNumber : ' + asset.SerialNumber);
            if (asset.Status == KDCE_GlobalValue.ASSET_STATUS_PRODUCED) {
                /*
                System.debug('=== serialTAssetMap.get(asset.SerialNumber) : ' + serialTAssetMap.get(asset.SerialNumber));
                addParentCodentify.add(asset.SerialNumber);
                assetBySerialNum.put(asset.CCR_CodentifyId__c, serialTAssetMap.get(asset.SerialNumber));
                */

                System.debug('=== codentiTAssetMap : ' + codentiTAssetMap.get(asset.CCR_CodentifyId__c));
                addParentCodentify.add(asset.SerialNumber);
                assetBySerialNum.put(asset.SerialNumber, codentiTAssetMap.get(asset.CCR_CodentifyId__c));
            }
        }
        System.debug('=== codentiTAssetMap : ' + codentiTAssetMap);
        System.debug('=== addParentCodentify : ' + addParentCodentify);
        System.debug('=== assetBySerialNum : ' + assetBySerialNum);

        // 위에서 찾은 Asset과 일치하는 Serial Asset을 Asset Map에 넣어줌
        for (Asset asset : [
                SELECT Id, AccountId, ContactId, CCR_CodentifyId__c, SerialNumber, Status, CCR_OriginalAsset__c, CCR_OriginalBox__c
                FROM Asset
                WHERE SerialNumber IN :addParentCodentify
        ]) {
            assetMap.put(asset.Id, asset);
        }
        System.debug('=== assetMap : ' + assetMap);

        /** validation **/
        if (assetMap.isEmpty()) {
            tAsset = new IF_KDCE_API_BizBase.T_Asset();
            tAsset.JobResult = '0201'; // 존재하지 않는 기기입니다.
            invalidAssetList.add(tAsset);
            return invalidAssetList;
        }
        System.debug('=== assetMap : ' + assetMap);
        System.debug('=== serialTAssetMap : ' + serialTAssetMap);
        System.debug('=== codentiTAssetMap : ' + codentiTAssetMap);
        System.debug('=== assetBySerialNum : ' + assetBySerialNum);
        for (Asset asset : assetMap.values()) {
            /** validation **/
            // Parnet Codentify 인 경우
            if (serialTAssetMap.containsKey(asset?.SerialNumber)) {
                tAsset = serialTAssetMap.get(asset?.SerialNumber);
                if (tAsset.KDCE_ActionType == 'R') {
                    if (asset.Status != 'Produced') {
                        tAsset.JobResult = '0204';  // 홀더와 충전기를 나눠서 등록해주십시오
                        invalidAssetList.add(tAsset);
                        return invalidAssetList;
                    }
                }
            }

            // Codentify 인 경우
            else if (codentiTAssetMap.containsKey(asset.CCR_CodentifyId__c)) {
                tAsset = codentiTAssetMap.get(asset?.CCR_CodentifyId__c);
                if (tAsset.KDCE_ActionType == 'R') {
                    if (asset.ContactId != null) {
                        tAsset.JobResult = '0202';   // 이미 다른 고객에게 등록되어 있는 기기
                        invalidAssetList.add(tAsset);
                        return invalidAssetList;
                    }
                    else if (asset.Status != 'Active' && asset.Status != 'Produced') {
                        tAsset.JobResult = '0203';  // 등록이 불가능한 상태의 기기 입니다.
                        invalidAssetList.add(tAsset);
                        return invalidAssetList;
                    }
                }
            }

            // Parent Codentify이고 Produced로 들어온 경우에 일치하는 다른 Asset Codentify
            else
            {
                System.debug('=== assetBySerialNum : ' + assetBySerialNum);
                tAsset = assetBySerialNum.get(asset?.SerialNumber);
                if (asset.Status == 'Active') continue;    // 입력한 Codentify Asset과 Serial Num이 일치하는 Asset의 Status가 Active면, Link 하지 않음

            }
            System.debug('=== tAsset : ' + tAsset);
            if (tAsset?.KDCE_ActionType == 'R') {
                asset.AccountId = null;
                asset.ContactId = registeringContactMap.get(tAsset.ContactExtId).Id;
                asset.Status = 'Active';
                if (asset.CCR_OriginalAsset__c == null) asset.CCR_OriginalAsset__c = asset.CCR_CodentifyId__c;
                if (asset.CCR_OriginalBox__c == null) asset.CCR_OriginalBox__c = asset.SerialNumber;
            } else if (tAsset?.KDCE_ActionType == 'C') {
                asset.ContactId = null;
                asset.AccountId = System.Label.KDCE_DefaultAccount;
            }
        }
        System.debug('=== assetMap : ' + assetMap);
        if (!assetMap.isEmpty()) update assetMap.values();

        // 업데이트 결과 매핑
        Map<String, Asset> results = new Map<String, Asset>();
        for (Asset sAsset : assetMap.values()) {
            results.put(sAsset.CCR_CodentifyId__c, sAsset);
        }

        String assetId = null;
        String assetIdTmp = null;
        Set<String> assetIdSet = new Set<String>();
        if (tAssets != null) {
            for (IF_KDCE_API_BizBase.T_Asset tAss : tAssets) {
                // 성공
                tAss.JobResult = '0000';

                // 14자리 Condentify ID 정보 준 경우
                if (tAss.CCR_CodentifyId != null && tAss.CCR_CodentifyId != '') {
                    if (results.containsKey(tAss?.CCR_CodentifyId)) assetId = results.get(tAss?.CCR_CodentifyId).Id;
                    else if (results.containsKey(tAss?.CCR_CodentifyId.toUpperCase())) assetId = results.get(tAss?.CCR_CodentifyId.toUpperCase()).Id;
                    tAss.Id = assetId;
                }
                // 12자리 Parent Codentify ID 정보 준 경우
                else {
                    for (Integer idx = 0; idx < results.values().size(); idx++) {
                        tAsset = new IF_KDCE_API_BizBase.T_Asset();
                        if (results.values()[idx].SerialNumber == tAss.SerialNumber) {
                            assetIdTmp = results.values()[idx].Id;
                            assetIdSet.add(assetIdTmp);
                            // tAsset의 Serial Number를 Parent로 하고 업데이트 된 Asset 중 가장 마지막 Asset의 Id만 리턴중
                            assetId = assetIdTmp;
                        }
                    }
                    // 하기와 같이 진행시 업데이트된 모든 값을 넘겨줄 수 있으나 String Id Validation Exception 걸린 상태
                    // assetId = String.join((Iterable<String>)assetIdSet, ', ');
                    tAss.Id = assetId;
                }
            }
        }

        System.debug('=== tAssets : ' + tAssets);
        return tAssets;
    }

    /**
     * @description Ecommerce에서 신규 혹은 수정 주문정보를 수신하여 Order 주문객체에 저정/수정한다. IF_MG_DCE_0094
     * @param List<IF_KDCE_API_BizBase.T_Order> tOrders
     * @return List<IF_KDCE_API_BizBase.T_Order> 생성/수한 주문정보 반환
     */
    public static List<IF_KDCE_API_BizBase.T_Order> setOrdersByMagento(List<IF_KDCE_API_BizBase.T_Order> tOrders) {

        Map<String, Contact>                contactExtIdMap  = new Map<String, Contact>();
        Map<String, KDCE_Order__c>          orderMap         = new Map<String, KDCE_Order__c>();
        Map<String, KDCE_OrderLineItem__c>  orderLineItemMap = new Map<String, KDCE_OrderLineItem__c>();
        Map<String, KDCE_Coupon__c>         couponMap        = new Map<String, KDCE_Coupon__c>();
        Map<String, Product2>               productEANMap    = new Map<String, Product2>();
        Map<String, KDCE_Order__c>          originOrderMap   = new Map<String, KDCE_Order__c>();
        Map<String, Case>                   qureCaseMap      = new Map<String, Case>();

        Map<String, Product2>               productCodeMap   = new Map<String, Product2>();

        /* Validation */
        for (IF_KDCE_API_BizBase.T_Order tOrder : tOrders) {
            // T_TermsAndConditionsHistory Validation
            //tTnCHistories.ContactId required
            // TODO validation 최종 협의 후 반영할 것
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ActionChannel), LAB_IF_ERR_ORDER_ACTIONCHANNEL_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ActionType), LAB_IF_ERR_ORDER_ACTIONTYPE_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ContactExtId), LAB_IF_ERR_ORDER_CONTACTEXTID_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.OrderNo), LAB_IF_ERR_ORDER_ORDERNO_REQUIRED);
            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.OrderType), LAB_IF_ERR_ORDER_ORDERTYPE_REQUIRED);
//            IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrder.ExtOrderId), '[tOrders.ExtOrderId] is Required.');
            contactExtIdMap.put(tOrder.ContactExtId, null);
            orderMap.put(tOrder.OrderNo, null);
            couponMap.put(tOrder.CouponCode, null);
            originOrderMap.put(tOrder.OriginOrderNo, null);
            qureCaseMap.put(tOrder.QureCaseNo, null);

            if(tOrder?.t_OrderItems != null) {
                for (IF_KDCE_API_BizBase.T_OrderLineItem tOrderLineItem : tOrder.t_OrderItems) {
                    productEANMap.put(tOrderLineItem.KDCE_EANCode, null);
                    productCodeMap.put(tOrderLineItem.ProductCode, null);
                    IF_KDCE_API_BizBase.validate(true, Util.isNotEmpty(tOrderLineItem.OrderItemNo), LAB_IF_ERR_ORDERLINEITEM_ORDERITEMNO_REQUIRED);
                    orderLineItemMap.put(tOrderLineItem.OrderItemNo, null);
                }
            }
        }
        //get Contacts by contactExtIds
        if (contactExtIdMap.keySet().size() > 0) {
            for (Contact con : [
                    SELECT Id,RecordTypeId, KDCE_ExternalId__c, KDCE_fm_ConsumerType__c, KDCE_TnCVersion__c
                    FROM Contact
                    WHERE KDCE_ExternalId__c IN :contactExtIdMap.keySet()
            ])
            {
                contactExtIdMap.put(con.KDCE_ExternalId__c, con);
            }
        }
        //get Coupon by CouponCode
        if (couponMap.keySet().size() > 0) {
            for (KDCE_Coupon__c coupon : [
                    SELECT Id, Name, RecordTypeId, CouponCode__c
                    FROM KDCE_Coupon__c
                    WHERE CouponCode__c IN :couponMap.keySet()
            ])
            {
                couponMap.put(coupon.CouponCode__c?.toUpperCase(), coupon);
            }
        }
        // get Product by ProductCode
        if (productEANMap.keySet().size() > 0) {
            for (Product2 prod : [
                    SELECT Id, Name, KDCE_EANCode__c, CCR_Category__c
                    FROM Product2
                    WHERE KDCE_EANCode__c IN :productEANMap.keySet()
                    ORDER BY CreatedDate
            ])
            {
                productEANMap.put(prod.KDCE_EANCode__c, prod);
            }
        }
        // get Product by ProductCode
        if (productCodeMap.keySet().size() > 0) {
            for (Product2 prod : [
                    SELECT Id, Name, KDCE_EANCode__c, CCR_Category__c, ProductCode
                    FROM Product2
                    WHERE ProductCode IN :productCodeMap.keySet()
                    ORDER BY CreatedDate
            ])
            {
                productCodeMap.put(prod.ProductCode, prod);
            }
        }
        // get Order Item by Entity
        if (orderLineItemMap.keySet().size() > 0) {
            for (KDCE_OrderLineItem__c oli : [
                    SELECT Id, Order__c, EntityId__c
                    FROM KDCE_OrderLineItem__c
                    WHERE EntityId__c IN :orderLineItemMap.keySet()
            ])
            {
                orderLineItemMap.put(oli.EntityId__c, oli);
            }
        }

        /*
        // get Origin Order by OriginOrderNo
        if (originOrderMap.keySet().size() > 0) {
            for (KDCE_Order__c originOrder : [
                    SELECT Id, OrderNo__c
                    FROM KDCE_Order__c
                    WHERE OrderNo__c IN :originOrderMap.keySet()
            ])
            {
                originOrderMap.put(originOrder.OrderNo__c, originOrder);
            }
        }
        */
        // get QURE Case by QURE Case Number
        if (qureCaseMap.keySet().size() > 0) {
            for (Case qureCase : [
                    SELECT Id, CaseNumber
                    FROM Case
                    WHERE Id IN :qureCaseMap.keySet()
            ])
            {
                qureCaseMap.put(qureCase.Id, qureCase);
            }
        }

        KDCE_Order__c   order               = null;
        KDCE_OrderLineItem__c orderLineItem = null;
        for (IF_KDCE_API_BizBase.T_Order tOrder : tOrders) {

            IF_KDCE_API_BizBase.validate(TRUE, contactExtIdMap.containsKey(tOrder.ContactExtId) && Util.isNotEmpty(contactExtIdMap.get(tOrder.ContactExtId)), '[tOrders.ContactExtId] does not match or exist. please check ContactExtId.');

            order = new KDCE_Order__c(
                    OrderNo__c = tOrder.OrderNo,
                    Contact__c = contactExtIdMap.get(tOrder.ContactExtId).Id
            );

            switch on tOrder.OrderType {
                when 'ZTA' {
                    order.RecordTypeId = RT_Order_Normal;
                }
                when 'ZTI' {
                    order.RecordTypeId = RT_Order_TRADEIN;
                }
                when 'ZRNNEW' {
                    order.RecordTypeId = RT_Order_Rental;
                }
                when 'ZRN' {
                    order.RecordTypeId = RT_Order_Rental;
                }
                when 'ZRA' {
                    order.RecordTypeId = RT_Order_Replace;
                }
//                // POS용
//                when somethingPOS {
//                    order.RecordTypeId = RT_Order_Upgrade;
//                }
                when else {
                    IF_KDCE_API_BizBase.validate(true, true, LAB_IF_ERR_ORDER_ORDERTYPE_INVALID);
                }
            }

            order.ActionChannel__c = tOrder.ActionChannel;
            order.ActionType__c = tOrder.ActionType;
            order.OrderType__c = tOrder.OrderType; // PickList Validation
            if (Util.isNotEmpty(tOrder.ContactExtId)) order.CustomerId__c = tOrder.ContactExtId;
            // UTC +0
            if (Util.isNotEmpty(tOrder.OrderDate)) order.OrderDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tOrder.OrderDate);
            if (Util.isNotEmpty(tOrder.OriginOrderNo)) order.OriginOrderNo__c = tOrder.OriginOrderNo;
            //if (Util.isNotEmpty(tOrder.OriginOrderNo)) order.OriginOrder__c = originOrderMap.get(tOrder.OriginOrderNo)?.Id;
            if (Util.isNotEmpty(tOrder.QureCaseNo)){
                order.QureCaseNo__c = tOrder.QureCaseNo;
                order.QureCase__c = qureCaseMap.get(tOrder.QureCaseNo)?.Id;
            }
            if (Util.isNotEmpty(tOrder.OrderReason)) order.OrderReason__c = tOrder.OrderReason;
            if (Util.isNotEmpty(tOrder.OrderCurrency)) order.Currency__c = tOrder.OrderCurrency;
            if (Util.isNotEmpty(tOrder.CustomerName)) order.CustomerName__c = tOrder.CustomerName;
            if (Util.isNotEmpty(tOrder.CustomerEmail)) order.CustomerEmail__c = tOrder.CustomerEmail;
            if (Util.isNotEmpty(tOrder.OrderStatus)) order.OrderStatus__c = tOrder.OrderStatus;
            if (Util.isNotEmpty(tOrder.OrderState)) order.OrderState__c = tOrder.OrderState;
            if (Util.isNotEmpty(tOrder.RentalId)) order.RentalId__c = tOrder.RentalId;
            if (Util.isNotEmpty(tOrder.RentalStartDate)) order.RentalStartDate__c = IF_KDCE_API_BizBase.convertStringToDate(tOrder.RentalStartDate);
            if (Util.isNotEmpty(tOrder.RentalEndDate)) order.RentalEndDate__c = IF_KDCE_API_BizBase.convertStringToDate(tOrder.RentalEndDate);
            if (Util.isNotEmpty(tOrder.RentalStatus)) order.RentalStatus__c = tOrder.RentalStatus;
//          if (Util.isNotEmpty(tOrder.ShippingAddressName)) order.ShippingAddressName__c = tOrder.ShippingAddressName;
            if (Util.isNotEmpty(tOrder.ShippingAddress1)) order.ShippingAddress1__c = tOrder.ShippingAddress1;
            if (Util.isNotEmpty(tOrder.ShippingAddress2)) order.ShippingAddress2__c = tOrder.ShippingAddress2;
            if (Util.isNotEmpty(tOrder.ShippingState)) order.ShippingState__c = tOrder.ShippingState;
            if (Util.isNotEmpty(tOrder.ShippingCity)) order.ShippingCity__c = tOrder.ShippingCity;
            if (Util.isNotEmpty(tOrder.ShippingStreet)) order.ShippingStreet__c = tOrder.ShippingStreet;
            if (Util.isNotEmpty(tOrder.ShippingPostalCode)) order.ShippingPostalCode__c = tOrder.ShippingPostalCode;
            if (Util.isNotEmpty(tOrder.ShippingCountry)) order.ShippingCountryCode__c = tOrder.ShippingCountry;
            if (Util.isNotEmpty(tOrder.ShippingPhone)) order.ShippingPhone__c = tOrder.ShippingPhone;
            if (Util.isNotEmpty(tOrder.ShippingTax)) order.ShippingTax__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.ShippingTax);
            if (Util.isNotEmpty(tOrder.ShippingGrossPrice)) order.ShippingGrossPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.ShippingGrossPrice);
            if (Util.isNotEmpty(tOrder.ShippingItemId)) order.ShippingItemId__c = tOrder.ShippingItemId;
            if (Util.isNotEmpty(tOrder.ShippingMethod)) order.ShippingMethod__c = tOrder.ShippingMethod;
            if (Util.isNotEmpty(tOrder.GrossPrice)) order.GrossPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.GrossPrice);
            if (Util.isNotEmpty(tOrder.Discount)) order.Discount__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.Discount);
//            if (Util.isNotEmpty(tOrder.TaxBasis)) order.TaxBasis__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.TaxBasis);
//            if (Util.isNotEmpty(tOrder.Tax)) order.Tax__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.Tax);
            if (Util.isNotEmpty(tOrder.NetPrice)) order.NetPrice__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.NetPrice);
//            if (Util.isNotEmpty(tOrder.PriceAfterRental)) order.PriceAfterRental__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.PriceAfterRental);
            if (Util.isNotEmpty(tOrder.PaymentAmount)) order.PaymentAmount__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.PaymentAmount);
            if (Util.isNotEmpty(tOrder.PaymentMethod)) order.PaymentMethod__c = tOrder.PaymentMethod;
            if (Util.isNotEmpty(tOrder.PaymentProcessorId)) order.PaymentProcessorId__c = tOrder.PaymentProcessorId;
            if (Util.isNotEmpty(tOrder.PaymentTransactionId)) order.PaymentTransactionId__c = tOrder.PaymentTransactionId;
            if (Util.isNotEmpty(tOrder.PromotionId)) order.PromotionId__c = tOrder.PromotionId;
            if (Util.isNotEmpty(tOrder.PromotionName)) order.PromotionName__c = tOrder.PromotionName;
            if (Util.isNotEmpty(tOrder.CouponCode)) order.CouponCode__c = tOrder.CouponCode;
            if (Util.isNotEmpty(tOrder.CouponCode)) order.Coupon__c = couponMap.get(tOrder.CouponCode?.toUpperCase())?.Id;
//            if (Util.isNotEmpty(tOrder.Channel)) order.Channel__c = tOrder.Channel;
            if (Util.isNotEmpty(tOrder.ExtOrderId)) order.EntityId__c = tOrder.ExtOrderId;
            if (Util.isNotEmpty(tOrder.CollectCodentify)) order.CollectCodentify__c = tOrder.CollectCodentify;
            if (Util.isNotEmpty(tOrder.ShipStatus)) order.ShipStatus__c = tOrder.ShipStatus;
            if (Util.isNotEmpty(tOrder.ShipStatusDate)) order.ShipStatusDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tOrder.ShipStatusDate);
            if (Util.isNotEmpty(tOrder.ShipQuantity)) order.ShipQuantity__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.ShipQuantity);
            if (Util.isNotEmpty(tOrder.TrackingNo)) order.TrackingNo__c = tOrder.TrackingNo;
            if (Util.isNotEmpty(tOrder.TrackingUrl)) order.TrackingUrl__c = tOrder.TrackingUrl;
            if (Util.isNotEmpty(tOrder.ShippingMessage)) order.ShippingMessage__c = tOrder.ShippingMessage;
            if (Util.isNotEmpty(tOrder.ShippingStartDate)) order.ShippingStartDate__c = IF_KDCE_API_BizBase.convertStringToDate(tOrder.ShippingStartDate);
            if (Util.isNotEmpty(tOrder.ShippingEndDate)) order.ShippingEndDate__c = IF_KDCE_API_BizBase.convertStringToDate(tOrder.ShippingEndDate);
            if (Util.isNotEmpty(tOrder.ReturnStartDate)) order.ReturnStartDate__c = IF_KDCE_API_BizBase.convertStringToDate(tOrder.ReturnStartDate);
            if (Util.isNotEmpty(tOrder.ReturnEndDate)) order.ReturnEndDate__c = IF_KDCE_API_BizBase.convertStringToDate(tOrder.ReturnEndDate);
            if (Util.isNotEmpty(tOrder.CollectionStatus)) {     // collection_success, collection_failed, collection
                order.CollectionStatus__c = tOrder.CollectionStatus;
            }
            if (Util.isNotEmpty(tOrder.CollectionStatusDate)) {
                // UTC +0
                order.CollectionStatusDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tOrder.CollectionStatusDate);
                if (tOrder.CollectionStatus == 'collection_success' || tOrder.CollectionStatus == 'collection_failed') order.CollectionEndDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tOrder.CollectionStatusDate); // 성공시, 해당 Status 날짜를 End Date에 넣는다.
//                order.CollectionEndDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tOrder.CollectionStatusDate); // 성공시, 해당 Status 날짜를 End Date에 넣는다.
            }
            if (Util.isNotEmpty(tOrder.CollectionStartDate)) {
                // UTC +0
                order.CollectionStartDate__c = IF_KDCE_API_BizBase.convertStringToDatetimeGMT(tOrder.CollectionStartDate);
            }
//            if (Util.isNotEmpty(tOrder.CollectionStartDate) && Util.isEmpty(tOrder.CollectionStatus)) {
//                order.CollectionStatus__c = 'processing';   // Collection Start Date 들어오면, 추심 시작이라고 간주하고 상태값 processing으로 변경    (2021.07.05 지현 수정)
//            }
            if (Util.isNotEmpty(tOrder.CollectionAmount)) order.CollectionAmount__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrder.CollectionAmount);
            // Order Type이 forward가 아니면, Shipping Date가 들어가면 안된다.
            if (order.OrderReason__c != KDCE_GlobalValue.ORDER_REASON_FORWARD) {
                order.ShippingStartDate__c = null;
                order.ShippingEndDate__c = null;
            }

            System.debug('=== order : ' + order);
            orderMap.put(order.OrderNo__c, order);
        }

        upsert orderMap.values() OrderNo__c;

        // get Origin Order by OriginOrderNo
        if (originOrderMap.keySet().size() > 0) {
            for (KDCE_Order__c originOrder : [
                    SELECT Id, OrderNo__c
                    FROM KDCE_Order__c
                    WHERE OrderNo__c IN :originOrderMap.keySet()
            ])
            {
                originOrderMap.put(originOrder.OrderNo__c, originOrder);
            }
        }

        // Original Order 처리
        for(KDCE_Order__c header : orderMap.values()){
            if(header.OriginOrderNo__c != null) header.OriginOrder__c = originOrderMap.get(header.OriginOrderNo__c)?.Id;
        }

        //Accessory 제품 카테고리 값
        Set<String> accessoryCategorySet = new Set<String>();
        accessoryCategorySet.add('M0303');
        accessoryCategorySet.add('M0304');
        accessoryCategorySet.add('M0308');
        accessoryCategorySet.add('M0306');
        accessoryCategorySet.add('M0307');
        accessoryCategorySet.add('M0320');
        accessoryCategorySet.add('M0322');
        accessoryCategorySet.add('M0321');
        accessoryCategorySet.add('M0309');
        accessoryCategorySet.add('M0323');
        accessoryCategorySet.add('M0390');

        KDCE_Order__c header = null;
        Decimal headerSupply;
        Decimal headerTax;

        for (IF_KDCE_API_BizBase.T_Order tOrd : tOrders) {
            if(tOrd?.t_OrderItems != null) {

                header = orderMap.get(tOrd.OrderNo);
                headerSupply = 0;
                headerTax = 0;

                for (IF_KDCE_API_BizBase.T_OrderLineItem tOrderLineItem : tOrd.t_OrderItems) {

                    orderLineItem = new KDCE_OrderLineItem__c(
                            Order__c = header.Id
                    );

                    // Order Line Item 에서 로직 처리를 위해 Header에 있는 필드와 동기화 시켜줌
                    orderLineItem.OrderType__c = header.OrderType__c;
                    orderLineItem.OrderReason__c = header.OrderReason__c;
                    orderLineItem.OrderStatus__c = header.OrderStatus__c;
                    orderLineItem.CollectionStatus__c = header.CollectionStatus__c;

                    KDCE_OrderLineItem__c existingOrderLineItem = orderLineItemMap.get(tOrderLineItem.OrderItemNo);
                    if (existingOrderLineItem != null && existingOrderLineItem.Order__c != null) {
                        orderLineItem.Order__c = existingOrderLineItem.Order__c;
                    }
                    if (Util.isNotEmpty(tOrderLineItem.OrderItemNo)) orderLineItem.EntityId__c = tOrderLineItem.OrderItemNo;

                    // ProductCode Mapping. 2021.07.08 권준석
                    if (Util.isNotEmpty(tOrderLineItem.ProductCode)) {
                        if (Util.isNotEmpty(tOrderLineItem.KDCE_EANCode)) orderLineItem.EANCode__c = tOrderLineItem.KDCE_EANCode;
                        orderLineItem.Product__c = productCodeMap.get(tOrderLineItem.ProductCode)?.Id;
                        String productCategory = productCodeMap.get(tOrderLineItem.ProductCode)?.CCR_Category__c;
                        // Product Category가 Accessory 관련 코드 이거나 Product가 없을 경우
                        if (accessoryCategorySet.contains(productCategory) || orderLineItem.Product__c == null) orderLineItem.IsAccessory__c = TRUE;
                        // Product Category가 Device 관련 코드 이거나 Product가 없을 경우 by MZ (2021-08-25)
                        if (productCategory == 'M0401' || orderLineItem.Product__c == null) orderLineItem.IsDevice__c = true;
                    }
                    else if (Util.isNotEmpty(tOrderLineItem.KDCE_EANCode)) {
                        orderLineItem.EANCode__c = tOrderLineItem.KDCE_EANCode;
                        orderLineItem.Product__c = productEANMap.get(tOrderLineItem.KDCE_EANCode)?.Id;
                        String productCategory = productEANMap.get(tOrderLineItem.KDCE_EANCode)?.CCR_Category__c;
                        // Product Category가 Accessory 관련 코드 이거나 Product가 없을 경우
                        if (accessoryCategorySet.contains(productCategory) || orderLineItem.Product__c == null) orderLineItem.IsAccessory__c = TRUE;
                        // Product Category가 Accessory 관련 코드 이거나 Product가 없을 경우 by MZ (2021-08-25)
                        if (productCategory == 'M0401' || orderLineItem.Product__c == null) orderLineItem.IsDevice__c = true;
                    }

                    // TODO 현재 업데이트 되는 케이스에 대한 것만 고려되어있음. 인서트할 때 Product를 어떻게 처리할 것인지 결정 필요
                    if (Util.isNotEmpty(tOrderLineItem.Codentify)) orderLineItem.Codentify__c = tOrderLineItem.Codentify; // Codentify 있을 경우 Product 매핑은 정확한 Product 및 Asset으로 OrderItem Trigger에서 진행

                    if (Util.isNotEmpty(tOrderLineItem.ProductQuantity)) orderLineItem.ProductQuantity__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductQuantity);
                    if (Util.isNotEmpty(tOrderLineItem.ProductIGrossPrice)) orderLineItem.ProductGrossPrice__c = Math.round(IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductIGrossPrice));
                    if (Util.isNotEmpty(tOrderLineItem.ProductItemDiscount)) orderLineItem.ProductItemDiscount__c = Math.round(IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductItemDiscount));
                    if (Util.isNotEmpty(tOrderLineItem.ProductTaxBasis)) orderLineItem.ProductTaxBasis__c = Math.round(IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductTaxBasis));
                    if (Util.isNotEmpty(tOrderLineItem.ProductTaxRate)) orderLineItem.ProductTaxRate__c = Math.round(IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductTaxRate));
                    if (Util.isNotEmpty(tOrderLineItem.ProductTax)) orderLineItem.ProductTax__c = Math.round(IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductTax));
                    if (Util.isNotEmpty(tOrderLineItem.ProductNetPrice)) orderLineItem.ProductNetPrice__c = Math.round(IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ProductNetPrice));
                    if (Util.isNotEmpty(tOrderLineItem.PriceAfterRental)) orderLineItem.PriceAfterRental__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.PriceAfterRental);
                    if (Util.isNotEmpty(tOrderLineItem.FullProductId)) orderLineItem.FullProductId__c = tOrderLineItem.FullProductId;
//                if (Util.isNotEmpty(tOrderLineItem.ShipStatus)) orderLineItem.ShipStatus__c = tOrderLineItem.ShipStatus; // 제외검토
//                if (Util.isNotEmpty(tOrderLineItem.ShipStatusDate)) orderLineItem.ShipStatusDate__c = IF_KDCE_API_BizBase.convertStringToDatetime(tOrderLineItem.ShipStatusDate); // 변경검토
//                if (Util.isNotEmpty(tOrderLineItem.ShipQuantity)) orderLineItem.ShipQuantity__c = IF_KDCE_API_BizBase.convertStringToDecimal(tOrderLineItem.ShipQuantity); // 변경검토
//                if (Util.isNotEmpty(tOrderLineItem.TrackingNo)) orderLineItem.TrackingNo__c = tOrderLineItem.TrackingNo; // 변경검토
//                if (Util.isNotEmpty(tOrderLineItem.TrackingUrl)) orderLineItem.TrackingUrl__c = tOrderLineItem.TrackingUrl; // 변경검토

                    // 공급가액, 부가세 계산
                    orderLineItem.ProductTax__c = 0;
                    orderLineItem.ProductSupplyPrice__c = 0;

                    if(orderLineItem.ProductNetPrice__c != null){
                        orderLineItem.ProductTax__c = Math.round(orderLineItem.ProductNetPrice__c / 11);
                        orderLineItem.ProductSupplyPrice__c = orderLineItem.ProductNetPrice__c - orderLineItem.ProductTax__c;
                    }

                    headerTax += orderLineItem.ProductTax__c;
                    headerSupply += orderLineItem.ProductSupplyPrice__c;

                    orderLineItemMap.put(orderLineItem.EntityId__c, orderLineItem);
                }
                header.Tax__c = headerTax;
                header.SupplyPrice__c = headerSupply;
            }
        }

        System.debug('upsert values test>>' + orderLineItemMap.values());

        upsert orderLineItemMap.values() EntityId__c;

        // Header Update
        upsert orderMap.values() OrderNo__c;

        // 업데이트 결과 매핑
        Id currentOrderId;
        Map<Id, List<Id>> orderIdMap = new Map<Id, List<Id>>();
        List<Id> orderLineItemIds;
        if (orderMap.values().size() > 0) {
            for (KDCE_Order__c sOrder : orderMap.values()) {
                currentOrderId = sOrder.Id;
                orderLineItemIds = new List<Id>();
                for (KDCE_OrderLineItem__c sOrderLineItem : orderLineItemMap.values()) {
                    if(sOrderLineItem.Order__c == currentOrderId) orderLineItemIds.add(sOrderLineItem.Id);
                }
                orderIdMap.put(sOrder.Id, orderLineItemIds);
            }
        }

        List<IF_KDCE_API_BizBase.T_Order> tOrderList = new List<IF_KDCE_API_BizBase.T_Order>();
        IF_KDCE_API_BizBase.T_Order tOrder;

        for (Id id : orderIdMap.keySet()) {
            tOrder = new IF_KDCE_API_BizBase.T_Order();
            tOrder.Id = id;
            List<IF_KDCE_API_BizBase.T_OrderLineItem> tOrderLineItems = new List<IF_KDCE_API_BizBase.T_OrderLineItem>();
            IF_KDCE_API_BizBase.T_OrderLineItem tOrderLineItem;
            for (Id orderLineItemId : orderIdMap.get(id)) {
                tOrderLineItem = new IF_KDCE_API_BizBase.T_OrderLineItem();
                tOrderLineItem.Id = orderLineItemId;
            }
            tOrder.t_OrderItems = tOrderLineItems;

            tOrderList.add(tOrder);
        }

        return tOrderList;
    }

}