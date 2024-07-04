/**
 * An apex page controller that exposes the change password functionality
 */
@IsTest
public with sharing class ChangePasswordControllerTest {
  @IsTest(SeeAllData=true)
  public static void testChangePasswordController() {
    // Instantiate a new controller with all parameters in the page
    PageReference pageRef = Page.DECommunityChangePassword;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('setupid', 'ChangePassword');
    ChangePasswordController controller = new ChangePasswordController();

    controller.oldPassword = '123456';
    controller.newPassword = 'qwerty1';
    controller.verifyNewPassword = 'qwerty1';
    controller.isValidPassword = true;

    System.assertEquals(controller.changePassword(), null);
  }

  @IsTest(SeeAllData=true)
  public static void testChangePasswordDEForgotRequestController() {
    // Instantiate a new controller with all parameters in the page
    PageReference pageRef = Page.DECommunityChangePassword;
    Test.setCurrentPage(pageRef);
    ChangePasswordController controller = new ChangePasswordController();

    controller.oldPassword = '';
    controller.newPassword = 'qwerty1';
    controller.verifyNewPassword = 'qwerty1';
    controller.isValidPassword = true;

    System.assertEquals(controller.changePassword(), null);
  }

  @IsTest(SeeAllData=true)
  public static void testChangePasswordPasswordsAreBlank() {
    // Instantiate a new controller with all parameters in the page
    PageReference pageRef = Page.DECommunityChangePassword;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('setupid', 'ChangePassword');
    ChangePasswordController controller = new ChangePasswordController();

    controller.oldPassword = '';
    controller.newPassword = '';
    controller.verifyNewPassword = '';

    System.assertEquals(controller.changePassword(), null);

    controller.oldPassword = 'Test1234';
    controller.newPassword = '';
    controller.verifyNewPassword = '';

    System.assertEquals(controller.changePassword(), null);

    controller.oldPassword = 'Test1234';
    controller.newPassword = '1234';
    controller.verifyNewPassword = '';

    System.assertEquals(controller.changePassword(), null);

    controller.oldPassword = 'Test1234';
    controller.newPassword = '1234';
    controller.verifyNewPassword = '1234';

    System.assertEquals(controller.changePassword(), null);

    controller.oldPassword = 'Test1234';
    controller.newPassword = 'Teset12345';
    controller.verifyNewPassword = 'Test12345';

    System.assertEquals(controller.changePassword(), null);

    controller.oldPassword = 'Test1234';
    controller.newPassword = 'Teset12345#';
    controller.verifyNewPassword = 'Test12345';

    System.assertEquals(controller.changePassword(), null);

    controller.oldPassword = 'Test1234';
    controller.newPassword = '12345678';
    controller.verifyNewPassword = '12345678';

    System.assertEquals(controller.changePassword(), null);

    controller.oldPassword = 'Test1234';
    controller.newPassword = 'ABCDEFGHIJ';
    controller.verifyNewPassword = 'ABCDEFGHIJ';

    System.assertEquals(controller.changePassword(), null);
  }

  @IsTest(SeeAllData=true)
  public static void testChangePasswordDENonDERequestController() {
    // Instantiate a new controller with all parameters in the page
    PageReference pageRef = Page.ChangePassword;
    Test.setCurrentPage(pageRef);
    ChangePasswordController controller = new ChangePasswordController();

    controller.oldPassword = '';
    controller.newPassword = 'qwerty1';
    controller.verifyNewPassword = 'qwerty1';

    System.assertEquals(controller.changePassword(), null);
  }
}
