public without sharing class MdCCommunityHelper {
  public static User createUser(
    String email,
    String firstName,
    String lastName,
    String birthdate,
    String postCode,
    String streetName,
    String houseNumber,
    String city,
    String country,
    String networkId,
    String usernamePostfix
  ) {
    User communityUser = new User();
    communityUser.UserName = email + usernamePostfix;
    communityUser.Email = email;

    communityUser.FirstName = firstname;
    communityUser.LastName = lastname;

    communityUser.PostalCode = postcode;
    communityUser.Street = ((streetName != null &&
      houseNumber != null)
      ? streetName + ':' + houseNumber
      : (streetName != null &&
          houseNumber == null)
          ? streetName
          : (streetName != null && houseNumber != null) ? houseNumber : '');
    communityUser.City = city;
    communityUser.Country = country;

    String nickname =
      ((firstname != null &&
        firstname.length() > 0)
        ? firstname.substring(0, 1)
        : '') + lastname.substring(0, 1);
    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
    communityUser.CommunityNickname = nickname;

    return communityUser;
  }

  public static Account createAccount(
    String firstName,
    String lastName,
    String email,
    String gender,
    String birthdate,
    String postcode,
    String houseNumber,
    String streetName,
    String city,
    String country,
    String applianceOwnership,
    Boolean sixTnYrsOld,
    Boolean commercialConsent,
    String networkId,
    String brandName
  ) {
    Account communityAccount = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId(),
      FirstName = firstName,
      LastName = lastName,
      PersonEmail = email,
      Gender__pc = gender,
      //PersonBirthdate = Date.valueOf(birthdate),
      BillingPostalCode = postcode,
      BillingStreet = ((streetName != null &&
        houseNumber != null)
        ? streetName + ':' + houseNumber
        : (streetName != null &&
            houseNumber == null)
            ? streetName
            : (streetName != null && houseNumber != null) ? houseNumber : ''),
      BillingCity = String.isNotBlank(city) ? city : null,
      BillingCountry = country,
      Country__c = country,
      Brewers_Selected__c = applianceOwnership,
      Sixteen_Years_or_Older__c = sixTnYrsOld,
      External_id__c = email + 'FR' + brandName,
      Brand__c = brandName,
      OwnerId = Label.CommunityOwnerID,
      Language__c = 'French',
      Type__c = 'Loyalty',
      Account_Consent_Registration_Source_URL__c = Network.getSelfRegUrl(
        networkId
      ),
      Account_Registration_Status__c = 'Active',
      Account_Registration_Date__c = System.today(),
      Account_Registration_Email__c = email,
      Account_Registration_Source__c = 'MDC.FR'
    );
    if (String.isNotBlank(birthdate)) {
      communityAccount.PersonBirthdate = Date.valueOf(birthdate);
    }
    if (commercialConsent) {
      List<Community_Consent_Label__mdt> consentLabels = CommunityConsentLabelsSelector.getCommunityConsentLabelsForCommunity(
        'Maison du Cafe',
        'FR'
      );
      communityAccount.Consent_Text__c =
        consentLabels[0].Consent_Text_1__c +
        '\n' +
        consentLabels[0].Consent_Text_2__c +
        ' ' +
        consentLabels[0].Privacy_Policy_Label__c +
        ' ' +
        consentLabels[0].Privacy_Policy_URL__c +
        ' ' +
        consentLabels[0].Consent_Text_3__c;
      communityAccount.Consent_Text_Version__c = String.valueOf(
        consentLabels[0].Consent_Text_Version__c
      );
      communityAccount.Privacy_Policy_Version__c = String.valueOf(
        consentLabels[0].Privacy_Policy_Version__c
      );
      communityAccount.Privacy_Policy_Summary__c = String.valueOf(
        consentLabels[0].Privacy_Policy_Version__c
      );
      communityAccount.Consent_Registration_Source_URL__c = Network.getSelfRegUrl(
        networkId
      );
      communityAccount.Opt_in_Source__c = 'MDC.FR';
      communityAccount.Consent_Status__c = 'Registered';
      communityAccount.Consent_Registration_Date__c = System.today();
      communityAccount.Account_Consent_Registration_Date__c = System.now();
      communityAccount = ConsumerAttributes.generateOPTURLS2(
        new List<Account>{ communityAccount }
      )[0];
    }

    insert communityAccount;
    return communityAccount;
  }

  /*public static void addRegistrationToMdcCampaign(Account customer) {
        Campaign mdcCampaign = findOrCreateMdcCampaign();
        Account accountWithContactId = AccountSelector.getAccountExternalId(customer.Id);
        CampaignMember registrationMember = new CampaignMember(
            ContactId = accountWithContactId.PersonContactId,
            Customer_External_Id__c = accountWithContactId.External_Id__c,
            CampaignId = mdcCampaign.Id,
            Status = 'Registered'
        );
        if(registrationMember != null){
            insert registrationMember;
        }   
    }
    
    public static Campaign findOrCreateMdcCampaign() {
        Campaign mdcCampaign = CampaignSelector.getCampaignByExternalId('Maison du Café-FR-MdCRegistration');
        if(mdcCampaign == null){
            mdcCampaign = new Campaign(
                Name = 'MdCRegistration',
                Campaign_Type__c = 'Registration',
                Brand__c = 'Maison du Café',
                Country__c = 'FR'
            );
            if(mdcCampaign != null){
                insert mdcCampaign;
            }
        }
        return mdcCampaign;
    }*/
}
