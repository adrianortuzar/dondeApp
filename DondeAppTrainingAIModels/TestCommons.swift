import Foundation
import RealmSwift

@testable import DondeApp

class TestCommons: NSObject {
  static let shared = TestCommons()

  private override init() {
    super.init()
  }

  func createTracksFromLocation(realm: Realm) {
    let locations = realm.objects(RlmLocation.self)
    for location in locations {
      do {
        try DataManager.shared.addLocationToTrack(location: location, realm: realm)
      } catch {
        fatalError()
      }
    }
  }

  func deleteTracks(realm: Realm) {
    do {
      try realm.write {
        realm.delete(realm.objects(RlmTrack.self))
      }
    } catch {
      fatalError()
    }
  }
}
