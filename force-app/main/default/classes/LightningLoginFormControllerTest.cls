@IsTest
global with sharing class LightningLoginFormControllerTest {
  global class GoogleCaptchaMock implements HttpCalloutMock {
    global HttpResponse Respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(200);
      response.setBody('{"success":true}');
      return response;
    }
  }

  @IsTest
  static void testLoginWithInvalidCredentials() {
    Test.startTest();
    Object response = LightningLoginFormController.login(
      'testUser',
      'fakepwd',
      null,
      null,
      null
    );
    // System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null, null, null));
    Test.stopTest();
  }

  @IsTest
  static void testLoginWithInvalidCredentialsRecaptcha() {
    Test.setMock(HttpCalloutMock.class, new GoogleCaptchaMock());

    Test.startTest();
    String response = LightningLoginFormController.login(
      'testUser',
      'fakepwd',
      null,
      'TOKEN',
      'SECRET'
    );
    // System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null, null, null));
    Test.stopTest();
  }

  @IsTest
  static void testLoginWithMissingUsername() {
    Test.startTest();
    String response = LightningLoginFormController.login(
      null,
      'fakepwd',
      null,
      null,
      null
    );
    // System.assertEquals(Label.UserNameMissing, LightningLoginFormController.login(null, 'fakepwd', null, null, null));
    Test.stopTest();
  }

  @IsTest
  static void testLoginWithMissingPassword() {
    Test.startTest();
    String response = LightningLoginFormController.login(
      'testUser',
      null,
      null,
      null,
      null
    );
    // System.assert(response.contains(Label.PasswordMissing));
    Test.stopTest();
  }

  @IsTest
  static void LightningLoginFormControllerInstantiation() {
    Test.startTest();
    LightningLoginFormController controller = new LightningLoginFormController();
    Test.stopTest();
    System.assertNotEquals(controller, null);
  }
  @IsTest
  static void testIsUsernamePasswordEnabled() {
    Test.startTest();
    System.assertEquals(
      true,
      LightningLoginFormController.getIsUsernamePasswordEnabled()
    );
    Test.stopTest();
  }

  @IsTest
  static void testIsSelfRegistrationEnabled() {
    Test.startTest();
    System.assertEquals(
      true,
      LightningLoginFormController.getIsSelfRegistrationEnabled()
    );
    Test.stopTest();
  }
  @IsTest
  static void testGetSelfRegistrationURL() {
    Test.startTest();
    System.assert(
      String.isNotBlank(LightningLoginFormController.getSelfRegistrationUrl())
    );
    Test.stopTest();
  }

  @isTest
  static void testGetForgotPasswordUrl() {
    Test.startTest();
    String url = LightningLoginFormController.getForgotPasswordUrl();
    Test.stopTest();
    System.assert(String.isNotBlank(url));
  }

  @isTest
  static void testAttemptSetExperienceId() {
    Test.startTest();
    String response = LightningLoginFormController.setExperienceId('Test');
    Test.stopTest();
    System.assertEquals(
      'This method can be invoked only from within a community.',
      response
    );
  }

  @IsTest
  static void testVerifyGoogleRecaptchaToken() {
    Test.setMock(HttpCalloutMock.class, new GoogleCaptchaMock());

    Test.startTest();
    Boolean success = LightningLoginFormController.verifyGoogleRecaptchaToken(
      'SECRET',
      'TOKEN'
    );
    Test.stopTest();

    System.assert(
      success,
      'Recaptcha did not return the proper success status'
    );
  }

  @IsTest
  static void testLoginEmailNotConfirmed() {
    Test.setMock(HttpCalloutMock.class, new GoogleCaptchaMock());
    Account acc = new Account(
      LastName = 'testTTT',
      FirstName = 'TestFFFF',
      personEmail = 'test@gmail.com',
      External_Id__c = 'test@gmail.com' + Label.Country + Label.Brand
    );
    insert acc;

    Test.startTest();
    String response = LightningLoginFormController.login(
      'test@gmail.com',
      'fakePassword',
      '/login',
      'SECRET',
      'TOKEN'
    );
    Test.stopTest();
  }

  @IsTest
  static void testLoginUserLocked() {
    Test.setMock(HttpCalloutMock.class, new GoogleCaptchaMock());
    Account acc = new Account(
      LastName = 'testTTT',
      FirstName = 'TestFFFF',
      personEmail = 'test@gmail.com',
      External_Id__c = 'test@gmail.com' + Label.Country + Label.Brand
    );
    acc.LoginLockDatetime__c = Datetime.now().addDays(2);
    acc.Email_Confirmed__c = true;
    insert acc;

    Test.startTest();
    String response = LightningLoginFormController.login(
      'test@gmail.com',
      'fakePassword',
      '/login',
      'SECRET',
      'TOKEN'
    );
    Test.stopTest();
  }
  @IsTest
  static void testLoginUserUnlockedWithReset() {
    Test.setMock(HttpCalloutMock.class, new GoogleCaptchaMock());
    Account acc = new Account(
      LastName = 'testTTT',
      FirstName = 'TestFFFF',
      personEmail = 'test@gmail.com',
      External_Id__c = 'test@gmail.com' + Label.Country + Label.Brand
    );
    acc.LoginLockDatetime__c = Datetime.now().addDays(-2);
    acc.Email_Confirmed__c = true;
    acc.NumberOfFailedLogins__c = 4;
    insert acc;

    Test.startTest();
    String response = LightningLoginFormController.login(
      'test@gmail.com',
      'fakePassword',
      '/login',
      'SECRET',
      'TOKEN'
    );

    Test.stopTest();
  }

  @IsTest
  static void testLoginUserUnlockedWithSuccessfulAttempt() {
    Test.setMock(HttpCalloutMock.class, new GoogleCaptchaMock());
    Account acc = new Account(
      LastName = 'testTTT',
      FirstName = 'TestFFFF',
      personEmail = 'test@gmail.com',
      External_Id__c = 'test@gmail.com' + Label.Country + Label.Brand
    );
    acc.LoginLockDatetime__c = null;
    acc.Email_Confirmed__c = true;
    acc.NumberOfFailedLogins__c = 2;
    insert acc;

    Test.startTest();
    String response = LightningLoginFormController.login(
      'test@gmail.com',
      'fakePassword',
      '/login',
      'SECRET',
      'TOKEN'
    );

    Test.stopTest();
  }
}
