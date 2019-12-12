//
//  Extensions.swift
//  Treads
//
//  Created by Tomek Klocek on 2019-12-12.
//  Copyright © 2019 Tomek Klocek. All rights reserved.
//

import Foundation

extension Double {
    func metersToMiles(places: Int ) -> Double {
        let divisor = pow(10.0, Double(places))
        return ((self / 1609.34) * divisor).rounded() / divisor
    }
    
    func metersToKilometers(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor / 1000).rounded() / divisor
    }
}
