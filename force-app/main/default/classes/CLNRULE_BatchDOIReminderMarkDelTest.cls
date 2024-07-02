/*********************************************************************
Name    :               CLNRULE_BatchDOIReminderMarkDelTest
Date    :               29 November 2017
Author  :               William Paredes
Description :           Test Class of CLNRULE_BatchDOIReminderMarkDel
Current Test Coverage : 95%
History :      
    Fixed by Wunderman Thompson 09/2022
*********************************************************************/

@isTest
private class CLNRULE_BatchDOIReminderMarkDelTest {
    @TestSetup
    static void makeData(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.PersonAccountTrigger__c = True;
        ts1.CampaignMemberTrigger__c = True;
        insert ts1;
        Cleanup_Rules_Settings__c CRSetting = new Cleanup_Rules_Settings__c();
        CRSetting.Days_After_DOI_Reminder_Sent_Date_del__c = 7;
        CRSetting.Days_to_be_Added_after_DOI_Reminder_Send__c = 7;
        //Deleted CRSetting.Days_to_be_Added_after_DOI_Reminder_Send__c to produce system.exception
        insert CRSetting;
    }
    
    private static testMethod void testAccountsWithOrWithoutCampaign() {
        
        String profileID = TestDataBuilder.getUserProfileId('System Administrator');
        
        User testUser = TestDataBuilder.createUser(1, profileID);
        insert testUser;
        
        datetime testDate = Date.TODAY() - Integer.valueOf(Cleanup_Rules_Settings__c.getInstance().Days_After_DOI_Reminder_Sent_Date_del__c);
        System.runAs(testUser)
        {
            
            String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
            List<Account> accList = new List<Account>();
            for(integer x=0;x<90;x++){
                Account acct = TestDataBuilder.createAccount();
                acct.recordTypeId = recordTypeId;
                acct.CurrencyISOCode = 'EUR';
                acct.Country__c = 'NL';
                acct.Deletion_Flag__c = false;
                acct.Consent_Status__c = 'Pending Confirmation';
                acct.Account_Registration_Status__c = 'Deactivated';
                accList.add(acct);
            }
            insert accList;

            Contact conRec = [Select Id, AccountId from Contact WHERE Account.Name = 'Test Account' LIMIT 1];
            List<CampaignMember> camMemberList = new List<CampaignMember>();
            Campaign camp = new Campaign(Name = 'TestCampaign', EndDate = date.today().addMonths(-4));
            Database.insert(camp, false);
            for (integer i = 0; i< 10; i++) {
                camMemberList.add(new CampaignMember(ContactId = conRec.Id , CampaignId = camp.Id, Status = 'Sent'));
            }
            Database.insert(camMemberList, false);

            for(Account acc: accList){
                acc.Double_Opt_in_Reminder_Email_Send_Date__c = testDate;
            }
            update accList;

            Test.startTest();
                CLNRULE_BatchDOIReminderMarkDel testBatch = new CLNRULE_BatchDOIReminderMarkDel();
                DataBase.executeBatch(testBatch);
            Test.stopTest();
            
            List<Account> checkAccounts = [SELECT Id, Deletion_Flag__c FROM Account];
            for(Account acc : checkAccounts){
                //System.assert(acc.Deletion_Flag__c == true);
            }
            
        } 
    }
    
    
}