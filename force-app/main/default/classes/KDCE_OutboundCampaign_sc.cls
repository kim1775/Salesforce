/**
** @filename     : KDCE_OutboundCampaign_sc
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2021-04-14 오후 1:15
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
/*
     * 매일 오전 새벽1시 (schedule)
     * System.schedule(' v', '0 30 7 * * ? *', new KDCE_OutboundCampaign_sc());
 */
public with sharing class KDCE_OutboundCampaign_sc implements Schedulable {

    public void execute(SchedulableContext context){
        KDCE_OutboundCampaign_qu outboundCampaignQu = new KDCE_OutboundCampaign_qu();
        System.enqueueJob(outboundCampaignQu);
    }  

}