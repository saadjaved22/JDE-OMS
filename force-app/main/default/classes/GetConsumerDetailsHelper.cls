/*Author: Accenture
		  This is the main service class which do the heavy lifting to generate query dynamically based 
		  on the input received from the calling class. It searches the consumers and 
		  transform in a format expected by SAP PO layer. 
*/
public class GetConsumerDetailsHelper{
    public static string houseNumber = '';
    public static Boolean ISLOYALTY = TRUE;
    public static string strLoyaltyQuery = '(SELECT ID,Loyalty_Card_Status__c,Name FROM LOYALTY__R)';
    public static string strQuery = 'SELECT  ID,'+
                                 +'Data_Migration_Id__c,'+
            					 +'Customer_ID__c,'+
                                 +'LastName,'+
                                 +'FirstName,'+
                                 +'BillingStreet,'+
                                 +'BillingCity,'+
                                 +'BillingPostalCode,'+
                                 +'BillingCountry,'+
                                 +'PersonEmail,'+
                                 +'Gender__pc,'+
                                 +'PersonBirthdate,'+
                                 +'Phone,'+
                                 +'PersonMobilePhone,'+
        							+'Deletion_Flag__c,'+
        
                                 +strLoyaltyQuery+
                                 +' FROM ACCOUNT ';
    /*
     * The main purpose of this method is to query consumers based on the query string received as part of the argument. 
     * This method returns list of matching consumer records or throws exception if invalid query is passed. 
	*/
    public static List<Account> queryConsumer(String query){
        if(string.isNotBlank(query)){
            try{
                return Database.query(query);    
            }catch(Exception ex){
                throw new applicationException(Label.UnknownError);
            }
        }else{
            return null;
        }
    }
    
    public static EmailValidity checkEmail_ExternalID(Consumer.ConsumerInfo consInfo){
        
        string extId = consInfo.Email + Label.Country + Label.Brand;
        string strQuery1 = 'SELECT Id, PersonEmail, Customer_ID__c From Account ';
        
        EmailValidity emailVal = new EmailValidity();
        
        Map<String,String> mapExId_ConsId = new Map<String, String>();
        Map<String,String> mapConsId_ExId = new Map<String, String>();
        
        List<String> conditions = new List<String>();
        if(string.isBlank(consInfo.email)){
	        	emailVal.isEmailValid = false;      
            	return emailVal;    
       }
        
        else if (!ConsumerAttributes.validateEmail(consInfo.email)){
            emailVal.isEmailValid = false;      
            return emailVal;
        }
        
        if (String.isNotBlank(string.valueOf(consInfo.Id))) {
            conditions.add('Customer_ID__c = ' + string.valueOf(consInfo.Id) );
        }
        if (String.isNotBlank(extId)) {
            conditions.add('External_Id__c = \'' + extId + '\'');
        }
        
        if (conditions.size() > 0) {
            strQuery1 += 'WHERE Brand__c = \''+ Label.Brand +'\' AND ';
            if (conditions.size() > 1) {
                strQuery1 += '(' + conditions[0];
            } else {
                strQuery1 += conditions[0];
            }
            
            for (Integer i = 1; i < conditions.size(); i++)
                strQuery1 += ' OR ' + conditions[i];
            
            if (conditions.size() > 1) {
                strQuery1 += ')';
            }
        }
        
       for(Account acc: queryConsumer(strQuery1)){
            if(string.isNotBlank(acc.PersonEmail)){
                mapExId_ConsId.put((acc.PersonEmail+ Label.Country + Label.Brand).toLowerCase(), (string.valueOf(acc.Customer_ID__c)).toLowerCase());
            }
            if(string.isNotBlank(string.valueOf(acc.Customer_ID__c)) && string.isNotBlank(acc.PersonEmail)){
                mapConsId_ExId.put(string.valueOf((acc.Customer_ID__c)).toLowerCase(), (acc.PersonEmail+ Label.Country + Label.Brand).toLowerCase());
            }
            
        }
        /*** Create Consumer Request */
        
        if(String.isBlank(string.valueOf(consInfo.Id))){
               
            if(mapExId_ConsId.containsKey((consInfo.email+ Label.Country + Label.Brand).toLowerCase())){
                
                emailVal.isExternalIDExist = true;    
                emailVal.isConsumerExist = true;
                emailVal.isEmailValid = true;
            }
            else{
                emailVal.isExternalIDExist = false;    
                emailVal.isConsumerExist = false;
                emailVal.isEmailValid = true;
            }
            
        }
        
        /**** Change/Upgrade Request Consumer does not exist****/
        
        else if(String.isNotBlank(string.valueOf(consInfo.Id)) && !mapConsId_ExId.containsKey(string.valueOf(consInfo.Id))){
            emailVal.isConsumerExist = False;
        }        
        
        /**** Change/Upgrade Request ****/
        else if(String.isNotBlank(string.valueOf(consInfo.Id))){
            //Consumer New External Id exist and Email is Changed
            if(mapConsId_ExId.containsKey(string.valueOf(consInfo.Id)) 
                    && !(consInfo.email+ Label.Country + Label.Brand).equalsIgnoreCase(mapConsId_ExId.get(string.valueOf(consInfo.Id)))){
                    if(mapExId_ConsId.containsKey((consInfo.email+ Label.Country + Label.Brand).toLowerCase())){
                        emailVal.isExternalIDExist = true;    
                    }
                    emailVal.isEmailChanged = true;
                    emailVal.isConsumerExist = true;
            }
            else if(mapConsId_ExId.containsKey(string.valueOf(consInfo.Id))
                            && 
               mapExId_ConsId.containsKey(mapConsId_ExId.get(string.valueOf(consInfo.Id)))
                    && 
               mapExId_ConsId.get(mapConsId_ExId.get(string.valueOf(consInfo.Id))).equals(string.valueOf(consInfo.Id))
               ){
                   emailVal.isExternalIDExist = true;
                   emailVal.isConsumerExist = true;
                   emailVal.isEmailChanged = false;
            }
           
        }
       return emailVal;
    }
    
