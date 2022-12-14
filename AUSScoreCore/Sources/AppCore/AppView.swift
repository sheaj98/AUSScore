//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2022-12-12.
//

import Foundation
import ComposableArchitecture
import NewsFeature
import SwiftUI

public struct AppReducer: ReducerProtocol {
    
    public init() {}
    
    public struct State: Equatable {
        public var news: NewsFeature.State
        public var tab: Tab
    }
    
    public enum Action: Equatable {
        case news(NewsFeature.Action)
        case selectedTab(Tab)
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.news,
              action: CasePath(Action.news)) {
            NewsFeature()
        }
        
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
    
    public enum Tab {
      case news
      case scores
      case favorites
      case settings
    }

}


public struct AppView: View {
    
    private let store: StoreOf<AppReducer>
    @ObservedObject var viewStore: ViewStoreOf<AppReducer>
    
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    public var body: some View {
        Text("")
    }
    
}
