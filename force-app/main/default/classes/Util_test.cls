/****************************************************************************************
  * @filename      : 
  * @projectname   : 
  * @author        : i2max_Junseok.Kwon
  * @date          : 2021-02-08 오후 1:58
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
    0.1     2021-02-08 오후 1:58     i2max_Junseok.Kwon        Create
****************************************************************************************/

@SuppressWarnings('PMD')
@isTest
private class Util_test {

    @testSetup
    static void setData() {
    }

    static testMethod void utilTest() {

        Test.startTest();
        Util.getRecordTypeId('a', 'a');
        Util.yyyy_mm_dd(Datetime.now());
        Util.yyyy_mm(Datetime.now());
        Util.yyyymmdd(Datetime.now());
        Util.yymmddToDate_exceedYear('20190101');
        Util.yymmddToDateTime('20190101');
        Util.yyyy_mm_dd_hh_mm_ssToDate('2017-07-19 13:37:10');
        Util.yyymmdd_hhmmssToDateTime('20170719 13:37:10');

        system.assertEquals(Util.getDateFormat('ko_KR'), 'yyyy. M. d a h:mm');

        system.assertEquals(Util.isNull(null), true);

        system.assertEquals(Util.nvlInt(null), 0);
        system.assertEquals(Util.nvlDec(null), 0);
        system.assertEquals(Util.nvlStr(null), '');
        system.assertEquals(Util.nvlStr('s'), 's');

        system.assertEquals(Util.isNumber('123'), true);
        system.assertEquals(Util.isNumber('12x'), false);

        system.assertEquals(Util.lpad('123', '0', 5), '00123');
        system.assertEquals(Util.lpad(123, '0', 5), '00123');
        system.assertEquals(Util.rpad('123', '0', 5), '12300');

        system.assertNotEquals(Util.strDate(), '');
        system.assertNotEquals(Util.strDate('-'), '');
        system.assertNotEquals(Util.strYYMM(), '');
        system.assertNotEquals(Util.strYYMM(Date.today()), '');
        system.assertEquals(Util.strNextYYMM('201604'), '201605');
        system.assertEquals(Util.strPreYYMM('201604'), '201603');
        system.assertNotEquals(Util.dateFormat(Date.today(), '-'), '');
        system.assertNotEquals(Util.dateFormat(Date.today()), '');

        system.assertEquals(Util.getMax('Topic'), 1);
        system.assertEquals(Util.getMaxMonth('Topic'), 1);
        system.assertNotEquals(Util.getName(4, 'AC'), '');
        system.assertNotEquals(Util.getName('Topic', 'AC'), '');
        system.assertNotEquals(Util.getNameOfMonth('Topic', 'AC'), '');
        system.assertNotEquals(Util.getNameOfMonth(4, 'AC'), '');
        Util.yyyy_mm_dd(Date.today());
        Util.yyyy_mm(Date.today());
        Util.yyyymmdd(Date.today());
        Util.yymmddToDate('20150101');
        Util.str2Date('20150825');
        Util.str2Dt('201508251137');
        Util.byteSize('123가나다abc');
        Util.round(3.141592);
        Util.ceil(3.141592);
        Util.ceil(3.141592, 2);
        Util.floor(3.141592);
        Util.floor(3.141592, 2);
        //Util.getCommonCoode(UserInfo.getUserId(), 'TypeName');
        Util.debug('msg', true);

        insert new Topic(Name = 'ACC-001');
        system.assertEquals(Util.getMax('Topic'), 2);
        system.assertEquals(Util.getMaxMonth('Topic'), 2);
        system.assertNotEquals(Util.getName(4, 'AC'), '');
        system.assertNotEquals(Util.getName('Topic', 'AC'), '');
        system.assertNotEquals(Util.getNameOfMonth('Topic', 'AC'), '');
        system.assertNotEquals(Util.getNameOfMonth(4, 'AC'), '');


        system.assertEquals(Util.str2Date('20150825'), Date.newInstance(2015, 8, 25));
        system.assertEquals(Util.str2Date('2015-08-25'), Date.newInstance(2015, 8, 25));
        system.assertEquals(Util.str2Dt('201508251137'), DateTime.newInstance(2015, 08, 25, 11, 37, 0));
        system.assertEquals(Util.str2Dt('20150825113723'), DateTime.newInstance(2015, 08, 25, 11, 37, 23));

        system.assertEquals(Util.byteSize('123가나다abc'), 12);
        system.assertEquals(Util.round(3.141592), 3.14);
        system.assertEquals(Util.ceil(3.141592), 3.15);
        system.assertEquals(Util.floor(3.141592), 3.14);
        system.assertEquals(Util.isSAPEmpty('00000'), true);

        List<User> l = [SELECT Id, Name FROM USER limit 1];
        List<String> l2 = Util.getListValue(l, 'Name');
        system.assertEquals(l.get(0).Name, l2.get(0));


        system.assertEquals(Util.formatDate('20160801', '-'), '2016-08-01');
        system.assertEquals(Util.formatDate('20160801'), '2016-08-01');
        system.assertEquals(Util.revertMinus('1000-'), -1000);
        system.assertEquals(Util.substring('abc', 1, 3), 'bc');
        system.assertEquals(Util.isValidDate('20140509'), true);
        system.assertEquals((Util.splitAddr('부산광역시 금정구 장전동 산 30번지 부산대학교 의과대학 대학원 예방의학전공 123동 123호')).get('firstAddr'), '부산광역시 금정구 장전동 산 30번지 부산대학교');

        /*
        Profile p = [SELECT id FROM Profile WHERE Name ='System Admin'];

        User u = new User(Alias = 'testkor', Email='testkorea@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, DepartmentName__c = 'test',
            TimeZoneSidKey='America/Los_Angeles', UserName='testkorea@testorg.com');

        system.runAs(u){
            system.assertEquals(Util.getCommonCode('Country').size(), 10);
        }

        User us2 = [SELECT id FROM User WHERE Profile.Name ='System Admin' limit 1];
        system.assertEquals(Util.getCommonCode('Country').size(), 10);
        */

        Util.getParentHeader();

/*
		system.assertEquals(Util.phoneNoCheck('0211112222'), '02-1111-2222');
		system.assertEquals(Util.phoneNoCheck('03111112222'), '031-1111-2222');
		system.assertEquals(Util.phoneNoCheck('12345678'), '1234-5678');
		system.assertEquals(Util.phoneNoCheck('1234567'), '123-4567');
		system.assertEquals(Util.phoneNoCheck('82212345678'), '82-2-1234-5678');
		system.assertEquals(Util.phoneNoCheck('8221234567'), '82-2-123-4567');
		system.assertEquals(Util.phoneNoCheck('820212345678'), '82-02-1234-5678');
		system.assertEquals(Util.phoneNoCheck('82021234567'), '82-02-123-4567');
		system.assertEquals(Util.phoneNoCheck('823212345678'), '82-32-1234-5678');
		system.assertEquals(Util.phoneNoCheck('8203212345678'), '82-032-1234-5678');
*/
        Test.stopTest();
    }

}