public without sharing class DEPortalUsersConfirmEmailReminderBatch implements Database.Batchable<SObject> {
  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      'SELECT Id, personEmail, Email_Confirm_URL__c, ContactID__pc ' +
        'FROM ACCOUNT ' +
        'WHERE Brand__c = \'Douwe Egberts\' AND Email_Confirmed__c = false AND isCustomerPortal = true ' +
        'AND PersonEmailBouncedDate = null AND CreatedDate = YESTERDAY '
    );
  }

  public void execute(Database.BatchableContext BC, List<Account> scope) {
    Integer count = 0;
    List<Account> targetAccounts = new List<Account>();
    for (Account acc : scope) {
      targetAccounts.add(acc);
      count++;
      if (count == 99) {
        sendConfirmEmailReminder(targetAccounts);
        count = 0;
      }
    }
    if (count > 0) {
      sendConfirmEmailReminder(targetAccounts);
    }
  }

  public void finish(Database.BatchableContext BC) {
  }

  private static void sendConfirmEmailReminder(List<Account> targetAccounts) {
    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

    for (Account acc : targetAccounts) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ acc.personEmail };

      mail.setToAddresses(toAddresses);
      mail.setReplyTo('spaarprogramma@douwe-egberts.com');
      mail.setSenderDisplayName('D.E Spaarprogramma');
      mail.setBccSender(false);
      mail.setUseSignature(false);
      mail.setSaveAsActivity(true);

      mail.setTargetObjectId(acc.ContactID__pc);
      mail.setWhatId(acc.Id);
      mail.setTemplateId(Label.DE_Confirmation_Email_Template_Reminder_ID);
      mailList.add(mail);
    }
    if (mailList.size() > 0) {
      Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList, true);
    }
  }
}
