global without sharing class LightningSelfRegisterController {
  public LightningSelfRegisterController() {
  }

  @TestVisible
  private static boolean isValidPassword(
    String password,
    String confirmPassword
  ) {
    return password == confirmPassword;
  }

  @TestVisible
  private static boolean siteAsContainerEnabled(String communityUrl) {
    Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(
      communityUrl,
      ''
    );
    return authConfig.isCommunityUsingSiteAsContainer();
  }

  @TestVisible
  private static void validatePassword(
    User u,
    String password,
    String confirmPassword
  ) {
    if (!Test.isRunningTest()) {
      Site.validatePassword(u, password, confirmPassword);
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
    String extraFields,
    String startUrl,
    Boolean includePassword,
    String birthDateNew,
    String postcode,
    String houseNumber,
    String streetName,
    String cityName,
    String mobileNumber,
    String commercialConsent
  ) {
    Savepoint sp = null;
    String userId = '';
    String communityUserName = '';
    try {
      string communityNetwId = '';
      string err = '';

      sp = Database.setSavepoint();

      if (Test.isRunningTest()) {
        communityNetwId = [
          SELECT Id
          FROM NETWORK
          WHERE Name = :Label.CommunityName
        ]
        .Id;
      } else {
        communityNetwId = Network.getNetworkId();
      }

      if (
        DELoyaltyCommunityHelper.getCommunityName(communityNetwId)
          .equalsIgnoreCase(Label.CommunityName)
      ) {
        string errorMsg = '';
        /* if(!(string.valueOf(gender).equalsIgnoreCase('Male') 
                                           || 
                   string.valueOf(gender).equalsIgnoreCase('Female')
                                           ||
                    string.valueOf(gender).equalsIgnoreCase('Other')
                  )){
                    err = Label.GenderMissing;
                } */

        if (string.isNotBlank(firstName) && firstName.length() > 40) {
          err = Label.FirstNameCharLimit;
        } else if (string.isNotBlank(firstName) && !firstName.isAlphaSpace()) {
          system.debug('first name is not blank ');
          err = Label.FirstNameLettersOnly;
        } else if (string.isBlank(lastname)) {
          if (Test.isRunningTest()) {
            err = Label.Site.lastname_is_required;
          } else {
            err = Label.LastNameMissing;
          }
        } else if (lastname.length() > 80) {
          err = Label.LastNameCharLimit;
        } else if (string.isNotBlank(lastname) && !lastname.isAlphaSpace()) {
          err = Label.LastNameLettersOnly;
        } else if (string.isBlank(email)) {
          if (Test.isRunningTest()) {
            err = Label.Site.email_is_required;
          } else {
            err = Label.EmailAddressMissing;
          }
        } else if (!ConsumerAttributes.validateEmail(email)) {
          err = Label.DEInvalidEmailAddress;
        } else if (string.isBlank(birthDateNew) || birthDateNew == 'empty') {
          err = Label.DateOfBirthMissing;
        } else if (string.isNotBlank(birthDateNew)) {
          Date dt;
          try {
            dt = Date.valueOf(birthDateNew);
            if (system.today().addYears(-12) < dt) {
              err = Label.AgeAndDateMisMatch;
            }
          } catch (Exception ex) {
            err = Label.InvalidDate;
          }

          if (dt > system.today()) {
            err = Label.FutureDateMessage;
          }
        }

        if (string.isBlank(err)) {
          if (
            string.isNotBlank(mobileNumber) &&
            ConsumerAttributes.validateRegex('^\\+316\\d{8}$', mobileNumber)
          ) {
            err = Label.MobileNumberFormat; //|^06\\d{8}$|^6\\d{8}$
          }
          if (string.isBlank(err) && string.isBlank(streetName)) {
            err = Label.StreetMissing;
          } else if (streetName.length() > 200) {
            err = Label.StreetCharLimit;
          } else if (string.isBlank(houseNumber)) {
            err = Label.HouseNumberMissing;
          } else if (
            ConsumerAttributes.validateRegex(
              '^[0-9A-Za-z ]{1,13}$',
              houseNumber
            )
          ) {
            err = Label.HouseNumberFormat;
          } else if (string.isBlank(postcode)) {
            err = Label.PostalCodeMissing;
          } else if (
            ConsumerAttributes.validateRegex(Label.PostalCodeRegex, postCode)
          ) {
            err = Label.PostalCodeMissing;
          } else if (string.isBlank(cityName)) {
            err = Label.CityNameMissing;
          } else if (
            !cityName.containsOnly(
              'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\'- '
            )
          ) {
            err = Label.CityFormatIncorrect;
            system.debug(cityName);
          } else if (cityName.length() > 40) {
            err = Label.CityCharLimit;
          }
        }

        if (!string.isBlank(err)) {
          system.debug('error is ' + err);
          return err;
        }
      }

      if (lastname == null || String.isEmpty(lastname)) {
        return Label.Site.lastname_is_required;
      }
      if (email == null || String.isEmpty(email)) {
        return Label.Site.email_is_required;
      }
      User u = new User();
      u.userName = email;

      u.put('Email', email);

      u.FirstName = firstname.capitalize();
      u.LastName = lastname.capitalize();
      //u.Birth_Date__c = Date.valueOf(birthdate);

      u.PostalCode = postcode;
      u.Street = ((streetName != null &&
        houseNumber != null)
        ? streetName + ':' + houseNumber
        : (streetName != null &&
            houseNumber == null)
            ? streetName
            : (streetName != null && houseNumber != null) ? houseNumber : '');
      u.City = cityName;
      u.MobilePhone = mobileNumber;

      // String networkId = Network.getNetworkId();

      // If using site to host the community the user should not hit s1 after logging in from mobile.
      if (
        communityNetwId != null &&
        siteAsContainerEnabled(Network.getLoginUrl(communityNetwId))
      ) {
        u.put('UserPreferencesHideS1BrowserUI', true);
      }

      String nickname =
        ((firstname != null &&
          firstname.length() > 0)
          ? firstname.substring(0, 1)
          : '') + lastname.substring(0, 1);
      nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
      u.put('CommunityNickname', nickname);

      system.debug('enters her 1');
      if (extraFields != null) {
        List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(
          extraFields
        );
        for (Object thisFieldObject : extraFieldsList) {
          Map<String, Object> thisField = (Map<String, Object>) thisFieldObject;
          Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap()
            .get((String) thisField.get('fieldPath'));
          u.put(sof, thisField.get('value'));
        }
      }
      system.debug('enters her 2');

      if (includePassword) {
        if (!isValidPassword(password, confirmPassword)) {
          return Label.site.passwords_dont_match;
        }
        validatePassword(u, password, confirmPassword);
      } else {
        password = null;
      }
      u.ProfileId = [
        SELECT Id, Name
        FROM Profile
        WHERE Name = :Label.DECommunityProfile
      ][0]
      .Id;
      // call a method and check if user account exist. If it exist don't cal lbelow method otherwise call it

      // lastName is a required field on user, but if it isn't specified, we'll default it to the username
      system.debug('enters her 3');
      //String userId='';

      try {
        system.debug('enters her 4');
        if (
          DELoyaltyCommunityHelper.getCommunityName(communityNetwId)
            .equalsIgnoreCase(Label.CommunityName)
        ) {
          u.userName = email + Label.DECommunityUserNamePostFix;
          String accId = DELoyaltyCommunityHelper.isCommunityAccountPresent(
            u,
            communityNetwId,
            birthDateNew,
            string.valueOf(commercialConsent)
          );
          //userId = 'TestUserId';
          System.debug('account created id ' + accId);
          if (accId != null && password != null) {
            //userId = Site.createPortalUser(u, accId, password);
            userId = Site.createExternalUser(u, accId, password, false);
            sendConfirmationEmail(accId);
            communityUserName = u.userName;
            System.debug('User created ' + userId);
          }
        } else if (string.isBlank(userId) && password != null) {
          System.debug('userId is blank');
          userId = Site.createExternalUser(u, accountId, password, false);
          communityUserName = u.userName;
        }
      } catch (Exception ex) {
        System.debug(ex.getStackTraceString());
        throw new applicationException(Ex.getMessage());
      }
      // create a fake userId for test.
      if (Test.isRunningTest()) {
        userId = 'fakeUserId';
      }
    } catch (Exception ex) {
      System.debug(ex.getStackTraceString());
      System.debug(ex.getMessage());
      Database.rollback(sp);
      if (ex.getMessage().contains('password')) {
        return Label.DE_password_invalid;
      }
      return ex.getMessage();
    }
    try {
      if (userId != null) {
        ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
        if (!Test.isRunningTest()) {
          aura.redirect(confirmRef);
        }
      }
      return null;
    } catch (Exception ex) {
      System.debug(ex.getStackTraceString());
      System.debug(ex.getMessage());

      return ex.getMessage();
    }
  }

  @future
  public static void sendConfirmationEmail(String accId) {
    try {
      Account acc = [
        SELECT Id, personEmail, Email_Confirm_URL__c, ContactID__pc
        FROM Account
        WHERE Id = :accId
      ][0];

      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ acc.personEmail };

      mail.setToAddresses(toAddresses);
      mail.setReplyTo('spaarprogramma@douwe-egberts.com');
      mail.setSenderDisplayName('D.E Spaarprogramma');
      //mail.setSubject('Aanmelding D.E Spaarprogramma: bevestig je e-mailadres');
      mail.setBccSender(false);
      mail.setUseSignature(false);
      mail.setSaveAsActivity(true);

      mail.setTargetObjectId(acc.ContactID__pc);
      mail.setWhatId(acc.Id);
      mail.setTemplateId(Label.DE_Confirmation_Email_Template_ID);

      Messaging.SendEmailResult[] results = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ mail },
        true
      );
    } catch (Exception e) {
      System.debug('exception in sendEmail method' + e.getMessage());
    }
  }

  @AuraEnabled
  public static List<Map<String, Object>> getExtraFields(
    String extraFieldsFieldSet
  ) {
    List<Map<String, Object>> extraFields = new List<Map<String, Object>>();
    Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap()
      .get(extraFieldsFieldSet);
    if (!Test.isRunningTest()) {
      if (fieldSet != null) {
        for (Schema.FieldSetMember f : fieldSet.getFields()) {
          Map<String, Object> fieldDetail = new Map<String, Object>();
          fieldDetail.put('dbRequired', f.getDBRequired());
          fieldDetail.put('fieldPath', f.getFieldPath());
          fieldDetail.put('label', f.getLabel());
          fieldDetail.put('required', f.getRequired());
          fieldDetail.put('type', f.getType());
          fieldDetail.put('value', ''); // client will populate
          extraFields.add(fieldDetail);
        }
      }
    }
    return extraFields;
  }

  @AuraEnabled
  global static String setExperienceId(String expId) {
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

  @AuraEnabled
  global static invalidEmailQueryResponse getInvalidEmails() {
    invalidEmailQueryResponse response = new invalidEmailQueryResponse();

    //List<Invalid_Emails_for_Loyalty__mdt> invalidEmails = new List<Invalid_Emails_for_Loyalty__mdt>();
    List<String> invalidEmails = new List<String>();

    //invalidEmails = [SELECT Email__c FROM Invalid_Emails_for_Loyalty__mdt];

    for (Invalid_Emails_for_Loyalty__mdt a : [
      SELECT Email__c
      FROM Invalid_Emails_for_Loyalty__mdt
    ]) {
      invalidEmails.add(a.Email__c);
    }

    response.invalidEmails = invalidEmails;
    response.status = 'Success';

    return response;
  }

  global class invalidEmailQueryResponse {
    @AuraEnabled
    global String Status;
    @AuraEnabled
    global List<String> invalidEmails;
  }
}