    public static Boolean checkArgumentsAreMissing(Consumer.ConsumerSearch consInfo){
        if(consInfo == null || (string.isBlank(consInfo.LastName) 
                        && string.isBlank(consInfo.postCode) && string.isBlank(string.valueOf(consInfo.houseNumber))
                        && string.isBlank(consInfo.cardNumber)
                        && string.isBlank(string.valueOf(consInfo.EmailPart))
                        && string.isBlank(string.valueOf(consInfo.consumerId))))
        {   return true;
        }
        return false;
    }
   /*This method accepts argument of type Consumer.ConsumerSearch. 
    The argument mainly contains search attributes send by Blokker POS application via SAP PO. 
	Based on the inputs populated, this method generates the WHERE clause dynamically. 
	*/ 
    private static string buildQuery(Consumer.ConsumerSearch consInfo){
        List<String> conditions = new List<String>();

        if(string.isNotBlank(consInfo.cardNumber) ){
            strLoyaltyQuery = strLoyaltyQuery  + ' WHERE Loyalty_Card_Number__c LIKE \'%' + consInfo.cardNumber+ '%\' ';
            List<Loyalty__c> lstLoyalty = new List<Loyalty__c>();
            lstLoyalty  = [SELECT Loyalty_Consumer__c FROM Loyalty__c where Loyalty_Card_Number__c = :consInfo.cardNumber];
            if(lstLoyalty==null || lstLoyalty.isEmpty()){
                throw new applicationException(Label.ConsumerNotFound); 
                //return '';
            }else{
                strQuery += 'WHERE Brand__c = \''+ Label.Brand +'\' AND ID = \''+lstLoyalty[0].Loyalty_Consumer__c+'\'';    
            }
        }        
        else{
            if(string.isNotBlank(consInfo.LastName) ){
	            conditions.add('LastName LIKE \'' + consInfo.LastName + '\' ');
                //conditions.add('LastName LIKE \'%' + consInfo.LastName + '%\' ');
            }
                
            if(string.isNotBlank(consInfo.postCode) ){
            	string postalCodeTemp = consInfo.postCode.remove(' ');
            	postalCodeTemp = postalCodeTemp.left(4) + ' '+ postalCodeTemp.right(2);
            	
                conditions.add('(BillingPostalCode = \'' + consInfo.postCode+ '\' OR  BillingPostalCode = \'' + postalCodeTemp+ '\')');
            }
            if(string.isNotBlank(string.valueOf(consInfo.houseNumber))){
                conditions.add('BillingStreet LIKE \'%' + string.valueOf(consInfo.houseNumber)+ '%\' ');
            }
                
            if(string.isNotBlank(string.valueOf(consInfo.consumerId))){
                conditions.add('Customer_ID__c = ' + consInfo.consumerId);
            }
            
            if(string.isNotBlank(consInfo.emailPart) ){
                if (ConsumerAttributes.validateEmail(consInfo.emailPart)){
                    conditions.add('PersonEmail  = \'' + consInfo.emailPart+ '\' ');
                }else{
                	conditions.add('PersonEmail LIKE \'%' + consInfo.emailPart + '%\' ');
                }
            }
           
            if (conditions.size() > 0) {
                strQuery += 'WHERE Brand__c = \''+ Label.Brand +'\' AND ';
            
                if (conditions.size() > 0) {
                    strQuery += '(' + conditions[0];
                } else {
                    strQuery += conditions[0];
                }
                    
                for (Integer i = 1; i < conditions.size(); i++)
                     strQuery += ' AND ' + conditions[i];
                    
                if (conditions.size() > 0) {
                    strQuery += ') AND (Deletion_Flag__c = false) LIMIT 100';
                }
            }    
        }
        system.debug('query is '+strQuery);
        return strQuery;
    }
    /*This method is called by web service operations of class GetConsumerDetailsStack. 
	 This method return type is Consumer.ConsumerResult
	 This method search for the consumer based on the input received and return matching consumer records*/
    public static Consumer.ConsumerResult getConsumerData(Consumer.ConsumerSearch consInfo){
        List<Consumer.ConsumerRecord> lstConRec = new List<Consumer.ConsumerRecord>(); 
        Consumer.ConsumerResult consRes = new Consumer.ConsumerResult();
        
        if(checkArgumentsAreMissing(consInfo))
        {
           consRes.status = Label.ArgumentsMissing; 
           return consRes;
        }
        
        try{
            string query = buildQuery(consInfo);
            if(string.isNotBlank(query)){
                List<Account> lstAcc = new List<Account>();
                lstAcc = queryConsumer(query);
                generateDataMigrationId(lstAcc);
                
                for(Account acc  : lstAcc){
                    lstConRec.add(populateConsumerData(acc));
                    /*if(string.isNotBlank(string.valueOf(consinfo.HouseNumber))){
                    	List<String> lstBillingStreet  = new List<String> ();
                        lstBillingStreet  = acc.BillingStreet.split(':');
                        if(lstBillingStreet.size()>)
                    }*/
                    
                }
                
                if (lstConRec.size() > 0) 
                {
                    consRes.status = Label.SuccessMessage;
                    consRes.listConsumerRecord = lstConRec;
                } else {
                    consRes.status = Label.ConsumerNotFound;
                    consRes.listConsumerRecord = null;
                }   return consRes;    
            }
            else{
                consRes.status = Label.UnknownError;
            }
            
        }catch(Exception ex){
            consRes.status = ex.getMessage();
        }  
        
        return consRes;
    }
    /*
     * This method receives account as argument and returns Consumer.ConsumerRecord. 
     * This method map/populate corresponding attributes of consumer record from the account record receives as part of argument.
	*/        
    public static Consumer.ConsumerRecord populateConsumerData(Account acc){
        Consumer.ConsumerRecord rec = new Consumer.ConsumerRecord();
        rec.Id  = (acc.Customer_ID__c!=null ? Integer.ValueOf(acc.Customer_ID__c):null);
        rec.FirstName = (string.isNotBlank(acc.FirstName)? acc.FirstName: '');
        rec.LastName = (string.isNotBlank(acc.LastName)? acc.LastName: '');
        rec.MiddleName = '';//acc.LastName; (string.isNotBlank(acc.FirstName)? acc.FirstName: '');
        if(string.isNotBlank(acc.BillingStreet)){
            rec = populateConsumerAddr(rec,acc.BillingStreet);
        }

        rec.City = (string.isNotBlank(acc.BillingCity)? acc.BillingCity: '');
        rec.PostCode = (string.isNotBlank(acc.BillingPostalCode)? acc.BillingPostalCode: '');
        rec.Country= (string.isNotBlank(acc.BillingCountry)? acc.BillingCountry: '');
        rec.Email =  (string.isNotBlank(acc.PersonEmail)? acc.PersonEmail: '');
       
        rec.IsLoyaltyMember = (acc.Loyalty__r!=null && (acc.Loyalty__r).size() > 0 ? true:false); 
        rec.HasActiveLoyaltyCard = (acc.Loyalty__r!=null && (acc.Loyalty__r).size() > 0 && string.isNotBlank((acc.Loyalty__r)[0].Loyalty_Card_Status__c) ?
                                    ((acc.Loyalty__r)[0].Loyalty_Card_Status__c == 'Active' ? true : false):
                                    false);
        rec.AccountNumber  = (acc.Loyalty__r!=null && (acc.Loyalty__r).size() > 0 &&  
                              string.isNotBlank((acc.Loyalty__r)[0].Name) && 
                              ((acc.Loyalty__r)[0].Name).isNumeric()  ? 
                              Integer.valueOf((acc.Loyalty__r)[0].Name) : null);

        rec.Initials= '';
        rec.Title= '';
        if(string.isNotBlank(acc.Gender__pc)){
            if(acc.Gender__pc.equalsIgnoreCase('Male')){
        		rec.Gender = 'M';        
            }else if (acc.Gender__pc.equalsIgnoreCase('FeMale')){
                rec.Gender = 'V';
            }else{
                rec.Gender = 'M';
            }
        }

        
        rec.BirthDate = (string.isNotBlank(string.valueOf(acc.PersonBirthdate))? string.valueOf(acc.PersonBirthdate): string.valueOf(system.today()));

        rec.Region= '';
        rec.Telephone = acc.Phone;
        rec.Mobile=(string.isNotBlank(string.valueOf(acc.PersonMobilePhone))? acc.PersonMobilePhone: '');

        return rec;   
    }
     /*
      * This method populates the populates the consumer address into discreet address attributes 
      * of Consumer.ConsumerRecord object. In Salesforce all the address is stored in one field
      * BillingStreet but at Blokker level it is break down in Street, House Number and Letter.
      *
	*/
    private static Consumer.ConsumerRecord populateConsumerAddr(Consumer.ConsumerRecord rec, string addr){
            
        List<String> lstAddr = new List<String>();
        
        lstAddr =  (string.isNotBlank(addr)? addr.split(':'): null);
        Integer cnt = 0;
        for(String s : lstAddr){
            if(cnt  ==0 ){
                
                rec.Street= s;
                
            }else if (cnt == 1){
                rec.HouseNumber = ((s.trim().isNumeric()) ? Integer.valueOf(s.trim()) : null );
            }else if (cnt == 2){
                rec.HouseLetters=s;     
            }
            
            cnt++;
        } 
        
        return rec;
            
     }

