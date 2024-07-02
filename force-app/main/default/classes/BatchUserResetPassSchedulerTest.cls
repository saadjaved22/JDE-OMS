/*********************************************************************
Name    :       BatchUserResetPassSchedulerTest
Date    :       26 April 2021
Author  :       Anlene Sanmocte
Description:    To schedule batch user's hard reset password
History :       
*********************************************************************/
@isTest
public class BatchUserResetPassSchedulerTest {
    private static testMethod void testMassSched(){
    Test.StartTest();
        
     Map<String, Schema.RecordTypeInfo> recordTypeInfo = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Id profId = [select Id,name from Profile where NAME = 'DE External Identity User'].Id;
         
        Account acct = New Account();
        acct.lastName = 'Test Account';
        acct.recordTypeId = recordTypeId;
        acct.firstName = 'Test Name';
        acct.lastName = 'Test Account';
        
        insert acct;
        
        Contact con = [SELECT Id,FirstName,LastName FROM Contact WHERE AccountId = :acct.Id];
        
        User usr = NEW User(
        	Alias = 'tstUsr',
        	Email = 'tstUsr@email.com',
        	EmailEncodingKey = 'UTF-8',
       		LastName = 'Test Account',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'tstUsr@email.com',
            contactId = con.Id,
            isActive = true
        );
        
        insert usr;
        
        
	BatchUserResetPassScheduler sh1 = new BatchUserResetPassScheduler();
	String sch = '0 0 15 * * ?'; 
    system.schedule('Test Check', sch, sh1); 
    Test.stopTest(); 
    }
}