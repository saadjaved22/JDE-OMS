/* 
History
    Created by Wunderman Thompson  09/2022
*/
@IsTest
public class CLNRULE_InactiveAccountsScheduleTest {
  @IsTest
  static void testScheduler() {
    Test.StartTest();
    CLNRULE_InactiveAccountsSchedule sh1 = new CLNRULE_InactiveAccountsSchedule();
    String sch = '0 0 15 * * ?';
    system.schedule('Test run schedulable', sch, sh1);
    Test.stopTest();
  }
}
