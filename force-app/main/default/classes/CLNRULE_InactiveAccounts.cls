/************* Run the batch every month  not every day in order to save performance  ******************/
/* 

History
    Created by Wunderman Thompson  09/2022
*/

global without sharing class CLNRULE_InactiveAccounts implements Database.Batchable<SObject> {
  Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
  String queryLimit = settings.Query_Limit__c != null
    ? settings.Query_Limit__c
    : '';
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      'SELECT Id,Type__c, CreatedDate, Deletion_Flag__c, To_be_Deleted_Date__c, Deletion_Reason__c, Last_Email_clicked__c, Last_Email_opened__c, ' +
        'Brand__c,Consent_Status__c,Loyalty_Total_Points__c, IsCustomerPortal,Loyalty_Last_Transaction_Date__c, ' +
        '(SELECT Id,Start_Date__c FROM Orders__r ORDER BY Start_Date__c DESC LIMIT 1) ' +
        'FROM Account ' +
        'WHERE Deletion_Flag__c = false ' +
        'AND (Type__c = \'Registered\' OR Type__c = \'Loyalty\')' +
        queryLimit
    );
  }

  global void execute(Database.BatchableContext BC, List<Account> scope) {
    List<Account> accountsToUpdate = new List<Account>();
    Set<Id> accountIdsWithPortalUser = new Set<Id>();

    for (Account acc : Scope) {
      if (acc.IsCustomerPortal == true) {
        accountIdsWithPortalUser.add(acc.Id);
      }
    }
    List<User> portalUsersList = [
      SELECT Id, Contact.AccountId, LastLoginDate
      FROM User
      WHERE
        IsActive = TRUE
        AND IsPortalEnabled = TRUE
        AND Contact.AccountId IN :accountIdsWithPortalUser
    ];
    Map<Id, User> usersMapWithRelatedAccount = new Map<Id, User>();
    for (User u : portalUsersList) {
      usersMapWithRelatedAccount.put(u.Contact.AccountId, u);
    }

    for (Account acc : scope) {
      /****DTC brands****/
      /****** For DTC using the created date since we do not have the last login date ******/
      if (
        (acc.Brand__c == 'Tassimo' || acc.Brand__c == 'L\'OR') &&
        acc.CreatedDate < Date.today().addYears(-5)
      ) {
        if (acc.Orders__r.size() > 0) {
          if (acc.Orders__r[0].Start_Date__c < Date.today().addYears(-5)) {
            acc.Deletion_Flag__c = true;
            acc.To_be_Deleted_Date__c = date.today();
            acc.Deletion_Reason__c = 'Inactive account';
            accountsToUpdate.add(acc);
          }
        } else {
          acc.Deletion_Flag__c = true;
          acc.To_be_Deleted_Date__c = date.today();
          acc.Deletion_Reason__c = 'Inactive account';
          accountsToUpdate.add(acc);
        }
      } else if (acc.Brand__c == 'Douwe Egberts') {
        /****DE brand****/
        if (
          acc.IsCustomerPortal == true &&
          usersMapWithRelatedAccount.keySet().contains(acc.Id)
        ) {
          /******Account with portal user******/
          Datetime lasLoginDate = usersMapWithRelatedAccount.get(acc.Id)
            .LastLoginDate;
          if (Test.isRunningTest()) {
            lasLoginDate = Date.today().addYears(-6);
          }
          if (
            acc.Loyalty_Total_Points__c == 0 &&
            lasLoginDate < Date.today().addYears(-5) &&
            (acc.Loyalty_Last_Transaction_Date__c == null ||
            acc.Loyalty_Last_Transaction_Date__c < Date.today().addYears(-5))
          ) {
            acc.Deletion_Flag__c = true;
            acc.To_be_Deleted_Date__c = date.today();
            acc.Deletion_Reason__c = 'Inactive account';
            acc.IsCustomerPortal = false;
            accountsToUpdate.add(acc);
          }
        }
      } else if (acc.Brand__c == 'Maison du Café') {
        /****MDC brand****/
        if (
          acc.IsCustomerPortal == true &&
          usersMapWithRelatedAccount.keySet().contains(acc.Id)
        ) {
          /******Account with portal user******/
          Datetime lasLoginDate = usersMapWithRelatedAccount.get(acc.Id)
            .LastLoginDate;
          if (Test.isRunningTest()) {
            lasLoginDate = Date.today().addYears(-2);
          }
          if (lasLoginDate < Date.today().addYears(-1)) {
            acc.Deletion_Flag__c = true;
            acc.To_be_Deleted_Date__c = date.today();
            acc.Deletion_Reason__c = 'Inactive account';
            acc.IsCustomerPortal = false;
            accountsToUpdate.add(acc);
          }
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
