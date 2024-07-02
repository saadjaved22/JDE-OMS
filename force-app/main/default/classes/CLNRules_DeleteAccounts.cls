/*****************************************************************************
Name    :       CLNRules_DeleteAccounts Batchable Class
Date    :       22 November 2017
Author  :       Anjerico Caburnay
Description:    Batchable class that will Delete all Account Records with To_be_Deleted_Date__c = Today
History :   
History
    fixed by Wunderman Thompson  09/2022  
*****************************************************************************/

global class CLNRules_DeleteAccounts implements Database.Batchable<sObject>{

     global Database.QueryLocator start(Database.BatchableContext BC){
          Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
          String queryLimit = settings.Query_Limit__c != Null ? settings.Query_Limit__c : '';
         return Database.getQueryLocator('SELECT Id, PersonContactId, Deletion_Flag__c, To_be_Deleted_Date__c, Deletion_Reason__c, ContactID__pc '+
                                        'FROM Account WHERE Deletion_Flag__c = true AND To_be_Deleted_Date__c <= TODAY '+ queryLimit);
     }
 
     global void execute(Database.BatchableContext BC, List<Account> scope){
          //sp = Database.setSavepoint();
          try{
             //Initialization of Set needed
             Set<Id> setAccoundIds = new Set<Id>();
             Set<Id> setContactIds = new Set<Id>();
             
             //Initialization of List needed
             List<Account> accToBeDeleted = new List<Account>();
             List<Voucher__c> vchList = new List<Voucher__c>();
             List<et4ae5__IndividualEmailResult__c> ierList = new List<et4ae5__IndividualEmailResult__c>();
             List<Post_Deletion_Audit_Log__c> pdaList = new List<Post_Deletion_Audit_Log__c>();
             
             //Add Account and Contact Ids to Set
            for(Account acc: scope){
                 setAccoundIds.add(acc.Id);
                 setContactIds.add(acc.ContactID__pc);
            }
             
             //Population of List for Voucher and IndividualEmailResult__c to be deleted
             vchList = [SELECT Id FROM Voucher__c WHERE Customer__c IN: setAccoundIds];
             ierList = [SELECT Id FROM et4ae5__IndividualEmailResult__c WHERE et4ae5__Contact__c IN: setContactIds];
             
             //Console Log to check the values of List
             System.Debug('Voucher to be deleted: ' + vchList);
             System.Debug('Individual Email Result to be deleted: ' + ierList);
             System.Debug('Account to be deleted: ' + scope);
             
            //Start of DML Operations
             
            //Delete Voucher__c
            if(!vchList.isEmpty()){
               // Delete vchList;
               Database.delete(vchList, false) ;
            }
             
             //Delete et4ae5__IndividualEmailResult__c
            if(!ierList.isEmpty()){
               // Delete ierList;
               Database.delete(ierList, false);
            }
             
             //Delete Account
            if(!scope.isEmpty()){

                 //Add records to Post_Deletion_Audit_Log__c for Deletion History
               for(Account acc1: scope){
                     Post_Deletion_Audit_Log__c pda = new Post_Deletion_Audit_Log__c();
                     pda.Salesforce_Person_Contact_ID__c = acc1.PersonContactId;
                     pda.To_be_Deleted_Date__c = acc1.To_be_Deleted_Date__c;
                     pda.Actual_Deletion_Date__c = system.Today();
                     pda.Reason_for_Deletion__c = acc1.Deletion_Reason__c;
                     
                     pdaList.add(pda);
               }

               //DML Insert for Post_Deletion_Audit_Log__c
               //Insert pdaList;
               Database.insert(pdaList, false);
               System.Debug('Post Deletion Audit Log : ' + pdaList);
                 
               //DML Delete for Account
               // Delete scope;
               Database.delete(scope, false);
            }
          }
          catch(exception e){
               //Database.rollback(sp); 
               System.debug('exception when inserting pdaLis & deleting scope'+e);
          }
     }
 
    global void finish(Database.BatchableContext BC){
        
    }
 }