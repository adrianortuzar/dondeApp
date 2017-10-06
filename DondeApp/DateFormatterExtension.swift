import Foundation

extension DateFormatter {
  func stringHourMinutes(from date: Date) -> String {
    timeZone = NSTimeZone.local
    dateFormat = "HH:mm"
    return string(from: date)
  }

  func stringDayMonth(from date: Date) -> String {
    timeZone = NSTimeZone.local
    dateFormat = "dd MMMM"
    return string(from: date)
  }
}
