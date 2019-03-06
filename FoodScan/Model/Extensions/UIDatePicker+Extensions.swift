//
//  UIDatePicker.swift
//  Bazinga
//
//  Created by C110 on 18/11/17.
//  Copyright © 2017 C110. All rights reserved.
//

import UIKit

extension UIDatePicker
{
    func set18YearValidation() {
        let currentDate: NSDate = NSDate()
        let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let components: NSDateComponents = NSDateComponents()
        components.calendar = calendar as Calendar
        components.year = -18
        let maxDate: NSDate = calendar.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        components.year = -150
        let minDate: NSDate = calendar.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        self.minimumDate = minDate as Date
        self.maximumDate = maxDate as Date
    }
}
