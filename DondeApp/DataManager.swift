import Foundation
import CoreLocation
import RealmSwift

enum RealmType {
  case defaultType
  case testType
  case locationsTestType
}

class DataManager: NSObject {

  static let shared = DataManager()

  fileprivate let rlmTrackInteractor = RlmTrackInteractor.shared
  fileprivate let rlmInteractor = RlmInteractor.shared
  fileprivate let rlmVisitInteractor = RlmVisitInteractor.shared
  fileprivate let rlmLocationInteractor = RlmLocationInteractor.shared
  fileprivate let rlmPlaceInteractor = RlmPlaceInteractor.shared

  enum DataManagerError: Error {
    case creatingRealm
  }

  private override init() {
    super.init()
  }

  let realmSchemaVersion: UInt64 = 30

  // MARK: string extension

  func stringToDate(_ dateStr: String) -> Date {
    //let strTime = "2017-02-05T21:24:56.000Z"
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let date = formatter.date(from: dateStr)
    return date!
  }
}

extension DataManager: RlmInteractorProtocol {
  func getRealm(fileName: String) -> Realm {
    return rlmInteractor.getRealm(fileName: fileName)
  }

  func getRealm(type: RealmType) -> Realm {
    return rlmInteractor.getRealm(type: type)
  }

  /// clean all data from database
  func clean(_ type: RealmType) {
    rlmInteractor.clean(type)
  }

  func delete(object: Object, realm: Realm) {
    rlmInteractor.delete(object: object, realm: realm)
  }

  func delete(results: Results<Object>, realm: Realm) {
    rlmInteractor.delete(results: results, realm: realm)
  }

  func addTo(realm: Realm, object: Object) {
    rlmInteractor.addTo(realm: realm, object: object)
  }

  func update(object: Object, realm: Realm) throws {
    try rlmInteractor.update(object: object, realm: realm)
  }
}

extension DataManager: RlmLocationInteractorProtocol {
  func getLocationsWithDate(_ date: Date, realm: Realm) -> RlmLocation? {
    return rlmLocationInteractor.getLocationsWithDate(date, realm: realm)
  }

  func getNameFromLocation(location: CLLocation, realm: Realm) -> String? {
    return rlmLocationInteractor.getNameFromLocation(location: location, realm: realm)
  }

  func getLocations(from fromDate: Date?, to toDate: Date?, realm: Realm) -> [RlmLocation] {
    return rlmLocationInteractor.getLocations(from: fromDate, to: toDate, realm: realm)
  }
}

extension DataManager: RlmTrackInteractorProtocol {
  func getResultsTracks(from fromDate: Date, to toDate: Date, realmType: RealmType) -> Results<RlmTrack>? {
    let realm = getRealm(type: realmType)
    return getResultsTracks(from: fromDate, to: toDate, realm: realm)
  }

  func getResultsTracks(from fromDate: Date, to toDate: Date, realm: Realm) -> Results<RlmTrack>? {
    return rlmTrackInteractor.getResultsTracks(from: fromDate, to: toDate, realm: realm)
  }

  func getTracks(from fromDate: Date, to toDate: Date, realm: Realm) -> [RlmTrack] {
    return rlmTrackInteractor.getTracks(from: fromDate, to: toDate, realm: realm)
  }

  func addLocationToTrack(location: RlmLocation, realm: Realm) {
    rlmTrackInteractor.addLocationToTrack(location: location, realm: realm)
  }

  func addVisitToTrack(visit: RlmVisit, realm: Realm) {
    rlmTrackInteractor.addVisitToTrack(visit: visit, realm: realm)
  }
}

extension DataManager: RlmVisitInteractorProtocol {
  func createPlacesFor(visits: [RlmVisit], realm: Realm) throws {
    try rlmVisitInteractor.createPlacesFor(visits: visits, realm: realm)
  }

  func getVisitsWithSameLocationAs(_ visit: RlmVisit, realm: Realm) -> [RlmVisit] {
    return rlmVisitInteractor.getVisitsWithSameLocationAs(visit, realm: realm)
  }

  func getCurrentVisit(realm: Realm) -> RlmVisit? {
    return rlmVisitInteractor.getCurrentVisit(realm: realm)
  }

  func getVisits(from fromDate: Date?, to toDate: Date?, realm: Realm) -> [RlmVisit] {
    return rlmVisitInteractor.getVisits(from: fromDate, to: toDate, realm: realm)
  }
}

extension DataManager: RlmPlaceInteractorProtocol {
  func getPlaceWithSame(location: CLLocation, realm: Realm) -> [RlmPlace] {
    return rlmPlaceInteractor.getPlaceWithSame(location: location, realm: realm)
  }
}
