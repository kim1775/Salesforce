/****************************************************************************************
  * @filename      : IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_shlee 
  * @date          : 2021/02/18 3:37 오후
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2021/02/18 3:37 오후     i2max_shlee       Create
****************************************************************************************/
public with sharing class IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ {

    private static IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ sInstance = null;
    public static IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ getInstance() {
        if(sInstance == null){
            sInstance = new IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL_BIZ();
        }
        return sInstance;
    }

    public IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputBody pre(IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputBody inputBody, IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.OutputBody outputBody) {

        return inputBody;
    }

    public IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.OutputBody post(IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.InputBody inputBody, IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.OutputBody outputBody) {

        IF_DCE_Korea_SFDC_REST_DYNAMIC_SOQL.T_DATA inputData = inputBody.T_DATA[0];

        String dynamicSoql      = inputData.DYNAMIC_SOQL;
        String unEncrypt        = inputData.UN_ENCRYPT;
        System.debug('dynamicSoql: '+dynamicSoql);

//        if(!'Y'.equals(unEncrypt)) {
//            IfStaticValue__c staticValue = IfStaticValue__c.getInstance('Magento');
//            String algorithm  	= staticValue.ENCRYPT_ALGORITHM__c;
//            String vector		= staticValue.ENCRYPT_VECTOR__c;
//            String privateKey	= staticValue.ENCRYPT_PRIVATE_KEY__c;
//
//            dynamicSoql 	= IF_Comm.cryptoDecrypt(algorithm, vector, privateKey, dynamicSoql);
//        }

        //Validation
        if (Util.isEmpty(dynamicSoql)) {
            throw new IF_Base.IFException('The Mandatory Parameter is Required.');
        }

        System.debug('dynamicSoql.toLowerCase().trim() : '+dynamicSoql.toLowerCase().replace(' ',''));
        System.debug('dynamicSoql contains(\'fromcontact\') : '+dynamicSoql.toLowerCase().replace(' ','').contains('fromcontact'));
        if (dynamicSoql.toLowerCase().replace(' ','').contains('fromcontact')) {
            throw new IF_Base.IFException('The Contact info can not be call by dynamic soql API.');
        }

        List<SObject> objectList = DataBase.query(dynamicSoql);

        outputBody.T_DATA           = objectList;

        outputBody.ifAggregation    = IF_Comm.convertEmpty(inputBody.ifAggregation);
        outputBody.ifSplitCnt       = IF_Comm.convertEmpty(inputBody.ifSplitCnt);
        outputBody.ifRcvCnt         = IF_Comm.convertEmpty(objectList.size());
        outputBody.ifRetnCnt        = IF_Comm.convertEmpty(objectList.size());

        return outputBody;
    }
}