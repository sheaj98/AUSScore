// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import ComposableArchitecture
import Foundation
import GameFeature
import NewsFeature
import ScoresFeature
import LeaguesFeature
import TeamFeature
import FavoritesFeature
import SwiftUI

// MARK: - AppReducer
@Reducer
public struct AppReducer {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  @Reducer
  public struct Path {
    public enum State: Equatable {
      case gameDetails(GameDetails.State)
      case league(League.State)
      case team(TeamContainerReducer.State)
    }

    public enum Action: Equatable {
      case gameDetails(GameDetails.Action)
      case league(League.Action)
      case team(TeamContainerReducer.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: \.gameDetails, action: \.gameDetails) {
        GameDetails()
      }
      Scope(state: \.league, action: \.league) {
        League()
      }
      Scope(state: \.team, action: \.team) {
        TeamContainerReducer()
      }
    }
  }

  public struct State: Equatable {
    public var news: NewsFeature.State
    public var scores: ScoresFeature.State
    public var sports: LeaguesList.State
    public var favorites: FavoritesList.State
    public var tab: Tab
    public var appDelegate: AppDelegateReducer.State
    public var scoresPath = StackState<Path.State>()
    public var leaguesPath = StackState<Path.State>()

    public init(news: NewsFeature.State = .init(), scores: ScoresFeature.State = .init(), sports: LeaguesList.State = .init(), tab: AppReducer.Tab = .news, appDelegate: AppDelegateReducer.State = .init(), favorites: FavoritesList.State = .init()) {
      self.news = news
      self.tab = tab
      self.scores = scores
      self.favorites = favorites
      self.sports = sports
      self.appDelegate = appDelegate
    }
  }

  public enum Action {
    case news(NewsFeature.Action)
    case scores(ScoresFeature.Action)
    case sports(LeaguesList.Action)
    case favorites(FavoritesList.Action)
    case selectedTab(Tab)
    case appDelegate(AppDelegateReducer.Action)
    case scoresPath(StackAction<Path.State, Path.Action>)
    case leaguesPath(StackAction<Path.State, Path.Action>)
    case clearNavStack(Tab)
  }

  public enum Tab {
    case favorites
    case news
    case scores
    case sports
  }

