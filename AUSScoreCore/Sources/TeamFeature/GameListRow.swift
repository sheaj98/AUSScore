//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-10-15.
//

import ComposableArchitecture
import Models
import NukeUI
import SwiftUI

struct GameRowReducer: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    // MARK: Lifecycle

    public init(
      id: String,
      startTime: Date,
      status: GameStatus,
      currentTime: String?,
      sport: Sport,
      isExhibition: Bool = false,
      gameResults: [GameResultInfo],
      teamId: Int64
    ) {
      self.id = id
      self.startTime = startTime
      self.status = status
      self.currentTime = currentTime
      self.sport = sport
      self.isExhibition = isExhibition
      selectedTeamResult = gameResults.first(where: { $0.team.id == teamId }) ?? .unknown(isHome: true, gameId: id)
      opponentTeamResult = gameResults.first(where: { $0.team.id != teamId }) ?? .unknown(isHome: false, gameId: id)
    }

    public init(from gameInfo: GameInfo, teamId: Int64) {
      id = gameInfo.id
      startTime = gameInfo.startTime
      status = gameInfo.status
      currentTime = gameInfo.currentTime
      sport = gameInfo.sport
      isExhibition = gameInfo.isExhibition
      selectedTeamResult = gameInfo.gameResults.first(where: { $0.team.id == teamId }) ?? .unknown(isHome: true, gameId: gameInfo.id)
      opponentTeamResult = gameInfo.gameResults.first(where: { $0.team.id != teamId }) ?? .unknown(isHome: false, gameId: gameInfo.id)
    }

    // MARK: Public

    public let id: String
    public let startTime: Date
    public let status: GameStatus
    public let currentTime: String?
    public let sport: Sport
    public let isExhibition: Bool
    public let selectedTeamResult: GameResultInfo
    public let opponentTeamResult: GameResultInfo

    public var timeString: String {
      switch status {
      case .cancelled:
        return "Cancelled"
      case .complete:
        return "Final"
      case .inProgress:
        return currentTime?.replacingOccurrences(of: "half", with: "") ?? "Upcoming"
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

struct GameRowView: View {
  let gameInfo: GameInfo
  let teamId: Int64
  let selectedTeamResult: GameResultInfo
  let opponentTeamResult: GameResultInfo

  public init(gameInfo: GameInfo, teamId: Int64) {
    self.gameInfo = gameInfo
    self.teamId = teamId
    selectedTeamResult = gameInfo.gameResults.first(where: { $0.team.id == teamId }) ?? .unknown(isHome: true, gameId: gameInfo.id)
    opponentTeamResult = gameInfo.gameResults.first(where: { $0.team.id != teamId }) ?? .unknown(isHome: false, gameId: gameInfo.id)
  }

  var body: some View {
    HStack {
      VStack {
        Text(gameInfo.startTime.formatted(Date.FormatStyle().day(.twoDigits)))
          .font(.system(size: 18)).fontWeight(.semibold)
        Text(gameInfo.startTime.formatted(Date.FormatStyle().weekday())).textCase(.uppercase).font(.system(size: 12))
      }
      .frame(width: 28, height: 28)
      .padding()
      .background(Circle().fill(Color(uiColor: Calendar.current.isDateInToday(gameInfo.startTime) ? .systemBlue : .tertiarySystemBackground)))
      Text(selectedTeamResult.isHome ? "vs." : "at")
      HStack {
        VStack(alignment: .leading) {
          HStack {
            Group {
              if let url = opponentTeamResult.team.school.logo {
                LazyImage(url: url, resizingMode: .aspectFit)
              } else {
                Image(systemName: "sportscourt.circle")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .foregroundColor(.primary)
              }
            }
            .frame(width: 26, height: 26)
            Text(opponentTeamResult.team.school.displayName)
              .fontWeight(.semibold)
          }
          if gameInfo.isExhibition {
            Text("Exhibition")
              .font(.caption).foregroundColor(Color(uiColor: .lightGray))
          }
          if gameInfo.isPlayoff {
            Text(gameInfo.description ?? "Playoff")
              .font(.caption).foregroundColor(Color(uiColor: .lightGray))
          }
        }
      }
      Spacer()
      switch gameInfo.status {
      case .complete:
        HStack {
          switch selectedTeamResult.outcome {
          case .win:
            Text("W")
              .foregroundStyle(.green)
          case .loss:
            Text("L")
              .foregroundStyle(.red)
          case .draw:
            Text("D")
          case .tbd:
            Text("Live")
          }
          Text("\(selectedTeamResult.score ?? 0)-\(opponentTeamResult.score ?? 0)")
        }

      case .cancelled:
        Text("Cancelled")
      default:
        Text(gameInfo.startTime.formatted(date: .omitted, time: .shortened))
      }
    }
    .listRowBackground(Color(uiColor: .secondarySystemBackground))
    .background(Color(uiColor: .secondarySystemBackground))
  }
}

#if DEBUG
struct GameRowView_Preview: PreviewProvider {
  static var previews: some View {
    GameRowView(gameInfo: .mock(id: "123"), teamId: 12)
  }
}
#endif
