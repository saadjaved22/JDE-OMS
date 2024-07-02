/*********************************************************************
Name    :       CLNRules_NoEmailSentToCustomerSchedulable
Date    :       7 December 2017
Author  :       Anjerico Caburnay
Description:    Schedulable class for the CLNRules_NoEmailSentToCustomer Batch Class that will run every day
History : 
History
    fixed by Wunderman Thompson  09/2022
*********************************************************************/

global class CLNRules_NoEmlSntToCustSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CLNRules_NoEmailSentToCustomer b = new CLNRules_NoEmailSentToCustomer();
        
        database.executebatch(b,200);
    }
   
}