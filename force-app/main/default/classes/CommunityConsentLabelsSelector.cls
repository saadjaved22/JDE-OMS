public class CommunityConsentLabelsSelector {
  public static List<Community_Consent_Label__mdt> getCommunityConsentLabelsForCommunity(
    String communityName,
    String country
  ) {
    return [
      SELECT
        Id,
        DeveloperName,
        Label,
        Consent_Text_1__c,
        Consent_Text_2__c,
        Consent_Text_3__c,
        Consent_Text_Version__c,
        Privacy_Policy_URL__c,
        Privacy_Policy_Label__c,
        Privacy_Policy_Version__c,
        Country__c
      FROM Community_Consent_Label__mdt
      WHERE Label = :communityName AND Country__c = :country
    ];
  }

  public static Map<String, Community_Consent_Label__mdt> getCommunityConsentLabels() {
    List<Community_Consent_Label__mdt> consentLabels = [
      SELECT
        Id,
        DeveloperName,
        Label,
        Consent_Text_1__c,
        Consent_Text_2__c,
        Consent_Text_3__c,
        Consent_Text_Version__c,
        Privacy_Policy_URL__c,
        Privacy_Policy_Label__c,
        Privacy_Policy_Version__c,
        Country__c
      FROM Community_Consent_Label__mdt
    ];

    Map<String, Community_Consent_Label__mdt> consentLabelsByName = new Map<String, Community_Consent_Label__mdt>();
    for (Community_Consent_Label__mdt consentLabel : consentLabels) {
      consentLabelsByName.put(consentLabel.Label, consentLabel);
    }

    return consentLabelsByName;
  }
}
