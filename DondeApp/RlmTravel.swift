//
//  RlmTravel.swift
//  clientApp
//
//  Created by Adrian on 3/7/17.
//  Copyright © 2017 AdrianOrtuzar. All rights reserved.
//

import Foundation
import RealmSwift

//struct TravelModel {
//    let departureVisit:RlmVisit
//    let arrivalVisit:RlmVisit
//    let locations:[RlmLocation]
//}

class RlmTravel: Object {

    dynamic var departureVisit: RlmVisit?
    dynamic var arrivalVisit: RlmVisit?
    let locations = List<RlmLocation>()

    // Specify properties to ignore (Realm won't persist these)

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}
