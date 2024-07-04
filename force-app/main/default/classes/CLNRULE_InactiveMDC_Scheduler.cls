/* 
History
    Created by Wunderman Thompson  11/2022
*/
public class CLNRULE_InactiveMDC_Scheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    CLNRULE_InactiveAccountsMDC b = new CLNRULE_InactiveAccountsMDC();

    database.executebatch(b, 200);
  }
}
