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

  public struct State: Equatable {
    public var leagues: IdentifiedArrayOf<SportInfo>

    public init(leagues: IdentifiedArrayOf<SportInfo> = []) {
      self.leagues = leagues
    }
  }

  public enum Action: Equatable {
    public enum DelegateAction: Equatable {
      case leagueRowTapped(SportInfo)
    }

    case task
    case leaguesResponse(TaskResult<[SportInfo]>)
    case delegate(DelegateAction)
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
      default:
        return .none
      }
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
        .font(.headline)
      List {
        ForEach(viewStore.leagues) { league in
          Button(action: {
            viewStore.send(.delegate(.leagueRowTapped(league)))
          }) {
            HStack {
              LeaguesListRowView(league: league)
              Spacer()
              Image(systemName: "chevron.right")
            }
            .padding(6)
              
          }
          .listRowBackground(Color(.secondarySystemBackground))
        }
      }
      .listStyle(.inset)
      .scrollContentBackground(.hidden)
    }
    .background(Color(.secondarySystemBackground))

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
