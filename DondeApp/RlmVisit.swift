import Foundation
import RealmSwift
import CoreLocation

class RlmVisit: Object {

  convenience init(visit: CLVisit) {
    self.init()
    longitudPrivate = visit.coordinate.longitude
    latitudPrivate = visit.coordinate.latitude
    horizontalAccuracy = Float(visit.horizontalAccuracy)
    arrivalDate = visit.arrivalDate
    departureDate = visit.departureDate
  }

  private dynamic var latitud: Double = 0
  private dynamic var longitud: Double = 0

  public var latitudPrivate: Double {
    get {
      return self.latitud
    }

    set (newValue) {
      self.latitud = newValue
    }
  }

  public var longitudPrivate: Double {
    get {
      return self.longitud
    }

    set (newValue) {
      self.longitud = newValue
    }
  }

  func setPlace(realm: Realm) {
    if let locationCoordinate = self.locationCoordinate2D {
      if let place = DataManager.shared.getPlaceWithSame(
        location: CLLocation.init(
          latitude: locationCoordinate.latitude,
          longitude: locationCoordinate.longitude
        ),
        realm:realm).first {
        self.place = place
      } else {
        // CREATE NEW PLACE
        let place = RlmPlace()
        self.place = place
      }
    }
  }

  dynamic var horizontalAccuracy: Float = 0
  dynamic var arrivalDate: Date = Date(timeIntervalSince1970: 1)
  dynamic var departureDate: Date = Date(timeIntervalSince1970: 1)

  private dynamic var _place: RlmPlace?

  public var place: RlmPlace? {
    get {
      return _place
    }

    set (newPlace) {
      _place = newPlace

      // when we set a place we calculate the average coordinates
      _place?.calculateAverageCoordinates()
    }
  }

  override static func ignoredProperties() -> [String] {
    return ["locationCoordinate2D",
            "isCurrentVisit",
            "isValidAverageCoordinates",
            "place", "latitudPrivate",
            "longitudPrivate"]
  }

  var locationCoordinate2D: CLLocationCoordinate2D? {
    get {
      if self.latitud != 0 && self.longitud != 0 {
        return CLLocationCoordinate2D(latitude: self.latitud, longitude:self.longitud)
      } else {
        return nil
      }
    }

    set { }
  }

  var isCurrentVisit: Bool {
    get {
      return (self.departureDate == Date.distantFuture) ? true : false
    }

    set { }
  }

  var isArrivalCourrupted: Bool {
    get {
      return (self.arrivalDate == Date.distantPast) ? true : false
    }

    set { }
  }

}
