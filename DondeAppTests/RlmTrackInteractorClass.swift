import XCTest
import RealmSwift
@testable import DondeApp

class RlmTrackInteractorClass: XCTestCase {

  // MARK: test data

  let realmType: RealmType = .testType
  var realm: Realm {
    return DataManager.shared.getRealm(type: self.realmType)
  }
  let currentDate = Date()
  let calendar = Calendar.current
  var dateComponents: Set<Calendar.Component> {
    return [.year, .month, .day, .hour, .minute, .second, .nanosecond]
  }
  var currentDatePlus1h: Date {
    var datecompo = calendar.dateComponents(dateComponents, from: currentDate)
    datecompo.hour = calendar.component(.hour, from: currentDate) + 1
    return calendar.date(from: datecompo)!
  }
  var currentDateMinus1h: Date {
    var datecompo = calendar.dateComponents(dateComponents, from: currentDate)
    datecompo.hour = calendar.component(.hour, from: currentDate) - 1
    return calendar.date(from: datecompo)!
  }
  var currentDateMinus2h: Date {
    var datecompo = calendar.dateComponents(dateComponents, from: currentDate)
    datecompo.hour = calendar.component(.hour, from: currentDate) - 2
    return calendar.date(from: datecompo)!
  }

  // MARKS: visits
  var pastVisit: RlmVisit {
    let visit = RlmVisit()
    visit.arrivalDate = currentDate
    visit.departureDate = currentDatePlus1h
    return visit
  }
  var pastVisitArrivalCorrupted: RlmVisit {
    let visit = RlmVisit()
    visit.arrivalDate = Date.distantPast
    visit.departureDate = currentDatePlus1h
    return visit
  }
  var currentVisitArrivalCorrupted: RlmVisit {
    let visit = RlmVisit()
    visit.arrivalDate = Date.distantPast
    visit.departureDate = Date.distantFuture
    return visit
  }

  // MARKS: locations
  var locationVisitPlus1h: RlmLocation {
    let location = RlmLocation()
    location.speedType = Speed.Velocity.visit.description
    location.timestamp = currentDatePlus1h
    return location
  }
  var locationVisitLess1h: RlmLocation {
    let location = RlmLocation()
    location.speedType = Speed.Velocity.visit.description
    location.timestamp = currentDateMinus1h
    // b building location
    location.latitud = 52.342656
    location.longitud = 4.8305975
    return location
  }
  var locationVisitLess2h: RlmLocation {
    let location = RlmLocation()
    location.speedType = Speed.Velocity.visit.description
    location.timestamp = currentDateMinus2h
    // radion location
    location.latitud = 52.3449122
    location.longitud = 4.8226331
    return location
  }

  // MARK: test implementation

  override func setUp() {
    DataManager.shared.clean(realmType)
  }

  func testAddVisitToTrack() {
    DataManager.shared.addVisitToTrack(visit: pastVisit, realm: realm)

    XCTAssertEqual(realm.objects(RlmTrack.self).count, 1)
    let track = realm.objects(RlmTrack.self)[0]
    XCTAssertNotNil(track.visit)
    XCTAssertEqual(track.speedType, Speed.Velocity.visit.description)
  }

  func testAddLocationAndVisit() {
    DataManager.shared.addLocationToTrack(location: locationVisitPlus1h, realm: realm)
    DataManager.shared.addVisitToTrack(visit: pastVisit, realm: realm)

    let tracks = realm.objects(RlmTrack.self)
    XCTAssertEqual(tracks.count, 1)
    let track = tracks[0]
    XCTAssertNotNil(track.visit)
    XCTAssertEqual(track.locations.count, 1)
    XCTAssertEqual(track.speedType, Speed.Velocity.visit.description)
  }

  func testAddCurrentVisitArrivalCorrupted() {
    XCTAssertTrue(currentVisitArrivalCorrupted.isCurrentVisit)
    XCTAssertTrue(currentVisitArrivalCorrupted.isArrivalCourrupted)

    DataManager.shared.addLocationToTrack(location: locationVisitLess1h, realm: realm)
    DataManager.shared.addVisitToTrack(visit: currentVisitArrivalCorrupted, realm: realm)

    let tracks = realm.objects(RlmTrack.self)
    XCTAssertEqual(tracks.count, 1)
    let track = tracks[0]
    XCTAssertNotNil(track.visit)
    XCTAssertEqual(track.locations.count, 1)
    XCTAssertEqual(track.speedType, Speed.Velocity.visit.description)
  }

  func testAddVisitArrivalCorrupted() {
    DataManager.shared.addLocationToTrack(location: locationVisitLess1h, realm: realm)
    DataManager.shared.addVisitToTrack(visit: pastVisitArrivalCorrupted, realm: realm)

    let tracks = realm.objects(RlmTrack.self)
    XCTAssertEqual(tracks.count, 1)
    let track = tracks[0]
    XCTAssertNotNil(track.visit)
    XCTAssertEqual(track.locations.count, 1)
    XCTAssertEqual(track.speedType, Speed.Velocity.visit.description)
  }

  func testAddVisitLocationsFromDifferentGeoPositions() {
    DataManager.shared.addLocationToTrack(location: locationVisitLess2h, realm: realm)
    DataManager.shared.addLocationToTrack(location: locationVisitLess1h, realm: realm)

    let tracks = realm.objects(RlmTrack.self)
    XCTAssertEqual(tracks.count, 2)
  }
}
