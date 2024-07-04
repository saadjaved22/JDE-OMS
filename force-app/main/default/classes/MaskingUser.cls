/*
    Name: MaskingUser
    Purpose: This class is called from Process Builder -  Request To Be Forgotten. 
             This class deactivates and masks. 

*/
public class MaskingUser {
  /*
		This is invocable method which receives list of consumer records. 
		This method queries related community user record for these consumer records and send it to 
		MaskUserRecord method for actual implementation.
	*/
  @InvocableMethod(
    label='Deactivate User'
    description='This Method will deactivate the User record'
  )
  public static List<Account> MaskCommunityUserForAccount(
    List<Account> lstAccount
  ) {
    Set<ID> setAccId = new Set<ID>();
    List<Account> lstAcc = new List<Account>();
    for (Account acc : lstAccount) {
      try {
        setAccId.add(acc.Id);
      } catch (Exception ex) {
      }
    }

    Set<ID> setUserId = new Set<ID>();

    for (User u : [SELECT ID FROM USER WHERE accountId IN :setAccId]) {
      setUserId.add(u.Id);
    }
    MaskUserRecord(setUserID);

    return null;
  }
  /*
	This is a future method which receives set of User Id's. 
	This method masks the set of fields for community user records for GDPR compliance.
	*/

  @future
  public static void MaskUserRecord(Set<Id> setUserID) {
    system.debug('setof UserId ' + setUserID);
    List<User> lstUser = [
      SELECT ID, EMAIL, USERNAME, ACCOUNTID, ACCOUNT.PERSONEMAIL
      FROM USER
      WHERE Id IN :setUserID
    ];
    for (User usr : lstUser) {
      usr.FirstName = Label.mskFirstName;
      usr.LastName = Label.mskLastName;
      usr.Email = Label.mskEmail + string.valueOf(Math.random());
      usr.userName = Label.mskUsername + string.valueOf(Math.random());
      usr.alias = Label.mskAlias;
      usr.CommunityNickname =
        Label.maskNickname + CommunityUsersFactory.createRandomDigits(7);
      usr.IsActive = false;
      if (lstUser != null) {
        try {
          update lstUser;
        } catch (Exception ex) {
        }
      }
    }
  }
}
