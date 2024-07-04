public class ConsumerStackHelper {
  private static Boolean checkArgumentsAreMissing(
    Consumer.ConsumerInfo consInfo
  ) {
    if (consInfo == null) {
      return true;
    }
    return false;
  }

  /*This method is called from ConsumerStack class to create a loyalty consumer in Salesforce. */
  public static Consumer.ConsumerResult createLoyaltyConsumer(
    Consumer.ConsumerInfo consInfo
  ) {
    Consumer.ConsumerResult resp = new Consumer.ConsumerResult();

    if (consInfo != null && string.isNotBlank(string.valueOf(consInfo.id))) {
      resp.status = Label.ArgumentsMissing;
      return resp;
    }

    if (checkArgumentsAreMissing(consInfo)) {
      resp.status = Label.ArgumentsMissing;
      return resp;
    }

    try {
      GetConsumerDetailsHelper.EmailValidity emailVal = new GetConsumerDetailsHelper.EmailValidity();

      emailVal = GetConsumerDetailsHelper.checkEmail_ExternalID(consInfo);
      system.debug('Email Validity is ' + emailVal);
      if (emailVal != null) {
        if (emailVal.isConsumerExist) {
          resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
          resp.status = Label.ConsumerExist;
          return resp;
        }
        if (!emailVal.isEmailValid) {
          resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
          resp.status = Label.ArgumentsMissing;
          return resp;
        } else if (emailVal.isExternalIDExist) {
          resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
          resp.status = Label.ArgumentsMissing;
          return resp;
        }

        Account acc = new Account();
        acc = GetConsumerDetailsHelper.populateAccountValues(consInfo);
        acc.Email_Confirmed__c = true;
        resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
        String accId = GetConsumerDetailsHelper.insertConsumer(
            new List<Account>{ acc }
          )[0]
          .Id;
        GetConsumerDetailsHelper.strQuery =
          GetConsumerDetailsHelper.strQuery +
          ' WHERE ID = \'' +
          accId +
          '\'';

        resp.listConsumerRecord.add(
          GetConsumerDetailsHelper.populateConsumerData(
            GetConsumerDetailsHelper.queryConsumer(
              GetConsumerDetailsHelper.strQuery
            )[0]
          )
        );
        resp.status = Label.SuccessMessage;
      } else {
        resp.status = Label.UnknownError;
        return resp;
      }
    } catch (Exception ex) {
      system.debug('enters in exception' + ex.getMessage());
      resp.status = ex.getMessage();
    }
    return resp;
  }
  /*This method is called from ConsumerStack class to change defined attributes on consumer records. */
  public static Consumer.ConsumerResult changeConsumerDetails(
    Consumer.ConsumerInfo consInfo
  ) {
    GetConsumerDetailsHelper.ISLOYALTY = false;
    system.debug('consInfo is ' + consInfo);
    Consumer.ConsumerResult resp = new Consumer.ConsumerResult();
    if (checkArgumentsAreMissing(consInfo)) {
      resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
      resp.status = Label.ArgumentsMissing;
      return resp;
    }

    /*Check if we can include email Validity*/

    try {
      Account acc = new Account();
      acc = GetConsumerDetailsHelper.populateAccountValues(consInfo);
      resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
      GetConsumerDetailsHelper.upsertConsumer(new List<Account>{ acc });
      GetConsumerDetailsHelper.strQuery =
        GetConsumerDetailsHelper.strQuery +
        ' WHERE Customer_ID__c = ' +
        acc.Customer_ID__c;

      resp.listConsumerRecord.add(
        GetConsumerDetailsHelper.populateConsumerData(
          GetConsumerDetailsHelper.queryConsumer(
            GetConsumerDetailsHelper.strQuery
          )[0]
        )
      );
      resp.status = Label.SuccessMessage;
    } catch (Exception ex) {
      resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
      resp.status = ex.getMessage();
    }
    return resp;
  }
  /*This method is called from ConsumerStack class to upgrade existing consumer to Loyalty consumer.*/
  public static Consumer.ConsumerResult upgradeToLoyaltyAccount(
    Consumer.ConsumerInfo consInfo
  ) {
    Consumer.ConsumerResult resp = new Consumer.ConsumerResult();

    if (
      checkArgumentsAreMissing(consInfo) ||
      string.isBlank(string.valueOf(consInfo.Id))
    ) {
      resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
      resp.status = Label.ArgumentsMissing;
      return resp;
    }
    try {
      Account acc = new Account();
      consInfo.IsLoyaltyMember = true;
      acc = GetConsumerDetailsHelper.populateAccountValues(consInfo);

      resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
      GetConsumerDetailsHelper.upsertConsumer(new List<Account>{ acc });

      GetConsumerDetailsHelper.strQuery =
        GetConsumerDetailsHelper.strQuery +
        ' WHERE Customer_ID__c = ' +
        acc.Customer_ID__c;
      resp.listConsumerRecord.add(
        GetConsumerDetailsHelper.populateConsumerData(
          GetConsumerDetailsHelper.queryConsumer(
            GetConsumerDetailsHelper.strQuery
          )[0]
        )
      );
      resp.status = Label.SuccessMessage;
    } catch (Exception ex) {
      resp.listConsumerRecord = new List<Consumer.ConsumerRecord>();
      resp.status = ex.getMessage();
    }

    return resp;
  }
}
