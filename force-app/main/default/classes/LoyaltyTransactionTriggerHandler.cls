/*********************************************************************
Name    :       Loyalty Transaction Trigger Handler
Date    :       29 April 2020
Author  :       Miguel Paguio
Description:    Trigger handler of Loyalty Transaction for Loyalty_Transaction__c Object
History :       
*********************************************************************/

public class LoyaltyTransactionTriggerHandler {
  //calls all methods Before Insert
  public static void onBeforeInsert(
    List<Loyalty_Transaction__c> loyaltyTransactionList
  ) {
    customerContact(loyaltyTransactionList);
  }

  public static void onAfterInsert(
    List<Loyalty_Transaction__c> loyaltyTransactionList
  ) {
  }
  public static void customerContact(
    List<Loyalty_Transaction__c> loyaltyTransactionList
  ) {
    Set<Id> accIds = new Set<Id>();
    for (Loyalty_Transaction__c transList : loyaltyTransactionList) {
      accIds.add(transList.Loyalty_Consumer__c);
    }
    if (!accIds.isEmpty()) {
      Map<Id, Account> accMap = new Map<Id, Account>(
        [SELECT PersonContactId FROM Account WHERE Id IN :accIds]
      );
      for (Loyalty_Transaction__c ltyTrans : loyaltyTransactionList) {
        ltyTrans.Contact__c = accMap.get(ltyTrans.Loyalty_Consumer__c)
          .PersonContactId;
      }
    }
  }
}
