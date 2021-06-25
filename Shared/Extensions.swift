//
//  Extensions.swift
//  daylight
//
//  Created by boB Rudis on 6/23/21.
//

import Foundation
import SwiftUI

extension Date {
    
  var fractionalHour: Double {
    
    let hour = Double(Calendar.current.component(.hour, from: self))
    let minute = Double(Calendar.current.component(.minute, from: self))
    let second = Double(Calendar.current.component(.second, from: self))
  
    return(hour + (((minute * 60.0) + second) / (3600.0)))
    
  }
  
  var display: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM d, yyyy HH:mm"
    return(dateFormatter.string(from: self))
  }
  
  var displayShort: String {
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
  
  func rescale(from domain: ClosedRange<Self>, to range: ClosedRange<CGFloat>) -> CGFloat {
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

extension CGFloat {
  
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

extension View {
    func trackingMouse(onMove: @escaping (NSPoint) -> Void) -> some View {
        TrackinAreaView(onMove: onMove) { self }
    }
}

struct TrackinAreaView<Content>: View where Content : View {
    let onMove: (NSPoint) -> Void
    let content: () -> Content
    
    init(onMove: @escaping (NSPoint) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onMove = onMove
        self.content = content
    }
    
    var body: some View {
        TrackingAreaRepresentable(onMove: onMove, content: self.content())
    }
}

struct TrackingAreaRepresentable<Content>: NSViewRepresentable where Content: View {
    let onMove: (NSPoint) -> Void
    let content: Content
    
    func makeNSView(context: Context) -> NSHostingView<Content> {
        return TrackingNSHostingView(onMove: onMove, rootView: self.content)
    }
    
    func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
    }
}

class TrackingNSHostingView<Content>: NSHostingView<Content> where Content : View {
    let onMove: (NSPoint) -> Void
    
    init(onMove: @escaping (NSPoint) -> Void, rootView: Content) {
        self.onMove = onMove
        
        super.init(rootView: rootView)
        
        setupTrackingArea()
    }
    
    required init(rootView: Content) {
        fatalError("init(rootView:) has not been implemented")
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.mouseMoved, .activeAlways, .inVisibleRect]
        self.addTrackingArea(NSTrackingArea.init(rect: .zero, options: options, owner: self, userInfo: nil))
    }
        
    override func mouseMoved(with event: NSEvent) {
        self.onMove(self.convert(event.locationInWindow, from: nil))
    }
}
