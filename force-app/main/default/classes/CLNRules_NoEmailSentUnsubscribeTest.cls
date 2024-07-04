@isTest
public class CLNRules_NoEmailSentUnsubscribeTest {
  @IsTest
  private static void testNoEmailSentCustomer() {
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
      acct.Consent_Status__c = 'Active';
      acct.Type__c = 'Registered';
      accList.add(acct);
    }
    insert accList;

    for (Account ac : accList) {
      Test.setCreatedDate(ac.Id, testDate);
    }

    Test.startTest();
    CLNRules_NoEmailSentUnsubscribe testBatch = new CLNRules_NoEmailSentUnsubscribe();
    DataBase.executeBatch(testBatch);
    Test.stopTest();

    List<Account> checkAccountList = [
      SELECT Id, Deletion_Flag__c, Last_Email_Send_Date__pc, Consent_Status__c
      FROM Account
    ];
    System.debug(checkAccountList);
    for (Account acc : checkAccountList) {
      system.assert(acc.Consent_Status__c == 'Expired');
    }
  }
}
