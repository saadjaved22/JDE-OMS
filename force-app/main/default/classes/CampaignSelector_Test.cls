/**
 * @author piotr.tugeman@emark.com
 */
@isTest
private class CampaignSelector_Test {
  @testSetup
  static void beforeEachTest() {
    //3 accounts:
    List<Account> testAccounts = new List<Account>();

    Account account1 = new AccountBuilder()
      .setLastName('FirstName')
      .setEmail('existing@email.com')
      .setCountry('NL')
      .setBrand('Jacobs')
      .build();

    Account account2 = new AccountBuilder()
      .setLastName('SecondName')
      .setEmail('existing@email.com')
      .setCountry('UK')
      .setBrand('Jacobs')
      .build();

    Account account3 = new AccountBuilder()
      .setLastName('ThirdName')
      .setEmail('existing@email.com')
      .setCountry('UK')
      .setBrand('Senseo')
      .build();

    testAccounts.add(account1);
    testAccounts.add(account2);
    testAccounts.add(account3);

    // 3 campaigns:
    List<Campaign> testCampaigns = new List<Campaign>();

    Campaign campaign1 = new Campaign();
    campaign1.Name = 'FirstCampaign';
    campaign1.Brand__c = 'Senseo';
    campaign1.Country__c = 'NL';

    Campaign campaign2 = new Campaign();
    campaign2.Name = 'SecondCampaign';
    campaign2.Brand__c = 'Senseo';
    campaign2.Country__c = 'UK';

    Campaign campaign3 = new Campaign();
    campaign3.Name = 'ThirdCampaign_empty';
    campaign3.Brand__c = 'Tassimo';
    campaign3.Country__c = 'NL';

    testCampaigns.add(campaign1);
    testCampaigns.add(campaign2);
    testCampaigns.add(campaign3);

    Test.startTest();

    insert testAccounts;
    insert testCampaigns;

    // 1st Account as Campaign1 member; 2nd and 3rd Account as Campaign2 member; Campaign3 without members;
    List<CampaignMember> testMembers = new List<CampaignMember>();

    Account account1withPersonContact = [
      SELECT PersonContactId
      FROM Account
      WHERE Id = :account1.Id
    ];
    CampaignMember member1 = new CampaignMember();
    member1.CampaignId = campaign1.Id;
    member1.ContactId = account1withPersonContact.PersonContactId;

    Account account2withPersonContact = [
      SELECT PersonContactId
      FROM Account
      WHERE Id = :account2.Id
    ];
    CampaignMember member2 = new CampaignMember();
    member2.CampaignId = campaign2.Id;
    member2.ContactId = account2withPersonContact.PersonContactId;

    Account account3withPersonContact = [
      SELECT PersonContactId
      FROM Account
      WHERE Id = :account3.Id
    ];
    CampaignMember member3 = new CampaignMember();
    member3.CampaignId = campaign2.Id;
    member3.ContactId = account3withPersonContact.PersonContactId;

    testMembers.add(member1);
    testMembers.add(member2);
    testMembers.add(member3);

    insert testMembers;

    Test.stopTest();
  }

  @isTest
  static void test_getAllCampaignMembers_returns_members() {
    // setup
    // existing campaigns @see beforeEachTest()
    Campaign campaign1 = [SELECT Id FROM Campaign WHERE Name = 'FirstCampaign'];
    Campaign campaign2 = [
      SELECT Id
      FROM Campaign
      WHERE Name = 'SecondCampaign'
    ];
    Campaign campaign3 = [
      SELECT Id
      FROM Campaign
      WHERE Name = 'ThirdCampaign_empty'
    ];

    // under test:
    List<CampaignMember> members1 = CampaignSelector.getAllCampaignMembers(
      campaign1.Id
    );
    List<CampaignMember> members2 = CampaignSelector.getAllCampaignMembers(
      campaign2.Id
    );
    List<CampaignMember> members3 = CampaignSelector.getAllCampaignMembers(
      campaign3.Id
    );

    // assertions:
    System.assertEquals(
      1,
      members1.size(),
      'There should be 1 member of this campaign'
    );
    System.assertEquals(
      2,
      members2.size(),
      'There should be 2 member of this campaign'
    );
    System.assert(
      members3.isEmpty(),
      'There should be 0 member of this campaign'
    );
  }

