@IsTest
public class LightningConfirmEmailControllerTest {
  @IsTest
  static void testConfirmEmail() {
    Account acc = new Account(
      FirstName = 'TESTforTEST',
      LastName = 'UserTestTEST',
      PersonEmail = 'testForTest1995@gmail.com',
      Gender__pc = 'Male',
      PersonBirthdate = System.today().addYears(-18),
      BillingPostalCode = '12365',
      BillingStreet = 'Mckinley hill:22:A',
      BillingCity = 'Taguig',
      Phone = '12345567465',
      Sixteen_Years_or_Older__c = true,
      Data_Migration_Id__c = '123456',
      Customer_ID__c = 123456,
      External_Id__c = 'testForTest1995@gmail.comNLDouwe Egberts',
      Account_Consent_Registration_Date__c = system.today(),
      Type__c = 'Loyalty',
      Consent_Status__c = 'Active',
      Brand__c = Label.Brand, //Douwe Egberts
      OwnerId = Label.CommunityOwnerID
      //RecordTypeId  = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account' LIMIT 1].Id
    );
    insert acc;

    Blob targetBlob = Blob.valueOf(String.valueOfGmt(acc.PersonBirthdate));
    Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
    String hashBase64SHA1 = EncodingUtil.base64encode(hash);

    System.debug('account ' + acc.RecordTypeId);
    Account acct = [
      SELECT Id, Name, PersonEmail
      FROM Account
      WHERE PersonEmail = 'testForTest1995@gmail.com'
      LIMIT 1
    ];
    System.debug('account ' + acc);

    Test.startTest();
    // test confirmed
    String confirmEmailResponse = LightningConfirmEmailController.confirmEmail(
      hashBase64SHA1,
      'testForTest1995@gmail.com',
      './login'
    );
    System.assert(confirmEmailResponse == 'Confirmed');
    System.debug(confirmEmailResponse);

    Test.stopTest();
  }

  @IsTest
  static void testAlreadyConfirmed() {
    Account acc = new Account(
      FirstName = 'TESTforTEST',
      LastName = 'UserTestTEST',
      PersonEmail = 'testForTest1995@gmail.com',
      Gender__pc = 'Male',
      PersonBirthdate = System.today().addYears(-18),
      BillingPostalCode = '12365',
      BillingStreet = 'Mckinley hill:22:A',
      BillingCity = 'Taguig',
      Phone = '12345567465',
      Sixteen_Years_or_Older__c = true,
      Data_Migration_Id__c = '123456',
      Customer_ID__c = 123456,
      External_Id__c = 'testForTest1995@gmail.comNLDouwe Egberts',
      Account_Consent_Registration_Date__c = system.today(),
      Type__c = 'Loyalty',
      Consent_Status__c = 'Active',
      Brand__c = Label.Brand, //Douwe Egberts
      OwnerId = Label.CommunityOwnerID,
      Email_Confirmed__c = true
      //RecordTypeId  = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account' LIMIT 1].Id
    );
    insert acc;

    Blob targetBlob = Blob.valueOf(String.valueOfGmt(acc.PersonBirthdate));
    Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
    String hashBase64SHA1 = EncodingUtil.base64encode(hash);

    System.debug('account ' + acc.RecordTypeId);
    Account acct = [
      SELECT Id, Name, PersonEmail
      FROM Account
      WHERE PersonEmail = 'testForTest1995@gmail.com'
      LIMIT 1
    ];
    System.debug('account ' + acc);

    Test.startTest();
    // test already confirmed
    String alreadyConfirmedResponse = LightningConfirmEmailController.confirmEmail(
      hashBase64SHA1,
      'testForTest1995@gmail.com',
      './login'
    );
    System.assert(alreadyConfirmedResponse == 'Already confirmed');
    System.debug(alreadyConfirmedResponse);

    Test.stopTest();
  }
  @IsTest
  static void testNotFound() {
    Account acc = new Account(
      FirstName = 'TESTforTEST',
      LastName = 'UserTestTEST',
      PersonEmail = 'testForTest1995@gmail.com',
      Gender__pc = 'Male',
      PersonBirthdate = System.today().addYears(-18),
      BillingPostalCode = '12365',
      BillingStreet = 'Mckinley hill:22:A',
      BillingCity = 'Taguig',
      Phone = '12345567465',
      Sixteen_Years_or_Older__c = true,
      Data_Migration_Id__c = '123456',
      Customer_ID__c = 123456,
      External_Id__c = 'testForTest1995@gmail.comNLDouwe Egberts',
      Account_Consent_Registration_Date__c = system.today(),
      Type__c = 'Loyalty',
      Consent_Status__c = 'Active',
      Brand__c = Label.Brand, //Douwe Egberts
      OwnerId = Label.CommunityOwnerID,
      Email_Confirmed__c = true
      //RecordTypeId  = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE = 'ACCOUNT' AND NAME = 'Person Account' LIMIT 1].Id
    );
    insert acc;

    Blob targetBlob = Blob.valueOf(String.valueOfGmt(acc.PersonBirthdate));
    Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
    String hashBase64SHA1 = EncodingUtil.base64encode(hash);

    System.debug('account ' + acc.RecordTypeId);
    Account acct = [
      SELECT Id, Name, PersonEmail
      FROM Account
      WHERE PersonEmail = 'testForTest1995@gmail.com'
      LIMIT 1
    ];
    System.debug('account ' + acc);

    Test.startTest();
    // test already confirmed
    String notFOund = LightningConfirmEmailController.confirmEmail(
      hashBase64SHA1,
      'testForTl.com',
      './login'
    );
    System.assert(notFOund == 'Customer  not found');
    System.debug(notFOund);

    Test.stopTest();
  }
}
