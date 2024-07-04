/* 
History
    Created by Wunderman Thompson  11/2022
    Enhancement on date criteria 01/12/2022
*/
global without sharing class CLNRULE_InactiveAccountsDTC implements Database.Batchable<SObject> {
  Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
  String queryLimit = settings.Query_Limit__c != null
    ? settings.Query_Limit__c
    : '';
  DateTime lastfiveYears = Datetime.now().addYears(-5);
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      'SELECT Id,CreatedDate, Deletion_Flag__c, To_be_Deleted_Date__c, Deletion_Reason__c, ' +
        'Brand__c,Inactive_Account_Last_Check__c, ' +
        '(SELECT Id,Start_Date__c FROM Orders__r ORDER BY Start_Date__c DESC LIMIT 1) ' +
        'FROM Account ' +
        'WHERE Deletion_Flag__c = false  AND Type__c = \'Registered\' ' +
        'AND (Brand__c = \'Tassimo\' OR Brand__c = \'L\\\'Or\' ) AND ' +
        'CreatedDate < :lastfiveYears AND ' +
        '(Inactive_Account_Last_Check__c = null OR Inactive_Account_Last_Check__c < :lastfiveYears) ' +
        queryLimit
    );
  }
  global void execute(Database.BatchableContext BC, List<Account> scope) {
    List<Account> accountsToUpdate = new List<Account>();

    for (Account acc : scope) {
      /****DTC brands****/
      /****** For DTC using the created date since we do not have the last login date ******/
      if (acc.Orders__r.size() > 0) {
        if (acc.Orders__r[0].Start_Date__c < Date.today().addYears(-5)) {
          acc.Deletion_Flag__c = true;
          acc.To_be_Deleted_Date__c = date.today();
          acc.Deletion_Reason__c = 'Inactive account';
          accountsToUpdate.add(acc);
        } else {
          acc.Inactive_Account_Last_Check__c = acc.Orders__r[0].Start_Date__c;
          accountsToUpdate.add(acc);
        }
      } else {
        acc.Deletion_Flag__c = true;
        acc.To_be_Deleted_Date__c = date.today();
        acc.Deletion_Reason__c = 'Inactive account';
        accountsToUpdate.add(acc);
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
