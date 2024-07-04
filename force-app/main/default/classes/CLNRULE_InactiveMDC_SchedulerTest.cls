/* 
History
    Created by Wunderman Thompson  11/2022
*/
@IsTest
public with sharing class CLNRULE_InactiveMDC_SchedulerTest {
  @IsTest
  static void testScheduler() {
    Test.StartTest();
    CLNRULE_InactiveMDC_Scheduler sh1 = new CLNRULE_InactiveMDC_Scheduler();
    String sch = '0 0 15 * * ?';
    System.schedule('Test run schedulable', sch, sh1);
    Test.stopTest();
  }
}
