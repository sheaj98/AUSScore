// Copyright © 2023 Shea Sullivan. All rights reserved.

import Foundation

extension Date {
  public var startOfDay: Date {
    Calendar.current.startOfDay(for: self)
  }
}
