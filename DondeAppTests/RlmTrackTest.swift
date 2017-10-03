import XCTest
import RealmSwift

@testable import DondeApp

class RlmTrackTest: XCTestCase {
  var realm: Realm!

  override func setUp() {
    super.setUp()

    guard let realmTest = DataManager.shared.getRealm(type: .testType) else {
      fatalError()
    }
    realm = realmTest
  }

  func test_1_AddLocationToTrack() {
    let location: RlmLocation = {
      let location = RlmLocation()
      location.latitud = 52.3495016515999
      location.longitud = 4.79794601613031
      location.horizontalAccuracy = 65
      location.timestamp = {
        var datc = DateComponents()
        datc.year = 2017
        datc.month = 3
        datc.day = 19
        datc.hour = 11
        datc.minute = 57
        datc.second = 49
        let userCalendar = Calendar.current // user calendar
        return userCalendar.date(from: datc)!
      }()
      location.speed = -1
      return location
    }()

    do {
      DataManager.shared.clean(.testType)

      try DataManager.shared.addLocationToTrack(location: location, realm: realm)

      guard let rlmtrack = realm.objects(RlmTrack.self).first else {
        throw NSError.init(domain: "does not exist tracks", code: 0, userInfo: nil)
      }
      XCTAssertEqual(rlmtrack.averageLatitud, location.latitud, "it should have average latitud")
      XCTAssertEqual(rlmtrack.averageLongitud, location.longitud, "it should have average longitud")
      XCTAssertEqual(rlmtrack.averageSpeed, 0, "it should have average speed")
      XCTAssertEqual(rlmtrack.speedType, Speed.Velocity.visit.description, "it should have track speed")
    } catch {
      print(error)
    }
  }

  func test_2_AddSecondLocationWithHorizontallAccuracy() {
    let location: RlmLocation = {
      let location = RlmLocation()
      location.latitud = 52.348064521567
      location.longitud = 4.79992137637907
      location.horizontalAccuracy = 287.8043
      location.timestamp = {
        var datc = DateComponents()
        datc.year = 2017
        datc.month = 3
        datc.day = 19
        datc.hour = 11
        datc.minute = 58
        datc.second = 02
        let userCalendar = Calendar.current // user calendar
        return userCalendar.date(from: datc)!
      }()
      location.speed = -1
      return location
    }()

    do {
      try DataManager.shared.addLocationToTrack(location: location, realm: realm)

      guard let rlmtrack = realm.objects(RlmTrack.self).first,
        let firstLocation = rlmtrack.locations.first else {
          throw NSError.init(domain: "does not exist tracks", code: 0, userInfo: nil)
      }
      XCTAssertEqual(rlmtrack.averageLatitud, firstLocation.latitud)
      XCTAssertEqual(rlmtrack.averageLongitud, firstLocation.longitud)
    } catch {
      print(error)
    }
  }

  func test_3_Add3rdLocationSignificantDifferentLocation() {
    let location: RlmLocation = {
      let location = RlmLocation()
      location.latitud = 52.3513590354454
      location.longitud = 4.84273288604379
      location.altitud = 0.0368256
      location.horizontalAccuracy = 65
      location.timestamp = {
        var datc = DateComponents()
        datc.year = 2017
        datc.month = 3
        datc.day = 19
        datc.hour = 12
        datc.minute = 17
        datc.second = 42
        let userCalendar = Calendar.current // user calendar
        return userCalendar.date(from: datc)!
      }()
      location.speed = -1
      return location
    }()
    do {
      try DataManager.shared.addLocationToTrack(location: location, realm: realm)
      let tracks = realm.objects(RlmTrack.self)
      XCTAssertEqual(tracks.count, 2, "should create another track")
    } catch {
      print(error)
    }
  }
}
