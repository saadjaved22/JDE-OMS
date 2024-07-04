/* 
History
    Created by Wunderman Thompson  11/2022
*/
public class CLNRULE_InactiveDTC_Scheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    CLNRULE_InactiveAccountsDTC b = new CLNRULE_InactiveAccountsDTC();

    database.executebatch(b, 200);
  }
}
