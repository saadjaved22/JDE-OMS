global without sharing class ForceDeleteConsumer {
  webService static String forceDeleteAction(Id accountId) {
    string status = 'Failed';
    forceDeleteConsumerSetting__c forceDeleteConsumer = forceDeleteConsumerSetting__c.getInstance();

    if (!forceDeleteConsumer.Access_to_force_deletion_process__c) {
      status = forceDeleteConsumer.Insufficient_access_error__c;
      return status;
    }

    Id userId;
    Account accountRec = new Account();
    accountRec.Id = accountId;
    Id contactId = [
      SELECT contactID__pc
      FROM Account
      WHERE id = :accountId
      LIMIT 1
    ]
    .contactID__pc;
    List<User> userList = [
      SELECT ID, IsPortalEnabled, IsActive
      FROM User
      WHERE contactId = :contactId
      LIMIT 1
    ];
    if (userList.size() > 0) {
      User userRec = userList.get(0);
      userRec.Force_Delete_User__c = true;
      update userRec;
      status = forceDeleteConsumer.Successfully_deleted_text__c;
    } else {
      delete accountRec;
      status = forceDeleteConsumer.Successfully_deleted_text__c;
    }
    return status;
  }

  @future
  webService static void deleteAccount(Id accountId) {
    Account accountRec = new Account(Id = accountId);
    if (Test.isRunningTest()) {
      return;
    }
    delete accountRec;
  }
  @InvocableMethod
  webService static void deleteAccountPB(List<Account> accountList) {
    deleteAccount(accountList[0].Id);
  }
}
