public class MdCUserCreation {
  public static List<Id> createUserRecord(List<Account> lstAccount) {
    Set<ID> setAccId = new Set<ID>();
    for (Account acc : lstAccount) {
      try {
        setAccId.add(acc.Id);
      } catch (Exception ex) {
      }
    }
    List<Account> accRec = [
      SELECT
        Id,
        FirstName,
        LastName,
        PersonEmail,
        IsCustomerPortal,
        Type__c,
        Brand__c,
        Consent_Status__c,
        PersonContactId
      FROM Account
      WHERE Id IN :setAccId
    ];
    List<User> lstUsers = new List<User>();
    List<Id> userId = new List<Id>();
    Database.DMLOptions dlo = new Database.DMLOptions();
    dlo.EmailHeader.triggerUserEmail = true;
    for (Account acc : accRec) {
      if (
        acc.IsCustomerPortal == false &&
        acc.Type__c == 'Loyalty' &&
        acc.Brand__c == 'Maison du Café' &&
        acc.Consent_Status__c == 'Active'
      ) {
        User usrRec = new User();
        usrRec.FirstName = acc.FirstName;
        usrRec.LastName = acc.LastName;
        usrRec.Email = acc.PersonEmail;
        usrRec.ProfileId = [
          SELECT Id, Name
          FROM Profile
          WHERE Name = 'MdC External Identity User'
        ]
        .Id;
        usrRec.ContactId = acc.PersonContactId;
        usrRec.userName = acc.PersonEmail + Label.MDCCommunityUserNamePostFix;
        usrRec.alias =
          ((acc.FirstName != null &&
            acc.FirstName.length() > 0)
            ? acc.FirstName.substring(0, 1)
            : '') + acc.LastName.substring(0, 1);
        usrRec.CommunityNickname = CommunityUsersFactory.createRandomDigits(7);
        usrRec.EmailPreferencesAutoBcc = true;
        usrRec.EmailPreferencesAutoBccStayInTouch = false;
        usrRec.EmailPreferencesStayInTouchReminder = false;
        usrRec.UserPreferencesHideS1BrowserUI = true;
        usrRec.LanguageLocaleKey = Label.LanguageLocaleKey;
        usrRec.LocaleSidKey = Label.LocaleSidKey;
        usrRec.TimeZoneSidKey = Label.TimeZoneSidKey;
        usrRec.EmailEncodingKey = Label.EmailEncodingKey;
        lstUsers.add(usrRec);
      }
    }

    if (lstUsers != null) {
      try {
        Database.insert(lstUsers, dlo);
        userId.add(lstUsers[0].AccountId);
      } catch (Exception ex) {
      }
    }
    return userId;
  }
}
