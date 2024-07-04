/* Developer: Accenture
   Purpose: Batch class which is called from scheduled class ScheduleUpdateCustomerPortal.
			This class queries all loyalty consumer records where request to be forgotten is true and iscustomer portal is enabled.
		 	The execute method disable community user.*/

/* 
History
    fixed by Wunderman Thompson  09/2022
*/
global class UpdateCustomerPortalForAccount implements Database.batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT ID, IsCustomerPortal
        FROM ACCOUNT
        WHERE
          Deletion_Flag__c = TRUE
          AND IsCustomerPortal = TRUE
          AND Type__c = 'Loyalty'
      ]
    );
  }
  global void execute(Database.BatchableContext info, List<Account> scope) {
    List<Account> accsToUpdate = new List<Account>();
    for (Account acc : scope) {
      acc.IsCustomerPortal = false;
      accsToUpdate.add(acc);
    }
    if (!accsToUpdate.isEmpty()) {
      update accsToUpdate;
    }
  }
  global void finish(Database.BatchableContext info) {
  }
}
