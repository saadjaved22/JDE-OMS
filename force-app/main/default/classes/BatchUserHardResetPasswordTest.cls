/*********************************************************************
Name    :       BatchUserHardResetPasswordTest
Date    :       23 April 2021
Author  :       Anlene Sanmocte
Description:    To be able hard reset user's password automatically
History :       
*********************************************************************/

@IsTest
public class BatchUserHardResetPasswordTest {
    public static testMethod void testScenario1(){
        
        Map<String, Schema.RecordTypeInfo> recordTypeInfo = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Id profId = [select Id FROM Profile WHERE NAME = 'DE External Identity User'].Id;
        Id usrId = [SELECT Id FROM User WHERE Name = 'Batch Apex'].Id;
        //Id accId = [SELECT Id FROM Account WHERE Name ='Miguel TestingSalesforce' LIMIT 1].Id;
        
        Account acct = New Account();
        acct.LastName = 'Test Account';
        acct.recordTypeId = recordTypeId;
        acct.FirstName = 'Test Name';
        acct.lastName = 'Test Account';
        acct.OwnerId = usrId;
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
        
        Test.startTest();
        BatchUserHardResetPassword testBatch = new BatchUserHardResetPassword();
        DataBase.executeBatch(testBatch, 70);
        Test.stopTest();
    }
    
    
}