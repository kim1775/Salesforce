/**
 * Created by I2MAX on 2021-07-05.
 */

@IsTest(seealldata=false)
public class CCR_TestUtility {

    public static final String HEATSTICKTEXT = 'HeatStick';
    public static final String HEETSSTRING = 'HEETS';
    public static final String YELLOWSTRING = 'Yellow';
    public static final String SAMPLETEXT = 'Samp';
    public static final Id conRecordTypeId = CCR_Utility.getRecordTypeId ('Contact','Member');
    public static final Id nonDCERecordTypeId = CCR_Utility.getRecordTypeId ('Contact','Prospect');
//    public static final Id caseRecordTypeId = CCR_Utility.getRecordTypeId ('Case','CCR_QoachProgram');
    static Id caseRecordTypeIdAE=SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCR_AdverseEvent').getRecordTypeId();
//    public static final Id caseHeatStickRecordTypeId = CCR_Utility.getRecordTypeId('case','CCR_NewHeatStick');
//    public static final Id TaskRecordTypeId = CCR_Utility.getRecordTypeId ('Task','Qoach Program');
//    public static final Id brandFamilyRecordtypeId = CCR_Utility.getRecordTypeId('CCR_ProductType__c','Brand Family');
//    public static final Id brandDiffRecordtypeId = CCR_Utility.getRecordTypeId('CCR_ProductType__c','Brand Differentiator');
//    public static final Id joinerRecordTypeId = CCR_Utility.getRecordTypeId('CCR_ProductType__c','Joiner');

    public static final String PS_NAME_SUPERVISOR = 'CCR_Supervisor';
    public static final String PS_NAME_KNOWLEDGE_KR = 'CCR_KR';
    public static final String PS_NAME_CONT_MNGMT = 'CCR_CAAContactAdmin';

    /**
    * Method Name :  createAdminUser
    * Arguments: string profileName,string permissionsetname
    * Return : user
    * Description: Set up test user
    **/
    Public static user createAdminUser(){
//        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='[KDCE] System Administrator Mirror'];  //QA
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];  //PRD
        List<UserRole> usrRole = [SELECT Id FROM UserRole WHERE Name = 'Korea' limit 1];
        User newUser=new user(Alias=timeStampForUser(),email='newuser@testorg.com',profileId=systemadminprofile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US', UserRoleId = usrRole[0].id,
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUserAdmin@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser(),country='France');
        return newUser;
    }

    /**
* Method Name :  createAdminUserforCountry
* Arguments: string profileName,string permissionsetname
* Return : user
* Description: Set up test user
**/
    Public static user createAdminUserforCountry(String countryName, string countryCode){
//        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='[KDCE] System Administrator Mirror'];  //QA
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name='Admin - System Administrator'];  //PRD
        User newUser=new user(Alias=timeStampForUser(),email='newuser@testorg.com',profileId=systemadminprofile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUserAdmin@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser(),country = countryName, CCR_UserType__c = 'Call Center Agent');
        return newUser;
    }


    /**
    * Method Name :  timeStampForUser
    * Arguments: NA
    * Return : String
    * Description: to prepare the timestamp strng
    **/
    Public static String timeStampForUser() {
        DateTime dtime = system.now();
        String str = 'UR'+generateRandomString(2)+dTime.millisecond();
        system.debug('TimeStamp :'+str);
        return str;
    }
    /**
    * Method Name :  createIntegrationUser
    * Arguments: string profileName,string permissionsetname
    * Return : user
    * Description: Set up test user
    **/
    Public static user createIntegrationUser(string profileName,string permissionsetname){
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name=:profileName];
        User newUser=new user(Alias=timeStampForUser(),email='newuser@testorg.com',profileId=systemadminprofile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUser@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser(),country='France');
        database.insert(newUser);
