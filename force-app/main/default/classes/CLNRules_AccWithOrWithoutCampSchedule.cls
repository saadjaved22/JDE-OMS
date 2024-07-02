/* 
History
    Created by Wunderman Thompson  09/2022
*/
public  class CLNRules_AccWithOrWithoutCampSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        CLNRULE_AccountWithOrWithoutCampaign b = new CLNRULE_AccountWithOrWithoutCampaign();
        
        database.executebatch(b,200);
    }
}