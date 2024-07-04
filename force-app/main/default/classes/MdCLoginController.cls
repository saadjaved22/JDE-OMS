global class MdCLoginController {
  private static final String USERNAME_POSTFIX = '.mdc.fr';

  @AuraEnabled
  public static List<String> login(
    String username,
    String password,
    String startUrl,
    String nonLocalStartUrl
  ) {
    List<String> errorMessages = new List<String>();
    try {
      //string errorMessage = '';
      if (String.isBlank(username)) {
        //errorMessage =  Label.UserNameMissing;
        errorMessages.add('Entrez votre adresse email');
      }

      if (String.isBlank(password)) {
        //errorMessage  = errorMessage  + '\n ' + Label.PasswordMissing;
        errorMessages.add('Entrez votre mot de passe');
      }

      if (!errorMessages.isEmpty()) {
        return errorMessages;
      }

      username = username + USERNAME_POSTFIX;
      ApexPages.PageReference lgn = Site.login(username, password, startUrl);

      if (String.isNotBlank(nonLocalStartUrl)) {
        String returnUrl = lgn.getParameters().get('retURL');
        lgn.getParameters()
          .put(
            'retURL',
            returnUrl +
              '?redirect=' +
              EncodingUtil.urlEncode(nonLocalStartUrl, 'UTF-8')
          );
      }

      if (!Test.isRunningTest()) {
        aura.redirect(lgn);
      }
      return null;
    } catch (Exception ex) {
      errorMessages.add(
        'Votre identifiant et/ou mot de passe est incorrect. Veuillez réessayer.'
      );
      errorMessages.add(
        'Note : Après 5 tentatives infructueuses, votre compte sera bloqué. Merci de réessayer dans 15 minutes.'
      );
    }

    return errorMessages;
  }

  @AuraEnabled
  public static Boolean getIsUsernamePasswordEnabled() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
    return authConfig.getUsernamePasswordEnabled();
  }

  @AuraEnabled
  public static Boolean getIsSelfRegistrationEnabled() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
    return authConfig.getSelfRegistrationEnabled();
  }

  @AuraEnabled
  public static String getSelfRegistrationUrl() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
    if (authConfig.getSelfRegistrationEnabled()) {
      return authConfig.getSelfRegistrationUrl();
    }
    return null;
  }

  @AuraEnabled
  public static String getForgotPasswordUrl() {
    Auth.AuthConfiguration authConfig = getAuthConfig();
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
}
