/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class MdCCommunitiesLandingController {

    public PageReference forwardToStartPage() {

        PageReference pageRef = new PageReference(Label.MdCLandingPageAfterPasswordSet);
        return pageRef;
       // return Network.communitiesLanding();
    }
    
    public MdCCommunitiesLandingController() {}
}