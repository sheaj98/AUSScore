// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import ComposableArchitecture
import Foundation
import GameFeature
import NewsFeature
import ScoresFeature
import SportsFeature
import SwiftUI

// MARK: - AppReducer

public struct AppReducer: Reducer {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  // MARK: Public

  public struct Path: Reducer {
    public enum State: Equatable {
      case gameDetails(GameDetails.State)
      case league(League.State)
    }

    public enum Action: Equatable {
      case gameDetails(GameDetails.Action)
      case league(League.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.gameDetails, action: /Action.gameDetails) {
        GameDetails()
      }
      Scope(state: /State.league, action: /Action.league) {
        League()
      }
    }
  }

  public struct State: Equatable {
    public var news: NewsFeature.State
    public var scores: ScoresFeature.State
    public var sports: LeaguesList.State
    public var tab: Tab
    public var appDelegate: AppDelegateReducer.State
    public var scoresPath = StackState<Path.State>()

    public init(news: NewsFeature.State = .init(), scores: ScoresFeature.State = .init(), sports: LeaguesList.State = .init(), tab: AppReducer.Tab = .news, appDelegate: AppDelegateReducer.State = .init()) {
      self.news = news
      self.tab = tab
      self.scores = scores
      self.sports = sports
      self.appDelegate = appDelegate
    }
  }

  public enum Action {
    case news(NewsFeature.Action)
    case scores(ScoresFeature.Action)
    case sports(LeaguesList.Action)
    case selectedTab(Tab)
    case appDelegate(AppDelegateReducer.Action)
    case scoresPath(StackAction<Path.State, Path.Action>)
  }

  public enum Tab {
    case news
    case scores
    case sports
  }

  public var body: some Reducer<State, Action> {
    Scope(
      state: \.news,
      action: CasePath(Action.news))
    {
      NewsFeature()
    }

    Scope(state: \.scores, action: CasePath(Action.scores)) {
      ScoresFeature()
    }

    Scope(state: \.sports, action: CasePath(Action.sports)) {
      LeaguesList()
    }

    Reduce { state, action in
      switch action {
      case .selectedTab(let tab):
        state.tab = tab
        return .none
      case .scores(.scoresList(id: _, action: .gamesSection(id: _, action: .gamesRow(id: _, action: .tapped(let gameInfo))))):
        state.scoresPath.append(Path.State.gameDetails(GameDetails.State(from: gameInfo)))
        return .none
      case .scoresPath:
        return .none
      default:
        return .none
      }
    }
    .forEach(\.scoresPath, action: /Action.scoresPath) {
      Path()
    }

    SyncLogic()
    Scope(
      state: \.appDelegate,
      action: /Action.appDelegate)
    {
      AppDelegateReducer()
    }
  }
}

// MARK: - AppView

public struct AppView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<AppReducer>) {
    self.store = store
    viewStore = ViewStore(store, observe: ViewState.init)
  }

  // MARK: Public

  public var body: some View {
    TabView(
      selection: viewStore.binding(
        get: \.tab,
        send: AppReducer.Action.selectedTab))
    {
      Group {
        NewsContainer(store: store.scope(
          state: \.news,
          action: AppReducer.Action.news))
          .tabItem {
            Label("News", systemImage: "newspaper")
          }
          .tag(AppReducer.Tab.news)
        

        NavigationStackStore(self.store.scope(state: \.scoresPath, action: { .scoresPath($0) }), root: {
          ScoresContainer(store: store.scope(state: \.scores, action: AppReducer.Action.scores))
        }, destination: { store in
          SwitchStore(store) { initialState in
            switch initialState {
            case .gameDetails:
              CaseLet(/AppReducer.Path.State.gameDetails, action: AppReducer.Path.Action.gameDetails, then: GameDetailsView.init(store:))
            case .league:
              Text("League")
            }
          }
        }).tabItem {
          Label("Scores", systemImage: "sportscourt")
        }
        .tag(AppReducer.Tab.scores)

        NavigationView {
          LeaguesListView(store: store.scope(state: \.sports, action: AppReducer.Action.sports))
        }
        .tabItem {
          Label("Leagues", systemImage: "trophy")
        }
        .tag(AppReducer.Tab.sports)
      }
      .toolbarColorScheme(.light, for: .bottomBar)
    }
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
}
