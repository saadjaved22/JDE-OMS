/* 
History
    Created by Wunderman Thompson  09/2022
*/
public  class CLNRULE_InactiveAccountsSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        CLNRULE_InactiveAccounts b = new CLNRULE_InactiveAccounts();
        
        database.executebatch(b,200);
    }
}