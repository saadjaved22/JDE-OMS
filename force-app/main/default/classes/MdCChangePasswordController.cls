public with sharing class MdCChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}  
    public Boolean isChangePasswordRequest {get;set;}
    
    public PageReference changePassword() {
        if(!isChangePasswordRequest && string.isBlank(oldPassword)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Entrez l\'ancien mot de passe'));
            return null;
        }
        if(string.isBlank(newPassword)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Entrez un nouveau mot de passe'));
            return null;
        }
        if(string.isBlank(verifyNewPassword )){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Répétez votre nouveau mot de passe'));
            return null;
        }
        if(newPassword!=verifyNewPassword ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Les deux mots de passe ne sont pas les mêmes'));
            return null;
        }
        if(newPassword.length() < 8){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Votre mot de passe doit contenir au moins 8 caractères, dont 1 lettre et 1 chiffre'));
            return null;
        } 
        if(newPassword.isNumeric()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Votre mot de passe doit contenir au moins 8 caractères, dont 1 lettre et 1 chiffre'));
            return null;
        }
        if(newPassword.isAlpha()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Votre mot de passe doit contenir au moins 8 caractères, dont 1 lettre et 1 chiffre.'));
            return null;
        }
        
        PageReference pg = Site.changePassword(newPassword, verifyNewPassword, oldpassword); 
		PageReference redirect = new PageReference('http://www.maisonducafe.com/');
        return redirect;
    }
    
    public MdCChangePasswordController() {
        this.isChangePasswordRequest = false;
        String isChangePassword = ApexPages.CurrentPage().getParameters().get('setupid');
        if(String.isNotBlank(isChangePassword) && isChangePassword.equals('ChangePassword')){
            this.isChangePasswordRequest = true;
        }
	}
}