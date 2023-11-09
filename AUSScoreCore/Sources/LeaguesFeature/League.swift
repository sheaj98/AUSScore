//
//  SwiftUIView.swift
//  
//
//  Created by Shea Sullivan on 2023-03-25.
//

import SwiftUI
import ComposableArchitecture
import Models
import AppCommon
import NewsFeature
import ScoresFeature

public struct League: Reducer {
  public init() {}
  
  public enum Tab: Int {
    case news = 0
    case scores = 1
    case standings = 2
  }
  
  public struct State: Equatable, Identifiable {
    public var sport: SportInfo
    public var selectedView: Int
    public var isFavorite: Bool
    public var isUpdatingFavorite: Bool
    public var news: NewsList.State
    public var scores: ScoresFeature.State
    public var standings: StandingsReducer.State
    public var userId: String?
    
    public init(sport: SportInfo, selectedView: Int = 0, isFavorite: Bool = false, isUpdatingFavorite: Bool = false, userId: String? = nil) {
      self.sport = sport
      self.selectedView = selectedView
      self.news = .init(from: sport.newsFeed, index: 0)
      self.isFavorite = isFavorite
      self.scores = ScoresFeature.State.init(sportId: sport.id)
      self.standings = StandingsReducer.State(sportId: sport.id)
      self.isUpdatingFavorite = isUpdatingFavorite
      self.userId = userId
    }
    
    public var id: Sport.ID { self.sport.id }
  }
  
  public enum Action: Equatable {
    case task
    case toggleIsFavorite(Bool)
    case updateFavoriteSport(Bool)
    case selected(tab: Int)
    case news(NewsList.Action)
    case scores(ScoresFeature.Action)
    case standings(StandingsReducer.Action)
    case user(String)
  }
  
  public var body: some Reducer<State, Action> {
    
    Scope(state: \.news, action: /Action.news) {
      NewsList()
    }
    
    Scope(state: \.scores, action: /Action.scores) {
      ScoresFeature()
    }
    
    Scope(state: \.standings, action: /Action.standings) {
      StandingsReducer()
    }
    
    Reduce { state, action in
      switch(action) {
      case .task:
        return .run { [id = state.id] send in
          for try await user in dbClient.userStream() {
            await send(.user(user.id))
            if user.favoriteSports.contains(where: { $0.id == id }) {
              await send(.toggleIsFavorite(true))
            }
          }
        }
      case .toggleIsFavorite(let value):
        state.isFavorite = value
        state.isUpdatingFavorite = false
        return .none
      case .updateFavoriteSport(let value):
        state.isUpdatingFavorite = true
        return .run { [id = state.id, userId = state.userId] send in
          do {
            if let userId = userId {
              if (value) {
                try await addFavoriteSport(id, for: userId)
              } else {
                try await removeFavoriteSport(id, for: userId)
              }
              await send(.toggleIsFavorite(value))
            }
          } catch(let err) {
            print("error saving favorite \(err)")
          }
        }
      case .selected(let tab):
        state.selectedView = tab
        return .none
      case .user(let userId):
        state.userId = userId
        return .none
      case .news:
        return .none
      default:
        return .none
      }
    }
  }
  @Dependency(\.databaseClient) var dbClient
  @Dependency(\.ausClient) var ausClient
  
  private func addFavoriteSport(_ sportId: Int64, for userId: String) async throws {
    try await ausClient.addFavoriteSport(AddFavoriteSportRequest(sportId: sportId), userId)
    try await dbClient.addFavoriteSport(sportId, userId)
  }
  
  private func removeFavoriteSport(_ sportId: Int64, for userId: String) async throws {
    try await ausClient.deleteFavoriteSport(sportId, userId)
    let _ = try await dbClient.deleteFavoriteSport(sportId, userId)
  }
}

public struct LeagueView: View {
  private let store: StoreOf<League>
  
  @Environment(\.dismiss) var dismiss
  
  public init(store: StoreOf<League>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<League>
  
  public var body: some View {
      SimplePageHeader(
        selected: viewStore.binding(
          get: \.selectedView,
          send: League.Action.selected),
        labels: ["NEWS", "SCORES", "STANDINGS"])
      .padding(.bottom, -8)

      TabView(selection: viewStore.binding(
        get: \.selectedView,
        send: League.Action.selected))
      {
        NewsListView(store: self.store.scope(state: \.news, action: League.Action.news))
          .tag(0)
        
        ScoresContainer(store: self.store.scope(state: \.scores, action: League.Action.scores))
          .tag(1)
          .padding(.top, -16)
        StandingsView(store: self.store.scope(state: \.standings, action: League.Action.standings))
          .tag(2)
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .navigationTitle(viewStore.sport.name)
      .toolbar(content: {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            viewStore.send(.updateFavoriteSport(!viewStore.isFavorite))
          } label: {
            if viewStore.isFavorite {
              Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            } else {
              Image(systemName: viewStore.isUpdatingFavorite ? "star.fill" : "star")
            }
          }
          .symbolEffect(.variableColor, value: viewStore.isUpdatingFavorite)
        }
      })
      .toolbarRole(.editor)
      .onLoad {
        viewStore.send(.task)
      }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
      LeagueView(store: .item)
    }
}

extension Store where State == League.State, Action == League.Action {
  static let item = Store(
    initialState: .init(sport: .mock()),
    reducer: {
      League()
    })
}
