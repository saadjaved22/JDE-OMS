/*********************************************************************
Name    :      CLNRules_NoEmlSntToCustSchedTest
Date    :       07 December 2017
Author  :       William Paredes
Description:    Test class for CLNRules_NoEmlSntToCustSchedulable
History : 
History
    fixed by Wunderman Thompson  09/2022
*********************************************************************/

@isTest
private class CLNRules_NoEmlSntToCustSchedTest {

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
            
            CLNRules_NoEmlSntToCustSchedulable sh1 = new CLNRules_NoEmlSntToCustSchedulable();      
            String sch = '0 0 15 * * ?';
            system.schedule('Test run schedulable', sch, sh1);
        Test.stopTest();
	}

}