/*********************************************************************
Name    :               CLNRULE_AccountWithoutCampaignTest
Date    :               
Author  :               
Description :           Test Class of CLNRULE_AccountWithCampaign
Current Test Coverage : 
History :       
*********************************************************************/

@isTest
private class CLNRULE_AccountWithoutCampaignTest{
    
    public static testMethod void testScenario1(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Consumer_Deletes_Account__c = 14;
        settings.Days_for_Consumer_Withdraws__c = 14;
        settings.Days_for_Request_to_be_Forgotten__c = 14;
        insert settings;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Loyalty';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL@salesforce.com';
        accRec.External_Id__c = 'testclassNL@salesforce.comNLDouweEgberts';
        accRec.Request_to_be_Forgotten__c = True;
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        
        insert accRec;
        
        
        
        Test.startTest();
        CLNRULE_AccountWithoutCampaign testBatch = new CLNRULE_AccountWithoutCampaign();
        DataBase.executeBatch(testBatch);
        Test.stopTest();
        
    }

    
    public static testMethod void testScenario2(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Consumer_Deletes_Account__c = 14;
        settings.Days_for_Consumer_Withdraws__c = 14;
        settings.Days_for_Request_to_be_Forgotten__c = 14;
        insert settings;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 2';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Loyalty';
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
        CLNRULE_AccountWithoutCampaign testBatch = new CLNRULE_AccountWithoutCampaign();
        DataBase.executeBatch(testBatch);
        Test.stopTest();
        
    }
    
  public static testMethod void testScenario3(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Consumer_Deletes_Account__c = 14;
        settings.Days_for_Consumer_Withdraws__c = 14;
        settings.Days_for_Request_to_be_Forgotten__c = 14;
        insert settings;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 3';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Loyalty';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Consent_Withdrawn_Date__c =  date.today();
        
        insert accRec;
        
        
        Test.startTest();
        CLNRULE_AccountWithoutCampaign testBatch = new CLNRULE_AccountWithoutCampaign();
        DataBase.executeBatch(testBatch);
        Test.stopTest();
        
    }   
    
    public static testMethod void testScenario4(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        insert ts1;
        Cleanup_Rules_Settings__c settings =  Cleanup_Rules_Settings__c.getInstance();
        settings.Days_for_Consumer_Deletes_Account__c = 14;
        settings.Days_for_Consumer_Withdraws__c = 14;
        settings.Days_for_Request_to_be_Forgotten__c = 14;
        insert settings;
        
        
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.LastName = 'Test Class 4';
        accRec.RecordTypeId = recordTypeId;
        accRec.Brand__c = 'Douwe Egberts';
        accRec.Type__c = 'Loyalty';
        accRec.Country__c = 'NL';
        accRec.PersonEmail = 'testclassNL2@salesforce.com';
        accRec.External_Id__c = 'testclassNL2@salesforce.comNLDouweEgberts';
        accRec.Deletion_Flag__c = False;
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Consent_Withdrawn_Date__c =  date.today();
        
        insert accRec;
        
        Contact conRec = [Select Id, AccountId from Contact WHERE Account.Name = 'Test Class 4' LIMIT 1];
        List<CampaignMember> camMemberList = new List<CampaignMember>();
        campaign camp = new Campaign(Name = 'TestCampaign', EndDate = date.today().addMonths(-4));
        Database.insert(camp, false);
        for (integer i = 0; i< 10; i++) {
            camMemberList.add(new CampaignMember(ContactId = conRec.Id , CampaignId = camp.Id, Status = 'Sent'));
        }
        Database.insert(camMemberList, false);
       
        
        Test.startTest();
        CLNRULE_AccountWithoutCampaign testBatch = new CLNRULE_AccountWithoutCampaign();
        DataBase.executeBatch(testBatch);
        Test.stopTest();
        
    } 
    
}