  public var body: some Reducer<State, Action> {
    Scope(
      state: \.news,
      action: \.news)
    {
      NewsFeature()
    }

    Scope(state: \.scores, action: \.scores) {
      ScoresFeature()
    }

    Scope(state: \.sports, action: \.sports) {
      LeaguesList()
    }
    
    Scope(state: \.favorites, action: \.favorites) {
      FavoritesList()
    }

    Reduce { state, action in
      switch action {
      case .selectedTab(let tab):
        if state.tab == tab {
          // This is a double tap send clear navStack action
          return .send(.clearNavStack(tab))
        } else {
          state.tab = tab
          return .none
        }
      case .clearNavStack(.scores):
        if state.scoresPath.isEmpty {
          let id = state.scores.selectedIndex
          return .send(.scores(.scoresLists(.element(id: id, action: .scrollToTop))))
        }
        state.scoresPath.removeAll()
        return .none
      case .clearNavStack(.news):
        let selectedCategory = state.news.newsCategories[state.news.selectIndex]
        if let _ = selectedCategory.articleView {
          return .send(.news(.newsCategories(.element(id: selectedCategory.id, action: .dismissArticle))))
        }
        return .send(.news(.newsCategories(.element(id: selectedCategory.id, action: .scrollToTop))))
      case .clearNavStack(.sports):
        if state.leaguesPath.isEmpty {
          return .none
        }
        state.leaguesPath.removeAll()
        return .none
      case .sports(.delegate(.leagueRowTapped(let sport))):
        state.leaguesPath.append(Path.State.league(League.State.init(sport: sport)))
        return .none
      case .scores(.delegate(.showGameDetails(let gameInfo))):
        state.scoresPath.append(Path.State.gameDetails(GameDetails.State(from: gameInfo)))
        return .none
      case .scores(.delegate(.leagueTapped(let sport))):
        state.scoresPath.append(Path.State.league(League.State.init(sport: sport)))
        return .none
      case .leaguesPath(.element(id: _, action: .league(.scores(.delegate(.showGameDetails(let gameInfo)))))):
        state.leaguesPath.append(Path.State.gameDetails(GameDetails.State(from: gameInfo)))
        return .none
      case .leaguesPath(.element(id: _, action: .team(.delegate(.showGameDetails(let gameInfo))))):
        state.leaguesPath.append(Path.State.gameDetails(GameDetails.State(from: gameInfo)))
        return .none
      case .leaguesPath(.element(id: _, action: .gameDetails(.delegate(.teamTapped(let team))))):
        state.leaguesPath.append(Path.State.team(TeamContainerReducer.State(team: team)))
        return .none
      case .leaguesPath(.element(id: _, action: .league(.standings(.teamTapped(let teamInfo))))):
        state.leaguesPath.append(Path.State.team(TeamContainerReducer.State(team: teamInfo)))
        return .none
      case .scoresPath(.element(id: _, action: .gameDetails(.delegate(.teamTapped(let team))))):
        state.scoresPath.append(Path.State.team(TeamContainerReducer.State(team: team)))
        return .none
      case .scoresPath(.element(id: _, action: .team(.delegate(.showGameDetails(let game))))):
        state.scoresPath.append(Path.State.gameDetails(GameDetails.State(from: game)))
        return .none
      case .scoresPath(.element(id: _, action: .league(.scores(.delegate(.showGameDetails(let gameInfo)))))):
        state.scoresPath.append(Path.State.gameDetails(GameDetails.State.init(from: gameInfo)))
        return .none
      case .scoresPath(.element(id: _, action: .league(.standings(.teamTapped(let teamInfo))))):
        state.scoresPath.append(Path.State.team(TeamContainerReducer.State.init(team: teamInfo)))
        return .none
      default:
        return .none
      }
    }
    .forEach(\.scoresPath, action: \.scoresPath) {
      Path()
    }
    .forEach(\.leaguesPath, action: \.leaguesPath) {
      Path()
    }

    SyncLogic()
    Scope(
      state: \.appDelegate,
      action: \.appDelegate)
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
          action: \.news))
          .tabItem {
            Label("News", systemImage: "newspaper")
          }
          .tag(AppReducer.Tab.news)
        

        NavigationStackStore(self.store.scope(state: \.scoresPath, action: \.scoresPath), root: {
          ScoresContainer(store: store.scope(state: \.scores, action: \.scores))
        }, destination: { store in
          SwitchStore(store) { initialState in
            switch initialState {
            case .gameDetails:
              CaseLet(/AppReducer.Path.State.gameDetails, action: AppReducer.Path.Action.gameDetails, then: GameDetailsView.init(store:))
            case .league:
              CaseLet(/AppReducer.Path.State.league, action: AppReducer.Path.Action.league, then: LeagueView.init(store:))
            case .team:
              CaseLet(/AppReducer.Path.State.team, action: AppReducer.Path.Action.team, then: TeamContainerView.init(store:))
            }
          }
        }).tabItem {
          Label("Scores", systemImage: "sportscourt")
        }
        .tag(AppReducer.Tab.scores)

        NavigationStackStore(self.store.scope(state: \.leaguesPath, action: \.leaguesPath), root: {
          LeaguesListView(store: store.scope(state: \.sports, action: \.sports))
        }, destination: { store in
          SwitchStore(store) { initialState in
            switch initialState {
            case .gameDetails:
              CaseLet(/AppReducer.Path.State.gameDetails, action: AppReducer.Path.Action.gameDetails, then: GameDetailsView.init(store:))
            case .league:
              CaseLet(/AppReducer.Path.State.league, action: AppReducer.Path.Action.league, then: LeagueView.init(store:))
            case .team:
              CaseLet(/AppReducer.Path.State.team, action: AppReducer.Path.Action.team, then: TeamContainerView.init(store:))
            }
          }
        })
        .tabItem {
          Label("Leagues", systemImage: "trophy")
        }
        .tag(AppReducer.Tab.sports)
        
        FavoritesListView(store: store.scope(state: \.favorites, action: \.favorites))
          .tabItem({
            Label("Favorites", systemImage: "star")
          })
          .tag(AppReducer.Tab.favorites)
        
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
