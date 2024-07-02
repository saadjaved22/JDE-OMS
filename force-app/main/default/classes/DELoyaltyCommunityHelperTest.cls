/* ----------------------------------------------------------------------------------------------
   Name: DELoyaltyCommunityHelperTest
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
  012-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/

@IsTest(seeAllData = false)
public with sharing class DELoyaltyCommunityHelperTest {
    
    public static List<Id> lstAccIds = new List<Id>();
    
    private static List<Account> setupAccountData() {
        //TestDataFactory.setCustomSetting();
        
        
        List<Account> lstAcc = new List<Account>();
        
        Account acc = new Account(firstName = 'loyaltyTest', 
                                  lastName = 'UserTest',
                                  Brand__c = 'Douwe Egberts',
                                  Type__c = 'Newsletter Subscriber',
                                  Consent_Status__c	 = 'Active',
                                  PersonEmail='jde5@douweegberts.com', 
                                  External_Id__c ='jde5@douweegberts.com'+Label.Country+Label.Brand,
                                  PersonBirthdate = System.today(),
                                  OwnerId=Label.CommunityOwnerID);
        lstAcc.add(acc);
         
        acc = new Account(firstName = 'loyaltyTest', 
                                  lastName = 'UserTest',
                                  Brand__c = 'Douwe Egberts',
                                  Type__c = 'Newsletter Subscriber',
                                  Consent_Status__c	 = 'Pending Confirmation',
                                  PersonEmail='jde6@douweegberts.com', 
                                  External_Id__c ='jde6@douweegberts.com'+Label.Country+Label.Brand,
                                  PersonBirthdate = System.today(),
                                  OwnerId=Label.CommunityOwnerID);
        acc = new Account(firstName = 'loyaltyTest', 
                                  lastName = 'UserTest',
                                  Brand__c = 'Douwe Egberts',
                                  Type__c = 'Loyalty',
                                  Consent_Status__c	 = 'Pending Confirmation',
                                  PersonEmail='jde7@douweegberts.com', 
                                  External_Id__c ='jde7@douweegberts.com'+Label.Country+Label.Brand,
                                  PersonBirthdate = System.today(),
                                  OwnerId=Label.CommunityOwnerID);
        
        
        lstAcc.add(acc);
        /*    
        Account acc3 = new Account(firstName = 'loyaltyTest7', lastName = 'UserTest7', Gender__pc = 'Male',
                                      PersonEmail='loyaltyTest.userTestx7@gmail.com', External_Id__c ='loyaltyTest.userTestx7@gmail.comNLDouwe Egberts',
                                      PersonBirthdate = Date.valueOf('1992-03-15'), Loyalty_Email_Sent_Date__c = system.now(),
                                     OwnerId='0054E000002dJtCQAU');
        lstAcc.add(acc2);
        lstAcc.add(acc3);
		*/  
        insert lstAcc;
        
        return lstAcc;
    }
    
    static testMethod void positivelightningSelfRegisterNewConsumer(){
        TestDataFactory.setCustomSetting();
        Test.startTest();
    	LightningSelfRegisterController.selfRegister('firstname1', 'lastname1', 'jde4@douweegberts.com', 
                                                     '', '','','regConfirmUrl', null, 'startUrl', false, 
                                                     String.valueOf(System.today().addYears(-20)),'1186 EC','26','Matterhorn','Amstelveen',
                                                     '', 'True');
        Test.stopTest();
        
    }
    static testMethod void positivelightningSelfRegisterCreateUser(){
        TestDataFactory.setCustomSetting();
        Test.startTest();
        LightningSelfRegisterController.selfRegister('firstname1', 'lastname1', 'jde8@douweegberts.com', 
                                                     '', '','','regConfirmUrl', null, 'startUrl', false, 
                                                     String.valueOf(System.today().addYears(-20)),'1186 EC','26','Matterhorn','Amstelveen',
                                                     '', 'True');
        
        List<Account> lstAcc  = new List<Account> ([SELECT ID FROM ACCOUNT WHERE personEmail = 'jde8@douweegberts.com']);
        system.debug('lstAcc '+lstAcc);
        
    	CommunityUsersFactory.Consumer_NewUser_EmailChange(lstAcc);
        Test.stopTest();
        
    }
    
    static testMethod void positivelightningSelfRegisterExistingConsumer(){
        
        setupAccountData();

        Test.startTest();
    	LightningSelfRegisterController.selfRegister('firstname1', 'lastname1', 'jde5@douweegberts.com', 
                                                     '', '','','regConfirmUrl', null, 'startUrl', false, 
                                                     String.valueOf(System.today().addYears(-20)),'1186 EC','26','Matterhorn','Amstelveen',
                                                     '', 'True');
        Test.stopTest();
    }
    
    static testMethod void positivelightningSelfRegisterExistingConsumerUpgrade(){
        setupAccountData();
        
        Test.startTest();
    	LightningSelfRegisterController.selfRegister('firstname1', 'lastname1', 'jde6@douweegberts.com', 
                                                     '', '','','regConfirmUrl', null, 'startUrl', false, 
                                                     String.valueOf(System.today().addYears(-20)),'1186 EC','26','Matterhorn','Amstelveen',
                                                     '', 'True');
        Test.stopTest();
    }
    static testMethod void positivelightningForgotPassword(){
 		LightningForgotPasswordController.forgotPassword('username', 'test');
    }
    
    @isTest
    static void createUser(){
        List<Account> lstAcc = setupAccountData();
        Test.startTest();
        lstAccIds = CommunityUsersFactory.createUser(lstAcc);
        Test.stopTest();
    }
    
    @isTest
    static void updateUserEmailAddress(){ 
        Set<ID> accIds = new Set<ID>();
        //User usr = TestDataFactory.TestCreateUser(3);
        
        for (Id AccId : lstAccIds)
        	accIds.add(AccId);
        
        Test.startTest();
        system.debug('!!! accids:: ' + accIds);
    	CommunityUsersFactory.updateUserEmailAddress(accIds);
        Test.stopTest();
    }
    @IsTest
    static void testUpgradeConsumerToLoyalty(){
        EncryptionKey__c encrypnKey = new EncryptionKey__c(SetupOwnerId=UserInfo.getOrganizationId());
        
        encrypnKey.Algorithm__c = 'AES256';
        encrypnKey.IV__c = '7402862816488480';
        encrypnKey.Key__c = 'falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X';
        encrypnKey.OptinURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf';
        encrypnKey.OptoutURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Opt-out/?id=EID&s=SIG&origin=sf';
        insert encrypnKey;
        System.debug(encrypnKey);

        Account acc = new Account(firstName = 'loyaltyTestUpgrade', 
                                  lastName = 'UserTestUp',
                                  Brand__c = 'Douwe Egberts',
                                  Type__c = 'Newsletter Subscriber',
                                  Consent_Status__c	 = '',
                                  PersonEmail='testUpgrade@douweegberts.com', 
                                  External_Id__c =null,
                                  PersonBirthdate = System.today(),
                                  OwnerId=Label.CommunityOwnerID,
                                  Privacy_Policy_Summary__c =null,
                                  Account_Consent_Registration_Source_URL__c = null,
                                  Account_Registration_Status__c = null ,
                                  Account_Consent_Registration_Date__c = null,
                                  Account_Registration_Email__c = null,
                                  Account_Registration_Source__c = null,
                                  Consent_Text__c = null,
                                  Consent_Text_Version__c = null,
                                  Privacy_Policy_Version__c = null,
                                  Consent_Registration_Source_URL__c = null,
                                  Opt_in_Source__c = null, BillingStreet = null, 
                                  BillingCity = null,BillingPostalCode = null,BillingCountry = null
                                  );
        insert acc;
        System.debug(acc);
        Id userId = UserInfo.getUserId();
        User u = [SELECT Name,Street, City, postalCode FROM User WHERE Id = :userId];

        Test.startTest();
            DELoyaltyCommunityHelper.upgradeConsumerToLoyalty(acc, true, 'DE.NL', u);
        Test.stopTest();
        
    }

    @IsTest
    static void testUpdateUser(){
        Id userId = UserInfo.getUserId();
        List<User> lstUser  = [SELECT Name,Street, City, postalCode FROM User WHERE Id = :userId];
        Test.startTest();
            List<User> rtListUser =  DELoyaltyCommunityHelper.updateUsers(lstUser);
            System.assert(rtListUser.size() > 0);
        Test.stopTest();
        
    }

    @IsTest
    static void testConsumerUserAccountExist(){
        
        Test.startTest();
          Boolean ret =   DELoyaltyCommunityHelper.consumerUserAccountExist('wrongId');
          System.assert(ret == false);
        Test.stopTest();
        
    }
    @IsTest
    static void testAccountPresentPositive(){
        Id userId = UserInfo.getUserId();
        User u = [SELECT Name,Email,Street, City, postalCode FROM User WHERE Id = :userId];

        Account acc = new Account(firstName = 'loyaltyTestUpgrade', 
                                  lastName = 'UserTestUp',
                                  Brand__c = 'Douwe Egberts',
                                  Type__c = 'Loyalty',
                                  Consent_Status__c	 = '',
                                  PersonEmail= u.Email, 
                                  External_Id__c =u.Email+Label.Country+Label.Brand,
                                  PersonBirthdate = System.today(),
                                  OwnerId=Label.CommunityOwnerID,
                                  Privacy_Policy_Summary__c =null,
                                  Account_Consent_Registration_Source_URL__c = null,
                                  Account_Registration_Status__c = null ,
                                  Account_Consent_Registration_Date__c = null,
                                  Account_Registration_Email__c = null,
                                  Account_Registration_Source__c = null,
                                  Consent_Text__c = null,
                                  Consent_Text_Version__c = null,
                                  Privacy_Policy_Version__c = null,
                                  Consent_Registration_Source_URL__c = null,
                                  Opt_in_Source__c = null, BillingStreet = null, 
                                  BillingCity = null,BillingPostalCode = null,BillingCountry = null
                                  );
        insert acc;
        System.debug(acc);

        Loyalty__c l = new Loyalty__c(Loyalty_Account_Number__c ='1111111',Loyalty_Consumer__c = acc.Id,External_Id__c = acc.External_Id__c);
        insert l;

        String communityNetwId = [SELECT Id FROM NETWORK WHERE Name = :Label.CommunityName].Id;
        
        Test.startTest();
            DELoyaltyCommunityHelper.isCommunityAccountPresent(u, communityNetwId, '2000-10-01', 'true');
        Test.stopTest();

    }

    @IsTest
    static void testAccountPresentPositiveWithoutLoyalty(){
        EncryptionKey__c encrypnKey = new EncryptionKey__c(SetupOwnerId=UserInfo.getOrganizationId());

        encrypnKey.Algorithm__c = 'AES256';
        encrypnKey.IV__c = '7402862816488480';
        encrypnKey.Key__c = 'falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X';
        encrypnKey.OptinURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf';
        encrypnKey.OptoutURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Opt-out/?id=EID&s=SIG&origin=sf';
        insert encrypnKey;
        System.debug(encrypnKey);
        Id userId = UserInfo.getUserId();
        User u = [SELECT Name,Email,Street, City, postalCode FROM User WHERE Id = :userId];

        Account acc = new Account(firstName = 'loyaltyTestUpgrade', 
                                  lastName = 'UserTestUp',
                                  Brand__c = 'Douwe Egberts',
                                  Type__c = 'Loyalty',
                                  Consent_Status__c	 = '',
                                  PersonEmail= u.Email, 
                                  External_Id__c =u.Email+Label.Country+Label.Brand,
                                  PersonBirthdate = System.today(),
                                  OwnerId=Label.CommunityOwnerID,
                                  Privacy_Policy_Summary__c =null,
                                  Account_Consent_Registration_Source_URL__c = null,
                                  Account_Registration_Status__c = null ,
                                  Account_Consent_Registration_Date__c = null,
                                  Account_Registration_Email__c = null,
                                  Account_Registration_Source__c = null,
                                  Consent_Text__c = null,
                                  Consent_Text_Version__c = null,
                                  Privacy_Policy_Version__c = null,
                                  Consent_Registration_Source_URL__c = null,
                                  Opt_in_Source__c = null, BillingStreet = null, 
                                  BillingCity = null,BillingPostalCode = null,BillingCountry = null
                                  );
        insert acc;
        System.debug(acc);

        String communityNetwId = [SELECT Id FROM NETWORK WHERE Name = :Label.CommunityName].Id;
        
        Test.startTest();
            DELoyaltyCommunityHelper.isCommunityAccountPresent(u, communityNetwId, '2000-10-01', 'true');
        Test.stopTest();

    }
    
    @IsTest
    static void testAccountCreation(){
       /*  User u = new User();
        u.FirstName ='testF';
        u.LastName = 'testL';
        u.Email= 'test@test.com';
        u.PostalCode = '75008';
        u.Street = 'street';
        u.City  = 'cityName';
        u.MobilePhone  = 0000000; */
        EncryptionKey__c encrypnKey = new EncryptionKey__c(SetupOwnerId=UserInfo.getOrganizationId());
        encrypnKey.Algorithm__c = 'AES256';
        encrypnKey.IV__c = '7402862816488480';
        encrypnKey.Key__c = 'falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X';
        encrypnKey.OptinURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf';
        encrypnKey.OptoutURLPlaceholder__c = 'https://denl-test.jdecoffee.net/Newsletter/Opt-out/?id=EID&s=SIG&origin=sf';
        insert encrypnKey;

        Account a = new Account (Name = 'TestNNN',Customer_ID__c = 1);
        insert a;

        User u = TestDataFactory.TestCreateUser(1, true)[0];
        String communityNetwId = [SELECT Id FROM NETWORK WHERE Name = :Label.CommunityName].Id;

        Test.startTest();
            DELoyaltyCommunityHelper.isCommunityAccountPresent(u, communityNetwId, '2000-10-01', 'true');
        Test.stopTest();
        
    }

     @IsTest
    static void testGetInactiveUsers(){
       List<User> userList = TestDataFactory.TestCreateUser(2, true);
       Set<String> userSet = new Set<String>();

       for(User u : userList){
        userSet.add(u.Username);
       }

       Test.startTest();
           List<User> inactiveUsers= DELoyaltyCommunityHelper.getInactiveUsers(userSet);
       Test.stopTest();
       System.assert(inactiveUsers.size() == 0);
        
    }
}