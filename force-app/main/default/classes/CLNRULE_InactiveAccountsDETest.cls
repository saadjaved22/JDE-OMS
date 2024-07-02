/* 
History
    Created by Wunderman Thompson  11/2022
*/
@IsTest
public class CLNRULE_InactiveAccountsDETest {
    public static testMethod void testDE() {
    	Account acc = new Account();
        acc  = TestDataFactory.testAccountData()[0];
        acc.Loyalty_Email_Sent_Date__c =  System.today();
        acc.Brand__c = 'Douwe Egberts';
        acc.type__c = 'Loyalty';
        update acc;

        Test.setCreatedDate(acc.Id, Date.TODAY().addYears(-6));
        
        User u = new User();
        u = TestDataFactory.TestCreateUser(1,true)[0];
        u.ContactId = [SELECT ID FROM CONTACT WHERE ACCOUNTID = :acc.Id].Id;
        u.CommunityNickname = u.Alias;
        insert u;
        
        Test.startTest();
            CLNRULE_InactiveAccountsDE testBatch = new CLNRULE_InactiveAccountsDE();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccountList = [SELECT Id,IsCustomerPortal, Deletion_Flag__c,Last_Email_Send_Date__pc FROM Account WHERE Id = :acc.Id ];
        System.debug(checkAccountList);
        for(Account ac : checkAccountList){
            system.assert(ac.Deletion_Flag__c == true);
        }
    }
}