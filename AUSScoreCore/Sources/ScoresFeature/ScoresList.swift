// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import ComposableArchitecture
import DatabaseClient
import Models
import SwiftUI

// MARK: - ScoresList

public struct ScoresList: Reducer {
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
    public var sportId: Int64?

    public init(selectedDate: Date, index: Int, scoreSections: IdentifiedArrayOf<ScoresListSection.State> = [], loadingState: LoadingState = .loading, sportId: Int64?) {
      self.selectedDate = selectedDate
      self.scoreSections = scoreSections
      self.index = index
      self.loadingState = loadingState
      self.sportId = sportId
    }
  }

  public enum Action: Equatable {
    case task
    case scoreSections(sections: [ScoresListSection.State])
    case gamesSection(id: ScoresListSection.State.ID, action: ScoresListSection.Action)
    case refreshGames
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { [date = state.selectedDate, sportId = state.sportId] send in
          for try await games in dbClient.gamesStream(date, sportId) {
            let gameRows = games.map { ScoresRow.State(from: $0) }
            if sportId != nil {
              if gameRows.isEmpty {
                return await send(.scoreSections(sections: []))
              }
              let scoresSections = ScoresListSection.State(name: date.formatted(Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day(.defaultDigits)), scoreRows: IdentifiedArray(uniqueElements: gameRows))
              await send(.scoreSections(sections: [scoresSections]))
            } else {
              let gameSections = Dictionary(grouping: gameRows, by: { $0.sport.name })
                .map { sportName, mappedGameRows -> ScoresListSection.State in
                  ScoresListSection.State(name: sportName, scoreRows: IdentifiedArray(uniqueElements: mappedGameRows))
                }
                .sorted(by: { $0.name < $1.name })
              await send(.scoreSections(sections: gameSections))
            }
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
    }
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
      await viewStore.send(.refreshGames).finish()
    }
    .task {
      await viewStore.send(.task).finish()
    }
//  This is causing crash for some reason
//    .emptyPlaceholder(loadingState: viewStore.loadingState)
    .overlay(content: {
      Group {
        switch viewStore.loadingState {
        case .loading:
          ProgressView()
        case .empty(let text):
          Text(text)
            .foregroundColor(.gray)
            .font(.body)
            .fontWeight(.semibold)
        case .loaded:
          EmptyView()
        }
      }
    })
    .tag(viewStore.index)
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<ScoresList>

  // MARK: Private

  private let store: StoreOf<ScoresList>
}