    /*
     * This method receives Consumer.ConsumerInfo as argument and based on the values passed to the argument 
     * it populates the value at consumer level and return the updated reference version to the calling method.
     */
    public static Account populateAccountValues(Consumer.ConsumerInfo conRec){
        Account acc = new Account();
        Integer migrationId = (conRec.ID!=null ? conRec.ID: getMaxDataMigrationID());
            
        acc.Customer_ID__c = migrationId;
        
        List<Account> existingAccount = [SELECT Id, Account_Registration_Date__c, Account_Consent_Registration_Date__c, Account_Registration_Source__c FROM Account WHERE Customer_ID__c =: migrationId];
        if(!existingAccount.isEmpty()){
           acc.Account_Registration_Date__c =  existingAccount[0].Account_Registration_Date__c;
           acc.Account_Consent_Registration_Date__c =  existingAccount[0].Account_Consent_Registration_Date__c;
           acc.Account_Registration_Source__c =  existingAccount[0].Account_Registration_Source__c;
        }
        
        if(string.isNotBlank(conRec.LastName)){
        	acc.LastName = conRec.LastName;
        }
        
        if(string.isNotBlank(conRec.FirstName) && !conRec.FirstName.equals('-')){
        	acc.FirstName = conRec.FirstName;
        }
        
        if(string.isNotBlank(conRec.MiddleName)){
        	acc.MiddleName = conRec.MiddleName;
        }
        
        if(string.isNotBlank(conRec.City)){
        	acc.BillingCity = conRec.City;
        }
        
        if(string.isNotBlank(conRec.PostCode)){
        	acc.BillingPostalCode = conRec.PostCode;
        }
        
        if(string.isNotBlank(conRec.Country)){
        	acc.BillingCountry = conRec.Country;
        }
        
        if(string.isNotBlank(conRec.Email)){
        	acc.PersonEmail = conRec.Email;
        }
        
        
        if(string.isNotBlank(conRec.Initials)){
        	acc.Salutation = conRec.Initials;
        }
        
        if(string.isNotBlank(conRec.Initials)){
        	acc.PersonTitle = conRec.Initials;
        }
        
        if(string.isNotBlank(conRec.Telephone)){
        	acc.Phone = conRec.Telephone;
        }
        
        if(string.isNotBlank(conRec.Mobile)){
        	acc.PersonMobilePhone = conRec.Mobile;
        }
        
        if(string.isNotBlank(conRec.Email)){
        	acc.External_id__c = conRec.Email+Label.Country+Label.Brand;
        }
        
        acc.PersonBirthdate = populateBirthDate(conRec.BirthDate);
        IF(ISLOYALTY){
        	acc.Type__c = Label.AccountType;    
        }
        acc.Brand__c = Label.Brand;
        acc.Country__c = 'NL';
        acc.Language__c = 'Dutch';
        acc.BillingStreet= conRec.Street+ ':'+conRec.HouseNumber +':' +conRec.HouseLetters;
        
        if(string.isNotBlank(conRec.gender)){
            if(conRec.gender.equalsIgnoreCase('Male') || conRec.gender.equalsIgnoreCase('M')){
        		acc.gender__pc = 'Male';        
            }else if (conRec.gender.equalsIgnoreCase('Female') || conRec.gender.equalsIgnoreCase('F')|| conRec.gender.equalsIgnoreCase('V')){
                acc.gender__pc = 'Female';        
            }else{
                acc.gender__pc = 'Other';
            }
        }
		
        /* Author:			 Accenture NL
         * Date Modified: 	 06- 06 - 2018
         * Comment:  		 This piece of code is commented because as per new requirements 
         * 					 Blokkers POS consumers does not have any commercial consent
         */
        /*acc = ConsumerAttributes.populateGDPRAttributes(new List<Account> {acc}, Label.SourceBlokker, '',
                                                                isEmailChanged(conRec.Email,String.valueOf(migrationId)))[0];
		*/
        acc = ConsumerAttributes.populateAccountRegistrationAttributes(new List<Account> {acc}, 'Active', '', Label.SourceBlokker)[0];
        
        return acc;
    }
    
