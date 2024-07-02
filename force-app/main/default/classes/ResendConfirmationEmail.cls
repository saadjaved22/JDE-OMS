public without sharing class ResendConfirmationEmail {
    public Id Id { get; set; }
    public Account accRecord {get;set;}

    public ResendConfirmationEmail(ApexPages.StandardController controller) {
        accRecord =  (Account) controller.getRecord();
        Id = accRecord.Id;

    }

    public PageReference ResendEmail() {
        
        LightningSelfRegisterController.sendConfirmationEmail(Id);
        PageReference pageRef = new PageReference('/'+Id);
        pageRef.setRedirect(true);
        return pageRef; 
    }
}