/* 
History
    fixed by Wunderman Thompson  09/2022
*/
@IsTest (seeallData = false)
public with sharing class UpdateCustomerPortalForAccountTest {
    public static testMethod void testForgotPasswordController() {
    	Account acc = new Account();
        acc  = TestDataFactory.testAccountData()[0];
        acc.Loyalty_Email_Sent_Date__c =  System.today();
        update acc;
        system.debug('is account customer portal 1'+ [SELECT ID,ISCUSTOMERPORTAL FROM ACCOUNT WHERE ID = :acc.Id]);
        
        User u = new User();
        u = TestDataFactory.TestCreateUser(1,true)[0];
        u.ContactId = [SELECT ID FROM CONTACT WHERE ACCOUNTID = :acc.Id].Id;
        u.CommunityNickname = u.Alias;
        insert u;
        
        system.debug('is account customer portal 2'+ [SELECT ID,ISCUSTOMERPORTAL FROM ACCOUNT WHERE ID = :acc.Id]);
        
        acc.Deletion_Flag__c = true;
        update acc;
        
        Test.startTest();
            UpdateCustomerPortalForAccount testBatch = new UpdateCustomerPortalForAccount();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccountList = [SELECT Id,IsCustomerPortal, Deletion_Flag__c,Last_Email_Send_Date__pc FROM Account ];
        for(Account ac : checkAccountList){
            system.assert(acc.IsCustomerPortal == false);
        }
    }
}