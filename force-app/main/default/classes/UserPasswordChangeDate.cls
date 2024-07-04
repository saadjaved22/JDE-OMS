/*********************************************************************
Name    :       UserPasswordChangeDate 
Date    :       12 August 2020
Author  :       Anlene Sanmocte
Description:    To get Last Password Change Date from User Object with a community user
History :       
*********************************************************************/

public without sharing class UserPasswordChangeDate {
  public static DateTime checkLastPasswordChangeDate(Id userId) {
    for (User usrRec : [
      SELECT Id, LastPasswordChangeDate
      FROM User
      WHERE Id = :userId
    ]) {
      //return usrRec.LastPasswordChangeDate.addDays(30);
      DateTime oldPWExpDuration = DateTime.newInstance(2020, 8, 18);

      if (usrRec.LastPasswordChangeDate < oldPWExpDuration) {
        return usrRec.LastPasswordChangeDate.addDays(90);
      } else {
        return usrRec.LastPasswordChangeDate.addDays(180);
      }
    }

    return null;
  }
}
