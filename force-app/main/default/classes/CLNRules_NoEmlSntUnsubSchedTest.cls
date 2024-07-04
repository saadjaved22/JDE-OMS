@IsTest
public with sharing class CLNRules_NoEmlSntUnsubSchedTest {
  private static testMethod void testScheduler() {
    Test.StartTest();
    CLNRules_NoEmlSntUnsubSched sh1 = new CLNRules_NoEmlSntUnsubSched();
    String sch = '0 0 15 * * ?';
    system.schedule('Test run schedulable', sch, sh1);
    Test.stopTest();
  }
}