    public static List<Account> upsertConsumer(List<Account> lstAccount){
        if(lstAccount!=null && !lstAccount.isEmpty()) {
            try{
                upsert lstAccount Customer_ID__c;    
            }catch(Exception ex){
                throw new applicationException(Label.UnknownError);
            }
            
        }
        return lstAccount;
    }
    public static List<Account> insertConsumer(List<Account> lstAccount){
        if(lstAccount!=null && !lstAccount.isEmpty()) {
            try{
                 insert lstAccount;
            }catch(Exception ex){
                throw new applicationException(Label.UnknownError);
            }
        }
        return lstAccount;
    }

	/*This method takes account list as argument and iterate over all the 
		account records to populate customer id for those account where it is blank 
		and return updated account list back to the calling method.*/
    public static List<Account> generateDataMigrationId(List<Account> lstAccount){
        Integer dataMigrationId;
        for(Account acc : lstAccount){
            if(acc.Customer_ID__c == null){
                if(dataMigrationId == null){
                    dataMigrationId = getMaxDataMigrationID();
                }else{
                    dataMigrationId  = dataMigrationId + 1;
                }
                acc.Customer_ID__c = dataMigrationId;
            }
        }
        
        try{
            Database.update(lstAccount,false);
        }catch(Exception ex)
        {
        }
        return lstAccount;
    }
    /*This Method return the max customer Id present in Salesforce. The return max value is used for new consumer record.*/
    public static Integer getMaxDataMigrationID(){
        return (Integer.valueOf([select id, Customer_ID__c from account where Customer_ID__c != null order by Customer_ID__c desc limit 1].Customer_ID__c)) + 1;
    }
    
