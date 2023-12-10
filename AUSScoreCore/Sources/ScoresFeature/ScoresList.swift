// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import AsyncAlgorithms
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
    public var id: Int {
      index
    }

    public var selectedDate: Date
    public var index: Int
    public var scoreSections: IdentifiedArrayOf<ScoresListSection.State>
    public var loadingState: LoadingState
    public var sportId: Int64?
    public var favoriteTeams: IdentifiedArrayOf<TeamInfo>
    public var toggleScrollToTop: Bool = false

    public init(selectedDate: Date, index: Int, scoreSections: IdentifiedArrayOf<ScoresListSection.State> = [], loadingState: LoadingState = .loading, sportId: Int64?, favoriteTeams: IdentifiedArrayOf<TeamInfo> = []) {
      self.selectedDate = selectedDate
      self.scoreSections = scoreSections
      self.index = index
      self.loadingState = loadingState
      self.favoriteTeams = favoriteTeams
      self.sportId = sportId
    }
  }

  public enum Action: Equatable {
    case task
    case scoreSections(sections: [ScoresListSection.State])
    case gamesSection(id: ScoresListSection.State.ID, action: ScoresListSection.Action)
    case refreshGames
    case scrollToTop
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { [date = state.selectedDate, sportId = state.sportId] send in
          for try await (games, user) in combineLatest(dbClient.gamesStream(date, sportId), dbClient.userStream()) {
            var gameRows = games.map { ScoresRow.State(from: $0) }
            let p = gameRows.partition(by: { row in
              var containsFavTeam = false
              user.favoriteTeams.forEach { team in
                if team.id == row.homeTeamResult.team.id || row.awayTeamResult.team.id == team.id {
                  containsFavTeam = true
                }
              }
              return containsFavTeam
            })
            if sportId != nil {
              if gameRows.isEmpty {
                return await send(.scoreSections(sections: []))
              }
              let scoresSections = ScoresListSection.State(name: date.formatted(Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day(.defaultDigits)), scoreRows: IdentifiedArray(uniqueElements: gameRows))
              await send(.scoreSections(sections: [scoresSections]))
            } else {
              var gameSections = Dictionary(grouping: gameRows[..<p], by: { $0.sport.name })
                .map { sportName, mappedGameRows -> ScoresListSection.State in
                  ScoresListSection.State(name: sportName, scoreRows: IdentifiedArray(uniqueElements: mappedGameRows))
                }
                .sorted(by: { $0.name < $1.name })
              if !gameRows[p...].isEmpty {
                gameSections.insert(ScoresListSection.State(name: "Favorites", scoreRows: IdentifiedArray(uniqueElements: gameRows[p...].map { gameRow in
                  var newRow = gameRow
                  newRow.containsFavorite = true
                  return newRow
                })), at: 0)
              }
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
      case .scrollToTop:
        state.toggleScrollToTop.toggle()
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
    ScrollViewReader { proxy in
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
      .onChange(of: viewStore.toggleScrollToTop) { oldValue, newValue in
        withAnimation {
          if let fistItem = viewStore.scoreSections.first {
            proxy.scrollTo(fistItem.id, anchor: .bottom)
          }
        }
      }
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
