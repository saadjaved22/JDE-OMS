@isTest
public class MdCCommunityHelperTest {
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

    Account testAccount = new Account(
      FirstName = 'Testy',
      LastName = 'McTestFace',
      PersonEmail = 'testy@emark.com',
      Brand__c = 'Maison du Café',
      PersonBirthdate = Date.valueOf('1990-06-03')
    );

    insert testAccount;
  }

  @isTest
  static void createUserTest() {
    Test.startTest();
    Id communityId = [SELECT Id FROM Network WHERE Name = 'Maison du Café'].Id;
    User user = MdCCommunityHelper.createUser(
      'test@emark.com',
      'Emark',
      'Test',
      '1990-06-03',
      '2011 PX',
      'Teststraat',
      '8',
      'Haarlem',
      'FR',
      communityId,
      '.mdc.fr'
    );
    Test.stopTest();

    System.assert(user != null);
  }

  @isTest
  static void createAccountTest() {
    Test.startTest();
    Id communityId = [SELECT Id FROM Network WHERE Name = 'Maison du Café'].Id;
    Account account = MdCCommunityHelper.createAccount(
      'Emark',
      'Test',
      'test@emark.com',
      'Male',
      '1990-06-03',
      '2011 PX',
      '8',
      'Teststraat',
      'Haarlem',
      'FR',
      'Automatique Brewer',
      true,
      true,
      communityId,
      'Maison du Café'
    );
    Test.stopTest();

    System.assert(account != null);
    System.assert(String.isNotBlank(account.Id));
  }

  /*@isTest static void addRegistrationToMdcCampaignTest() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		Test.startTest();
		//MdCCommunityHelper.addRegistrationToMdcCampaign(testAccount);
		Test.stopTest();
		
		Campaign campaignWithMembers = [SELECT Id, (SELECT Id FROM CampaignMembers) FROM Campaign WHERE External_Id__c = 'Maison du Café-FR-MdCRegistration'];
		System.assert(campaignWithMembers != null);
		System.assert(!campaignWithMembers.CampaignMembers.isEmpty());
	}*/
}
