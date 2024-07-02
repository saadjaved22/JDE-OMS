/*
 * Author: Accenture
 * Description: It is a web service apex class which exposes web service operations to external applications. 
 * This class only exposes methods but does perform any logic but pass on the pay load to LoyaltyStackHelper class 
 * which does all the heavy lifting. 
*/
global class LoyaltyStack {
    /*This method takes input of type LoyaltyDetails.LoyaltyInfo. Blokker POS sends Account number which is mapped to 
	  Loyalty Name field on consumer loyalty record. This method return the total loyalty points on consumer
	*/
    webservice static LoyaltyDetails.LoyaltyResponse GetDigitalPointsBalance(LoyaltyDetails.LoyaltyInfo loyaltyInfo){
        return LoyaltyStackHelper.GetDigitalLoyaltyPointsBalance(loyaltyInfo);
    }  
    /*This method takes input of type LoyaltyDetails.LoyaltyInfo. Blokker POS sends Account number and regular points to be desposited
     * for consumer. This method return success/error in response */
    webservice static LoyaltyDetails.LoyaltyResponse TransactPoints(LoyaltyDetails.LoyaltyInfo loyaltyInfo){
        return LoyaltyStackHelper.transactPoints(loyaltyInfo); 
    }
    /*This method takes input of type LoyaltyDetails.LoyaltyInfo. Blokker POS sends Account number and pointsAmount as part of request. 
     * Blokker POS calls this method when consumer reqeust to redeem the points to purchase product
     * Salesforce creates a transaction with negative points amount and set transaction type as REDEEM.
     * for consumer. 
	*  This method return success/error in response 
	*/
    webservice static LoyaltyDetails.LoyaltyResponse UsePointsForPurchase(LoyaltyDetails.LoyaltyInfo loyaltyInfo){
        return LoyaltyStackHelper.usePointsForPurchase(loyaltyInfo); 
    } 
}