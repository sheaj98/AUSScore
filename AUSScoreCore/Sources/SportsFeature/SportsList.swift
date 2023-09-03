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

public struct LeaguesList: Reducer {
  public init() {}

  public struct Path: Reducer {
    public enum State: Equatable {
      case league(League.State)
    }

    public enum Action: Equatable {
      case league(League.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.league, action: /Action.league) {
        League()
      }
    }
  }

  public struct State: Equatable {
    public var leagues: IdentifiedArrayOf<SportInfo>
    public var path = StackState<Path.State>()

    public init(leagues: IdentifiedArrayOf<SportInfo> = []) {
      self.leagues = leagues
    }
  }

  public enum Action: Equatable {
    case task
    case leaguesResponse(TaskResult<[SportInfo]>)
    case leagueRowTapped(id: League.State.ID)
    case path(StackAction<Path.State, Path.Action>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { send in
          await send(.leaguesResponse(TaskResult {
            try await dbClient.sports()
          }))
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
        state.path.append(.league(.init(sport: league)))
        return .none
      default:
        return .none
      }
    }
    .forEach(\.path, action: /Action.path) {
      Path()
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
    NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) }), root: {
      VStack(spacing: 0) {
        Text("Leagues")
          .font(.headline)
        List {
          ForEach(viewStore.leagues) { league in
            NavigationLink(state: LeaguesList.Path.State.league(.init(sport: league)), label: {
              LeaguesListRowView(league: league)
            })
            .listRowBackground(Color(.secondarySystemBackground))
          }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
      }
      .background(Color(.secondarySystemBackground))
    }, destination: { state in
      switch state {
      case .league:
        CaseLet(
          /LeaguesList.Path.State.league,
          action: LeaguesList.Path.Action.league,
          then: LeagueView.init(store:)
        )
      }
    })

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
    initialState: .init(leagues: IdentifiedArray(uniqueElements: [SportInfo.mock()])))
  {
    LeaguesList()
  }
}
