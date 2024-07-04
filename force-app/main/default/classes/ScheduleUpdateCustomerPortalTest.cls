/* 

History
    fixed by Wunderman Thompson  09/2022
*/
@isTest
public with sharing class ScheduleUpdateCustomerPortalTest {
  @IsTest
  static void testScheduler() {
    Test.StartTest();
    ScheduleUpdateCustomerPortal sh1 = new ScheduleUpdateCustomerPortal();
    String sch = '0 0 15 * * ?';
    system.schedule('Test run schedulable', sch, sh1);
    Test.stopTest();
  }
}
