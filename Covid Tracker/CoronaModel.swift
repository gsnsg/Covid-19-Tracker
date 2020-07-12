//
//  CoronaModel.swift
//  Covid Tracker
//
//  Created by Nikhi on 11/07/20.
//  Copyright © 2020 nikit. All rights reserved.
//

import Foundation
import UIKit

// Data Model for JSON data
struct CovidSummary: Decodable {
    let Global: GlobalData
    let Countries: [Location]
    let Date: String
}


struct GlobalData: Decodable {
    let TotalConfirmed: Int
    let TotalDeaths: Int
    let TotalRecovered: Int
}

struct Location: Decodable {
    var id: String {
        CountryCode
    }
    let Country: String
    let CountryCode: String
    let TotalConfirmed: Int
    let TotalDeaths: Int
    let TotalRecovered: Int
    
}
