/**
 * Created by I2MAX on 2021-07-20.
 */

@IsTest(seeAllData = false)
public class CCR_TelemtryUtility_ts {

    static final String SAMPLETEXT = 'sampletext';
    /**
* Method Name :  testEventPush
* Arguments: null
* Return : void
* Description: This method is used to test platform event
**/
    @istest
    public static void testEventPush () {
        CCR_TelemtryUtility.Custom_Details customDetails = new CCR_TelemtryUtility.Custom_Details();
        List<CCR_TelemtryUtility.JSON_Payload> jsonPayLoadList =  new List<CCR_TelemtryUtility.JSON_Payload>();
        CCR_TelemtryUtility.JSON_Payload jsonPayLoad =  new CCR_TelemtryUtility.JSON_Payload();
        CCR_TelemtryUtility.Source_Details srcDetails = new CCR_TelemtryUtility.Source_Details();
        CCR_TelemtryUtility.App_Detail appDetail = new CCR_TelemtryUtility.App_Detail();
        CCR_TelemtryUtility.SFDC_Details sfdcDetail = new CCR_TelemtryUtility.SFDC_Details();
        CCR_TelemtryUtility.Metric_Set metricset = new CCR_TelemtryUtility.Metric_Set();
        CCR_TelemtryUtility.Custom_Details customDet = new CCR_TelemtryUtility.Custom_Details();
        CCR_TelemtryUtility.TriggerModule_Details triggModDetail= new CCR_TelemtryUtility.TriggerModule_Details();
        CCR_TelemtryUtility.Data_Details dataDetail =  new  CCR_TelemtryUtility.Data_Details();
        List<CCR_TelemtryUtility.ProductDetail> productDetail = new List<CCR_TelemtryUtility.ProductDetail>();
        CCR_TelemtryUtility.ProductDetail prodDetail = new CCR_TelemtryUtility.ProductDetail();
        List<CCR_TelemtryUtility.QureProductData> qureProductDetail = new List<CCR_TelemtryUtility.QureProductData>();
        CCR_TelemtryUtility.QureProductData qureProdDetail = new CCR_TelemtryUtility.QureProductData();
        //Order replacement from Qure Details
        qureProdDetail.codentify = SAMPLETEXT;
        qureProdDetail.demandwareprodcutId = SAMPLETEXT;
        qureProdDetail.market = SAMPLETEXT;
        qureProdDetail.casenumber = SAMPLETEXT;
        qureProdDetail.productcategory = SAMPLETEXT;
        qureProdDetail.Materialgroup = SAMPLETEXT;
        qureProdDetail.color = SAMPLETEXT;
        qureProductDetail.add(qureProdDetail);
        //AIT Details
        prodDetail.codentify = SAMPLETEXT;
        prodDetail.factory= SAMPLETEXT;
        prodDetail.packinglevel= SAMPLETEXT;
        prodDetail.market= SAMPLETEXT;
        prodDetail.codentifycounterfeitstatus= SAMPLETEXT;
        prodDetail.codentifyvaliditystatus= SAMPLETEXT;
        prodDetail.productvariant= SAMPLETEXT;
        prodDetail.branddifferentiator= SAMPLETEXT;
        prodDetail.brandfamily= SAMPLETEXT;
        productDetail.add(prodDetail);
        //Spice details
        dataDetail.decomposecodes_starttime = SAMPLETEXT;
        dataDetail.decomposecodes_endtime = SAMPLETEXT;
        dataDetail.decomposecodes_duration = SAMPLETEXT;
        dataDetail.getproductinfos_starttime = SAMPLETEXT;
        dataDetail.getproductinfos_endtime = SAMPLETEXT;
        dataDetail.getproductinfos_duration = SAMPLETEXT;
        dataDetail.full_codentifycheck_starttime = SAMPLETEXT;
        dataDetail.full_codentifycheck_endtime = SAMPLETEXT;
        dataDetail.full_codentifycheck_durationtime = SAMPLETEXT;
        dataDetail.data_spiceid = SAMPLETEXT;
        dataDetail.authenticate_starttime = SAMPLETEXT;
        dataDetail.authenticate_endtime = SAMPLETEXT;
        dataDetail.authenticate_duration = SAMPLETEXT;
        dataDetail.get_fullcontactdetailsbeforeputTospice_starttime = SAMPLETEXT;
        dataDetail.get_fullcontactdetailsbeforeputTospice_endtime = SAMPLETEXT;
        dataDetail.get_fullcontactdetailsbeforeputTospice_duration = SAMPLETEXT;
        dataDetail.post_contactdetails_startTime = SAMPLETEXT;
        dataDetail.post_contactdetails_endTime = SAMPLETEXT;
        dataDetail.post_contactdetails_duration = SAMPLETEXT;
        dataDetail.put_contactdetails_starttime = SAMPLETEXT;
        dataDetail.put_contactdetails_endtime = SAMPLETEXT;
        dataDetail.put_contactdetails_duration = SAMPLETEXT;
        dataDetail.get_fullcontactdetailsbeforedirectsavetosfdc_starttime = SAMPLETEXT;
        dataDetail.get_fullcontactdetailsbeforedirectsavetosfdc_endtime = SAMPLETEXT;
        dataDetail.get_fullcontactdetailsbeforedirectsavetosfdc_duration = SAMPLETEXT;
        dataDetail.save_fullcontactdetails_starttime = SAMPLETEXT;
        dataDetail.save_fullcontactdetails_endtime = SAMPLETEXT;
        dataDetail.save_fullcontactdetails_duration = SAMPLETEXT;
        dataDetail.save_contact_starttime = SAMPLETEXT;
        dataDetail.save_contact_endtime = SAMPLETEXT;
        dataDetail.save_contact_durationtime = SAMPLETEXT;
        dataDetail.save_acceptedtermsconditions_starttime = SAMPLETEXT;
        dataDetail.save_acceptedtermsconditions_endtime = SAMPLETEXT;
        dataDetail.save_acceptedtermsconditions_duration = SAMPLETEXT;
        dataDetail.save_optin_starttime = SAMPLETEXT;
        dataDetail.save_optin_endtime = SAMPLETEXT;
        dataDetail.save_optin_duration = SAMPLETEXT;
        dataDetail.post_logincreation_starttime = SAMPLETEXT;
        dataDetail.post_logincreation_endTime = SAMPLETEXT;
        dataDetail.post_logincreation_duration = SAMPLETEXT;
        dataDetail.getproductid_starttime =SAMPLETEXT;
        dataDetail.getproductid_endtime =SAMPLETEXT;
        dataDetail.getproductid_duration= SAMPLETEXT;
        dataDetail.replacementordercreation_starttime =SAMPLETEXT;
        dataDetail.replacementordercreation_endtime =SAMPLETEXT;
        dataDetail.replacementordercreation_duration = SAMPLETEXT;
        dataDetail.productdetails = productDetail;
        dataDetail.qureproductdata =qureProductDetail;
        //GENERIC PARAMETERS
        triggModDetail.marketcode = SAMPLETEXT;
        triggModDetail.type = SAMPLETEXT;
        triggModDetail.classname = SAMPLETEXT;
        triggModDetail.runninguser= SAMPLETEXT;
        triggModDetail.transactionstarttime = SAMPLETEXT;
        triggModDetail.transactionendtime =SAMPLETEXT;
        triggModDetail.transactionduration = SAMPLETEXT;
        triggModDetail.errorcodes =SAMPLETEXT;
        triggModDetail.numberoferrors = 0;
        triggModDetail.errorlogref =SAMPLETEXT;
        triggModDetail.transactiontrigger = SAMPLETEXT;
        triggModDetail.transactionID = SAMPLETEXT;
        triggModDetail.data = dataDetail;
        metricset.host = SAMPLETEXT;
        metricset.module = SAMPLETEXT;
        sfdcDetail.spice_integration = triggModDetail;
        sfdcDetail.aitWebservice_integration = triggModDetail;
        appDetail.id = SAMPLETEXT;
        appDetail.alias = SAMPLETEXT;
        srcDetails.environment = SAMPLETEXT;
        srcDetails.app = appDetail;
        srcDetails.sfdc= sfdcDetail;
        srcDetails.timestamp = string.valueof(system.now());
        srcDetails.type = SAMPLETEXT;
        srcDetails.metricset = metricset;
        srcDetails.custom = customDet;
        jsonPayLoad.index = SAMPLETEXT;
        jsonPayLoad.type = SAMPLETEXT;
        jsonPayLoad.source = srcDetails;
        jsonPayLoadList.add(jsonPayLoad);
        system.assert(jsonPayLoad!=null);
        test.startTest();
        CCR_TelemtryUtility.publishEvent(jsonPayLoad);
        CCR_TelemtryUtility.publishEvent(jsonPayLoadList);
        CCR_Constants cc = new CCR_Constants();
        test.stopTest();
    }
}