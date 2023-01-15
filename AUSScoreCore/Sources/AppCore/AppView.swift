// Copyright © 2022 Solbits Software Inc. All rights reserved.

import ComposableArchitecture
import Foundation
import NewsFeature
import SwiftUI

// MARK: - AppReducer

public struct AppReducer: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable {
    public var news: NewsFeature.State
    public var tab: Tab

    public init(news: NewsFeature.State = .init(), tab: AppReducer.Tab = .news) {
      self.news = news
      self.tab = tab
    }
  }

  public enum Action: Equatable {
    case news(NewsFeature.Action)
    case selectedTab(Tab)
    case appDelegate(AppDelegateReducer.Action)
  }

  public enum Tab {
    case news
    case scores
    case favourites
    case settings
  }

  public var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \.news,
      action: CasePath(Action.news))
    {
      NewsFeature()
    }

    Reduce { _, action in
      switch action {
      default:
        return .none
      }
    }
  }
}

// MARK: - AppView

public struct AppView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<AppReducer>) {
    self.store = store
    viewStore = ViewStore(self.store.scope(state: ViewState.init))
  }

  // MARK: Public

  public var body: some View {
    mainAppView()
  }

  // MARK: Internal

  struct ViewState: Equatable {
    let tab: AppReducer.Tab

    init(
      state: AppReducer.State)
    {
      tab = state.tab
    }
  }

  @ObservedObject var viewStore: ViewStore<ViewState, AppReducer.Action>

  // MARK: Private

  private let store: StoreOf<AppReducer>

  @ViewBuilder
  private func mainAppView() -> some View {
    TabView(
      selection: viewStore.binding(
        get: \.tab,
        send: AppReducer.Action.selectedTab))
    {
      NewsContainer(store: store.scope(
        state: \.news,
        action: AppReducer.Action.news))
        .tabItem {
          Label("News", systemImage: "newspaper")
        }
        .tag(AppReducer.Tab.news)

      Text("Score View")
        .tabItem {
          Label("Scores", systemImage: "sportscourt")
        }
        .tag(AppReducer.Tab.scores)
    }
  }
}
