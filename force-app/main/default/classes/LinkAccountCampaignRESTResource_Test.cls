/**
* @author piotr.tugeman@emark.com
*/
@isTest
public with sharing class LinkAccountCampaignRESTResource_Test {

    @testSetup
    static void beforeEachTest(){

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

        testAccounts.add( account1 );
        testAccounts.add( account2 );
        testAccounts.add( account3 );

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
        
        testCampaigns.add( campaign1 );
        testCampaigns.add( campaign2 );
        testCampaigns.add( campaign3 );

        Test.startTest();

        insert testAccounts;
        insert testCampaigns;

        // 1st Account as Campaign1 member; 2nd and 3rd Account as Campaign2 member; Campaign3 without members;
        List<CampaignMember> testMembers = new List<CampaignMember>();
        
        Account account1withPersonContact = [Select PersonContactId From Account Where Id = :account1.Id];
        CampaignMember member1 = new CampaignMember();
        member1.CampaignId = campaign1.Id;
        member1.ContactId = account1withPersonContact.PersonContactId;

        Account account2withPersonContact = [Select PersonContactId From Account Where Id = :account2.Id];
        CampaignMember member2 = new CampaignMember();
        member2.CampaignId = campaign2.Id;
        member2.ContactId = account2withPersonContact.PersonContactId;

        Account account3withPersonContact = [Select PersonContactId From Account Where Id = :account3.Id];
        CampaignMember member3 = new CampaignMember();
        member3.CampaignId = campaign2.Id;
        member3.ContactId = account3withPersonContact.PersonContactId;

        testMembers.add( member1 );
        testMembers.add( member2 );
        testMembers.add( member3 );

        insert testMembers;

        Test.stopTest();
    }

    @isTest 
    static void test_linkAccountWithCampaign_error_insuficient_data_no_brand() {
        // setup:
        Campaign campaign1 = [Select Id From Campaign Where Name = 'FirstCampaign']; // existing campaign @see beforeEachTest()
        // account without required field (no brand):
        mockPOSTRequest('{"account":{"country":"NL", "email":"existing@email.com"}, "campaign":{"id":"' + campaign1.Id + '", "memberStatus": "gold"} }');

        // under test:
        try{
            LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
            // assertions:
            System.assert(false, 'Exception should be thrown and this line should never be reached');
        }
        catch( CalloutException ce ){
            System.assert(ce.getMessage().contains(LinkAccountCampaignRESTResource.ERROR_INSUFFICIENT_DATA), 'Exception should have appropriate message=' + ce.getMessage());
            List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
            System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created');
            List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
            System.assertEquals( 1, campaignsMembersAfter.size(), 'There should be still 1 CampaignMember on requested campaig. No new members');
        }
        catch (Exception e){
            System.assert(false, 'CalloutException should be thrown and this line should never be reached. e=' + e);
        }
    }

    @isTest 
    static void test_linkAccountWithCampaign_error_insuficient_data_no_country() {
        // setup:
        Campaign campaign1 = [Select Id From Campaign Where Name = 'FirstCampaign']; // existing campaign @see beforeEachTest()
        // account without required field (no country):
        mockPOSTRequest('{"account":{"brand":"Jacobs", "email":"existing@email.com"}, "campaign":{"id":"' + campaign1.Id + '", "memberStatus": "gold"} }');

        // under test:
        try{
            LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
            // assertions:
            System.assert(false, 'Exception should be thrown and this line should never be reached');
        }
        catch( CalloutException ce ){
            System.assert(ce.getMessage().contains(LinkAccountCampaignRESTResource.ERROR_INSUFFICIENT_DATA), 'Exception should have appropriate message=' + ce.getMessage());
            List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
            System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created');
            List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
            System.assertEquals( 1, campaignsMembersAfter.size(), 'There should be still 1 CampaignMember on requested campaig. No new members');
        }
        catch (Exception e){
            System.assert(false, 'CalloutException should be thrown and this line should never be reached. e=' + e);
        }
    }

    @isTest 
    static void test_linkAccountWithCampaign_error_insuficient_data_no_email() {
        // setup:
        Campaign campaign1 = [Select Id From Campaign Where Name = 'FirstCampaign']; // existing campaign @see beforeEachTest()
        // account without required field (no email):
        mockPOSTRequest('{"account":{"brand":"Jacobs", "country":"UK"}, "campaign":{"id":"' + campaign1.Id + '", "memberStatus": "gold"} }');

        // under test:
        try{
            LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
            // assertions:
            System.assert(false, 'Exception should be thrown and this line should never be reached');
        }
        catch( CalloutException ce ){
            System.assert(ce.getMessage().contains(LinkAccountCampaignRESTResource.ERROR_INSUFFICIENT_DATA), 'Exception should have appropriate message=' + ce.getMessage());
            List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
            System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created');
            List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
            System.assertEquals( 1, campaignsMembersAfter.size(), 'There should be still 1 CampaignMember on requested campaig. No new members');
        }
        catch (Exception e){
            System.assert(false, 'CalloutException should be thrown and this line should never be reached. e=' + e);
        }
    }

    @isTest 
    static void test_linkAccountWithCampaign_error_insuficient_data_no_campaign_id() {
        // setup:
        Campaign campaign1 = [Select Id From Campaign Where Name = 'FirstCampaign']; // existing campaign @see beforeEachTest()
        // account without required field (no campaign id):
        mockPOSTRequest('{"account":{"brand":"Jacobs", "country":"NL", "email":"existing@email.com"}, "campaign":{"memberStatus": "gold"} }');

        // under test:
        try{
            LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
            // assertions:
            System.assert(false, 'Exception should be thrown and this line should never be reached');
        }
        catch( CalloutException ce ){
            System.assert(ce.getMessage().contains(LinkAccountCampaignRESTResource.ERROR_INSUFFICIENT_DATA), 'Exception should have appropriate message=' + ce.getMessage());
            List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
            System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created');
            List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
            System.assertEquals( 1, campaignsMembersAfter.size(), 'There should be still 1 CampaignMember on requested campaig. No new members');
        }
        catch (Exception e){
            System.assert(false, 'CalloutException should be thrown and this line should never be reached. e=' + e);
        }
    }

    @isTest 
    static void test_linkAccountWithCampaign_error_insuficient_data_no_member_status() {
        // setup:
        Campaign campaign1 = [Select Id From Campaign Where Name = 'FirstCampaign']; // existing campaign @see beforeEachTest()
        // account without required field (no campaign member status):
        mockPOSTRequest('{"account":{"brand":"Jacobs", "country":"NL", "email":"existing@email.com"}, "campaign":{"id":"' + campaign1.Id + '"} }');

        // under test:
        try{
            LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
            // assertions:
            System.assert(false, 'Exception should be thrown and this line should never be reached');
        }
        catch( CalloutException ce ){
            System.assert(ce.getMessage().contains(LinkAccountCampaignRESTResource.ERROR_INSUFFICIENT_DATA), 'Exception should have appropriate message=' + ce.getMessage());
            List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
            System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created');
            List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
            System.assertEquals( 1, campaignsMembersAfter.size(), 'There should be still 1 CampaignMember on requested campaig. No new members');
        }
        catch (Exception e){
            System.assert(false, 'CalloutException should be thrown and this line should never be reached. e=' + e);
        }
    }

    @isTest 
    static void test_linkAccountWithCampaign_error_account_does_not_exist() {
        // setup:
        Campaign campaign1 = [Select Id, External_Id__c From Campaign Where Name = 'FirstCampaign']; // existing campaign @see beforeEachTest()
        // non existing account:
        mockPOSTRequest('{"account":{"externalId":"nonexistingg@email.comNLSenseo"}, "campaign":{"externalId":"' + campaign1.External_Id__c + '", "memberStatus": "gold"} }');

        // under test:
        try{
            LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
            // assertions:
            System.assert(false, 'Exception should be thrown and this line should never be reached');
        }
        catch( CalloutException ce ){
            System.assert(ce.getMessage().contains(LinkAccountCampaignRESTResource.ERROR_ACCOUNT_DOES_NOT_EXIST), 'Exception should have appropriate message=' + ce.getMessage());
            List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
            System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created ce=' + ce);
            List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
            System.assertEquals( 1, campaignsMembersAfter.size(), 'There should be still 1 CampaignMember on requested campaig. No new members');
        }
        catch (Exception e){
            System.assert(false, 'CalloutException should be thrown and this line should never be reached. e=' + e);
        }
    }

    @isTest 
    static void test_linkAccountWithCampaign_error_campaign_does_not_exist() {
        // setup:
        // non existing campaign Id:
        mockPOSTRequest('{"account":{"externalId":"existing@email.comNLJacobs"}, "campaign":{"externalId":"123123123", "memberStatus": "gold"} }');

        // under test:
        try{
            LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
            // assertions:
            System.assert(false, 'Exception should be thrown and this line should never be reached');
        }
        catch( CalloutException ce ){
            System.assert(ce.getMessage().contains(LinkAccountCampaignRESTResource.ERROR_CAMPAIGN_DOES_NOT_EXIST), 'Exception should have appropriate message=' + ce.getMessage());
            List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
            System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created ce=' + ce);
            List<Campaign> campaignsAfter = CampaignSelector.getAllCampaignsWithMembers();
            System.assertEquals( 3, campaignsAfter.size(), 'There should be still 3 Campaigns. No new campaigns created');
        }
        catch (Exception e){
            System.assert(false, 'CalloutException should be thrown and this line should never be reached. e=' + e);
        }
    }

    @isTest 
    static void test_linkAccountWithCampaign_update_status_when_already_linked() {
        // setup:
        //existing campaign:
        Campaign campaign1 = [Select External_Id__c From Campaign Where Name = 'FirstCampaign'];
        String newStatus = 'Responded';
        // existing account already linked to campaign:
        mockPOSTRequest('{"account":{"externalId":"existing@email.comNLJacobs"}, "campaign":{"externalId":"'
            + campaign1.External_Id__c + '", "memberStatus": "'+ newStatus +'"} }');

        // under test:
        LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();
        
        // assertions:
        System.assertEquals(true, response.success, 'Response should be successfull');
        System.assertEquals(LinkAccountCampaignRESTResource.SUCCESS_STATUS_UPDATED, response.message, 'Response should have appropriate message=' + response.message);
        System.assert( null != response.account, 'Response should contain Account information');
        System.assert( null != response.campaign, 'Response should contain Campaign information');

        List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
        System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created');
        List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
        System.assertEquals( 1, campaignsMembersAfter.size(), 'There should be still 1 CampaignMember on requested campaig. No new members');
        System.assertEquals( newStatus, campaignsMembersAfter[0].Status, 'Status after update should be equal to one from request');
    }

    @isTest 
    static void test_linkAccountWithCampaign_link_account_with_campaign() {
        // setup:
        //existing campaign:
        Campaign campaign1 = [Select Id, External_Id__c From Campaign Where Name = 'FirstCampaign'];
        String existingCampaignExternalId = campaign1.External_Id__c;
        String newStatus = 'Responded';
        // existing account not linked to any campaign:
        mockPOSTRequest('{"account":{ "externalId":"existing@email.comUKSenseo" }, "campaign":{"externalId":"'
            + existingCampaignExternalId + '", "memberStatus": "'+ newStatus +'"} }');

        // under test:
        LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();

        // assertions:
        System.assertEquals(true, response.success, 'Response should be successfull');
        System.assertEquals(LinkAccountCampaignRESTResource.SUCCESS_LINKED, response.message, 'Response should have appropriate message=' + response.message);
        System.assert( null != response.account, 'Response should contain Account information');
        System.assert( null != response.campaign, 'Response should contain Campaign information');

        List<Account> accountsAfter = AccountSelector.getAllAccountsBusinessRelevantFields();
        System.assertEquals( 3, accountsAfter.size(), 'There should be 3 accounts - no new account created');
        List<CampaignMember> campaignsMembersAfter = CampaignSelector.getAllCampaignMembers( campaign1.Id );
        System.assertEquals( 2, campaignsMembersAfter.size(), 'There should be 2 CampaignMembers on requested campaig. One new and one old');
        Account accountAfter = AccountSelector.getAccountByExternalId('existing@email.comUKSenseo');
        String contactId = accountAfter.PersonContactId;
        CampaignMember memberAfter = CampaignSelector.getCampaignMember( campaign1.Id, contactId);
        System.assert(null != memberAfter, 'CampaignMember should be found after insertion');
        System.assertEquals( newStatus, memberAfter.Status, 'Status after update should be equal to one from request');
    }

    @isTest 
    static void test_linkAccountWithCampaign_success_response_fields() {
        // setup:
        //existing campaign:
        Campaign campaign1 = [Select Id, External_Id__c From Campaign Where Name = 'FirstCampaign'];
        String accountExternalId = 'existing@email.comUKSenseo';
        String existingCampaignExternalId = campaign1.External_Id__c;
        String memberStatus = 'Responded';
        // existing account not linked to any campaign:
        mockPOSTRequest('{"account":{ "externalId":"'+ accountExternalId 
            +'" }, "campaign":{"externalId":"' + existingCampaignExternalId 
            + '", "memberStatus": "'+ memberStatus +'"} }');

        // under test:
        LinkAccountCampaignRESTResource.FullResponse response = LinkAccountCampaignRESTResource.linkAccountWithCampaign();

        // assertions:
        System.assertEquals(true, response.success, 'Response should be successfull.');
        System.assertEquals(LinkAccountCampaignRESTResource.SUCCESS_LINKED, response.message, 'Response should have appropriate message=' + response.message);
        System.assert( null != response.account, 'Response should contain Account information.');
        System.assert( null != response.account.externalId, 'Response should contain Account.ExternalId.');
        System.assertEquals( accountExternalId, response.account.externalId, 'Response Account.ExternalId should equal Account externalId from setup.');
        System.assert( null != response.campaign, 'Response should contain Campaign information.');
        System.assert( null != response.campaign.externalId, 'Response should contain Campaign.ExternalId information.');
        System.assertEquals( existingCampaignExternalId, response.campaign.externalId, 'Response Campaign.ExternalId should equal id from setup.');
        System.assert( null != response.campaign.memberStatus, 'Response should contain Campaign.memberStatus information.');
        System.assertEquals( memberStatus, response.campaign.memberStatus, 'Response Campaign.memberStatus should equal id from setup.');

    }

    private static void mockPOSTRequest(String jsonRequestBody){

        RestRequest request = new RestRequest();

        //for the purpose of testing, url and headers are not required
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonRequestBody);

        RestContext.request = request;
    }
}