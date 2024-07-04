/* AUTHOR: Accenture
 * PURPOSE:This is a main service class for LoyaltyStack web service class. The main purpose of this class is to create transaction
 * 		   or return total loyalty balance for the consumer.
 */
public class LoyaltyStackHelper {
  /*This method return false if arguments is null or account number is null*/
  public static Boolean checkArgumentsAreMissing(
    LoyaltyDetails.LoyaltyInfo loyaltyInfo
  ) {
    if (loyaltyInfo == null || loyaltyInfo.accountNumber == null) {
      return true;
    }
    return false;
  }

  /*This method query the total loyalty points for the consumer whose account number matches with the account number received in argument*/
  public static LoyaltyDetails.LoyaltyResponse GetDigitalLoyaltyPointsBalance(
    LoyaltyDetails.LoyaltyInfo loyaltyInfo
  ) {
    LoyaltyDetails.LoyaltyResponse resp = new LoyaltyDetails.LoyaltyResponse();
    if (checkArgumentsAreMissing(loyaltyInfo)) {
      resp.Status = Label.ArgumentsMissing;
      return resp;
    } else {
      try {
        string statusMsg = '';
        List<Loyalty__c> lstLoaylty = new List<Loyalty__c>(
          getLoyaltyDetails(
            new Set<String>{ string.valueOf(loyaltyInfo.accountNumber) }
          )
        );

        resp = populateLoyaltyResponse(lstLoaylty, 0);
      } catch (Exception ex) {
        resp.status = Label.UnknownError;
      }
    }
    return resp;
  }

  /*This method return the loyalty record details where account number is equal to the loyalty name */
  public static List<Loyalty__c> getLoyaltyDetails(
    Set<String> setAccountNumber
  ) {
    system.debug('string is ' + setAccountNumber);
    return [
      SELECT
        ID,
        Loyalty_Total_Points__c,
        Loyalty_Consumer__c,
        Name,
        Loyalty_Account_Number__c
      FROM Loyalty__c
      WHERE Loyalty_Account_Number__c IN :setAccountNumber
    ];
  }
  /*This method populates the Loyalty response class attributes with the loyalty record received as part of reqeust*/
  public static LoyaltyDetails.LoyaltyResponse populateLoyaltyResponse(
    List<Loyalty__c> listLylt,
    Integer pointsUsed
  ) {
    LoyaltyDetails.LoyaltyResponse resp = new LoyaltyDetails.LoyaltyResponse();

    resp.Balance = (listLylt != null && !listLylt.isEmpty()
      ? (Long) listLylt[0].Loyalty_Total_Points__c
      : 0);
    resp.Status = (listLylt != null && !listLylt.isEmpty()
      ? Label.SuccessMessage
      : Label.ConsumerNotFound);
    resp.BonusPointsUsed = 0;
    resp.RegularPointsUsed = (Long) pointsUsed;

    return resp;
  }
  /*This method creates the transaction based on the input received and returns the created transaction as part of response*/
  public static Loyalty_Transaction__c createTransaction(
    LoyaltyDetails.LoyaltyInfo loyaltyInfo,
    Loyalty__c loyalty
  ) {
    Loyalty_Transaction__c trans = new Loyalty_Transaction__c();

    trans.Loyalty__c = loyalty.Id;
    trans.Loyalty_Consumer__c = loyalty.Loyalty_Consumer__c;
    trans.Loyalty_Notes__c = loyaltyInfo.referenceID;
    trans.Loyalty_Notes_Reference__c = loyaltyInfo.specification;
    trans.Loyalty_Source__c = Label.BlokkerPOS;
    trans.Loyalty_Transaction_Type__c = loyaltyInfo.mutationType;
    trans.Transaction_Amount__c = loyaltyInfo.regularPointsAmount;

    try {
      insert trans;
    } catch (Exception ex) {
      if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
        throw new applicationException(Label.ArgumentsMissing);
      } else {
        throw new applicationException(Label.UnknownError);
      }
    }

    return trans;
  }
  /*This method creates transaction of type deposit by calling createTransaction method.
      It calls populateLoyaltyResponse method to populate the response for web service operation. 
	*/
  public static LoyaltyDetails.LoyaltyResponse transactPoints(
    LoyaltyDetails.LoyaltyInfo loyaltyInfo
  ) {
    LoyaltyDetails.LoyaltyResponse resp = new LoyaltyDetails.LoyaltyResponse();
    List<Loyalty__c> lstLoyalty = new List<Loyalty__c>();

    if (checkArgumentsAreMissing(loyaltyInfo)) {
      resp.Status = Label.ArgumentsMissing;
      return resp;
    }

    // This is the scenario when Use points for purchase is used. POS makes two successive calls. One with 0 transact points and another
    // for UsePointsForPurchase
    if (loyaltyInfo.pointsAmount == 0 || loyaltyInfo.regularPointsAmount == 0) {
      lstLoyalty = getLoyaltyDetails(
        new Set<String>{ String.valueOf(loyaltyInfo.accountNumber) }
      );
      resp = LoyaltyStackHelper.populateLoyaltyResponse(lstLoyalty, 0);
      return resp;
    }

    try {
      lstLoyalty = getLoyaltyDetails(
        new Set<String>{ String.valueOf(loyaltyInfo.accountNumber) }
      );
      if (lstLoyalty != null && !lstLoyalty.isEmpty()) {
        // Due to some technical reason @Blokker  POS, we are hardcoding this value to Deposit
        loyaltyInfo.mutationType = Label.TransactionTypeDeposit;
        createTransaction(loyaltyInfo, lstLoyalty[0]);
      }
      resp = LoyaltyStackHelper.populateLoyaltyResponse(lstLoyalty, 0);
    } catch (Exception ex) {
      resp.status = ex.getMessage();
      //throw new applicationException(ex.getMessage());
    }

    return resp;
  }

  /*This method is called to redeem the points available to the consumer.
   * This method negates the points requested and calls method createTransaction.
   * It then calls populateLoyaltyResponse method to populate the response attributes.
   */
  public static LoyaltyDetails.LoyaltyResponse usePointsForPurchase(
    LoyaltyDetails.LoyaltyInfo loyaltyInfo
  ) {
    LoyaltyDetails.LoyaltyResponse resp = new LoyaltyDetails.LoyaltyResponse();
    List<Loyalty__c> lstLoyalty = new List<Loyalty__c>();
    if (
      checkArgumentsAreMissing(loyaltyInfo) || loyaltyInfo.pointsAmount == null
    ) {
      resp.Status = Label.ArgumentsMissing;
      return resp;
    }
    try {
      loyaltyInfo.regularPointsAmount = (-1) * loyaltyInfo.pointsAmount;
      loyaltyInfo.mutationType = Label.TransactionTypeRedeem;
      lstLoyalty = getLoyaltyDetails(
        new Set<String>{ String.valueOf(loyaltyInfo.accountNumber) }
      );

      if (lstLoyalty != null && !lstLoyalty.isEmpty()) {
        createTransaction(loyaltyInfo, lstLoyalty[0]);
      }
      resp = LoyaltyStackHelper.populateLoyaltyResponse(lstLoyalty, 0);
    } catch (Exception ex) {
      resp.status = ex.getMessage();
      //throw new applicationException(ex.getMessage());
    }

    return resp;
  }
}
