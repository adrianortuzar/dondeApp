import Foundation
import RealmSwift

class RlmTrackInteractor: NSObject {

  static let shared = RlmTrackInteractor()

  private override init() {
    super.init()
  }

  func getResultsTracks(from fromDate: Date, to toDate: Date, realm: Realm) ->  Results<RlmTrack>? {
    return realm.objects(RlmTrack.self).filter("firstTime > %@ && lastTime < %@", fromDate, toDate)
  }

  func getTracks(from fromDate: Date, to toDate: Date, realm: Realm) -> [RlmTrack] {
    let tracksArr =  Array(realm.objects(RlmTrack.self))

    return tracksArr.filter({ (track) -> Bool in
      let firstLocation = track.locations.first!
      let lastLocation = track.locations.last!

      return firstLocation.timestamp > fromDate && lastLocation.timestamp < toDate
    })
  }

  func createNewTrackWith(location: RlmLocation, realm: Realm) throws {
    let newTrack = RlmTrack()
    newTrack.addLocation(location: location, realm: realm)
    DataManager.shared.addTo(realm: realm, object: newTrack)
  }

  func addLocationToTrack(location: RlmLocation, realm: Realm) throws {
    guard let lastTrack = realm.objects(RlmTrack.self).last else {
      try createNewTrackWith(location: location, realm: realm)
      return
    }

    if lastTrack.isBelonging(location: location) {
      lastTrack.addLocation(location: location, realm: realm)
    } else {
      try createNewTrackWith(location: location, realm: realm)
    }
  }

  private func getTrack(fromLast: Int, realm: Realm) -> RlmTrack? {
    let tracks = realm.objects(RlmTrack.self)

    let index: Int? = {
      if tracks.count >= fromLast {
        return tracks.count - fromLast
      } else {
        return nil
      }
    }()

    guard let secontLastIndex = index else {
      return nil
    }
    return tracks[secontLastIndex]
  }
}
