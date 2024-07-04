/* 
Name    :       CLNRules_NoEmailSentUnsubscribe Batchable Class
Date    :       07/11/2022
Author  :       Abderrezak FENOUCHE 
Description:    Batchable class that will get all accounts with no email sent over 24 months and they
*/

global without sharing class CLNRules_NoEmailSentUnsubscribe implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String Query =
      'SELECT Id, Type__c, IsCustomerPortal, Deletion_Flag__c, To_be_Deleted_Date__c, Deletion_Reason__c, Last_Email_clicked__c, Last_Email_opened__c, ' +
      'Brand__c, Last_Order_Date__c,Consent_Status__c,CreatedDate ' +
      'FROM Account ' +
      'WHERE Deletion_Flag__c = false AND (Consent_Status__c = \'Active\' OR Consent_Status__c = \'Confirmed\') ' +
      'AND (Last_Email_clicked__c <  LAST_N_MONTHS:24 OR Last_Email_clicked__c = Null) ' +
      'AND (Last_Email_opened__c < LAST_N_MONTHS:24 OR Last_Email_opened__c  = NULL) ' +
      'AND CreatedDate < LAST_N_MONTHS:24 ' +
      'AND (Type__c = \'Loyalty\' OR Type__c = \'Registered\' OR IsCustomerPortal = true)';

    return Database.getQueryLocator(Query);
  }
  global void execute(Database.BatchableContext BC, List<Account> scope) {
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    List<Account> accountsToUpdate = new List<Account>();
    System.debug(scope.size());
    try {
      for (Account acc : scope) {
        // DTC or portal user
        acc.Consent_Status__c = 'Expired';
        accountsToUpdate.add(acc);
      }

      System.Debug(
        'Scope of the  Batch NoEMailSent24Months : \n' + scope.size()
      );
      System.Debug(
        'List of Account from Batch NoEMailSent24Months to be deleted : \n' +
        accountsToUpdate.size()
      );
      if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
      }
    } catch (exception e) {
      system.debug('Error: ' + e);
    }
  }

  global void finish(Database.BatchableContext BC) {
  }
}
