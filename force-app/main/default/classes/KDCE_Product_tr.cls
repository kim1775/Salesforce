/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-05-10 오후 2:12
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
    0.1     2021-05-10 오후 2:12     i2max_Junseok.Kwon        Create
****************************************************************************************/

public with sharing class KDCE_Product_tr extends TriggerHandler {
    public static Map<String, String> productCategoryPickVal = KDCE_Util.getPicklistValue('Product2', 'KDCE_ProductCategoryDescription__c');

    public override void beforeInsert() {
        setDefault();
    }
    public override void beforeUpdate() {
        setDefault();
    }

    private void setDefault() {

        Set<String> targetSet = new Set<String>();
        targetSet.add('KR04');
        targetSet.add('KR05');

        for(Product2 pd : (List<Product2>)Trigger.new){

            // CCR_OriginalDesignMarket__c 의 값이 KR04, KR05인 경우에 마젠토로 해당 제품 정보가 전송될 수 있도록 설정함
            if(targetSet.contains(pd.CCR_OriginalDesignMarket__c)) pd.KDCE_MG_SendTarget__c = true;

            // KDCE_ProductCategoryDescription에 대한 초기값 설정 (처음 생성될때는, Product Category와 같은 값으로 생성)
            if (Trigger.isInsert) {
                if (pd.CCR_Category__c != null && productCategoryPickVal.containsKey(pd.CCR_Category__c)) {
                    pd.KDCE_ProductCategoryDescription__c = pd.CCR_Category__c;
                }
            }
        }


    }
}