/**
 * Created by I2MAX on 2021-03-17.
 */

public class CCR_TelemtryUtility {
    public static final String TRIGGERMODULEDETAILS = 'TriggerModule_Details';
    public static final String CUSTOMTYPE = 'custom';
    public static final String  TYPESTRING = 'metricset';
    public static final String NAMESTRING = 'sfdc_backend_telemetry_engine';
    public static final String SFDCSTRING = 'sfdc';
    public static final String ERRORSTRING = 'Error returned: ';
    public static final String TRIGGERMODULETEXT = 'triggermodule';
    public static final String VERSIONTEXT = '0.1';
    public static final String CLASSNAME = 'CCR_TelemtryUtility';
    public static final String METHODNAME = 'publishEvent';
    public static final String ERRORTEXT = 'Error';
    public static final String INTEGRATIONTEXT = 'Integration';
    public static final String TELEMETRYINTEGRATION = 'Telemetry_Engine';
    /**
* Method Name :  publishEvent
* Arguments: json_Payload jsonReq
* Return : None
* Description: Used to publish temetry event
**/
    public static void publishEvent (JSON_Payload jsonReq) {

        List<JSON_Payload> jsonList = new List<JSON_Payload>();
        jsonList.add(jsonReq);
        publishEvent(jsonList);
    }
    /**
* Method Name :  publishEvent
* Arguments: List<JSON_Payload> jsonList
* Return : None
* Description: Used to publish temetry event
**/
    public static void publishEvent (List<JSON_Payload> jsonList) {

        String jsonPayload;
        CCR_TelemetryPlatformEvent__e telemetryEvent = new CCR_TelemetryPlatformEvent__e();
        List<CCR_TelemetryPlatformEvent__e> listEvents = new List<CCR_TelemetryPlatformEvent__e>();
        for(JSON_Payload jsonReq : jsonList) {

            jsonPayload = JSON.serialize(jsonReq,true);
            telemetryEvent = new CCR_TelemetryPlatformEvent__e();
            telemetryEvent.CCR_JSONPayload__c = jsonPayload;
            system.debug(telemetryEvent.CCR_JSONPayload__c);
            listEvents.add(telemetryEvent);
        }
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(listEvents);
        // Inspect publishing result for each event
        CCR_ErrorLogUtility.createErrorLog(results, CLASSNAME, METHODNAME, ERRORTEXT, INTEGRATIONTEXT,TELEMETRYINTEGRATION);
    }
    /*Wrapper class for json payload*/
    public class JSON_Payload {
        public String index;//Type-sfdc.Trigger_Module-environmentname-date
        public String type;//For example "Metric"
        public Source_Details source;
    }
    /*Wrapper class for source details*/
    public class Source_Details {
        public String environment;//EnvironmentName such as Production
        public App_Detail app;//sfdc-Trigger_Module
        public SFDC_Details sfdc;
        public String timestamp;//StartTime
        public String type = CUSTOMTYPE;
        public Metric_Set metricset;
        public Custom_Details custom;
    }
    /*Wrapper class for app detail*/
    public class App_Detail {
        public String id;//sfdc-app-Trigger_Module
        public String alias;//SFDC_App_Trigger_Module SFDC_spice-integration
    }
    /*Wrapper class for sfdc detail*/
    public class SFDC_Details {
        public TriggerModule_Details spice_integration;
        public TriggerModule_Details aitwebservice_integration;
        public TriggerModule_Details demandware_integration;
        public TriggerModule_Details deviceactivitystreaming_integration;//Added as per US CCR-5989 TELEMETRY FOR DEVICE STREAMING API
        public TriggerModule_Details isobar_Integration;
        public TriggerModule_Details iSWAP_Integration;
    }
    /*Wrapper class for xxx detail*/
    public class TriggerModule_Details {
        public String marketcode;//Market_ISO2Code
        public String type;//batch; trigger, class
        public String classname;//API name of class
        public String runninguser;//RunningUserID 00530000000ibYcUZS
        public String transactionstarttime;//StartTime 2011-01-10T00:00:00.000Z
        public String transactionendtime;//2011-01-10T00:00:00.000Z
        public String transactionduration;//Duration 20
        public String errorcodes;//401;404
        public Integer numberoferrors;//0
        public String errorlogref;//ErrorLogObjectRecordID 00930000000ibYcUZS
        public String transactiontrigger;//Trigger_Transaction create-contact
        public String transactionID;//TransactionId
        public Data_Details data;//Flexible Attributes
    }
    /*Wrapper class for data detail*/
    public class Data_Details {

