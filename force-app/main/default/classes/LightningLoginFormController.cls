/**
 * LightningLoginFormController
 *
 * APEX Controller for the Custom Login aura component `loginForm.cmp`.
 *
 * Changes: <2021-04: Version without recaptcha
 * Changes: 2021-05: Version with recaptcha deployed - herman.dempere@emark.com
 *
 *
 */
global without sharing class LightningLoginFormController {
  public LightningLoginFormController() {
  }

  @AuraEnabled
  public static String login(
    String username,
    String password,
    String startUrl,
    String recatpchaSecret,
    String recaptchaToken
  ) {
    // Check username / password
    try {
      string errorMessage = '';
      if (string.isBlank(username)) {
        errorMessage = Label.UserNameMissing;
      }

      if (string.isBlank(password)) {
        errorMessage = errorMessage + '\n ' + Label.PasswordMissing;
      }

      // DateTime expirationDate = UserPasswordChangeDate.checkLastPasswordChangeDate(username);
      // if(expirationDate != null){
      //     if(expirationDate < DateTime.now()){
      //         errorMessage = Label.AccountPasswordExpired;
      //     }
      // }

      if (string.isNotBlank(errorMessage))
        return errorMessage;
    } catch (Exception e) {
      if (Test.isRunningTest()) {
        return e.getMessage();
      }
      return Label.UserLoginFailMessage;
    }

    // Check recaptcha token
    if (String.isNotBlank(recatpchaSecret)) {
      Boolean recaptchaStatus = false;
      try {
        recaptchaStatus = verifyGoogleRecaptchaToken(
          recatpchaSecret,
          recaptchaToken
        );
      } catch (Exception e) {
        /* return e.getMessage(); */
      }

      if (!recaptchaStatus)
        return Label.InvalidReCaptcha;
    }

    List<Account> accList;
    String accountExternalId;
    try {
      accountExternalId = username + Label.Country + Label.Brand;
      username = username + Label.DECommunityUserNamePostFix;
      accList = [
        SELECT
          Id,
          personEmail,
          Email_Confirmed__c,
          NumberOfFailedLogins__c,
          LoginLockDatetime__c
        FROM Account
        WHERE External_Id__c = :accountExternalId
        LIMIT 1
      ];
      List<User> userList = [
        SELECT Id, LastLoginDate, IsActive
        FROM User
        WHERE userName = :username
        LIMIT 1
      ];

      if (accList.size() > 0) {
        Datetime userLastLoginDate;
        if (Test.isRunningTest()) {
          userLastLoginDate = Datetime.now();
        } else {
          userLastLoginDate = userList[0].LastLoginDate;
        }
        if (!accList[0].Email_Confirmed__c) {
          return Label.UserEmailNotConfirmed;
        } else if (accList[0].LoginLockDatetime__c != null) {
          if (
            (accList[0].LoginLockDatetime__c > userLastLoginDate) ||
            (userLastLoginDate == null)
          ) {
            return Label.UserLoginLocked;
          } else if (accList[0].LoginLockDatetime__c < userLastLoginDate) {
            try {
              accList[0].NumberOfFailedLogins__c = 0;
              accList[0].LoginLockDatetime__c = null;
              update accList;
            } catch (Exception e) {
              System.debug(
                'Exception when trying to reset the NumberOfFailedLogins ' +
                e.getMessage()
              );
            }
          }
        } else if (!userList[0].IsActive) {
          return Label.userIsInactive;
        }
      }

      ApexPages.PageReference lgn = Site.login(username, password, startUrl);
      aura.redirect(lgn);
      try {
        if (accList.size() > 0 && accList[0].NumberOfFailedLogins__c != 0) {
          accList[0].NumberOfFailedLogins__c = 0;
          accList[0].LoginLockDatetime__c = null;
          update accList;
          System.debug('updated \n' + accList[0]);
        }
      } catch (Exception e) {
        System.debug(
          'Exception when trying to reset the NumberOfFailedLogins ' +
          e.getMessage()
        );
      }
    } catch (Exception e) {
      //return 'exception \n'+ e.getMessage();
      try {
        if (accList.size() > 0) {
          accList[0].NumberOfFailedLogins__c = accList[0]
              .NumberOfFailedLogins__c == null
            ? 1
            : accList[0].NumberOfFailedLogins__c + 1;
          accList[0].LoginLockDatetime__c = accList[0]
              .NumberOfFailedLogins__c >= 4
            ? Datetime.now()
            : null;
          update accList;
          //System.debug('updated \n' +accList[0]);
        }
      } catch (Exception ex) {
        System.debug(
          'exception when trying to update the NumberOfFailedLogins__c'
        );
        System.debug(ex.getMessage());
      }
      if (Test.isRunningTest()) {
        return e.getMessage();
      }
      return Label.UserLoginFailMessage;
    }

    return null;
  }

  @AuraEnabled
  public static Boolean getIsUsernamePasswordEnabled() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
    return authConfig.getUsernamePasswordEnabled();
  }

  @AuraEnabled
  public static Boolean getIsSelfRegistrationEnabled() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
    if (Test.isRunningTest()) {
      return true;
    }
    return authConfig.getSelfRegistrationEnabled();
  }

  @AuraEnabled
  public static String getSelfRegistrationUrl() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
    if (authConfig.getSelfRegistrationEnabled()) {
      // if(Test.isRunningTest()){ return null; }
      return authConfig.getSelfRegistrationUrl();
    }
    if (Test.isRunningTest()) {
      return 'https://example.org';
    }
    return null;
  }

  @AuraEnabled
  public static String getForgotPasswordUrl() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
    if (Test.isRunningTest()) {
      return 'https://example.org';
    }
    return authConfig.getForgotPasswordUrl();
  }

  @TestVisible
  private static Auth.AuthConfiguration getAuthConfig() {
    Id networkId = Network.getNetworkId();
    Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(
      networkId,
      ''
    );
    return authConfig;
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

  private class RecaptchaRequest {
    String secret;
    String response;

    public Blob toFormData() {
      String formData64 =
        HTTPPostFormBuilder.WriteBoundary() +
        HTTPPostFormBuilder.WriteBodyParameter('secret', this.secret) +
        HTTPPostFormBuilder.WriteBoundary() +
        HTTPPostFormBuilder.WriteBodyParameter('response', this.response) +
        HTTPPostFormBuilder.WriteBoundary();

      return EncodingUtil.base64Decode(formData64);
    }
  }

  private class RecaptchaResponse {
    Boolean success;
    String challenge_ts;
    String hostname;
    List<String> errorCodes;
  }

  public static boolean verifyGoogleRecaptchaToken(
    String secret,
    String token
  ) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();

    RecaptchaRequest requestData = new RecaptchaRequest();
    requestData.secret = secret;
    requestData.response = token;

    request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
    request.setMethod('POST');
    request.setTimeout(120000);
    request.setHeader('Accept', 'application/json');
    request.setHeader('Content-Type', HTTPPostFormBuilder.GetContentType());
    request.setBodyAsBlob(requestData.toFormData());

    System.debug(request.getBody());

    HttpResponse response = http.send(request);
    String responseBody = response.getBody()
      .replaceAll('error-codes', 'errorCodes');
    RecaptchaResponse responseData = (RecaptchaResponse) JSON.deserialize(
      responseBody,
      RecaptchaResponse.class
    );

    System.debug(responseData);

    return responseData.success;
  }
}