//        PermissionSet perset=[SELECT Description,Id FROM PermissionSet WHERE name =:permissionsetname];
//        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = perset.id, AssigneeId = newUser.id);
//        insert psa;
        return newUser;
    }

    Public static user createGuestUser(string profileName){
        Profile systemAdminProfile=[SELECT Id, name from profile WHERE name=:profileName];
        User newUser=new user(Alias=timeStampForUser(),email='newuser@testorg.com',profileId=systemadminprofile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUser@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser());
        insert newUser;
        return newUser;
    }

    /**
* Method Name :  createCallCntAgentForCountry
* Arguments: Country Name
* Return : None
* Description: Set up test user
**/
    Public static user createCallCntAgentForCountry(string countryname){
//        Profile agentProfile=[SELECT Id from profile WHERE name='[KDCE] Customer Care Agent'];  //QA
        Profile agentProfile=[SELECT Id from profile WHERE name='Standard - KR SFSC Customer Care Supervisor (Reporting with export)'];  //PRD
        system.debug('qwerty'+agentProfile);
        User newUser=new user(Alias=timeStampForUser(),email='newuser@testorg.com',profileId=agentProfile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUser@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser(),country=countryname,
                CCR_UserType__c ='Call Center Agent');
        database.insert(newUser);
        system.debug(newUser.Alias+ '--'+newUser.email+'--'+newUser.CommunityNickname);
        return newUser;
    }

    /**
* Method Name :  createQAInspectorForCountry
* Arguments: Country Name
* Return : None
* Description: Set up test user
**/
    Public static user createQAInspectorForCountry(string countryname){
//        Profile agentProfile=[SELECT Id from profile WHERE name='CCR Call Center User'];    //QA
        Profile agentProfile=[SELECT Id from profile WHERE name='Standard - KR SFSC Customer Care Agent'];    //PRD
        system.debug('qwerty'+agentProfile);
        User newUser=new user(Alias=timeStampForUser(),email='newuser@testorg.com',profileId=agentProfile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUser@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser(),country=countryname);
        database.insert(newUser);
        system.debug(newUser.Alias+ '--'+newUser.email+'--'+newUser.CommunityNickname);
        return newUser;
    }
    /**
     * Method Name: CreateServiceCenterAgent
     * Arguments:
     * Return: User
     * Description: to create service center agent for Qure
**/
    public static User CreateServiceCenterAgent(String name){
//        Profile agentProfile=[SELECT Id from profile WHERE name='CCR Call Center User'];    //QA
        Profile agentProfile=[SELECT Id from profile WHERE name='Standard - KR SFSC Customer Care Agent'];    //PRD
        User newUser=new user(Alias=timeStampForUser(),email=name+'@testorg.com',profileId=agentProfile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUser@'+generateRandomString(6)+'.com',CommunityNickname=timeStampForUser(),country='Korea, Republic of', CCR_UserType__c = 'Call Center Agent');
        database.insert(newUser);
        return newUser;
    }
    /**
* Method Name :  createCallCntAgentForCountryTest
* Arguments: Country Name
* Return : User
* Description: Set up test user
**/
    Public static user createCallCntAgentForCountryTest(string countryname){
//        Profile agentProfile=[SELECT Id from profile WHERE name='CCR Call Center User'];    //QA
        Profile agentProfile=[SELECT Id from profile WHERE name='Standard - KR SFSC Customer Care Agent'];    //PRD
        User newUser=new user(Alias=timeStampForUser(),email='newuser@testorg.com',profileId=agentProfile.id,emailEncodingKey='UTF-8',
                LastName='TestUser',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestUser@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser(),country=countryname);
        database.insert(newUser);
//        PermissionSet perset=[SELECT Description,Id FROM PermissionSet where name ='CCR_CallCenterAgent'];
//        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = perset.id, AssigneeId = newUser.id);

        return newUser;
    }

    /**
* Method Name :  createCallCntAgentForCountry
* Arguments: Country Name
* Return : None
* Description: Set up test user
**/
    Public static user createSuperviorForCountry(string countryname){
//        Profile agentProfile=[SELECT Id from profile WHERE name='CCR Call Center User'];    //QA
        Profile agentProfile=[SELECT Id from profile WHERE name='Standard - KR SFSC Customer Care Agent'];    //PRD
        User newUser=new user(Alias=timeStampForUser(),email='newuser@pmi.com',profileId=agentProfile.id,emailEncodingKey='UTF-8',
                LastName='TestSupervisor',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                timezoneSidKey=UserInfo.getTimeZone().getID(),UserName='newTestSupervisor@'+generateRandomString(5)+'.com',CommunityNickname=timeStampForUser(),country=countryname);
        database.insert(newUser);
        return newUser;
    }

    /**
    * Method Name :  createCallCntUserForCountry
    * Arguments:
    *        firstName - to allow to search the User after creation
    *        countryName - country of the User to be created
    *        permSetNames - List of Permission Sets to assign to the created User
    * Return : None
    * Description: Set up test user
    **/
    public static User createCallCntUserForCountry(
            String firstName,
            String countryName,
            Set<String> permSetNames){
//        Profile agentProfile = [SELECT Id FROM Profile WHERE Name ='CCR Call Center User']; //QA
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name ='Standard - KR SFSC Customer Care Agent']; //PRD
        User newUser = new User(
                Alias=timeStampForUser(),
                Email='newuser@pmi.com',
                ProfileId=agentProfile.Id,
                EmailEncodingKey='UTF-8',
                FirstName=firstName,
                LastName='TestCallCenterUser',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey=UserInfo.getTimeZone().getID(),
                UserName='newTestCallCenterUser@'+generateRandomString(5)+'.com',
                CommunityNickname=timeStampForUser(),
                Country=countryName);
        Database.insert(newUser);
        if (permSetNames != null && !permSetNames.isEmpty())
        {
            List<PermissionSet> permSets = [
                    SELECT Id
                    FROM PermissionSet
                    WHERE Name IN :permSetNames];

            List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment>();
            for (PermissionSet perm : permSets)
            {
                listPSA.add(new PermissionSetAssignment(
                        PermissionSetId = perm.Id,
                        AssigneeId = newUser.Id));
            }
            if (!listPSA.isEmpty()) { Database.insert(listPSA); }
        }
        return newUser;
    }

    /**
     * Method Name: CreateQureHistoryRecord
     * Arguments: AssetId
     * return: QureHistory Record
     * Description: Create QURE history records
     **/
    public static CCR_QureHistory__C CreateQureHistoryRecord(Asset assetRec){
        try{
            CCR_QureHistory__C qureHistRec = new CCR_QureHistory__C();
            qureHistRec.CCR_Device__c = assetRec.Id;
            qureHistRec.CCR_Consumer__c = assetRec.ContactId;
            qureHistRec.CCR_Status__c = 'Active';
            insert(qureHistRec);
            return qureHistRec;
        }
        Catch(Exception ex){
            system.debug(ex);
            return null;
        }


    }
    /**
* Method Name :  createUserForCountry
* Arguments: integer n,string conId
* Return : list<case>
* Description: Set up test user
**/
    Public static list<case> createCases(integer n,string conId){
        list<case> casList = new list<case>();
        for(Integer i=0;i<n;i++){
            case cas = new case();
            cas.subject =SAMPLETEXT+i;
            cas.ContactId = conId;
            cas.CCR_Verbatim__c=SAMPLETEXT;
            casList.add(cas);
        }
        if(casList.size()>0 && casList!=null){
            Database.insert(casList);
        }
        return casList;
    }
    /**
* Method Name :  createCaseForQoach
* Arguments: integer n,string conId
* Return : list<case>
* Description: Set up test user
**/
    Public static list<case> createCaseForQoach(integer n,string conId){
        list<case> casList = new list<case>();
        for(Integer i=0;i<n;i++){
            case cas = createRawCaseForQoach(i, conId);
            casList.add(cas);
        }
        if(casList.size()>0 && casList!=null){
            Database.insert(casList);
        }
        return casList;
    }
    /**
* Method Name :  createRawCaseForQoach
* Arguments: Integer n, String conId
* Return : Case
* Description: Set up test QOACH Case
**/

    Public static Case createRawCaseForQoach(Integer n, String conId){
        Case cas = new Case();
        cas.Subject ='Sample case' + n;
        cas.ContactId = conId;
        cas.CCR_Verbatim__c='Sample';
        cas.CCR_ProgrmStage__c = 'Welcome Call';
        cas.CCR_DueDate__c = System.now();
        cas.CCR_NumberOfCallsForTheCurrentStage__c = 3;
//        cas.RecordTypeId = caseRecordTypeId;
        return cas;
    }

    /**
* Method Name :  createCaseForAdverseEvent
* Arguments: integer n,string conId
* Return : list<case>
* Description: Set up test user
**/
    Public static list<case> createCaseForAdverseEvent(integer n){
        list<case> AdversecasList = new list<case>();

        for(Integer i=0;i<n;i++){
            case adverseEventCase = new Case();
            adverseEventCase.CCR_Verbatim__c='Verbatim'+i;
            adverseEventCase.CCR_Comments__c='Comment'+i;
            adverseEventCase.RecordTypeId=caseRecordTypeIdAE;
            AdversecasList.add(adverseEventCase);
        }
        if(AdversecasList.size()>0 && AdversecasList!=null){
            Database.insert(AdversecasList);
        }
        return AdversecasList;
    }

    /**
* Method Name :  createProduct
* Arguments: Integer n, List<String> productCode
* Return : List<Product2>
* Description: Set up test product records
**/
    public static List<Product2> createProduct(Integer n, List<String> productCode){
        //'FA000040'
        String name = 'FA000040.0';
        List<Product2> productList = new List<Product2>();
        for(Integer i=0; i<n; i++){
            Product2 product = new Product2();
            product.Name = name+i;
            product.CCR_Category__c = SAMPLETEXT;
            product.CCR_OriginalDesignMarket__c = SAMPLETEXT;

            product.ProductCode = productCode[0];

            product.CCR_Differentiator__c = YELLOWSTRING;
            product.Family = HEETSSTRING;
            product.Description = SAMPLETEXT+i;
            productList.add(product);
        }
        database.insert(productList);
        return productList;
    }
    /**
     *
     *
     *
     *
     **/
