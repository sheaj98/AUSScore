// Copyright © 2023 Shea Sullivan. All rights reserved.

import ComposableArchitecture
import DatabaseClient
import Models
import SwiftUI

// MARK: - ScoresList

public struct ScoresList: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable, Identifiable {
    public var id: Date {
      selectedDate
    }

    public var selectedDate: Date
    public var index: Int
    public var scoreSections: IdentifiedArrayOf<ScoresListSection.State>

    public init(selectedDate: Date, index: Int, scoreSections: IdentifiedArrayOf<ScoresListSection.State> = []) {
      self.selectedDate = selectedDate
      self.scoreSections = scoreSections
      self.index = index
    }
  }

  public enum Action: Equatable {
    case task
    case gamesResponse(TaskResult<[ScoresListSection.State]>)
    case gamesSection(id: ScoresListSection.State.ID, action: ScoresListSection.Action)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .task(operation: { [selectedDate = state.selectedDate] in
          await .gamesResponse(TaskResult {
            let games = try await dbClient.gamesForDate(selectedDate)
            let gameRows = games.map { ScoresRow.State(from: $0) }
            return Dictionary(grouping: gameRows, by: { $0.sport.name })
              .map { sportName, mappedGameRows -> ScoresListSection.State in
                ScoresListSection.State(name: sportName, scoreRows: IdentifiedArray(uniqueElements: mappedGameRows))
              }
              .sorted(by: { $0.name < $1.name })
          })
        })
      case .gamesResponse(.success(let scores)):
        state.scoreSections = IdentifiedArray(uniqueElements: scores)
        return .none
      case .gamesResponse(.failure(let error)):
        print("Could not fetch games \(error.localizedDescription)")
        return .none
      case .gamesSection:
        return .none
      }
    }._printChanges()
  }

  // MARK: Internal

  @Dependency(\.databaseClient) var dbClient
}

// MARK: - ScoresListView

public struct ScoresListView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<ScoresList>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Public

  public var body: some View {
    List {
      ForEachStore(self.store.scope(state: \.scoreSections, action: ScoresList.Action.gamesSection(id:action:))) {
        ScoresListSectionView(store: $0)
      }
    }
    .listStyle(.grouped)
    .refreshable {
      await viewStore.send(.task).finish()
    }
    .overlay(Group {
      if viewStore.scoreSections.isEmpty {
        Text("No Games Today!")
      }
    })
    .task {
      await viewStore.send(.task).finish()
    }.tag(viewStore.index)
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<ScoresList>

  // MARK: Private

  private let store: StoreOf<ScoresList>
}
