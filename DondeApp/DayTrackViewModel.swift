import Foundation
import RealmSwift
import RxRealm
import RxSwift

class DayTrackViewModel {

  enum DayTrackViewModelError: Error {
    case realm
  }

  init() {
    guard let resultsTracks = getResultsTracks() else {
      return
    }

    _ = Observable.collection(from: resultsTracks).subscribe({ _ in
      guard let tracksDidChange = self.tracksDidChange else {
        return
      }
      tracksDidChange(self)
    })
  }

  var tracksDidChange: ((DayTrackViewModel) -> Void)?

  enum DayType {
    case start
    case end
  }

  func getDate(dayType: DayType) -> Date {
    let calendar = NSCalendar.current
    let currentDate = Date()
    var datc = DateComponents()
    datc.year = calendar.component(.year, from: currentDate)
    datc.month = calendar.component(.month, from: currentDate)
    datc.day = calendar.component(.day, from: currentDate)
    datc.hour = (dayType == .end) ? 23 : 0
    datc.minute = (dayType == .end) ? 59 : 0
    datc.second = (dayType == .end) ? 59 : 0
    let userCalendar = Calendar.current // user calendar
    return userCalendar.date(from: datc)!
  }

  func getResultsTracks() -> Results<RlmTrack>? {
    return DataManager.shared.getResultsTracks(from: getDate(dayType: .start), to: getDate(dayType: .end), realmType: .defaultType)
  }

  var tracks: [RlmTrack]? {
    guard let results = getResultsTracks() else {
      return nil
    }
    return Array(results)
  }
}
