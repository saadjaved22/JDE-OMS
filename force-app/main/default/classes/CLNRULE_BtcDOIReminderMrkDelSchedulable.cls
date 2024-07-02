/*********************************************************************
Name    :       CLNRULE_BatchDOIReminderMarkDelSchedulable
Date    :       7 December 2017
Author  :       Anjerico Caburnay
Description:    Schedulable class for the CLNRULE_BatchDOIReminderMarkDel Batch Class that will run every day
History : 
History
    @Fixed by Wunderman Thompson  09/2022
*********************************************************************/

global class CLNRULE_BtcDOIReminderMrkDelSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CLNRULE_BatchDOIReminderMarkDel b = new CLNRULE_BatchDOIReminderMarkDel();
        
        database.executebatch(b,200);
    }
   
}