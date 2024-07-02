/* 
History
    Created by Wunderman Thompson  09/2022
*/
@IsTest
public class CLNRules_AccWithOrWithoutCampSchTest {
    @IsTest
    private static  void testScheduler() {
        ProcessBuilderSettings__c PBSettings = new ProcessBuilderSettings__c();
            PBSettings.IndividualEmailResultProcessBuilder__c = true;
            insert PBSettings;
            
            String recordTypeIdSt = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
            List<Account> accList = new List<Account>();
            for(integer x=0;x<=50;x++){
                Account acct = new Account(LastName='AccountTest '+x, recordTypeId = recordTypeIdSt);
                accList.add(acct);
            }
            insert accList;
        Test.StartTest();
            CLNRules_AccWithOrWithoutCampSchedule sh1 = new CLNRules_AccWithOrWithoutCampSchedule();      
            String sch = '0 0 15 * * ?';
            system.schedule('Test run schedulable', sch, sh1);
        Test.stopTest();
	}
}