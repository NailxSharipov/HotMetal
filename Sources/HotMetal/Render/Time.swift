//
//  Time.swift
//  
//
//  Created by Nail Sharipov on 12.04.2022.
//

import Foundation

public struct Time {

  /// The total time of the app. This is just a number that is always
  /// increasing, it might not start at 0, just use it for relative calculations
  public let totalTime: TimeInterval

  /// The time since the last update call
  public let updateTime: TimeInterval
    
}
