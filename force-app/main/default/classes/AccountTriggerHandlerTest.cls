/*********************************************************************
Name    :               AccountTriggerHandlerTest
Date    :               20 June 2017
Author  :               Anjerico Caburnay
Description :           Test Class of AccountTriggerHandler for Account Object
Current Test Coverage : 100% 
History :       
*********************************************************************/

@isTest
private class AccountTriggerHandlerTest{
    
    
        @testSetup()
   	 	static void createAdminUser() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		insert r;
        User usr = new User();
        usr.ProfileId =  [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usr.UserRoleId = r.Id;
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.LastName = 'Test LName';
        usr.FirstName = 'Test Fname';
        usr.Email = 'tstUsr@email.com';
        usr.Username = 'tst123@email.com';
        usr.Alias = 'tstUsr';
        usr.CommunityNickname = 'Test Nickname';
        usr.isActive = true;
        insert usr;
    }
     private static testMethod void soiFlow(){
    	TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        DateTime dateToday = System.today();
		String dateTodayStr = dateToday.format('yyyy-MM-dd');
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Consent_Registration_Source_URL__c = 'Checkout';
        accRec.Brand__c = 'Tassimo';
        accRec.Country__c = 'FR';
        accRec.Consent_Registration_Date__c = system.today();
          Test.startTest();
        insert accRec;
        
        accRec.Consent_Registration_Date__c = system.today();
        accRec.Single_Opt_in__c = True;
        accRec.Consent_Status__c = 'Confirmed';
        update accRec;         
        System.debug('Insert Record: + ' + accRec); 
		   Test.stopTest();     
    }
    
    private static testMethod void testOptInRequestDate() {
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        ProcessBuilderSettings__c pb1 = new ProcessBuilderSettings__c();
        pb1.AccountProcessBuilder__c = True;
        insert pb1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> accList = new List<Account>();
        for(integer x=0;x<10;x++){
            Account acct = TestDataBuilder.createAccount();
            acct.recordTypeId = recordTypeId;
            acct.Opt_in_Request_Date__c = Date.Today();
            accList.add(acct);
        }
        
        insert accList;
        
        for(Account acc: accList){
            acc.Opt_in_Request_Date__c = Date.Today()-1;
        }
        
        update accList;
    }
    
    private static testMethod void testOptInConfirmationDate() {
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        ProcessBuilderSettings__c pb1 = new ProcessBuilderSettings__c();
        pb1.AccountProcessBuilder__c = True;
        insert pb1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> accList = new List<Account>();
        for(integer x=0;x<10;x++){
            Account acct = TestDataBuilder.createAccount();
            acct.recordTypeId = recordTypeId;
            acct.Opt_in_Confirmation_Date__c = Date.Today();
            accList.add(acct);
        }
        
        insert accList;
        
        for(Account acc: accList){
            acc.Opt_in_Confirmation_Date__c = Date.Today()-1;
        }
        
        update accList;
    }
    
    private static testMethod void testOptOutRequestDate() {
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        ProcessBuilderSettings__c pb1 = new ProcessBuilderSettings__c();
        pb1.AccountProcessBuilder__c = True;
        insert pb1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> accList = new List<Account>();
        for(integer x=0;x<10;x++){
            Account acct = TestDataBuilder.createAccount();
            acct.recordTypeId = recordTypeId;
            acct.Opt_out_Request_Date__c = Date.Today();
            accList.add(acct);
        }
        
        insert accList;
        
        for(Account acc: accList){
            acc.Opt_out_Request_Date__c = Date.Today()-1;
        }
        
        update accList;
    }
    
    private static testMethod void testElse() {
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        ProcessBuilderSettings__c pb1 = new ProcessBuilderSettings__c();
        pb1.AccountProcessBuilder__c = True;
        insert pb1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> accList = new List<Account>();
        for(integer x=0;x<10;x++){
            Account acct = TestDataBuilder.createAccount();
            acct.recordTypeId = recordTypeId;
            accList.add(acct);
        }
        
        insert accList;
        
        for(Account acc: accList){
            acc.Phone = '123';
        }
        
        update accList;
    }
    
