//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2022-12-12.
//

import Foundation
import ComposableArchitecture

public struct NewsFeature: ReducerProtocol {
    
    public init() {}
    
    public struct State: Equatable {
        public var newsItems: [String]
    }
    
    public enum Action: Equatable {
         case tapped
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .tapped:
                return .none
            }
        }
    }
}

