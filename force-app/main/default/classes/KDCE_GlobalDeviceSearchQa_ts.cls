/****************************************************************************************
  * @filename      : KDCE_GlobalDeviceSearchQa_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-18
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
    0.1     2021-06-18             Park HE         Create
****************************************************************************************/

@IsTest
private class KDCE_GlobalDeviceSearchQa_ts {
    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }
    @IsTest
    static void saveTest(){
        Contact con = KDCE_TestUtil.contactMember.clone(true);
        String productListJSONString = '[{"ItemId":"25ZM55219EAX","AlternateId":"25ZM55219EAX","ProductionDateTimeUTC":"2021-02-03T01:04:00.000Z","FactoryCode":"FL","FactoryName":"FLEXTRONICS","ProductionLineCode":93,"ProductBrandDifferentiator":"IQOS","ProductBrandFamily":"3DIP","ProductCode":"DK001551.00","ProductDescription":"KIT IQOS 3 DUO IRIDESCENT PURPLE OPK 1","ProductType":"RRP Kit / P1","OriginalDesignMarketCode":"JP04","Model":"IQOS","Children":{"Item":[{"ItemId":"T3NWRL3557WE1W","InternalId":"0x002700480004C0B07D8A","AlternateId":"T3NWRL3***WE1W","ProductionDateTimeUTC":"2021-01-28T23:04:40.000Z","FactoryCode":"FL","FactoryName":"FLEXTRONICS","ProductionLineCode":5,"ProductBrandDifferentiator":"IQOS","ProductBrandFamily":"3DIP","ProductCode":"DVC1214","ProductDescription":"HTP Holder IQOS 3 DUO IRIDESCENT PURPLE A1406 - A1406 RND IPL3.1 Generic Holder (IR Purple) NB","ProductType":"RRP Holder / P1","OriginalDesignMarketCode":"Unknown","Model":"IQOS"},{"ItemId":"T7R84BXHGU006W","InternalId":"0x002800530004009E8B30","AlternateId":"T7R84BX***006W","ProductionDateTimeUTC":"2021-01-29T15:37:30.000Z","FactoryCode":"FL","FactoryName":"FLEXTRONICS","ProductionLineCode":36,"ProductBrandDifferentiator":"IQOS","ProductBrandFamily":"3DIP","ProductCode":"DVC1336","ProductDescription":"Pocket Charger IQOS 3 DUO IRIDESCENT PURPLE A1505 - A1505 RND IPL3.1 Generic Charger (NCM)-FL","ProductType":"RRP Charger / P1","OriginalDesignMarketCode":"Unknown","Model":"IQOS"}]}}]';
        String materialListJSONString = '[{"ItemId":"T3NWRL3557WE1W","InternalId":"0x002700480004C0B07D8A","AlternateId":"T3NWRL3***WE1W","ProductionDateTimeUTC":"2021-01-28T23:04:40.000Z","FactoryCode":"FL","FactoryName":"FLEXTRONICS","ProductionLineCode":5,"ProductBrandDifferentiator":"IQOS","ProductBrandFamily":"3DIP","ProductCode":"DVC1214","ProductDescription":"HTP Holder IQOS 3 DUO IRIDESCENT PURPLE A1406 - A1406 RND IPL3.1 Generic Holder (IR Purple) NB","ProductType":"RRP Holder / P1","OriginalDesignMarketCode":"Unknown","Model":"IQOS"},{"ItemId":"T7R84BXHGU006W","InternalId":"0x002800530004009E8B30","AlternateId":"T7R84BX***006W","ProductionDateTimeUTC":"2021-01-29T15:37:30.000Z","FactoryCode":"FL","FactoryName":"FLEXTRONICS","ProductionLineCode":36,"ProductBrandDifferentiator":"IQOS","ProductBrandFamily":"3DIP","ProductCode":"DVC1336","ProductDescription":"Pocket Charger IQOS 3 DUO IRIDESCENT PURPLE A1505 - A1505 RND IPL3.1 Generic Charger (NCM)-FL","ProductType":"RRP Charger / P1","OriginalDesignMarketCode":"Unknown","Model":"IQOS"}]';

        Test.startTest();

        KDCE_GlobalDeviceSearchQa.save(con.Id, productListJSONString, materialListJSONString);
        KDCE_GlobalDeviceSearchQa.search('codentifyTest0');
        Test.stopTest();
    }

}