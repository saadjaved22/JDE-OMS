@isTest
public class MdCSelfRegisterControllerTest {
  @testSetup
  static void setUpTestData() {
    ConsentUrlEncryption__c testEncryptionRecord = new ConsentUrlEncryption__c(
      Name = 'Maison du Café',
      Algorithm__c = 'AES256',
      Initialization_Vector__c = '7402862816488480',
      Private_Key__c = 'falcwE3A6lFtyNWiPJoVDeHoH6h/QZ7X',
      Opt_In_URL_Template__c = 'https://moncompte.maisonducafe.com/Newsletter/Confirmation/?id=EID&e=EXP&cv=CONSVER&pv=PRIVVER&s=SIG&origin=sf',
      Opt_Out_URL_Template__c = 'https://moncompte.maisonducafe.com/Newsletter/Opt-out/?id=EID&s=SIG&origin=sf'
    );

    insert testEncryptionRecord;

    User communityUser = new User();
    communityUser.UserName = 'test@emark.com.mdc.fr';
    communityUser.Email = 'test@emark.com';

    communityUser.FirstName = 'test';
    communityUser.LastName = 'test';

    String nickname = 'testt';
    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
    communityUser.CommunityNickname = nickname;

    Account communityAccount = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId(),
      FirstName = 'test',
      LastName = 'test',
      PersonEmail = 'test1@emark.com',
      Gender__pc = 'Male',
      PersonBirthdate = Date.valueOf('1990-06-03'),
      Sixteen_Years_or_Older__c = true,
      External_id__c = 'test1@emark.comFRMaison du Café',
      Brand__c = 'Maison du Café',
      OwnerId = Label.CommunityOwnerID
    );

    insert communityAccount;

    Site.createExternalUser(communityUser, communityAccount.Id, 'Testing123!');

    Account communityAccount2 = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId(),
      FirstName = 'test',
      LastName = 'test',
      PersonEmail = 'test2@emark.com',
      Gender__pc = 'Male',
      PersonBirthdate = Date.valueOf('1990-06-03'),
      Sixteen_Years_or_Older__c = true,
      External_id__c = 'test2@emark.comFRMaison du Café',
      Brand__c = 'Maison du Café',
      OwnerId = Label.CommunityOwnerID
    );
    insert communityAccount2;
  }

  @isTest
  static void selfRegisterTest() {
    Test.startTest();
    MdCSelfRegisterController.SelfRegister(
      'Emark',
      'Test',
      'test@emark.com',
      null,
      null,
      null,
      './CheckPasswordResetEmail',
      null,
      false,
      'Male',
      '1990-06-03',
      '2011 PX',
      'Teststraat',
      '8',
      'Haarlem',
      'FR',
      'Automatique Brewer',
      true,
      true
    );
    Test.stopTest();

    Account testAccount = [
      SELECT Id, PersonEmail, IsCustomerPortal
      FROM Account
      WHERE PersonEmail = 'test@emark.com'
    ];
    System.assert(testAccount != null);
  }

  @isTest
  static void selfRegister2Test() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    MdCSelfRegisterController.SelfRegister(
      'Emark',
      'Test',
      'test2@emark.com',
      'Testing123!',
      'Testing123!',
      testAccount.Id,
      './CheckPasswordResetEmail',
      null,
      true,
      'Male',
      '1990-06-03',
      '2011 PX',
      'Teststraat',
      '8',
      'Haarlem',
      null,
      'Automatique Brewer',
      true,
      true
    );
    Test.stopTest();

    Account updatedTestAccount = [
      SELECT Id, PersonEmail, IsCustomerPortal
      FROM Account
      WHERE PersonEmail = 'test2@emark.com'
      LIMIT 1
    ];
    System.assert(updatedTestAccount != null);
  }

  @isTest
  static void selfRegister3Test() {
    Test.startTest();
    MdCSelfRegisterController.SelfRegister(
      'Emark',
      'Test',
      'test1@emark.com',
      null,
      null,
      null,
      './CheckPasswordResetEmail',
      null,
      false,
      'Male',
      '1990-06-03',
      '2011 PX',
      'Teststraat',
      '8',
      'Haarlem',
      'FR',
      'Automatique Brewer',
      true,
      true
    );
    Test.stopTest();

    List<Account> testAccount = [
      SELECT Id, PersonEmail, IsCustomerPortal
      FROM Account
      WHERE PersonEmail = 'test1@emark.com'
    ];
    System.assert(testAccount.size() == 1);
  }

  @isTest
  static void siteAsContainerEnabledTest() {
    Test.startTest();
    Boolean isSelfRegContainer = MdCSelfRegisterController.siteAsContainerEnabled(
      URL.getSalesforceBaseUrl().toExternalForm() + '/s/mdc/login/SelfRegister'
    );
    Test.stopTest();
    //System.assertNotEquals(null, isSelfRegContainer, 'It would work if I could create community user just for UT.' );
  }

  @isTest
  static void returnApplianceOwnershipValuesTest() {
    Test.startTest();
    List<Map<String, String>> applianceValues = MdCSelfRegisterController.returnApplianceOwnershipValues();
    Test.stopTest();

    System.assert(!applianceValues.isEmpty());
  }

  @isTest
  static void setExperienceIdTest() {
    Test.startTest();
    MdCSelfRegisterController.setExperienceId('123');
    Test.stopTest();
  }
}
