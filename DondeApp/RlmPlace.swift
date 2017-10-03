//
//  RlmPlace.swift
//  clientApp
//
//  Created by Adrian on 3/9/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class RlmPlace: Object {

    let visits = LinkingObjects(fromType: RlmVisit.self, property: "_place")
    dynamic var customName: String?
    dynamic var averageLatitud: Double = 0
    dynamic var averageLongitud: Double = 0

    func calculateAverageCoordinates() {
        self.averageLatitud = self.visits.reduce(0) { $0 + $1.latitudPrivate } / Double(self.visits.count)
        self.averageLongitud = self.visits.reduce(0) { $0 + $1.longitudPrivate } / Double(self.visits.count)

    }

    var locationCoordinate2D: CLLocationCoordinate2D? {
        get {
            if self.averageLatitud != 0 && self.averageLongitud != 0 {
                return CLLocationCoordinate2D(latitude: self.averageLatitud, longitude:self.averageLongitud)
            } else {
                return nil
            }
        }

        set { }
    }

    override static func ignoredProperties() -> [String] {
        return ["locationCoordinate2D"]
    }
}
