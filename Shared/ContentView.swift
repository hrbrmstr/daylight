import SwiftUI
import CoreLocation

func daylightLeft(sunsetFractionalHour: Double, currentFractionalHour: Double) -> String {
  let remaining: Double = sunsetFractionalHour - currentFractionalHour
  if ((remaining) > 0) {
    return("\(remaining.asHoursMinutes) of daylight remaining")
  } else {
    return("The sun has set.")
  }
}

func fmtPlacemark(_ p: CLPlacemark?) -> String {
  guard let tempP = p else {
    return("")
  }
  return("\(tempP.locality!), \(tempP.country!)\n")
}

struct ContentView: View {
  
#if os(iOS)
  @State private var orientation = UIDeviceOrientation.unknown
#endif
  
  @ObservedObject var model = SunrisetModel()
  @State var note: String = " "
  
  var body: some View {
    
    VStack {
            
      Text("\(model.today.display)\n\(fmtPlacemark(model.placemark))\(model.todayHours.asHoursMinutes) of total daylight\n\(daylightLeft(sunsetFractionalHour: model.todaySet, currentFractionalHour: model.today.fractionalHour))")
        .multilineTextAlignment(.center)
        .padding()
      
      GeometryReader { g in

        Rectangle()
          .fill(.black)
          .trackingMouse { location in
            let day = location.x.rescale(from: 0...g.size.width, to: model.dateRange.min()!.timeIntervalSince1970...model.dateRange.max()!.timeIntervalSince1970)
            let dayte = Date(timeIntervalSince1970: day)
            let ss = model.sunriset(dayte)
            self.note = "\(dayte.displayShort) ☀️ \((ss.set-ss.rise).asHoursMinutes)"
          }
          .clipped()
        
        Band(x: model.dateRange, ymin: model.sunrises, ymax: model.sunsets)
          .fill(
            RadialGradient(colors: [.yellow, .white, .yellow], center: .center, startRadius: 1.0, endRadius: 50.0)
          )
        
        HRule(today: model.today, todayRise: model.todayRise, todaySet: model.todaySet, x: model.dateRange)
          .stroke(style: StrokeStyle(lineWidth: 0.5, lineCap: .round))
          .foregroundColor(Color.black)
        
        if ((model.today.fractionalHour >= model.todayRise) && (model.today.fractionalHour <= model.todaySet)) {
          Sun(today: model.today, x: model.dateRange)
            .fill(Color.black)
        }
        
      }
      .border(Color.primary)
      .padding()
      
      Text(note)
      
#if os(iOS)
      Group {
        if orientation.isPortrait {
          Spacer().padding(10)
        } else if orientation.isLandscape {
          Spacer()
        } else {
          Spacer()
        }
      }
      .onRotate { newOrientation in
//        orientation = newOrientation
      }
#endif
      
    }
    .padding()
    
  }
}

#if os(iOS)
struct DeviceRotationViewModifier: ViewModifier {
  let action: (UIDeviceOrientation) -> Void
  
  func body(content: Content) -> some View {
    content
      .onAppear()
      .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
        action(UIDevice.current.orientation)
      }
  }
}

// A View wrapper to make the modifier easier to use
extension View {
  func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
    self.modifier(DeviceRotationViewModifier(action: action))
  }
}
#endif
