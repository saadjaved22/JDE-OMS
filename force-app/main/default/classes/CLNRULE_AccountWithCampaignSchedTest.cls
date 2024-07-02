@isTest
private class CLNRULE_AccountWithCampaignSchedTest {

	private static testMethod void testScheduler() {
        Test.StartTest();
        
            ProcessBuilderSettings__c PBSettings = new ProcessBuilderSettings__c();
            PBSettings.IndividualEmailResultProcessBuilder__c = true;
            insert PBSettings;
            
            String recordTypeIdSt = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
            List<Account> accList = new List<Account>();
            for(integer x=0;x<=50;x++){
                Account acct = new Account(LastName='AccountTest '+x, recordTypeId = recordTypeIdSt);
                accList.add(acct);
            }
            insert accList;
            
            CLNRULE_AccountWithCampaignSchedulable sh1 = new CLNRULE_AccountWithCampaignSchedulable();      
            String sch = '0 0 15 * * ?';
            system.schedule('Test run schedulable', sch, sh1);
        Test.stopTest();
	}

}