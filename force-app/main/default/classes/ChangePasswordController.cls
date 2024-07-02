/**
 * An apex page controller that exposes the change password functionality
 Modified By: Accenture 
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}  
    public Boolean isDECommunity {get;set;}
    public Boolean isChangePasswordRequest {get;set;}
    public string pageName {get;set;}  
    public Boolean isValidPassword {get; set;}

    /*
	Modified By: Accenture
	Changes: Method is modified to support JDE 'DE Community' specific business requiements. 
	         This method will throw error in Dutch for Dutch Locale Users.
	*/
    public PageReference changePassword() {
       
        if(isDECommunity){     
            if(!isChangePasswordRequest && string.isBlank(oldPassword)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.OldPasswordBlank));
                return null;
            }
        	if(string.isBlank(newPassword)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.NewPasswordBlank));
                return null;
            }
            if(string.isBlank(verifyNewPassword )){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.VerifyPasswordEmpty));
                return null;
            }
            if(newPassword!=verifyNewPassword ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.PasswordMisMatch));
                return null;
            }
            if(newPassword.length() < 8){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.PasswordMinimumCriteria));
                return null;
            } 
            
            if(newPassword.isNumeric()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.PasswordMinimumCriteria));
                return null;
            }
            
            if(newPassword.isAlpha()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, Label.PasswordMinimumCriteria));
                return null;
            }    
        }
       
       PageReference pg = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
		//PageReference redirect = new PageReference('https://denl-acc2.jdecoffee.net/');
        return pg;
        //return redirect;   
        
     

    }     
    
     /*
	Modified By: Accenture
	Changes: Controller Method is modified to support JDE 'DE Community' specific business requiements. 
	         It behaves differently depending upon whether request is change password or forget password
			
	*/    
    public ChangePasswordController(){
        
        DateTime expirationDate = UserPasswordChangeDate.checkLastPasswordChangeDate(UserInfo.getUserID());
        if(expirationDate != null){
        	if(expirationDate > DateTime.now()){
            	isValidPassword = true;
         	}
        }
        
        isChangePasswordRequest = false;   
        isDECommunity = false;
        string isChangePassword = ApexPages.CurrentPage().getParameters().get('setupid');
        
        if(string.isBlank(pageName)){
        	pageName = ApexPages.CurrentPage().getUrl();     
        }
        if(pageName.toUpperCase().contains('DECommunityChangePassword'.toUpperCase())){
        	isDECommunity = true;
            if(string.isNotBlank(isChangePassword) && isChangePassword.equals('ChangePassword')){
                isChangePasswordRequest = true;
        	}
    	}
	}
}