// Copyright © 2023 Shea Sullivan. All rights reserved.

import ComposableArchitecture
import Models
import NukeUI
import SwiftUI
import GameFeature

// MARK: - ScoresRow

public struct ScoresRow: Reducer {
  public struct State: Equatable, Identifiable {
    // MARK: Lifecycle

    public init(
      id: String,
      startTime: Date,
      status: GameStatus,
      currentTime: String?,
      sport: Sport,
      isExhibition: Bool = false,
      is4PointGame: Bool = false,
      gameResults: [GameResultInfo])
    {
      self.id = id
      self.startTime = startTime
      self.status = status
      self.currentTime = currentTime
      self.sport = sport
      self.isExhibition = isExhibition
      self.is4PointGame = is4PointGame
      homeTeamResult = gameResults.first(where: { $0.isHome })!
      awayTeamResult = gameResults.first(where: { !$0.isHome })!
    }

    public init(from gameInfo: GameInfo) {
      id = gameInfo.id
      startTime = gameInfo.startTime
      status = gameInfo.status
      currentTime = gameInfo.currentTime
      sport = gameInfo.sport
      isExhibition = gameInfo.isExhibition
      is4PointGame = gameInfo.is4PointGame
      homeTeamResult = gameInfo.gameResults.first(where: { $0.isHome }) ?? gameInfo.gameResults.first!
      awayTeamResult = gameInfo.gameResults.first(where: { !$0.isHome }) ?? gameInfo.gameResults.first!
    }

    // MARK: Public

    public let id: String
    public let startTime: Date
    public let status: GameStatus
    public let currentTime: String?
    public let sport: Sport
    public let isExhibition: Bool
    public let is4PointGame: Bool
    public let homeTeamResult: GameResultInfo
    public let awayTeamResult: GameResultInfo

    public var timeString: String {
      switch status {
      case .cancelled:
        return "Cancelled"
      case .complete:
        return "Final"
      case .inProgress:
        return currentTime ?? "Upcoming"
      case .upcoming:
        return startTime.formatted(date: .omitted, time: .shortened)
      }
    }
  }

  public enum Action: Equatable {
    case tapped(GameInfo)
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, _ in
      .none
    }
  }
}

// MARK: - TeamRowView

struct TeamRowView: View {
  let teamResult: GameResultInfo

  var body: some View {
    Label {
      Text(teamResult.team.school.displayName)
    } icon: {
      if let url = teamResult.team.school.logo {
        LazyImage(url: url, resizingMode: .aspectFit)
      } else {
        Image(systemName: "sportscourt.circle")
        .font(.system(size: 24))
        .foregroundColor(.primary)
      }
    }
    .fontWeight(.semibold)
    .gridColumnAlignment(.leading)
    Spacer()

    if let score = teamResult.score {
      Text(score.formatted())
        .fontWeight(.semibold)
    }
  }
}

// MARK: - ScoresRowView

struct ScoresRowView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<ScoresRow>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<ScoresRow>

  var body: some View {
      Grid(verticalSpacing: 8) {
        GridRow {
          TeamRowView(teamResult: viewStore.homeTeamResult)
          Text(viewStore.timeString)
            .gridColumnAlignment(.trailing)
            .frame(width: 100, alignment: .trailing)
        }

        GridRow {
          TeamRowView(teamResult: viewStore.awayTeamResult)
        }
        if (viewStore.isExhibition) {
          GridRow {
            Text("Exhibition").font(.caption).foregroundColor(Color(uiColor: .lightGray))
              .gridColumnAlignment(.leading)
              .padding(.top, 4)
          }
        }
      }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
      .onTapGesture {
        viewStore.send(.tapped(GameInfo.init(id: viewStore.id, startTime: viewStore.startTime, status: viewStore.status, currentTime: viewStore.currentTime, sport: viewStore.sport, gameResults: [viewStore.homeTeamResult, viewStore.awayTeamResult])))
      }
  }

  // MARK: Private

  private let store: StoreOf<ScoresRow>
}

// MARK: - ScoresRowView_Previews

struct ScoresRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      Section {
        Text("GameObject")
      } header: {
        Text("Men's Basketball")
          .font(.title2)
          .textCase(.none)
          .foregroundColor(.primary)
      }
    }.listStyle(.grouped)
  }
}
