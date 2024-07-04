/**
 * REST endpoint to allow linking Account with Campaign
 *
 * @author piotr.tugeman@emark.com
 */
@RestResource(urlMapping='/v1/linkAccountCampaign')
global with sharing class LinkAccountCampaignRESTResource {
  public static final String SUCCESS_LINKED = 'Account and Campaign linked.';
  public static final String SUCCESS_STATUS_UPDATED = 'Account and Campaign already linked. Updating status and preference.';
  public static final String ERROR_INSUFFICIENT_DATA = 'Can\'t link Account with Campaign - insufficient incoming data. Missing field from request: ';
  public static final String ERROR_ACCOUNT_DOES_NOT_EXIST = 'Can\'t link Account with Campaign. Account does not exist. Account from request: ';
  public static final String ERROR_CAMPAIGN_DOES_NOT_EXIST = 'Can\'t link Account with Campaign. Campaign does not exist. Campaign from request: ';

  /*
	@HttpGet
	global static List<Campaign> getAllCampaigns() {
		return CampaignSelector.getAllCampaignsWithMembers();
	}*/

  @HttpPost
  global static FullResponse linkAccountWithCampaign() {
    RestRequest request = RestContext.request;
    System.debug(
      'Incoming request uri: ' +
        request.requestURI +
        ' parh:' +
        request.resourcePath +
        'headers:' +
        request.headers +
        ' body: ' +
        request.requestBody
    );
    FullRequest parsedRequest = readDataFrom(request);
    system.debug('parsedRequest' + parsedRequest);
    Account account = findAccountInDatabase(parsedRequest.account);
    Campaign campaign = findCampaignInDatabase(parsedRequest.campaign);

    CampaignMember existingCampaignMember = checkIfLinked(account, campaign);
    String newStatus = getMemberStatus(parsedRequest);
    String preference = getMemberPreference(parsedRequest);

    FullResponse response;
    // update:
    if (null != existingCampaignMember) {
      existingCampaignMember = updateCampaignMemberStatus(
        existingCampaignMember,
        newStatus,
        preference
      );

      System.debug(
        'Account with ExternalID=[' +
          account.External_Id__c +
          '] was already linked with Campaign=[' +
          campaign.Id +
          ']. Updating status. CampaginMember=' +
          existingCampaignMember
      );
      response = generateResponse(
        account,
        existingCampaignMember,
        SUCCESS_STATUS_UPDATED
      );
    }
    // linking:
    else {
      CampaignMember createdMember = link(
        account,
        campaign,
        newStatus,
        preference
      );

      System.debug(
        'Account with ExternalID=[' +
          account.External_Id__c +
          '] was linked with Campaign=[' +
          campaign.Id +
          ']'
      );
      response = generateResponse(account, createdMember, SUCCESS_LINKED);
    }

    System.debug('Sending response: ' + response);
    return response;
  }

  private static FullRequest readDataFrom(RestRequest request) {
    String requestBody = request.requestBody.toString();
    FullRequest fullRequest = (FullRequest) JSON.deserialize(
      requestBody,
      FullRequest.class
    );

    checkMandatoryFields(fullRequest);

    return fullRequest;
  }

  private static void checkMandatoryFields(FullRequest fullRequest) {
    RESTRequestAccount account = fullRequest.account;
    system.debug('account' + account);
    system.debug('account' + account.externalId);
    if (String.isEmpty(account.externalId)) {
      throw new CalloutException(
        ERROR_INSUFFICIENT_DATA + 'account.externalId=' + account.externalId
      );
    }

    RESTRequestCampaign campaign = fullRequest.campaign;

    if (String.isEmpty(campaign.externalId)) {
      throw new CalloutException(
        ERROR_INSUFFICIENT_DATA + 'campaign.externalId=' + campaign.externalId
      );
    }
  }

  private static Account findAccountInDatabase(RESTRequestAccount restAccount) {
    String externalId = restAccount.externalId;

    Account existingAccount = AccountSelector.getAccountByExternalId(
      externalId
    );

    if (null == existingAccount) {
      throw new CalloutException(ERROR_ACCOUNT_DOES_NOT_EXIST + restAccount);
    }

    return existingAccount;
  }

  private static Campaign findCampaignInDatabase(
    RESTRequestCampaign restCampaign
  ) {
    String externalId = restCampaign.externalId;

    Campaign existingCampaign = CampaignSelector.getCampaignByExternalId(
      externalId
    );

    if (null == existingCampaign) {
      throw new CalloutException(ERROR_CAMPAIGN_DOES_NOT_EXIST + restCampaign);
    }

    return existingCampaign;
  }
  private static CampaignMember checkIfLinked(
    Account account,
    Campaign campaign
  ) {
    String campaignId = campaign.Id;
    String contactId = account.PersonContactId;

    CampaignMember existingMember = CampaignSelector.getCampaignMember(
      campaignId,
      contactId
    );

    return existingMember;
  }

  private static String getMemberStatus(FullRequest fullResponse) {
    String status = fullResponse.campaign.memberStatus;

    return status;
  }

  private static String getMemberPreference(FullRequest fullResponse) {
    String preference = fullResponse.campaign.preference;

    return preference;
  }

  private static CampaignMember updateCampaignMemberStatus(
    CampaignMember campaignMember,
    String status,
    String preference
  ) {
    campaignMember.Status = status;
    campaignMember.Preference__c = preference;
    upsert campaignMember;

    // check real status after insertion:
    CampaignMember updatedMember = CampaignSelector.getCampaignMember(
      campaignMember.CampaignId,
      campaignMember.ContactId
    );

    return updatedMember;
  }

  private static CampaignMember link(
    Account account,
    Campaign campaign,
    String status,
    String preference
  ) {
    CampaignMember member = new CampaignMember();
    member.ContactId = account.PersonContactId;
    member.CampaignId = campaign.Id;
    member.Status = status;
    member.Preference__c = preference;
    insert member;

    // check real status after insertion:
    CampaignMember insertedMember = CampaignSelector.getCampaignMember(
      member.CampaignId,
      member.ContactId
    );

    return insertedMember;
  }

  private static FullResponse generateResponse(
    Account account,
    CampaignMember campaignMember,
    String message
  ) {
    FullResponse response = new FullResponse();

    RESTResponseAccount responseAccount = new RESTResponseAccount();
    responseAccount.externalId = account.External_Id__c;

    RESTResponseCampaign responseCampaign = new RESTResponseCampaign();
    Campaign campaign = CampaignSelector.getCampaignById(
      campaignMember.CampaignId
    );
    responseCampaign.externalId = campaign.External_Id__c;
    responseCampaign.memberStatus = campaignMember.Status;
    responseCampaign.preference = campaignMember.Preference__c;

    response.account = responseAccount;
    response.campaign = responseCampaign;
    response.success = true;
    response.message = message;

    return response;
  }

  //==========Inner classes used for serialization/deserialization of request/response bodies =========================================
  public class FullRequest {
    private RESTRequestAccount account;
    private RestRequestCampaign campaign;
  }

  public class RESTRequestAccount {
    private String externalId;
  }

  public class RESTRequestCampaign {
    private String externalId;
    private String memberStatus;
    private String preference;
  }

  global class FullResponse {
    public Boolean success;
    public String message;
    public RESTResponseAccount account;
    public RESTResponseCampaign campaign;
  }

  public class RESTResponseAccount {
    public String externalId;
  }

  public class RESTResponseCampaign {
    public String externalId;
    public String memberStatus;
    public String preference;
  }
}
