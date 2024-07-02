/* 
History
    Created by Wunderman Thompson  09/2022
*/
@IsTest
public  class CLNRULE_InactiveAccountsTest {
    
    @TestSetup
    static void makeData(){
        
    }

    @IsTest
    static void testDTCAccountsWithOrders(){
        date testDate = Date.TODAY().addYears(-6);
        
            String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
            List<Account> accList = new List<Account>();
            for(integer x=0;x<10;x++){
                Account acct = TestDataBuilder.createAccount();
                acct.recordTypeId = recordTypeId;
                acct.CurrencyISOCode = 'EUR';
                acct.Deletion_Flag__c = false;
                acct.brand__c = 'Tassimo';
                acct.Type__c = 'Registered';
                
                accList.add(acct);
            }
            insert accList;
            
            List<Order__c> orderList = new List<Order__c>(); 
            for(integer i=0;i<5;i++){
                Order__c o = new Order__c(Name= 'Test'+i,Customer__c=accList[i].Id, Start_Date__c = testDate);
                orderList.add(o);
            }
            insert orderList;
            System.debug('orders in test \n'+orderList);
            
            for(Account acc : accList){
                Test.setCreatedDate(acc.Id, testDate);
            }

            Test.startTest();
                CLNRULE_InactiveAccounts testBatch = new CLNRULE_InactiveAccounts();
                DataBase.executeBatch(testBatch);
            Test.stopTest();

            List<Account> checkAccountList = [SELECT Id, Deletion_Flag__c,Last_Email_Send_Date__pc FROM Account ];
            System.debug(checkAccountList);
            for(Account acc : checkAccountList){
                system.assert(acc.Deletion_Flag__c == true);
            }  
    }

    public static testMethod void testDE() {
    	Account acc = new Account();
        acc  = TestDataFactory.testAccountData()[0];
        acc.Loyalty_Email_Sent_Date__c =  System.today();
        acc.Brand__c = 'Douwe Egberts';
        acc.Type__c = 'Loyalty';
        update acc;

        //Test.setCreatedDate(acc.Id, Date.TODAY().addYears(-6));
        
        User u = new User();
        u = TestDataFactory.TestCreateUser(1,true)[0];
        u.ContactId = [SELECT ID FROM CONTACT WHERE ACCOUNTID = :acc.Id].Id;
        u.CommunityNickname = u.Alias;
        insert u;
        
        Test.startTest();
            CLNRULE_InactiveAccounts testBatch = new CLNRULE_InactiveAccounts();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccountList = [SELECT Id,IsCustomerPortal, Deletion_Flag__c,Last_Email_Send_Date__pc FROM Account WHERE Id = :acc.Id ];
        System.debug(checkAccountList);
        for(Account ac : checkAccountList){
            system.assert(ac.Deletion_Flag__c == true);
        }
    }

    public static testMethod void testMDC() {
    	Account acc = new Account();
        acc  = TestDataFactory.testAccountData()[0];
        acc.Loyalty_Email_Sent_Date__c =  System.today();
        acc.Brand__c = 'Maison du Café';
        acc.Type__c = 'Loyalty';
        update acc;

        //Test.setCreatedDate(acc.Id, Date.TODAY().addYears(-6));
        
        User u = new User();
        u = TestDataFactory.TestCreateUser(1,true)[0];
        u.ContactId = [SELECT ID FROM CONTACT WHERE ACCOUNTID = :acc.Id].Id;
        u.CommunityNickname = u.Alias;
        insert u;
        
        Test.startTest();
            CLNRULE_InactiveAccounts testBatch = new CLNRULE_InactiveAccounts();
            DataBase.executeBatch(testBatch);
        Test.stopTest();

        List<Account> checkAccountList = [SELECT Id,IsCustomerPortal, Deletion_Flag__c,Last_Email_Send_Date__pc FROM Account WHERE Id = :acc.Id];
        for(Account ac : checkAccountList){
            System.assert(ac.Deletion_Flag__c == true);
        }
    }

   
}