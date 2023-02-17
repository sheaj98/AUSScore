// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import ComposableArchitecture
import DatabaseClient
import Models
import SwiftUI

// MARK: - ScoresList

public struct ScoresList: ReducerProtocol {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable, Identifiable {
    public var id: Date {
      selectedDate
    }

    public var selectedDate: Date
    public var index: Int
    public var scoreSections: IdentifiedArrayOf<ScoresListSection.State>
    public var loadingState: LoadingState

    public init(selectedDate: Date, index: Int, scoreSections: IdentifiedArrayOf<ScoresListSection.State> = [], loadingState: LoadingState = .loading) {
      self.selectedDate = selectedDate
      self.scoreSections = scoreSections
      self.index = index
      self.loadingState = loadingState
    }
  }

  public enum Action: Equatable {
    case task
    case scoreSections(sections: [ScoresListSection.State])
    case gamesSection(id: ScoresListSection.State.ID, action: ScoresListSection.Action)
    case refreshGames
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { [date = state.selectedDate] send in
          for try await games in dbClient.gameStream(date) {
            let gameRows = games.map { ScoresRow.State(from: $0) }
            let gameSections = Dictionary(grouping: gameRows, by: { $0.sport.name })
              .map { sportName, mappedGameRows -> ScoresListSection.State in
                ScoresListSection.State(name: sportName, scoreRows: IdentifiedArray(uniqueElements: mappedGameRows))
              }
              .sorted(by: { $0.name < $1.name })
            await send(.scoreSections(sections: gameSections))
          }
        } catch: { error, _ in
          print("Error Syncing Games \(error)")
        }
      case .scoreSections(let scores):
        if scores.isEmpty {
          state.loadingState = .empty("No games today!")
        } else {
          state.loadingState = .loaded
        }
        state.scoreSections = IdentifiedArray(uniqueElements: scores)
        return .none
      case .gamesSection:
        return .none
      default:
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
    .animation(.default, value: viewStore.loadingState)
    .listStyle(.grouped)
    .refreshable {
      viewStore.send(.refreshGames)
    }
    .task {
      await viewStore.send(.task).finish()
    }
    .tag(viewStore.index)
    .emptyPlaceholder(loadingState: viewStore.loadingState)
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<ScoresList>

  // MARK: Private

  private let store: StoreOf<ScoresList>
}
