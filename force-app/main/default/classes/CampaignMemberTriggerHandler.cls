/**
* handler for CampaignMemberTrigger .
*
* @author piotr.tugeman@emark.com

History
    @Fixed by Wunderman Thompson  09/2022
*/
public class CampaignMemberTriggerHandler {
  public static final String LOYALTY_TRANSACTION_TYPE = 'Campaign Reward';
  public static final String LOYALTY_SOURCE = 'Campaign';

  public static void onBeforeInsert(List<CampaignMember> CampaignMemList) {
    customerAccount(CampaignMemList);
  }

  public static void onBeforeUpdate(List<CampaignMember> CampaignMemList) {
    customerAccount(CampaignMemList);
  }
  public static void customerAccount(List<CampaignMember> CampaignMemList) {
    Set<Id> contId = new Set<Id>();
    for (CampaignMember campMemList : CampaignMemList) {
      contId.add(campMemList.ContactId);
    }
    if (!contId.isEmpty()) {
      Map<Id, Contact> contMap = new Map<Id, Contact>(
        [SELECT Id, AccountId FROM Contact WHERE Id IN :contId]
      );
      for (CampaignMember cMemList : CampaignMemList) {
        if (cMemList.Customer__c == null) {
          try {
            cMemList.Customer__c = contMap.get(cMemList.ContactId).AccountId;
          } catch (Exception e) {
            System.debug('Exception while updating the customer__c field' + e);
          }
        }
      }
    }
  }

  /*
    public static void onAfterInsert( List<CampaignMember> campaignMembers ){
        for ( CampaignMember member: campaignMembers ){
            createLoyaltyTransaction( member );
        }
    }
    
    private static void createLoyaltyTransaction( CampaignMember member ){

        Campaign campaign = CampaignSelector.getCampaignById( member.CampaignId );
        if ( null == campaign ){
            System.debug( 'LoyaltyTransaction NOT created. Campaign does not exist. CampaignMember:' + member );
            return;
        }
        if ( false == campaign.Add_Points__c ){
            System.debug( 'LoyaltyTransaction NOT created. Campaign.Add_Points__c is unchecked (false). CampaignMember:' + member + ' Campaign:' + campaign );
            return;
        }

        //TODO: for which Loyalty when more than one? ANSWER: with matching externalID.
        //TODO: Create Loyalty when not available? ANSWER: No.
        Account account = AccountSelector.getAccountByContactId( member.ContactId );
        Loyalty__c loyalty = LoyaltySelector.getLoyaltyByExternalId( account.External_Id__c );
        
        if ( ! shouldGenerateLoyaltyTransaction( account, loyalty ) ){
            System.debug( 'LoyaltyTransaction NOT created for CampaignMember:' + member );
            return;
        }

        Loyalty_Transaction__c loyaltyTransaction = generateLoyaltyTransaction( loyalty, account, campaign );
        saveLoyaltyTransaction ( loyaltyTransaction );
    }

    private static Boolean shouldGenerateLoyaltyTransaction( Account account, Loyalty__c loyalty ){
        //only for Loyalty type accounts with existing Loyalty:
        if ( null == account ){
            System.debug( 'Account does not exist. Account:' + account );
            return false;
        }
        if ( 'Loyalty' != account.Type__c ){
            System.debug( 'Account type is not \'Loyalty\'. AccountType:' + account.Type__c + ' account:' + account );
            return false;
        }
        if ( null == loyalty ){
            System.debug( 'Loyalty does not exist for account:' + account );
            return false;
        }
        if ( account.External_Id__c != loyalty.External_Id__c){
            System.debug( 'Loyalty externalId does not match account externalId. Loyalty:' + loyalty + ' account:' + account );
            return false;
        }
        return true;
    }

    private static Loyalty_Transaction__c generateLoyaltyTransaction( Loyalty__c loyalty, Account account, Campaign campaign ){
        Loyalty_Transaction__c trans = new Loyalty_Transaction__c();
        trans.Loyalty__c = loyalty.Id;
        trans.Loyalty_Consumer__c = account.Id;
        trans.Loyalty_Transaction_Type__c = CampaignMemberTriggerHandler.LOYALTY_TRANSACTION_TYPE;
        trans.Loyalty_Source__c = CampaignMemberTriggerHandler.LOYALTY_SOURCE;
        trans.Loyalty_Notes_Reference__c = Campaign.External_Id__c;
        // transfer points from campaign:
        // Misleading, but campaign points should be stored in Transaction_Amount__c field (NOT Total_Loyalty_Points__c) 
        // trans.Total_Loyalty_Points__c = 0; // TODO: what is the purpose of this field ?
        Decimal points = 0;
        if ( true == campaign.Add_Points__c ){
            points = campaign.Points_Amount__c;
        }  
        trans.Transaction_Amount__c = points;

        return trans;

    }

    private static void saveLoyaltyTransaction( Loyalty_Transaction__c loyaltyTransaction ){
        insert loyaltyTransaction;
        System.debug( 'LoyaltyTransaction iserted. LoyaltyTransaction:' + loyaltyTransaction );
    } */
}
