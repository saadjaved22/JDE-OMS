/*********************************************************************
Name    :       IndividualEmailResultHandler Trigger
Date    :       28 December 2017
Author  :       Anjerico Caburnay
Description:    Trigger handler of IndividualEmailResultTrigger for et4ae5__IndividualEmailResult__c Object
History :       Code Enhancements: Miguel Paguio 3/19/19
				
*********************************************************************/

public class IndividualEmailResultTriggerHandler {
  //calls all methods Before Insert
  public static void onBeforeInsert(
    List<et4ae5__IndividualEmailResult__c> emailList
  ) {
    //SendLastEmailSendDateOnInsert(emailList);
  }

  //calls all methods Before Update
  public static void onBeforeUpdate(
    List<et4ae5__IndividualEmailResult__c> emailList
  ) {
    //CheckIfEmailBouncedOnInsert(emailList);
  }

  //calls all methods After Insert
  public static void onAfterInsert(
    List<et4ae5__IndividualEmailResult__c> emailList
  ) {
    SendLastEmailSendDateOnInsertAndCheckIfEmailBouncedOnInsert(emailList);
  }

  //calls all methods After Update
  public static void onAfterUpdate(
    List<et4ae5__IndividualEmailResult__c> emailList
  ) {
    CheckIfEmailBouncedOnInsert(emailList);
  }

  public static void CheckIfEmailBouncedOnInsert(
    List<et4ae5__IndividualEmailResult__c> emailList
  ) {
    List<Contact> contactList = new List<Contact>();

    for (et4ae5__IndividualEmailResult__c em : [
      SELECT Id, et4ae5__Contact__c, et4ae5__HardBounce__c
      FROM et4ae5__IndividualEmailResult__c
      WHERE Id IN :emailList
      FOR UPDATE
    ]) {
      if (em.et4ae5__HardBounce__c) {
        Contact con = new Contact();
        con.Id = em.et4ae5__Contact__c;
        con.isHardBounced__c = true;

        contactList.add(con);
      } else {
        Contact con = new Contact();
        con.Id = em.et4ae5__Contact__c;
        con.isHardBounced__c = false;

        contactList.add(con);
      }
    }

    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    for (Contact conMap : contactList) {
      contactMap.put(conMap.Id, conMap);
    }

    if (!contactMap.isEmpty()) {
      update contactMap.values();
    }
  }

  public static void SendLastEmailSendDateOnInsertAndCheckIfEmailBouncedOnInsert(
    List<et4ae5__IndividualEmailResult__c> emailList
  ) {
    List<Contact> contactList = new List<Contact>();

    for (et4ae5__IndividualEmailResult__c em : [
      SELECT Id, et4ae5__Contact__c, et4ae5__HardBounce__c
      FROM et4ae5__IndividualEmailResult__c
      WHERE Id IN :emailList
      FOR UPDATE
    ]) {
      Contact con = new Contact();
      con.Id = em.et4ae5__Contact__c;
      con.Last_Email_Send_Date__c = system.today();
      if (em.et4ae5__HardBounce__c) {
        con.isHardBounced__c = true;
        contactList.add(con);
      } else {
        con.isHardBounced__c = false;
        contactList.add(con);
      }
    }

    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    for (Contact conMap : contactList) {
      contactMap.put(conMap.Id, conMap);
      //update contactMap.values();
    }

    if (!contactMap.isEmpty()) {
      update contactMap.values();
    }
  }
}
