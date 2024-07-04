/*********************************************************************
Name    :       BrewerRegistrationTriggerHandler Trigger
Date    :       12 July 2017
Author  :       Anjerico Caburnay
Description:    Trigger handler of BrewerRegistrationTrigger for Brewer_Registration__c Object
History :       
*********************************************************************/

public class BrewerRegistrationTriggerHandler {
  //calls all methods Before Insert
  public static void onBeforeInsert(List<Brewer_Registration__c> brewerList) {
    customerContact(brewerList);
  }
  public static void onAfterInsert(List<Brewer_Registration__c> brewerList) {
    // Call all methods on After Insert
    // CLM Flow
    CLMTriggerFlowClass.CLMTriggerFlow(brewerList);
  }

  public static void customerContact(List<Brewer_Registration__c> brewerList) {
    Set<Id> accIds = new Set<Id>();

    for (Brewer_Registration__c b : brewerList) {
      accIds.add(b.Customer__c);
    }

    if (!accIds.isEmpty()) {
      Map<Id, Account> accMap = new Map<Id, Account>(
        [SELECT PersonContactId FROM Account WHERE Id IN :accIds]
      );

      for (Brewer_Registration__c brw : brewerList) {
        brw.Contact__c = accMap.get(brw.Customer__c).PersonContactId;
      }
    }
  }
}
