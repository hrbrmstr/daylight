//
//  Model.swift
//  daylight
//
//  Created by boB Rudis on 6/23/21.
//

import Foundation
import CoreLocation

class SunrisetModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  
  @Published var sunrises: [Double] = []
  @Published var sunsets: [Double] = []
  @Published var dateRange: [Date] = []
  
  @Published var today = Date()
  @Published var todayHours: Double = 0
  @Published var todayRise: Double = 0
  @Published var todaySet: Double = 0
  
  @Published var placemark: CLPlacemark?
  
  private let geocoder = CLGeocoder()

  let locationManager = CLLocationManager()
  
  var latitude: Double = 0
  var longitude: Double = 0
  
  weak var timer: Timer?

  override init() {
    
    super.init()
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()

    self.longitude = -70.8636
    self.latitude = 43.2683
    
    self.updateSunriseSunset()
    
    self.startTimer()
    
  }
  
  deinit {
    stopTimer()
  }
  
  func startTimer() {
    
    stopTimer()
    
    timer = Timer.scheduledTimer(withTimeInterval: 1*60, repeats: true) { [weak self] _ in
      
      self?.locationManager.requestLocation()
      
      DispatchQueue.main.async {
        self?.updateSunriseSunset()
      }
      
    }
    
  }
  
  func stopTimer() {
    timer?.invalidate()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    debugPrint("\(error)")
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      DispatchQueue.main.async {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.updateSunriseSunset()
      }
    }
  }
  
  func sunriset(_ d: Date) -> (rise: Double, set: Double) {
    
    let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
    let GMTHourOffset = Double(location.timeZone.secondsFromGMT() / 60 / 60)
    var sunrise: CDouble = 0
    var sunset: CDouble = 0
    
    let mdy = d.get(.day, .month, .year)

    let _ = __sunriset__(CInt(mdy.year!), CInt(mdy.month!), CInt(mdy.day!), self.longitude, self.latitude, -35.0/60.0, 1, &sunrise, &sunset)
          
    let sunriseDbl: Double = Double(sunrise) + GMTHourOffset
    let sunsetDbl: Double = Double(sunset) + GMTHourOffset

    return((rise: sunriseDbl, set: sunsetDbl))
    
  }
  
  func updateSunriseSunset() {
    
    var sunrise: CDouble = 0
    var sunset: CDouble = 0
    
    today = Date()
    
    let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
    
    geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
      if error == nil {
        self.placemark = places?[0]
      } else {
        self.placemark = nil
      }
    })
    
    let GMTHourOffset = Double(location.timeZone.secondsFromGMT() / 60 / 60)
    
    dateRange = Date.dates(
      from: Calendar.current.date(byAdding: .day, value: -(365/2), to: today)!,
      to: Calendar.current.date(byAdding: .day, value: (365/2), to: today)!
    )
    
    let ssTimes = dateRange.map { (ssDate: Date) -> (Double, Double) in
      
      let mdy = ssDate.get(.day, .month, .year)
      let _ = __sunriset__(CInt(mdy.year!), CInt(mdy.month!), CInt(mdy.day!), self.longitude, self.latitude, -35.0/60.0, 1, &sunrise, &sunset)
            
      let sunriseDbl: Double = Double(sunrise) + GMTHourOffset
      let sunsetDbl: Double = Double(sunset) + GMTHourOffset
      
      if (ssDate == today) {
        todayHours = sunsetDbl - sunriseDbl
        todayRise = sunriseDbl
        todaySet = sunsetDbl
      }
      
      return((sunriseDbl, sunsetDbl))
      
    }
    
    sunrises = ssTimes.map { val in val.0 }
    sunsets = ssTimes.map { val in val.1 }
        
  }
  
}
