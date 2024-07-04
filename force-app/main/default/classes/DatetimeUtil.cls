/**
 * This util may be pointless, because miliseconds are lost when stored in database...
 * https://success.salesforce.com/ideaView?id=08730000000LhBNAA0
 * unless saved as a String
 *
 * @author piotr.tugeman@emark.com
 */
global class DatetimeUtil {
  /**
   * Use insted of Datetime.valueOfGmt().
   *
   * @return GMT datetime. 3 formats supported:
   * 'yyyy-MM-dd HH:mm:ss'
   * ISO 8601:
   * 'yyyy-MM-ddTHH:mm:ssZ'
   * 'yyyy-MM-ddTHH:mm:ss.SSSZ'
   */
  public static DateTime valueOfGmt(String dateTimeString) {
    if (String.isEmpty(dateTimeString)) {
      throw new UnsupportedOperationException(
        '[DatetimeUtil.valueOfGmt] Can\'t parse null or empty values. dateTimeString:' +
        dateTimeString
      );
    }

    //Datetime.valueOfGmt is broken - it will ignore milliseconds (setting them to 000) thats why below logic is necessary.

    //ISO 8601:
    if (dateTimeString.contains('T') && dateTimeString.contains('Z')) {
      //WTF - date should be in double quotes, otherwise deserialized as Midnight 1st January without throwing errors...
      String datetoDeserialize = '"' + dateTimeString + '"';
      return (DateTime) JSON.deserialize(datetoDeserialize, DateTime.class);
    }

    //'yyyy-MM-dd HH:mm:ss':
    return Datetime.valueOfGmt(dateTimeString);
  }

  public static String to_ISO_8601_String(Datetime datetimeToFormat) {
    String isoDateWithQuotes = JSON.serialize(datetimeToFormat);
    String isoDate = isoDateWithQuotes.remove('"');
    return isoDate;
  }

  public static String now_ISO_8601_String() {
    DateTime nowToFormat = DateTime.now();
    return DatetimeUtil.to_ISO_8601_String(nowToFormat);
  }

  //public static String to_SOQL_String( Datetime datetimeToFormat ){
  //	String isoDateWithQuotes = JSON.serialize( datetimeToFormat );
  //	String isoDate = isoDateWithQuotes.remove('"');
  //	return isoDate;
  //}
}
