import XCTest
import RealmSwift

@testable import DondeApp

class TrackLocationDbTest: XCTestCase {

  var realm: Realm!

  // MARK: common methods

  func deleteTracks() {
    do {
      try realm.write {
        realm.delete(realm.objects(RlmTrack.self))
      }
    } catch {
      fatalError()
    }
  }

  // MARK: tests

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.

    do {
      guard let realmm = DataManager.shared.getRealm(type: .locationsTestType) else {
        throw NSError.init()
      }
      realm = realmm
    } catch {
      print(error)
    }
  }

  func test_1_AddFirst14LocationsToTracks() {
    let locations = realm.objects(RlmLocation.self).sorted(byKeyPath: "timestamp", ascending: true)

    do {
      deleteTracks()

      for (index, location) in locations.enumerated() where index < 14 {
        try DataManager.shared.addLocationToTrack(location: location, realm: realm)
      }

      XCTAssertEqual(realm.objects(RlmTrack.self).count, 4, "it should have 4 tracks")

      let firstTrack: RlmTrack = realm.objects(RlmTrack.self).first!
      XCTAssertEqual(firstTrack.locations.count, 2, "the firt track should have two locations")

      let secondTrack: RlmTrack = realm.objects(RlmTrack.self)[1]
      XCTAssertEqual(secondTrack.averageSpeed, 11.556666692098, "second track it should have correct speed average")

    } catch {
      print(error)
    }
  }

  func test_2_AddLocationsBetweenTwoTimes() {
    let startDate: Date = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 19
      datc.hour = 13
      datc.minute = 43
      datc.second = 33
      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()
    let endDate: Date = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 19
      datc.hour = 13
      datc.minute = 46
      datc.second = 50
      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()

    do {
      deleteTracks()

      let locations = DataManager.shared.getLocations(from: startDate, to: endDate, realm:realm)

      for location in locations {
        try DataManager.shared.addLocationToTrack(location: location, realm: realm)
      }

      XCTAssertEqual(realm.objects(RlmTrack.self).count, 1)
    } catch {
      fatalError()
    }
  }

  func test_3_ProcessTransportationCar() {
    let startDate: Date = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 19
      datc.hour = 13
      datc.minute = 47
      datc.second = 46
      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()

    let endDate: Date = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 19
      datc.hour = 13
      datc.minute = 55
      datc.second = 53
      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()

    do {
      try realm.write {
        realm.delete(realm.objects(RlmTrack.self))
      }

      let locations = DataManager.shared.getLocations(from: startDate, to: endDate, realm:realm)

      for location in locations {
        try DataManager.shared.addLocationToTrack(location: location, realm: realm)
      }

      _ = RlmTrackInteractor.shared.mergeLastTrack(realm: realm)
      XCTAssertEqual(realm.objects(RlmTrack.self).count, 1)
    } catch {
      fatalError()
    }
  }

  func test_4_ProcessAllLocations() {
    deleteTracks()

    let locations = realm.objects(RlmLocation.self).sorted(byKeyPath: "timestamp", ascending: true)

    do {
      for location in locations {
        try DataManager.shared.addLocationToTrack(location: location, realm: realm)
      }

      _ = RlmTrackInteractor.shared.mergeLastTrack(realm: realm)
      XCTAssertEqual(realm.objects(RlmTrack.self).count, 7)
    } catch {
      fatalError()
    }

    let track1: RlmTrack = realm.objects(RlmTrack.self)[0]
    XCTAssertEqual(track1.speedType, Speed.Velocity.visit.description)
    let track2: RlmTrack = realm.objects(RlmTrack.self)[1]
    XCTAssertEqual(track2.speedType, Speed.Velocity.transport.description)
    let track3: RlmTrack = realm.objects(RlmTrack.self)[2]
    XCTAssertEqual(track3.speedType, Speed.Velocity.walk.description)
    let track4: RlmTrack = realm.objects(RlmTrack.self)[3]
    XCTAssertEqual(track4.speedType, Speed.Velocity.visit.description)
    let track5: RlmTrack = realm.objects(RlmTrack.self)[4]
    XCTAssertEqual(track5.speedType, Speed.Velocity.walk.description)
    let track6: RlmTrack = realm.objects(RlmTrack.self)[5]
    XCTAssertEqual(track6.speedType, Speed.Velocity.transport.description)
    let track7: RlmTrack = realm.objects(RlmTrack.self)[6]
    XCTAssertEqual(track7.speedType, Speed.Velocity.visit.description)
  }

  func test_5_GetTracksForDate() {
    let fromDate: Date = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 19
      datc.hour = 0
      datc.minute = 0
      datc.second = 0
      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()
    let toDate: Date = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 19
      datc.hour = 23
      datc.minute = 59
      datc.second = 59
      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()
    let tracks = DataManager.shared.getTracks(from:fromDate, to:toDate, realm:realm)
    XCTAssertEqual(tracks.count, 7)
  }
}