    private static testMethod void testCurrency() {
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        ProcessBuilderSettings__c pb1 = new ProcessBuilderSettings__c();
        pb1.AccountProcessBuilder__c = True;
        insert pb1;
        
        list<CurrencyCustomSet__c> lstAccounts=new list<CurrencyCustomSet__c>();//bulk List of custom setting object for bulk insert
        
        CurrencyCustomSet__c ccs1 = new CurrencyCustomSet__c();
        ccs1.Name ='CZ';
        ccs1.Country_Code__c = 'CZ';
        ccs1.Currency__c = 'CZK';
        lstAccounts.add(ccs1);
        
        CurrencyCustomSet__c ccs2 = new CurrencyCustomSet__c();
        ccs2.Name = 'SE';
        ccs2.Country_Code__c = 'SE';
        ccs2.Currency__c = 'SEK';
        lstAccounts.add(ccs2);
        
        insert lstAccounts;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> accList = new List<Account>();
        for(integer x=0;x<10;x++){
            Account acct = TestDataBuilder.createAccount();
            if(x<5)
                acct.Country__c = 'CZ';
            else if (x>5)
                acct.Country__c = 'SE';
            acct.recordTypeId = recordTypeId;
            accList.add(acct);
        }
        
        insert accList;
        List<Account> insertedAccounts = [SELECT country__c, CurrencyIsoCode FROM Account];
        system.debug(insertedAccounts); 
        for(Account acc: accList){
            acc.Phone = '123';
        }
        
        //update accList;
    }
    
    private static testMethod void checkAccountTypeIfLoyaltyThenRemainLoyalty(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.FirstName = 'testing 123';
        accRec.LastName = 'testing 321';
        accRec.Consent_Registration_Source_URL__c = 'Checkout';
        accRec.Brand__c = 'Tassimo';
        accRec.Country__c = 'FR';
        accRec.Consent_Registration_Date__c = system.today();
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.RecordTypeId = recordTypeId;
        accRec.Type__c = 'Loyalty';
        insertAccs.add(accRec);
        insert insertAccs;
        test.startTest();
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Consent_Registration_Date__c = system.today();
        update insertAccs;
        test.stopTest();
    }
    
    private static testMethod void createLoyaltyRecord(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Loyalty';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL@salesforce.com';
        accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
        insert accRec;
        
        Test.startTest();
        Test.stopTest();
        
        
    }
    
    public static testMethod void loyaltyPointsDelete(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Type__c = 'Loyalty';
        insert accRec;
        
        Loyalty__c ltyRec = new Loyalty__c();
        ltyRec.Loyalty_Consumer__c = accRec.Id;
        ltyRec.External_Id__c = 'imapaguio+002@gmail.comNLDouwe Egberts';
        insert ltyRec;
        
        Loyalty_Transaction__c ltyTransRec = new Loyalty_Transaction__c();
        ltyTransRec.Loyalty__c = ltyRec.Id;
        ltyTransRec.Loyalty_Consumer__c = accRec.Id;
        ltyTransRec.Loyalty_Transaction_Type__c = 'Compensation';
        ltyTransRec.Loyalty_Source__c = 'Blokker POS';
        ltyTransRec.Transaction_Amount__c = 1000;
        insert ltyTransRec;
        
        try{
            Delete accRec;
        }
        catch(Exception ee){
            
        }
    }
    
    /* private static testMethod void lastEmailSentHardBounced(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.isHardBounced__pc = True;
        insertAccs.add(accRec);
        insert insertAccs;
        test.startTest();
        accRec.To_be_Deleted_Date__c = date.today() + 7;
        accRec.Deletion_Flag__c = true;
        accRec.Deletion_Reason__c = 'Email hard bounced';
        update insertAccs;
        test.stopTest();
    } */
    
