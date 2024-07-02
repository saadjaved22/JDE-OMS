/*********************************************************************
Name    :       CLNRules_DeleteAccountsSchedulable
Date    :       7 December 2017
Author  :       Anjerico Caburnay
Description:    Schedulable class for the CLNRules_DeleteAccounts Batch Class that will run every day
History : 
History
    fixed by Wunderman Thompson  09/2022
*********************************************************************/

global class CLNRules_DeleteAccountsSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CLNRules_DeleteAccounts b = new CLNRules_DeleteAccounts();
        
        database.executebatch(b,200);
    }
   
}