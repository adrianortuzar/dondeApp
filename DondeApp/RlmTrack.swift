//
//  RlmTrack.swift
//  clientApp
//
//  Created by Adrian on 3/20/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class RlmTrack: Object {

  let locations = List<RlmLocation>()

  dynamic var averageLatitud: Double = 0
  dynamic var averageLongitud: Double = 0
  dynamic var averageSpeed: Double = 0

  dynamic var speedType: String = ""

  dynamic var firstTime: Date = Date()
  dynamic var lastTime: Date = Date()

  func isBelonging(location: RlmLocation) -> Bool {

    if isVisit(location: location) {
      return isVisitBelonging(location: location)
    }

    if speedType == Speed.Velocity.visit.description {
      return location.speedType == speedType
    }

    if diffWithLastLocation(location: location) > 240 {
      return false
    } else {
      return isValidAcceleration(location: location)
    }
  }

  func isVisit(location: RlmLocation) -> Bool {
    return location.speedType == Speed.Velocity.visit.description
  }

  func isVisitBelonging(location: RlmLocation) -> Bool {
    if !isVisit(location: location) {
      return false
    }

    guard let lastlocation = locations.last else {
      return true
    }

    return lastlocation.speedType == location.speedType
  }

  func isDistanceGreatThan50m(location: RlmLocation) -> Bool {
    return getDistanceFromAverate(location: location) > 50
  }

  func isValidAcceleration(location: RlmLocation) -> Bool {
    guard let lastLocation = self.locations.last else {
      return false
    }

    if location.speed < 0 && lastLocation.speed < 0 {
      return true
    } else if location.speed < 0 || lastLocation.speed < 0 {
      return false
    }

    return abs(location.speed - lastLocation.speed) < 10
  }

  func getDistanceFromAverate(location: RlmLocation) -> CLLocationDistance{
    // get the distance between average and the location
    let averageLocation = CLLocation.init(latitude:
      self.averageLatitud,
                                          longitude: self.averageLongitud
    )
    let cllocation = CLLocation.init(latitude: location.latitud, longitude: location.longitud)
    return averageLocation.distance(from:cllocation)
  }

    func setAverageCoordinates() {

        let averageLatitudSum = self.locations.reduce(0) { (result, location) -> Double in
            if location.isHorizontalAccuracyReliable() {
                return result + location.latitud
            } else {
                return result
            }
        }

        let averageLongitudSum = self.locations.reduce(0) { (result, location) -> Double in
            if location.isHorizontalAccuracyReliable() {
                return result + location.longitud
            } else {
                return result
            }
        }

        let totalReliableLocations = Array(self.locations).filter { $0.horizontalAccuracy < 100 }

        self.averageLatitud = averageLatitudSum / Double(totalReliableLocations.count)
        self.averageLongitud = averageLongitudSum / Double(totalReliableLocations.count)

    }

    func setAverageSpeed() {

        self.averageSpeed = {
            let totalLocationsValidSpeed: Array = Array(self.locations).filter { $0.speed != -1 }

            let totalSpeedSum = self.locations.reduce(0) { (total, location) -> Double in
                if location.speed != -1 {
                    return total + location.speed
                } else {
                    return total
                }
            }

            return (totalLocationsValidSpeed.count == 0) ? totalSpeedSum : totalSpeedSum / Double(totalLocationsValidSpeed.count)
        }()
    }

    func setSpeedType() {

        self.speedType = {
            let totalLocationsValidSpeed: Array = Array(self.locations).filter { $0.speed != -1 }
            let totalLocations = self.locations.count

            let percentegeLocationsValidSpeeds = (totalLocationsValidSpeed.count == 0) ? 0 : (totalLocationsValidSpeed.count * 100)/totalLocations

            // if locations valid speeds are more than 50%
            if percentegeLocationsValidSpeeds > 50 {

                let velocityFromAverage =  Speed.getVelocity(from:self.averageSpeed)

                // if the velocity from average is bike
                if velocityFromAverage.description == Speed.Velocity.bike.description {

                    let maxVelocityFromAverage = Speed.getMaxVelocity(from: velocityFromAverage.description)

                    // get locations with faster velocity than the max velocity
                    let locationsWithFasterVelocity = Array(self.locations)
                        .filter { $0.speed > Double(maxVelocityFromAverage!) }

                    let percentageLocationsWithFasterVelocity = (locationsWithFasterVelocity.count * 100) / self.locations.count

                    // if there is more than 50% of locations with faster velocity than the max velocity from average
                    if percentageLocationsWithFasterVelocity > 25 {
                        return Speed.Velocity.transport.description
                    } else {
                        return Speed.Velocity.bike.description
                    }
                } else {
                    return velocityFromAverage.description
                }
            } else {
                return Speed.Velocity.visit.description
            }
        }()
    }

    func addLocation(location: RlmLocation, realm: Realm) {
        do {
            try realm.write {
                self.locations.append(location)
                self.setAverageSpeed()
                self.setSpeedType()
                self.setAverageCoordinates()
                self.lastTime = location.timestamp
                self.firstTime = self.locations.first!.timestamp
            }
        } catch {
            fatalError()
        }
    }

    // // get difference between last date and passed location
    func secondsDifferenceRespect(location: CLLocation) -> Int {
        return Calendar.current.dateComponents([.second], from: self.lastTime, to: location.timestamp).second ?? 0
    }

  func diffWithLastLocation(location: RlmLocation) -> Int { //in minutes
    guard let lastlocation: RlmLocation = self.locations.last else {
      return 0
    }

    return Calendar.current.dateComponents([.second],
                                               from: lastlocation.timestamp,
                                               to: location.timestamp).second ?? 0
  }

    // Specify properties to ignore (Realm won't persist these)
    override static func ignoredProperties() -> [String] {
        return [""]
    }
}
