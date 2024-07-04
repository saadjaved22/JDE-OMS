@IsTest
public class ResendConfirmationEmailTest {
  @IsTest
  static void testResendEmail() {
    Account acc = new Account();
    acc = TestDataFactory.testAccountData()[0];
    acc.Loyalty_Email_Sent_Date__c = System.today();
    acc.Brand__c = 'Douwe Egberts';
    acc.type__c = 'Loyalty';
    update acc;

    Test.setCreatedDate(acc.Id, Date.TODAY().addYears(-6));

    User u = new User();
    u = TestDataFactory.TestCreateUser(1, true)[0];
    u.ContactId = [SELECT ID FROM CONTACT WHERE ACCOUNTID = :acc.Id].Id;
    u.CommunityNickname = u.Alias;
    insert u;

    Test.startTest();

    ApexPages.currentPage().getParameters().put('event', acc.Id);
    ApexPages.StandardController acctController = new ApexPages.StandardController(
      acc
    );
    ResendConfirmationEmail acctControllerExtension = new ResendConfirmationEmail(
      acctController
    );
    PageReference pageRef = acctControllerExtension.ResendEmail();
    System.assert(pageRef != null);
    System.debug(pageRef);

    Test.stopTest();
  }
}
