/****************************************************************************************
  * @filename      : i2SEMA_Util_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/22 7:59 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_Util_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/22 7:59 PM     i2max_shlee       Create
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_Util_ts {

    /**
     * @description Test Data 생성
     */
    @TestSetup static void setup(){

        i2SEMA_TestDataUtil.getSMSNotification();
    }

    /**
     * @description notification 재시도 initialize 실행
     */
    static testmethod void testCase01(){
        Notification__c notification = null;
        System.assertEquals(i2SEMA_Util.isEmpty(notification), true);
        System.assertEquals(i2SEMA_Util.isNotEmpty(notification), false);

        String test01 = '';
        System.assertEquals(i2SEMA_Util.isEmpty(test01), true);
        System.assertEquals(i2SEMA_Util.isNotEmpty(test01), false);

//        System.assertEquals(i2SEMA_Util.isEmpty(i2SEMA_TestDataUtil.smsTemplate), false);
//        System.assertEquals(i2SEMA_Util.isNotEmpty(i2SEMA_TestDataUtil.smsTemplate), true);

        String test02 = 'null';
        System.assertEquals(i2SEMA_Util.convertIFString(test02), '');
        System.assertNotEquals(i2SEMA_Util.convertEmpty(test02), '');

        String test03 = '010-2288-4132';
        System.assertEquals(i2SEMA_Util.convertPhoneNumberFormat(test03), '01022884132');

        Map<String,String> picklistVal = i2SEMA_Util.getPicklistValue('NotificationTemplate__c','Channel__c');
        System.debug('picklistVal : '+picklistVal);
        System.assertEquals(picklistVal.get('0'), 'SMS');
        System.assertEquals(picklistVal.get('2'), 'MMS');
        System.assertEquals(picklistVal.get('3'), 'LMS');

        List<String> sObjectTypes = new List<String>{'NotificationTemplate__c','Notification__c','NotificationGroup__c'};
        Map<String,Object> sObjectTypeMap = i2SEMA_Util.getSObjectDescribe(sObjectTypes);
        System.debug(sObjectTypeMap.get('NotificationTemplate__c'));
//        System.assertEquals(sObjectTypeMap.get('NotificationTemplate__c'));

        System.assertEquals(i2SEMA_Util.isValidMessageLength('0', '안녕하세요.'), true);
        System.assertEquals(i2SEMA_Util.isValidMessageLength('0', '안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.안녕하세요.'), false);
        System.assertEquals(i2SEMA_Util.isValidMessageLength('2', '안녕하세요.'), true);
        System.assertEquals(i2SEMA_Util.isValidMessageLength('3', '안녕하세요.'), true);
        System.assertEquals(i2SEMA_Util.isValidMessageLength('1009', '안녕하세요.'), true);
        System.assertEquals(i2SEMA_Util.isValidMessageLength('1008', '안녕하세요.'), true);
        System.assertEquals(i2SEMA_Util.isValidMessageLength('10', '안녕하세요.'), true);


        Datetime myDateTime = Datetime.newInstance(1997, 1, 31, 7, 8, 16);
        System.assertEquals(i2SEMA_Util.convertSchedule(myDateTime), '0 8 7 31 1 ? 1997');

        System.assertEquals(i2SEMA_Util.getFindURLs('String test : www.google.com'), null);

        NotificationTemplate__c nt = new NotificationTemplate__c(Content__c = 'test %%LABEL1%% %%LABEL2%% %%LABEL3%% %%LABEL4%% %%LABEL5%%',
                LABEL1__c = true,
                LABEL2__c = true,
                LABEL3__c = true,
                LABEL4__c = true,
                LABEL5__c = true,
                Channel__c = '0' );
        insert nt;
        System.debug('nt  ' + nt.fm_LABELCount__c);

        Contact con = i2SEMA_TestDataUtil.getContact();
        con.KDCE_ExternalId__c = 'testExternalId';
        update con;

        List<i2SEMA_Util.Receiver> receivers = new List<i2SEMA_Util.Receiver>();
        List<String> labels     = new List<String>{'공덕 아이코스점','서울 마포구 마포대로 137','09:00~18:00','test1', 'test2'};
        i2SEMA_Util.Receiver receiver = new i2SEMA_Util.Receiver();
        receiver.receiverExtId  = 'testExternalId';
        receiver.labels         = labels;
        receivers.add(receiver);

        i2SEMA_Util.I2Notification msg = new i2SEMA_Util.I2Notification();
        System.debug('nt.KDCE_ExternalId__c ' + nt.KDCE_ExternalId__c);
        msg.templateExtId   = 'nt.KDCE_ExternalId__c';
        msg.receiverType    = 'Contact';
        msg.receivers       = receivers;

        i2SEMA_Util.sendNotification(msg);
        List<String> btnURLs     = new List<String>{'test'};

        receivers = new List<i2SEMA_Util.Receiver>();
        receiver.btnURLs = btnURLs;
        receivers.add(receiver);

        msg = new i2SEMA_Util.I2Notification();
        System.debug('nt.KDCE_ExternalId__c ' + nt.KDCE_ExternalId__c);
        msg.templateExtId   = 'nt.KDCE_ExternalId__c';
        msg.receiverType    = 'Contact';
        msg.receivers       = receivers;
        i2SEMA_Util.sendNotification(msg);

        i2SEMA_Util.runtest();






    }
}