//    public static List<CCR_ProductType__c> createProdType () {
//
//        List<CCR_ProductType__c> productTypeListReturn = new List<CCR_ProductType__c>();
//        List<CCR_ProductType__c> productTypeList = new List<CCR_ProductType__c>();
//        CCR_ProductType__c brandFamRec = new CCR_ProductType__c();
//        CCR_ProductType__c brandDiffRec = new CCR_ProductType__c();
//        brandFamRec.Name = HEETSSTRING;
//        brandFamRec.recordTypeId =brandFamilyRecordtypeId;
//        productTypeList.add(brandFamRec);
//        brandDiffRec.name = YELLOWSTRING;
//        brandDiffRec.recordTypeId = brandDiffRecordtypeId;
//        productTypeList.add(brandDiffRec);
//        insert productTypeList;
//        CCR_ProductType__c joinerRec = new CCR_ProductType__c();
//        joinerRec.name = SAMPLETEXT;
//        joinerRec.RecordTypeId = joinerRecordTypeId;
//        joinerRec.CCR_BrandDifferentiator__c = brandDiffRec.Id;
//        joinerRec.CCR_BrandFamily__c = brandFamRec.id;
//        insert joinerRec;
//        productTypeListReturn.add(joinerRec);
//        productTypeListReturn.add(brandFamRec);
//        productTypeListReturn.add(brandDiffRec);
//
//        return productTypeListReturn;
//    }
    /**
* Method Name :  createLocalization
* Arguments: None
* Return :
* Description: Set up test product records
**/
    public static CCR_Localization__c createLocalization(){

        CCR_Localization__c subjectCode = new CCR_Localization__c();
        subjectCode.Name = SAMPLETEXT;
        subjectCode.CCR_Active__c = true;
        subjectCode.CCR_Language__c = 'fr';
        subjectCode.CCR_Store__c ='FR';
        subjectCode.CCR_NCPUOM__c = SAMPLETEXT;
        subjectCode.CCR_Title__c =SAMPLETEXT;
        Database.insert(subjectCode);
        return subjectCode;
    }
    /**
* Method Name :  createGhostContact
* Arguments: none
* Return : Contact
* Description: Set up test user
**/
    Public static Contact createGhostContact(){
        Contact ghCon = new contact();
        ghcon.lastname ='-';
        ghcon.FirstName = '-';
        ghcon.RecordTypeId = conRecordTypeId;
        database.insert(ghcon);
        return ghcon;
    }

    public static Account createAccount(){
        Account acc = new Account();
        acc.Name = 'testAcc';
        database.insert(acc);
        return acc;
    }
    /**
* Method Name :  createContacts
* Arguments: integer n : no of contacts
* Return : list<Contact>
* Description: Set up test user
**/
    Public static list<Contact> createContacts(integer n){
        list<Contact> conList = new list<contact>();
        User userObj=[SELECT id,Name from user WHERE id=:userinfo.getUserId() limit 1];
        Contact con = new contact();
        for(integer i=0;i<n;i++){
            con = new contact();
            con.lastname = generateRandomString(6) + i;
            con.FirstName = generateRandomString(6) + i;
            con.CCR_ConsumerUID__c = generateRandomString(6) + i;
            con.Phone = '01012341234' + i;
            con.RecordTypeId = conRecordTypeId;
            conList.add(con);
        }
        if(conList.size()>0 && conList!=null){
            database.insert(conList);
        }
        return conList;
    }
    /**
* Method Name :  createContactsForSpecificCountry
* Arguments: integer n : no of contacts
* Return : list<Contact>
* Description: Set up test user
**/
    public static List<Contact> createContactsForSpecificCountry(Integer contactCount, String countryCode){
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        for(Integer i = 0; i < contactCount; i++){
            con = new Contact();
            con.Lastname = generateRandomString(6);
            con.FirstName = generateRandomString(6);
            con.CCR_ConsumerUID__c = countryCode + generateRandomString(15) + System.now().millisecond();
            con.CCR_CountryID__c = countryCode;
            con.RecordTypeId = conRecordTypeId;
            con.Email = 'test@test.com';
            conList.add(con);
        }
        if(conList != null){
            database.insert(conList);
        }

        return conList;
    }
    /**
    * Method Name :  createContactsForOwnerTest
    * Arguments: none
    * Return : list<Contact>
    * Description: Set up test user
    **/
    Public static void createContactsForOwnerTest(){
        User testUser = [SELECT id FROM User WHERE Alias LIKE 'UR%' ORDER BY CreatedDate DESC LIMIT 1];
        List<Contact> conList = new List<Contact>();
        Contact con = new contact();
        con.lastname ='TESTCONLNAMEDCENONLEAD';
        con.FirstName = 'TESTCONLNAMEDCENONLEAD';
        con.CCR_ConsumerUID__c ='TESTNOLEAD12345611';
        con.RecordTypeId = nonDCERecordTypeId;
//        con.CCR_ContactDateTimeFrom__c = system.today();
        //con.CCR_ConsumerRetailerId__c = userObj.Id;
        conList.add(con);
        con = new contact();
        con.lastname ='TESTCONLNAMEDCE';
        con.FirstName = 'TESTCONLNAMEDCE';
        con.CCR_ConsumerUID__c ='TEST12345611';
        con.CCR_CountryID__c= 'FR';
        con.RecordTypeId = conRecordTypeId;
//        con.CCR_ContactRetailerId__c = testUser.Id;
        conList.add(con);
        con = new contact();
        con.lastname ='TESTCONLNAMEDCEIT';
        con.FirstName = 'TESTCONLNAMEDCEIT';
        con.CCR_ConsumerUID__c ='ITTEST12345611';
        con.CCR_CountryID__c= 'IT';
        con.RecordTypeId = conRecordTypeId;
//        con.CCR_ContactRetailerId__c = testUser.Id;
        conList.add(con);
        con = new contact();
        con.lastname ='TESTCONLNAMEAGENT';
        con.FirstName = 'TESTCONLNAMEAGENT';
        con.CCR_ConsumerUID__c ='TESTAGENT12345611';
        con.CCR_CountryID__c= 'FR';
        con.RecordTypeId = conRecordTypeId;
//        con.CCR_RegistrationAgentId__c = testUser.Id;
        conList.add(con);
        con = new contact();
        con.lastname ='TESTCONLNAMECAAPP';
        con.FirstName = 'TESTCONLNAMECAAPP';
        con.CCR_ConsumerUID__c ='TESTCA12345611';
        con.CCR_CountryID__c= 'FR';
        con.RecordTypeId = conRecordTypeId;
//        con.CAA_RegistrationFieldMarketerID__c = testUser.Id;
        conList.add(con);
        con = new contact();
        con.lastname ='TESTCONLNAMECONTACTDCE';
        con.FirstName = 'TESTCONLNAMECONTACTDCE';
        con.CCR_ConsumerUID__c ='CONTACTDCE12345611';
//        con.CCR_CountryID__c = testUser.CountryCode;
        con.RecordTypeId = conRecordTypeId;
//        con.CCR_ConsumerRetailerId__c = testUser.Id;
        conList.add(con);
        con = new contact();
        con.lastname ='TESTCONLNAMECONSUMER';
        con.FirstName = 'TESTCONLNAMECONSUMER';
        con.CCR_ConsumerUID__c ='TESTCONSUMER12345611';
//        con.CCR_CountryID__c = testUser.CountryCode;
        con.RecordTypeId = conRecordTypeId;
//        con.CCR_ConsumerRetailerId__c = testUser.Id;
        conList.add(con);
        if(conList.size()>0 && conList!=null){
            database.insert(conList);
        }
        List<Contact> conReturned = [select id,owner.name,createdby.name from contact
        where id in : conList];
        system.debug(conreturned);
    }
    /**
* Method Name :  createContactswithDisableStatus
* Arguments: integer n : no of contacts
* Return : list<Contact>
* Description: Set up test user
**/
    Public static list<Contact> createContactswithDisableStatus(integer n){
        list<Contact> conList = new list<contact>();
        for(integer i=0;i<n;i++){
            Contact con = new contact();
            con.lastname ='TESTCONLNAME'+i;
            con.FirstName = 'TESTCONFNAME'+i;
            con.CCR_ConsumerUID__c ='Dis123456'+i;
//            con.CCR_Status__c ='Disabled';
            con.RecordTypeId = conRecordTypeId;
            conList.add(con);
        }
        if(conList.size()>0 && conList!=null){
            database.insert(conList,false);
        }
        return conList;
    }

    /**
* Method Name :  createMaterials
* Arguments: Integer n : no of materials
* Return : list<CCR_Material__c>
* Description: Set up test user
**/
    Public static list<CCR_Material__c> createMaterials(integer n,string prgroup,string version,string market){
        list<CCR_Material__c> materialList = new List<CCR_Material__c>();
        CCR_Material__c materialDis = new CCR_Material__c();
        materialDis.Name = 'Pocket Charger /S';
        materialDis.CCR_Group__c = 'D0201';
        insert materialDis;
        for(integer i=0;i<n;i++){
            CCR_Material__c material = new CCR_Material__c();
            material.Name ='TESTDEVICE'+i;
            material.CCR_Group__c = prgroup;
            material.CCR_Version__c =version;
            material.CCR_ModelNumber__c = 'A1403';
            material.CCR_GroupDescription__c = materialDis.Id;
            materialList.add(material);
        }
        if(materialList.size()>0 && materialList!=null){
            database.insert(materialList);
        }
        return materialList;
    }

    /**
* Method Name :  createassets
* Arguments: string materialId,string contactid, string aststatus,string codentifyId,string serialNo
* Return : Asset
* Description: Set up test user
**/
    Public static Asset createassets(string materialId,string contactid, string aststatus,string codentifyId,string serialNo,string internalId){
        Asset linkAsset = new asset();
        linkAsset.name= codentifyId;
        linkAsset.CCR_CodentifyId__c= codentifyId;
        linkAsset.CCR_InternalId__c = generateRandomString(10);
        linkAsset.SerialNumber = serialNo;
        linkAsset.Status = aststatus;
        linkAsset.ContactId = contactid;
        linkAsset.AccountId = getAcc().Id;
        linkAsset.CCR_DeviceProductCode__c= materialId;
        linkAsset.CCR_ParentProductionDateTime__c = Datetime.newInstance(2017, 1,10);
        linkAsset.PurchaseDate = Date.newInstance(2018,1,1);

        database.insert(linkAsset);
        return linkAsset;
    }
    /**
* Method Name :  createassets
* Arguments: string materialId,string contactid, string aststatus,string codentifyId,string serialNo
* Return : Asset
* Description: Set up test user
**/
    Public static list<Asset> createBulkAssets(integer n,string materialId,string contactid){
        List<Asset> Assetlst = new List<asset>();
        for(Integer i=0;i<n;i++){
            Asset linkAsset = new asset();
            linkAsset.name= 'TESTDEVICE';
            linkAsset.CCR_CodentifyId__c= generateRandomString(9) + i;
            linkAsset.CCR_InternalId__c = generateRandomString(10)+i;
            linkAsset.SerialNumber = 'serialNo'+i;
            linkAsset.Status = 'Obsolete';
            linkAsset.ContactId = contactid;
            linkAsset.CCR_DeviceProductCode__c= materialId;
            Assetlst.add(linkAsset);
        }

        database.insert(Assetlst);
        return Assetlst;
    }

    /**
* Method Name :  createassets
* Arguments: string materialId,string contactid, string aststatus,string codentifyId,string serialNo
* Return : Asset
* Description: Set up test user
**/
    Public static Asset createassetswithProduct(string materialId,string contactid, string aststatus,string codentifyId,string serialNo,string internalId,string prdId){
        Asset linkAsset = new asset();
        linkAsset.name= 'TESTDEVICE';
        linkAsset.CCR_CodentifyId__c=codentifyId;
        linkAsset.CCR_InternalId__c = internalId;
        linkAsset.SerialNumber = serialNo;
        linkAsset.Status = aststatus;
        linkAsset.ContactId = contactid;
        linkAsset.CCR_DeviceProductCode__c= materialId;
        linkAsset.product2id = prdId;
        database.insert(linkAsset);
        return linkAsset;
    }
    /**
* Method Name :  createassetLifeCycle
* Arguments: string assetId,string contactid
* Return : CCR_AssetLifeCycle__c
* Description: Set up test user
**/
    Public static CCR_AssetLifeCycle__c createassetLifeCycle(string assetId,string contactid,string action){
        CCR_AssetLifeCycle__c assetlifecycle = new CCR_AssetLifeCycle__c();
        assetlifecycle.CCR_Asset__c=assetId;
        assetlifecycle.CCR_Consumer__c = contactid;
        assetlifecycle.CCR_Action__c = action;
        assetlifecycle.CCR_ActionDate__c = system.now();
        database.insert(assetlifecycle);

        return assetlifecycle;
    }

    /**
* Method Name :  createCCRProducts
* Arguments: string pname,string category, string version,string pmarket
* Return : none
* Description: Set up test user
**/
    Public static product2 createCCRProducts(string pname, string category,  string version, string pmarket){
        product2 prd = new product2();
        prd.name=pname;
        prd.ProductCode ='DA000006';
        prd.CCR_Category__c=category;
        prd.CCR_Version__c=version;
        prd.CCR_OriginalDesignMarket__c=pmarket;
        prd.Description ='HOLDER IQOS 24SLATES OPK 1';
        database.insert(prd);
        return prd;
    }

    /**
* Method Name :  createTaskforConact
* Arguments: integer n,string conid
* Return : List<Task>
* Description: Set up test user
**/
    Public static List<Task> createTaskforConact(integer n, string conid){
        List<Task> tsklst = new list<Task>();
        for(integer i=0;i<n;i++){
            task tsk = new task(subject='Sample Task'+i,WhoId=conid);
            tsklst.add(tsk);
        }
        if(tsklst.size()>0 && tsklst!=null){
            database.insert(tsklst);
        }
        return tsklst;
    }
    /**
* Method Name :  createTaskforQoach
* Arguments: integer n,string conid
* Return : List<Event>
* Description: Set up test user
**/

    /*Public static List<Task> createTaskforQoach(integer n, string conid){
        List<Task> tsklst = new list<Task>();
        for(integer i=0;i<n;i++){
            task tsk = new task(subject='Call',WhoId=conid, Status='Completed', Priority='Normal');
            tsk.RecordTypeId=TaskRecordTypeId;
            tsklst.add(tsk);
        }
        if(tsklst.size()>0 && tsklst!=null){
            database.insert(tsklst);
        }
        return tsklst;
    } */
    /**
* Method Name :  createTaskforConact
* Arguments: integer n,string conid
* Return : List<Event>
* Description: Set up test user
**/
    Public static List<Event> createEventforConact(integer n, string conid){
        List<Event> evelst = new list<Event>();
        for(integer i=0;i<n;i++){
            Event eve = new Event(Subject='EVENTSUBJECT'+i, WhoId=conid, DurationInMinutes=12, ActivityDateTime=system.now());
            evelst.add(eve);
        }
        if(evelst.size()>0 && evelst!=null){
            database.insert(evelst);
        }
        return evelst;
    }

    /**
* Method Name :  createAttachment
* Arguments: integer n, string parentId
* Return : List<Event>
* Description: Set up test user
**/
    Public static list<Attachment> createAttachment(integer n, string parentId){
        list<Attachment> attLst = new list<Attachment>();
        for(integer i=0;i<n;i++){
            attachment att = new attachment();
            att.Name='Sample att';
            att.Body=Blob.valueOf('Unit Test Attachment Body');
            att.ParentId=parentId;
            attLst.add(att);
        }
        if(attLst.size()>0 && attLst!=null){
            database.insert(attLst);
        }
        return attLst;
    }

    /**
* Method Name :  createNotes
* Arguments: integer n, string parentId
* Return : List<Event>
* Description: Set up test user
**/
    Public static list<note> createNotes(integer n, string parentId){
        list<note> ntLst = new list<note>();
        for(integer i=0;i<n;i++){
            attachment att = new attachment();
            note nte = new note();
            nte.Title='Sample Note';
            nte.ParentId=parentId;
            ntLst.add(nte);
        }
        if(ntLst.size()>0 && ntLst!=null){
            database.insert(ntLst);
        }
        return ntLst;
    }
    /**
* Method Name :  createPushNotifications
* Arguments: integer n
* Return : List<Event>
* Description: Set up test user
**/
//    public static List<CCR_AssetPushNotification__c> createPushNotifications(Integer n) {
//        List<CCR_AssetPushNotification__c> listNotification = new List<CCR_AssetPushNotification__c>();
//
//        for(integer i=0;i<n;i++) {
//            listNotification.add(new CCR_AssetPushNotification__c(CCR_AssetcodentifyId__c = 'Test'+i,
//                    CCR_AssetPayload__c = String.ValueOf('Test'+i),
//                    CCR_PushNotificationStatus__c = 'Pending',
//                    CCR_UpdatedSection__c = 'Test'));
//        }
//        for(integer i=0;i<n;i++) {
//            listNotification.add(new CCR_AssetPushNotification__c(CCR_AssetcodentifyId__c = 'Test'+i,
//                    CCR_AssetPayload__c = String.ValueOf('Test'+i),
//                    CCR_PushNotificationStatus__c = 'Processed',
//                    CCR_UpdatedSection__c = 'Test'));
//        }
//        if (!listNotification.isEmpty()) {
//            database.insert(listNotification);
//        }
//        return listNotification;
//    }
//    public static User createUserIne(String useAlias, String lastName, ID prflId) {
//        return null;
//    }

    /**
* Method Name :  generateRandomString
* Arguments: integer n
* Return : String
* Description: Generate random string
**/
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        Integer charsLength = chars.length();
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsLength);
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    /**
* Method Name :
* Arguments:
* Return :
* Description:
**/
    public static CCR_DeviceDiagnostic__c createDigonsticrec(String Message,string recordtypeId,string Endmessagetype ){
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'CCR_DeviceDiagnostic__c' AND Name = :recordtypeId];
        CCR_DeviceDiagnostic__c devDigonstic = new CCR_DeviceDiagnostic__c();
        devDigonstic.Name = Message;
        devDigonstic.CCR_MessageName__c = Message;
        devDigonstic.CCR_Active__c = true;
        devDigonstic.CCR_DiagnosticResult__c = 'HB1';
        devDigonstic.CCR_EndMessageType__c = Endmessagetype;
        devDigonstic.CCR_IsIssueSolved__c = true;
        devDigonstic.CCR_Model__c = '1403';
        devDigonstic.CCR_NextNegativeStep__c = devDigonstic.Id;
        devDigonstic.CCR_NextStep__c = devDigonstic.Id;
        devDigonstic.CCR_OrderPriority__c = 3.0;
        devDigonstic.RecordTypeid = rt.id;
        database.insert(devDigonstic);
        return devDigonstic;
    }

    /**
    * Method Name: createDevDiagLocalization
    * Arguments: fields for record: DeviceDiagnosticId, Active, Language, Country
    * Return: Device Diagnostic Localization record
    * Description:
    **/
    public static CCR_DeviceDiagnosticLocalization__c createDevDiagLocalization(String devDiagId, Boolean isActive, String language, String country, String status) {
        CCR_DeviceDiagnosticLocalization__c ddl = new CCR_DeviceDiagnosticLocalization__c();
        ddl.CCR_DeviceDiagnostic__c = devDiagId;
        ddl.CCR_Active__c = isActive;
        ddl.CCR_Language__c = language;
        ddl.CCR_Country__c = country;
        ddl.CCR_Status__c = status;
        return ddl;
    }

    public static Account getAcc() {
        Account acc = new Account();
        acc.Name = 'PMK';
        acc.Phone = '01012341234';
        insert acc;

        return acc;
    }

    public static Contact getCnt() {
        Contact cnt = new Contact();
        cnt.LastName = 'PMK';
        cnt.Phone = '01012341234';
        insert cnt;

        return cnt;
    }

    public Static void getModelProductMap(){
        ModelProductMapping__c mpm = new ModelProductMapping__c();
        insert mpm;
    }
}