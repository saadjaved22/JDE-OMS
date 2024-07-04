/*Author: ConsumerStack class is a web service class.
 This web service class contains 3 methods which are called by Blokker POS application via SAP PO layer*/
global class ConsumerStack {
  /*Blokker POS calls this method when it to create new loyalty consumer record.*/
  webService static Consumer.ConsumerResult CreateLoyaltyConsumer(
    Consumer.ConsumerInfo consInfo
  ) {
    return ConsumerStackHelper.CreateLoyaltyConsumer(consInfo);
  }

  /*Blokker POS calls this method when it to change consumer details.*/
  webService static Consumer.ConsumerResult ChangeConsumerDetails(
    Consumer.ConsumerInfo consInfo
  ) {
    return ConsumerStackHelper.changeConsumerDetails(consInfo);
  }

  /*Blokker POS calls this method when it to upgrade newsletter consumer to Loyalty */
  webService static Consumer.ConsumerResult UpgradeToLoyaltyAccount(
    Consumer.ConsumerInfo consInfo
  ) {
    return ConsumerStackHelper.upgradeToLoyaltyAccount(consInfo);
  }
}
