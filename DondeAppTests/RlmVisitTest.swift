import XCTest
import RealmSwift
import CoreLocation

@testable import DondeApp

class RlmVisitTest: XCTestCase {
  let arrivalDate = Date()
  var realm = DataManager.shared.getRealm(type: .testType)

  override class func setUp() {
    super.setUp()
    DataManager.shared.clean(.testType)
  }

  func test_1_CreateVisit() {
    let rlmVisit = RlmVisit()
    rlmVisit.longitudPrivate = 52.349553
    rlmVisit.latitudPrivate = 4.796865
    rlmVisit.horizontalAccuracy = Float(12.3)
    rlmVisit.arrivalDate = arrivalDate
    rlmVisit.departureDate = Date.distantFuture

    DataManager.shared.addTo(realm: realm, object: rlmVisit)
    XCTAssertEqual(realm.objects(RlmVisit.self).count, 1, "Should have one visit")
    XCTAssertEqual(realm.objects(RlmVisit.self).first?.departureDate, Date.distantFuture, "Create visit should have departure date distante future")
  }

  func test_2_CreateVisitWithDepartureDate() {
    let departureDate: Date = {
      let calendar = Calendar.current
      let date = calendar.date(byAdding: .hour, value: 5, to: arrivalDate)
      return date!
    }()

    let rlmVisit = RlmVisit()
    rlmVisit.longitudPrivate = 52.349553
    rlmVisit.latitudPrivate = 4.796865
    rlmVisit.horizontalAccuracy = Float(12.3)
    rlmVisit.arrivalDate = arrivalDate
    rlmVisit.departureDate = departureDate

    DataManager.shared.addTo(realm: realm, object: rlmVisit)
    XCTAssertEqual(realm.objects(RlmVisit.self).count, 1, "Should have one visit")
  }

  let currentVisit: RlmVisit = {
    let visit = RlmVisit()
    visit.latitudPrivate = 52.359096350547
    visit.longitudPrivate = 4.80242981858101
    visit.horizontalAccuracy = 60.2262954711914
    visit.arrivalDate = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 16
      datc.hour = 13
      datc.minute = 48
      datc.second = 3

      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()
    visit.departureDate = Date.distantFuture
    return visit
  }()

  let completeVisit: RlmVisit = {
    let visit = RlmVisit()
    visit.latitudPrivate = 52.359023266116
    visit.longitudPrivate = 4.80255960006622
    visit.horizontalAccuracy = 55.3310241699219
    visit.arrivalDate = {
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 16
      datc.hour = 13
      datc.minute = 48
      datc.second = 55

      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()
    visit.departureDate = {//Mar 16, 2017, 1:59:32 PM
      var datc = DateComponents()
      datc.year = 2017
      datc.month = 3
      datc.day = 16
      datc.hour = 13
      datc.minute = 59
      datc.second = 32

      let userCalendar = Calendar.current // user calendar
      return userCalendar.date(from: datc)!
    }()
    return visit
  }()

  func test_3_createCorruptVisit() {
    DataManager.shared.clean(.testType)

    do {
      let realm = try Realm()
      DataManager.shared.addTo(realm: realm, object: currentVisit)
      DataManager.shared.addTo(realm: realm, object: completeVisit)

      XCTAssertEqual(realm.objects(RlmVisit.self).count, 1, "should replace the corrupted visit")

      let firstVisit = realm.objects(RlmVisit.self).first
      XCTAssertEqual(firstVisit?.place?.averageLatitud, completeVisit.latitudPrivate, "should keep the horizontal accuracy")
    } catch {
      print(error)
    }
  }

  func test_4_createSameVisitTwice() {
    DataManager.shared.clean(.testType)

    let visit = RlmVisit()
    visit.arrivalDate = Date.distantPast
    visit.departureDate = Date()
    visit.locationCoordinate2D = CLLocationCoordinate2D(latitude: 52.3410578222804, longitude: 4.82998169210379)
    DataManager.shared.addTo(realm:realm, object:visit)

    let visit2 = RlmVisit()
    visit2.arrivalDate = visit.arrivalDate
    visit2.departureDate = visit.departureDate
    visit2.locationCoordinate2D = visit.locationCoordinate2D
    DataManager.shared.addTo(realm:realm, object:visit2)

    XCTAssertEqual(realm.objects(RlmVisit.self).count, 1)
  }
}
