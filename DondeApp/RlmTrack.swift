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

    // isbelonging
    func isBelonging(location: RlmLocation) -> Bool {

        if self.locations.count != 0 {

            // check horizontal accuracy
            if location.isHorizontalAccuracyReliable() {

                // if is visit
                // if the duration between the last location of the track and the new location
                // is longer than 2 minutes we should create a new track
                let lastLocation = self.locations.last
                //Calendar.current.dateComponents([.second], from: self.lastTime, to: location.timestamp).second ?? 0
                let secondDiff: Int = Calendar.current.dateComponents([.second],
                                                                      from: lastLocation!.timestamp,
                                                                      to: location.timestamp).second ?? 0
                if secondDiff > 120 && lastLocation?.speedType.description != location.speedType.description {
                    return false
                } else if self.speedType == Speed.Velocity.visit.description {
                    // get the distance between average and the location
                    let averageLocation = CLLocation.init(latitude:
                        self.averageLatitud,
                        longitude: self.averageLongitud
                    )
                    let cllocation = CLLocation.init(latitude: location.latitud, longitude: location.longitud)
                    let distance = averageLocation.distance(from:cllocation)
                    if distance > 50 {
                        return false
                    } else {
                        return true
                    }
                } else {

                    if self.speedType == Speed.getVelocity(from:location.speed).description {
                        return true
                    } else {
                        // if the duration is less than 3 minutes
                        if self.duration() < 180 {

                            return true
                        } else {
                            return false
                        }
                    }
                }
            } else {
                // location unreliable
                // check velocity
                if Speed.getVelocity(from:location.speed).description == self.speedType {
                    return true
                } else {
                    return false
                }
            }

        } else {
            return true
        }

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
            // print error
        }
    }

    // // get difference between last date and passed location
    func secondsDifferenceRespect(location: CLLocation) -> Int {
        return Calendar.current.dateComponents([.second], from: self.lastTime, to: location.timestamp).second ?? 0
    }

    func duration() -> Int { //in minutes
        let firstlocation: RlmLocation = self.locations.first!
        let lastlocation: RlmLocation = self.locations.last!

        return Calendar.current.dateComponents([.second],
                                               from: firstlocation.timestamp,
                                               to: lastlocation.timestamp).second ?? 0
    }

    // Specify properties to ignore (Realm won't persist these)
    override static func ignoredProperties() -> [String] {
        return [""]
    }
}
