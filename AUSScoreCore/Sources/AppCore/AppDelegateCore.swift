// Copyright © 2023 Solbits Software Inc. All rights reserved.

import ComposableArchitecture
import Foundation

public struct AppDelegateReducer: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  public struct State: Equatable { }
  public enum Action: Equatable {
    case didFinishLaunching
  }

  public func reduce(into _: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .didFinishLaunching:
      return .none
    }
  }
}
