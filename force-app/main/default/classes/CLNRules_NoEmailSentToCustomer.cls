/*****************************************************************************
Name    :       CLNRules_NoEmailSentToCustomer Batchable Class
Date    :       21 November 2017
Author  :       Anjerico Caburnay
Description:    Batchable class that will get all accounts with Deletion_Flag__c = false AND Account_Registration_Status__c !=: accStatus
                AND Last_Email_Send_Date__pc < LAST_N_DAYS:365
History
    fixed by Wunderman Thompson  09/2022   
*****************************************************************************/

global class CLNRules_NoEmailSentToCustomer implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String Query =
      'SELECT Id, Type__c, IsCustomerPortal, Deletion_Flag__c, To_be_Deleted_Date__c, Deletion_Reason__c, Last_Email_clicked__c, Last_Email_opened__c, ' +
      'Brand__c, Last_Order_Date__c,Consent_Status__c,CreatedDate ' +
      'FROM Account ' +
      'WHERE Deletion_Flag__c = false ' +
      'AND (Last_Email_clicked__c <  LAST_N_MONTHS:24 OR Last_Email_clicked__c = Null) ' +
      'AND (Last_Email_opened__c < LAST_N_MONTHS:24 OR Last_Email_opened__c  = NULL) ' +
      'AND CreatedDate < LAST_N_MONTHS:24 ' +
      'AND Type__c != \'Loyalty\' AND Type__c != \'Registered\' AND IsCustomerPortal = false';
    /*
     'AND (Last_Email_Send_Date__pc < LAST_N_MONTHS:24 OR (Last_Email_Send_Date__pc = Null AND CreatedDate < LAST_N_MONTHS:24)) '+ */
    return Database.getQueryLocator(Query);
  }

  global void execute(Database.BatchableContext BC, List<Account> scope) {
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    List<Account> accountsToUpdate = new List<Account>();
    System.debug(scope.size());
    try {
      for (Account acc : scope) {
        // NON-DTC, non portal user
        acc.Deletion_Flag__c = true;
        acc.To_be_Deleted_Date__c = date.today()
          .addDays(Integer.valueOf(settings.Days_For_NoEmailSentToCustomer__c));
        acc.Deletion_Reason__c = 'No email sent over 24 months';
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
