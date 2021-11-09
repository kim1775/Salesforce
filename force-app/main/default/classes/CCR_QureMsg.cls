/**
 * Created by I2MAX on 2021-03-17.
 */

public class CCR_QureMsg {
    public static final String DEVICENOTMARKEDREPLACEBLE = 'DEVICENOTMARKEDREPLACEBLE';
    public static final String REPLACEMENTCHANNELNOTSELECTED = 'REPLACEMENTCHANNELNOTSELECTED';
    public static final String OTHERREPLACEMENTCHANNEL = 'OTHERREPLACEMENTCHANNEL';
    public static final String ISSUESOLVED = 'ISSUESOLVED';
    public static final String ISSUENOTSOLVED = 'ISSUENOTSOLVED';
    public static final String AGENTOVERRIDE = 'AGENTOVERRIDE';
    public static final String ESCALATETOCSC = 'ESCALATETOCSC';
    public static final String QUREINACTIVE = 'QUREINACTIVE';
    public static final String NETWORKDISRUPTION = 'NETWORKDISRUPTION';
    public static final String SYSTEMERROR = 'SYSTEMERROR';
    public static final String ISOBARRESENDVOUCHER = 'ISOBARRESENDVOUCHER';
    public static final String AGENTRESTART = 'AGENTRESTART';

    public static final String ISGOODWILLUSED = 'ISGOODWILLUSED';

    @AuraEnabled
    public String ErrorMsgId;   //"Message Name"  "CCR_MessageName__c"       "Picklist"
    @AuraEnabled
    public String WarningMessageId;   //"Message Name"  "CCR_MessageName__c"      "Picklist"
    @AuraEnabled
    public String Results;
    /* Available values:
     * DEVICENOTMARKEDREPLACEBLE
     * REPLACEMENTCHANNELNOTSELECTED
     * OTHERREPLACEMENTCHANNEL
     * ISSUESOLVED
     * ISSUENOTSOLVED
     * AGENTOVERRIDE
     * AGENTRESTART (only in PreEligibility)
     *
     */
    @AuraEnabled
    public String Language;
    @AuraEnabled
    public String Codentify;
    @AuraEnabled
    public String contactExternalId;
    @AuraEnabled
    public String contactEmailId;
    @AuraEnabled
    public String assetId;
    @AuraEnabled
    public String OriginalCodentify;

    public String Market = 'KR';   // Country
    @AuraEnabled
    public String QureHistryId;
    @AuraEnabled
    public String UserType;
    @AuraEnabled
    public Boolean IsLimitedEdition;
    @AuraEnabled
    public String CaseId;
    @AuraEnabled
    public Map<String,String> Labels;
    @AuraEnabled
    public String ResultCode;
    @AuraEnabled
    public String ReplacementReason;
    @AuraEnabled
    public Integer NoOfPastReplacements;
    @AuraEnabled
    public Boolean RplsWarningMsgFlag;
    @AuraEnabled
    public String channelSelected;
    @AuraEnabled
    public String orderId;
    @AuraEnabled
    public Boolean isCalloutSuccess;
    @AuraEnabled
    public String calloutErrorStr;
    @AuraEnabled
    public String model;
    @AuraEnabled
    public String color;
    @AuraEnabled
    public String productId;
    @AuraEnabled
    public CCR_QureConfiguration__c emailConfiguration;
    @AuraEnabled
    public Boolean sentEmailSuccess = false;
    @AuraEnabled
    public String fullAddressText;
    @AuraEnabled
    Public List<CCR_AssetReplacementOrderApi.Res_hits> colorSwapDataList;
    @AuraEnabled
    public List<CCR_QureConfiguration__c> replacementChannels = new List<CCR_QureConfiguration__c> ();
    @AuraEnabled
    public List<CCR_QureConfiguration__c> defaultChannels = new List<CCR_QureConfiguration__c> ();

    /* Care Plus */
    @AuraEnabled
    public Boolean coveredInCarePlus;
    @AuraEnabled
    public Boolean carePlusInvite;
    // 20210709 CarePlusStatus added
    @AuraEnabled
    public Boolean carePlusStatusEnrolled = true;

    /* Data For Escalation*/
    @AuraEnabled
    public String MaterialGroup;
    @AuraEnabled
    public String SubjectCode;
    @AuraEnabled
    public String otherMessage;

    /* Address for delivery*/
    @AuraEnabled
    Public String Salutation;
    @AuraEnabled
    Public String FirstName;
    @AuraEnabled
    Public String LastName;
    @AuraEnabled
    public String Address1;
    @AuraEnabled
    Public String Address2;
    @AuraEnabled
    public String Address3;
    @AuraEnabled
    Public String Address4;
    @AuraEnabled
    public String Address5;
    @AuraEnabled
    Public String Area;
    @AuraEnabled
    Public String District;
    @AuraEnabled
    Public String AddressCity;
    @AuraEnabled
    Public String AddressPostalCode;
    @AuraEnabled
    public String AddressStreet;
    @AuraEnabled
    public String ConsumerPhone;
    @AuraEnabled
    public String IDType;
    @AuraEnabled
    public String IDNumber;
    @AuraEnabled
    public String TaxID;
    @AuraEnabled
    public List<String> optionsParent;
    @AuraEnabled
    public List<String> optionsIDType;

    // 20210506 자가진단 후 후속 프로세스 막기 위한 Flag
    // 20210706 고객의 경우에만 히팅 블레이드로 인한 두번 째 교환 불가
    //          고객의 경우에만 3번 교체 후 재 교환 불가
    @AuraEnabled
    public Boolean IsReplacableWarrantyDate = true;
    @AuraEnabled
    public Boolean IsReplacableCarePlus = true;
    @AuraEnabled
    public Boolean IsReplacableByReplaceCount = true;
    @AuraEnabled
    public String BlockEndMessage;

    // 20210513 Online Qure 로 사용자 판별하기 위한 Flag
    @AuraEnabled
    public Boolean IsOnlineQure = false;
    @AuraEnabled
    public String AccessToken;

    // 20210531 Magento API 를 위한 파라미터 추가
    @AuraEnabled
    public String ProductCode;
    @AuraEnabled
    public String ProductName;
    // 20210608 Magento API 를 위한 변수(FullProductId)
    @AuraEnabled
    public String Product2Name;

    @AuraEnabled
    public String InfoMessageId;   //"Message Name"  "CCR_MessageName__c"      "Picklist"

    /* Courier Delivery form fields */
    @AuraEnabled
    Public List<CCR_QureConfiguration__c> formFieldsList = new List<CCR_QureConfiguration__c>();
}