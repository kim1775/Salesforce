/**
** @filename     : KDCE_OutboundCampaign_qu
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2021-04-14 오후 12:44
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
public with sharing class KDCE_OutboundCampaign_qu implements Queueable {

    /**
     * @param BC
     * KDCE_OutboundCampaign_ba 는 삭제.
     * external Id - master부터 name으로 upsert 치면 조회 할 필요가 없다.
     * year & month에는 Genesys Cloud Campaign Setting, Genesys Cloud Campaign Schedule 필드 비워두기/
     * 매일 오전 새벽1시 (schedule)
     * @return
     */

    Date searchDate;
    public KDCE_OutboundCampaign_qu() {
        this.searchDate = Date.today();
    }

    public KDCE_OutboundCampaign_qu(Date searchDate) {
        if (searchDate != null) {
            this.searchDate = searchDate;
        } else {
            this.searchDate = Date.today();
        }
    }


    public void execute(QueueableContext context) {

        List<Campaign> scope = [
                SELECT Id,Name,Type,IsActive,Status,StartDate,EndDate,ExternalId__c
                FROM Campaign
                WHERE Type = 'Outbound Master' AND IsActive = TRUE
        ];

        //Oubound Master기준으로 Year Campaign생성
        List<Campaign> campaignYearList = new List<Campaign>();
        for (Campaign ca : scope) {
            Campaign newCampaign = new Campaign();
            newCampaign.ParentId = ca.Id;
            newCampaign.Name = ca.Name + ' ' + searchDate.year();
            newCampaign.Type = 'Outbound Program';
            newCampaign.StartDate = Date.newInstance(searchDate.year(), 1, 1);
            newCampaign.EndDate = Date.newInstance(searchDate.year(), 12, 31);
            newCampaign.ExternalId__c = ca.ExternalId__c + '_' + searchDate.year();
            campaignYearList.add(newCampaign);
        }
        upsert campaignYearList ExternalId__c;

        //Year 기준으로 Month Campaign생성
        List<Campaign> campaignMonthList = new List<Campaign>();
        for (Campaign cam : campaignYearList) {
            Campaign newCampaign2 = new Campaign();
            newCampaign2.ParentId = cam.Id;
            newCampaign2.Name = cam.Name + '-' + Util.lpad(searchDate.month(), '0', 2);
            newCampaign2.Type = 'Outbound Program';
            newCampaign2.StartDate = Date.newInstance(searchDate.year(), searchDate.month(), 1);
            newCampaign2.EndDate = Date.newInstance(searchDate.year(), searchDate.month() + 1, 1).addDays(-1);
            newCampaign2.ExternalId__c = cam.ExternalId__c + '_' + Util.lpad(searchDate.month(), '0', 2);
            campaignMonthList.add(newCampaign2);
        }
        upsert campaignMonthList ExternalId__c;
        List<Campaign> monthList = [
                SELECT Id,Name,ExternalId__c,Parent.Parent.purecloud__PureCloud_Campaign_Setting__c, Parent.Parent.purecloud__PureCloud_Campaign_Schedule__c
                FROM Campaign
                WHERE Id IN :campaignMonthList
        ];

        //Year 기준으로 Day Campaign생성
        //Day는 Master의 GC Setting 값 매핑
        List<Campaign> campaignDayList = new List<Campaign>();
        for (Campaign camp : monthList) {
            Campaign newCampaign3 = new Campaign();
            newCampaign3.ParentId = camp.Id;
            newCampaign3.Name = camp.Name + '-' + Util.lpad(searchDate.day(), '0', 2);
            newCampaign3.Type = 'Outbound Program';
            newCampaign3.StartDate = searchDate;
            newCampaign3.EndDate = searchDate;
            newCampaign3.IsActive = true;
            newCampaign3.purecloud__PureCloud_Campaign_Setting__c = camp.Parent.Parent.purecloud__PureCloud_Campaign_Setting__c;
            newCampaign3.purecloud__PureCloud_Campaign_Schedule__c = camp.Parent.Parent.purecloud__PureCloud_Campaign_Schedule__c;
            newCampaign3.ExternalId__c = camp.ExternalId__c + '_' + Util.lpad(searchDate.day(), '0', 2);
            campaignDayList.add(newCampaign3);
        }
        upsert campaignDayList ExternalId__c;

    }


}