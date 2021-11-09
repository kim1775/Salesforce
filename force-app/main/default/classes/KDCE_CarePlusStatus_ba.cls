/****************************************************************************************
  * @filename      : KDCE_CarePlusStatus_ba
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-04-26
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log 
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2021-04-26             Park HE         Create
****************************************************************************************/
public with sharing class KDCE_CarePlusStatus_ba implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // 타겟 :: CCR_CarePlusDueDate__c 날짜가 지난 데이터(ex.today=0428, careplusduedate=0427)
        String soql =   ' SELECT Id, CCR_CarePlusStatus__c, CCR_CarePlusDueDate__c, KDCE_ReplacementSource__c, CCR_Override__c ' +
                        ' FROM Asset ' +
                        ' WHERE CCR_CarePlusDueDate__c < TODAY ' +
                        ' AND CCR_CarePlusStatus__c != \'Disenrolled\' AND CCR_CarePlusStatus__c != \'Expired\' ' ;
                        //' AND CCR_CarePlusStatus__c IN (\'Enrolled\', \'Not Enrolled\') ' ;
                        //' AND CCR_CarePlusStatus__c != \'Disenrolled\'' ; //디스인롤 제외하고 인롤/낫인롤인 경우에만 수정

        return Database.getQueryLocator(soql);
    }

    public void execute(Database.BatchableContext bc, List<Asset> scope) {
        System.debug('scope : ' + scope);
        List<Asset> updateAssetList = new List<Asset>();

        for (Asset asset : scope) {
            System.debug(asset);
            asset.CCR_CarePlusStatus__c = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_EXPIRED;
//            //Disenrolled 4 :: 한 번이라도 교환 받은 제품의 Warranty due date이 지났을 경우 -- ------> 워런티교환. (고장이 안나서 워런티 넘겻을때 )
//            if (asset.KDCE_ReplacementSource__c <> null && !asset.CCR_Override__c)
//                asset.CCR_CarePlusStatus__c = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_DISENROLLED;

//            // Not enroll 3 :: Override되어 교환이 되었음 -- 디스인롤 // 이전 기기의 값인데 ????
//            else if (asset.CCR_Override__c)
//                asset.CCR_CarePlusStatus__c = KDCE_GlobalValue.ASSET_CAREPLUSSTATUS_NOTENROLLED;
            updateAssetList.add(asset);
        }

        if(!updateAssetList.isEmpty()) update updateAssetList;
    }

    @SuppressWarnings('PMD')
    public void finish(Database.BatchableContext param1) {
    }


}