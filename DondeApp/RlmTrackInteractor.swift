import Foundation
import RealmSwift

protocol RlmTrackInteractorProtocol {
  func getResultsTracks(from fromDate: Date, to toDate: Date, realm: Realm) ->  Results<RlmTrack>?
  func getTracks(from fromDate: Date, to toDate: Date, realm: Realm) -> [RlmTrack]
  /// decided in wich track the location has to be.
  func addLocationToTrack(location: RlmLocation, realm: Realm)
  func addVisitToTrack(visit: RlmVisit, realm: Realm)
}

class RlmTrackInteractor: NSObject, RlmTrackInteractorProtocol {

  static let shared = RlmTrackInteractor()
  private let rlmLocationInteractor = RlmLocationInteractor.shared
  private let rlmInteractor = RlmInteractor.shared

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

      return firstLocation.timestamp >= fromDate && lastLocation.timestamp <= toDate
    })
  }

  private func getVisitTracks(from fromDate: Date, to toDate: Date, realm: Realm) -> [RlmTrack] {
    let tracks = getTracks(from: fromDate, to: toDate, realm: realm)
    return tracks.filter { $0.speedType == Speed.Velocity.visit.description }
  }

  // MARK: create tracks

  func createNewTrackWith(location: RlmLocation, realm: Realm) {
    let newTrack = RlmTrack()
    newTrack.add(location: location, realm: realm)
    rlmInteractor.addTo(realm: realm, object: newTrack)
  }

  func createNewTrackWith(visit: RlmVisit, realm: Realm) {
    let track = RlmTrack()
    track.setVisit(visit: visit, realm: realm)
    rlmInteractor.addTo(realm: realm, object: track)
  }

  // MARK: add tracks

  func addLocationToTrack(location: RlmLocation, realm: Realm) {
    guard let lastTrack = realm.objects(RlmTrack.self).last else {
      createNewTrackWith(location: location, realm: realm)
      return
    }

    if lastTrack.isBelonging(location: location) {
      lastTrack.add(location: location, realm: realm)
    } else {
      createNewTrackWith(location: location, realm: realm)
    }
  }

  func addVisitToTrack(visit: RlmVisit, realm: Realm) {
    if realm.objects(RlmTrack.self).isEmpty {
      createNewTrackWith(visit: visit, realm: realm)
      return
    }

    if visit.isCurrentVisit && !visit.isArrivalCourrupted {
      addCurrentVisitToTrack(visit: visit, realm: realm)
    } else if visit.isArrivalCourrupted {
      addVisitCurrenArrivalCorruptedToTrack(visit: visit, realm: realm)
    } else if !visit.isCurrentVisit && !visit.isArrivalCourrupted {
      addVisitFinishToTrack(visit: visit, realm: realm)
    } else {
      fatalError()
    }
  }

  private func addVisitFinishToTrack(visit: RlmVisit, realm: Realm) {
    if visit.isCurrentVisit || visit.isArrivalCourrupted {
      return
    }
    setVisitOntracks(visit: visit, fromDate: visit.arrivalDate, toDate: visit.departureDate, realm: realm)
  }

  private func addVisitCurrenArrivalCorruptedToTrack(visit: RlmVisit, realm: Realm) {
    if !visit.isArrivalCourrupted {
      return
    }

    let visitTracks = getVisitTracks(from: visit.arrivalDate, to: Date(), realm: realm)

    guard let track = visitTracks.last else {
      createNewTrackWith(visit: visit, realm: realm)
      return
    }

    track.setVisit(visit: visit, realm: realm)
  }

  private func addCurrentVisitToTrack(visit: RlmVisit, realm: Realm) {
    if !visit.isCurrentVisit || visit.isArrivalCourrupted {
      return
    }

    setVisitOntracks(visit: visit, fromDate: visit.arrivalDate, toDate: Date(), realm: realm)
  }

  private func setVisitOntracks(visit: RlmVisit, fromDate: Date, toDate: Date, realm: Realm) {
    let visitTracks = getVisitTracks(from: fromDate, to: toDate, realm: realm)

    guard var track = visitTracks.first else {
      createNewTrackWith(visit: visit, realm: realm)
      return
    }

    if visitTracks.count > 1 {
      guard let unwraptrack = merge(tracks: visitTracks, realm: realm) else {
        return
      }
      track = unwraptrack
    }

    track.setVisit(visit: visit, realm: realm)
  }

  // MARK: merge

  func merge(tracks: [RlmTrack], realm: Realm) -> RlmTrack? {
    if tracks.isEmpty {
      return nil
    }

    let resultTrack = RlmTrack()

    for track in tracks {
      resultTrack.add(locations: Array(track.locations), realm: realm)
      rlmInteractor.delete(object: track, realm: realm)
    }

    return resultTrack
  }

  // MARK: get

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
