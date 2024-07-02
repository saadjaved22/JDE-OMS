@isTest(seeAllData = false)
public class ConsumerTest {
    public static testMethod void populateConsumerRecord(){
        Test.startTest();
        Consumer c = new consumer();
        Consumer.ConsumerRecord consRec= new Consumer.ConsumerRecord();
        consRec.ID = 1;
        consRec.LastName = '';
        consRec.FirstName = '';
        consRec.MiddleName = '';
        consRec.Street = '';
        consRec.HouseNumber = 8;
        consRec.HouseLetters = '';
        consRec.City = '';
        consRec.PostCode = '';
        consRec.Country = '';
        consRec.Email = '';
        consRec.IsLoyaltyMember = false;
        consRec.HasActiveLoyaltyCard = false;
        consRec.AccountNumber = 45;
        consRec.Initials = '';
        consRec.Title = '';
        consRec.Gender = '';
        consRec.BirthDate = '';
        consRec.Region = '';
        consRec.Telephone = '';
        consRec.Mobile = '';
        
        List<Consumer.ValidationError> lst = new List<Consumer.ValidationError>();
        List<Consumer.ConsumerRecord> lst2 = new List<Consumer.ConsumerRecord>();
        
        Consumer.ConsumerResult conRes = new Consumer.ConsumerResult();
        conRes.ArrayOfValidationError = new List<Consumer.ValidationError>();
        conRes.listConsumerRecord = new List<Consumer.ConsumerRecord>();
        
        conRes.status = 'Success';
        
        conRes.ArrayOfValidationError = lst;
        
        conRes.listConsumerRecord = lst2;
        Test.stopTest();
        
    }
    public static testMethod void populateConsumerInfo(){
        Consumer c = new Consumer();
        Consumer.ConsumerInfo conInfo = new Consumer.ConsumerInfo();
        
        Consumer.AuditHeader audHeader = new Consumer.AuditHeader();
        audHeader.cashiername = '';
        audHeader.shopname = '';
        audHeader.shopnr = '';
        
        conInfo.ID= 1;
        conInfo.LastName= '';
        conInfo.FirstName= '';
        conInfo.MiddleName= '';
        conInfo.Street= '';
        conInfo.HouseNumber= 2;
        conInfo.HouseLetters= '';
        conInfo.City= '';
        conInfo.PostCode= '';
        conInfo.Country= '';
        conInfo.Email= '';
        conInfo.IsLoyaltyMember= true;
        conInfo.HasActiveLoyaltyCard= false;
        conInfo.AccountNumber= 3;
        conInfo.Initials= '';
        conInfo.Title= '';
        conInfo.Gender= '';
        conInfo.BirthDate= '';
        conInfo.Region= '';
        conInfo.Telephone= '';
        conInfo.Mobile= '';
        conInfo.audit= audHeader;
    }
    
    public static testMethod void populateConsumerSearch(){
        Consumer.ConsumerSearch conSearch = new Consumer.ConsumerSearch();
        
        Consumer.AuditHeader audHeader = new Consumer.AuditHeader();
        audHeader.cashiername = '';
        audHeader.shopname = '';
        audHeader.shopnr = '';
        
        conSearch.LastName='';
        conSearch.PostCode='';
        conSearch.HouseNumber=2;
        conSearch.emailPart='';
        conSearch.CardNumber='';
        conSearch.consumerId=1;
        
        conSearch.audit = audHeader;
    }
    
     public static testMethod void populateValidation(){
       Consumer.ValidationError valError = new Consumer.ValidationError();
       
       valError.Key='';
       valError.Message ='';
       valError.Tag = '';
            
        
    }
}