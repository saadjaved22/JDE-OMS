public class DEPortalUsersConfirmEmailReminderSch implements Schedulable {
  public void execute(SchedulableContext sc) {
    DEPortalUsersConfirmEmailReminderBatch b = new DEPortalUsersConfirmEmailReminderBatch();
    database.executebatch(b, 99);
  }
}
