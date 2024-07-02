/*********************************************************************
Name    :               CLNRules_DeleteAccountsTest
Date    :               29 November 2017
Author  :               William Paredes
Description :           Test Class of  CLNRules_DeleteAccounts
Current Test Coverage : 93%
History :       
History
    fixed by Wunderman Thompson  09/2022
*********************************************************************/

@isTest
private class CLNRules_DeleteAccountsTest {

    private static testMethod void testDeleteAccounts() {


        String profileID = TestDataBuilder.getUserProfileId('System Administrator');
        
        User testUser = TestDataBuilder.createUser(1, profileID);
        insert testUser;
        
        date testDate = Date.TODAY();
        System.runAs(testUser)
        {
            
            String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
            List<Account> accList = new List<Account>();
            for(integer x=0;x<10;x++){
                Account acct = TestDataBuilder.createAccount();
                acct.LastName = 'Test Name' + x;
                acct.recordTypeId = recordTypeId;
                acct.CurrencyISOCode = 'EUR';
                acct.Deletion_Flag__c = true;
                acct.Account_Registration_Status__c = 'Deactivated';
                acct.To_be_Deleted_Date__c = testDate;
                accList.add(acct);
            }
            insert accList;
            
            List<Contact> conList = new List<Contact>();
            for(integer x=0;x<10;x++){
                Contact con = new Contact();
                con.LastName = 'testCon'+x;
                Account testAccId = acclist.get(x);
                con.Account = testAccId;
                conList.add(con);
            }
            insert conList;
            
            List<Voucher__c> voucherList = new List<Voucher__c>();
            for(integer x=0;x<10;x++){
                Voucher__c vch = new Voucher__c();
                vch.Name = 'testVoucher'+x;
                Account testAccId = acclist.get(x);
                vch.Customer__c = testAccId.Id;
                voucherList.add(vch);
            }
            insert voucherList;
           
           et4ae5__SendDefinition__c testEmSend = new et4ae5__SendDefinition__c();
           testEmSend.et4ae5__Status_Date_Time__c = Date.Today();
           testEmSend.et4ae5__DedupeSubscribers__c = true;
           testEmSend.et4ae5__RecipientsOptedIn__c = true;
           insert testEmSend;
           
           /*
            List<et4ae5__IndividualEmailResult__c> invEmailList = new List<et4ae5__IndividualEmailResult__c>();
            for(integer x=0;x<10;x++){
                et4ae5__IndividualEmailResult__c invEmail = new et4ae5__IndividualEmailResult__c();
                invEmail.Name = 'testInvEmail'+x;
                Contact testConId = conlist.get(x);
                invEmail.et4ae5__Contact__c = testConId.Id;
                invEmail.et4ae5__SendDefinition__c = testEmSend.Id;
                invEmailList.add(invEmail);
            }
            insert invEmailList;
           */
            
           
            Test.startTest();
            CLNRules_DeleteAccounts testBatch = new CLNRules_DeleteAccounts();
            DataBase.executeBatch(testBatch);
            Test.stopTest();
            
           // Account checkAccount = [SELECT Id FROM Account LIMIT 1];
            //system.assert(checkAccount.Id == null);
            
        } 
    }
    
}