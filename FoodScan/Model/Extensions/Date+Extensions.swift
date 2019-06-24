//
//  Date+Extensions.swift
//  Bazinga
//
//  Created by C110 on 15/12/17.
//  Copyright © 2017 C110. All rights reserved.
//

import Foundation

public extension Date {
    
    // returns if a date is over 18 years ago
    func isOver18Years() -> Bool {
        var comp = (Calendar.current as NSCalendar).components(NSCalendar.Unit.month.union(.day).union(.year), from: Date())
        guard comp.year != nil && comp.day != nil else { return false }
        
        comp.year! -= 18
        comp.day! += 1
        if let date = Calendar.current.date(from: comp) {
            if self.compare(date) != ComparisonResult.orderedAscending {
                return false
            }
        }
        return true
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func localToUTC(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dt = dateFormatter.date(from: self.toString(format: format))
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: dt!)
    }
    
    func UTCToLocal(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self.toString(format: format))
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: dt!)
    }
}

public func stringToDate(_ str: String)->Date{
    
//    let formatter = DateFormatter()
//    formatter.timeZone = TimeZone.current
//    formatter.dateFormat="yyyy-MM-dd HH:mm:ss"
//    print(str)
//    return formatter.date(from: str)!
    
    ///====Changed by Map : on 13/5/2019
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_us")
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let dt = dateFormatter.date(from: str)
    return dt!
}

func convertDateFormater(_ date: String, currentFormate: String, newFormate: String) -> String
{
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = currentFormate
//    let date = dateFormatter.date(from: date)
//    dateFormatter.dateFormat = newFormate
//    return  dateFormatter.string(from: date!)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
    let date = dateFormatter.date(from: date)
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return  dateFormatter.string(from: date!)
    
}
