public class IERRelatedListController {
  public List<IERRelatedListHelper.IERWrapperClass> individualEmailResults {
    get;
    set;
  }
  public boolean firstbutton { get; set; }
  public boolean prevbutton { get; set; }
  public boolean nextbutton { get; set; }
  public boolean lastbutton { get; set; }
  public Integer currentPage { get; set; }
  public Integer numberOfPages { get; set; }
  public boolean renderPage { get; set; }
  public boolean successCall { get; set; }
  map<Integer, list<IERRelatedListHelper.IERWrapperClass>> pageMap;
  IERRelatedList__c setting = IERRelatedList__c.getInstance();
  string clientId = setting.Client_ID__c;
  string clientSecret = setting.Client_Secret__c;
  Decimal pageSetting = setting.Page_Size__c;
  Boolean showSetting = setting.Show_IER_Related_List__c;

  public IERRelatedListController(ApexPages.StandardController controller) {
    renderPage =
      (string.isNotBlank(clientId) || string.isNotBlank(clientSecret)) &&
      showSetting;
    Account acc = (account) controller.getRecord();
    List<IERRelatedListHelper.IERWrapperClass> retrievedIER;
    if (String.isBlank(acc.Id)) {
      retrievedIER = null;
      successCall = false;
    } else {
      individualEmailResults = new List<IERRelatedListHelper.IERWrapperClass>();
      string accessToken = IERRelatedListHelper.getMarketingCloudOAuthToken(
        clientId,
        clientSecret
      );
      string responseXML = IERRelatedListHelper.performMCAction(
        accessToken,
        acc.ContactID__pc
      );
      List<Map<String, String>> IERValues = new List<Map<String, String>>();
      IERRelatedListHelper.XMLParserResult parserResult = new IERRelatedListHelper.XMLParserResult();
      parserResult = IERRelatedListHelper.XMLParser(responseXML);
      if (parserResult.status == 'Success') {
        IERValues = parserResult.result;
        successCall = true;
      } else {
        successCall = false;
      }
      if (pageSetting == 0 || pageSetting == null) {
        pageSetting = 4;
      }

      //retrievedIER = new List<IERRelatedListHelper.IERWrapperClass>();
      retrievedIER = new List<IERRelatedListHelper.IERWrapperClass>();
      for (Map<String, String> IER : IERValues) {
        /*
                IERRelatedListHelper.IERWrapperClass IERRec = new IERRelatedListHelper.IERWrapperClass();
                IERRec.Name = IERRelatedListHelper.checkEmptyString(IER.get('EmailName'));
                IERRec.SubjectLine = IERRelatedListHelper.checkEmptyString(IER.get('SubjectLine'));
                IERRec.FromName = IERRelatedListHelper.checkEmptyString(IER.get('FromName'));
                IERRec.FromAddress = IERRelatedListHelper.checkEmptyString(IER.get('FromAddress'));
                IERRec.DateSent = IERRelatedListHelper.IERDateParser(IER.get('SendDate'));
                IERRec.DateOpened = IERRelatedListHelper.checkEmptyString(IER.get('Last_Open'));
                IERRec.HardBounce = String.isNotBlank(IER.get('num_Bounces'));
                IERRec.JourneyName = IERRelatedListHelper.checkEmptyString(IER.get('JourneyName'));
        */
        retrievedIER.add(
          new IERRelatedListHelper.IERWrapperClass(
            IERRelatedListHelper.checkEmptyString(IER.get('EmailName')),
            IERRelatedListHelper.checkEmptyString(IER.get('SubjectLine')),
            IERRelatedListHelper.checkEmptyString(IER.get('FromName')),
            IERRelatedListHelper.checkEmptyString(IER.get('FromAddress')),
            IERRelatedListHelper.IERDateParser(IER.get('SendDate')),
            IERRelatedListHelper.IERDateParser(IER.get('Last_Open')),
            String.isNotBlank(IER.get('num_Bounces')),
            IERRelatedListHelper.checkEmptyString(IER.get('JourneyName'))
          )
        );
      }
    }

    if (retrievedIER != null && retrievedIER.size() > 0) {
      retrievedIER.sort();
      for (IERRelatedListHelper.IERWrapperClass IER : retrievedIER) {
        IER.DateSentSTR = IERRelatedListHelper.IERDateFormat(IER.DateSent);
        IER.DateOpenedSTR = IERRelatedListHelper.IERDateFormat(IER.DateOpened);
      }
      pageMap = IERRelatedListHelper.assignToPageMap(pageSetting, retrievedIER);
      numberOfPages = pageMap.size();
      moveToFirst();
    } else {
      nextbutton = true;
      prevbutton = true;
      firstbutton = true;
      lastbutton = true;
      individualEmailResults = null;
    }
  }
  public PageReference moveToFirst() {
    currentPage = 0;
    individualEmailResults.clear();
    individualEmailResults.addAll(pageMap.get(currentPage));
    checkPage();
    return null;
  }
  public PageReference moveToPrev() {
    currentPage -= 1;
    individualEmailResults.clear();
    individualEmailResults.addAll(pageMap.get(currentPage));
    checkPage();
    return null;
  }
  public PageReference moveToNext() {
    currentPage += 1;
    individualEmailResults.clear();
    individualEmailResults.addAll(pageMap.get(currentPage));
    checkPage();
    return null;
  }
  public PageReference moveToLast() {
    currentPage = pageMap.size() - 1;
    individualEmailResults.clear();
    individualEmailResults.addAll(pageMap.get(currentPage));
    checkPage();
    return null;
  }
  public void checkPage() {
    if (currentPage == pageMap.size() - 1) {
      nextbutton = true;
      lastbutton = true;
    } else {
      nextbutton = false;
      lastbutton = false;
    }
    if (currentPage == 0) {
      prevbutton = true;
      firstbutton = true;
    } else {
      prevbutton = false;
      firstbutton = false;
    }
  }
}
