public class CLMTriggerFlowClass 
{
	public static void CLMTriggerFlow(List<Brewer_Registration__C> lBrewerRegistrations)
    {
        List<Id> lBrewerRegistrationsinCLM = new List<Id>();
        // Countries and Brands for which the CLM Flow applies
        List<CLM_Flow_CountryBrand__mdt> CountryBrandMD = [SELECT Id, Country__c, Brand__c, Active__c, Start_Date__c FROM CLM_Flow_CountryBrand__mdt WHERE Active__c = TRUE];
        Map<String,CLM_Flow_CountryBrand__mdt> CountryBrandMap = new Map<String,CLM_Flow_CountryBrand__mdt>();
		for(CLM_Flow_CountryBrand__mdt CBMD : CountryBrandMD)
        {	
    		CountryBrandMap.put(CBMD.Country__c+CBMD.Brand__c,CBMD);
		}
        for (Brewer_Registration__C oBrewerRegistration : lBrewerRegistrations)
    	{
            system.debug('Account_Commercial_Consent__c'+oBrewerRegistration.Account_Commercial_Consent__c);
            // Added Condition to only send if commercial consent status is active
            if (oBrewerRegistration.Account_Commercial_Consent__c == 'Active')
            {
            	system.debug('oBrewerRegistration.CLM_Welcome_Mail_Sent__c'+oBrewerRegistration.CLM_Welcome_Mail_Sent__c);
                // Condition to only allow the CLM flow to be sent once
                if (oBrewerRegistration.CLM_Welcome_Mail_Sent__c == null)
                {
                    system.debug('CountryBrandMap.containsKey(oBrewerRegistration.Country__c+oBrewerRegistration.Brand__c)'+CountryBrandMap.containsKey(oBrewerRegistration.Country__c+oBrewerRegistration.Brand__c));
                    // Condition to check on brand and Country, only specific country/brands are allowed
                    if (CountryBrandMap.containsKey(oBrewerRegistration.Consumer_Country__c+oBrewerRegistration.Brand__c))
                    {	
                       	// Condition to only allow brewer registrations as of the start date of the CLM Flow
                        Date dCLMStartdate = CountryBrandMap.get(oBrewerRegistration.Consumer_Country__c+oBrewerRegistration.Brand__c).Start_Date__c;
                        system.debug('dCLMStartdate'+dCLMStartdate);
                        if (oBrewerRegistration.CreatedDate >= dCLMStartdate)
            			{
                            // Add Brewer Registration to List as input for interface
                            lBrewerRegistrationsinCLM.add(oBrewerRegistration.Id);
                            system.debug(oBrewerRegistration.Id);
                    	}
                	}
           		}
            }
        }
        system.debug('lBrewerRegistrationsinCLM.size()'+lBrewerRegistrationsinCLM.size());
        if (lBrewerRegistrationsinCLM.size()>0)
        {
            UpdateBrewerRegistrationsCLM(lBrewerRegistrationsinCLM);
            system.debug('Call Interface');
        }
    }

    @future
    public static void UpdateBrewerRegistrationsCLM(List<ID> lBrewerRegistrationsinCLMids)
    {
        List<Brewer_Registration__C> lBrewerRegsUpdate = [SELECT Id, CLM_Welcome_Mail_Sent__c, Send_Welcome_Email__c,Consumer_Country__c FROM Brewer_Registration__C WHERE Id in: lBrewerRegistrationsinCLMids]; 
        for (Brewer_Registration__C BR : lBrewerRegsUpdate)
        {
            // Empty Quick Message
            BR.CLM_Welcome_Mail_Sent__c = system.today();
            BR.Send_Welcome_Email__c = true;
        }
        update lBrewerRegsUpdate;
    }
}