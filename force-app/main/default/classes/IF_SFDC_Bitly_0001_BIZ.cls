/****************************************************************************************
  * @filename      : IF_SFDC_Bitly_0001_BIZ
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/04/08 8:52 오전
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_SFDC_Bitly_0001_BIZ_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/04/08 8:52 오전     i2max_shlee       Create
****************************************************************************************/
public with sharing class IF_SFDC_Bitly_0001_BIZ {
    /**
     * singleton
     */
    private static IF_SFDC_Bitly_0001_BIZ sInstance = null;
    public static IF_SFDC_Bitly_0001_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_SFDC_Bitly_0001_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_SFDC_Bitly_0001.InputBody pre(IF_SFDC_Bitly_0001.InputBody inputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */

        return inputBody;
    }

    /**
     * post logic
     */
    public IF_SFDC_Bitly_0001.OutputBody post(IF_SFDC_Bitly_0001.InputBody inputBody, IF_SFDC_Bitly_0001.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */



        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }


}