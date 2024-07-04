public without sharing class MdCSelfRegisterController {
  private static final String BRAND_NAME = 'Maison du Café';

  public MdCSelfRegisterController() {
  }

  @TestVisible
  private static boolean siteAsContainerEnabled(String communityUrl) {
    Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(
      communityUrl,
      ''
    );
    return authConfig.isCommunityUsingSiteAsContainer();
  }

  @AuraEnabled
  public static void validatePassword(
    User user,
    String password,
    String confirmPassword
  ) {
    if (!Test.isRunningTest()) {
      if (user != null) {
        Site.validatePassword(user, password, confirmPassword);
      } else {
        Site.validatePassword(new User(), password, confirmPassword);
      }
    }
    return;
  }

  @AuraEnabled
  public static String selfRegister(
    String firstname,
    String lastname,
    String email,
    String password,
    String confirmPassword,
    String accountId,
    String regConfirmUrl,
    String startUrl,
    Boolean includePassword,
    String gender,
    String birthdate,
    String postcode,
    String houseNumber,
    String streetName,
    String city,
    String country,
    String applianceOwnership,
    Boolean sixTnYrsOld,
    Boolean commercialConsent
  ) {
    Savepoint sp = Database.setSavepoint();

    String communityId = '';
    if (Test.isRunningTest()) {
      communityId = [SELECT Id FROM Network WHERE Name = 'Maison du Café'].Id;
    } else {
      communityId = Network.getNetworkId();
    }

    if (String.isBlank(country)) {
      country = 'FR';
    }

    String usernamePostfix = '.mdc.fr';
    User communityUser = MdCCommunityHelper.createUser(
      email,
      firstName,
      lastName,
      birthdate,
      postCode,
      streetName,
      houseNumber,
      city,
      country,
      communityId,
      usernamePostfix
    );
    communityUser.ProfileId = [
      SELECT Id, Name
      FROM Profile
      WHERE Name = 'MdC External Identity User'
    ]
    .Id;
    if (
      communityId != null &&
      siteAsContainerEnabled(Network.getLoginUrl(communityId))
    ) {
      communityUser.put('UserPreferencesHideS1BrowserUI', true);
    }

    if (includePassword) {
      validatePassword(communityUser, password, confirmPassword);
    } else {
      password = null;
    }

    Account portalAccount;
    Account existingAccount = AccountSelector.getAccountByExternalId(
      email + country + BRAND_NAME
    );
    if (existingAccount != null) {
      if (existingAccount.IsCustomerPortal) {
        return 'Ce compte existe déjà !';
      } else {
        portalAccount = existingAccount;
      }
    } else if (existingAccount == null) {
      portalAccount = MdCCommunityHelper.createAccount(
        firstName,
        lastName,
        email,
        gender,
        birthdate,
        postcode,
        houseNumber,
        streetName,
        city,
        country,
        applianceOwnership,
        sixTnYrsOld,
        commercialConsent,
        communityId,
        BRAND_NAME
      );
    }

    Id userId;
    try {
      if (includePassword && String.isNotBlank(password)) {
        userId = Site.createExternalUser(
          communityUser,
          portalAccount.Id,
          password
        );
      } else {
        userId = Site.createExternalUser(communityUser, portalAccount.Id);
      }
      //MdCCommunityHelper.addRegistrationToMdcCampaign(portalAccount);
    } catch (Site.ExternalUserCreateException e) {
      System.debug(e.getMessage());
      Database.rollback(sp);
      return e.getMessage();
    }

    if (String.isNotBlank(userId)) {
      ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
      if (!Test.isRunningTest()) {
        aura.redirect(confirmRef);
      }
    }

    return null;
  }

  @AuraEnabled
  public static List<Map<String, String>> returnApplianceOwnershipValues() {
    List<Map<String, String>> applianceOwnershipValues = new List<Map<String, String>>();
    Schema.DescribeFieldResult fieldResult = Account.Brewers_Selected__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      if (pickListVal.getValue() != 'Not Yet Defined') {
        applianceOwnershipValues.add(
          new Map<String, String>{
            'label' => pickListVal.getLabel(),
            'value' => pickListVal.getValue()
          }
        );
      }
    }
    return applianceOwnershipValues;
  }

  @AuraEnabled
  public static String setExperienceId(String expId) {
    // Return null if there is no error, else it will return the error message
    try {
      if (expId != null) {
        Site.setExperienceId(expId);
      }
      return null;
    } catch (Exception ex) {
      return ex.getMessage();
    }
  }
}
