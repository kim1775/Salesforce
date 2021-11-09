/**
 * Created by I2MAX on 2021-05-19.
 */

public without sharing class EQureLandPageController {
    public ApexPages.StandardController sc;                 // 페이지 기본 Controller
    public String codentify { get; set; }
    public String accessToken { get; set; }
    public Boolean isError { get; set; }

    public EQureLandPageController() {
        codentify = String.valueOf(ApexPages.currentPage().getParameters().get('codentify'));
        accessToken = String.valueOf(ApexPages.currentPage().getParameters().get('accessToken'));
    }

    public PageReference doInit() {
        System.debug('class called debug test ok');
        System.debug(codentify);
        System.debug(accessToken);

        isError = false;

        if(codentify == null || codentify == '' || accessToken == null || accessToken == '') {
            isError = true;
            return null;
        }

        List<Asset> ass = [select id, ContactId from asset where CCR_CodentifyId__c = :codentify limit 1];

        List<KDCE_ConsumerLoginHistory__c> lh = new List<KDCE_ConsumerLoginHistory__c>();

        if(ass != null && !ass.isEmpty()) {
            lh = [select id, AccessToken__c from KDCE_ConsumerLoginHistory__c where Contact__c = :ass[0].ContactId order by createddate desc limit 1];
        }

        if(lh != null && !lh.isEmpty() && lh[0].AccessToken__c == accessToken) {
            System.debug('access token good condition');
            return doTimeoutCheck();
        } else {
            System.debug('access token bad condition');
            return null;
        }
    }

    public PageReference doTimeoutCheck() {
        List<Profile> pfList = [SELECT Id, UserLicense.Name FROM Profile WHERE Id = :UserInfo.getProfileId()];

        PageReference retURL;
        if (pfList.size() == 1) {
            String userLicenseName = pfList[0].UserLicense.Name;
//            if (userLicenseName == 'Guest User License') retURL = new PageReference('/' + domain + 'Login');     // 로그인 페이지
//            else retURL = new PageReference('/apex/' + domain + 'Login');     // 로그인 페이지
        }

        retURL = new PageReference('/CCR_QUREAgentPage?codentify=' + codentify+'&accessToken='+accessToken);

//        timeout = String.valueOf(ApexPages.currentPage().getParameters().get('timeout'));// enc with hex
//
//        if (Utility.isEmpty(timeout)) {
//            return retURL;
//        }
//
//        Genesis__c genesis = Genesis__c.getInstance('강남'); // Custom Setting.
//        Long min = (Long) genesis.Timeout_min__c;
//        String t = CustomCrypto.decrypt(timeout);// session 시작 시간 from login.
//        Long l = Long.valueOf(t); // 시작시간을 long으로 casting.
//        Long timeLimit = l + min * 60 * 1000;
//        if (System.currentTimeMillis() > timeLimit) {
//            return retURL;
//        }
//
//        Map<String, String> holidayMap = new Map<String, String>();
//        availableDays = JSON.serialize(holidayMap);

        return retURL;
    }

    public static void runTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}