import SwiftUI
import CoreLocation

struct ContentView: View {
  
  @ObservedObject var model = SunrisetModel()
  
  var body: some View {
    
    VStack {
      
#if os(iOS)
      Spacer()
        .padding()
#endif
      
      Text("\(Date().display)\n\(model.todayHours.asHoursMinutes) of daylight")
        .multilineTextAlignment(.center)
        .padding()
      
      GeometryReader { g in
        
        Line(x:model.dateRange, y:model.sunrises)
          .stroke(style: StrokeStyle(lineWidth: 1.0, lineCap: .round))
          .foregroundColor(Color.primary)
        
        Line(x:model.dateRange, y:model.sunsets)
          .stroke(style: StrokeStyle(lineWidth: 1.0, lineCap: .round))
          .foregroundColor(Color.primary)
        
        HRule(today: model.today, todayRise: model.todayRise, todaySet: model.todaySet, x: model.dateRange)
          .stroke(style: StrokeStyle(lineWidth: 0.5, lineCap: .round))
          .foregroundColor(Color.primary)
        
        Sun(today: model.today, x: model.dateRange)
          .fill(Color.yellow)
        
      }
      .border(Color.primary)
      .padding()
      
#if os(iOS)
      Spacer()
        .padding()
#endif
      
    }
    .padding()
    
  }
}

