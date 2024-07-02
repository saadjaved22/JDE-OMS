/*********************************************************************
Name    :      CLNRULE_BtcDOIReminderMrkDelSchedTest
Date    :       07 December 2017
Author  :       William Paredes
Description:    Test class for CLNRULE_BtcDOIReminderMrkDelSchedulable
History : 
History
    @Fixed by Wunderman Thompson  09/2022
*********************************************************************/

@isTest
private class CLNRULE_BtcDOIReminderMrkDelSchedTest {

	private static testMethod void testScheduler() {
        Test.StartTest();
        
            ProcessBuilderSettings__c PBSettings = new ProcessBuilderSettings__c();
            PBSettings.IndividualEmailResultProcessBuilder__c = true;
            insert PBSettings;
            
            Cleanup_Rules_Settings__c CRSetting = new Cleanup_Rules_Settings__c();
            CRSetting.Days_After_DOI_Reminder_Sent_Date_del__c = 7;
            CRSetting.Days_to_be_Added_after_DOI_Reminder_Send__c = 14;
            insert CRSetting;

            
            String recordTypeIdSt = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
            List<Account> accList = new List<Account>();
            for(integer x=0;x<=50;x++){
                Account acct = new Account(LastName='AccountTest '+x, recordTypeId = recordTypeIdSt);
                accList.add(acct);
            }
            insert accList;
            
            CLNRULE_BtcDOIReminderMrkDelSchedulable sh1 = new CLNRULE_BtcDOIReminderMrkDelSchedulable();      
            String sch = '0 0 15 * * ?';
            system.schedule('Test run schedulable', sch, sh1);
        Test.stopTest();
	}

}