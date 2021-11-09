/****************************************************************************************
  * @filename      : KDCE_C360Controller_ts
  * @projectname   : PMK qa - KR
  * @author        : Park HE
  * @date          : 2021-06-17
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
    0.1     2021-06-17             Park HE         Create
****************************************************************************************/
@IsTest
private class KDCE_C360Controller_ts {
    @IsTest
    static void testBehavior() {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();

        Contact contact = KDCE_TestUtil.contactMember.clone(true);
        contact.KDCE_RentalConsumer__c = true;
        update contact;

        KDCE_C360Controller.getContact(contact.Id);

        Map<String, Object> testMap = new Map<String, Object>{contact.Id => contact};

        KDCE_ComponentResponse response = new KDCE_ComponentResponse();
        response.setData(testMap);
        response.getData(contact.Id);

    }
}