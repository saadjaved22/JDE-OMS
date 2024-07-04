public class HighcoRequest {
  public static final BoomiAPI__c API_SETTINGS = BoomiAPI__c.getOrgDefaults();

  @future(callout=true)
  public static void deleteUser(String email) {
    System.debug('sending delete request for user = ' + email);
    System.debug('settings = ' + API_SETTINGS);

    HttpRequest request = new HttpRequest();
    request.setMethod('DELETE');
    request.setHeader('Content-Type', 'application/json');

    Blob headerValue = Blob.valueOf(
      API_SETTINGS.Username__c + ':' + API_SETTINGS.Password__c
    );
    String authorizationHeader =
      'Basic ' + EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    // request.setHeader('Authorization', API_SETTINGS.Token__c);

    String url = API_SETTINGS.Endpoint_URL__c;
    url = url.replace('{partnerKey}', API_SETTINGS.Partner_Key__c);
    url = url.replace('{userEmail}', email /*'j.frusque@highco.fr'*/); // TODO
    request.setEndpoint(url);

    System.debug('endpoint url = ' + url);

    Http httpProtocol = new Http();
    HttpResponse response = httpProtocol.send(request);

    if (response.getStatusCode() == 200) {
      System.debug('success!');
    } else {
      System.debug('error!');
    }
    System.debug(response.getBody());
  }
}
