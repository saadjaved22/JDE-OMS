/**
*    @author: Alexander Cruz
*    @date: 20.Nov.2017
*    @description: Batch Class responsible for checking the double opt-in reminder email was sent and if the account is to be marked for deletion.
*
*    @Revision History: Miguel Paguio 1/21/2020
History
    @Fixed by Wunderman Thompson  09/2022
*    
*/
global class CLNRULE_BatchDOIReminderMarkDel implements Database.Batchable<SObject>{
    public string Query;
    
    //constructor
    global CLNRULE_BatchDOIReminderMarkDel(){
        Query = 'Select id,Type__c,IsCustomerPortal, Deletion_Flag__c, Account_Registration_Status__c, Double_Opt_in_Reminder_Email_Send_Date__c, Double_Opt_in_Reminder_Send_Date__c,'+
                '(SELECT Id, Campaign.EndDate FROM  CampaignMembers__r ORDER BY  Campaign.EndDate DESC LIMIT 1)'+ 
                'FROM Account ' + 
                'WHERE Double_Opt_in_Reminder_Email_Send_Date__c != null AND Double_Opt_in_Reminder_Send_Date__c <= :last7daysformatted ' +
                'AND Consent_Status__c = \'Pending Confirmation\' AND Deletion_Flag__c = false '+
                'AND Type__c != \'Loyalty\' AND Type__c != \'Registered\' AND IsCustomerPortal = false ';
        System.debug('Query List: ' + Query);
    }
    
    //Method to determine batch data to be processed
    global Database.QueryLocator start(Database.BatchableContext BC){
        // to change the Days_After_DOI_Reminder_Sent_Date_del__c custom setting
        datetime last7days = Date.TODAY() - Integer.valueOf(Cleanup_Rules_Settings__c.getInstance().Days_After_DOI_Reminder_Sent_Date_del__c);
        date mydate = date.newInstance(last7days.year(), last7days.month(), last7days.day());
        String last7daysformatted = String.valueOf(mydate);
        return Database.getQueryLocator(Query);
    }
    
    //Method to execute to run batch job logic
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<Account> accountsToBeUpdated = new List<Account>();
        for(Account acc : scope){
            if(acc.CampaignMembers__r.size() > 0){
                Date LastCampaignEndDate = acc.CampaignMembers__r[0].Campaign.EndDate;
                Date last3Months = Date.today().addMonths(-3);
                if(LastCampaignEndDate < last3Months){
                    acc.Deletion_Flag__c = true; 
                    acc.To_be_Deleted_Date__c = acc.Double_Opt_in_Reminder_Email_Send_Date__c.date() + Integer.valueOf(Cleanup_Rules_Settings__c.getInstance().Days_to_be_Added_after_DOI_Reminder_Send__c);
                    acc.Deletion_Reason__c = Label.DelReason_No_Response_Consumer;
                    accountsToBeUpdated.add(acc);
                }
                
            }else {
                acc.Deletion_Flag__c = true; 
                acc.To_be_Deleted_Date__c = acc.Double_Opt_in_Reminder_Email_Send_Date__c.date() + Integer.valueOf(Cleanup_Rules_Settings__c.getInstance().Days_to_be_Added_after_DOI_Reminder_Send__c);
                acc.Deletion_Reason__c = Label.DelReason_No_Response_Consumer;
                accountsToBeUpdated.add(acc);
            }
        }
        if(!accountsToBeUpdated.isEmpty()){
            Database.update(accountsToBeUpdated, false);
        }
    }
    
    //Method to execute after running batch job
    global void finish(Database.BatchableContext BC){
        
    }
}