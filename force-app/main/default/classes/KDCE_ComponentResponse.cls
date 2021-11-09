/****************************************************************************************
 * @filename      : KDCE_ComponentResponse
 * @projectname   : PMK LocalDCE QA
 * @author        : i2max_Sukun
 * @date          : 3/3/21 11:00 AM
 * @group         : Service
 * @group-content :
 * @description   :
 * @tester        :KDCE_C360Controller_ts
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     3/3/21 11:00 AM            i2max_Sukun           Create
 ****************************************************************************************/
public with sharing class KDCE_ComponentResponse {
    @AuraEnabled public Map<String,Object> data {get;set;}

    public KDCE_ComponentResponse (){
        this.data = new Map<String,Object>();
    }
    public KDCE_ComponentResponse setData(String key,Object value){
        this.data.put(key,value);
        return this;
    }
    public KDCE_ComponentResponse setData(Map<String,Object> keyValues){
        this.data.putAll(keyValues);
        return this;
    }
    public Object getData(String key){
        return this.data.get(key);
    }
}