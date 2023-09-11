//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-09-04.
//

import Models
import ComposableArchitecture
import NukeUI
import SwiftUI

public struct GameDetails: Reducer {
  
  public init() {}
  
  public struct State: Equatable, Identifiable {
    // MARK: Lifecycle
    
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
    
    public init(id: String, startTime: Date, status: GameStatus, currentTime: String?, sport: Sport, isExhibition: Bool, is4PointGame: Bool, homeTeamResult: GameResultInfo, awayTeamResult: GameResultInfo) {
      self.id = id
      self.startTime = startTime
      self.status = status
      self.currentTime = currentTime
      self.sport = sport
      self.isExhibition = isExhibition
      self.is4PointGame = is4PointGame
      self.homeTeamResult = homeTeamResult
      self.awayTeamResult = awayTeamResult
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
      default:
        return startTime.formatted(date: .abbreviated, time: .shortened)
      }
    }
  }

  public enum Action: Equatable {
    case tapped
  }

  public var body: some Reducer<State, Action> {
    Reduce { _, _ in
      .none
    }
  }
}

public struct GameDetailsView: View {
  public init(store: StoreOf<GameDetails>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<GameDetails>
  private let store: StoreOf<GameDetails>
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(viewStore.timeString).font(.subheadline)
      Grid(verticalSpacing: 12) {
        GridRow {
          TeamRowView(teamResult: viewStore.homeTeamResult)
        }
        GridRow {
          TeamRowView(teamResult: viewStore.awayTeamResult)
        }
      }
      Divider()
      Text("Game Details").font(.title2)
      KeyValueView(key: "Location", value: viewStore.homeTeamResult.team.school.location)
      Spacer()
    }.padding()
      .navigationTitle("\(self.viewStore.awayTeamResult.team.school.displayName) @ \(self.viewStore.homeTeamResult.team.school.displayName)")
  }
}

public struct KeyValueView: View {
  let key: String
  let value: String
  
  public var body: some View {
    VStack(alignment: .leading) {
      Text(key).font(.system(size: 14)).foregroundStyle(Color(uiColor: .lightGray))
      Text(value)
    }
  }
}

public struct TeamRowView: View {
  let teamResult: GameResultInfo

  public var body: some View {
    HStack {
      HStack {
        if let url = teamResult.team.school.logo {
          LazyImage(url: url, resizingMode: .aspectFit)
            .frame(width: 50, height: 50)
        } else {
          Image(systemName: "sportscourt.circle")
            .font(.system(size: 45))
            .foregroundColor(.primary)
        }
        VStack(alignment: .leading) {
          Text(teamResult.team.school.displayName).font(.system(size: 24)).fontWeight(.regular)
          Text("0-0, 1st AUS (WIP)")
        }
      }

      Spacer()

      if let score = teamResult.score {
        Text(score.formatted())
          .fontWeight(.semibold)
          .font(.system(size: 36))
      }
    }
  }
}
#if DEBUG
struct ScoresRowView_Previews: PreviewProvider {
  static var previews: some View {
    GameDetailsView(store: .items)
  }
}
extension Store where State == GameDetails.State, Action == GameDetails.Action {
  static let items = Store(
    initialState: .init(from: .mock(id: "gameId")))
  {
    GameDetails()
  }
}
#endif
