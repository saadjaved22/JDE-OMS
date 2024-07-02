@isTest
public class LoyaltyTransactionTriggerHandlerTest{
    
    private static testMethod void insertRecord(){
        TriggerSettings__c ts1 = new TriggerSettings__c();
        ts1.LoyaltyTransactionTrigger__c = True;
        insert ts1;
             
        String recordTypeId = TestDataBuilder.getObjectRecordTypeId(Account.SObjectType, 'Person Account');
        Account accRec = new Account();
        accRec.RecordTypeId = recordTypeId;
        accRec.LastName = 'testing 123';
        insert accRec;
        
        Loyalty__c loytRec = new Loyalty__c();
        loytRec.Loyalty_Consumer__c = accRec.Id;
        insert loytRec;
        
  		Loyalty_Transaction__c loytTransRec = new Loyalty_Transaction__c();
        loytTransRec.Loyalty__c = loytRec.Id;
        loytTransRec.Loyalty_Consumer__c = accRec.Id;
        loytTransRec.Loyalty_Transaction_Type__c = 'Compensation';
        loytTransRec.Loyalty_Source__c = 'Blokker POS';
        loytTransRec.Transaction_Amount__c = 1000;
		insert loytTransRec;
        
        Test.startTest();
        loytTransRec.Contact__c = accRec.PersonContactId;
        update loytTransRec;
        Test.stopTest();
    }
}