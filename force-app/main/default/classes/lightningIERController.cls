global class lightningIERController {
    @AuraEnabled  
    public static List<IERRelatedListHelper.IERWrapperforLTNGClass> lightningIER(Id accId) {
        Account acc = [SELECT ContactID__pc FROM Account WHERE Id =: accId]; 
        IERRelatedList__c setting = IERRelatedList__c.getInstance();    
        string clientId = setting.Client_ID__c;
        string clientSecret = setting.Client_Secret__c;
        Decimal pageSetting = setting.Page_Size__c;
        Boolean showSetting = setting.Show_IER_Related_List__c;
        List<IERRelatedListHelper.IERWrapperforLTNGClass> individualEmailResults = new List<IERRelatedListHelper.IERWrapperforLTNGClass>();
        individualEmailResults = new List<IERRelatedListHelper.IERWrapperforLTNGClass>();
        string accessToken = IERRelatedListHelper.getMarketingCloudOAuthToken(clientId,clientSecret);
        string responseXML = IERRelatedListHelper.performMCAction(accessToken, 
                                                                  acc.ContactId__pc);
        List<Map<String, String>> IERValues = new List<Map<String, String>>();
        IERRelatedListHelper.XMLParserResult parserResult = new IERRelatedListHelper.XMLParserResult();
        parserResult = IERRelatedListHelper.XMLParser(responseXML); 
        IERValues = parserResult.result;
        System.debug('hello world' + parserResult); 
        List<IERRelatedListHelper.IERWrapperforLTNGClass> retrievedIER;
        retrievedIER = new List<IERRelatedListHelper.IERWrapperforLTNGClass>();
        for(Map<String, String> IER : IERValues) {
            retrievedIER.add(new IERRelatedListHelper.IERWrapperforLTNGClass(IERRelatedListHelper.checkEmptyString(IER.get('EmailName')),
                                                                      IERRelatedListHelper.checkEmptyString(IER.get('SubjectLine')),
                                                                      IERRelatedListHelper.checkEmptyString(IER.get('FromName')),
                                                                      IERRelatedListHelper.checkEmptyString(IER.get('FromAddress')),
                                                                      IERRelatedListHelper.IERDateParser(IER.get('SendDate')),
                                                                      IERRelatedListHelper.IERDateParser(IER.get('Last_Open')),
                                                                      String.isNotBlank(IER.get('num_Bounces')),
                                                                      IERRelatedListHelper.checkIfTrue(String.isNotBlank(IER.get('num_Bounces'))),
                                                                      IERRelatedListHelper.checkEmptyString(IER.get('JourneyName'))));
        }
        
        if (retrievedIER != null && retrievedIER.size() > 0)
        {
            retrievedIER.sort();
            for(IERRelatedListHelper.IERWrapperforLTNGClass IER : retrievedIER){
                IER.DateSentSTR = IERRelatedListHelper.IERDateFormat(IER.DateSent);
                IER.DateOpenedSTR = IERRelatedListHelper.IERDateFormat(IER.DateOpened);
            }
        }
        return retrievedIER;   
        
    }
}