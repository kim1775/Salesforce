/****************************************************************************************
  * @filename      : IF_KDCE_API_BizBase
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/23 5:20 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_KDCE_API_BizBase_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/23 5:20 오후     i2max_shlee       Create
    0.2     2021/03/05              i2max_Sukun       Update
    0.3     2021/04/01              i2max_Sukun       Update
****************************************************************************************/
public virtual without sharing class IF_KDCE_API_BizBase extends IF_Base {
    public static Boolean isInvokedFromInterface = FALSE;
    static {
        if (String.valueOf(URL.getCurrentRequestUrl()).toLowerCase().contains('/services/apexrest')) {
            isInvokedFromInterface = TRUE;
        }
    }


    /**
     * @description Ecommerce(Magento : IF_MG_DCE_0092) 에서 Product 정보를 수신하여 Product( Product2 ) 객체에 업데이트 한다.
     * @param IF_KDCE_API_BizBase.T_Product tProducts
     * @return List<IF_KDCE_API_BizBase.T_Product> 업데이트한 Product 정보
     */
    public static List<IF_KDCE_API_BizBase.T_Product> setProductsByMagento(List<IF_KDCE_API_BizBase.T_Product> tProducts) {
        return IF_KDCE_API_BizService.setProductsByMagento(tProducts);
    }

    /**
     * @description Offline(Fujitsu POS : IF_POS_DCE_0093) 에서 Product 정보를 수신하여 Product( Product2 ) 객체에 업데이트 한다.
     * @param IF_KDCE_API_BizBase.T_Product tProducts
     * @return List<IF_KDCE_API_BizBase.T_Product> 업데이트한 Product 정보
     */
    public static List<IF_KDCE_API_BizBase.T_Product> setProductsByPOS(List<IF_KDCE_API_BizBase.T_Product> tProducts) {
        return IF_KDCE_API_BizService.setProductsByPOS(tProducts);
    }

    /**
     * @description POS Contact 조회 IF_POS_DCE_0143
     * @param IF_KDCE_API_BizBase.T_Contact tContact (Name + Phone Combination)
     * @return : 반환값에 조회된 Contact List
     */
    public static List<IF_KDCE_API_BizBase.T_POS_Contact> getContactsByPOS(IF_KDCE_API_BizBase.T_POS_Contact tContact) {
        return IF_KDCE_API_BizService.getContactsByPOS(tContact);
    }

    /**
     * @description Magento Contact 조회 IF_MG_DCE_0097
     * @param IF_KDCE_API_BizBase.T_Contact tContact (Name + Phone Combination OR external ID)
     * @return : 반환값에 조회된 Contact List
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> getContactsByMagento(IF_KDCE_API_BizBase.T_Contact tContact) {
        return IF_KDCE_API_BizService.getContactsByMagento(tContact);
    }
    /**
     * @description Contact List 생성 및 수정 IF_MG_DCE_0096
     * @param List<IF_KDCE_API_BizBase.T_Contact> tContacts
     * @return List<IF_KDCE_API_BizBase.T_Contact> upsert한 Contact 정보
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> setContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {
        return IF_KDCE_API_BizService.setContacts(tContacts);
    }
    /**
     * @description 휴면고객 복구 IF_MG_DCE_0101
     * @param List<IF_KDCE_API_BizBase.T_Contact> tContacts
     * @return List<IF_KDCE_API_BizBase.T_Contact> update한 Contact 정보
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> restoreDormantContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {
        return IF_KDCE_API_BizService.restoreDormantContacts(tContacts);
    }
    /**
     * @description 고객 탈퇴처리 관련내용 업데이트 IF_MG_DCE_0103
     * @param List<IF_KDCE_API_BizBase.T_Contact> tContacts
     * @return List<IF_KDCE_API_BizBase.T_Contact> update한 Contact 정보
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> setDropoutContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {
        return IF_KDCE_API_BizService.setDropoutContacts(tContacts);
    }
    /**
     * @description 고객 성인인증여부 업데이트 IF_MG_DCE_0098
     * @param List<IF_KDCE_API_BizBase.T_Contact> tContacts
     * @return List<IF_KDCE_API_BizBase.T_Contact> update한 Contact 정보
     */
    public static List<IF_KDCE_API_BizBase.T_Contact> setHAVContacts(List<IF_KDCE_API_BizBase.T_Contact> tContacts) {
        return IF_KDCE_API_BizService.setHAVContacts(tContacts);
    }
    /**
     * @description Asset List 업데이트 (고객 기기등록/수정) IF_MG_DCE_0106
     * @param List<IF_KDCE_API_BizBase.T_Asset> tAssets
     * @return List<IF_KDCE_API_BizBase.T_Asset> update Asset 정보
     */
    public static List<IF_KDCE_API_BizBase.T_Asset> setAssets(List<IF_KDCE_API_BizBase.T_Asset> tAssets) {
        return IF_KDCE_API_BizService.setAssets(tAssets);
    }

    /**
     * @description Ecommerce에서 T&C 동의정보를 수신하여 T&C History( KDCE_TnCHistory__c ) 객체에 저장한다. IF_MG_DCE_0099
     * @param List<IF_KDCE_API_BizBase.T_TnCHistory> tTnCHistories
     * @return List<IF_KDCE_API_BizBase.T_TnCHistory> 생성한 T&C History 반환
     */
//    public static List<IF_KDCE_API_BizBase.T_TnCHistory> setTnCHistories(List<IF_KDCE_API_BizBase.T_TnCHistory> tTnCHistories) {
//        return IF_KDCE_API_BizService.setTnCHistories(tTnCHistories);
//    }

    /**
     * @description Ecommerce에서 신규 혹은 수정 주문정보를 수신하여 Order 주문객체에 저정/수정한다. IF_MG_DCE_0094
     * @param List<IF_KDCE_API_BizBase.T_Order> tOrders
     * @return List<IF_KDCE_API_BizBase.T_Order> 생성/수한 주문정보 반환
     */
    public static List<IF_KDCE_API_BizBase.T_Order> setOrdersByMagento(List<IF_KDCE_API_BizBase.T_Order> tOrders) {
        return IF_KDCE_API_BizService.setOrdersByMagento(tOrders);
    }

    /**
     * @description POS에서 신규 혹은 수정 주문정보를 수신하여 Order 주문객체에 저정/수정한다. IF_POS_DCE_0129
     * @param List<IF_KDCE_API_BizBase.T_Order> tOrders
     * @return List<IF_KDCE_API_BizBase.T_Order> 생성/수한 주문정보 반환
     */
    public static List<IF_KDCE_API_BizBase.T_Order> setOrdersByPOS(List<IF_KDCE_API_BizBase.T_Order> tOrders) {
        return IF_KDCE_API_BizService.setOrdersByPOS(tOrders);
    }

    /* Value Object */
    public virtual class T_Product {
        public String Id;
        public String Name;
        public String CCR_ProductName;      //External Id Ecommerce
        public String KDCE_EANCode;         //External Id POS
        public String ProductCode;
        public String CCR_Category;
        public String CCR_Differentiator;
        public String CCR_OriginalDesignMarket;
        public String CCR_SubMarket;
        public String CCR_Version;
        public String KDCE_RequestChannel;
        //Ecommerce(Magento)
        public String KDCE_MG_Id;
        public String KDCE_MG_SKU;
        public String KDCE_MG_ProductName_ko;
        public String KDCE_MG_Price;
        public String KDCE_MG_TaxClass;
        public String KDCE_MG_Visiblity;
        public String KDCE_MG_ManufactureCountry;
        public String KDCE_MG_Color;
        public String KDCE_MG_Weight;
        public String KDCE_MG_Material;
        public String KDCE_MG_Image;
        public String KDCE_MG_VideoURL;
        public String KDCE_MG_VideoTitle;
        public String KDCE_MG_VideoDescription;
        public String KDCE_MG_VideoPreviewImage;
        public String KDCE_MG_MasterProductId;
        public String KDCE_MG_ModelName_en;
        public String KDCE_MG_Content;
        public String KDCE_MG_Description;
        public String KDCE_MG_Category;
        public String KDCE_MG_Unit;
        public String KDCE_MG_ModelGroup;
        public String KDCE_MG_Type;
        public String KDCE_MG_Version;
        //Offline(POS)
        public String KDEC_POS_ProductName;
        public String KDEC_POS_ProductDescription;
        public String KDEC_POS_ProductCategory;

    }

    /**
     * POS IF용 Contact VO
     */
    public virtual class T_POS_Contact {
        //검색필드
        public String Mobile4Digit;		//MobilePhone; 4자리 검색전화 번호
        //검색 결과값
        public String ContactExtId;		//KDCE_ExternalId;
        public String NameMask;			//Name; 심*지
        public String MobilePhoneMask;  //KDCE_PhoneMask__c; 010-****-1234
        public String BirthDateMask;    //fm_BirthDate; 1999-**-**
//        public String Gender;           //gender; M/F/U
        public String ConsumerType;     //KDCE_fm_ConsumerType +'-'+ KDCE_LASLAU;
        public String CreatedDate;		//CreatedDate;
        public String LastModifiedDate;	//LastModifiedDate;
    }

    public virtual class T_Contact {

        //검색필드
        public String ContactExtId;				            //KDCE_ExternalId;
        public String Name;				                    //KDCE_Name;
        public String Mobile4Digit;				            //MobilePhone; 4자리 검색전화 번호
        public String LoginType;                            //로그인 타입 : L(Login), K(KakaoLogin), N(Search)

        // Return 용 필드
        public String RequestResult;                        // 요청에 대한 결과가 필요할 경우 사용
        public String ResultFailReason;                     // 처리가 불가할 경우 메시지
        public String QUREAccessToken;
        public String QUREAccessTokenExpireTime;

        public String Id;				                    //Id;
        public String LastName;				                //LastName;
//        public String Phone;				                //Phone;
        public String ConsumerUID;				            //CCR_ConsumerUID;
        public String NamePNKey;				            //KDCE_NamePNKey;
        public String Salutation;				            //Salutation;
        public String Gender;				                //CCR_Gender;
        public String Birthdate;                            //BirthDate
        public String MobileCarrier;				        //KDCE_MobileCarrier;
        public String MobilePhone;				            //Phone; KDCE_PNKey;
        public String MobilePhoneMask;				        //KDCE_PhoneMask;
        public String Email;                                //Email;
        public String EmailMask;                            //EmailMask;
        public String Address1;                             //FirstAddressv1;
        public String Address2;                             //FirstAddressv2;
        public String State;                                //MailingState;
        public String City;                                 //MailingCity;
        public String PostalCode;                           //MailingPostalCode;
        public String MailingState;				            //MailingState;
        public String MailingCity;				            //MailingCity;
        public String MailingStreet;				        //MailingStreet;
        public String MailingPostalCode;				    //MailingPostalCode;
        public String MailingCountry;				        //MailingCountry;
        public String RegistrationChannel;				    //KDCE_RegistrationChannel;
        public String RegistrationConsumerID;				//CCR_RegistrationConsumerID;
        public String RegistrationDate;                     //필드 생성 필요
//        public String QrCodeUrl;				            //KDCE_QrCodeUrl;
        public String HasRegistedUsingKakaoId;				//KDCE_HasRegistedUsingKakaoId;
        public String JoinedPMKChannel;				        //KDCE_JoinedPMKChannel;
        public String KakaoId;				                //KDCE_KakaoId;
        public String DatabaseOptin;				        //CCR_DatabaseOptin;
        public String InformationOptIn;                     //KDCE_InformationOptIn;
        public String MarketingOptIn;				        //KDCE_MarketingOptIn;
        public String CarePlusStatus;				        //CCR_CarePlusStatus;
        public String CarePlusDueDate;				        //CCR_CarePlusDueDate;
        public String QoachProgram;				            //CCR_QoachProgram;
        public String ConsumerType;				            //KDCE_fm_ConsumerType;
        public String LASLAU;				                //KDCE_LASLAU;
        public String Subtype;				                //CAA_SubType;
        public String Stage;				                //CAA_Stage;
        public String Smoker;				                //CCR_Smoker;
        public String SmokerDeclarationDate;				//CCR_SmokerDeclarationDate;
        public String HardAgeVerification;				    //CCR_GlobalAgeVerification;
        public String HardAgeVerificationStatus;			//CCR_AgeVerificationStatus;
        public String HardAVStatusDateChange;				//CCR_AVStatusDateChange;
        public String HardAgeVerifiedDate;			        //KDCE_HardAgeVerifiedDate__c;
        public String IsHardAgeReVerification;				//KDCE_fm_IsAgeReVerification;
        public String SoftAgeVerified;				        //CCR_SoftAgeVerified;
        public String SoftAgeVerifiedDate;				    //CCR_SoftAgeVerifiedDate;
        public String MGMCode;				                //KDCE_MGMCode;
        public String PersonalInfoValidityPeriod;			//KDCE_PersonalInfoValidityPeriod; 개인정보 보유 유효기간
        public String RestoreDormantRequest;                //KDCE_IsRequestRestoreDormant;
        public String IsDormantMailSend;				    //KDCE_fm_IsDormantMailSend;
        public String IsDormant;				            //KDCE_fm_IsDormant;
        public String ConvertDormantDate;				    //KDCE_ConvertDormantDate;
        public String AvailDropout;                         //KDCE_fm_AvailDropout;
        public String DropOutRequestDate;                   //KDCE_DropoutRequestDate;
        public String DropOutRequest;                       //KDCE_IsRequestDropout;
        public String DropOutReason;                        //KDCE_DropOutReason;
        public String DropOutDate;                          //KDCE_DropoutDate;
        public String DropOutContact;                       //KDCE_IsDropout;
        public String BlockedContact;				        //CCR_BlockedContact;
        public String BockingReason;				        //CCR_BockingReason;
        public String LastLoginDate;                        //KDCE_LastLoginDate;
        public String RestoreDormantDate;                   //KDCE_ReactivateDormantDate;
        public String CreatedDate;				            //CreatedDate;
        public String LastModifiedDate;				        //LastModifiedDate;
        public String StoreCode;                            //KDCE_Store;
        public String ConvertedConsumer;                    //KDCE_ConvertedConsumer;
        public String MGMUseCount;				            //KDCE_MGMUseCount;
        public String ECLoginEmail;                         //KDCE_ECLoginEmail

        public String JobResult;                            // 인터페이스 에러 코드를 보내기 위한 값

        public List<T_ContactHistory> t_ContactHistories;
        public List<T_Order> t_Orders;
        public List<T_Asset> t_Assets;
        public List<T_AssetLifecycle> t_AssetLifecycles;
        public List<T_AssetHistory> t_AssetHistories;
        public List<T_Coupon> t_Coupons;
        public List<T_CouponHistory> t_CouponHistories;
        public List<T_TnCAccepted> t_TnCAccepteds;
        public List<T_TnCHistory> t_TnCHistories;
        public List<T_DormantContact> t_DormantContacts;

    }

    public virtual class T_ContactHistory {
        public String Id;
        public String RecordNumber;     //Name
        public String ContactId;
        public String HistoryType;      //HistoryType__c
        public String ActionDate;
        public String ActionType;
        public String Log;
        public String CreatedDate;      //CreatedDate;
        public String LastModifiedDate; //LastModifiedDate;
    }

    public virtual class T_Asset {
        // 검색필드
        public String ContactExtId;
        public String KDCE_ActionType;
        public String KDCE_ActionDate;
        public String CCR_CodentifyId;
        public String SerialNumber;

        // Standard Fields
        public String Id;
        public String Name;
        public String ContactId;
        public String ProductCode;
        public String DeviceProductCode;
        public String Status;
        public String AssetLevel;
        public String Owner;
        public String IsCompetitorProduct;
        public String Description;
        public String DigitalAssetStatus;
        public String ExternalIdentifier;
        public String InstallDate;
        public String IsInternal;
        public String Location;
        public String ManufactureDate;
        public String Parent;
        public String Price;
        public String Product2;
        public String ProductDescription;
        public String ProductFamily;
        public String StockKeepingUnit;
        public String PurchaseDate;
        public String Quantity;
        public String RootAsset;
        public String StatusReason;
        public String Uuid;
        public String UsageEndDate;
        public String CreatedDate;                          // CreatedDate;
        public String LastModifiedDate;                     // LastModifiedDate;

        // Custom Fields
        public String CCR_AccidentalDamageCounter;
        public String CCR_CarePlusDueDate;
        public String CCR_CarePlusStatus;
        public String CCR_DefectiveDevice;
        public String KDCE_DeviceLabelling;
        public String CCR_DeviceProductCode;
        public String KDCE_DeviceType;
        public String CCR_ExternalReference;
        public String CCR_FactoryCode;
        public String CCR_FactoryName;
        public String CCR_FirstLinkDatetoCurrentContact;
        public String CCR_Image;
        public String CCR_InternalId;
        public String CCR_IsForTrial;
        public String CCR_Lender;
        public String CCR_MaterialDescription;
        public String CCR_MaterialGroupDescription;
        public String CCR_NumberOfConsumers;
        public String CCR_OriginalAsset;
        public String CCR_OriginalBox;
        public String CCR_OriginaDesignMarket;
        public String CCR_Override;
        public String CCR_OverrideReason;
        public String CCR_ParentProductionDateTime;
        public String KDCE_fm_ProductEAN;
        public String CCR_ProductionDateTime;
        public String CCR_ProductionLineCode;
        public String CCR_PromotionApplied;
        public String CCR_PurchaseChannel;
        public String CCR_PurchaseCountry;
        public String CCR_ReplacedBy;
        public String KDCE_Replacement;
        public String CCR_ReplacementChannelNew;
        public String CCR_ReplacementCountry;
        public String CCR_ReplacementDate;
        public String CCR_ReplacementDoneBy;
        public String CCR_EligibilityDueDate;
        public String CCR_Flag;
        public String CCR_ReplacementExternalReference;
        public String CCR_ReplacementReason;
        public String CCR_ReplacementSponsored_By;
        public String CCR_Replaces;
        public String CCR_SubscribedDevice;
        public String CCR_SubscriptionID;
        public String CCR_TrialExternalReference;
        public String CCR_WarrantyDueDate;
        public String CCR_WarrantyDueDate_Flag;
        public String CCR_Version;

        public String JobResult;        // 인터페이스 에러 코드를 보내기 위한 값

        public List<T_AssetLifecycle> t_AssetLifecycles;
        public List<T_AssetHistory> t_AssetHistories;

    }

    public virtual class T_AssetLifecycle {
        public String Id;
        public String RecordNumber;     //Name
        public String ContactId;
        public String ContactExtId;
        public String AssetId;          //CCR_Asset__c
        public String CodentifyId;      //CCR_Asset__r.CCR_CodentifyId__c
        public String KDCE_DeviceType;  //KDCE_DeviceType__c
        public String CCR_Action;
        public String CCR_ActionDate;   //CCR_ActionDate
        public String CreatedDate;
        public String LastModifiedDate;
    }
    public virtual class T_AssetHistory {
        public String Id;
        public String RecordNumber;     //Name
        public String ContactId;        //Contact__c
        public String ContactExtId;
        public String AssetId;          //Asset__c
        public String CodentifyId;      //Asset__c.CCR_CodentifyId__c
        public String OrderId;          //OrderLineItem__r.Order__c
        public String OrderNumber;      //OrderLineItem__r.Order__r.Name
        public String OrderLineItemId;    //OrderLineItem__c
        public String StatusValue;      //StatusValue__c
        public String LabellingValue;   //LabellingValue__c
        public String CreatedDate;
        public String LastModifiedDate;
    }

    public virtual class T_Coupon {
        public String Id;
        public String RecordNumber;     //Name
        public String ContactId;        //Contact__c
        public String ContactExtId;
        public String CouponCode;
        public String Status;
        public String IssuanceStatus;
        public String Channel;          //Channel__c
        public String ChannelDetails;   //ChannelDetails__c
        public String FailReason;
        public String CouponType;
        public String CategoryName;     //CategoryName__c
        public String ModfiedDate;      //ModfiedDate__c
        public String CVSChainCode;     //CVSChainCode__c
        public String CVSChainName;     //CVSChainName__c
        public String OrderIdx;         //OrderIdx__c
        public String OrderType;        //OrderType__c
        public String OriginType;       //OriginType__c
        public String SendEndDate;      //SendEndDate__c
        public String UsedDate;         //UsedDate__c
        public String ConsumerId;       //ConsumerId__c
        public Decimal Amount;           //Amount__c
        public String ExpiryDate;       //ExpiryDate__c
        public String CouponName;       //CouponName__c
        public String ru_UseCount;      //ru_UseCount__c
        public String Datasource;       //Datasource__c
        public String Email;            //Email__c
        public String EndDate;          //EndDate__c
        public String GifticonIssuedCount;      //ru_GifticonReceivedHistoryCount__c
        public String Idx;              //Idx__c
        public String StoreCode;        //StoreCode__c
        public String IssueChannel;     //IssueChanne__c

        public String CreatedDate;				            //CreatedDate;
        public String LastModifiedDate;				        //LastModifiedDate;

        public String JobResult;        // 인터페이스 에러 코드를 보내기 위한 값

        public List<T_CouponHistory> t_CouponHistories;
    }

    public virtual class T_CouponHistory {
        public String Id;
        public String Name;
        public String ContactId;
        public String ContactExtId;
        public String CouponId;         //Coupon__c
        public String ActionChannel;    //ActionChannel__c
        public String ActionDate;       //ActionDate__c
        public String ActionType;       //ActionType__c
        public String Gifticon;         //Gifticon__c
        public String CreatedDate;
        public String LastModifiedDate;
    }
 
    public virtual class T_Order {
        public String Id;
        public String OrderNo;              //
        public String OriginOrderNo;        //취소주문시 필수값 / 기기회수 등
        public String QureCaseNo;           //QURE Case Number
        public String CollectCodentify;     //주문 유형에 따라 필수값인 필
        public String OrderReason;          //주문사유
        public String ExtOrderId;           //
        public String Name;
        public String ActionChannel;
        public String ActionType;
        public String ParentOrderId;        //Rental 을 통한 기기 인수
        public String OrderDate;            //
        public String OrderType;            //드
        public String OrderCurrency;        //
//        public String CustomerLocale;       //
//        public String PreferredLocale;      //
        public String ContactExtId;         //Contact External Key
        public String CustomerName;         //
        public String CustomerEmail;        //
        public String OrderStatus;          //주문 상태 1
        public String OrderState;           //주문 상태 2
        public String RentalId;
        public String RentalStartDate;
        public String RentalEndDate;
        public String RentalStatus;
//        public String ShippingAddressName;  //
        public String ShippingAddress1;     //
        public String ShippingAddress2;     //
        public String ShippingState;        //
        public String ShippingCity;         //
        public String ShippingStreet;       //
        public String ShippingPostalCode;   //
        public String ShippingCountry;      //
        public String ShippingPhone;        //
        public String ShippingTax;          //
        public String ShippingGrossPrice;   //
        public String ShippingItemId;       //
        public String ShippingMethod;       //
        public String GrossPrice;           //
        public String Discount;             //
//        public String TaxBasis;             //
//        public String Tax;                  //
        public String NetPrice;             //
//        public String PriceAfterRental;     //
        public String PaymentAmount;        //
        public String PaymentMethod;        //
        public String PaymentProcessorId;   //
        public String PaymentTransactionId; //
//        public String PaymentStatus;        //
        public String PromotionId;          //
        public String PromotionName;        //
//        public String CouponId;             //
//        public String Channel;              //
//        public String SpiceID;              //
        public String Status;               //
        public String CouponCode;           //
        public String CreatedDate;
        public String LastModifiedDate;
        public String StoreChannel;
        public String StoreCode;
        public String ShipStatus;           //
        public String ShipStatusDate;       //
        public String ShipQuantity;         //
        public String TrackingNo;           //
        public String TrackingUrl;          //
        public String ShippingMessage;
        public String ShippingStartDate;
        public String ShippingEndDate;
        public String ReturnStartDate;      // 반품시작날짜
        public String ReturnEndDate;        // 반품종료날짜
        public String CollectionStartDate;  // 추심시작날짜
        public String CollectionEndDate;    // 추심종료날짜
        public String CollectionStatusDate; // 추심 상태값 변경 날짜
        public String CollectionStatus;     // 추심 상태값
        public String CollectionAmount;



//        public List<T_Coupon> t_Coupons;
        public List<T_OrderReturn> t_OrderReturns;
        public List<T_OrderLineItem> t_OrderItems;


    }

    public virtual class T_OrderReturn {
        public String Id;
        public String Name;
        public String OrderId;              //
        public String OrderDate;            //
        public String OrderNo;              //
        public String OrderType;            //
        public String OrderCurrency;        //
        public String CustomerLocale;       //
        public String PreferredLocale;      //
        public String ContactExtId;         //Contact External Key
        public String CustomerName;         //
        public String CustomerEmail;        //
        public String OrderStatus;          //주문 상태 1
        public String ShippingAddressName;  //
        public String ShippingAddress1;     //
        public String ShippingAddress2;     //
        public String ShippingState;        //
        public String ShippingCity;         //
        public String ShippingStreet;       //
        public String ShippingPostalCode;   //
        public String ShippingCountry;      //
        public String ShippingPhone;        //
        public String ShippingTax;          //
        public String ShippingGrossPrice;   //
        public String ShippingItemId;       //
        public String ShippingMethod;       //
        public String GrossPrice;           //
        public String Discount;             //
        public String TaxBasis;             //
        public String Tax;                  //
        public String NetPrice;             //
        public String PaymentAmount;        //
        public String PaymentMethod;        //
        public String PaymentProcessorId;   //
        public String PaymentTransactionId; //
        public String PaymentStatus;        //
        public String PromotionId;          //
        public String PromotionName;        //
//        public String CouponId;             //
        public String Channel;              //
        public String SpiceID;              //
        public String MGOrderReturnId;      //
        public String Status;               //
        public String CreatedDate;
        public String LastModifiedDate;

        public List<T_OrderLineItem> t_OrderReturnLineItems;

    }

    public virtual class T_OrderLineItem {
        public String Id;
        public String Name;
        public String Codentify;            //Codentify
        public String OrderItemNo;          //External Order Item Id
        public String OrderNo;              //External Order Id
        public String OrderId;
        public String OrderRetrunId;
        public String AssetId;              //Asset Order History Id 1:N
        public String Produc2Id;            //Product Id
        public String MaterialId;           //Material Id
        public String KDCE_EANCode;         //EANCode
        public String ProductCode;          //SKU
        public String ProductName;          //
        public String ProductQuantity;      //
        public String ProductIGrossPrice;   //
        public String ProductItemDiscount;  //
        public String ProductTaxBasis;      //
        public String ProductTaxRate;       //
        public String ProductTax;           //
        public String ProductNetPrice;      //
        public String PriceAfterRental;     //
        public String ProductPromotionId;   //
        public String ProductPromotionName; //
        public String ProductCouponId;      //
//        public String ShipStatus;           //
//        public String ShipStatusDate;       //
//        public String ShipQuantity;         //
//        public String TrackingNo;           //
//        public String TrackingUrl;          //
        public String FullProductId;        //
        public String CreatedDate;
        public String LastModifiedDate;

        public List<T_Coupon> t_Coupons;
    }

//    public virtual class T_OrderReturnLineItem {
//        public String Id;
//        public String Name;
//        public String OrderId;
//        public String OrderRetrunId;
//        public String AssetId;              //Asset Order History Id 1:N
//        public String Produc2Id;            //Product Id
//        public String MaterialId;           //Material Id
//        public String ProductCode;          //SKU
//        public String ProductName;          //
//        public String ProductQuantity;      //
//        public String ProductIGrossPrice;   //
//        public String ProductItemDiscount;  //
//        public String ProductTaxBasis;      //
//        public String ProductTaxRate;       //
//        public String ProductTax;           //
//        public String ProductNetPrice;      //
//        public String ProductPromotionId;   //
//        public String ProductPromotionName; //
//        public String ProductCouponId;      //
//        public String ShipStatus;           //
//        public String ShipStatusDate;       //
//        public String ShipQuantity;         //
//        public String TrackingNo;           //
//        public String TrackingUrl;          //
//        public String FullProductId;        //
//        public String Codentify;            //
//        public String MGOrderItemId;        //
//        public String CreatedDate;
//        public String LastModifiedDate;
//
//        public List<T_Coupon> t_Coupons;
//    }

    public virtual class T_TnC {
        public String Id;
        public String Name;

        public String CreatedDate;          //
        public String LastModifiedDate;
        public List<T_TnCAccepted> t_TnCAccepteds;
        public List<T_TnCHistory> t_TnCHistories;
    }

    public virtual class T_TnCAccepted {
        public String Id;
        public String Name;
        public String ContactId;            //ContactId
        public String ContactExtId;         //ContactExtId
        public String TnCVersionSetId;      //TnCVersionSetId
        public String SubGroup;             //KDCE_SubGroup__c
        public String TnCName;              //fm_TnCName__c
        public String Channel;              //Channel
        public String Accepted;             //Accepted__c
        public String CreatedDate;		    //CreatedDate;
        public String LastModifiedDate;		//LastModifiedDate;

    }
    public virtual class T_TnCHistory {
        public String Id;
        public String Name;
        public String ContactId;            //ContactId
        public String ContactExtId;         //ContactId
        public String KDCE_TnCVersionSetId; //KDCE_TnCVersionSet__c
        public String KDCE_TnCId;           //KDCE_TnC__c
        public String KDCE_Channel;         //KDCE_Channel
        public String CCR_Acceptance_Date;  //CCR_Acceptance_Date
        public String KDCE_Accepted;        //KDCE_Accepted__c
        public String KDCE_AcceptanceResponse; //KDCE_AcceptanceResponse__c
        public String CreatedDate;				            //CreatedDate;
        public String LastModifiedDate;				        //LastModifiedDate;
    }

    public virtual class T_DormantContact {
        public String Id;
        public String Name;
        public String ContactName;
        public String Phone;
        public String CreatedDate;				            //CreatedDate;
        public String LastModifiedDate;				        //LastModifiedDate;
    }

    // IF BIZ 처리시, 처리 필수값 유효체크 및 에러메세지 반환
    public static Boolean validate(Object expected, Object actual, String exceptionMessage) {
        Boolean result = expected == null ? expected == actual : expected.equals(actual);
        if (!result) {
            throw new ValidationException(exceptionMessage);
        }
        return result;
    }
    public class ValidationException extends Exception {
    }

    // Date 또는 Datetime 을 String 으로 변환
    // YYYY-MM-DD, YYYY-MM-DD HH:mm:ss (24시 기준)
    public static String convertDateAndDateTimeToString(Object value) {
        if (Util.isEmpty(value)) return null;

        String returnValue;
        if (value instanceof Date) {
            Date dateValue = (Date) value;
            returnValue = String.valueOf(dateValue.year()) + '-' + String.valueOf(dateValue.month()).leftPad(2, '0') + '-' + String.valueOf(dateValue.day()).leftPad(2, '0');
        } else if (value instanceof Datetime) {
            Datetime datetimeValue = (Datetime) value;
            String dateToken = String.valueOf(datetimeValue.year()) + '-' + String.valueOf(datetimeValue.month()).leftPad(2, '0') + '-' + String.valueOf(datetimeValue.day()).leftPad(2, '0');
            String timeToken = String.valueOf(datetimeValue.hour()).leftPad(2, '0') + ':' + String.valueOf(datetimeValue.minute()).leftPad(2, '0') + ':' + String.valueOf(datetimeValue.second()).leftPad(2, '0');
            returnValue = dateToken + ' ' + timeToken;
        }
        return returnValue;
    }
    public static String convertDateAndDateTimeToStringNotNull(Object value) {
        String returnValue = convertDateAndDateTimeToString(value);
        if (Util.isEmpty(returnValue)) return '';

        return returnValue;
    }
    // "YYYY-MM-DD" to Date
    public static Date convertStringToDate(String value) {
        if (Util.isEmpty(value)) return null;

        List<String> tokens = value.split('-');
        IF_KDCE_API_BizBase.validate(true, tokens != null && tokens.size() == 3, '[Date format invalid] expected format : YYYY-MM-DD , actual ' + value);
        if (tokens == null || tokens.size() != 3) {
            return null;
        }

        return Date.newInstance(Integer.valueOf(tokens[0]), Integer.valueOf(tokens[1]), Integer.valueOf(tokens[2]));
    }

    // "YYYY-MM-DD HH:mm:ss" to Datetime
    public static Datetime convertStringToDatetime(String value) {
        if (Util.isEmpty(value)) return null;

        List<String> tokens = value.split(' ');
        IF_KDCE_API_BizBase.validate(true, tokens != null && tokens.size() == 2, '[Datetime format invalid] expected format : YYYY-MM-DD HH:mm:ss , actual ' + value);

        List<String> dateToken = tokens[0].split('-');
        List<String> timeToken = tokens[1].split(':');

        IF_KDCE_API_BizBase.validate(true, dateToken.size() == 3 && timeToken.size() == 3, '[Datetime format invalid] expected format : YYYY-MM-DD HH:mm:ss , actual \' + value');

        Date dateValue = Date.newInstance(Integer.valueOf(dateToken[0]), Integer.valueOf(dateToken[1]), Integer.valueOf(dateToken[2]));
        Time timeValue = Time.newInstance(Integer.valueOf(timeToken[0]), Integer.valueOf(timeToken[1]), Integer.valueOf(timeToken[2]), 0);

        return Datetime.newInstance(dateValue, timeValue);
    }

    public static Datetime convertStringToDatetimeGMT(String value) {
        if (Util.isEmpty(value)) return null;

        List<String> tokens = value.split(' ');
        IF_KDCE_API_BizBase.validate(true, tokens != null && tokens.size() == 2, '[Datetime format invalid] expected format : YYYY-MM-DD HH:mm:ss , actual ' + value);

        List<String> dateToken = tokens[0].split('-');
        List<String> timeToken = tokens[1].split(':');

        IF_KDCE_API_BizBase.validate(true, dateToken.size() == 3 && timeToken.size() == 3, '[Datetime format invalid] expected format : YYYY-MM-DD HH:mm:ss , actual \' + value');

        Date dateValue = Date.newInstance(Integer.valueOf(dateToken[0]), Integer.valueOf(dateToken[1]), Integer.valueOf(dateToken[2]));
        Time timeValue = Time.newInstance(Integer.valueOf(timeToken[0]), Integer.valueOf(timeToken[1]), Integer.valueOf(timeToken[2]), 0);

        return Datetime.newInstanceGMT(dateValue, timeValue);
    }

    // "1234.1234" to Decimal
    public static Decimal convertStringToDecimal(String value) {
        Boolean isValidDecimal = true;
        Decimal dec = null;

        if (value != null) {
            try {
                dec = Decimal.valueOf(value);
            } catch (TypeException e) {
                isValidDecimal = false;
            }
        }
        system.debug(isValidDecimal);

        return dec;
    }

    /**
     * @description
     * @param str i.g. 'true', 'TRUE', 'false', ...
     * @return Boolean (default false)
     */
    public static Boolean getValidBoolean(String str) {
        try {
            return Boolean.valueOf(str);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * @description
     * @param name
     * @param mobileCarrier
     * @param mobilePhone
     * @return String (Temp Ext Key)
     */
    public static String getExtForNotHavingExternal(String name, String mobilePhone) {
        return name + '_' + mobilePhone;
    }
}