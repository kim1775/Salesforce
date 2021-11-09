/****************************************************************************************
  * @filename      : TestDataBaseFactory
  * @author        : I2MAX
  * @date          : 2021-01-15 오후 1:18
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2021-01-15 오후 1:18      I2MAX               Create
****************************************************************************************/
@SuppressWarnings('PMD')
@IsTest
public class TestDataBaseFactory { 

    public static void init() {}

    /**
     * Account Test Data
     *
     * @param isInsert : Boolean
     *
     * @return Account
     */
    public static Account createAccount(final Boolean isInsert) {
        Account account = new Account();

        account.Name = 'businessOfficeAccount';

        if(isInsert)    insert account;

        return account;
    }

    public static Account baseAccount {get;set;}

    static {
        baseAccount = createAccount(true);
    }

    /**
     * Contact Test Data
     *
     * @param isInsert : Boolean
     *
     * @return Contact
     */
    public static Contact createContact(final Boolean isInsert) {
        Contact contact = new Contact();

        contact.LastName = 'testContact';
        contact.Email = 'test@test.com';
        contact.MobilePhone = '010-1234-1234';
        contact.KDCE_MarketingOptIn__c = true;

        if(isInsert)    insert contact;

        return contact;
    }

    public static Contact baseContact {get;set;}

    static {
        baseContact = createContact(true);
    }

    /**
    * Case Test Data
    *
    * @param isInsert : insert 여부.
    *
    * @return Case
    */
    public static Case createCase(final Boolean isInsert) {
        Case insertCase = new Case();

        insertCase.Subject = 'Test';
        insertCase.Description = 'Test';
        insertCase.SuppliedName = TestDataBaseFactory.baseContact.LastName;
        insertCase.Origin = 'Web';
        insertCase.CCR_ContactType__c = 'Webpage';
        insertCase.ContactId = TestDataBaseFactory.baseContact.Id;
        insertCase.Status = 'New';
        insertCase.KDCE_SendNPS__c = 'Yes';
        insertCase.SuppliedPhone = '010-0000-0135';
        //insertCase.RecordTypeId = TestDataUtilFactory.getRecordTypeId('Case','CCR_ECommerceOrderOnBehalf');

        if(isInsert) insert insertCase;

        return insertCase;
    }

    public static Case baseCase {get;set;}

    static {
        if(baseCase == null) {
            baseCase = createCase(true);
        }
    }

    /**
    * Store Test Data
    *
    * @param isInsert : insert 여부.
    *
    * @return Store
    */
    public static KDCE_Store__c createStore(final Boolean isInsert) {
        KDCE_Store__c store = new KDCE_Store__c();
        store.Name = 'Test';

        if(isInsert) insert store;

        return store;
    }

    public static KDCE_Store__c baseStore {get;set;}

    static {
        if(baseStore == null) {
            baseStore = createStore(true);
        }
    }

    /**
     * Campaign Test Data
     *
     * @param isInsert : Boolean
     *
     * @return Campaign
     */

    public static Campaign baseOutboundCampaign;
    public static Campaign createOutboundCampaign(Boolean isInsert){
        if(Util.isEmpty(baseOutboundCampaign)){
            baseOutboundCampaign = (Campaign)TestDataFactory.createSObject('Campaign', new Map<string, Object>{
                    'Name' => 'TEST OUTBOUND CAMPAIGN'
                    ,'Type' => 'Outbound Master'
                    ,'StartDate' => Date.newInstance(Date.today().year(), 1, 1)
                    ,'EndDate' => Date.newInstance(Date.today().year(), 12, 31)
                    , 'ExternalId__c' => '0909090'
                    ,'IsActive' =>true
            }, isInsert);
        }
        return baseOutboundCampaign;
    }
}