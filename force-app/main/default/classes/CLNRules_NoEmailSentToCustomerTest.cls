/*********************************************************************
Name    :               CLNRules_NoEmailSentToCustomerTest
Date    :               29 November 2017
Author  :               William Paredes
Description :           Test Class of CLNRules_NoEmailSentToCustomer
Current Test Coverage : 95%
History :       
History
    fixed by Wunderman Thompson  09/2022
*********************************************************************/

@isTest
private class CLNRules_NoEmailSentToCustomerTest {
  private static testMethod void testNoEmailSentCustomer() {
    Cleanup_Rules_Settings__c CLN_Settings = new Cleanup_Rules_Settings__c(
      SetupOwnerId = UserInfo.getOrganizationId()
    );
    CLN_Settings.Days_For_NoEmailSentToCustomer__c = 0;
    insert CLN_Settings;
    date testDate = Date.TODAY().addMonths(-25);

    String recordTypeId = TestDataBuilder.getObjectRecordTypeId(
      Account.SObjectType,
      'Person Account'
    );
    List<Account> accList = new List<Account>();
    for (integer x = 0; x < 10; x++) {
      Account acct = TestDataBuilder.createAccount();
      acct.recordTypeId = recordTypeId;
      acct.CurrencyISOCode = 'EUR';
      acct.Deletion_Flag__c = false;
      acct.Account_Registration_Status__c = 'Deactivated';
      acct.Last_Email_Send_Date__pc = testDate;
      acct.Last_Email_clicked__c = testDate;
      acct.Last_Email_opened__c = testDate;
      if (x < 5) {
        acct.brand__c = 'Tassimo';
      }
      accList.add(acct);
    }
    insert accList;

    for (Account ac : accList) {
      Test.setCreatedDate(ac.Id, testDate);
    }
    /* List<Order__c> orderList = new List<Order__c>(); 
            for(integer i=0;i<3;i++){
                Order__c o = new Order__c(Name= 'Test'+i,Customer__c=accList[i].Id, Start_Date__c = testDate);
                orderList.add(o);
            }
            insert orderList;
            System.debug('orders in tet \n'+orderList); */

    Test.startTest();
    CLNRules_NoEmailSentToCustomer testBatch = new CLNRules_NoEmailSentToCustomer();
    DataBase.executeBatch(testBatch);
    Test.stopTest();

    List<Account> checkAccountList = [
      SELECT Id, Deletion_Flag__c, Last_Email_Send_Date__pc
      FROM Account
    ];
    System.debug(checkAccountList);
    for (Account acc : checkAccountList) {
      system.assert(acc.Deletion_Flag__c == true);
    }
  }
}
