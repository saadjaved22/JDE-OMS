public without sharing class DELoyaltyCommunityHelper {
  /*
    Developer: Accenture
    Create Date: 22nd February 2018
    Purpose: Consumer Record (Account) field values will be mapped (updated) with User Record Values
    Parameter: AccountID at User Level
    Return Type: Account Record
    */

  /*This method checks if consumer account exist or not
	•	If consumer account does not exist, it creates the loyalty consumer record.
    •	If consumer account exists but consumer is not loyalty consumer it upgrades the consumer account to loyalty consumer accounts.
    •	If consumer account exists and consumer is loyalty consumer then system throws error message to the consumer.
	*/
  public static string isCommunityAccountPresent(
    User u,
    string networkId,
    String birthDate,
    String commConsent
  ) {
    system.debug('enter here in iscommunityAccountPresent');
    string userId = '';

    Boolean commercialConsent = (string.valueOf(commConsent)
        .equalsIgnoreCase('True')
      ? true
      : false);

    if (u != null && string.isNotBlank(networkId)) {
      string communityName = getCommunityName(networkId);

      string extId = u.Email + Label.Country + Label.Brand;

      List<Account> accList = new List<Account>();

      accList = [
        SELECT
          Id,
          PersonEmail,
          Consent_Status__c,
          Account.IsCustomerPortal,
          PersonBirthdate,
          Email_Confirm_URL__c,
          (SELECT ID FROM CONTACTS),
          (SELECT ID FROM Loyalty__r)
        FROM ACCOUNT
        WHERE External_Id__c = :extId
      ];
      system.debug('enter here in accList ' + accList);
      if (accList != null && accList.size() > 0) {
        Account acc = accList[0];
        //acc.
        system.debug('enter here in acc ' + acc);
        if ((acc.Loyalty__r).size() > 0) {
          if (acc.IsCustomerPortal) {
            throw new applicationException(Label.UserExist);
          }
          /*
                    else{
                        
                        updateConsumerPersonAccount(acc.Id,Label.AccountType,loylSubsc);
                    }*/
        } else {
          if (consumerUserAccountExist(acc.Id)) {
            throw new applicationException(Label.UserExist);
          }

          List<String> lstConsentStatus = new List<String>();
          lstConsentStatus = Label.ConsentStatusValues.split(',');
          acc.PersonBirthdate = Date.valueOf(birthDate);

          Blob targetBlob = Blob.valueOf(
            String.valueOfGmt(acc.PersonBirthdate)
          );
          Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
          String hashBase64SHA1 = EncodingUtil.base64encode(hash);
          acc.Email_Confirm_URL__c =
            Label.Community_DE_BaseURL +
            '/s/regconfirmemail?s=' +
            EncodingUtil.URLENCODE(hashBase64SHA1, 'UTF-8') +
            '&u=' +
            EncodingUtil.URLENCODE(acc.personEmail, 'UTF-8');

          boolean hasExistingConsumerConsent = (string.isNotBlank(
              acc.Consent_Status__c
            ) || lstConsentStatus.contains(acc.Consent_Status__c)
            ? true
            : false);
          if (commercialConsent) {
            if (hasExistingConsumerConsent) {
              upgradeConsumerToLoyalty(acc, false, Label.SourceDE_NL, u);
            } else {
              upgradeConsumerToLoyalty(acc, true, Label.SourceDE_NL, u);
            }
          } else {
            upgradeConsumerToLoyalty(acc, false, Label.SourceDE_NL, u);
          }
        }
        return acc.Id;
      } else {
        Account a = createConsumer(
          u,
          Date.valueOf(birthDate),
          commercialConsent
        );
        //string contactId = [SELECT ID FROM CONTACT WHERE ACCOUNTID = :a.Id].Id;

        return a.Id;
      }
    }
    return null;
  }

  /*If Douwe Egberts consumer account exist but consumer is not Loyalty consumer, this method upgrades consumer record to Loyalty and
   also populates relevant GDPR and Account Registration attributes*/
  public static Account upgradeConsumerToLoyalty(
    Account accRec,
    Boolean commConsent,
    string source,
    User usr
  ) {
    Account acc = new Account();
    acc = accRec;
    acc.Type__c = Label.AccountType;
    acc.External_Id__c = acc.PersonEmail + Label.Country + Label.Brand;

    acc = ConsumerAttributes.populateAccountRegistrationAttributes(
      new List<Account>{ acc },
      'Active',
      (system.url.getSalesforceBaseUrl() != null
        ? string.valueOf(system.url.getSalesforceBaseUrl())
        : ''),
      source
    )[0];

    if (commConsent) {
      acc = ConsumerAttributes.populateGDPRAttributes(
        new List<Account>{ acc },
        source,
        (system.url.getSalesforceBaseUrl() != null
          ? string.valueOf(system.url.getSalesforceBaseUrl())
          : ''),
        true
      )[0];
    }

    acc = ConsumerAttributes.populateAccountAddressRegistrationAttributes(
      new List<Account>{ acc },
      'NL',
      usr
    )[0];

    update acc;

    return acc;
  }
  // This method returns true if consumer account has active consumer User profile otherwise false.
  public static Boolean consumerUserAccountExist(string accId) {
    List<User> lstUser = new List<User>();
    lstUSer = [SELECT Id FROM USER WHERE AccountId = :accId];

    if (lstUser != null && !lstUser.isEmpty()) {
      return true;
    }
    return false;
  }
  /*This method takes User record as input parameter and populate personal, GDPR and Accounty Registration attributes at
   account level*/
  public static Account createConsumer(
    User usr,
    Date birthDate,
    Boolean commercialCons
  ) {
    Account acc = new Account();

    acc = ConsumerAttributes.populateGeneralAttributes(usr, birthDate);

    if (commercialCons) {
      acc = ConsumerAttributes.populateGDPRAttributes(
        new List<Account>{ acc },
        Label.SourceDE_NL,
        string.valueOf(system.url.getSalesforceBaseUrl()),
        true
      )[0];
    }
    acc = ConsumerAttributes.populateAccountRegistrationAttributes(
      new List<Account>{ acc },
      'Active',
      string.valueOf(system.url.getSalesforceBaseUrl()),
      Label.SourceDE_NL
    )[0];

    Blob targetBlob = Blob.valueOf(String.valueOfGmt(birthDate));
    Blob hash = Crypto.generateDigest('SHA-256', targetBlob);
    String hashBase64SHA1 = EncodingUtil.base64encode(hash);
    acc.Email_Confirm_URL__c =
      Label.Community_DE_BaseURL +
      '/s/regconfirmemail?s=' +
      EncodingUtil.URLENCODE(hashBase64SHA1, 'UTF-8') +
      '&u=' +
      EncodingUtil.URLENCODE(acc.personEmail, 'UTF-8');

    try {
      insert acc;
    } catch (Exception ex) {
      System.debug(
        'Error in createConsumer function' + ex.getStackTraceString()
      );
    }

    return acc;
  }
  /*This method marks users as active and returns list of those users.*/
  public static List<User> getInactiveUsers(set<String> setUserName) {
    List<User> lstUser = new List<User>();
    for (User usr : [
      SELECT ID, ISACTIVE
      FROM USER
      WHERE USERNAME IN :setUserName AND ISACTIVE = FALSE
    ]) {
      usr.isActive = true;
      lstUser.add(usr);
    }
    system.debug('check if it returns' + lstUser);
    return lstUser;
  }

  /*This method returns updated list of users received as parameter*/
  public static List<User> updateUsers(List<User> lstUser) {
    system.debug(lstUser);
    if (lstUser != null && !lstUser.isEmpty()) {
      system.debug('###test' + lstUser);
      update lstUser;
      system.debug('test' + lstUser);
    }
    return lstUser;
  }
  /*This method return community name for the community network Id passed as parameter*/
  public static string getCommunityName(Id networkId) {
    return [SELECT NAME FROM NETWORK WHERE ID = :networkId].Name;
  }

  /*This method return map of Account Id and its corresponding contact Id*/
  public static Map<Id, Id> mapAccountContactId(List<Account> lstAccount) {
    set<ID> setAccountId = new Set<ID>();
    Map<Id, Id> mapAccContactIds = new Map<Id, Id>();
    for (Account acc : lstAccount) {
      setAccountId.add(acc.Id);
    }

    for (Contact con : [
      SELECT Id, AccountId
      FROM Contact
      WHERE AccountId IN :setAccountId
    ]) {
      mapAccContactIds.put(con.AccountId, con.Id);
    }

    return mapAccContactIds;
  }

  /*This method returns map of profile name and its corresponding profile details*/
  public static Map<String, Profile> mapProfileDetail(
    set<String> setStringProfileName
  ) {
    Map<String, Profile> mapProfileDetails = new Map<String, Profile>();
    for (Profile prf : [
      SELECT Id, Name
      FROM Profile
      WHERE Name IN :setStringProfileName
    ]) {
      mapProfileDetails.put(prf.Name, Prf);
    }

    return mapProfileDetails;
  }
}
