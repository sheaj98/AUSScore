//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-02-09.
//

import Foundation
import SwiftUI

// See https://stackoverflow.com/questions/56496359/swiftui-view-viewdidload/64495887#64495887
struct ViewDidLoadModifier: ViewModifier {
  @State private var didLoad = false
  private let action: (() -> Void)?

  init(perform action: (() -> Void)? = nil) {
    self.action = action
  }

  func body(content: Content) -> some View {
    content.onAppear {
      if didLoad == false {
        didLoad = true
        action?()
      }
    }
  }
}

public extension View {
  func onLoad(perform action: (() -> Void)? = nil) -> some View {
    modifier(ViewDidLoadModifier(perform: action))
  }
}
