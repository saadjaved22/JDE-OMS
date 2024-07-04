@IsTest
public class DEPortalUsersConfEmailReminderSchTest {
  @IsTest
  static void testScheduler() {
    Test.startTest();
    DEPortalUsersConfirmEmailReminderSch sched = new DEPortalUsersConfirmEmailReminderSch();
    System.schedule('confirmation email Reminder', '0 0 0 * * ? *', sched);
    Test.stopTest();
  }
}
