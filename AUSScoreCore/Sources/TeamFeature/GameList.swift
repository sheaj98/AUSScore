//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-10-08.
//

import AppCommon
import ComposableArchitecture
import DatabaseClient
import Models
import NukeUI
import SwiftUI

public struct GameListReducer: Reducer {
  public init() {}
  
  public struct State: Equatable, Identifiable {
    public let teamId: Int64
    public var gameRows: [Date: IdentifiedArrayOf<GameInfo>]
    public var loadingState: LoadingState
    
    public var id: Int64 {
      teamId
    }
    
    public init(teamId: Int64, gameRows: [Date: IdentifiedArrayOf<GameInfo>] = [Date: IdentifiedArrayOf<GameInfo>](), loadingState: LoadingState = .loading) {
      self.teamId = teamId
      self.gameRows = gameRows
      self.loadingState = loadingState
    }
  }
  
  public enum Action: Equatable {
    case task
    case tapped(GameInfo)
    case gameRows(TaskResult<[Date: IdentifiedArrayOf<GameInfo>]>)
    case refreshGames
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { [teamId = state.teamId] send in
          await send(.gameRows(TaskResult {
            try await refreshGames(teamId: teamId)
          }))
        }
      case .gameRows(.success(let gameSections)):
        state.gameRows = gameSections
        state.loadingState = .loaded
        return .none
      case .refreshGames:
        return .none
      default:
        return .none
      }
    }._printChanges()
  }
  
  @Dependency(\.databaseClient) var dbClient
  
  private func refreshGames(teamId: Int64) async throws -> [Date: IdentifiedArrayOf<GameInfo>] {
    let games = try await dbClient.gamesForTeam(teamId)

    let gameSections = Dictionary(grouping: games, by: { game in
      let components = Calendar.current.dateComponents([.month, .year], from: game.startTime)
      return Calendar.current.date(from: components)!
    }).mapValues {
      IdentifiedArray(uniqueElements: $0)
    }
    return gameSections
  }
}

struct GameListView: View {
  @ObservedObject var viewStore: ViewStoreOf<GameListReducer>
  private let store: StoreOf<GameListReducer>
  
  public init(store: StoreOf<GameListReducer>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }
  
  var body: some View {
    List {
      ForEach(viewStore.gameRows.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
        Section(header: Text(key.formatted(Date.FormatStyle().month(.abbreviated).year())).font(.title2).foregroundStyle(.white).textCase(.none)) {
          ForEach(value) { game in
            Button {
              self.viewStore.send(.tapped(game))
            } label: {
              GameRowView(gameInfo: game, teamId: viewStore.teamId)
            }
            .foregroundStyle(.white)
            .listRowBackground(Color(.secondarySystemBackground))
          }
        }
      }
    }
      
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .background(Color(uiColor: .secondarySystemBackground))
      .refreshable(action: {
        viewStore.send(.refreshGames)
      })
      .onLoad {
        viewStore.send(.task)
      }
  }
}
