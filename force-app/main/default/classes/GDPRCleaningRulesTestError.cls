@isTest
public class GDPRCleaningRulesTestError {
    private static testMethod void manyAccountTest() {
        List<Account> lstAcc = new List<Account>();
        
        ProcessBuilderSettings__c cs = new ProcessBuilderSettings__c();
        cs.AccountProcessBuilder__c = true;
        cs.IndividualEmailResultProcessBuilder__c = true;
        cs.LoyaltyProcessBuilder__c = true;
        cs.LoyaltyTransactionProcessBuilder__c = true;
        //cs.Other field values
     	insert cs;

        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        for(integer x=0;x<200;x++){
            Account acct = TestDataBuilder.createAccount();
            acct.recordTypeId = recordTypeId;
            acct.Type__c = 'Loyalty';
            //acct.IsCustomerPortal = true;
            acct.Account_Registration_Status__c = 'Active';
            acct.Consent_Status__c = 'Active';
            lstAcc.add(acct);
        }
        
        insert lstAcc;
        
        system.debug('First');
        system.debug(lstAcc);
        
        for(Account accRec: lstAcc){ 
            accRec.Request_to_be_Forgotten__c = true;
        }
        update lstAcc;
        List<Account> updatedAcc = [SELECT Id, Request_to_be_Forgotten__c, Deletion_Flag__c, To_be_Deleted_Date__c From Account where Id IN :lstAcc];
        
        system.debug('Second');
        system.debug(updatedAcc);
        for(Account accRec: lstAcc){            
            accRec.Double_Opt_in_Reminder_Email_Send_Date__c = system.now();
        }
        update lstAcc;
        updatedAcc = [SELECT Id, Name, Request_to_be_Forgotten__c, Deletion_Flag__c, To_be_Deleted_Date__c From Account where Id IN :lstAcc];
        
        system.debug('last');
        system.debug(updatedAcc);
		
    }
}