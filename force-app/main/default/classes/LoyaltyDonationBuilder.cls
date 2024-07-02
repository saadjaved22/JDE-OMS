public without sharing class LoyaltyDonationBuilder{
    
    //Loyalty Transaction related:
    private String loyaltyId; 
    private String loyaltyConsumer; 
    private Integer transactionAmount;
    private String transactionType;
    private String loyaltySource;
    private Boolean hasCharity;
    
    //Donation Related:
    private Integer donatedPoints; 
    private String donorId;
    private String charityId; 
    private String transactionId;
    private String contactId;
    
    public LoyaltyDonationBuilder setLoyaltyId(String loyaltyId){
        Loyalty__c loyRec = [SELECT Id FROM Loyalty__c WHERE External_ID__c = :loyaltyId LIMIT 1];
        this.loyaltyId = loyRec.Id;
        return this;
    }
    
    public LoyaltyDonationBuilder setLoyaltyConsumer(String loyaltyConsumer){
        this.loyaltyConsumer = loyaltyConsumer;
        return this;
    }
    
    public LoyaltyDonationBuilder setTransactionAmount(Integer transactionAmount){
        this.transactionAmount = transactionAmount;
        return this;
    }
    
    public LoyaltyDonationBuilder setTransactionType(String transactionType){
        this.transactionType = transactionType;
        return this;
    }
    
    public LoyaltyDonationBuilder setLoyaltySource(String loyaltySource){
        this.loyaltySource = loyaltySource;
        return this;
    }
    
    public LoyaltyDonationBuilder setHasCharity(Boolean hasCharity){
        this.hasCharity = hasCharity;
        return this;
    }
    
    public LoyaltyDonationBuilder setDonatedPoints(Integer donatedPoints){
        this.donatedPoints = donatedPoints;
        return this;
    }
    
    public LoyaltyDonationBuilder setDonorId(String donorId){
        this.donorId = donorId;
        return this;
    }
    
    public LoyaltyDonationBuilder setCharityId(String charityId){
        Charity__c chaRec = [SELECT Id FROM Charity__c WHERE External_ID__c = :charityId LIMIT 1];
        this.charityId = chaRec.Id;
        return this;
    }
    
    public LoyaltyDonationBuilder setTransactionId(String transactionId){
        this.transactionId = transactionId;
        return this;
    }
    
    public LoyaltyDonationBuilder setContactId(String contactId){
        Loyalty_Transaction__c ltyRec = [SELECT Id, Contact__c FROM Loyalty_Transaction__c WHERE Id = :contactId LIMIT 1];
        this.contactId = ltyRec.Contact__c;
        return this;
    }
    
    public Loyalty_Transaction__c transactionbuild(){
        Loyalty_Transaction__c t = new Loyalty_Transaction__c();
        
        if(String.isNotEmpty(this.loyaltyId)){
            t.Loyalty__c = this.loyaltyId;
        }
        if(String.isNotEmpty(this.loyaltyConsumer)){
            t.Loyalty_Consumer__c = this.loyaltyConsumer;
        }
        if(this.transactionAmount != null){
            t.Transaction_Amount__c = this.transactionAmount;
        }
        if(String.isNotEmpty(this.transactionType)){
            t.Loyalty_Transaction_Type__c	= 'Redeem';
        }
        if(String.isNotEmpty(this.loyaltySource)){
            t.Loyalty_Source__c = this.loyaltySource;
        }
        if(this.hasCharity != null){
            t.Has_Charity__c = this.hasCharity;
        }
        return t;
    }
    
    public Donation__c donationbuild(){
        Donation__c d = new Donation__c();
        if(this.donatedPoints != null){
            d.Donated_Points__c = this.donatedPoints;
        }
        if(String.isNotEmpty(this.donorId)){
            d.Donor__c = this.donorId;
        }
        if(String.isNotEmpty(this.charityId)){
            d.Charity__c = this.charityId;
        }
        if(String.isNotEmpty(this.transactionId)){
            d.Loyalty_Transaction__c = this.transactionId;
        }
        if(String.isNotEmpty(this.contactId)){
            d.DonorContact__c = this.contactId;
        }
        return d;
    }
}