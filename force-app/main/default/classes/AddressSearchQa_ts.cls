/**
** @filename     : AddressSearchQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-22 오후 2:35
* @group         :
* @group-content :
* @description   : 행안부 대한민국 주소 API 이용 주소검색 Lightning Component
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
@IsTest
private class AddressSearchQa_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {
        Contact contact = KDCE_TestUtil.contactMember;
        Account account = KDCE_TestUtil.account;
        AddressSearchQa.init(contact.Id);

        //sObjectName == 'Account'
        AddressSearchQa.save('billingaddress', 'Account', account.Id, '경기도', '이천시', '이장로 409', '467-811', 'address1', 'address2');
        AddressSearchQa.save('shippingaddress', 'Account', account.Id, '경기도', '이천시', '이장로 409', '467-811', 'address1', 'address2');

        //sObjectName == 'Contact'
        AddressSearchQa.save('firstAddress', 'Contact', contact.Id, '경기도', '이천시', '이장로 409', '467-811', 'address1', 'address2');
        AddressSearchQa.save('otheraddress', 'Contact', contact.Id, '경기도', '이천시', '이장로 409', '467-811', 'address1', 'address2');

        //sObjectName == 'Lead'
        Lead lead = new Lead(
                LastName = 'Lead', Company = 'Company', Street = '경기도', City = '이천시', Country = '이장로 409', PostalCode = '467-811'
        );
        insert lead;
        AddressSearchQa.save('billingaddress', 'Lead', lead.Id, '경기도', '이천시', '이장로 409', '467-811', 'address1', 'address2');
        AddressSearchQa.save('shippingaddress', 'Lead', lead.Id, '경기도', '이천시', '이장로 409', '467-811', 'address1', 'address2');

//        TestDataSalesFactory.init();
//        TestDataBaseFactory.init();

//        AddressSearchQa.init(TestDataBaseFactory.agencyAccount.Id);
//
//        Account acc = TestDataBaseFactory.businessOfficeAccount;
//        Contact con = TestDataBaseFactory.agencyContact;
//        Lead    le  = TestDataSalesFactory.baseLead;
//
//
//        //sObjectName == 'Contact'
//        AddressSearchQa.save('mailingaddress','Contact',con.Id,'경기도','이천시','이장로 409','467-811');
//        AddressSearchQa.save('otheraddress','Contact',con.Id,'경기도','이천시','이장로 409','467-811');
//
//        //sObjectName == 'Lead'
//        AddressSearchQa.save('test','a',le.Id,'경기도','이천시','이장로 409','467-811');
//
//        // search callOut

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"common":{"errorMessage":"정상","countPerPage":"10","totalCount":"1","errorCode":"0","currentPage":"1"},"juso":[{"detBdNmList":"","engAddr":"137, Mapo-daero, Mapo-gu, Seoul","rn":"마포대로","emdNm":"공덕동","zipNo":"04143","roadAddrPart2":" (공덕동)","emdNo":"02","sggNm":"마포구","jibunAddr":"서울특별시 마포구 공덕동 473 KPX빌딩","siNm":"서울특별시","roadAddrPart1":"서울특별시 마포구 마포대로 137","bdNm":"KPX빌딩","admCd":"1144010200","udrtYn":"0","lnbrMnnm":"473","roadAddr":"서울특별시 마포구 마포대로 137 (공덕동)","lnbrSlno":"0","buldMnnm":"137","bdKdcd":"0","liNm":"","rnMgtSn":"114402113001","mtYn":"0","bdMgtSn":"1144010200104730000000001","buldSlno":"0"}]}'));
            AddressSearchQa.search(10, 1, 'Test');
        Test.stopTest();
    }
}