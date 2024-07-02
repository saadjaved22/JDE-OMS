/************************************************************************************************************************************************** 
@author: Wunderman Thompson :  Abderrezak FENOUCHE 
*    @date: 09/2022
*    @description: test class for CLNRULE_AccountWithOrWithoutCampaign
History
    Created by Wunderman Thompson  09/2022
**************************************************************************************************************************************************/
@IsTest
public  class CLNRULE_AccountWithOrWithoutCampaignTest {
    @TestSetup
    static void makeData(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        ts1.CampaignMemberTrigger__c = True;
        insert ts1;

        Cleanup_Rules_Settings__c CRSetting = new Cleanup_Rules_Settings__c();
        CRSetting.Days_for_Consumer_Deletes_Account__c = 0;
        CRSetting.Days_for_Request_to_be_Forgotten__c = 0;
        CRSetting.Days_for_Consumer_Withdraws__c = 0;

        //Deleted CRSetting.Days_to_be_Added_after_DOI_Reminder_Send__c to produce system.exception
        insert CRSetting;
    }
    public static testMethod void testScenario1_WithoutCampaign(){
        /***** Request to be forgotten ******/
        System.debug('Creation of Account 1');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL@salesforce.com';
        accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
        accRec.Request_to_be_Forgotten__c = True;
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        
        insert accRec;
        System.debug('Account Inserted');
        
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }

        
    }

    
    /* public static testMethod void testScenario2_WithoutCampaign(){
        
        System.debug('pumasok dito 2?');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 2';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
     	accRec.Request_to_be_Forgotten__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Account_Deletion_Date__c = date.today();
        insert accRec;
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }
    } */
    
  public static testMethod void testScenario3_WithoutCampaign(){
        /***** Consent Withdrawn ******/
        System.debug('pumasok dito 3?');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 3';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Consent_Withdrawn_Date__c =  date.today();
        System.debug('lumabas 3');
        insert accRec;
        System.debug('meron ba 3' + accRec);
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }
        
    }   

    public static testMethod void testScenario8_WithoutCampaign(){
        /***** No commercial Consent without campaign  ******/
        System.debug('pumasok dito 3?');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 3';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = Null;
        System.debug('lumabas 3');
        insert accRec;

        Test.setCreatedDate(accRec.Id, Date.today().addDays(-1));

        System.debug('meron ba 3' + accRec);
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }
        
    }  
    
    public static testMethod void testScenario4_WithCampaign(){
        /***** Consent Withdrawn  with campaign******/
        System.debug('pumasok dito 4?');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 4';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Consent_Withdrawn_Date__c =  date.today();
        System.debug('lumabas 4');
        insert accRec;
        
        System.debug('meron ba 4' + accRec);
        Contact conRec = [Select Id, AccountId from Contact WHERE Account.Name = 'Test Class 4' LIMIT 1];
        campaign camp = new Campaign(Name = 'TestCampaign', EndDate = date.today().addMonths(-4));
        Database.insert(camp, false);

        CampaignMember cmpM = new CampaignMember(ContactId = conRec.Id , CampaignId = camp.Id, Status = 'Sent');
        
        Database.insert(cmpM, false);
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }
        
    }
    
    public static testMethod void testScenario5_WithCampaign(){
        /***** Request to bne forgotten  with campaign******/
        System.debug('pumasok dito 4?');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 4';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Request_to_be_Forgotten__c = True;
        accRec.Consent_Withdrawn_Date__c =  Null;
        System.debug('lumabas 4');
        insert accRec;
        
        System.debug('meron ba 4' + accRec);
        Contact conRec = [Select Id, AccountId from Contact WHERE Account.Name = 'Test Class 4' LIMIT 1];
        campaign camp = new Campaign(Name = 'TestCampaign', EndDate = date.today().addMonths(-4));
        Database.insert(camp, false);

        CampaignMember cmpM = new CampaignMember(ContactId = conRec.Id , CampaignId = camp.Id, Status = 'Sent');
        
        Database.insert(cmpM, false);
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }
        
    }
    public static testMethod void testScenario6_WithCampaign(){
        /***** No commercial consent but with campaign ******/
        System.debug('pumasok dito 4?');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 4';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = Null;
        accRec.Consent_Withdrawn_Date__c =  Null;
        System.debug('lumabas 4');
        insert accRec;
        
        System.debug('meron ba 4' + accRec);
        Contact conRec = [Select Id, AccountId from Contact WHERE Account.Name = 'Test Class 4' LIMIT 1];
        campaign camp = new Campaign(Name = 'TestCampaign', EndDate = date.today().addMonths(-4));
        Database.insert(camp, false);

        CampaignMember cmpM = new CampaignMember(ContactId = conRec.Id , CampaignId = camp.Id, Status = 'Sent');
        
        Database.insert(cmpM, false);
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }
        
    }

    /* public static testMethod void testScenario7_WithCampaign(){
        System.debug('pumasok dito 4?');
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 4';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Newsletter Subscriber';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
     	accRec.Request_to_be_Forgotten__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Account_Deletion_Date__c = date.today();
        System.debug('lumabas 4');
        insert accRec;
        
        System.debug('meron ba 4' + accRec);
        Contact conRec = [Select Id, AccountId from Contact WHERE Account.Name = 'Test Class 4' LIMIT 1];
        campaign camp = new Campaign(Name = 'TestCampaign', EndDate = date.today().addMonths(-4));
        Database.insert(camp, false);

        CampaignMember cmpM = new CampaignMember(ContactId = conRec.Id , CampaignId = camp.Id, Status = 'Sent');
        
        Database.insert(cmpM, false);
        
        Test.startTest();
            CLNRULE_AccountWithOrWithoutCampaign testBatch = new CLNRULE_AccountWithOrWithoutCampaign();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
        for(Account acc : checkAccounts){
            System.assert(acc.Deletion_Flag__c == true);
        }
        
    } */

    
}