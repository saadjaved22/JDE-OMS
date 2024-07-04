@IsTest
public class DEPortalUsersConfirmEmailReminderTest {
  @IsTest
  static void testReminder() {
    String RecType = [
      SELECT ID
      FROM RECORDTYPE
      WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account'
    ]
    .Id;
    List<Account> lstAccount = new List<Account>();
    for (Integer i = 0; i <= 120; i++) {
      lstAccount.add(
        new Account(
          FirstName = 'T' + i + 'e' + i + 'st' + i + 't',
          LastName = 'U' + i + 's' + i + 'er' + i + 'r',
          PersonEmail = 'jde1' + i + '@douweEgberts.com',
          Gender__pc = 'Male',
          PersonBirthdate = System.today().addYears(-18),
          BillingPostalCode = '12365',
          BillingStreet = 'Mckinley hill:22:A',
          BillingCity = 'Taguig',
          Phone = '12345567465',
          Sixteen_Years_or_Older__c = true,
          Data_Migration_Id__c = '123456' + i,
          Customer_ID__c = 123456 + i,
          External_Id__c = 'jde1' + i + '@douweEgberts.comNLDouwe Egberts',
          Account_Consent_Registration_Date__c = system.today(),
          Type__c = 'Loyalty',
          Consent_Status__c = 'Active',
          Brand__c = Label.Brand, //Douwe Egberts
          OwnerId = Label.CommunityOwnerID,
          Loyalty_Email_Sent_Date__c = System.today(),
          RecordTypeId = RecType
        )
      );
    }

    insert lstAccount;
    for (Account a : lstAccount) {
      Test.setCreatedDate(a.Id, Datetime.now().addDays(-1));
    }

    List<Contact> contactList = [SELECT ID FROM CONTACT];
    System.debug(contactList.size());

    List<User> userList = TestDataFactory.TestCreateUser(120, true);
    for (Integer i = 0; i <= 120; i++) {
      userList[i].ContactId = contactList[i].ID;
      userList[i].Alias = 'DE' + i;
      userList[i].CommunityNickname = userList[i].Alias;
      userList[i].Username =
        'U' +
        i +
        's' +
        i +
        'er' +
        i +
        'r' +
        '@douweEgberts.com';
    }
    insert userList;

    Test.startTest();
    DEPortalUsersConfirmEmailReminderBatch b = new DEPortalUsersConfirmEmailReminderBatch();
    database.executebatch(b);
    Test.stopTest();
  }
}
