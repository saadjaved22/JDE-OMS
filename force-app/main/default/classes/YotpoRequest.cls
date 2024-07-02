public class YotpoRequest {
    /** 
     * https://apidocs.yotpo.com/reference/about-unsubscribers
     * 
     * By default, all Yotpo customers are opted-in/subscribed and unsubscribers are customers who unsubscribed themselves from one or more Yotpo emails.
     * that means, if we want to remove a set of email addresses from email distribution lists we need to create entries for them on unsubscribe list
    */
    public static final String TOKEN_ENDPOINT = 'https://api.yotpo.com/oauth/token';
    public static final String SUBSCRIBE_ENDPOINT = 'https://api.yotpo.com/apps/{{client_id}}/unsubscribers/mass_delete';
    public static final String UNSUBSCRIBE_ENDPOINT = 'https://api.yotpo.com/apps/{{client_id}}/unsubscribers/mass_create';

    public static final Integer REQUEST_TIMEOUT = 120000;

    public class TokenResponse
    {
        public String access_token;
        public String token_type;
    }

    public class subscribeRequest
    {
        public String utoken;
        public Boolean validate_data;
        public Boolean async;
        public Map<Integer, String[]> email_list;
    }

    public class unsubscribeRequest
    {
        public String utoken;
        public Boolean validate_data;
        public Boolean async;
        public Map<Integer, String[]> email_list;
    }

    public static Map<String, YotpoAPI__c> getYotpoCredentials() {
		List<YotpoAPI__c> yotpoCredentialRecords = [
			SELECT Id, Country__c, Language__c, Brand__c, Client_Id__c, Client_Secret__c, Access_Token__c
            FROM YotpoAPI__c ORDER BY Country__c, Language__c, Brand__c
		];

		Map<String, YotpoAPI__c> yotpoCredentialMap = new Map<String, YotpoAPI__c>();
        String key = '';

		for(YotpoAPI__c row : yotpoCredentialRecords){
            key = row.Country__c + '_' + row.Language__c + '_' + row.Brand__c;
			yotpoCredentialMap.put(key, row);
		}

		return yotpoCredentialMap;
	}

    public static Map<String, String[]> getAccountsMap(List<Id> subscriberIds) {
        List<Account> subscribeList = [SELECT Id, PersonEmail, Country__c, Brand__c, Language__c FROM Account WHERE Id IN :subscriberIds];
        Map<String, String[]> subscribersMap = new Map<String, String[]>();
        String key = '';

        System.debug('YotpoRequest: Gathering subscribers...');

        //Generate users Map
        for(Account row : subscribeList) {
            if(row.Country__c != null && row.Language__c != null && row.Brand__c != null){
                key = row.Country__c + '_' + row.Language__c + '_' + row.Brand__c;

                if(!subscribersMap.containsKey(key)){
                    subscribersMap.put(key, new List<String>());
                }

                subscribersMap.get(key).add(row.PersonEmail);
            } else {
                System.debug('YotpoRequest: Country, Language or Brand is missing for ' + row.PersonEmail);
            }
        }

        System.debug('YotpoRequest: Done. Map size = ' + subscribersMap.size());
        return subscribersMap;
    }

    public static String getToken(YotpoAPI__c credentials) {
        String access_token = '';
        HttpRequest request = new HttpRequest();
        String endpoint = TOKEN_ENDPOINT + '?client_id=' + credentials.Client_Id__c + '&client_secret=' + credentials.Client_Secret__c + '&grant_type=client_credentials';

        try {
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setTimeout(REQUEST_TIMEOUT);
            Http httpProtocol = new Http();
            HttpResponse response = httpProtocol.send(request);
    
            if (response.getStatusCode() == 200) {
                TokenResponse tokenResponse = (TokenResponse)JSON.deserialize(response.getBody(), TokenResponse.class);
                access_token = tokenResponse.access_token;
    
                System.debug('YotpoRequest: Token = ' + access_token);
            } else {
                System.debug('YotpoRequest: Error obtaining token!');
            }
        } catch(CalloutException  e) {
            System.debug('YotpoRequest: Exception Occurred in getToken callout: ' + e.getMessage());
        }
        catch(Exception e)
        {
            System.debug('YotpoRequest: Exception Occurred in getToken: ' + e.getMessage());
        }

        return access_token;
    }

    @future (callout=true)
    public static void subscribeUsers(List<Id> subscriberIds){
        Map<String, YotpoAPI__c> yotpoCredentialsMap = getYotpoCredentials();
        Map<String, String[]> subscribersMap = getAccountsMap(subscriberIds);

        //Iterate through map
        for (String key : subscribersMap.keySet()) {
            if(yotpoCredentialsMap.containsKey(key)){
                YotpoAPI__c credentials = yotpoCredentialsMap.get(key);

                //getToken
                System.debug('YotpoRequest: Obtaining token for key = ' + key);

                String access_token = getToken(credentials);

                if (access_token != null && access_token != '') {
                    //sending subscribe request
                    System.debug('YotpoRequest: Sending subscribe request...');

                    try {
                        HttpRequest request = new HttpRequest();
                        request.setMethod('DELETE');
                        request.setHeader('Content-Type', 'application/json');
                        request.setEndpoint(SUBSCRIBE_ENDPOINT.replace('{{client_id}}', credentials.Client_Id__c));
                        request.setTimeout(REQUEST_TIMEOUT);
    
                        subscribeRequest body = new subscribeRequest();
                        body.utoken = access_token;
                        body.validate_data = true;
                        body.async = true;
                        body.email_list = new Map<Integer, String[]> {
                            1 => subscribersMap.get(key)
                        };
    
                        request.setBody(JSON.serialize(body, true));
    
                        Http httpProtocol = new Http();
                        HttpResponse response = httpProtocol.send(request);
    
                        if (response.getStatusCode() == 200) {
                            System.debug('YotpoRequest: Success!');
                        } else {
                            System.debug('YotpoRequest: Error sending request!: ' + response.getBody());
                        }
                    } catch(CalloutException  e) {
                        System.debug('YotpoRequest: Exception Occurred in subscribeUsers callout: ' + e.getMessage());
                    }
                    catch(Exception e)
                    {
                        System.debug('YotpoRequest: Exception Occurred in subscribeUsers: ' + e.getMessage());
                    }
                 } else {
                    System.debug('YotpoRequest: Token error for key = ' + key);
                 }
            } else {
                System.debug('YotpoRequest: ' + key + ' not found in YotpoAPI custom settings');
            }
        }
    }

    @future (callout=true)
    public static void unsubscribeUsers(List<Id> subscriberIds){
        Map<String, YotpoAPI__c> yotpoCredentialsMap = getYotpoCredentials();
        Map<String, String[]> subscribersMap = getAccountsMap(subscriberIds);

        //Iterate through map
        for (String key : subscribersMap.keySet()) {
            if(yotpoCredentialsMap.containsKey(key)){
                YotpoAPI__c credentials = yotpoCredentialsMap.get(key);

                //getToken
                System.debug('YotpoRequest: Obtaining token for key = ' + key);

                String access_token = getToken(credentials);

                if (access_token != null && access_token != '') {

                    //sending subscribe request
                    System.debug('YotpoRequest: Sending unsubscribe request...');

                    try {
                        HttpRequest request = new HttpRequest();
                        request.setMethod('POST');
                        request.setHeader('Content-Type', 'application/json');
                        request.setEndpoint(UNSUBSCRIBE_ENDPOINT.replace('{{client_id}}', credentials.Client_Id__c));
                        request.setTimeout(REQUEST_TIMEOUT);
    
                        unsubscribeRequest body = new unsubscribeRequest();
                        body.utoken = access_token;
                        body.validate_data = true;
                        body.async = true;
                        body.email_list = new Map<Integer, String[]> {
                            1 => subscribersMap.get(key)
                        };
    
                        request.setBody(JSON.serialize(body, true));
    
                        Http httpProtocol = new Http();
                        HttpResponse response = httpProtocol.send(request);
    
                        if (response.getStatusCode() == 200) {
                            System.debug('YotpoRequest: Success!');
                        } else {
                            System.debug('YotpoRequest: Error sending request!: ' + response.getBody());
                        }
                    } catch(CalloutException  e) {
                        System.debug('YotpoRequest: Exception Occurred in unsubscribeUsers callout: ' + e.getMessage());
                    }
                    catch(Exception e)
                    {
                        System.debug('YotpoRequest: Exception Occurred in unsubscribeUsers: ' + e.getMessage());
                    }
                 } else {
                    System.debug('YotpoRequest: Token error for key = ' + key);
                 }
            } else {
                System.debug('YotpoRequest: ' + key + ' not found in YotpoAPI custom settings');
            }
        }
    }
}