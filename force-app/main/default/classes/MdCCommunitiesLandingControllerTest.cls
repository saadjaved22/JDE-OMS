@isTest
public class MdCCommunitiesLandingControllerTest {
  @isTest
  static void testCommunitiesLandingController() {
    MdCCommunitiesLandingController controller = new MdCCommunitiesLandingController();
    PageReference pageRef = controller.forwardToStartPage();
    System.debug(pageRef);
  }
}
