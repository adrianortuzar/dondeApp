import XCTest

@testable import DondeApp

class DateFormatterExtensionTest: XCTestCase {
  let date: Date = {
    var datc = DateComponents()
    datc.year = 2017
    datc.month = 3
    datc.day = 16
    datc.hour = 13
    datc.minute = 48
    datc.second = 3

    let userCalendar = Calendar.current // user calendar
    return userCalendar.date(from: datc)!
  }()

  func testStringHourMinute() {
    let string = DateFormatter().stringHourMinutes(from: date)
    XCTAssertEqual(string, "13:48")
  }

  func testStringDayMonth() {
    let string = DateFormatter().stringDayMonth(from: date)
    XCTAssertEqual(string, "16 March")
  }
}
