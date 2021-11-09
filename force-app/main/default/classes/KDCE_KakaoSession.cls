/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-08-05 오후 3:47
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-08-05 오후 3:47     i2max_Junseok.Kwon        Create
****************************************************************************************/

public with sharing class KDCE_KakaoSession {

    @Future(callout=true)
    public static void closeSession(Id kakaoConsultId){
        //System.debug('=== kakaoConsultId : ' + kakaoConsultId);
        if(!Test.isRunningTest()) EndSessionCallout.process(kakaoConsultId);
    }
}