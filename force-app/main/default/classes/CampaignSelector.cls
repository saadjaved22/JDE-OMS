/**
 * All Campaign related SOQL queries.
 *
 * @author piotr.tugeman@emark.com
 */
public with sharing class CampaignSelector {
  // Returns all campaigns with members
  //TODO: is there a need for Members in this response?
  public static List<Campaign> getAllCampaignsWithMembers() {
    List<Campaign> allCampaigns = [
      SELECT
        Id,
        External_Id__c,
        Name,
        Add_Points__c,
        Points_Amount__c,
        (SELECT Id, Email, Country, LastName FROM CampaignMembers)
      FROM Campaign
    ];

    return allCampaigns;
  }

  public static Campaign getCampaignByExternalId(String externalId) {
    List<Campaign> campaigns = [
      SELECT Id, External_Id__c, Name, Add_Points__c, Points_Amount__c
      FROM Campaign
      WHERE External_Id__c = :externalId
    ];

    if (!campaigns.isEmpty() && 1 == campaigns.size()) {
      return campaigns[0];
    } else {
      return null;
    }
  }

  public static Campaign getCampaignById(String campaignId) {
    List<Campaign> campaigns = [
      SELECT Id, External_Id__c, Name, Add_Points__c, Points_Amount__c
      FROM Campaign
      WHERE Id = :campaignId
    ];

    if (!campaigns.isEmpty() && 1 == campaigns.size()) {
      return campaigns[0];
    } else {
      return null;
    }
  }

  public static List<CampaignMember> getAllCampaignMembers(String campaignId) {
    List<CampaignMember> allMembers = [
      SELECT
        Id,
        Email,
        Country,
        LastName,
        Status,
        ContactId,
        CampaignId,
        Preference__c
      FROM CampaignMember
      WHERE CampaignId = :campaignId
    ];

    return allMembers;
  }

  public static CampaignMember getCampaignMember(
    String campaignId,
    String contactId
  ) {
    List<CampaignMember> members = [
      SELECT
        Id,
        Email,
        Country,
        LastName,
        Status,
        ContactId,
        CampaignId,
        campaign.External_Id__c,
        Preference__c
      FROM CampaignMember
      WHERE CampaignId = :campaignId AND ContactId = :contactId
    ];

    if (!members.isEmpty() && 1 == members.size()) {
      return members[0];
    } else {
      return null;
    }
  }
}
