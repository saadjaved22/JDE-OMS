/* 
History
    Created by Wunderman Thompson  11/2022
*/
@IsTest
public class CLNRULE_InactiveDE_SchedulerTest {
    
    @IsTest
    static void testScheduler(){
        
        Test.StartTest();
            CLNRULE_InactiveDE_Scheduler sh1 = new CLNRULE_InactiveDE_Scheduler();      
            String sch = '0 0 15 * * ?';
            System.schedule('Test run schedulable', sch, sh1);
        Test.stopTest();
        
    }
}