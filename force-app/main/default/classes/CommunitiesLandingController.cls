/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    /*
	Modifed By: Accenture
	Purpose: This method will redirect user to EPI page after successful login
	*/
    public PageReference forwardToStartPage() {

        PageReference pageRef = new PageReference(Label.DELandingPageAfterPasswordSet);
        return pageRef;
        //return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
}