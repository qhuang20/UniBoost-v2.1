//
//  Date+Helper.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension Date {
    
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "s"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "m"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "h"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "d"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "w"
        } else {
            quotient = secondsAgo / month
            unit = "mon"
        }
        
//        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s")"
        return "\(quotient)\(unit)" + " ago"///or change follow label postion
    }
    
}


