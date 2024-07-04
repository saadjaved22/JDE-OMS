/*Author: GetConsumerDetailsStack class is a web service class.
 This web service class contains 5 methods which are called by Blokker POS application via SAP PO layer*/

global class GetConsumerDetailsStack {
  /*Blokker POS calls this method when it searches for consumer based on Postal code, LastName, email and house number.*/
  webService static Consumer.consumerResult SearchConsumers(
    Consumer.consumerSearch consInfo
  ) {
    return GetConsumerDetailsHelper.getConsumerData(consInfo);
  }
  /*Blokker POS calls this operation to search consumer record based on entered email address only. */
  webService static Consumer.ConsumerResult GetLoyaltyConsumerByConsumerId(
    Consumer.consumerSearch consInfo
  ) {
    return GetConsumerDetailsHelper.getConsumerData(consInfo);
  }
  /*This method searches consumer based on the consumer id received as part of the request. */
  webService static Consumer.ConsumerResult GetLoyaltyConsumerByCardNumber(
    Consumer.consumerSearch consInfo
  ) {
    return GetConsumerDetailsHelper.getConsumerData(consInfo);
  }
  /*This method searches the consume record based on the loyalty card number received as part of the request. */
  webService static Consumer.ConsumerResult SearchConsumersByEmailPart(
    Consumer.consumerSearch consInfo
  ) {
    return GetConsumerDetailsHelper.getConsumerData(consInfo);
  }
  /*To be removed from class after confirmation from Blokker stake holders*/
  webService static Consumer.ConsumerResult SearchConsumersByUserData(
    Consumer.consumerSearch consInfo
  ) {
    return GetConsumerDetailsHelper.getConsumerData(consInfo);
  }
}
