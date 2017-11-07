//
//  RlmLocation.swift
//  clientApp
//
//  Created by Adrian on 2/10/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class RlmLocation: Object {

  convenience init(cllocation: CLLocation) {
    self.init()
    let locValue: CLLocationCoordinate2D = cllocation.coordinate
    latitud = locValue.latitude
    longitud = locValue.longitude

    if cllocation.floor?.level != nil {
      floor = (cllocation.floor?.level)!
    }

    altitud = Float(cllocation.altitude)
    horizontalAccuracy = Float(cllocation.horizontalAccuracy)
    verticalAccuracy = Float(cllocation.verticalAccuracy)
    timestamp = cllocation.timestamp
    speed = cllocation.speed
    course = Float(cllocation.course)
    speedType = Speed.getVelocity(from: cllocation.speed).description
  }

  dynamic var latitud: Double = 0
  dynamic var longitud: Double = 0
  dynamic var altitud: Float = 0
  dynamic var floor: Int = 0
  dynamic var horizontalAccuracy: Float = 0
  dynamic var verticalAccuracy: Float = 0
  dynamic var timestamp: Date = Date(timeIntervalSince1970: 1)
  dynamic var customName: String = ""
  dynamic var speed: Double = 0
  dynamic var course: Float = 0
  dynamic var speedType: String = ""

  var track: RlmTrack? {
    guard let realm = realm else {
      return nil
    }
    guard let track = tracks.first else {
      return nil
    }
    return track
  }
  private let tracks = LinkingObjects(fromType: RlmTrack.self, property: "locations")

  func isHorizontalAccuracyReliable() -> Bool {
    return (self.horizontalAccuracy < 100)
  }
}
