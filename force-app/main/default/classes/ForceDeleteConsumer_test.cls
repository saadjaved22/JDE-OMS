@isTest
public class ForceDeleteConsumer_test {
  @testSetup
  static void testSetup() {
    forceDeleteConsumerSetting__c testSettings = new forceDeleteConsumerSetting__c();
    testSettings.Access_to_force_deletion_process__c = true;
    testSettings.Confirmation_text__c = 'you sure?';
    testSettings.Insufficient_access_error__c = 'error';
    testSettings.Successfully_deleted_text__c = 'success';
    insert testSettings;
  }
  @isTest
  static void accountWithUser() {
    String RecTypeId = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'Person Account' AND SobjectType = 'Account'
    ]
    .Id;
    Id sysAd = [
      SELECT id, Name
      FROM Profile
      WHERE name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    ID globalSupportRole = [
      SELECT Id, Name
      FROM UserRole
      WHERE name = 'Global Support'
    ]
    .Id;

    User testUser = new User();
    testUser.username = 'testUserLastName@testUserLastName.com';
    testUser.email = 'testUserLastName@ff.com';
    testUser.emailencodingkey = 'UTF-8';
    testUser.localesidkey = 'en_US';
    testUser.UserRoleId = globalSupportRole;
    testUser.languagelocalekey = 'en_US';
    testUser.timezonesidkey = 'America/Los_Angeles';
    testUser.alias = 'tuAdmin';
    testUser.lastname = 'testUserLastName';
    testUser.ProfileId = sysAd;
    insert testUser;

    System.runAs(testUser) {
      Account acc = new Account(lastName = 'newAcc1', RecordTypeID = RecTypeId);
      insert acc;
      Account testacc = [
        SELECT contactID__pc
        FROM Account
        WHERE id = :acc.Id
        LIMIT 1
      ];
      Profile p = [
        SELECT Id, name
        FROM Profile
        WHERE UserType = 'CspLitePortal'
        LIMIT 1
      ];
      User newUser = new User(
        profileId = p.id,
        username = 'newUser@yahoo.com',
        email = 'pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias = 'nuser',
        lastname = 'lastname',
        contactId = testacc.contactID__pc
      );
      insert newUser;
      Test.startTest();
      ForceDeleteConsumer.forceDeleteAction(acc.Id);
      Test.stopTest();
    }
  }
  @isTest
  static void accountWithoutUser() {
    String RecTypeId = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'Person Account' AND SobjectType = 'Account'
    ]
    .Id;
    Id sysAd = [
      SELECT id, Name
      FROM Profile
      WHERE name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    ID globalSupportRole = [
      SELECT Id, Name
      FROM UserRole
      WHERE name = 'Global Support'
    ]
    .Id;

    User testUser = new User();
    testUser.username = 'testUserLastName@testUserLastName.com';
    testUser.email = 'testUserLastName@ff.com';
    testUser.emailencodingkey = 'UTF-8';
    testUser.localesidkey = 'en_US';
    testUser.UserRoleId = globalSupportRole;
    testUser.languagelocalekey = 'en_US';
    testUser.timezonesidkey = 'America/Los_Angeles';
    testUser.alias = 'tuAdmin';
    testUser.lastname = 'testUserLastName';
    testUser.ProfileId = sysAd;
    insert testUser;

    System.runAs(testUser) {
      Account acc = new Account(lastName = 'newAcc1', RecordTypeID = RecTypeId);
      insert acc;

      Test.startTest();
      ForceDeleteConsumer.forceDeleteAction(acc.Id);
      Test.stopTest();
    }
  }
  @isTest
  static void testAccountDeletionMethod() {
    String RecTypeId = [
      SELECT Id
      FROM RecordType
      WHERE Name = 'Person Account' AND SobjectType = 'Account'
    ]
    .Id;
    Id sysAd = [
      SELECT id, Name
      FROM Profile
      WHERE name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    ID globalSupportRole = [
      SELECT Id, Name
      FROM UserRole
      WHERE name = 'Global Support'
    ]
    .Id;

    User testUser = new User();
    testUser.username = 'testUserLastName@testUserLastName.com';
    testUser.email = 'testUserLastName@ff.com';
    testUser.emailencodingkey = 'UTF-8';
    testUser.localesidkey = 'en_US';
    testUser.UserRoleId = globalSupportRole;
    testUser.languagelocalekey = 'en_US';
    testUser.timezonesidkey = 'America/Los_Angeles';
    testUser.alias = 'tuAdmin';
    testUser.lastname = 'testUserLastName';
    testUser.ProfileId = sysAd;
    insert testUser;

    System.runAs(testUser) {
      Account acc = new Account(lastName = 'newAcc1', RecordTypeID = RecTypeId);
      insert acc;

      Test.startTest();
      List<Account> listOfAccount = new List<Account>();
      listOfAccount.add(acc);
      ForceDeleteConsumer.deleteAccountPB(listOfAccount);
      Test.stopTest();
    }
  }
}
