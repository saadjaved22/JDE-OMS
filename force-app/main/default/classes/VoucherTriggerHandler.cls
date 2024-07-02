/*********************************************************************
Name    :       Voucher Trigger Handler
Date    :       19 January 2021
Author  :       Miguel Paguio
Description:    Trigger handler of Voucher for Voucher__c Object
History :       
*********************************************************************/

public class VoucherTriggerHandler{
    //calls all methods Before Insert
    public static void onBeforeInsert(List<Voucher__c> voucherList){
        customerContact(voucherList);
    } 
    
    public static void onAfterInsert(List<Voucher__c> voucherList)
    {
        
    }
    public static void customerContact(List<Voucher__c> voucherList){
        Set<Id> accIds = new Set<Id>();
        for(Voucher__c vouchList : voucherList){
            accIds.add(vouchList.Customer__c);
        }
        if(!accIds.isEmpty()){
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT PersonContactId FROM Account WHERE Id IN: accIds]);
            for(Voucher__c vchList: voucherList){
                if(vchList.Customer__c != null){
                    vchList.Contact__c = accMap.get(vchList.Customer__c).PersonContactId; 
                } 
            }
        }
    }
}