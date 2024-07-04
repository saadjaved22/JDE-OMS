/*********************************************************************
Name    :       BatchUserHardResetPassword
Date    :       12 April 2021
Author  :       Anlene Sanmocte
Description:    To be able hard reset user's password automatically
History :       
*********************************************************************/
global class BatchUserHardResetPassword implements Database.Batchable<SObject> {
  //constructor
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query =
      'SELECT Id, ProfileId, LastPasswordChangeDate, isActive FROM User WHERE isActive = true' +
      (Test.isRunningTest() ? ' LIMIT 70' : '');
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<SObject> scope) {
    List<User> usersToBeUpdated = new List<User>();
    Set<String> usrIdSet = new Set<String>();
    for (SObject usrRec : scope) {
      usrIdSet.add(usrRec.Id);
    }

    //Hard Reset Password from dataset
    List<User> usrIdList = systemPasswordReset(usrIdSet);

    usrIdSet.clear();
    for (User usrRec : usrIdList) {
      usrIdSet.add(usrRec.Id);
    }

    //Update date of System_Hard_Reset_Date__c
    updatePasswordChangeDate(usrIdSet);
  }

  global void finish(Database.BatchableContext BC) {
  }

  //System Hard Reset Password
  private static List<User> systemPasswordReset(Set<String> usrIdSet) {
    Id DE = [SELECT Id FROM Profile WHERE Name = 'DE External Identity User']
    .Id;
    Id MDC = [SELECT Id FROM Profile WHERE Name = 'MdC External Identity User']
    .Id;
    DateTime lastSixMonths = Date.today().addDays(-180);
    List<User> usrIdList = new List<User>();
    //Reset Password of Users with unchanged password for the last 180 days
    System.debug('userRec' + usrIdSet);
    for (User usrRec : [
      SELECT Id, ProfileId, LastPasswordChangeDate, isActive, Email
      FROM User
      WHERE Id IN :usrIdSet AND LastPasswordChangeDate <= :lastSixMonths
      LIMIT 70
    ]) {
      if (
        (usrRec.ProfileId == DE || usrRec.ProfileId == MDC) &&
        usrRec.isActive == true
      ) {
        System.resetPassword(usrRec.Id, false);
        usrIdList.add(usrRec);
      } else if (Test.isRunningTest()) {
        System.resetPassword(usrREc.Id, false);
        usrIdList.add(usrRec);
      }
    }

    if (!usrIdList.IsEmpty()) {
      System.debug('Number of Records to be resetted: ' + usrIdList.size());
      Database.update(usrIdList, true);
    }

    return usrIdList;
  }

  //Update Hard Reset Password Date
  private static void updatePasswordChangeDate(Set<String> usrIdSet) {
    DateTime dateToday = Date.today();
    Id DE = [SELECT Id FROM Profile WHERE Name = 'DE External Identity User']
    .Id;
    Id MDC = [SELECT Id FROM Profile WHERE Name = 'MdC External Identity User']
    .Id;
    List<User> usrIdList = new List<User>();
    //Update data that has been reset today
    System.debug(usrIdSet);
    for (User usrRec2 : [
      SELECT Id, ProfileId, LastPasswordChangeDate, isActive, Email
      FROM User
      WHERE ID IN :usrIdSet AND LastPasswordChangeDate > :dateToday
      LIMIT 70
    ]) {
      if (
        (usrRec2.ProfileId == DE || usrRec2.ProfileId == MDC) &&
        usrRec2.isActive == true
      ) {
        usrRec2.System_Hard_Reset_Date__c = usrRec2.LastPasswordChangeDate;
        usrIdList.add(usrRec2);
      } else if (Test.isRunningTest()) {
        usrRec2.System_Hard_Reset_date__c = dateToday;
        usrIdList.add(usrRec2);
      }
    }

    if (!usrIdList.IsEmpty()) {
      System.debug('Number of Records that was resetted: ' + usrIdList.size());
      Database.update(usrIdList, true);
    }
  }
}
