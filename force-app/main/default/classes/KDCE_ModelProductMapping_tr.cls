/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-06-14 오전 9:21
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
    0.1     2021-06-14 오전 9:21     i2max_Junseok.Kwon        Create
****************************************************************************************/

public without sharing class KDCE_ModelProductMapping_tr extends TriggerHandler{

    public override void beforeInsert() {
        setDefault();
    }

    public override void beforeUpdate() {
        setDefault();
    }

    private void setDefault(){

        for(ModelProductMapping__c row : (List<ModelProductMapping__c>)Trigger.new){
            row.RecordKey__c = row.ModelNumber__c + '_' + row.Color__c;
        }
    }
}