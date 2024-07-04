/* ----------------------------------------------------------------------------------------------
   Name: ConsumerStackTest
   Description: 

   Date         Version     Author              Summary of Changes 
   -----------  -------     -----------------   -----------------------------------------
   14-March-2018   1.0       ralph.r.v.gozarin   Intial creation
*/

@IsTest(seeAllData=false)
public class ConsumerStackTest {
  public static EncryptionKey__c encryptionKey = new EncryptionKey__c();
  static {
    encryptionKey = TestDataFactory.setCustomSetting();
    List<Account> lstacc = TestDataFactory.testAccountData();
    List<Loyalty__c> lstloyal = TestDataFactory.testLoyaltyData(lstacc);
  }

  @isTest
  static void testConfInfoNull() {
    Test.startTest();
    ConsumerStack.CreateLoyaltyConsumer(null);
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    ConsumerStack.CreateLoyaltyConsumer(cInfo);
    Test.stopTest();
  }
  @isTest
  static void testCreateLoyaltyConsumerConsumerExist() {
    Test.startTest();
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.FirstName = 'Test';
    cInfo.LastName = 'User';
    cInfo.HouseNumber = 22;
    cInfo.PostCode = '12365';
    cInfo.BirthDate = '1992-03-15';
    cInfo.Gender = 'Male';
    cInfo.Email = 'jde1@douweEgberts.com';

    Consumer.ConsumerResult resp = ConsumerStack.CreateLoyaltyConsumer(cInfo);
    System.assertEquals(Label.ConsumerExist, resp.status);
    Test.stopTest();
  }
  @isTest
  static void testBlankEmail() {
    Test.startTest();
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.Email = '';

    Consumer.ConsumerResult resp = ConsumerStack.CreateLoyaltyConsumer(cInfo);
    System.assertEquals(Label.ArgumentsMissing, resp.status);

    cInfo.FirstName = 'TestUser';
    cInfo.LastName = 'Loyalty';
    cInfo.HouseNumber = 22;
    cInfo.PostCode = '12365';
    cInfo.BirthDate = '1992-03-15';
    cInfo.Gender = 'Male';

    resp = ConsumerStack.ChangeConsumerDetails(cInfo);

    resp = ConsumerStack.UpgradeToLoyaltyAccount(cInfo);
    System.assertEquals(Label.ArgumentsMissing, resp.status);

    Test.stopTest();
  }
  @isTest
  static void testCreateLoyaltyConsumerArgumentAreMissing() {
    Test.startTest();

    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.FirstName = 'Test';
    cInfo.LastName = 'User';
    cInfo.HouseNumber = 22;
    cInfo.PostCode = '12365';
    cInfo.BirthDate = '1992-03-15';
    cInfo.Gender = 'Male';
    cInfo.Email = 'testuser@salesforce.com';
    cInfo.Id = 123456;

    Consumer.ConsumerResult resp = ConsumerStack.CreateLoyaltyConsumer(cInfo);
    System.assertEquals(Label.ArgumentsMissing, resp.status);
    cInfo.Id = null;
    resp = ConsumerStack.CreateLoyaltyConsumer(cInfo);
    Test.stopTest();
  }

  @isTest
  static void testChangeConsumerDetailsArgumentAreMissing() {
    Consumer.ConsumerResult response = ConsumerStack.ChangeConsumerDetails(
      null
    );
    System.assertEquals(Label.ArgumentsMissing, response.status);
  }

  @isTest
  static void testUpgradeToLoyaltyAccountArgumentAreMissing() {
    Consumer.ConsumerResult response = ConsumerStack.UpgradeToLoyaltyAccount(
      null
    );
    System.assertEquals(Label.ArgumentsMissing, response.status);
  }

  @isTest
  static void testInvalidEmail() {
    Test.startTest();
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.FirstName = 'TestUser';
    cInfo.LastName = 'Loyalty';
    cInfo.HouseNumber = 22;
    cInfo.PostCode = '12365';
    cInfo.BirthDate = '1992-03-15';
    cInfo.Gender = 'Male';
    cInfo.Email = 'testUser@';

    Consumer.ConsumerResult response = ConsumerStack.CreateLoyaltyConsumer(
      cInfo
    );
    System.assertEquals(Label.ArgumentsMissing, response.status);
    cInfo = null;
    response = ConsumerStack.ChangeConsumerDetails(cInfo);
    System.assertEquals(Label.ArgumentsMissing, response.status);
    cInfo = null;
    response = ConsumerStack.UpgradeToLoyaltyAccount(cInfo);
    System.assertEquals(Label.ArgumentsMissing, response.status);

    Test.stopTest();
  }

