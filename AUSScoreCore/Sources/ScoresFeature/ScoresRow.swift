// Copyright © 2023 Shea Sullivan. All rights reserved.

import ComposableArchitecture
import GameFeature
import Models
import NukeUI
import SwiftUI

// MARK: - ScoresRow

public struct ScoresRow: Reducer {
  public struct State: Equatable, Identifiable {
    // MARK: Lifecycle

    public init(
      id: String,
      startTime: Date,
      status: GameStatus,
      gameTime: String?,
      sport: Sport,
      isExhibition: Bool = false,
      containsFavorite: Bool = false,
      isPlayoff: Bool = false,
      description: String? = nil,
      gameResults: [GameResultInfo])
    {
      self.id = id
      self.startTime = startTime
      self.status = status
      self.gameTime = gameTime
      self.sport = sport
      self.containsFavorite = containsFavorite
      self.isExhibition = isExhibition
      self.isPlayoff = isPlayoff
      self.description = description
      homeTeamResult = gameResults.first(where: { $0.isHome })!
      awayTeamResult = gameResults.first(where: { !$0.isHome })!
    }

    public init(from gameInfo: GameInfo, containsFavorite: Bool = false) {
      id = gameInfo.id
      startTime = gameInfo.startTime
      status = gameInfo.status
      gameTime = gameInfo.gameTime
      sport = gameInfo.sport
      self.containsFavorite = containsFavorite
      isExhibition = gameInfo.isExhibition
      isPlayoff = gameInfo.isPlayoff
      description = gameInfo.description
      homeTeamResult = gameInfo.gameResults.first(where: { $0.isHome }) ?? .unknown(isHome: true, gameId: gameInfo.id)
      awayTeamResult = gameInfo.gameResults.first(where: { !$0.isHome }) ?? .unknown(isHome: false, gameId: gameInfo.id)
    }

    // MARK: Public

    public let id: String
    public let startTime: Date
    public let status: GameStatus
    public let gameTime: String?
    public let sport: Sport
    public let isExhibition: Bool
    public var containsFavorite: Bool
    public let isPlayoff: Bool
    public let description: String?
    public let homeTeamResult: GameResultInfo
    public let awayTeamResult: GameResultInfo

    public var timeString: String {
      switch status {
      case .cancelled:
        return "Cancelled"
      case .complete:
        return "Final"
      case .inProgress:
        return gameTime?.replacingOccurrences(of: "half", with: "") ?? "Upcoming"
      case .upcoming:
        return startTime.formatted(date: .omitted, time: .shortened)
      }
    }
  }

  public enum Action: Equatable {
    case tapped(GameInfo)
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .tapped(let gameInfo):
        print(gameInfo)
        return .none
      }
    }
  }
}

// MARK: - TeamRowView

struct TeamRowView: View {
  let teamResult: GameResultInfo
  let gameStatus: GameStatus

  var body: some View {
    Label {
      Text(teamResult.team.school.displayName)
    } icon: {
      Group {
        if let url = teamResult.team.school.logo {
          LazyImage(url: url, resizingMode: .aspectFit)
        } else {
          Image(systemName: "sportscourt.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.primary)
        }
      }.frame(width: 26, height: 26)
    }
    .fontWeight(.semibold)
    .gridColumnAlignment(.leading)
    Spacer()

    if let score = teamResult.score, gameStatus != .upcoming {
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
    Button {
      viewStore.send(.tapped(GameInfo(id: viewStore.id, startTime: viewStore.startTime, status: viewStore.status, gameTime: viewStore.gameTime, sport: viewStore.sport, gameResults: [viewStore.homeTeamResult, viewStore.awayTeamResult])))
    } label: {
      Grid(verticalSpacing: 12) {
        GridRow {
          TeamRowView(teamResult: viewStore.homeTeamResult, gameStatus: viewStore.status)
          Text(viewStore.timeString)
            .gridColumnAlignment(.trailing)
            .frame(width: 100, alignment: .trailing)
        }

        GridRow {
          TeamRowView(teamResult: viewStore.awayTeamResult, gameStatus: viewStore.status)
        }
        if viewStore.containsFavorite {
          GridRow {
            Text(viewStore.sport.name).font(.caption).foregroundColor(Color(uiColor: .lightGray))
              .gridColumnAlignment(.leading)
              .padding(.top, 4)
          }
        }
        if viewStore.isExhibition {
          GridRow {
            Text("Exhibition").font(.caption).foregroundColor(Color(uiColor: .lightGray))
              .gridColumnAlignment(.leading)
              .padding(.top, 4)
          }
        }
        if viewStore.isPlayoff {
          GridRow {
            Text(viewStore.description ?? "Playoff").font(.caption).foregroundColor(Color(uiColor: .lightGray))
              .gridColumnAlignment(.leading)
              .padding(.top, 4)
          }
        }
      }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
    .foregroundStyle(.white)
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
