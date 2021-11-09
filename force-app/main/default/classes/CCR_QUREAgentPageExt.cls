/**
 * Created by MS on 2021-03-17.
 */

public without sharing class CCR_QUREAgentPageExt {
    public String CodentifyId{get; set;}
    public String accessToken{get; set;}
    //public String LanguageVf{get;set;}
    public Boolean qureEnabled{get;set;}
    public static final String ERRORTYPE='Error';
    public static final String ERRORSCOPE='Application';
    public static final String ERRORFUNCTION ='Qure Landing Page';

    public static final String URLST='/';
    public static String assetId;

    // 세션 유지 시간. 추후 라벨 혹은 CustomSetting 으로 변경하여 옵션처럼 사용 가능
    public static final Integer SessionRemainTime = 60; //minutes

    /*Zero Parameter constructor*/
    public CCR_QUREAgentPageExt(ApexPages.StandardController controller) {
        System.debug('=== controller : ' + controller);
        CodentifyId = ApexPages.currentPage().getParameters().get('codentify');
        accessToken = ApexPages.currentPage().getParameters().get('accessToken');
        System.debug('=== ApexPages.currentPage().getParameters().get(\'codentify\') : ' + ApexPages.currentPage().getParameters().get('codentify'));
        //LanguageVf= ApexPages.currentPage().getParameters().get('lang');
        //Added By Surendar
        String qureMessage = null;
        System.debug('QUREAgentPageExt.cls called');
        System.debug(system.UserInfo.getUserName());
        System.debug(system.UserInfo.getUserType());
        System.debug(system.UserInfo.getUserRoleId());

        List<Asset> assList = [select id, ContactId from asset where CCR_CodentifyId__c = :CodentifyId limit 1];
        assetId = assList[0].Id;
        System.debug('CCR_QUREAgentPageExt called ' + assetId);

        if(system.UserInfo.getUserType() == 'Guest')   qureMessage = doTimeoutCheck();
        else qureMessage = 'true';
        if(qureMessage == 'true'){
            qureEnabled = true;
        } else {
            qureEnabled = false;
            ApexPages.AddMessage(new Apexpages.message(Apexpages.Severity.ERROR, qureMessage));
        }

    }

    /**
    *@ Method Name :  checkTimeout
    *@ Arguments: String codentifyId
    *@ Return : Null or Error message
    *@ Description: This method is to Check the User eligibility to perform QURE from Console
    **/
    public String doTimeoutCheck() {
        List<Asset> assList = [select id, ContactId from asset where CCR_CodentifyId__c = :CodentifyId limit 1];
        assetId = assList[0].Id;
        List<KDCE_ConsumerLoginHistory__c> lhList = new List<KDCE_ConsumerLoginHistory__c>();
        if(assList != null && !assList.isEmpty()){
            lhList = [select id, AccessToken__c, LoginDate__c from KDCE_ConsumerLoginHistory__c where Contact__c = :assList[0].ContactId order by createddate desc limit 1];
        }
        if(lhList != null && !lhList.isEmpty()){
            Datetime dt = Datetime.now();
            if(lhList[0].LoginDate__c.addMinutes(SessionRemainTime) < dt || lhList[0].AccessToken__c != accessToken) {
                // Magento 쪽 로그인 후 SessionRemainTime 시간이 지난 뒤 QURE 페이지 접속하면 보이는 에러 문구
                return '세션 정보가 만료되었습니다. 로그아웃 후 다시 로그인 하여 진행해주시기 바랍니다.';
            }
            return 'true';
        } else {
            return '로그인 정보가 없습니다. 잘못된 접근 방법입니다.';
        }
    }

//    public PageReference testCall(){
//        System.debug('test called');
//        List<Asset> assList = [select id, ContactId from asset where CCR_CodentifyId__c = :CodentifyId limit 1];
//        assetId = assList[0].Id;
//        System.debug(URLST + ' // ' + assetId);
//        PageReference ref = new PageReference(URLST+assetid);
//        ref.setredirect(true);
//        return ref;
//    }
}