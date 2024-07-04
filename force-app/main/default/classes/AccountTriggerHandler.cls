/*********************************************************************
Name    :       AccountTriggerHandler Trigger
Date    :       20 June 2017
Author  :       Anjerico Caburnay
Description:    Trigger handler of AccountTrigger for Account Object
History :       
*********************************************************************/

public class AccountTriggerHandler {
  //calls all methods Before Insert
  public static void onBeforeInsert(List<Account> accountList) {
    System.debug(accountList + 'BEFOREINSERT');
    checkOptInStatusOnInsert(accountList);
    // lastEmailSentHardBounced(accountList);
    // email hard bounced disabled due to Dave's request 02/11/2022
    checkConsentStatusOnInsert(accountList);
  }

  //calls all methods Before Update
  public static void onBeforeUpdate(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    System.debug(accountList + 'BEFOREUPDATE');
    checkAccountTypeIfLoyaltyThenRemainLoyalty(accountList, oldMap);
    checkOptInStatusOnUpdate(accountList, oldMap);
    // lastEmailSentHardBounced(accountList);
    // email hard bounced disabled due to Dave's request 02/11/2022
    gdprConsumerCleaningRules(accountList);
    maskingAccount(accountList, oldMap);
    sendHighCoRequest(accountList, oldMap);
    checkConsentStatusOnUpdate(accountList, oldMap);
  }

  public static void onBeforeDelete(List<Account> accountList) {
    loyaltyTotalPointsDelete(accountList);
    commercialConsent(accountList);
  }

  public static void onAfterInsert(
    List<Account> accountList,
    Map<Id, Account> oldMap,
    Map<Id, Account> newMap
  ) {
    sendYotpoRequestOnAfterInsert(accountList);
  }

  public static void onAfterUpdate(
    List<Account> accountList,
    Map<Id, Account> oldMap,
    Map<Id, Account> newMap
  ) {
    brewerRegistration(accountList, oldMap);
    createLoyaltyRecord(newMap, oldMap);
    sendYotpoRequestOnAfterUpdate(accountList, oldMap);
  }

  // Global - needed for Tests
  public static List<ConsentSettings__mdt> consentSettings {
    get {
      if (consentSettings == null) {
        consentSettings = [
          SELECT Id, CountryList__c, CompletedBrandList__c
          FROM ConsentSettings__mdt
          ORDER BY Id
          LIMIT 1
        ];
      }
      return consentSettings;
    }
    set;
  }

  public static void brewerRegistration(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Account oAccount : accountList) {
      accountIds.add(oAccount.Id);
    }

    List<Brewer_Registration__C> lstBrewerRegs = [
      SELECT
        Id,
        Customer__c,
        Brand__c,
        Country__c,
        CreatedDate,
        Account_Commercial_Consent__c,
        CLM_Welcome_Mail_Sent__c,
        Person_Account_Email__c,
        Consumer_Country__c
      FROM Brewer_Registration__C
      WHERE Customer__c IN :accountIds
    ];
    Map<Id, List<Brewer_Registration__c>> registrationsByAccount = new Map<Id, List<Brewer_Registration__c>>();

    for (Brewer_Registration__c registration : lstBrewerRegs) {
      if (!registrationsByAccount.containsKey(registration.Customer__c)) {
        registrationsByAccount.put(
          registration.Customer__c,
          new List<Brewer_Registration__c>()
        );
      }
      registrationsByAccount.get(registration.Customer__c).add(registration);
    }

