public with sharing class TransactionId {
  public static String generateID() {
    String transId =
      String.valueof(datetime.now().getTime()) +
      String.valueOf(Math.roundToLong(Math.Random() * 999999)).leftPad(7, '0');

    return transId;
  }
}
