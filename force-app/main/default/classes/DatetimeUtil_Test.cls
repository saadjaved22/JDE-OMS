/**
 * @author piotr.tugeman@emark.com
 */
@isTest
private class DatetimeUtil_Test {
  @isTest
  static void test_valueOfGmt() {
    // under test:
    DateTime parsed = DatetimeUtil.valueOfGmt('2018-12-21 13:25:42'); //yyyy-MM-dd HH:mm:ss

    // assertions:
    System.assertEquals(
      2018,
      parsed.yearGmt(),
      'Request Datetime YEAR should be same as in setup.'
    );
    System.assertEquals(
      12,
      parsed.monthGmt(),
      'Request Datetime MONTH should be same as in setup.'
    );
    System.assertEquals(
      21,
      parsed.dayGmt(),
      'Request Datetime DAY should be same as in setup.'
    );
    System.assertEquals(
      13,
      parsed.hourGmt(),
      'Request DatetimeHOUR should be same as in setup.'
    );
    System.assertEquals(
      25,
      parsed.minuteGmt(),
      'Request Datetime MINUTE should be same as in setup.'
    );
    System.assertEquals(
      42,
      parsed.secondGmt(),
      'Request DatetimeSECOND should be same as in setup.'
    );
    System.assertEquals(
      0,
      parsed.millisecondGmt(),
      'Request Datetime MILLISECOND should be same as in setup.'
    );
  }

  @isTest
  static void test_valueOfGmt_empty() {
    // under test:
    try {
      DateTime parsed = DatetimeUtil.valueOfGmt('');
      // assertions:
      System.assert(
        false,
        'Exception should be thrown and this line should never be reached.'
      );
    } catch (UnsupportedOperationException ex) {
      System.assertEquals(
        true,
        ex.getMessage().contains('[DatetimeUtil.valueOfGmt]'),
        'Exception message should contain appropriate information. ex:' + ex
      );
    } catch (Exception e) {
      System.assert(
        false,
        'CalloutException should be thrown and this line should never be reached.'
      );
    }
  }

  @isTest
  static void test_valueOfGmt_ISO_8601() {
    // under test:
    DateTime parsed = DatetimeUtil.valueOfGmt('2018-12-21T13:25:42Z'); //yyyy-MM-ddTHH:mm:ssZ

    // assertions:
    System.assertEquals(
      2018,
      parsed.yearGmt(),
      'Request Datetime YEAR should be same as in setup.'
    );
    System.assertEquals(
      12,
      parsed.monthGmt(),
      'Request Datetime MONTH should be same as in setup.'
    );
    System.assertEquals(
      21,
      parsed.dayGmt(),
      'Request Datetime DAY should be same as in setup.'
    );
    System.assertEquals(
      13,
      parsed.hourGmt(),
      'Request DatetimeHOUR should be same as in setup.'
    );
    System.assertEquals(
      25,
      parsed.minuteGmt(),
      'Request Datetime MINUTE should be same as in setup.'
    );
    System.assertEquals(
      42,
      parsed.secondGmt(),
      'Request DatetimeSECOND should be same as in setup.'
    );
    System.assertEquals(
      0,
      parsed.millisecondGmt(),
      'Request Datetime MILLISECOND should be same as in setup.'
    );
  }

  @isTest
  static void test_valueOfGmt_ISO_8601_with_milliseconds() {
    // under test:
    DateTime parsed = DatetimeUtil.valueOfGmt('2018-12-21T13:25:42.666Z'); //yyyy-MM-ddTHH:mm:ss.SSSZ

    // assertions:
    System.assertEquals(
      2018,
      parsed.yearGmt(),
      'Request Datetime YEAR should be same as in setup.'
    );
    System.assertEquals(
      12,
      parsed.monthGmt(),
      'Request Datetime MONTH should be same as in setup.'
    );
    System.assertEquals(
      21,
      parsed.dayGmt(),
      'Request Datetime DAY should be same as in setup.'
    );
    System.assertEquals(
      13,
      parsed.hourGmt(),
      'Request DatetimeHOUR should be same as in setup.'
    );
    System.assertEquals(
      25,
      parsed.minuteGmt(),
      'Request Datetime MINUTE should be same as in setup.'
    );
    System.assertEquals(
      42,
      parsed.secondGmt(),
      'Request DatetimeSECOND should be same as in setup.'
    );
    System.assertEquals(
      666,
      parsed.millisecondGmt(),
      'Request Datetime MILLISECOND should be same as in setup.'
    );
  }

  @isTest
  static void test_to_ISO_8601_String() {
    // setup:
    Datetime dateWithMiliseconds = (DateTime) JSON.deserialize(
      '"2018-12-21T13:25:42.666Z"',
      DateTime.class
    ); //! datetime should be in double and sigle quotes: '"xxx"'

    // under test:
    String dateWithMilisecondsString = DatetimeUtil.to_ISO_8601_String(
      dateWithMiliseconds
    );

    //assertions:
    System.assertEquals(
      '2018-12-21T13:25:42.666Z',
      dateWithMilisecondsString,
      'Complete datetime in ISO 8061 notation should be returned as String.'
    );
  }
}