  @isTest
  static void testUpgradeToLoyaltyAccountConsumerExist() {
    Test.startTest();
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.FirstName = 'test';
    cInfo.LastName = 'User';
    cInfo.HouseNumber = 22;
    cInfo.PostCode = '123456789';
    cInfo.BirthDate = '1992-03-15';
    cInfo.Gender = 'Male';
    cInfo.Id = 1234567;
    cInfo.Email = 'jde2@douweEgberts.com';

    Consumer.ConsumerResult response3 = ConsumerStack.UpgradeToLoyaltyAccount(
      cInfo
    );
    System.assertEquals(Label.SuccessMessage, response3.status);
    Test.stopTest();
  }
  @isTest
  static void testCreateLoyaltyConsumerSuccess() {
    Test.startTest();
    string query = GetConsumerDetailsHelper.strQuery;
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.FirstName = 'test';
    cInfo.LastName = 'User 4';
    cInfo.HouseNumber = 22;
    cInfo.PostCode = '555';
    cInfo.BirthDate = '1992-03-15';
    cInfo.Gender = 'Male';
    cInfo.Email = 'jde9@douweEgberts.com';

    Consumer.ConsumerResult resp = new Consumer.ConsumerResult();
    resp = ConsumerStack.CreateLoyaltyConsumer(cInfo);
    System.assertEquals(Label.SuccessMessage, resp.status);

    cInfo = new Consumer.ConsumerInfo();

    cInfo.ID = resp.listConsumerRecord[0].ID;
    cInfo.Email = 'jde9@douweEgberts.com';
    cInfo.City = 'Manila';
    cInfo.BirthDate = '1980-03-16';
    cInfo.LastName = 'User 4';

    GetConsumerDetailsHelper.strQuery = query;
    resp = new Consumer.ConsumerResult();
    resp = ConsumerStack.ChangeConsumerDetails(cInfo);
    System.assertEquals(Label.SuccessMessage, resp.status);

    cInfo = new Consumer.ConsumerInfo();
    Integer confId = resp.listConsumerRecord[0].ID;
    cInfo.ID = confId;
    cInfo.Email = 'jde9@douweEgberts.com';
    cInfo.City = 'Manila';
    cInfo.BirthDate = 'abc';
    cInfo.LastName = 'User 4';
    resp = new Consumer.ConsumerResult();
    resp = ConsumerStack.ChangeConsumerDetails(cInfo);
    System.assertEquals(Label.ArgumentsMissing, resp.status);

    cInfo = new Consumer.ConsumerInfo();

    cInfo.ID = confId;
    cInfo.Email = 'jde9@douweEgberts.com';
    cInfo.City = 'Manila';
    cInfo.BirthDate = 'abc';
    cInfo.Gender = '';
    cInfo.LastName = 'User 4';

    resp = new Consumer.ConsumerResult();
    resp = ConsumerStack.ChangeConsumerDetails(cInfo);
    System.assertEquals(Label.ArgumentsMissing, resp.status);

    Test.stopTest();
  }
  @isTest
  static void testUpgradeToLoyaltyAccountSuccess() {
    Test.startTest();
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.Email = 'jde4@douweEgberts.com';
    cInfo.Id = 123456789;
    cInfo.LastName = 'Test';
    cInfo.Gender = 'Male';

    Consumer.ConsumerResult resp = new Consumer.ConsumerResult();
    resp = ConsumerStack.UpgradeToLoyaltyAccount(cInfo);
    System.assertEquals(Label.SuccessMessage, resp.status);
    Test.stopTest();
  }
  @isTest
  static void testUpgradeToLoyaltyAccountInvalidEmail() {
    Test.startTest();
    Consumer.ConsumerInfo cInfo = new Consumer.ConsumerInfo();
    cInfo.Email = 'xyz';

    Consumer.ConsumerResult resp = new Consumer.ConsumerResult();
    resp = ConsumerStack.UpgradeToLoyaltyAccount(cInfo);
    //System.assertEquals(Label.SuccessMessage, resp.status);
    Test.stopTest();
  }
  @isTest
  static void populateValidationErrors() {
    Consumer.ValidationError conVal = new Consumer.ValidationError();
    List<Consumer.ValidationError> lstConVal = new List<Consumer.ValidationError>();
    lstConVal.add(conVal);
  }
  @isTest
  static void populateAuthenticationHeader() {
    Consumer.AuditHeader conAuthHdr = new Consumer.AuditHeader();
    List<Consumer.AuditHeader> lstAuthHdr = new List<Consumer.AuditHeader>();
    lstAuthHdr.add(conAuthHdr);
  }

  @isTest
  static void insertUpsertFail() {
    try {
      GetConsumerDetailsHelper.insertConsumer(
        new List<Account>{
          new Account(LastName = 'Test', Gender__pc = 'Incorrect')
        }
      );
    } catch (Exception ex) {
    }
    try {
      GetConsumerDetailsHelper.upsertConsumer(
        new List<Account>{
          new Account(LastName = 'Test', Gender__pc = 'Incorrect')
        }
      );
    } catch (Exception ex) {
    }
  }
}
