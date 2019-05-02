//
//  Date.swift
//  thecareportal
//
//  Created by Anil Kukadeja on 01/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import Foundation

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    static let preciseUTCTime : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

extension Date {
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var startOfWeek: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    var endOfWeek: Date? {
        let calendar = Calendar.current
        var comp = DateComponents()
        comp.weekOfYear = 1
        return calendar.date(byAdding: comp, to: self)!
    }
    
    var monthofWeek : Date?{
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
    }
    
    func datebyAddingDay(day : Int) -> Date{
        return Calendar.current.date(byAdding: DateComponents(day: day), to: self)!
    }
    
    func startOfMonthDate() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    func endOfMonthDate() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self)!
    }
    
    var nanosecond: Int { return Calendar.current.component(.nanosecond,  from: self)   }
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
    
    var preciseUTCTime : String{
        return Formatter.preciseUTCTime.string(for: self) ?? ""
    }
    
    func getStringInformat(convDateFormatter : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = convDateFormatter
        return dateFormatter.string(from: self)
    }
    
    public static func dateFromInterval(_ interval: Double) -> Date? {
        return Date(timeIntervalSince1970: interval / 1000)
    }
    
    public static func dateFromString(_ string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    public static func intervalFromDate(_ date: Date) -> Double {
        return date.timeIntervalSince1970 * 1000
    }
    
    var weekday: String {
        return self.formatted("EEE")
    }
    
    var day: String {
        return self.formatted("dd")
    }
    
    var month: String {
        return self.formatted("MM")
    }
    
    var monthString: String {
        return self.formatted("MMMM")
    }
    
    var year: String {
        return self.formatted("YYYY")
    }
    
    func formatted(_ format: String = "dd/MM/yyyy HH:mm:ss ZZZ") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    var dayOfMonth: Int {
        let comp = Calendar.current.dateComponents([.month,.day], from:self)
        return comp.day!
    }
    
    var dayOfWeek: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        let comp = calendar.dateComponents([.weekday], from: self)
        return comp.weekday ?? -1
    }
    
    static var serverUnixTimestamp: TimeInterval {
        return Date().timeIntervalSince1970 * 1000 - ServerManager.shared.timestampOffset
    }
    
    static var serverDate: Date {
        return Date(timeIntervalSince1970: Date.serverUnixTimestamp / 1000) }

    func getDifferanceBetweenDate(endDate : Date) -> String{
        let timeInterval = self.timeIntervalSince(endDate)
        if timeInterval < 3600{
            return "\(Int(timeInterval) / 60) minutes"
        }
        else if timeInterval >= 3600 && timeInterval < 86400{
            let hours = Int(floor(timeInterval / 3600))
            let minutes = Int(floor(timeInterval.truncatingRemainder(dividingBy: 3600) / 60))
            if hours < 1{
                return "\(minutes) minutes"
            }
            return "\(hours) \(hours >= 1 ? "hour":"hours")  \(minutes > 0 ? "\(minutes) minutes":"")"
            
        }
        else if timeInterval >= 86400 && timeInterval < (60*60*24*30){
            if (timeInterval / 86400) == 1{
                return "\(Int(floor(timeInterval / 86400))) day"
            }
            else{
                return "\(Int(floor(timeInterval / 86400))) days"
            }
        }
        else{
            if (timeInterval / 60*60*24*30) == 1{
                return "\(Int(floor(timeInterval / 86400))) month"
            }
            else{
                return "\(Int(floor(timeInterval / 86400))) months"
            }
        }
    }
    
    func sameDayAs(_ otherDate: Date) -> Bool {
        return day == otherDate.day &&
            month == otherDate.month &&
            year == otherDate.year
    }
    
    func isDateInToday(date : Date) -> Bool{
       return NSCalendar.current.isDateInToday(date)
    }
    
    func isDateInYesterday(date : Date) -> Bool{
        return NSCalendar.current.isDateInYesterday(date)
    }
    
}

