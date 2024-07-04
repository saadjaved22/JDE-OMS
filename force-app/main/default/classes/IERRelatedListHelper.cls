public class IERRelatedListHelper {
  public static String getMarketingCloudOAuthToken(
    String clientId,
    String clientSecret
  ) {
    String requestBody = makeJSONPostCall(
      'https://mcsf6d9ncc-158z6s2rjldt79x94.auth.marketingcloudapis.com/v2/token',
      JSON.serialize(
        new Map<String, String>{
          'grant_type' => 'client_credentials',
          'client_id' => clientId,
          'client_secret' => clientSecret
        }
      )
    );
    system.debug('IER' + requestBody);
    return requestBody;
  }

  private static String makeJSONPostCall(String endPoint, String soapBody) {
    Http h = new Http();
    HttpRequest r = new HttpRequest();
    r.setTimeout(60000);
    r.setEndpoint(endPoint);
    r.setMethod('POST');
    r.setHeader('Content-type', 'application/json');
    r.setBody(soapBody);
    HttpResponse res = h.send(r);
    Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
      res.getBody()
    );
    system.debug('response' + response);
    return String.valueof(response.get('access_token'));
  }

  private static String makeHTTPXMLPost(String endPoint, String soapBody) {
    Http h = new Http();
    HttpRequest r = new HttpRequest();
    r.setTimeout(60000);
    r.setEndpoint(endPoint);
    r.setHeader('SOAPAction', 'Retrieve');
    r.setHeader('Accept', 'text/xml');
    r.setHeader('Content-type', 'text/xml');
    r.setHeader('charset', 'UTF-8');
    r.setMethod('GET');
    r.setBody(soapBody);
    system.debug(r);
    HttpResponse res = h.send(r);
    return res.getBody();
  }

  public static String performMCAction(
    String accessToken,
    String subscriberKey
  ) {
    String soapEnvelopeTemplate =
      '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
      '<soapenv:Header>' +
      '<fueloauth>' +
      accessToken +
      '</fueloauth>' +
      '</soapenv:Header>' +
      '<soapenv:Body>' +
      '<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
      '<RetrieveRequest>' +
      '<ObjectType>DataExtensionObject[EmailResults_Master]</ObjectType>' +
      '<Properties>SubscriberId</Properties>' +
      '<Properties>SubscriberKey</Properties>' +
      '<Properties>JobId</Properties>' +
      '<Properties>BatchId</Properties>' +
      '<Properties>SendDate</Properties>' +
      '<Properties>Domain</Properties>' +
      '<Properties>Num_Opens</Properties>' +
      '<Properties>Unique_Opens</Properties>' +
      '<Properties>num_Clicks</Properties>' +
      '<Properties>Unique_Clicks</Properties>' +
      '<Properties>num_Bounces</Properties>' +
      '<Properties>Bounce_User_Unknown</Properties>' +
      '<Properties>Bounce_Domain_Unknown</Properties>' +
      '<Properties>Bounce_Blocked</Properties>' +
      '<Properties>Bounce_Inactive_Account</Properties>' +
      '<Properties>Bounce_Network_Error</Properties>' +
      '<Properties>Bounce_Other</Properties>' +
      '<Properties>Last_Open</Properties>' +
      '<Properties>Last_CLick</Properties>' +
      '<Properties>Last_Bounce</Properties>' +
      '<Properties>EmailName</Properties>' +
      '<Properties>SubjectLine</Properties>' +
      '<Properties>FromName</Properties>' +
      '<Properties>FromAddress</Properties>' +
      '<Properties>TriggeredSendId</Properties>' +
      '<Properties>ErrorCode</Properties>' +
      '<Properties>ListId</Properties>' +
      '<Properties>JourneyName</Properties>' +
      '<Properties>LastPublishedDate</Properties>' +
      '<Filter xsi:type="SimpleFilterPart">' +
      '<Property>SubscriberKey</Property>' +
      '<SimpleOperator>equals</SimpleOperator>' +
      '<Value>' +
      subscriberKey +
      '</Value>' +
      '</Filter>' +
      '</RetrieveRequest>' +
      '</RetrieveRequestMsg>' +
      '</soapenv:Body>' +
      '</soapenv:Envelope>';
    //IERRelatedList__c setting = IERRelatedList__c.getInstance();
    String endpointSoap = 'https://mcsf6d9ncc-158z6s2rjldt79x94.soap.marketingcloudapis.com//Service.asmx';
    //setting.Endpoint_SOAP__c;
    return makeHTTPXMLPost(endpointSoap, soapEnvelopeTemplate);
  }

  public static XMLParserResult XMLParser(String rawXML) {
    XMLParserResult returnResult = new XMLParserResult();
    List<Map<String, String>> content = new List<Map<String, String>>();
    Dom.Document doc = new Dom.Document();
    doc.load(rawXML);
    Dom.XMLNode root = doc.getRootElement();
    Dom.XmlNode[] rootElements = root.getChildren();
    Dom.XmlNode[] retrieveResponse = rootElements[1].getChildren();
    Dom.XmlNode[] innerRetrieveResponse = retrieveResponse[0].getChildren();
    system.debug(rootElements);
    system.debug(retrieveResponse);
    system.debug(innerRetrieveResponse);

    if (retrieveResponse[0].getName() == 'Fault') {
      returnResult.status = 'Fault';
      return returnResult;
    } else {
      for (Dom.XMLNode child : innerRetrieveResponse) {
        system.debug(child);
        if (child.getName() == 'Results') {
          Dom.XmlNode Properties = child.getChildElement(
            'Properties',
            'http://exacttarget.com/wsdl/partnerAPI'
          );
          List<Map<String, String>> recordFields = new List<Map<String, String>>();
          Map<String, String> recordDetails = new Map<String, String>();
          for (Dom.XMLNode fields : Properties.getChildren()) {
            string fieldName = fields.getChildElement(
                'Name',
                'http://exacttarget.com/wsdl/partnerAPI'
              )
              .getText();
            string fieldValue = fields.getChildElement(
                'Value',
                'http://exacttarget.com/wsdl/partnerAPI'
              )
              .getText();
            recordDetails.put(fieldName, fieldValue);
          }
          content.add(recordDetails);
        } else if (child.getName() == 'Results') {
        }
      }
      returnResult.status = 'Success';
      returnResult.result = content;
      system.debug(returnResult);
      return returnResult;
    }
  }

  public static Map<Integer, list<IERRelatedListHelper.IERWrapperClass>> assignToPageMap(
    Decimal pageSetting,
    List<IERRelatedListHelper.IERWrapperClass> tempList
  ) {
    //Initiation of Page Number, this will also be the Key or Index of the PageMap
    Map<Integer, list<IERRelatedListHelper.IERWrapperClass>> pageMap = new Map<Integer, list<IERRelatedListHelper.IERWrapperClass>>();
    integer pageNum = 0;

    //iterate for temporary list which contains records from the query
    for (IERRelatedListHelper.IERWrapperClass record : tempList) {
      //first instance of iteration goes in here since the pageMap size is 0
      if (
        pageMap.size() ==
        0 //pageMap: map of integer and a list of records
      ) {
        //Put the record into PageMap then set PageNum as Key
        pageMap.put(
          pageNum,
          new List<IERRelatedListHelper.IERWrapperClass>{ record }
        );
      } else {
        if (
          pageMap.get(pageNum).size() <
          pageSetting //is pageNum < page size from Custom Setting
        ) {
          pageMap.get(pageNum).add(record); //add the record to the value which is a list
        } else {
          //go to next page
          pageNum++; //add 1 page throught iteration if size of the last value exceeds the page size setting
          pageMap.put(
            pageNum,
            new List<IERRelatedListHelper.IERWrapperClass>{ record }
          ); //put record into new list
        }
      }
    }
    return pageMap;
  }

  public static String checkEmptyString(String toBeConverted) {
    String checkedValue;
    if (String.isNotBlank(toBeConverted)) {
      checkedValue = toBeConverted;
    } else {
      checkedValue = '';
    }
    return checkedValue;
  }

  /*
    public class IERWrapperClass{
        public String Name{get; set;}
        public String SubjectLine{get; set;}
        public String FromName{get; set;}
        public String FromAddress{get; set;}
        public Datetime DateSent{get; set;}
        public String DateOpened{get; set;}
        public Boolean HardBounce{get; set;}
        public String JourneyName{get; set;}
    }
    */
  public class XMLParserResult {
    public List<Map<String, String>> result;
    public string status;
  }

  public class IERWrapperClass implements Comparable {
    public String Name { get; set; }
    public String SubjectLine { get; set; }
    public String FromName { get; set; }
    public String FromAddress { get; set; }
    public Datetime DateSent { get; set; }
    public Datetime DateOpened { get; set; }
    public String DateSentSTR { get; set; }
    public String DateOpenedSTR { get; set; }
    public Boolean HardBounce { get; set; }
    public String JourneyName { get; set; }

    // Constructor
    public IERWrapperClass(
      String NameArg,
      String SubjectLineArg,
      String FromNameArg,
      String FromAddressArg,
      Datetime DateSentArg,
      Datetime DateOpenedArg,
      Boolean HardBounceArg,
      String JourneyNameArg
    ) {
      Name = NameArg;
      SubjectLine = SubjectLineArg;
      FromName = FromNameArg;
      FromAddress = FromAddressArg;
      DateSent = DateSentArg;
      DateOpened = DateOpenedArg;
      HardBounce = HardBounceArg;
      JourneyName = JourneyNameArg;
    }

    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
      /*
            IERWrapperClass compareToEmp = (IERWrapperClass)compareTo;
            if (DateSent == compareToEmp.DateSent) return 0;
            if (DateSent > compareToEmp.DateSent) return 1;
            return -1;        
            
            */
      Integer returnValue = 0;
      IERWrapperClass compareToIER = (IERWrapperClass) compareTo;
      if (DateSent > compareToIER.DateSent) {
        // Set return value to a positive value.
        returnValue = -1;
      } else if (DateSent < compareToIER.DateSent) {
        // Set return value to a negative value.
        returnValue = 1;
      }

      return returnValue;
    }
  }
  public class IERWrapperforLTNGClass implements Comparable {
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String SubjectLine { get; set; }
    @AuraEnabled
    public String FromName { get; set; }
    @AuraEnabled
    public String FromAddress { get; set; }
    @AuraEnabled
    public Datetime DateSent { get; set; }
    @AuraEnabled
    public Datetime DateOpened { get; set; }
    @AuraEnabled
    public String DateSentSTR { get; set; }
    @AuraEnabled
    public String DateOpenedSTR { get; set; }
    @AuraEnabled
    public Boolean HardBounce { get; set; }
    @AuraEnabled
    public String HardBounceSTR { get; set; }
    @AuraEnabled
    public String JourneyName { get; set; }

    // Constructor
    public IERWrapperforLTNGClass(
      String NameArg,
      String SubjectLineArg,
      String FromNameArg,
      String FromAddressArg,
      Datetime DateSentArg,
      Datetime DateOpenedArg,
      Boolean HardBounceArg,
      String HardBounceSTRArg,
      String JourneyNameArg
    ) {
      Name = NameArg;
      SubjectLine = SubjectLineArg;
      FromName = FromNameArg;
      FromAddress = FromAddressArg;
      DateSent = DateSentArg;
      DateOpened = DateOpenedArg;
      HardBounce = HardBounceArg;
      HardBounceSTR = HardBounceSTRArg;
      JourneyName = JourneyNameArg;
    }

    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
      /*
            IERWrapperClass compareToEmp = (IERWrapperClass)compareTo;
            if (DateSent == compareToEmp.DateSent) return 0;
            if (DateSent > compareToEmp.DateSent) return 1;
            return -1;        
            
            */
      Integer returnValue = 0;
      IERWrapperforLTNGClass compareToIER = (IERWrapperforLTNGClass) compareTo;
      if (DateSent > compareToIER.DateSent) {
        // Set return value to a positive value.
        returnValue = -1;
      } else if (DateSent < compareToIER.DateSent) {
        // Set return value to a negative value.
        returnValue = 1;
      }

      return returnValue;
    }
  }
  public static string IERDateFormat(DateTime dateInput) {
    if (dateInput == null) {
      return null;
    } else {
      return dateInput.format('dd-MM-yyyy HH:mm', 'UTC');
    }
  }
  public static Datetime IERDateParser(String unformattedDate) {
    system.debug(unformattedDate);
    if (string.isBlank(unformattedDate)) {
      return null;
    } else {
      /*
            system.debug('0');
            DateTime currenttime = Datetime.valueOf(unformattedDate);
            system.debug('1');
            String strConvertedDate = currenttime.format('YYYY-MM-DD hh:mm:ss', 'Europe/Amsterdam');
             system.debug('2');
            DateTime formattedDate = Datetime.valueOf(strConvertedDate);
            system.debug('3');
            system.debug(formattedDate);
            return formattedDate;
			*/
      Map<String, String> dateValues = new Map<String, String>();
      unformattedDate = unformattedDate.replace(' ', '/').replace(':', '/');
      String[] dateDivided = unformattedDate.split('/');

      string year = dateDivided[2];
      string month = dateDivided[0];
      string day = dateDivided[1];
      string hour;

      if (dateDivided[6] == 'PM') {
        hour = string.valueof(integer.valueof(dateDivided[3]) + 12);
      } else {
        //hour = dateDivided[3];
        hour = string.valueOf(integer.valueOf(dateDivided[3]) + 7);
      }
      string minute = dateDivided[4];
      string second = dateDivided[5];
      string stringDate =
        year +
        '-' +
        month +
        '-' +
        day +
        ' ' +
        hour +
        ':' +
        minute +
        ':' +
        second;
      return Datetime.valueOfGmt(stringDate);
    }
  }
  public static string checkIfTrue(Boolean check) {
    String returnValue = 'X';
    if (check) {
      returnValue = '√';
    }

    return returnValue;
  }
}
