/*********************************************************************
Name    :       AccountHardResetPassword 
Date    :       12 October 2020
Author  :       Anlene Sanmocte
Description:    To be able hard reset user's password
History :       
*********************************************************************/

@IsTest
public class AccountHardResetPasswordTest {
     public static testMethod void testScenario1(){
        
        TriggerSettings__c ts1 = new TriggerSettings__c();
        
        Map<String, Schema.RecordTypeInfo> recordTypeInfo = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        String recordTypeId = recordTypeInfo.get('Person Account').getRecordTypeId();
        Profile profId = [select Id,name from Profile where NAME = 'DE External Identity User'];
         
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
            ProfileId = '00e0Y000000RZR0QAO',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'tstUsr@email.com',
            contactId = con.Id,
            isActive = true,
            Hard_Reset_Password__c = true
        );
        
        insert usr;
        
        Test.startTest();
        AccountHardResetPassword testBatch = new AccountHardResetPassword();
        DataBase.executeBatch(testBatch);
        Test.stopTest();
    }
    
        
}