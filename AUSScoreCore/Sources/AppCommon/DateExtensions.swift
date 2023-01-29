//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-01-28.
//

import Foundation

public extension Date {
  var startOfDay: Date {
    Calendar.current.startOfDay(for: self)
  }
}
