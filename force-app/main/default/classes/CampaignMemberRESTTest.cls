@isTest
global class CampaignMemberRESTTest {
  // Test Class to Test CampaignMemberREST Class - Created for DE265
  // Robbie Schaap 12-12-2018
  @isTest
  static void CampaignMemberRESTTest() {
    test.startTest();
    Account account = new AccountBuilder()
      .setAccountType('Loyalty')
      .setLastName('TestName')
      .build();
    insert account;

    Campaign Camp = new Campaign();
    Camp.Name = 'TEST';
    Camp.Brand__c = 'Senseo';
    Camp.Country__c = 'NL';
    insert Camp;

    test.stopTest();

    Account ACNTEST = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :account.Id
    ];
    CampaignMember CampMem = new CampaignMember();
    CampMem.Status = 'Registered';
    CampMem.ContactId = ACNTEST.PersonContactId;
    CampMem.CampaignId = Camp.id;
    insert CampMem;

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI =
      '/services/apexrest/CampaignMemberGET/CampaignId=' +
      Camp.Id +
      '&ContactId=' +
      ACNTEST.PersonContactId;
    req.addParameter('ContactId', ACNTEST.PersonContactId);
    req.addParameter('CampaignId', Camp.Id);
    req.httpMethod = 'GET';
    req.addHeader('Content-Type', 'application/json');
    RestContext.request = req;
    RestContext.response = res;
    CampaignMemberREST.FullResponse Results = CampaignMemberREST.getCampaignMemberbyCampConId();

    //Success Assertion - Results: Already Member of Campaign
    system.assertEquals(true, Results.success);
    system.assertEquals(
      'Campaign NOT allowed. Consumer ALREADY in Campaign',
      Results.message
    );

    //Delete CampaignMember - Results: Not Yet Member of Campaign
    delete CampMem;
    CampaignMemberREST.FullResponse Results_NYMC = CampaignMemberREST.getCampaignMemberbyCampConId();
    system.assertEquals(true, Results_NYMC.success);
    system.assertEquals(
      'Campaign allowed. Consumer NOT YET in Campaign',
      Results_NYMC.message
    );

    req.requestURI =
      '/services/apexrest/CampaignMemberGET/CampaignId=' +
      ACNTEST.PersonContactId +
      '&ContactId=' +
      ACNTEST.PersonContactId;
    req.addParameter('ContactId', ACNTEST.PersonContactId);
    req.addParameter('CampaignId', Camp.Id);
    req.httpMethod = 'GET';
    req.addHeader('Content-Type', 'application/json');
    RestContext.request = req;
    RestContext.response = res;
    CampaignMemberREST.FullResponse Results_Fault = CampaignMemberREST.getCampaignMemberbyCampConId();

    //Campaign Not found Assertion
    system.assertEquals(false, Results_Fault.success);
    system.assertEquals('Campaign does not exist', Results_Fault.message);
  }
}
