import Foundation
import RealmSwift
import CoreLocation

protocol RlmLocationInteractorProtocol {
  func getLocationsWithDate(_ date: Date, realm: Realm) -> RlmLocation?
  func getNameFromLocation(location: CLLocation, realm: Realm) -> String?
  func getLocations(from fromDate: Date?, to toDate: Date?, realm: Realm) -> [RlmLocation]
}

class RlmLocationInteractor: NSObject, RlmLocationInteractorProtocol {
  static let shared = RlmLocationInteractor()

  private override init() {
    super.init()
  }

  func updateLocationWith(_ location: RlmLocation, realm: Realm) throws {
    guard let rlmLocation = getLocationsWithDate(location.timestamp, realm: realm) else {
      throw NSError.init(domain: "Imposible to update location", code: 0, userInfo: nil)
    }
    try realm.write {
      rlmLocation.latitud = location.latitud
      rlmLocation.longitud = location.longitud
      rlmLocation.floor = location.floor
      rlmLocation.altitud = location.altitud
      rlmLocation.horizontalAccuracy = location.horizontalAccuracy
      rlmLocation.verticalAccuracy = location.verticalAccuracy
      rlmLocation.timestamp = location.timestamp
      rlmLocation.speed = location.speed
      rlmLocation.course = location.course
      rlmLocation.speedType = location.speedType
    }
  }

  private func existSameDateLocation(_ location: RlmLocation, realm: Realm) -> Bool {
    return getLocationsWithDate(location.timestamp, realm: realm) != nil
  }

  func getLocationsWithDate(_ date: Date, realm: Realm) -> RlmLocation? {
    return realm.objects(RlmLocation.self).filter("timestamp == %@", date).first
  }

  func getNameFromLocation(location: CLLocation, realm: Realm) -> String? {

    let visits = Array(realm.objects(RlmVisit.self))
      .filter { $0.place?.customName != nil && !($0.place?.customName?.isEmpty)! }

    var name: String? = nil

    for visit in visits {
      let visitiLocation = CLLocation(latitude: visit.latitudPrivate, longitude: visit.longitudPrivate)
      let distance: CLLocationDistance = location.distance(from: visitiLocation)

      if distance < 50 {
        name = visit.place?.customName
        break
      }
    }
    return name
  }

  func getLocations(from fromDate: Date?, to toDate: Date?, realm: Realm) -> [RlmLocation] {

    if fromDate != nil && toDate != nil {
      let dayLocationsResult = realm.objects(RlmLocation.self)
        .filter("timestamp < %@ && timestamp > %@", toDate!, fromDate!)

      let locations = Array(dayLocationsResult)
        .sorted(by: { $0.timestamp.compare($1.timestamp) == ComparisonResult.orderedAscending })

      return locations
    } else {
      return Array(realm.objects(RlmLocation.self))
        .sorted(by: { $0.timestamp.compare($1.timestamp) == ComparisonResult.orderedDescending })
    }
  }
}
