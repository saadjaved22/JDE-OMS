/*Developer: Accenture NL
 Purpose: It is schedule class which is runs hourly and calls UpdateCustomerPortalForAccount batch class.
*/
/* 
History
    fixed by Wunderman Thompson  09/2022
*/
global class ScheduleUpdateCustomerPortal implements Schedulable{
	global void execute(SchedulableContext SC) {
        UpdateCustomerPortalForAccount bat = new UpdateCustomerPortalForAccount();
       	Database.executeBatch(bat);
   }
}