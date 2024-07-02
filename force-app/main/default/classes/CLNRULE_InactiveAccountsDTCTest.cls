/* 
History
    Created by Wunderman Thompson  11/2022
*/
@IsTest
public  class CLNRULE_InactiveAccountsDTCTest {
    
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
                CLNRULE_InactiveAccountsDTC testBatch = new CLNRULE_InactiveAccountsDTC();
                DataBase.executeBatch(testBatch);
            Test.stopTest();

            List<Account> checkAccountList = [SELECT Id, Deletion_Flag__c,Last_Email_Send_Date__pc FROM Account ];
            System.debug(checkAccountList);
            for(Account acc : checkAccountList){
                system.assert(acc.Deletion_Flag__c == true);
            }  
    }
}