  @isTest
  static void test_getCampaignByExternalId_returns_null() {
    // setup:
    String nonexistingExternalId = 'Brand-Country-Name';

    // under test:
    Campaign campaign = CampaignSelector.getCampaignByExternalId(
      nonexistingExternalId
    );

    //assertion
    System.assertEquals(null, campaign, 'There should be NO campaign returned');
  }

  @isTest
  static void test_getCampaignByExternalId_returns_something() {
    // setup:
    Campaign existingCampaign = [
      SELECT External_Id__c
      FROM Campaign
      WHERE Name = 'FirstCampaign'
    ];

    // under test:
    Campaign campaign = CampaignSelector.getCampaignByExternalId(
      existingCampaign.External_Id__c
    );

    //assertion
    System.assert(
      null != campaign,
      'There should be campaign returned. campaign:' +
        campaign +
        ' existingCampaign:' +
        existingCampaign
    );
    System.assertEquals(
      'FirstCampaign',
      campaign.Name,
      'Returned Campaign Name should be same as in setup'
    );
  }

  @isTest
  static void test_getCampaignById_returns_null() {
    // setup:
    String nonexistingId = 'none';

    // under test:
    Campaign campaign = CampaignSelector.getCampaignById(nonexistingId);

    //assertion
    System.assertEquals(null, campaign, 'There should be NO campaign returned');
  }

  @isTest
  static void test_getCampaignById_returns_something() {
    // setup:
    Campaign existingCampaign = [
      SELECT Id
      FROM Campaign
      WHERE Name = 'FirstCampaign'
    ];

    // under test:
    Campaign campaign = CampaignSelector.getCampaignById(existingCampaign.Id);

    //assertion
    System.assert(null != campaign, 'There should be campaign returned');
    System.assertEquals(
      'FirstCampaign',
      campaign.Name,
      'Returned Campaign Name should be same as in setup'
    );
  }

  @isTest
  static void test_getCampaignMember_returns_null() {
    // setup:
    Campaign existingCampaign = [
      SELECT Id
      FROM Campaign
      WHERE Name = 'FirstCampaign'
    ];
    String existingCampaignId = existingCampaign.Id;
    String nonexistingContactId = '9999x000000179AAA';

    // under test:
    CampaignMember member = CampaignSelector.getCampaignMember(
      existingCampaignId,
      nonexistingContactId
    );

    //assertion
    System.assertEquals(null, member, 'There should be NO campaign returned');
  }

  @isTest
  static void test_getCampaignMember_returns_something() {
    // setup:
    Campaign existingCampaign = [
      SELECT Id
      FROM Campaign
      WHERE Name = 'FirstCampaign'
    ];
    Account existingAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE LastName = 'FirstName'
    ];
    String existingCampaignId = existingCampaign.Id;
    String existingContactId = existingAccount.PersonContactId;

    // under test:
    CampaignMember member = CampaignSelector.getCampaignMember(
      existingCampaignId,
      existingContactId
    );

    //assertion
    System.assert(null != member, 'There should be campaign returned');
    System.assertEquals(
      existingCampaign.Id,
      member.CampaignId,
      'Returned CampaignMember Campaign Id should be same as in setup'
    );
    System.assertEquals(
      existingAccount.PersonContactId,
      member.ContactId,
      'Returned CampaignMember Contact Id should be same as in setup'
    );
  }

  @isTest
  static void test_getAllCampaignsWithMembers_returns_something() {
    // under test:
    List<Campaign> allCampaigns = CampaignSelector.getAllCampaignsWithMembers();

    // assertions:
    System.assertEquals(
      3,
      allCampaigns.size(),
      'There should be 3 campaigns. AllCampaigns=' + allCampaigns
    );
  }
}
