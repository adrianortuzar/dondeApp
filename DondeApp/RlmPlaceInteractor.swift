import Foundation
import CoreLocation
import RealmSwift

class RlmPlaceInteractor: NSObject {
  static let shared = RlmPlaceInteractor()

  private override init() {
    super.init()
  }

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
}
