@RestResource(urlMapping='/v1/createLoyaltyDonation')
global without sharing class LoyaltyDonationRESTResource{
    
    public static final String SUCCESS_TRANSACTION_CREATED = 'Transaction created';
    public static final String SUCCESS_TRANSACTION_FAILED = 'Transaction failed';
    
    @HttpPost
    global static FullResponse upsertTransaction(){
        RestRequest request = RestContext.request;
        System.debug('Incoming request uri: ' + request.requestURI + ' parh:' + request.resourcePath + 'headers:' + request.headers + ' body: ' + request.requestBody.toString());
        FullResponse response;
        System.debug('request' + request);
        Loyalty_Transaction__c requestedTransaction = readTransactionDataFrom(request);
        /*try{
            // create:
        }
        catch (Exception e){
            //System.debug( 'AccountException catched. Can return relevant response. ae:' + ae + ' for account:' + ae.getAccount() + ' stackTrace:' + ae.getStackTraceString() );
            response = generateResponse(false, SUCCESS_TRANSACTION_FAILED);
        }*/
          if (requestedTransaction != null){
                response = saveNewTransaction(requestedTransaction);
                //response = generateResponse(true, SUCCESS_TRANSACTION_CREATED);
            }
        
        System.debug('Sending response: ' + response);
        return response;        
    }
    
    @TestVisible
    private static Loyalty_Transaction__c readTransactionDataFrom(RestRequest request){
        String requestBody = request.requestBody.toString();
        FullRequest fullRequest = (FullRequest) JSON.deserialize(requestBody, FullRequest.class);
        System.debug('fullRequest' + fullRequest);
        RESTRequestTransaction restTransaction = fullRequest.loyaltyTransaction;	
        System.debug('restTransaction' + restTransaction);
        //checkMandatoryFields(restTransaction);
        LoyaltyDonationBuilder builder = new LoyaltyDonationBuilder();
        if(restTransaction.loyaltyId != null){
            builder.setLoyaltyId(restTransaction.loyaltyId)
                .setLoyaltyConsumer(restTransaction.loyaltyConsumer)
                .setTransactionAmount(restTransaction.transactionAmount)
                .setTransactionType(restTransaction.transactionType)
                .setLoyaltySource(restTransaction.loyaltySource)
                .setHasCharity(restTransaction.hasCharity);
        }
      
        if(null != restTransaction.donation){
            System.debug('restDonation' + restTransaction.donation);
            builder.setDonatedPoints(restTransaction.donation.donatedPoints)
                .setdonorId(restTransaction.donation.donorId)
                .setCharityId(restTransaction.donation.charityId)
                .setTransactionId(restTransaction.donation.transactionId);
        }
        
        Loyalty_Transaction__c requestedTransaction = builder.transactionbuild();        
        return requestedTransaction;
    }
    
    @TestVisible
    private static Donation__c readDonationDataFrom(RestRequest request, Id LoyaltyId){
        String requestBody = request.requestBody.toString();
        FullRequest fullRequest = (FullRequest) JSON.deserialize(requestBody, FullRequest.class);
        System.debug('fullRequest' + fullRequest);
        RESTRequestTransaction restTransaction = fullRequest.loyaltyTransaction;	
        System.debug('restTransaction' + restTransaction);
        //checkMandatoryFields(restTransaction);
        LoyaltyDonationBuilder builder = new LoyaltyDonationBuilder();
      
        if(null != restTransaction.donation){
            System.debug('restDonation' + restTransaction.donation);
            builder.setDonatedPoints(restTransaction.donation.donatedPoints)
                .setdonorId(restTransaction.donation.donorId)
                .setCharityId(restTransaction.donation.charityId)
                .setTransactionId(LoyaltyId)
            	.setContactId(LoyaltyId);
        }
        
        Donation__c requestedTransaction = builder.donationbuild();        
        return requestedTransaction;
    }
    
    private static void checkMandatoryFields(RESTRequestTransaction restTransaction){
        //if(restTransaction.transactionAmount != null){
        //throw new CalloutException('Can\'t create Transaction - Type is mandatory. Type from request:' + restTransaction.transactionType);
        //}
    }
    
    @TestVisible    
    private static FullResponse saveNewTransaction(Loyalty_Transaction__c loyaltyTransaction){
        Savepoint sp = Database.setSavepoint();
        RestRequest request = RestContext.request;
        FullResponse response;
        try{
            insert loyaltyTransaction;
            System.debug('Successful Loyalty Insert' + loyaltyTransaction);
            if(loyaltytransaction != null){
                Donation__c requestedTransaction = readDonationDataFrom(request, loyaltyTransaction.Id); 
                insert requestedTransaction;
                response = generateResponse(true, SUCCESS_TRANSACTION_CREATED + '; Loyalty: ' + loyaltyTransaction.Id + '; Donation: ' + requestedTransaction.Id);
            }
            
        } 
        catch(exception e){
            response = generateResponse(false, e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    @TestVisible
    private static FullResponse generateResponse(Boolean success, String message){
        FullResponse response = new FullResponse();
        //RESTResponseTransaction responseTransaction = new RESTResponseTransaction();
        //responseTransaction = loyaltyTransaction.Id;
        //response.loyaltyTransaction = responseTransaction;
        response.success = success;
        response.message = message;
        return response;
    }
    
    public class FullRequest{
        private RESTRequestTransaction loyaltyTransaction;
    }
    
    public class RESTRequestTransaction{
        private String loyaltyId;
        private String loyaltyConsumer;
        private Integer transactionAmount;
        private String transactionType;	
        private String loyaltySource;
        private Boolean hasCharity;
        private RESTRequestDonate donation;
    } 
    
    public class RESTRequestDonate{
        private Integer donatedPoints;
        private String donorId;
        private String charityId;
        private String transactionId;
        private String contactId;
    }
    
    global class FullResponse{
        public Boolean success;
        public String message;
        //public RESTResponseTransaction loyaltyTransaction;
    }
    
    public class RESTResponseTransaction{
       //public String Id;
    }   
}