import XCTest
import RealmSwift

@testable import DondeApp

class RlmTravelTest: XCTestCase {
  var realm: Realm!

  let referenceDate = Date()

  var departureVisit: RlmVisit {
    let visit = RlmVisit()
    visit.longitudPrivate = 52.349553
    visit.latitudPrivate = 4.796865
    visit.horizontalAccuracy = Float(12.3)
    visit.arrivalDate = referenceDate
    visit.departureDate = {
      let calendar = Calendar.current
      let date = calendar.date(byAdding: .hour, value: 1, to: referenceDate)
      return date!
    }()
    return visit
  }

  var currentVisit: RlmVisit {
    let visit = RlmVisit()
    visit.longitudPrivate = 52.3586341
    visit.latitudPrivate = 4.8008507
    visit.horizontalAccuracy = Float(12.3)
    visit.arrivalDate = {
      let calendar = Calendar.current
      let date = calendar.date(byAdding: .hour, value: 2, to: referenceDate)
      return date!
    }()
    visit.departureDate = Date.distantFuture
    return visit
  }

  override func setUp() {
    super.setUp()
    
    guard let realmm = DataManager.shared.getRealm(type: .testType) else {
      fatalError()
    }
    realm = realmm
  }

  func test_1_CreateArrivaleAndDepartureVisit() {
    DataManager.shared.clean(.testType)

    DataManager.shared.addTo(realm: realm, object: departureVisit)
    DataManager.shared.addTo(realm: realm, object: currentVisit)

    XCTAssertEqual(realm.objects(RlmTravel.self).count, 1, "It has to create a travel")

    guard let travel = realm.objects(RlmTravel.self).first else {
      fatalError()
    }

    XCTAssertNotNil(travel.departureVisit?.place, "it has to create a place")
    XCTAssertNotNil(travel.arrivalVisit?.place, "it has to create a place")

    XCTAssertEqual(travel.arrivalVisit?.place?.averageLatitud, currentVisit.latitudPrivate)
    XCTAssertEqual(travel.arrivalVisit?.place?.averageLongitud, currentVisit.longitudPrivate)

    XCTAssertEqual(travel.departureVisit?.place?.averageLatitud, departureVisit.latitudPrivate)
    XCTAssertEqual(travel.departureVisit?.place?.averageLongitud, departureVisit.longitudPrivate)
  }

  func testCreateArrivalVisit() {
    let arrivalVisit: RlmVisit = {
      let visit = RlmVisit()
      visit.longitudPrivate = 52.3586341
      visit.latitudPrivate = 4.8008507
      visit.horizontalAccuracy = Float(12.3)
      visit.arrivalDate = {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: 2, to: referenceDate)
        return date!
      }()
      visit.departureDate = {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: 3, to: referenceDate)
        return date!
      }()
      return visit
    }()

    DataManager.shared.addTo(realm: realm, object: arrivalVisit)

    XCTAssertEqual(realm.objects(RlmVisit.self).count, 2)

    guard let travel = realm.objects(RlmTravel.self).first else {
      fatalError()
    }
    XCTAssertEqual(travel.arrivalVisit?.departureDate, arrivalVisit.departureDate)
  }
}
