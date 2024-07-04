@isTest
global class IERHTTPCalloutMock implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    if (
      req.getEndpoint() ==
      'https://mcsf6d9ncc-158z6s2rjldt79x94.auth.marketingcloudapis.com/v2/token'
    ) {
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"access_token":"testToken", "expiresIn":"3479"}');
      res.setStatusCode(200);
    } else if (
      req.getEndpoint() ==
      'https://mcsf6d9ncc-158z6s2rjldt79x94.soap.marketingcloudapis.com//Service.asmx'
    ) {
      res.setHeader('Content-type', 'text/xml');
      res.setBody(testXml);
      res.setStatusCode(200);
    }
    return res;
  }
  public static String testXml =
    '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
    '<soap:Header>' +
    '<wsa:Action>RetrieveResponse</wsa:Action>' +
    '<wsa:MessageID>urn:uuid:9567d2dd-f575-4596-8171-396b144d955e</wsa:MessageID>' +
    '<wsa:RelatesTo>urn:uuid:c181d95a-b736-44e6-9ee1-2f3e6088c0a8</wsa:RelatesTo>' +
    '<wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To>' +
    '<wsse:Security>' +
    '<wsu:Timestamp wsu:Id="Timestamp-040f45a7-8792-4bc4-b834-f79af7efcb16">' +
    '<wsu:Created>2018-08-29T15:01:34Z</wsu:Created>' +
    '<wsu:Expires>2018-08-29T15:06:34Z</wsu:Expires>' +
    '</wsu:Timestamp>' +
    '</wsse:Security>' +
    '</soap:Header>' +
    '<soap:Body>' +
    '<RetrieveResponseMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
    '<OverallStatus>OK</OverallStatus>' +
    '<RequestID>e35536fd-f230-4b0f-bb42-61d7e8bbcc5c</RequestID>' +
    '<Results xsi:type="DataExtensionObject">' +
    '<PartnerKey xsi:nil="true"/>' +
    '<ObjectID xsi:nil="true"/>' +
    '<Type>DataExtensionObject</Type>' +
    '<Properties>' +
    '<Property>' +
    '<Name>SubscriberId</Name>' +
    '<Value>66023944</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>SubscriberKey</Name>' +
    '<Value>0031l000001o8f6AAA</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>JobId</Name>' +
    '<Value>69720</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>SendDate</Name>' +
    '<Value>8/27/2018 4:06:37 AM</Value>' +
    '</Property>' +
    '</Properties>' +
    '</Results>' +
    '<Results xsi:type="DataExtensionObject">' +
    '<PartnerKey xsi:nil="true"/>' +
    '<ObjectID xsi:nil="true"/>' +
    '<Type>DataExtensionObject</Type>' +
    '<Properties>' +
    '<Property>' +
    '<Name>SubscriberId</Name>' +
    '<Value>66023944</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>SubscriberKey</Name>' +
    '<Value>0031l000001o8f6AAA</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>num_Bounces</Name>' +
    '<Value>1</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>JobId</Name>' +
    '<Value>69720</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>SendDate</Name>' +
    '<Value>8/27/2018 4:06:37 PM</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>num_Clicks</Name>' +
    '<Value>1</Value>' +
    '</Property>' +
    '<Property>' +
    '<Name>FromName</Name>' +
    '<Value>testFromName</Value>' +
    '</Property>' +
    '</Properties>' +
    '</Results>' +
    '</RetrieveResponseMsg>' +
    '</soap:Body>' +
    '</soap:Envelope>';
}
