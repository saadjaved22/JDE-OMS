global class CLNRULE_AccountWithoutCampSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CLNRULE_AccountWithoutCampaign b = new CLNRULE_AccountWithoutCampaign();
        
        database.executebatch(b,200);
    }
   
}