/*********************************************************************
Name    :       ACN_MatchOrderAndVouchersSchedulable
Date    :       20 June 2017
Author  :       Anjerico Caburnay
Description:    Schedulable class for the ACN_MatchOrderAndVouchers Batch Class that will run every 15 minutes
History : 
*********************************************************************/

global class ACN_MatchOrderAndVouchersSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        ACN_MatchOrderAndVouchers b = new ACN_MatchOrderAndVouchers ();
        
        database.executebatch(b,50);
        //used for ACN_MatchOrderAndVouchersSchedulable TESTING
    }
   
}
