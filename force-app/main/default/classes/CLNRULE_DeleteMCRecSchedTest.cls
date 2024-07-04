/*********************************************************************
Name    :   CLNRULE_DeleteMCRecSchedTest
Date    :   22.Feb.2018
Author  :   Alexander Cruz
Desc    :   Test class for CLNRULE_DeleteMCRecSchedulable
History : 

History
    @Fixed by Wunderman Thompson  09/2022
*********************************************************************/

@isTest(seealldata=false)
private class CLNRULE_DeleteMCRecSchedTest {
  private static testMethod void testScheduler() {
    TestDataFactory.setProcessBuilderSettings();
    ProcessBuilderSettings__c prcSettings = ProcessBuilderSettings__c.getOrgDefaults();
    system.debug('prc prcSettings' + prcSettings);
    Test.StartTest();

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    List<Account> accList = new List<Account>();
    for (integer x = 0; x < 10; x++) {
      Account acct = TestDataBuilder.createAccount();
      acct.recordTypeId = recordTypeId;
      //acct.Opt_in_Request_Date__c = Date.Today();
      accList.add(acct);
    }

    insert accList;

    CLNRULE_DeleteMCRecSchedulable sh1 = new CLNRULE_DeleteMCRecSchedulable();
    String sch = '0 0 15 * * ?';
    system.schedule('Test run schedulable', sch, sh1);
    Test.stopTest();
  }
}