        /*AIT parameters*/
        public String decomposecodes_starttime;
        public String decomposecodes_endtime;
        public String decomposecodes_duration;
        public String getproductinfos_starttime;
        public String getproductinfos_endtime;
        public String getproductinfos_duration;
        public String full_codentifycheck_starttime;
        public String full_codentifycheck_endtime;
        public String full_codentifycheck_durationtime;
        /*spiceIdentifier inside input parameter*/
        public String data_spiceid;//Spice id which triggerred the event
        /*makeCalloutContactCreation*//****In getOrgAccessToken method****/
        public String authenticate_starttime;//Start time for authentication callout
        public String authenticate_endtime;//End time for authentication callout
        public String authenticate_duration;//Duration for authentication callout***Calculated in milliseconds*****
        /*makeCalloutGetContact*/
        public String get_fullcontactdetailsbeforeputTospice_starttime;//Start time for get contact before put callout
        public String get_fullcontactdetailsbeforeputTospice_endtime;//End time for get contact before put callout
        public String get_fullcontactdetailsbeforeputTospice_duration;//Duration for get contact before put callout
        /*makeCalloutContactCreation*/
        public String post_contactdetails_startTime;//Start time for create contact callout
        public String post_contactdetails_endTime;//End time for create contact callout
        public String post_contactdetails_duration;//Duration for create contact callout
        /*makeCalloutContactUpdate*/
        public String put_contactdetails_starttime;//Start time for update contact callout
        public String put_contactdetails_endtime;//End time for update contact callout
        public String put_contactdetails_duration;//Duration for update contact callout
        /*makeCalloutGetContactDetails*/
        public String get_fullcontactdetailsbeforedirectsavetosfdc_starttime;//Start time for get contact before save callout
        public String get_fullcontactdetailsbeforedirectsavetosfdc_endtime;//End time for get contact before save callout
        public String get_fullcontactdetailsbeforedirectsavetosfdc_duration;//Duration for get contact before save callout
        /*upsertContact*/
        public String save_fullcontactdetails_starttime;//Start time for save contact and related objects
        public String save_fullcontactdetails_endtime;//End time for save contact and related objects
        public String save_fullcontactdetails_duration;//Duration for save contact and related objects
        public String save_contact_starttime;//Start time for save conatact
        public String save_contact_endtime;//End time for save conatact
        public String save_contact_durationtime;//Duration for save conatact
        public String save_acceptedtermsconditions_starttime;//Start time for save accepted t&c
        public String save_acceptedtermsconditions_endtime;//End time for save accepted t&c
        public String save_acceptedtermsconditions_duration;//Duration for save accepted t&c
        public String save_optin_starttime;//Start time for save channel opt in
        public String save_optin_endtime;//End time for save channel opt in
        public String save_optin_duration;//Duration for save channel opt in
        /*makeCalloutCreateLogin*/
        public String post_logincreation_starttime;//Start time for create login callout
        public String post_logincreation_endTime;//End time for create login callout
        public String post_logincreation_duration;//Duration for create login callout
        public ProductDetail[] productdetails;
        /*AssetReplacement-Demandware Parameter*/
        public String getproductid_starttime;
        public String getproductid_endtime;
        public String getproductid_duration;
        public String replacementordercreation_starttime;
        public String replacementordercreation_endtime;
        public String replacementordercreation_duration;
        public QureProductData[] qureproductdata;
        /*Device Streaming channel parameters*/
        //Added as per US CCR-5989 TELEMETRY FOR DEVICE STREAMING API
        public String publishevent_starttime;
        public String publishevent_endtime;
        public String publishevent_duration;
        public String batchexecution_starttime;
        public String batchexecution_endtime;
        public String batchexecution_duration;
        public String numberofrecords_processed;
        public String numberofrecords_failed;
        public String numberofrecords_skipped;
        public String config_pushnotificationreattempt;
        public String config_pushnotificationretention;
        public String config_assetpushnotificationchunk;
        /*ISOBAR Parameters
*Added as per US CCR-5995 Telemetry should be able to read ISOBAR callout metrics*/
        public String getvoucher_starttime;
        public String getvoucher_endtime;
        public String getvoucher_duration;
        public String resendvoucher_starttime;
        public String resendvoucher_endtime;
        public String resendvoucher_duration;
        public ISOBAR_ProductData[] isobarproductdata;
        public iSWAP_ProductData iSwapProductData;
    }

    /*Wrapper Class for AIT Product Details*/
    public class ProductDetail {

        public String codentify;
        public String factory;
        public String packinglevel;
        public String market;
        public String codentifycounterfeitstatus;
        public String codentifyvaliditystatus;
        public String productvariant;
        public String branddifferentiator;
        public String brandfamily;
    }
    /*Wrapper Class for Qure Product Replacement data*/
    public class QureProductData {

        public String codentify;
        public String demandwareprodcutId;
        public String market;
        public String casenumber;
        public String productcategory;
        public String Materialgroup;
        public String color;
    }
    /**Added as per US CCR-5995 Telemetry should be able to read ISOBAR callout metrics*/
    /*Wrapper Class for Qure Product Replacement data*/
    public class ISOBAR_ProductData {
        public String codentify;
        public String market;
        public String casenumber;
        public String version;
        public String materialgroup;
        public String color;
        public String voucher;
    }
    /*Wrapper Class for Qure Product Replacement data for iSWAP*/
    public class iSWAP_ProductData {
        public String codentify;
        public String market;
        public String casenumber;
        public String version;
        public String materialgroup;
        public String color;
        public String voucher;
    }
    /*Wrapper class for metric set*/
    public class Metric_Set {
        public String host;//Environment URL https://pmi--masint1.cs88.my.salesforce.com
        public String name = SFDCSTRING;
        public String module;//Trigger_Module spice-integration
    }
    /*Wrapper class for custom details*/
    public class Custom_Details {
        public String version = VERSIONTEXT;//Version of Telemetry Engine 0.1
        public String type = TYPESTRING;
        public String name = NAMESTRING;

    }
}