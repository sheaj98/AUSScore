// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import AppNotificationsClient
import ComposableArchitecture
import DatabaseClient
import Models
import SwiftUI
import GameFeature

// MARK: - ScoresFeature

public struct ScoresFeature: Reducer {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public
  public struct Path: Reducer {
    public enum State: Equatable {
      case gameDetails(GameDetails.State)
    }

    public enum Action: Equatable {
      case gameDetails(GameDetails.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: /State.gameDetails, action: /Action.gameDetails) {
        GameDetails()
      }
    }
  }

  public struct State: Equatable {
    public var datesWithGames: IdentifiedArrayOf<ScoresList.State>
    public var selectedIndex: Int
    public var sportId: Int64?
    public var path = StackState<Path.State>()

    public init(datesWithGames: IdentifiedArrayOf<ScoresList.State> = [], selectedIndex: Int = 0, sportId: Int64? = nil) {
      self.datesWithGames = datesWithGames
      self.selectedIndex = selectedIndex
      self.sportId = sportId
    }
  }

  public enum Destination: Equatable {
    case date(ScoresList.State)
  }

  public enum Action: Equatable {
    case selected(Int)
    case scoresList(id: ScoresList.State.ID, action: ScoresList.Action)
    case task
    case dateWithGamesResponse(TaskResult<[ScoresList.State]>)
    case dayDidChange
    case path(StackAction<Path.State, Path.Action>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .selected(let index):
        state.selectedIndex = index
        return .none
      case .task:
        return .run { [sportId = state.sportId] send in
          await withThrowingTaskGroup(of: Void.self, body: { group in
            group.addTask {
              for await _ in appNotificationsClient.didChangeDay() {
                await send(.dayDidChange)
              }
            }
            group.addTask {
              await send(.dateWithGamesResponse(TaskResult {
                try await refreshDatesWithGames(sportId: sportId)
              }))
            }
          })
        }
      case .dayDidChange:
        return .run { [sportId = state.sportId] send in
          await send(.dateWithGamesResponse(TaskResult {
            try await refreshDatesWithGames(sportId: sportId)
          }))
        }
      case .dateWithGamesResponse(.success(let dates)):
        let todayIndex = dates.firstIndex(where: { Calendar.current.isDateInToday($0.selectedDate) }) ?? 0
        state.selectedIndex = todayIndex
        state.datesWithGames = IdentifiedArray(uniqueElements: dates)
        return .none
      case .dateWithGamesResponse(.failure(let error)):
        print("Error fetch dates with games \(error)")
        return .none
      case .scoresList:
        return .none
      default:
        return .none
      }
    }.forEach(\.datesWithGames, action: /Action.scoresList(id:action:)) {
      ScoresList()
    }
    .forEach(\.path, action: /Action.path) {
      Path()
    }
  }

  // MARK: Internal

  @Dependency(\.databaseClient) var dbClient
  @Dependency(\.appNotificationsClient) var appNotificationsClient

  private func refreshDatesWithGames(sportId: Int64?) async throws -> [ScoresList.State] {
    var dates = try await dbClient.datesWithGames(sportId)
    if !dates.contains(where: { Calendar.current.isDateInToday($0) }) {
      dates.append(.now.startOfDay)
      dates = dates.sorted(by: { $0 < $1 })
    }
    return dates.enumerated().map { index, selectedDate -> ScoresList.State in
      ScoresList.State(selectedDate: selectedDate, index: index, sportId: sportId)
    }
  }
}

// MARK: - ScoresContainer

public struct ScoresContainer: View {
  // MARK: Lifecycle

  public init(store: StoreOf<ScoresFeature>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 0) {
      PageHeader(
        selected: viewStore.binding(get: \.selectedIndex, send: ScoresFeature.Action.selected),
        labels: viewStore.datesWithGames.map { gameList in
          if gameList.selectedDate == .now.startOfDay {
            return "TODAY"
          }
          return gameList.selectedDate.formatted(.dateTime.month(.abbreviated).day()).uppercased()
        })

      TabView(selection: viewStore.binding(get: \.selectedIndex, send: ScoresFeature.Action.selected)) {
        ForEachStore(
          self.store.scope(state: \.datesWithGames, action: ScoresFeature.Action.scoresList(id:action:)))
        { store in
          ScoresListView(store: store)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .background(Color.black)
    }
    .background(Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground))
    .onLoad {
      viewStore.send(.task)
    }
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<ScoresFeature>
  @Environment(\.colorScheme) var colorScheme

  // MARK: Private

  private let store: StoreOf<ScoresFeature>
}
