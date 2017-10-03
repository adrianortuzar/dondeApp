//
//  Speed.swift
//  clientApp
//
//  Created by Adrian on 3/28/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import Foundation

struct Speed {

    enum Velocity: Int {
        case visit = 0
        case walk = 1
        case bike = 2
        case transport = 3

        var description: String {
            switch self {
            case .visit:
                return "visit"
            case .walk:
                return "walk"
            case .bike:
                return "bike"
            case .transport:
                return "transport"
            }
        }
    }

    enum MaxVelocity: Float {
        case visit = 0.0
        case walk = 1.94444
        case bike = 8.33333
    }

    // speeed in meter/second
    static func getVelocity(from speed: Double) -> Velocity {
        switch speed {
        case _ where speed <= Double(self.MaxVelocity.visit.rawValue):
            return .visit
        case _ where speed > Double(self.MaxVelocity.visit.rawValue) && speed < Double(self.MaxVelocity.walk.rawValue):
            return .walk
        case _ where speed > Double(self.MaxVelocity.walk.rawValue) &&  speed < Double(self.MaxVelocity.bike.rawValue):
            return .bike
        case _ where  speed > Double(self.MaxVelocity.bike.rawValue):
            return .transport
        default:
            return .visit
        }
    }

    static func getVelocity(from string: String) -> Velocity? {
        switch string {
        case "visit":
            return .visit
        case "walk":
            return .walk
        case "bike":
            return .bike
        case "transport":
            return .transport
        default:
            return nil
        }
    }

    static func getMaxVelocity(from string: String) -> Float? {
        switch string {
        case "visit":
            return self.MaxVelocity.visit.rawValue
        case "walk":
            return self.MaxVelocity.walk.rawValue
        case "bike":
            return self.MaxVelocity.bike.rawValue
        case "transport":
            return nil
        default:
            return nil
        }
    }
}
