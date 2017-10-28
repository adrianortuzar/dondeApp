import XCTest
import RealmSwift

@testable import DondeApp

class RlmPlaceTest: XCTestCase {
  func testAverageCoordinates() {
    let rlmVisit = RlmVisit()
    rlmVisit.longitudPrivate = 52.349553
    rlmVisit.latitudPrivate = 4.796865
    rlmVisit.horizontalAccuracy = Float(12.3)
    rlmVisit.arrivalDate = Date()
    rlmVisit.departureDate = Date()

    let realm = DataManager.shared.getRealm(type: .testType)
    DataManager.shared.addTo(realm: realm, object: rlmVisit)

    guard let place = rlmVisit.place else {
      fatalError()
    }

    XCTAssertEqual(place.averageLongitud, 52.349553)
    XCTAssertEqual(place.averageLatitud, 4.796865)
  }

  func testVisitClose50m() {
    let rlmVisit50m = RlmVisit()
    rlmVisit50m.longitudPrivate = 52.349428
    rlmVisit50m.latitudPrivate = 4.7972605
    rlmVisit50m.horizontalAccuracy = Float(12.3)
    rlmVisit50m.arrivalDate = Date()
    rlmVisit50m.departureDate = Date()

    let realm = DataManager.shared.getRealm(type: .testType)
    DataManager.shared.addTo(realm: realm, object: rlmVisit50m)

    guard let place = rlmVisit50m.place else {
      fatalError()
    }

    XCTAssertEqual(place.visits.count, 2)
    XCTAssertEqual(place.averageLongitud, 52.3494905)
    XCTAssertEqual(place.averageLatitud, 4.79706275)
  }
}
