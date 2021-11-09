/****************************************************************************************
  * @filename      : KDCE_LiveChatTranscript_tr_ts
  * @projectname   : [PMI] QA 20210204
  * @author        : i2max_Jihyun.Lee
  * @date          : 2021-06-17 오후 3:14
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
    0.1     2021-06-17 오후 3:14     i2max_Jihyun.Lee        Create
****************************************************************************************/

@IsTest
private class KDCE_LiveChatTranscript_tr_ts {

    static {
        KDCE_TestUtil.init();
        KDCE_TestBizUtil.init();
    }

    @IsTest
    static void testBehavior() {

        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.CaseId = KDCE_TestUtil.caseItem.Id;
        lct.LiveChatVisitorId = lcv.Id;
        insert lct;

        LiveChatTranscript lct2 = new LiveChatTranscript();
        lct2.ContactId = KDCE_TestUtil.contactMember.Id;
        lct2.LiveChatVisitorId = lcv.Id;
        insert lct2;

        lct2.CaseId = null;
        update lct2;

        lct.CaseId = KDCE_TestUtil.caseItem.Id;
        update lct;
    }
}