//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-10-20.
//

import ComposableArchitecture
import DatabaseClient
import Models
import NukeUI
import SwiftUI

public struct StandingsReducer: Reducer {
  public init() {}

  public struct State: Equatable, Identifiable {
    public var id: Int64 { sportId }

    public var sportId: Int64
    public var teams: IdentifiedArrayOf<TeamInfo>

    public init(sportId: Int64, teams: IdentifiedArrayOf<TeamInfo> = []) {
      self.sportId = sportId
      self.teams = teams
    }
  }

  public enum Action: Equatable {
    case task
    case teamsResult(TaskResult<[TeamInfo]>)
    case teamTapped(TeamInfo)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { [sportId = state.sportId] send in
          await send(.teamsResult(TaskResult {
            try await dbClient.teamsForSport(sportId)
          }))
        }
      case .teamsResult(.success(let teams)):
        state.teams = IdentifiedArray(uniqueElements: teams.sorted(by: { $0.points ?? 0 > $1.points ?? 0
        }))
        return .none
      case .teamsResult(.failure(let err)):
        print("Error fetching teams \(err)")
        return .none
      default:
        return .none
      }
    }
  }

  @Dependency(\.databaseClient) var dbClient
}

public struct StandingsView: View {
  @ObservedObject var viewStore: ViewStoreOf<StandingsReducer>
  private let store: StoreOf<StandingsReducer>

  public init(store: StoreOf<StandingsReducer>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  let columns = [
    GridItem(.fixed(18)),
    GridItem(.flexible(), alignment: .leading),
    GridItem(.fixed(72), alignment: .trailing),
    GridItem(.fixed(64), alignment: .trailing),
  ]

  public var body: some View {
    VStack {
//      Grid {
//        GridRow {
//          Group {
//            Text("")
//            Text("Team")
//            Text("W-L-D")
//            Text("PTS")
//          }
//          .font(.headline)
//        }
//
//        ForEach(Array(viewStore.teams.enumerated()), id: \.offset) { index, team in
//          GridRow {
//            Text(String(describing: index + 1))
//            Label(
//              title: { Text(team.school.displayName) },
//              icon: {
//                Group {
//                  if let url = team.school.logo {
//                    LazyImage(url: url, resizingMode: .aspectFit)
//                  } else {
//                    Image(systemName: "sportscourt.circle")
//                      .resizable()
//                      .aspectRatio(contentMode: .fit)
//                      .foregroundColor(.primary)
//                  }
//                }.frame(width: 26, height: 26)
//              }
//            )
//            Text(String(describing: team.record ?? TeamInfo.GameRecord(wins: 0, losses: 0, draws: 0)))
//            Text(String(describing: team.points ?? 0))
//            Divider()
//          }
//        }
//      }
//      .padding()
      LazyVGrid(columns: columns, content: {
        Group {
          Text("")
          Text("Team")
          Text("W-L-D")
          Text("PTS")
        }
        .font(.headline)

        ForEach(Array(viewStore.teams.enumerated()), id: \.offset) { index, team in
          Group {
            Text(String(describing: index + 1))
            Label(
              title: { Text(team.school.displayName) },
              icon: {
                Group {
                  if let url = team.school.logo {
                    LazyImage(url: url, resizingMode: .aspectFit)
                  } else {
                    Image(systemName: "sportscourt.circle")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .foregroundColor(.primary)
                  }
                }.frame(width: 26, height: 26)
              }
            )
            Text(String(describing: team.record ?? TeamInfo.GameRecord(wins: 0, losses: 0, draws: 0)))
            Text(String(describing: team.points ?? 0))
          }
          .padding(.bottom)
          .onTapGesture {
            viewStore.send(.teamTapped(team))
          }
        }
      })
      .padding()
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .onLoad {
      viewStore.send(.task)
    }
  }
}

struct StandingsView_Preview: PreviewProvider {
  static var previews: some View {
    StandingsView(store: .items)
  }
}

extension Store where State == StandingsReducer.State, Action == StandingsReducer.Action {
  static let items = Store(
    initialState: .init(sportId: Int64(1), teams: IdentifiedArray(uniqueElements: [TeamInfo.mock(id: 1, school: .unbMock(), sport: .mock()), TeamInfo.mock(id: 2, school: .stfxMock(), sport: .mock())])))
  {
    StandingsReducer()
  }
}
