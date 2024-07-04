@isTest
public class ConsentUrlEncryptionSelectorTest {
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
  }

  @isTest
  static void getConsentUrlEncryptions() {
    Test.startTest();
    Map<String, ConsentUrlEncryption__c> encryptionRecords = ConsentUrlEncryptionSelector.getConsentUrlEncryptions();
    Test.stopTest();

    System.assert(!encryptionRecords.isEmpty());
  }
}
