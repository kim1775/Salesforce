/****************************************************************************************
  * @filename      : KDCE_ContactCaseSummary
  * @projectname   : PMK LocalDCE QA
  * @author        : i2max_JE Yoon
  * @date          : 2021-04-13
  * @group         :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1  2021-04-13          i2max_JE Yoon             Create
****************************************************************************************/
public with sharing class KDCE_ContactCaseSummary {

//    final static Map<String, String> RECORDTYPE_NAME_MAP_ORDER = new Map<String, String>{
//            'Order NORMAL' => 'E-commerce order',
//            'Order RENTAL' => 'Rental'
//    };

    /**
     * @description 컨택 아이디와 sobjectName을 이용해 컨텍에 해당하는 sObject의 레코드를 가져옴(Case/Order/Asset)
     * @param recordId (String)
     * @return response (KDCE_ComponentResponse)
     * @author JE Yoon
     **/
    @AuraEnabled
    public static KDCE_ComponentResponse getSummaryInfo(String recordId) {
        KDCE_ComponentResponse response = new KDCE_ComponentResponse();
        Map<String, Integer> caseMap = new Map<String, Integer>();
        Map<String, Integer> caseIBOBMap = new Map<String, Integer>{
                'Inbound' => 0, 'Outbound' => 0
        };
        Map<String, Integer> orderMap = new Map<String, Integer>();
        Map<String, Integer> assetMap = new Map<String, Integer>();
        String caseInKorean;
        String caseChannel;
        String ibob;
        String orderType;
        Map<String, Integer> caseChannelMap = new Map<String, Integer>();
        Map<String, String> recordTypeId_Name_Map_Case = KDCE_Util.getRecordDeveloperNameBySObject('Case');
        Map<String, String> recordTypeId_Name_Map_Order = KDCE_Util.getRecordDeveloperNameBySObject('KDCE_Order__c');

        Contact contact;
        List<Contact> contactList = [
                SELECT
                (SELECT Id, RecordType.DeveloperName,CCR_Inbound_Outbound__c,toLabel(CCR_ContactType__c) FROM Cases),
                (SELECT Id, RecordType.DeveloperName FROM Orders__r WHERE RecordType.DeveloperName IN :recordTypeId_Name_Map_Order.keySet()),
                (SELECT Id, CCR_ReplacementSponsored_By__c FROM Assets WHERE CCR_ReplacementSponsored_By__c != null)
                FROM Contact
                WHERE Id = :recordId
                LIMIT 1
        ];
        contact = contactList[0];
        System.debug('=== contact : ' + contact);
        if (contact != null) {
            System.debug('=== contact.Cases : ' + contact.Cases);
            //List<Case> caseList = [SELECT Id FROM Case WHERE ContactId  =:recordId];

            for (Case c : contact.Cases) {
                caseInKorean = recordTypeId_Name_Map_Case.get(c.RecordType.DeveloperName);
                if(!Util.isEmpty(caseInKorean)){
                    if (caseMap.get(caseInKorean) == null) {
                        caseMap.put(caseInKorean, 1);
                    } else {
                        caseMap.put(caseInKorean, caseMap.get(caseInKorean) + 1);
                    }
                }
                caseChannel =c.CCR_ContactType__c;
                if(!Util.isEmpty(caseChannel)){
                    if (caseChannelMap.get(caseChannel) == null) {
                        caseChannelMap.put(caseChannel, 1);
                    } else {
                        caseChannelMap.put(caseChannel, caseChannelMap.get(caseChannel) + 1);
                    }
                }

                if (c.CCR_Inbound_Outbound__c == null) continue;
                ibob = c.CCR_Inbound_Outbound__c;
                if (caseIBOBMap.get(ibob) == null) {
                    caseIBOBMap.put(ibob, 1);
                } else {
                    caseIBOBMap.put(ibob, caseIBOBMap.get(ibob) + 1);
                }

            }

            for (KDCE_Order__c order : contact.Orders__r) {
                orderType = recordTypeId_Name_Map_Order.get(order.RecordType.DeveloperName);
                if (orderMap.get(orderType) == null) {
                    orderMap.put(orderType, 1);
                } else {
                    orderMap.put(orderType, orderMap.get(orderType) + 1);
                }
            }

            for (Asset asset : contact.Assets) {
                if (assetMap.get(asset.CCR_ReplacementSponsored_By__c) == null) {
                    assetMap.put(asset.CCR_ReplacementSponsored_By__c, 1);
                } else {
                    assetMap.put(asset.CCR_ReplacementSponsored_By__c, assetMap.get(asset.CCR_ReplacementSponsored_By__c) + 1);
                }
            }
            response.setData('caseIBOBs', returnInfoWrappers(caseIBOBMap));
            response.setData('cases', returnInfoWrappers(caseMap));
            response.setData('caseChannelList', returnInfoWrappers(caseChannelMap));
            response.setData('orders', returnInfoWrappers(orderMap));
            response.setData('assets', returnInfoWrappers(assetMap));


        }

        return response;
    }

    /**
     * @description string, integer 맵을 받아 이를 InfoWrapper 형태로 치환해 반환
     * @param stringIntegerMap (Map<String, Integer>)
     * @return infoWrapperList(List<InfoWrapper>)
     * @author JE Yoon
     **/
    private static List<InfoWrapper> returnInfoWrappers(Map<String, Integer> stringIntegerMap) {
        List<InfoWrapper> infoWrapperList = new List<InfoWrapper>();
        InfoWrapper infoWrapper;

        for (String recordName : stringIntegerMap.keySet()) {
            infoWrapper = new InfoWrapper();
            infoWrapper.type = recordName;
            infoWrapper.count = stringIntegerMap.get(recordName);
            infoWrapperList.add(infoWrapper);
        }

        infoWrapperList.sort();
        return infoWrapperList;
    }

    public class InfoWrapper implements Comparable {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Integer count { get; set; }

        /**
         * @description infoWrapper 리스트의 레코드를 type을 기준으로 오름차순 정렬
         * @param compareTo (Object)
         * @return Integer
         * @author JE Yoon
         **/
        public Integer compareTo(Object compareTo) {
            InfoWrapper infoWrapper = (InfoWrapper) compareTo;
            if (type == infoWrapper.type) return 0;
            if (type > infoWrapper.type) return 1;
            return -1;
        }
    }

}