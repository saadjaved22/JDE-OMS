global with sharing class RestServiceUtils {
  global static List<RestServiceErrorMessage> ConvertExceptionList(
    List<String> exceptionList
  ) {
    List<RestServiceErrorMessage> errorMessageList = new List<RestServiceErrorMessage>();
    for (String exc : exceptionList) {
      RestServiceErrorMessage errorMessage = new RestServiceErrorMessage();
      errorMessage.message = exc;
      errorMessageList.add(errorMessage);
    }
    return errorMessageList;
  }

  global class RestServiceErrorMessage {
    public String message;
  }
}