    private static testMethod void gdprConsumerCleaningRulesv1(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Consumer_Withdraws__c = 7;
        insert settings;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Consent_Withdrawn_Date__c = Date.Today();
        insertAccs.add(accRec);
        
        insert insertAccs;
        accRec.Deletion_Flag__c = True;
        accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
        accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Consent_Withdrawn_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Withdraws__c));
        System.debug('meron ba?' + insertAccs);
        update insertAccs;
    }
    
    private static testMethod void gdprConsumerCleaningRulesv2(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Consumer_Deletes_Account__c = 7;
        insert settings;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Account_Deletion_Date__c = Date.Today();
        insertAccs.add(accRec);
        
        insert insertAccs;
        accRec.Deletion_Flag__c = True;
        accRec.Deletion_Reason__c = Label.DelReason_Consent_Withdrawn;
        accRec.To_be_Deleted_Date__c = Date.valueOf(accRec.Account_Deletion_Date__c).addDays(Integer.valueOf(settings.Days_for_Consumer_Deletes_Account__c));
        update insertAccs;
    }    
    
    private static testMethod void gdprConsumerCleaningRulesv3(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Deletion_Flag__c = False;
        accRec.Consent_Status__c = 'Active';
        accRec.Consent_Withdrawn_Date__c = Date.Today();
        insertAccs.add(accRec);
        
        insert insertAccs;
        accRec.Consent_Withdrawn_Date__c = null;
        accRec.Deletion_Flag__c = False;
        accRec.Deletion_Reason__c = null;
        accRec.To_be_Deleted_Date__c = null;
        update insertAccs;
    }    
    
    private static testMethod void gdprConsumerCleaningRulesv4(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Consent_Status__c = 'Active';
        accRec.Double_Opt_in_Email_Send_Date__c = Date.Today();
        insertAccs.add(accRec);
        
        insert insertAccs;
        accRec.Deletion_Flag__c = False;
        accRec.Deletion_Reason__c = null;
        accRec.To_be_Deleted_Date__c = null;
        update insertAccs;
    }    
    
    private static testMethod void gdprConsumerCleaningRulesv5(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Consumer_Withdraws__c = 7;
        insert settings;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Account_Deletion_Date__c = Date.Today();
        accRec.Consent_Status__c = 'Active';
        insertAccs.add(accRec);
        
        insert insertAccs;
        accRec.Account_Deletion_Date__c = null;
        accRec.Deletion_Flag__c = False;
        accRec.Deletion_Reason__c = null;
        accRec.To_be_Deleted_Date__c = null;
        update insertAccs;
    }      
    
    private static testMethod void gdprConsumerCleaningRulesv6(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Request_to_be_Forgotten__c = 7;
        insert settings;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Request_to_be_Forgotten__c = True;
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Active';
        insertAccs.add(accRec);
        
        insert insertAccs;
        accRec.Account_Deletion_Date__c = date.today(); 
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Consent_Withdrawn_Date__c = DateTime.Now();
        accRec.Deletion_Flag__c = True;
        accRec.Deletion_Reason__c = Label.DelReason_Request_to_be_Forgotten; 
        accRec.To_be_Deleted_Date__c = date.Today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
        update insertAccs;
    }  
    
    private static testMethod void gdprConsumerCleaningRulesv7(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Request_to_be_Forgotten__c = 7;
        insert settings;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        List<Account> insertAccs = new List<Account>();
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Country__c = 'NL';
        accRec.Deletion_Flag__c = False;
        accRec.Request_to_be_Forgotten__c = True;
        accRec.Account_Registration_Status__c = null;
        insertAccs.add(accRec);
        
        insert insertAccs;
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Consent_Withdrawn_Date__c = DateTime.Now();
        accRec.Deletion_Flag__c = True;
        accRec.Deletion_Reason__c = Label.DelReason_Request_to_be_Forgotten; 
        accRec.To_be_Deleted_Date__c = date.Today().addDays(Integer.valueOf(settings.Days_for_Request_to_be_Forgotten__c));
        update insertAccs;
    }
    
    private static testMethod void newsletterToLoyaltyUpdate(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Brand__c = 'Maison du Café';
        accRec.Country__c = 'FR';
        accRec.Brewers_Selected__c = 'Capsule Brewer';
        accRec.Consent_Registration_Source_URL__c = 'test.URL';
        insert accRec;
        
        Test.startTest();
        accRec.Consent_Status__c = 'Active';
        update accRec;         
        System.debug('Insert Record: + ' + accRec); 
        Test.stopTest();
    }
    
    private static testMethod void loyaltyTotalPointsDelete(){
    	TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        insert accRec;
        
		Loyalty__c ltyRec = new Loyalty__c();
        ltyRec.Loyalty_Consumer__c = accRec.Id;
        ltyRec.External_Id__c = 'imapaguio+002@gmail.comNLDouwe Egberts';
        insert ltyRec;
        
		Loyalty_Transaction__c ltyTransRec = new Loyalty_Transaction__c();
        ltyTransRec.Loyalty__c = ltyRec.Id;
        ltyTransRec.Loyalty_Consumer__c = accRec.Id;
        ltyTransRec.Loyalty_Transaction_Type__c = 'Compensation';
        ltyTransRec.Loyalty_Source__c = 'Blokker POS';
        ltyTransRec.Transaction_Amount__c = 1000;
        insert ltyTransRec;
        
        try{
        	Delete accRec;
        }
        catch(Exception ee){
            
        }
    }
    
    @isTest
    private static void testHighcoDelete() {
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        
        BoomiMock mock = new BoomiMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        BoomiAPI__c sett = new BoomiAPI__c();
        sett.Partner_Key__c = 'aa';
        sett.Endpoint_URL__c = 'http://';
        sett.Token__c = 'x';
        insert sett;
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Request_to_be_Forgotten__c = true;
        accRec.HighCO_synced__c = false;
		accRec.PersonEmail = 'test@email.com';
        insert accRec;
        
        accRec.HighCO_synced__c = true;
       

        Test.startTest();
        	update accRec;
        Test.stopTest(); 
    }
    
        public static testMethod void maskingAccount(){
        
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
       
        User u = [SELECT Id, IsActive FROM user Where Profile.Name = 'System Administrator' and CommunityNickname = 'Test Nickname'  limit 1];
  
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.FirstName = 'fname';
        accRec.Request_to_be_Forgotten__c = false; 
        accRec.LastName = 'lname';
        accRec.PersonEmail = 'test@email.com';
        accRec.OwnerId = u.Id;
        accRec.Request_to_be_Forgotten__c = false;
        accRec.Type__c = 'Loyalty';
        accRec.RecordTypeId = recordTypeId;
        accRec.User_Active__pc = true;
        insert accRec;
        
        Contact con = [SELECT Id, FirstName, LastName FROM Contact WHERE AccountId = :accRec.Id];
        createPartnerUser(con.Id);
        
        accRec.Request_to_be_Forgotten__c = true;
       

        Test.startTest();
        	update accRec;
        Test.stopTest(); 
         
    }
   
    @future
    private static void createPartnerUser(ID cId){
        User usr = new User();
        usr.ProfileId =  [SELECT Id FROM Profile WHERE Name = 'DE External Identity User'].Id;
        usr.PortalRole = 'PersonAccount';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.LastName = 'Test LName';
        usr.FirstName = 'Test Fname';
        usr.Email = 'tstUsrCommunityDEUser@email.com';
        usr.Username = 'tstUsrCommunityDEUser@email.com';
        usr.Alias = 'tstUsr';
        usr.CommunityNickname = 'Community Test Nick';
        usr.contactId = cId;
        usr.isActive = true;
        insert usr;
        
        
    }
    
    public static testMethod void brewerRegistrationTest(){
        
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
       
        User u = [SELECT Id, IsActive FROM user Where Profile.Name = 'System Administrator' and CommunityNickname = 'Test Nickname'  limit 1];
  
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.FirstName = 'fname';
        accRec.Request_to_be_Forgotten__c = false; 
        accRec.LastName = 'lname';
        accRec.PersonEmail = 'test@email.com';
        accRec.OwnerId = u.Id;
        accRec.Request_to_be_Forgotten__c = false;
        accRec.Type__c = 'Loyalty';
        accRec.RecordTypeId = recordTypeId;
        accRec.User_Active__pc = true;
        insert accRec;
        
        Brewer_Registration__c bReg = new Brewer_Registration__c();
        bReg.Customer__c = accRec.Id;
        bReg.Name = 'Test Reference';
        bReg.CurrencyIsoCode = 'EUR';
        insert bReg;
        
        accRec.FirstName = 'new first name';
       

        Test.startTest();
        	update accRec;
        Test.stopTest(); 
         
    }

    @isTest
    public static void checkConsentStatusTest() {
        List<Account> accList = new List<Account>();

        Account acc = new Account(LastName='Test Confirmed DE Tassimo');
        acc.Consent_Status__c = 'Confirmed';
        acc.Country__c = 'DE';
        acc.Language__c = 'German';
        acc.Brand__c = 'Tassimo';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        acc = new Account(LastName='Test Confirmed UK Tassimo');
        acc.Consent_Status__c = 'Confirmed';
        acc.Country__c = 'UK';
        acc.Language__c = 'German';
        acc.Brand__c = 'Tassimo';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        acc = new Account(LastName='Test Active DE Tassimo');
        acc.Consent_Status__c = 'Active';
        acc.Country__c = 'DE';
        acc.Language__c = 'German';
        acc.Brand__c = 'Tassimo';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        acc = new Account(LastName='Test Active UK Tassimo');
        acc.Consent_Status__c = 'Active';
        acc.Country__c = 'UK';
        acc.Language__c = 'German';
        acc.Brand__c = 'Tassimo';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        acc = new Account(LastName='Test Confirmed DE Jacobs');
        acc.Consent_Status__c = 'Confirmed';
        acc.Country__c = 'DE';
        acc.Language__c = 'German';
        acc.Brand__c = 'Jacobs';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        acc = new Account(LastName='Test Confirmed UK Jacobs');
        acc.Consent_Status__c = 'Confirmed';
        acc.Country__c = 'UK';
        acc.Language__c = 'German';
        acc.Brand__c = 'Jacobs';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        acc = new Account(LastName='Test Active DE Jacobs');
        acc.Consent_Status__c = 'Active';
        acc.Country__c = 'DE';
        acc.Language__c = 'German';
        acc.Brand__c = 'Jacobs';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        acc = new Account(LastName='Test Active UK Jacobs');
        acc.Consent_Status__c = 'Active';
        acc.Country__c = 'UK';
        acc.Language__c = 'German';
        acc.Brand__c = 'Jacobs';
        acc.PersonEmail = 'test@example.com';

        accList.add(acc);

        insert accList;

        List<Account> accListOld = accList.deepClone(true);
        Map<Id, Account> oldMap = new Map<Id, Account>();
        for(Account a : accListOld) {
            a.Consent_Status__c = 'Expired';
            oldMap.put(a.Id, a);
        }

        Test.startTest();
        AccountTriggerHandler.checkConsentStatusOnInsert(accList);
        AccountTriggerHandler.sendYotpoRequestOnAfterInsert(accList);
        AccountTriggerHandler.checkConsentStatusOnUpdate(accList, oldMap);
        AccountTriggerHandler.sendYotpoRequestOnAfterUpdate(accList, oldMap);
        Test.stopTest();
    }
}