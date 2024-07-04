public class MdCForgotPasswordController {
  public static final String USERNAME_POSTFIX = '.mdc.fr';

  @AuraEnabled
  public static String forgotPassword(String username, String checkEmailUrl) {
    try {
      String communityId;
      if (Test.isRunningTest()) {
        communityId = [SELECT Id FROM Network WHERE Name = 'Maison du Café'].Id;
      } else {
        communityId = Network.getNetworkId();
      }

      username = username + USERNAME_POSTFIX;

      if (
        DELoyaltyCommunityHelper.getInactiveUsers(new Set<String>{ userName })
          .isEmpty()
      ) {
        Site.forgotPassword(username);
      } else {
        DELoyaltyCommunityHelper.updateUsers(
          DELoyaltyCommunityHelper.getInactiveUsers(new Set<String>{ userName })
        );
      }

      //Site.forgotPassword(username);
      ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);

      if (!Test.isRunningTest()) {
        aura.redirect(checkEmailRef);
      }

      return null;
    } catch (Exception ex) {
      return ex.getMessage();
    }
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
