/* 
History
    Created by Wunderman Thompson  11/2022
    Enhancement on date criteria 01/12/2022
*/
global without sharing class CLNRULE_InactiveAccountsDE implements Database.Batchable<SObject> {
  Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
  String queryLimit = settings.Query_Limit__c != null
    ? settings.Query_Limit__c
    : '';
  Boolean disablePortalUser = settings.Disable_portal_user__c != null
    ? settings.Disable_portal_user__c
    : false;
  DateTime lastfiveYears = Datetime.now().addYears(-5);
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      'SELECT Id,CreatedDate, Deletion_Flag__c, To_be_Deleted_Date__c, Deletion_Reason__c, ' +
        'Brand__c,Loyalty_Total_Points__c, IsCustomerPortal,Loyalty_Last_Transaction_Date__c,Inactive_Account_Last_Check__c ' +
        'FROM Account ' +
        'WHERE Deletion_Flag__c = false AND  Type__c = \'Loyalty\' ' +
        'AND Brand__c = \'Douwe Egberts\' AND CreatedDate < :lastfiveYears AND IsCustomerPortal = true ' +
        'AND (Inactive_Account_Last_Check__c = null OR Inactive_Account_Last_Check__c < :lastfiveYears) ' +
        queryLimit
    );
  }
  global void execute(Database.BatchableContext BC, List<Account> scope) {
    List<Account> accountsToUpdate = new List<Account>();
    Set<Id> accountIdsWithPortalUser = new Set<Id>();

    for (Account acc : Scope) {
      accountIdsWithPortalUser.add(acc.Id);
    }
    List<User> portalUsersList = [
      SELECT Id, Contact.AccountId, LastLoginDate
      FROM User
      WHERE
        IsPortalEnabled = TRUE
        AND Contact.AccountId IN :accountIdsWithPortalUser
    ];
    Map<Id, User> usersMapWithRelatedAccount = new Map<Id, User>();
    for (User u : portalUsersList) {
      usersMapWithRelatedAccount.put(u.Contact.AccountId, u);
    }

    for (Account acc : scope) {
      /****DE brand****/
      if (usersMapWithRelatedAccount.keySet().contains(acc.Id)) {
        /******Account with portal user******/
        Datetime lastLoginDate = usersMapWithRelatedAccount.get(acc.Id)
          .LastLoginDate;
        if (Test.isRunningTest()) {
          lastLoginDate = Date.today().addYears(-6);
        }
        if (
          acc.Loyalty_Total_Points__c == 0 &&
          (lastLoginDate == null ||
          lastLoginDate < Date.today().addYears(-5)) &&
          (acc.Loyalty_Last_Transaction_Date__c == null ||
          acc.Loyalty_Last_Transaction_Date__c < Date.today().addYears(-5))
        ) {
          acc.Deletion_Flag__c = true;
          acc.To_be_Deleted_Date__c = date.today();
          acc.Deletion_Reason__c = 'Inactive account';

          if (disablePortalUser) {
            acc.IsCustomerPortal = false;
          }

          accountsToUpdate.add(acc);
        } else {
          acc.Inactive_Account_Last_Check__c = lastLoginDate;
          accountsToUpdate.add(acc);
        }
      }
    }
    System.debug('Accounts to be updated \n' + accountsToUpdate);

    try {
      if (!accountsToUpdate.isEmpty()) {
        Database.update(accountsToUpdate, false);
      }
    } catch (Exception e) {
      System.debug(
        'Exception when trying to update accounts ' + e.getMessage()
      );
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}