    /*This method converts and returns string birthdate to date type */
    public static Date populateBirthDate(string dt){
        if((string.isNotBlank(dt))){
            try{
             return date.valueOf(dt);   
            }catch(Exception ex){
                throw new applicationException(Label.ArgumentsMissing);        
            }
        }else{
            return null;
        }
    }
    /*
     * This method checks if email is changed for the existing consumer. The purpose of doing it is that if email 
     * has changed and new email address exit in the system then it will throw the error otherwise cursor will move to the proceeding logic*/
    
    public static Boolean isEmailChanged(string email, string consId){
        
        List<Account> lstAcc = new List<Account>();
        lstAcc = [SELECT PersonEmail From Account where Brand__c = :String.valueOf(Label.Brand) AND Data_Migration_Id__c = :consId];
        if(lstAcc!=null && !lstAcc.isEmpty()){
            if(email.equalsIgnoreCase(lstAcc[0].PersonEmail)){
                return false;
                    }else{
                        return true;
                    }
        }
        return true;
    }
    
    public class EmailValidity{
        public boolean isEmailValid;
        public boolean isExternalIDExist;
        public boolean isConsumerExist;	
        public boolean isEmailChanged;
        
        public EmailValidity(){
            isEmailValid = true;
            isExternalIDExist = false;
            isConsumerExist = false;
            isEmailChanged = false;
                
        }
    }
}