    for (Account oAccount : accountList) {
      if (registrationsByAccount.containsKey(oAccount.Id)) {
        List<Brewer_Registration__c> accountRegistrations = registrationsByAccount.get(
          oAccount.Id
        );
        if (
          oldMap.get(oAccount.Id).Consent_Status__c !=
          oAccount.Consent_Status__c &&
          oAccount.Consent_Status__c == 'Active'
        ) {
          CLMTriggerFlowClass.CLMTriggerFlow(accountRegistrations);
        }
      }
    }
  }

  public static void loyaltyTotalPointsDelete(List<Account> accountList) {
    for (Account acc : accountList) {
      if (acc.Loyalty_Total_Points__c > 0 && acc.Type__c == 'Loyalty') {
        acc.addError('Consumer with Active Loyalty Points cannot be deleted');
      }
    }
  }

  public static void commercialConsent(List<Account> accountList) {
    String profileName = [
      SELECT Name
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
    ]
    .Name;
    for (Account acc : accountList) {
      if (
        profileName != 'JDE DTC Support Agent' &&
        (acc.Consent_Status__c == 'Active' ||
        acc.Consent_Status__c == 'Confirmed')
      ) {
        acc.addError(
          'Consumer with Active or Confirmed consent cannot be deleted'
        );
      }
    }
  }

  //Checks if Opt in Request Date, Opt in Confirmation Date, Opt out Request Date has a value
  //Limitation Note: Intershop will only update one field at a time. So this method will just check one of these three fields
  public static void checkOptInStatusOnInsert(List<Account> accountList) {
    for (Account acc : accountList) {
      if (acc.Opt_in_Request_Date__c != null) {
        acc.Opt_In_Status__c = 'Requested';
        acc.Opt_in_Status_Changed__c = true;
      } else if (acc.Opt_in_Confirmation_Date__c != null) {
        acc.Opt_In_Status__c = 'Confirmed';
        acc.Opt_in_Status_Changed__c = true;
      } else if (acc.Opt_out_Request_Date__c != null) {
        acc.Opt_In_Status__c = 'Opt-out';
        acc.Opt_in_Status_Changed__c = true;
      }
    }
  }

  //Checks if Opt in Request Date, Opt in Confirmation Date, Opt out Request Date is Changed
  //Limitation Note: Intershop will only update one field at a time. So this method will just check one of these three fields
  public static void checkOptInStatusOnUpdate(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    for (Account acc : accountList) {
      if (
        acc.Opt_in_Request_Date__c != null &&
        oldMap.get(acc.Id).Opt_in_Request_Date__c != acc.Opt_in_Request_Date__c
      ) {
        acc.Opt_In_Status__c = 'Requested';
        acc.Opt_in_Status_Changed__c = true;
      } else if (
        acc.Opt_in_Confirmation_Date__c != null &&
        oldMap.get(acc.Id).Opt_in_Confirmation_Date__c !=
        acc.Opt_in_Confirmation_Date__c
      ) {
        acc.Opt_In_Status__c = 'Confirmed';
        acc.Opt_in_Status_Changed__c = true;
      } else if (
        acc.Opt_out_Request_Date__c != null &&
        oldMap.get(acc.Id).Opt_out_Request_Date__c !=
        acc.Opt_out_Request_Date__c
      ) {
        acc.Opt_In_Status__c = 'Opt-out';
        acc.Opt_in_Status_Changed__c = true;
      } else {
        acc.Opt_in_Status_Changed__c = false;
      }
    }
  }

  //Whenever a PersonAccount (all person account record types) is created for all brands. - modified by: angelito.cuello@accenture.com
  public static void checkConsentStatusOnInsert(List<Account> accountList) {
    if (consentSettings.size() > 0) {
      //List<ConsentSettings__mdt> consentSettings = [SELECT Id, CountryList__c, CompletedBrandList__c FROM ConsentSettings__mdt ORDER BY Id LIMIT 1];
      List<String> countryList = (List<String>) JSON.deserialize(
        consentSettings[0].CountryList__c,
        List<String>.class
      );
      List<String> brandList = (List<String>) JSON.deserialize(
        consentSettings[0].CompletedBrandList__c,
        List<String>.class
      );

      for (Account acc : accountList) {
        if (
          acc.Consent_Status__c == 'Confirmed' ||
          acc.Consent_Status__c == 'Active'
        ) {
          if (countryList.contains(acc.Country__c)) {
            if (brandList.contains(acc.Brand__c)) {
              acc.Social_Media_Consent__c = false;
              acc.Survey_Consent__c = false;
              acc.Commercial_Newsletter__c = true;
            }
          } else {
            if (brandList.contains(acc.Brand__c)) {
              acc.Social_Media_Consent__c = true;
              acc.Survey_Consent__c = true;
              acc.Commercial_Newsletter__c = true;
            }
          }
        }
      }
    }
  }

  //Whenever a PersonAccount (all person account record types) is updated for all brands. - modified by: angelito.cuello@accenture.com
  public static void checkConsentStatusOnUpdate(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    if (consentSettings.size() > 0) {
      //List<ConsentSettings__mdt> consentSettings = [SELECT Id, CountryList__c, CompletedBrandList__c FROM ConsentSettings__mdt ORDER BY Id LIMIT 1];
      List<String> countryList = (List<String>) JSON.deserialize(
        consentSettings[0].CountryList__c,
        List<String>.class
      );
      List<String> brandList = (List<String>) JSON.deserialize(
        consentSettings[0].CompletedBrandList__c,
        List<String>.class
      );

      for (Account acc : accountList) {
        if (
          (acc.Consent_Status__c == 'Confirmed' ||
          acc.Consent_Status__c == 'Active') &&
          oldMap.get(acc.Id).Consent_Status__c != acc.Consent_Status__c
        ) {
          if (countryList.contains(acc.Country__c)) {
            if (brandList.contains(acc.Brand__c)) {
              acc.Social_Media_Consent__c = false;
              acc.Survey_Consent__c = false;
              acc.Commercial_Newsletter__c = true;
            }
          } else {
            if (brandList.contains(acc.Brand__c)) {
              acc.Social_Media_Consent__c = true;
              acc.Survey_Consent__c = true;
              acc.Commercial_Newsletter__c = true;
            }
          }
        }
        if (
          acc.Consent_Status__c == 'Withdrawn' &&
          oldMap.get(acc.Id).Consent_Status__c != acc.Consent_Status__c
        ) {
          acc.Social_Media_Consent__c = false;
          acc.Survey_Consent__c = false;
          acc.Commercial_Newsletter__c = false;
        }

        if (
          (acc.Social_Media_Consent__c ||
          acc.Survey_Consent__c ||
          acc.Commercial_Newsletter__c) && acc.Consent_Status__c != 'Confirmed'
        ) {
          if (
            (oldMap.get(acc.Id).Social_Media_Consent__c !=
            acc.Social_Media_Consent__c) ||
            (oldMap.get(acc.Id).Survey_Consent__c != acc.Survey_Consent__c) ||
            (oldMap.get(acc.Id).Commercial_Newsletter__c !=
            acc.Commercial_Newsletter__c)
          ) {
            system.debug('Before Consent Update: ' + acc.Consent_Status__c);
            acc.Consent_Status__c = 'Active';
            acc.Consent_Withdrawn_Date__c = null;
            system.debug('After Consent Update: ' + acc.Consent_Status__c);
          }
        }

        if (
          !acc.Social_Media_Consent__c &&
          !acc.Survey_Consent__c &&
          !acc.Commercial_Newsletter__c
        ) {
          if (
            (oldMap.get(acc.Id).Social_Media_Consent__c !=
            acc.Social_Media_Consent__c) ||
            (oldMap.get(acc.Id).Survey_Consent__c != acc.Survey_Consent__c) ||
            (oldMap.get(acc.Id).Commercial_Newsletter__c !=
            acc.Commercial_Newsletter__c)
          ) {
            acc.Consent_Status__c = 'Withdrawn';
            acc.Consent_Withdrawn_Date__c = DateTime.Now();
          }
        }
      }
    }
  }
  public static void sendYotpoRequestOnAfterInsert(List<Account> accountList) {
    if (System.IsBatch() == false && System.isFuture() == false) {
      if (consentSettings.size() > 0) {
        //List<ConsentSettings__mdt> consentSettings = [SELECT Id, CountryList__c, CompletedBrandList__c FROM ConsentSettings__mdt ORDER BY Id LIMIT 1];
        List<String> countryList = (List<String>) JSON.deserialize(
          consentSettings[0].CountryList__c,
          List<String>.class
        );
        List<String> brandList = (List<String>) JSON.deserialize(
          consentSettings[0].CompletedBrandList__c,
          List<String>.class
        );

        List<Id> subscribeList = new List<Id>();
        List<Id> unsubscribeList = new List<Id>();

        for (Account acc : accountList) {
          //L'Or OR Tassimo
          if (acc.PersonEmail != null && brandList.contains(acc.Brand__c)) {
            if (
              acc.Consent_Status__c == 'Confirmed' ||
              acc.Consent_Status__c == 'Active'
            ) {
              if (!countryList.contains(acc.Country__c)) {
                subscribeList.add(acc.Id);
              } else {
                unsubscribeList.add(acc.Id);
              }
            } else {
              if (countryList.contains(acc.Country__c)) {
                unsubscribeList.add(acc.Id);
              }
            }
          }
        }

        if (subscribeList.size() > 0) {
          //Subscribe call
          System.debug('YotpoRequest: subscribeUsers');
          YotpoRequest.subscribeUsers(subscribeList);
        }

        if (unsubscribeList.size() > 0) {
          //Unsubscribe call
          System.debug('YotpoRequest: unsubscribeUsers');
          YotpoRequest.unsubscribeUsers(unsubscribeList);
        }
      } else {
        System.debug('Error: No Consent settings (Custom Metadata Type)');
      }
    }
  }

  public static void sendYotpoRequestOnAfterUpdate(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    if (System.IsBatch() == false && System.isFuture() == false) {
      if (consentSettings.size() > 0) {
        //List<ConsentSettings__mdt> consentSettings = [SELECT Id, CountryList__c, CompletedBrandList__c FROM ConsentSettings__mdt ORDER BY Id LIMIT 1];
        List<String> countryList = (List<String>) JSON.deserialize(
          consentSettings[0].CountryList__c,
          List<String>.class
        );
        List<String> brandList = (List<String>) JSON.deserialize(
          consentSettings[0].CompletedBrandList__c,
          List<String>.class
        );

        List<Id> subscribeList = new List<Id>();
        List<Id> unsubscribeList = new List<Id>();

        for (Account acc : accountList) {
          //L'Or OR Tassimo
          if (
            acc.PersonEmail != null &&
            brandList.contains(acc.Brand__c) &&
            oldMap.get(acc.Id).Consent_Status__c != acc.Consent_Status__c
          ) {
            if (
              acc.Consent_Status__c == 'Confirmed' ||
              acc.Consent_Status__c == 'Active'
            ) {
              if (!countryList.contains(acc.Country__c)) {
                subscribeList.add(acc.Id);
              } else {
                unsubscribeList.add(acc.Id);
              }
            } else {
              if (countryList.contains(acc.Country__c)) {
                unsubscribeList.add(acc.Id);
              }
            }
          }
        }

        if (subscribeList.size() > 0) {
          //Subscribe call
          System.debug('YotpoRequest: subscribeUsers');
          YotpoRequest.subscribeUsers(subscribeList);
        }

        if (unsubscribeList.size() > 0) {
          //Unsubscribe call
          System.debug('YotpoRequest: unsubscribeUsers');
          YotpoRequest.unsubscribeUsers(unsubscribeList);
        }
      } else {
        System.debug('Error: No Consent settings (Custom Metadata Type)');
      }
    }
  }

  public static void checkAccountTypeIfLoyaltyThenRemainLoyalty(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    for (Account acc : accountList) {
      if (oldMap.get(acc.Id).Type__c == 'Loyalty' && acc.Type__c != 'Loyalty') {
        acc.Type__c = 'Loyalty';
      }
    }
  }

  public static void sendHighCoRequest(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    for (Account acc : accountList) {
      if (acc.PersonEmail != null) {
        if (
          (acc.Consent_Status__c == 'Withdrawn' ||
          acc.Request_to_be_Forgotten__c == true) &&
          acc.HighCO_synced__c == true
        ) {
          acc.HighCO_synced__c = false;
          HighcoRequest.deleteUser(acc.PersonEmail);
        }
      }
    }
  }

  /* public static void lastEmailSentHardBounced(List<Account> accountList){
        for(Account acc : accountList){
        if(acc.Deletion_Flag__c == false && acc.Account_Registration_Status__c != 'Active' && acc.isHardBounced__pc == true){
        acc.To_be_Deleted_Date__c = date.today();
        acc.Deletion_Flag__c = true;
        acc.Deletion_Reason__c = 'Email hard bounced';
        }
        }
        } */

  public static void createLoyaltyRecord(
    Map<Id, Account> newMap,
    Map<Id, Account> oldMap
  ) {
    Map<Id, Account> accMap = new Map<Id, Account>(
      [
        SELECT Id, (SELECT Id FROM Loyalty__r)
        FROM Account
        WHERE ID IN :newMap.keySet()
      ]
    );
    List<Loyalty__c> loyaltyList = new List<Loyalty__c>();
    for (Id accId : newMap.keySet()) {
      Account Id = newMap.get(accId);
      if (accMap.get(accId).Loyalty__r.isEmpty()) {
        if (
          (oldMap.get(accId).Type__c != newMap.get(accId).Type__c &&
          oldMap.get(accId).Type__c == 'Loyalty') ||
          newMap.get(accId).Type__c == 'Loyalty'
        ) {
          Loyalty__c loyaltyRec = new Loyalty__c();
          loyaltyRec.Loyalty_Consumer__c = newMap.get(accId).Id;
          loyaltyRec.External_Id__c = newMap.get(accId).External_Id__c;
          loyaltyList.add(loyaltyRec);
        }
      }
    }
    if (!loyaltyList.isEmpty()) {
      Database.insert(loyaltyList);
    }
  }

  public static void gdprConsumerCleaningRules(List<Account> accountList) {
    List<Account> accList = new List<Account>();
    Cleanup_Rules_Settings__c settings = Cleanup_Rules_Settings__c.getInstance();
    for (Account accRec : accountList) {
      if (
        accRec.Request_to_be_Forgotten__c == true &&
        accRec.Deletion_Flag__c == false
      ) {
        /*****Updated****/
        // Request_to_be_Forgotten To be deleted: immediately after request to be forgotten (max 1 day delay)
        // accRec.Deletion_Flag__c = True; => This should be captured & flagged in the AccountWithOrWithoutCampaign class ! because  it should check if the account is already in a campaign
        accRec.Account_Registration_Status__c = 'Deactivated';
        accRec.Consent_Status__c = 'Withdrawn';
        accRec.Account_Deletion_Date__c = date.Today();
        accRec.Consent_Withdrawn_Date__c = DateTime.Now();
      } else if (
        accRec.Consent_Status__c != 'Withdrawn' &&
        accRec.Consent_Status__c != 'Expired' &&
        accRec.Consent_Withdrawn_Date__c != null &&
        accRec.Deletion_Reason__c == Label.DelReason_Consent_Withdrawn
      ) {
        /*****  REVERT THE DELETION FLAG FOR THE USE CASE:  CONSENT WITHDRAWN *****/
        accRec.Consent_Withdrawn_Date__c = null;
        accRec.Deletion_Flag__c = false;
        accRec.Deletion_Reason__c = null;
        accRec.To_be_Deleted_Date__c = null;
      } else if (
        accRec.Consent_Status__c != 'Withdrawn' &&
        accRec.Consent_Status__c != 'Expired' &&
        accRec.Double_Opt_in_Email_Send_Date__c != null &&
        accRec.Consent_Status__c != 'Pending Confirmation' &&
        accRec.Deletion_Reason__c == Label.DelReason_No_Response_Consumer
      ) {
        /*****  REVERT THE DELETION FLAG FOR THE USE CASE:  DOI NOT CONFIRMED *****/
        accRec.Deletion_Flag__c = false;
        accRec.Deletion_Reason__c = null;
        accRec.To_be_Deleted_Date__c = null;
      }
      // this needs to be ommited since we are not using the criteria on Account_Registration_Status__c
      /***********REVERT DELETION FLAG After registration status changes to active ************/
      /* else if(accRec.Account_Registration_Status__c == 'Active' && accRec.Consent_Status__c != 'Withdrawn' && accRec.Consent_Status__c != 'Expired'){
                 
                accRec.Deletion_Flag__c = False;
                accRec.Deletion_Reason__c = null;
                accRec.To_be_Deleted_Date__c = null;
                
            }  */
    }
  }

  public static void maskingAccount(
    List<Account> accountList,
    Map<Id, Account> oldMap
  ) {
    List<Account> accountsToMask = new List<Account>();
    for (Account accRec : accountList) {
      if (
        accRec.Request_to_be_Forgotten__c == true &&
        (oldMap.get(accRec.Id).Request_to_be_Forgotten__c !=
        accRec.Request_to_be_Forgotten__c) &&
        accRec.Type__c == 'Loyalty' &&
        accRec.IsCustomerPortal == true
      ) {
        accRec.FirstName = Label.mskFirstName;
        accRec.LastName = Label.mskLastName;
        accRec.PersonEmail = Label.mskEmail + string.valueOf(Math.random());
        accountsToMask.add(accRec);
      }
    }
    if (!accountsToMask.isEmpty()) {
      MaskingUser.MaskCommunityUserForAccount(accountsToMask);
    }
  }
}
