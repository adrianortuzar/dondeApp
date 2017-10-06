import Foundation
import XCTest
import RealmSwift

@testable import DondeApp

class VondelParkTrainingTest: XCTestCase {

  var realm: Realm!

  func deleteTracks() {
    // delete tracks
    do {
      try realm.write {
        realm.delete(realm.objects(RlmTrack.self))
      }
    } catch {
      fatalError()
    }
  }

  let startDate: Date = {
    var datc = DateComponents()
    datc.year = 2017
    datc.month = 4
    datc.day = 9
    datc.hour = 0
    datc.minute = 0
    datc.second = 0
    let userCalendar = Calendar.current // user calendar
    return userCalendar.date(from: datc)!
  }()

  let endDate: Date = {
    var datc = DateComponents()
    datc.year = 2017
    datc.month = 4
    datc.day = 9
    datc.hour = 23
    datc.minute = 59
    datc.second = 59
    let userCalendar = Calendar.current // user calendar
    return userCalendar.date(from: datc)!
  }()

  override func setUp() {
    guard let realmm = DataManager.shared.getRealmWith(fileName: "testCoffeVoundel") else {
      fatalError()
    }

    realm = realmm
  }

  func testAddLocations() {
    deleteTracks()

    let locations = DataManager.shared.getLocations(from: startDate, to: endDate, realm:realm)

    for location in locations {
      do {
        try DataManager.shared.addLocationToTrack(location: location, realm: realm)
      } catch {
        fatalError()
      }
    }

    // visit
    // bike
    // visit coffe entrada vondel park
    // walk
    // visit hierba vondel park
    // bike
    // alber hein
    // bike
    // visit
    XCTAssertEqual(realm.objects(RlmTrack.self).count, 9, "it should have 9 tracks")
  }
}
