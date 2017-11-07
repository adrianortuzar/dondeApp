import Foundation
import XCTest
import RealmSwift

@testable import DondeApp

class VondelParkTrainingTest: XCTestCase {

  var realm = DataManager.shared.getRealm(fileName: "testCoffeVoundel")

  func deleteTracks() {
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

  func testAddLocations() {
    deleteTracks()

    let locations = DataManager.shared.getLocations(from: startDate, to: endDate, realm:realm)

    for location in locations {
      DataManager.shared.addLocationToTrack(location: location, realm: realm)
    }

    let tracks = realm.objects(RlmTrack.self)
    XCTAssertEqual(tracks.count, 7, "it should have 8 tracks")
    XCTAssertEqual(tracks[0].speedType, Speed.Velocity.visit.description)
    XCTAssertEqual(tracks[1].speedType, Speed.Velocity.visit.description)
    XCTAssertEqual(tracks[2].speedType, Speed.Velocity.bike.description)
    XCTAssertEqual(tracks[3].speedType, Speed.Velocity.walk.description)
    XCTAssertEqual(tracks[4].speedType, Speed.Velocity.visit.description)
    XCTAssertEqual(tracks[5].speedType, Speed.Velocity.bike.description)
    XCTAssertEqual(tracks[6].speedType, Speed.Velocity.visit.description)
  }
}
