//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-03-25.
//

import AppCommon
import ComposableArchitecture
import DatabaseClient
import Foundation
import Models
import SwiftUI

public struct LeaguesList: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public var leagues: IdentifiedArrayOf<SportInfo>
    @PresentationState public var selectedLeague: League.State?

    public init(leagues: IdentifiedArrayOf<SportInfo> = []) {
      self.leagues = leagues
    }
  }

  public enum Action: Equatable {
    case task
    case leaguesResponse(TaskResult<[SportInfo]>)
    case leagueRowTapped(id: League.State.ID)
    case league(PresentationAction<League.Action>)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .task {
          await .leaguesResponse(TaskResult {
            try await dbClient.sports()
          })
        }
      case .leaguesResponse(.success(let sports)):
        state.leagues = IdentifiedArray(uniqueElements: sports)
        return .none
      case .leaguesResponse(.failure(let error)):
        print(error)
        return .none
      case .leagueRowTapped(id: let leagueId):
        guard let league = state.leagues[id: leagueId] else {
          return .none
        }
        state.selectedLeague = League.State(sport: league)
        return .none
      case .league:
        return .none
      }
    }
    .ifLet(\.$selectedLeague, action: /Action.league) {
      League()
    }
  }

  @Dependency(\.databaseClient) var dbClient
}

public struct LeaguesListView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<LeaguesList>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<LeaguesList>

  public var body: some View {
    VStack(spacing: 0) {
      Text("Leagues")
        .font(.title2)
      List {
        ForEach(viewStore.leagues) { league in
          NavigationLinkStore(
            self.store.scope(state: \.$selectedLeague, action: LeaguesList.Action.league),
            id: league.id)
          {
            viewStore.send(.leagueRowTapped(id: league.id))
          } destination: { store in
            LeagueView(store: store)
              .navigationTitle(league.name)
          } label: {
            LeaguesListRowView(league: league)
          }
        }
      }
      .listStyle(.grouped)
    }
    .onLoad {
      viewStore.send(.task)
    }
  }

  // MARK: Private

  private let store: StoreOf<LeaguesList>
}

// MARK: - ScoresListView_Preview

struct LeaguesList_Preview: PreviewProvider {
  static var previews: some View {
    LeaguesListView(store: .items)
  }
}

extension Store where State == LeaguesList.State, Action == LeaguesList.Action {
  static let items = Store(
    initialState: .init(leagues: [.mock()]),
    reducer: LeaguesList())
}
