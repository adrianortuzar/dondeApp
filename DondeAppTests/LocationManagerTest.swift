import XCTest
import RealmSwift
import CoreLocation

@testable import DondeApp

class LocationManagerTest: XCTestCase {
  var realm: Realm!
  var locationManager: LocationManager!

  func getLocationWithDate(_ date: Date) -> CLLocation {
    return CLLocation.init(
      coordinate: CLLocationCoordinate2D.init(),
      altitude: Double(0),
      horizontalAccuracy: 0,
      verticalAccuracy: 0,
      timestamp: date
    )
  }

  let location = CLLocation.init(
    coordinate: CLLocationCoordinate2D.init(),
    altitude: Double(0),
    horizontalAccuracy: 0,
    verticalAccuracy: 0,
    timestamp: Date()
  )

  override func setUp() {
    super.setUp()
    guard let realmTest = DataManager.shared.getRealm(type: .testType) else {
      return
    }
    realm = realmTest
    locationManager = LocationManager.shared
  }

  func test_1_RemoveDataBase() {
    DataManager.shared.clean(.testType)
    XCTAssertEqual(realm.objects(RlmLocation.self).count, 0, "Remove data base")
  }

  func test_2_CreateLocation() {
    let currentDate = Date()

    let rlmLocation = RlmLocation.init(cllocation: getLocationWithDate(currentDate))
    DataManager.shared.addTo(realm: realm, object: rlmLocation)
    XCTAssertEqual(realm.objects(RlmLocation.self).count, 1, "Create one location")
    DataManager.shared.addTo(realm: realm, object: rlmLocation)
    XCTAssertEqual(realm.objects(RlmLocation.self).count, 1, "Create one location with same date")
    DataManager.shared.addTo(realm: realm, object: RlmLocation.init(cllocation: getLocationWithDate(Date())))
    XCTAssertEqual(realm.objects(RlmLocation.self).count, 2, "Create one location with different date")
  }
}
