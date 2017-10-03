import Foundation
import CoreLocation
import RealmSwift

enum LocationManagerError: Error {
  case addToTrack
}

class LocationManager: NSObject {

  static let shared = LocationManager()

  static let notificationDidChangeAuthorization = "LocationManagerDidChangeAuthorization"

  let dataManager = DataManager.shared

  private let cLLocationManager = CLLocationManager()

  private override init() {
    super.init()

    // Ask for Authorisation from the User.
    cLLocationManager.requestAlwaysAuthorization()

    if CLLocationManager.locationServicesEnabled() {

      cLLocationManager.delegate = self

      cLLocationManager.activityType = .other
      cLLocationManager.desiredAccuracy = kCLLocationAccuracyBest
      cLLocationManager.distanceFilter = 20
      cLLocationManager.allowsBackgroundLocationUpdates = true
      cLLocationManager.pausesLocationUpdatesAutomatically = false

      if #available(iOS 11.0, *) {
        cLLocationManager.showsBackgroundLocationIndicator = true
      }

      cLLocationManager.startUpdatingLocation()
      cLLocationManager.startMonitoringVisits()
    }
  }
}

extension LocationManager: CLLocationManagerDelegate {
  internal func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    guard let realm = dataManager.getRealm(type: .defaultType) else {
      return
    }

    let rlmVisit = RlmVisit(visit: visit)
    dataManager.addTo(realm:realm, object:rlmVisit)
  }

  internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let realm = dataManager.getRealm(type: .defaultType) else {
      return
    }

    for location: CLLocation in locations {
      do {
        let rlmLocation = RlmLocation(cllocation: location)
        dataManager.addTo(realm: realm, object: rlmLocation)
        try dataManager.addLocationToTrack(location: rlmLocation, realm: realm)
      } catch {
        print(error)
      }
    }
  }

  private func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) throws {
    print(error?.localizedDescription ?? "errror", error.debugDescription)

    let rlmLocationError = RlmLocationManagerFinishError()
    rlmLocationError.errorDescription = error.debugDescription
    rlmLocationError.localizedDescription = (error?.localizedDescription)!

    guard let realm = dataManager.getRealm(type: .defaultType) else {
      return
    }
    dataManager.addTo(realm:realm, object:rlmLocationError)
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // send notification
    NotificationCenter.default
      .post(name: Notification.Name(LocationManager.notificationDidChangeAuthorization), object: status)
  }
}
