import Foundation
import RealmSwift
import CoreLocation

protocol RlmVisitInteractorProtocol {
  func createPlacesFor(visits: [RlmVisit], realm: Realm) throws
  func getVisitsWithSameLocationAs(_ visit: RlmVisit, realm: Realm) -> [RlmVisit]
  func getCurrentVisit(realm: Realm) -> RlmVisit?
  func getVisits(from fromDate: Date?, to toDate: Date?, realm: Realm) -> [RlmVisit]
}

class RlmVisitInteractor: NSObject, RlmVisitInteractorProtocol {
  let rlmPlaceInteractor = RlmPlaceInteractor.shared

  static let shared = RlmVisitInteractor()

  private override init() {
    super.init()
  }

  /**
   - recalculate the average coordinates for the visit
   - determinate the place of the visit
   - create a travel if need it
   */
  func resetVisitData(_ visit: RlmVisit, realm: Realm) {
    do {
      try realm.write {
        visit.setPlace(realm:realm)
        visit.place?.calculateAverageCoordinates()
      }
    } catch {
      print(error)
    }
  }

  func updateCurrentVisitWith(_ visit: RlmVisit, realm: Realm) throws {
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

  func createPlacesFor(visits: [RlmVisit], realm: Realm) throws {

    try realm.write {
      realm.delete(realm.objects(RlmPlace.self))
    }

    for visit in visits {
      if visit.place == nil {
        // get place with same location as visit
        if let place = rlmPlaceInteractor.getPlaceWithSame(
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

  func getVisitsWithSameLocationAs(_ visit: RlmVisit, realm: Realm) -> [RlmVisit] {
    let visitLocation = CLLocation.init(latitude: visit.latitudPrivate, longitude: visit.longitudPrivate)

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
}
