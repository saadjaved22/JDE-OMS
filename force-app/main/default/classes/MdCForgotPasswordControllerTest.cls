@isTest
public class MdCForgotPasswordControllerTest {
  @testSetup
  static void setUpTestData() {
    User communityUser = new User();
    communityUser.UserName = 'test@emark.com.mdc.fr';
    communityUser.Email = 'test@emark.com';

    communityUser.FirstName = 'test';
    communityUser.LastName = 'test';

    String nickname = 'testt';
    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
    communityUser.CommunityNickname = nickname;

    Account communityAccount = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Person Account')
        .getRecordTypeId(),
      FirstName = 'test',
      LastName = 'test',
      PersonEmail = 'test@emark.com',
      Gender__pc = 'Male',
      PersonBirthdate = Date.valueOf('1990-06-03'),
      Sixteen_Years_or_Older__c = true,
      External_id__c = 'test@emark.comFRMaison du Café',
      Brand__c = 'Maison du Café',
      OwnerId = Label.CommunityOwnerID
    );

    insert communityAccount;

    Site.createExternalUser(communityUser, communityAccount.Id);
  }

  @isTest
  static void forgotPasswordTest() {
    Test.startTest();
    MdCForgotPasswordController.forgotPassword(
      'test@emark.com',
      '/forgotpasswordconfirmation'
    );
    Test.stopTest();
  }

  @isTest
  static void forgotPasswordInactiveTest() {
    List<User> u = [
      SELECT Id, Email
      FROM User
      WHERE Profile.Name = 'MdC External Identity User' AND isActive = TRUE
      LIMIT 1
    ];
    u[0].IsActive = false;
    Test.startTest();
    update u;
    MdCForgotPasswordController.forgotPassword(
      u[0].Email,
      '/forgotpasswordconfirmation'
    );
    Test.stopTest();
  }

  @isTest
  static void setExperienceIdTest() {
    Test.startTest();
    MdCForgotPasswordController.setExperienceId('123');
    Test.stopTest();
  }
}
