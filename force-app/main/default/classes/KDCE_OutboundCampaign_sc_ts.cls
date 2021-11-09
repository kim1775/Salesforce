/**
** @filename     : KDCE_OutboundCampaign_sc_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2021-05-12 오후 2:22
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
@IsTest
private class KDCE_OutboundCampaign_sc_ts {

    @TestSetup
    static void setup() {
        TestDataBaseFactory.createOutboundCampaign(true);
    }

    /**
     *  KDCE_OutboundCampaign_sc pass
     */
    @IsTest
    static void test01() {
        KDCE_OutboundCampaign_sc sc = new KDCE_OutboundCampaign_sc();
        System.schedule('test', '0 30 7 * * ? *', sc);
    }


    @IsTest
    static void test02() {
        KDCE_OutboundCampaign_qu sc = new KDCE_OutboundCampaign_qu(Date.newInstance(System.today().year(), System.today().month(), 15));
        System.enqueueJob(sc);
    }

}