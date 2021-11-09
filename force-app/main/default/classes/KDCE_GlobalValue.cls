/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-03-08 오후 2:53
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
    0.1     2021-03-08 오후 2:53     i2max_Junseok.Kwon        Create
****************************************************************************************/

public without sharing class KDCE_GlobalValue {

    /**
     * <온라인 Order Reason별 Order Status 설명> (모든 Order Type 합쳐서 써놓았음. 참고용으로 확인해야하며, Order Type별 자세한 사항은 DeviceLifeCycle_기기상태처리에서 확인)
     *     Reason               Status
     *     forward              processing              => 기기 결제
     *     forward              ready_for_delivery      => 출고 요청
     *     forward              complete                => 출고 및 배송중
     *     forward              complete_delivery       => 배송 완료
     *     forward              cancel_order            => Trade-in 결제전 취소
     *     forward              closed                  => 출고전 취소
     *     forward              paid                    => Rental 사용중인 기기 구매 주문 결제
     *     return               pending                 => 출고 요청 이후 반품 요청
     *     return               processed_closed        => 반납기기 회수 완료
     *     collect              pending                 => Rental 회수중
     *     collect              processing              => 반납기기 회수중
     *     collect              processed_closed        => 반납기기 회수완료
     *     collect              cancel_order            => Trade-in 결제 취소
     *     rental forward       complete                => ZTA 기기 반납 후 신규 상품 구매 결제
     *     rental forward       complete_delivery       => ZTA 기기 반납 후 신규 상품 구매 결제
     *     rental return        processing              => ZTA 기기 구매 후 환불, 기기 회수 중
     *     rental return        processed_closed        => ZTA 기기 회수 완료
     */

    /*
    public static final String ORDER_PENDING    = 'pending';
    public static final String ORDER_PROCESS    = 'processing';
    public static final String ORDER_READY      = 'ready_for_delivery';
    public static final String ORDER_PICKING    = 'picking';
    public static final String ORDER_COMPLETE   = 'complete';
    public static final String ORDER_CLOSE      = 'closed';
    public static final String ORDER_CANCEL     = 'cancel_order';
    */
    // Order Type
    public static final String ORDER_TYPE_NORMAL        = 'ZTA';            // 일반주문
    public static final String ORDER_TYPE_TRADEIN       = 'ZTI';            // 보상판매
    public static final String ORDER_TYPE_RENTAL        = 'ZRN';            // 중고상품 렌탈주문 < zta?
    public static final String ORDER_TYPE_RENTALNEW     = 'ZRNNEW';         // 신품 렌탈주문
    public static final String ORDER_TYPE_RTLBUY        = 'ZTA';            // 렌탈 후 구매
    public static final String ORDER_TYPE_QURE          = 'ZRA';            // Replacement

    // Order Collection Status (추심 상태)
    public static final String ORDER_COL_STATUS_COLSUCCESS  = 'collection_success'; // 추심 성공
    public static final String ORDER_COL_STATUS_COLFAIL     = 'collection_failed';    // 추심 실패
    public static final String ORDER_COL_STATUS_COLLECTION  = 'collection';         // 추심 진행 (추심 시작일이 들어올떄 넣어줌)
    public static final String ORDER_COL_STATUS_PROCESSING  = 'processing';         // 추심 진행 (추심 시작일이 들어올떄 넣어줌)
    public static final String ORDER_COL_STATUS_EXTSUCCESS  = 'external_success';   // 외부에서 바꿔주는 추심 성공

    // Offline Program Type (Order Type과 동일한 경우는 생략)
    public static final String OFF_PG_TYPE_UPGRADE      = 'ZTU';            // 업그레이드
    public static final String OFF_PG_TYPE_KITTOKIT     = 'ZRT';            // Kit to Kit
    public static final String OFF_PG_TYPE_RTLBUY       = 'ZTAR';           // 렌탈 후 구매

    // Offline Program Status
    public static final String OFF_PG_STATUS_COMPLETE       = 'Complete';
    public static final String OFF_PG_STATUS_CANCEL         = 'Cancel';
    public static final String OFF_PG_STATUS_RTNPROCESS     = 'Rental Process';
    public static final String OFF_PG_STATUS_RTNCANCEL      = 'Rental Cancel';
    public static final String OFF_PG_STATUS_RTNCLOSED      = 'Rental Closed';
    public static final String OFF_PG_STATUS_RTNPURCHASE    = 'Rental Purchase';
    public static final String OFF_PG_STATUS_RTNREFUND      = 'Rental Refund';

    //Order Reason
    public static final String ORDER_REASON_FORWARD             = 'forward';
    public static final String ORDER_REASON_RETURN              = 'return';
    public static final String ORDER_REASON_COLLECT             = 'collect';
    public static final String ORDER_REASON_RTLFORWARD          = 'rental forward';
    public static final String ORDER_REASON_RTLRETURN           = 'rental return';

    //Order Status
    public static final String ORDER_STATUS_PENDING             = 'pending';
    public static final String ORDER_STATUS_PROCESS             = 'processing';
    public static final String ORDER_STATUS_READY               = 'ready_for_delivery';
    public static final String ORDER_STATUS_COMPLETE            = 'complete';
    public static final String ORDER_STATUS_COMPLETE_DELIVERY   = 'complete_delivery';
    public static final String ORDER_STATUS_CLOSE               = 'closed';
    public static final String ORDER_STATUS_PROCESSED_CLOSED    = 'processed_closed';
    public static final String ORDER_STATUS_PAID                = 'paid';
    public static final String ORDER_STATUS_DELIVERY            = 'delivery_collection';
    public static final String ORDER_STATUS_AUTHORIZED          = 'authorized';
    public static final String ORDER_STATUS_APPROVED            = 'approved';
    public static final String ORDER_STATUS_DELIVERED           = 'delivered';
    public static final String ORDER_STATUS_RENTING             = 'renting';
    public static final String ORDER_STATUS_CANCELED            = 'canceled';


    // Order Rental Status
    public static final String ORDER_RNTSTATUS_RENTAL     = 'Rental';
    public static final String ORDER_RNTSTATUS_CLOSED     = 'Closed';
    public static final String ORDER_RNTSTATUS_CANCEL     = 'Cancel';

    //Asset Device Status
    public static final String ASSET_STATUS_PRODUCED    = 'Produced';
    public static final String ASSET_STATUS_ACTIVE      = 'Active';
    public static final String ASSET_STATUS_LOCKED      = 'Locked';
    public static final String ASSET_STATUS_REPLACED    = 'Replaced';
    public static final String ASSET_STATUS_RETURNED    = 'Returned';

    //Asset Device Label
    public static final String ASSET_LABEL_ECOMMERCE        = 'E-Commerce';
    public static final String ASSET_LABEL_ONTRADEIN        = 'Online Trade-in';
    public static final String ASSET_LABEL_ONTRADEINR       = 'Online Trade-in Return';
    public static final String ASSET_LABEL_OFFTRADEIN       = 'Offline Trade-in';
    public static final String ASSET_LABEL_OFFTRADEINR      = 'Offline Trade-in Return';
    public static final String ASSET_LABEL_RENTING          = 'Renting';
    public static final String ASSET_LABEL_RENTALPURCHASED  = 'Rental Purchased';
    public static final String ASSET_LABEL_DISPOSED         = 'To be disposed';
    public static final String ASSET_LABEL_RETURNFAIL       = 'Return Fail';
    public static final String ASSET_LABEL_ECOMMRENTAL      = 'E-commerce Rental';
    public static final String ASSET_LABEL_OFFRENTAL        = 'Offline Rental';
    public static final String ASSET_LABEL_UPGRADE          = 'Upgrade';

    //Coupon Channel
    public static final String COUPON_CHANNEL_GS        = 'GS25';
    public static final String COUPON_CHANNEL_CU        = 'CU';
    public static final String COUPON_CHANNEL_K7        = '세븐일레븐';
    public static final String COUPON_CHANNEL_MS        = '미니스톱';
    public static final String COUPON_CHANNEL_EM        = '이마트24';
    public static final String COUPON_CHANNEL_CS        = '씨스페이스';
    public static final String COUPON_CHANNEL_SS        = '일반 소매점';

    //Coupon Status
    public static final String COUPON_STATUS_PRODUCE    = 'Produce';
    public static final String COUPON_STATUS_ISSUE      = 'Issue';
    public static final String COUPON_STATUS_USE        = 'Use';

    //Coupon Type
    public static final String COUPON_TYPE_MGM      = 'MGM';
    public static final String COUPON_TYPE_CVS      = 'CVS';  // Special Purchase Code
    public static final String COUPON_TYPE_GETINFO  = 'GetInfo';

    // Coupon History Action Type
    public static final String COUPON_HISTORY_TYPE_PRODUCE   = 'Produce';
    public static final String COUPON_HISTORY_TYPE_ISSUE     = 'Issue';
    public static final String COUPON_HISTORY_TYPE_USE       = 'Use';
    public static final String COUPON_HISTORY_TYPE_CANCEL    = 'Cancel';

    // Coupon History Action Type
    public static final String COUPON_HISTORY_CHANNEL_ONLINE        = 'Online';
    public static final String COUPON_HISTORY_CHANNEL_CALLCENTER    = 'Call Center';
    public static final String COUPON_HISTORY_CHANNEL_OFFLINE       = 'Offline';

    //Contact Channel Label
    public static final String CONTACT_CHANNEL_CVS          = 'CVS';
    public static final String CONTACT_CHANNEL_ECOMMERCE    = 'E-Commerce';
    public static final String CONTACT_CHANNEL_MANNED       = 'Manned';
    public static final String CONTACT_CHANNEL_RENTAL       = 'Rental';
    public static final String CONTACT_CHANNEL_TRADEIN      = 'Trade-in';

    // Asset Replacement
    //public static final String ASSET_REPLACE_CHANNEL        = 'LSP';

    //Asset Purchase Channel
    public static final String ASSET_PURCHASE_CHANNEL_DIRECT        = 'Direct Retail';
    public static final String ASSET_PURCHASE_CHANNEL_INDIRECT      = 'Indirect Retail';
    public static final String ASSET_PURCHASE_CHANNEL_ECOMMERCE     = 'Ecommerce';
    public static final String ASSET_PURCHASE_CHANNEL_FIELDSALES    = 'Field Sales Force';
    public static final String ASSET_PURCHASE_CHANNEL_LSP           = 'LSP';
    public static final String ASSET_REPLACEMENT_CHANNEL_PICKUP     = 'Pickup Point';

    //Asset Life Cycle
    public static final String ASSETLIFECYCLE_ACTION_LINK           = 'Link';
    public static final String ASSETLIFECYCLE_ACTION_UNLINK         = 'Unlink';

    // Asset Care Plus Status
    public static final String ASSET_CAREPLUSSTATUS_ENROLLED        = 'Enrolled';
    public static final String ASSET_CAREPLUSSTATUS_DISENROLLED     = 'Disenrolled';
    public static final String ASSET_CAREPLUSSTATUS_NOTENROLLED     = 'Not Enrolled';
    public static final String ASSET_CAREPLUSSTATUS_EXPIRED         = 'Expired';

    // Asset ReplacementSponsoredBy
    public static final String ASSET_REPLACE_SPONSOREDBY_IQOSCARE   = 'Care+';
    public static final String ASSET_REPLACE_SPONSOREDBY_GOODWILL   = 'Goodwill';
    public static final String ASSET_REPLACE_SPONSOREDBY_WARRANTY   = 'Warranty';

    // Asset Holder/Charger
    public static final String ASSET_MATERIALGROUPDESC_HOLDER       = 'Holder /S';
    public static final String ASSET_MATERIALGROUPDESC_CHARGER      = 'Pocket Charger /S';

    // Case Status
    public static final String CASE_STATUS_NEW                      = 'New';
    public static final String CASE_STATUS_OPEN                     = 'Open';
    public static final String CASE_STATUS_CLOSED                   = 'Closed';

    // 거래가 진행중인 Set
    /**
     * 탈퇴 불가 조건
     * 1. 추심 진행 중인 고객 (Order Collection Status = 'processing' AND 'collection fail')
     * 2. 온라인 주문 배송 진행 중인 고객 (Order Status != 'closed' AND 'processed_closed' AND 'complete_delivery' 이며 Collection Status가 NULL)
     * 3. Case가 진행 중인 고객 (Case Status != 'Closed')
     * 4. 오프라인 프로그램 진행중인 고객 (OP Status = 'rental process')
     * 5. 고객이 렌탈중인 고객이 체크되어 있을 때
     */
    public static final Set<String> ORDER_COL_STATUS_INPROGRESS_SET = new Set<String> {         // 추심 진행중인 상태
            ORDER_COL_STATUS_PROCESSING, ORDER_COL_STATUS_COLFAIL, ORDER_COL_STATUS_COLLECTION
    };
    public static final Set<String> ORDER_STATUS_NOT_INPROGRESS_SET = new Set<String> {         // 주문 배송이 진행중이 아닌 상태 (+ 추심 상태값이 null인 경우 체크해야함)
            ORDER_STATUS_CLOSE, ORDER_STATUS_PROCESSED_CLOSED, ORDER_STATUS_COMPLETE_DELIVERY, ORDER_STATUS_CANCELED
    };
    public static final Set<String> CASE_STATUS_NOT_INPROGRESS_SET = new Set<String> {          // Case가 종료된 상태
            CASE_STATUS_CLOSED
    };
    public static final Set<String> OP_STATUS_INPROGRESS_SET = new Set<String> {                // Offline Program이 진행중인 상태
            OFF_PG_STATUS_RTNPROCESS
    };

    /**
     *
    */

    /*
    public static final Map<String, String> orderStatusMap = new Map<String, String>{
            'Pending' => '대기',
            'Processing' => '진행',
            'Complete' => '완료',
            'Closed' => '확정',
            'Canceled' => '취소'
    };
     */

}