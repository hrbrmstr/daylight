//
//  Shapes.swift
//  daylight
//
//  Created by boB Rudis on 6/23/21.
//

import Foundation
import SwiftUI

struct Sun: Shape {
  
  var today: Date
  var x: [Date]
  
  func path(in rect: CGRect) -> Path {
    
    var path = Path()
    
    let midX = today.rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX)
    let midY = rect.maxY - today.fractionalHour.rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
    
    path.addEllipse(in: CGRect(origin: CGPoint(x: midX-4, y: midY-4), size: CGSize(width: 8, height: 8)))
    
    return(path)
    
  }
  
}

struct HRule: Shape {
  
  var today: Date
  var todayRise: Double
  var todaySet: Double
  var x: [Date]
  
  func path(in rect: CGRect) -> Path {
    
    var path = Path()
    
    path.move(
      to: CGPoint(
        x: today.rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
        y: todayRise.rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
      )
    )
    
    path.addLine(
      to: CGPoint(
        x: today.rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
        y: todaySet.rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
      )
    )
    
    return(path)
    
  }
}

struct Band: Shape {
  
  var x: [Date]
  var ymin: [Double]
  var ymax: [Double]
  
  func path(in rect: CGRect) -> Path {
    
    var path = Path()
    
    path.move(
      to: CGPoint(
        x: x.first!.rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
        y: ymin.first!.rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
      )
    )
    
    for i in stride(from: 1.0, through: Double(x.count - 1), by: 1.0) {
      path.addLine(
        to: CGPoint(
          x: x[Int(i)].rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
          y: ymin[Int(i)].rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
        )
      )
    }
    
    path.addLine(
      to: CGPoint(
        x: x.last!.rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
        y: ymax.last!.rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
      )
    )
    
    for i in stride(from: Double(x.count - 1), through: 1.0, by: -1.0) {
      path.addLine(
        to: CGPoint(
          x: x[Int(i)].rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
          y: ymax[Int(i)].rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
        )
      )
    }
    
    path.addLine(
      to: CGPoint(
        x: x.first!.rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
        y: ymin.first!.rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
      )
    )
    
    path.closeSubpath()
    
    return(path)
    
  }
  
}

struct Line: Shape {
  
  var x: [Date]
  var y: [Double]
  
  func path(in rect: CGRect) -> Path {
    
    var path = Path()
    
    path.move(
      to: CGPoint(
        x: x.first!.rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
        y: y.first!.rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
      )
    )
    
    for i in stride(from: 1.0, through: Double(x.count - 1), by: 1.0) {
      path.addLine(
        to: CGPoint(
          x: x[Int(i)].rescale(from: x.min()!...x.max()!, to: rect.minX...rect.maxX),
          y: y[Int(i)].rescale(from: 0.0...24.0, to: rect.minY...rect.maxY)
        )
      )
    }
    
    return(path)
    
  }
  
}
