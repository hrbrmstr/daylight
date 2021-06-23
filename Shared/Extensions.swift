//
//  Extensions.swift
//  daylight
//
//  Created by boB Rudis on 6/23/21.
//

import Foundation

extension Date {
    
  var fractionalHour: Double {
    
    let hour = Double(Calendar.current.component(.hour, from: self))
    let minute = Double(Calendar.current.component(.minute, from: self))
    let second = Double(Calendar.current.component(.second, from: self))
  
    return(hour + (((minute * 60.0) + second) / (3600.0)))
    
  }
  
  var display: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
    return(dateFormatter.string(from: self))
  }
  
  static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
    
    var dates: [Date] = []
    var date = fromDate
    
    while date <= toDate {
      dates.append(date)
      guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
      date = newDate
    }
    return dates
  }
  
  func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
    return calendar.dateComponents(Set(components), from: self)
  }
  
  func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
    return calendar.component(component, from: self)
  }
  
  func rescale(from domain: ClosedRange<Self>, to range: ClosedRange<Double>) -> Double {
    let x = (range.upperBound - range.lowerBound) * (self.timeIntervalSince1970 - domain.lowerBound.timeIntervalSince1970)
    let y = (domain.upperBound.timeIntervalSince1970 - domain.lowerBound.timeIntervalSince1970)
    return x / y + range.lowerBound
  }
  
}

extension Double {
  
  var asHoursMinutes: String {
    
    let formatter: DateComponentsFormatter = {
      let formatter = DateComponentsFormatter()
      formatter.unitsStyle = .full
      formatter.allowedUnits = [.hour, .minute]
      return formatter
    }()
    
    let seconds: TimeInterval = self * 60 * 60
    
    return(formatter.string(from: seconds)!)
    
  }
  
  func rescale(from domain: ClosedRange<Self>, to range: ClosedRange<Self>) -> Self {
    let x = (range.upperBound - range.lowerBound) * (self - domain.lowerBound)
    let y = (domain.upperBound - domain.lowerBound)
    return x / y + range.lowerBound
  }
  
}

extension FloatingPoint {
  func rescale(from domain: ClosedRange<Self>, to range: ClosedRange<Self>) -> Self {
    let x = (range.upperBound - range.lowerBound) * (self - domain.lowerBound)
    let y = (domain.upperBound - domain.lowerBound)
    return x / y + range.lowerBound
  }
}

//extension BinaryInteger {
//  func rescale(from domain: ClosedRange<Self>, to range: ClosedRange<Self>) -> Self {
//    let x = (range.upperBound - range.lowerBound) * (self - domain.lowerBound)
//    let y = (domain.upperBound - domain.lowerBound)
//    return x / y + range.lowerBound
//  }
//}
