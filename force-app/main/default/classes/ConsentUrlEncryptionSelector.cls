public class ConsentUrlEncryptionSelector {
  public static Map<String, ConsentUrlEncryption__c> getConsentUrlEncryptions() {
    List<ConsentUrlEncryption__c> encryptionRecords = [
      SELECT
        Id,
        Name,
        Algorithm__c,
        Initialization_Vector__c,
        Opt_In_URL_Template__c,
        Opt_Out_URL_Template__c,
        Private_Key__c
      FROM ConsentUrlEncryption__c
    ];

    Map<String, ConsentUrlEncryption__c> consentUrlEncryptionByBrand = new Map<String, ConsentUrlEncryption__c>();
    for (ConsentUrlEncryption__c encryptionRecord : encryptionRecords) {
      consentUrlEncryptionByBrand.put(encryptionRecord.Name, encryptionRecord);
    }

    return consentUrlEncryptionByBrand;
  }
}
