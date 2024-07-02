/*
Created By: Accenture 
Purpose: This class creates community user when Loyalty Email Date sent is populated at consumer level
		 This class updates the email of the user record when email is changed at consumer level. 
         Both of these actions are initiated by Process Builder.
*/
public class CommunityUsersFactory {
     
    public static BOOLEAN ISRUNNING = false;
    @InvocableMethod(label='Consumer_NewUser_EmailChange' description='Method will check whether to create new User or to update existing User')
    public static List<Account> Consumer_NewUser_EmailChange(List<Account> lstAccount) {
        
        List<Account> lstAcc = new List<Account>();
        lstAcc = [SELECT ID,PERSONEMAIL, FirstName,LastName,ISCUSTOMERPORTAL,Opt_out_URL__c,Opt_in_URL__c,EXTERNAL_ID__C
                            FROM ACCOUNT
                            WHERE ID IN : new Map<Id,Account>(lstAccount).keyset()];
        if(!ISRUNNING){
            ISRUNNING = TRUE;
            
            Set<Id> setConsumerEmailChange = new Set<Id>();
            List<Account> lstNewUser_Consumer = new List<Account>();
            List<Account> lstNewUserEmailChange_Consumer = new List<Account>();
            
            if(lstAcc!=null){
                for(Account acc : lstAcc){
                    if(acc.IsCustomerPortal){
                        setConsumerEmailChange.add(acc.Id);     
                        lstNewUserEmailChange_Consumer.add(acc);
                    }else{
                        lstNewUser_Consumer.add(acc);
                    }
                    
                }
                if(lstNewUser_Consumer!=null && !lstNewUser_Consumer.isEmpty()){
                    createUser(lstNewUser_Consumer);    
                }
                
                if(setConsumerEmailChange!=null && !setConsumerEmailChange.isEmpty()){

                    	updateUserEmailAddress(setConsumerEmailChange);
                   
                    
                }
                
                if(lstNewUserEmailChange_Consumer!=null && !lstNewUserEmailChange_Consumer.isEmpty()){
                    try{
                    update ConsumerAttributes.generateOPTURLS(lstNewUserEmailChange_Consumer);
                    
                    }catch(Exception ex){
                    }        
                }
                
            }       
        }
        return null;
    }
    /*
    This is a future method which updates the email address at the user level when address is changed at the account level.
	This method received set of account ids and populates the email address for those account records in their corresponding 
	community record . 
	This method also updates the username for those community users
	*/
    @future
    public static void updateUserEmailAddress(Set<Id> setAccountId) {
        List<User> lstUser = [SELECT ID,EMAIL,USERNAME,isactive, ACCOUNTID,ACCOUNT.PERSONEMAIL FROM USER WHERE ACCOUNTID IN : setAccountId];
        
        for(User usr : lstUser){
            
            usr.Email =  usr.account.PersonEmail.trim();
            usr.userName  = usr.account.PersonEmail.trim() + Label.DECommunityUserNamePostFix;
            if(lstUser!=null){
                try{
                    if(!usr.Email.contains(Label.mskEmail) ){
                		update lstUser;  
                    }
                }catch(Exception ex){
                    
                }
                
            }
        }    
     }
    /*This method create community users for consumer records received as part of the parameter.*/
    public static List<ID> createUser(List<Account> lstAccounts) {
        List<Id> userId = new List<Id>();
        List<User> lstUsers = new List<User>();
        
        Map<Id,Id> mapAccountContactId  = new Map<Id,Id>();
        Map<String,Profile> mapProfile  = new Map<String,Profile>();
        
        mapAccountContactId = DELoyaltyCommunityHelper.mapAccountContactId(lstAccounts);
        mapProfile =  DELoyaltyCommunityHelper.mapProfileDetail(new Set<String> {Label.DECommunityProfile});
        
        for(Account acc: lstAccounts){
            User usr = new User();
            if(mapAccountContactId!= null && mapAccountContactId.containsKey(acc.Id) 
                        &&  mapAccountContactId.get(acc.Id)!= null && mapProfile!=null && 
                                mapProfile.containsKey(Label.DECommunityProfile) && mapProfile.get(Label.DECommunityProfile)!=null){
                usr.FirstName = acc.FirstName;
                usr.LastName = acc.LastName;
                usr.EmailEncodingKey = Label.EmailEncodingKey;
                usr.userName = acc.PersonEmail + Label.DECommunityUserNamePostFix;
                usr.Email = acc.PersonEmail;
                                    
                String nickname = ((acc.firstname != null && acc.firstname.length() > 0) ? acc.firstname.substring(0,1) : '' ) + acc.lastname.substring(0,1);

                nickname += createRandomDigits(7);
                usr.CommunityNickname = nickname;
              
                usr.alias = ((acc.firstname != null && acc.firstname.length() > 0) ? acc.firstname.substring(0,1) : '' ) + acc.lastname.substring(0,1);
                usr.EmailPreferencesAutoBcc = true;
                usr.EmailPreferencesAutoBccStayInTouch = false;
                usr.EmailPreferencesStayInTouchReminder = false;
                usr.LanguageLocaleKey = Label.LanguageLocaleKey;
                usr.LocaleSidKey = Label.LocaleSidKey;
                usr.TimeZoneSidKey = Label.TimeZoneSidKey;
                usr.ContactId = mapAccountContactId.get(acc.Id);
                usr.profileId = mapProfile.get(Label.DECommunityProfile).Id;
				lstUsers.add(usr);
            }    
     	}
        
        try{
            Database.insert(lstUsers, false);
            // Using System.resetPassword here in order to receive the  email with a link to set a password
            // the email template is used for both : setting password after creation & for resetting the password when the password is forgotten
            for(User u : lstUsers){
                System.resetPassword(u.Id, true);
            }
            userId.add(lstUsers[0].AccountId);
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
        
  
    return userId;
  }
    
    public static String createRandomDigits(Integer numberOfDigit) {
        Integer count = Crypto.getRandomInteger();
        while (String.valueOf(count).length() < numberOfDigit) {
            count = Crypto.getRandomInteger();
        }
        return String.valueOf(count).substring(1,numberOfDigit);
    }
}