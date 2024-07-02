/*********************************************************************
Name    :       CLNRules_DeleteAccountsSchedTest
Date    :       07 December 2017
Author  :       William Paredes
Description:    Test class for CLNRules_DeleteAccountsSchedulable
History : 
History
    fixed by Wunderman Thompson  09/2022
*********************************************************************/

@isTest
private class CLNRules_DeleteAccountsSchedTest {

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
            
            CLNRules_DeleteAccountsSchedulable sh1 = new CLNRules_DeleteAccountsSchedulable();      
            String sch = '0 0 15 * * ?';
            system.schedule('Test run schedulable', sch, sh1);
        Test.stopTest();
	}

}