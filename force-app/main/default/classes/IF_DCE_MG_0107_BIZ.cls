/****************************************************************************************
  * File Name   : IF_DCE_MG_0107_BIZ
  * Description : IF_DCE_MG_0107_BIZ IF BIZ Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2021.05.17.    ldb3100    Create
****************************************************************************************/
public with sharing class IF_DCE_MG_0107_BIZ {
    /**
     * singleton
     */
    private static IF_DCE_MG_0107_BIZ sInstance = null;
    public static IF_DCE_MG_0107_BIZ getInstance() {
        if (sInstance == null) {
            sInstance = new IF_DCE_MG_0107_BIZ();
        }
        return sInstance;
    }

    /**
     * pre logic
     */
    public IF_DCE_MG_0107.InputBody pre(IF_DCE_MG_0107.InputBody inputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */


        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */

        return inputBody;
    }

    /**
     * post logic
     */
    public IF_DCE_MG_0107.OutputBody post(IF_DCE_MG_0107.InputBody inputBody, IF_DCE_MG_0107.OutputBody outputBody) {
        /* 업무 개발자에 의해 변경되어야 하는 부분 시작 */



        /* 업무 개발자에 의해 변경되어야 하는 부분 끝 */
        return outputBody;
    }


}