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

  enum DataManagerError: Error {
    case creatingRealm
  }

  private override init() {
    super.init()
  }

  let realmSchemaVersion: UInt64 = 29

  // MARK: realm interactor

  func getRealmWith(fileName: String) -> Realm? {
    var config = Realm.Configuration()
    config.fileURL = Bundle.main.url(forResource: fileName, withExtension: "realm")
    config.schemaVersion = realmSchemaVersion

    Realm.Configuration.defaultConfiguration = config

    do {
      return try Realm()
    } catch {
      return nil
    }
  }

  func copyRealmInDocumentsFolder(realm: Realm) throws {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    guard let url = URL.init(string: documentsPath + "/loc.realm") else {
      return
    }

    try realm.writeCopy(toFile: url, encryptionKey: nil)
  }

  func getRealm(type: RealmType) -> Realm? {
    switch type {
    case .defaultType:
      var config = Realm.Configuration()
      config.schemaVersion = realmSchemaVersion
      Realm.Configuration.defaultConfiguration = config

      do {
        return try Realm()
      } catch {
        print(error)
        return nil
      }
    case .testType :

      var config = Realm.Configuration()
      config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("test.realm")
      config.schemaVersion = realmSchemaVersion

      Realm.Configuration.defaultConfiguration = config

      do {
        return try Realm()
      } catch {
        print(error)
        return nil
      }
    case .locationsTestType:
      return DataManager.shared.getRealmWith(fileName: "locationsTest")
    }
  }

  /// clean all data from database
  func clean(_ type: RealmType) {
    do {
      guard let realm = getRealm(type: type) else {
        throw NSError.init(domain: "Can not cleam realm because does not exist", code: 0, userInfo: nil)
      }
      try realm.write {
        realm.deleteAll()
      }
    } catch {
      fatalError()
    }
  }

  func delete(object: Object, realm: Realm) {
    do {
      try realm.write {
        realm.delete(object)
      }
    } catch {
      fatalError()
    }
  }

  func addTo(realm: Realm, object: Object) {
    do {
      try update(object: object, realm: realm)
    } catch {
      // add to realm
      do {
        try realm.write {
          realm.add(object)
        }
      } catch {
        print(error)
      }

      if let visit = object as? RlmVisit {
        resetVisitData(visit, realm: realm)
      }
    }
  }

  func update(object: Object, realm: Realm) throws {
    if let visit = object as? RlmVisit {
      try updateCurrentVisitWith(visit, realm: realm)
    } else if let location = object as? RlmLocation {
      try updateLocationWith(location, realm: realm)
    } else {
      throw NSError.init(domain: "Not possible to update object", code: 0, userInfo: nil)
    }
  }

  // MARK: RlmLocation interactor

  private func updateLocationWith(_ location: RlmLocation, realm: Realm) throws {
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

  func getNameFromLocation(location: CLLocation) -> String? {

    guard let realm = getRealm(type: .defaultType) else {
      return nil
    }

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

  // MARK: RlmVisit

  /**
   - recalculate the average coordinates for the visit
   - determinate the place of the visit
   - create a travel if need it
   */
  private func resetVisitData(_ visit: RlmVisit, realm: Realm) {
    do {
      try realm.write {
        visit.setPlace(realm:realm)
        visit.place?.calculateAverageCoordinates()

        if let travel = createRlmTravel(with: visit, realm:realm) {
          realm.add(travel)
        }
      }
    } catch {
      print(error)
    }
  }

  private func updateCurrentVisitWith(_ visit: RlmVisit, realm: Realm) throws {
    guard let currentVisit = getCurrentVisit(realm: realm) else {
      throw NSError.init(domain: "Imposible to update current visit because there is not exist current visit", code: 0, userInfo: nil)
    }
    try realm.write {
      // update it
      currentVisit.latitudPrivate = visit.latitudPrivate
      currentVisit.longitudPrivate = visit.longitudPrivate
      currentVisit.departureDate = visit.departureDate
      currentVisit.arrivalDate = visit.arrivalDate
      currentVisit.horizontalAccuracy = visit.horizontalAccuracy
      currentVisit.setPlace(realm:realm)
      currentVisit.place?.calculateAverageCoordinates()
    }
  }

  func createPlacesFor(visits: [RlmVisit]) throws {

    // remove places
    guard let realm = getRealm(type: .defaultType) else {
      return
    }
    try realm.write {
      realm.delete(realm.objects(RlmPlace.self))
    }

    for visit in visits {
      if visit.place == nil {
        // get place with same location as visit
        if let place = getPlaceWithSame(
          location: CLLocation.init(latitude: visit.latitudPrivate, longitude: visit.longitudPrivate),
          realm: realm).first {

          try realm.write {
            visit.place = place
          }
        } else {
          // CREATE NEW PLACE
          let place = RlmPlace()

          try realm.write {
            realm.add(place)
            visit.place = place
          }
        }
      }

    }
  }

  func getVisitsWithSameLocationAs(_ visit: RlmVisit) -> [RlmVisit] {
    let visitLocation = CLLocation.init(latitude: visit.latitudPrivate, longitude: visit.longitudPrivate)

    guard let realm = getRealm(type: .defaultType) else {
      return []
    }

    return Array(realm.objects(RlmVisit.self)).filter { (visitCompare) -> Bool in
      let visitCompareLocation = CLLocation.init(
        latitude: visitCompare.latitudPrivate,
        longitude: visitCompare.longitudPrivate
      )
      let distance: CLLocationDistance = visitLocation.distance(from: visitCompareLocation)
      if distance < 50 {
        return true
      } else {
        return false
      }
    }
  }

  func getCurrentVisit(realm: Realm) -> RlmVisit? {
    let lastVisit = realm.objects(RlmVisit.self).sorted(byKeyPath: "arrivalDate", ascending: false).first
    return (lastVisit != nil && lastVisit?.departureDate == Date.distantFuture) ? lastVisit : nil
  }

  func getVisits(from fromDate: Date?, to toDate: Date?, realm: Realm) -> [RlmVisit] {

    if fromDate != nil && toDate != nil {
      let dayVisitsResult = realm.objects(RlmVisit.self)
        .filter("((departureDate < %@ && departureDate > %@) || (arrivalDate < %@ && arrivalDate > %@))",
                toDate!, fromDate!, toDate!, fromDate!)

      let visits = Array(dayVisitsResult)
        .sorted(by: { $0.arrivalDate.compare($1.arrivalDate) == ComparisonResult.orderedDescending })
      return visits
    } else {
      // all visits
      let visitsSorted = Array(realm.objects(RlmVisit.self)
        .sorted(by: { $0.arrivalDate.compare($1.arrivalDate) == ComparisonResult.orderedDescending }))

      return visitsSorted
    }
  }

  // MARK: RlmTravel

  func createRlmTravel(with arrivalVisit: RlmVisit, realm: Realm) -> RlmTravel? {

    // get departureVisit
    if let departureVisit = getVisits(
      from: Date.distantPast,
      to: arrivalVisit.arrivalDate,
      realm: realm
      ).first {

      // get locations
      let locations = getLocations(
        from: departureVisit.departureDate,
        to: arrivalVisit.arrivalDate,
        realm:realm
      )

      // create and save the travel
      let rlmTravel: RlmTravel = {
        if let travel = realm.objects(RlmTravel.self)
          .filter("arrivalVisit.departureDate == %@", arrivalVisit.departureDate)
          .first {
          return travel
        } else {
          return RlmTravel.init()
        }
      }()
      rlmTravel.departureVisit = departureVisit
      rlmTravel.arrivalVisit = arrivalVisit
      rlmTravel.locations.append(objectsIn: locations)

      return rlmTravel
    } else {
      return nil
    }
  }

  func createTravels() throws {

    // remove travels
    guard let realm = getRealm(type: .defaultType) else {
      throw DataManagerError.creatingRealm
    }

    try realm.write {
      realm.delete(realm.objects(RlmTravel.self))
    }

    let visits = getVisits(from: nil, to: nil, realm:realm)
    for visit in visits {
      if let travel = createRlmTravel(with: visit, realm:realm) {
        addTo(realm: realm, object: travel)
      }
    }
  }

  func getTravels(from fromDate: Date?, to toDate: Date?, realm: Realm) -> [RlmTravel] {

    if fromDate != nil && toDate != nil {

      let travels = realm.objects(RlmTravel.self)
        .filter("(departureVisit.departureDate > %@ && departureVisit.departureDate < %@) || (arrivalVisit.arrivalDate > %@ && arrivalVisit.arrivalDate < %@)",
                fromDate!, toDate!, fromDate!, toDate!)

      let travelsOrdered = Array(travels).sorted(by: {
        guard let currentArrivalDate = $0.arrivalVisit?.arrivalDate,
          let nextArrivalDate = $1.arrivalVisit?.arrivalDate else {
            return false
        }
        return currentArrivalDate.compare(nextArrivalDate) == ComparisonResult.orderedAscending
      })

      return travelsOrdered
    } else {
      return Array(realm.objects(RlmTravel.self)).sorted(by: {
        guard let currentArrivalDate = $0.arrivalVisit?.arrivalDate,
          let nextArrivalDate = $1.arrivalVisit?.arrivalDate else {
            return false
        }
        return currentArrivalDate.compare(nextArrivalDate) == ComparisonResult.orderedDescending
      })
    }
  }

  // MARK: RlmPlaces

  func getPlaceWithSame(location: CLLocation, realm: Realm) -> [RlmPlace] {

    let places = realm.objects(RlmPlace.self)

    return Array(places).filter { (rlmPlace) -> Bool in
      let placeLocation = CLLocation.init(latitude: rlmPlace.averageLatitud, longitude: rlmPlace.averageLongitud)
      let distance: CLLocationDistance = location.distance(from: placeLocation)
      if distance < 50 {
        return true
      } else {
        return false
      }
    }
  }

  // MARK: RlmTrack interactor

  func getResultsTracks(from fromDate: Date, to toDate: Date, realmType: RealmType) ->  Results<RlmTrack>? {
    guard let realm = getRealm(type: realmType) else {
      return nil
    }
    return rlmTrackInteractor.getResultsTracks(from: fromDate, to: toDate, realm: realm)
  }

  func getTracks(from fromDate: Date, to toDate: Date, realm: Realm) -> [RlmTrack] {
    return rlmTrackInteractor.getTracks(from: fromDate, to: toDate, realm: realm)
  }

  func createNewTrackWith(location: RlmLocation, realm: Realm) throws {
    try rlmTrackInteractor.createNewTrackWith(location: location, realm: realm)
  }

  func addLocationToTrack(location: RlmLocation, realm: Realm) throws {
    try rlmTrackInteractor.addLocationToTrack(location: location, realm: realm)
  }

  // MARK: string extension

  func stringToDate(_ dateStr: String) -> Date {
    //let strTime = "2017-02-05T21:24:56.000Z"
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let date = formatter.date(from: dateStr)
    return date!
  }
}
