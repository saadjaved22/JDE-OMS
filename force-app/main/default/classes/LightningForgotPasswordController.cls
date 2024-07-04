global without sharing class LightningForgotPasswordController {
  public LightningForgotPasswordController() {
  }

  @AuraEnabled
  public static String forgotPassword(String username, String checkEmailUrl) {
    try {
      string networkId;
      if (Test.isRunningTest()) {
        networkId = [SELECT ID FROM NETWORK WHERE NAME = 'DE'].ID;
      } else {
        networkId = Network.getNetworkId();
      }
      if (
        DELoyaltyCommunityHelper.getCommunityName(networkId)
          .equalsIgnoreCase(Label.CommunityName) ||
        DELoyaltyCommunityHelper.getCommunityName(networkId) == 'DE Loyalty'
      ) {
        if (string.isBlank(username)) {
          return Label.DEEmailAddressBlank;
        }

        if (!ConsumerAttributes.validateEmail(username)) {
          return Label.DEInvalidEmailAddress;
        }

        userName = username + Label.DECommunityUserNamePostFix;
        system.debug(
          'inactive user' +
          DELoyaltyCommunityHelper.getInactiveUsers(new Set<String>{ userName })
        );
        if (
          DELoyaltyCommunityHelper.getInactiveUsers(new Set<String>{ userName })
            .isEmpty()
        ) {
          Site.forgotPassword(username);
        } else {
          List<User> userList = DELoyaltyCommunityHelper.updateUsers(
            DELoyaltyCommunityHelper.getInactiveUsers(
              new Set<String>{ userName }
            )
          );
          System.debug(userList);
          for (User u : userList) {
            System.resetPassword(u.Id, true);
          }
        }
      }
      //if active
      //Site.forgotPassword(username);
      ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);

      aura.redirect(checkEmailRef);
      return null;
    } catch (Exception ex) {
      return ex.getMessage();
    }
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
