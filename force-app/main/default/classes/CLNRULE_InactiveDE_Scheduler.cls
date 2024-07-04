/* 
History
    Created by Wunderman Thompson  11/2022
*/
public class CLNRULE_InactiveDE_Scheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    CLNRULE_InactiveAccountsDE b = new CLNRULE_InactiveAccountsDE();

    database.executebatch(b, 200);
  }
}
