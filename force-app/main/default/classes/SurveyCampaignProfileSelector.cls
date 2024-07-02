/**
* All Survey Campaign Profile related SOQL queries
*
* @author tim.dirckx@emark.com
*/
public with sharing class SurveyCampaignProfileSelector {
    
    public static List<Survey_Campaign_Profile__c> findUnique(String campaignProfileId, Id campaignId, Id personContactId) {
        return [SELECT Id FROM Survey_Campaign_Profile__c WHERE campaignprofileid__c = :campaignProfileId AND CampaignId__c = :campaignId AND ContactId__c = :personContactId];
    }
}