global without sharing class LightningConfirmEmailController {
  @AuraEnabled
  public static string confirmEmail(
    String hach64,
    String email,
    String loginUrl
  ) {
    try {
      String accountExternalId = email + Label.Country + Label.Brand;
      List<Account> accList;

      accList = [
        SELECT
          Id,
          FirstName,
          LastName,
          personEmail,
          Email_Confirmed__c,
          PersonBirthdate
        FROM Account
        WHERE External_Id__c = :accountExternalId
        LIMIT 1
      ];
      Blob targetBlob = accList.size() > 0
        ? Blob.valueOf(String.valueOfGmt(accList[0].PersonBirthdate))
        : Blob.valueOf('0000');
      Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
      String hashBase64SHA1 = EncodingUtil.base64encode(hash);
      Boolean isValidLink = hashBase64SHA1 == hach64 ? true : false;

      System.debug('accountList : ' + accList);
      if (accList.size() > 0 && isValidLink) {
        Account acc = accList[0];

        if (!acc.Email_Confirmed__c) {
          acc.Email_Confirmed__c = true;
          update acc;
          System.debug('account updated');
        } else if (acc.Email_Confirmed__c) {
          return 'Already confirmed';
        }
      } else {
        System.debug('Customer  not found');
        return 'Customer  not found';
      }

      return 'Confirmed';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
