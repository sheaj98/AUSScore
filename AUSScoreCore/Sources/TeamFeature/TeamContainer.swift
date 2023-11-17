//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-10-08.
//

import ComposableArchitecture
import DatabaseClient
import AUSClient
import UserIdentifier
import Models
import NukeUI
import SwiftUI

public struct TeamContainerReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public var team: TeamInfo
    public var gameList: GameListReducer.State
    public var isFavorite: Bool
    public var isUpdating: Bool

    public init(team: TeamInfo, isFavorite: Bool = false, isUpdating: Bool = false) {
      self.team = team
      self.gameList = GameListReducer.State(teamId: team.id)
      self.isFavorite = isFavorite
      self.isUpdating = isUpdating
    }
  }

  public enum Action: Equatable {
    public enum DelegateAction: Equatable {
      case showGameDetails(GameInfo)
    }
    case task
    case setIsFavorite(Bool)
    case updateFavoriteTeamResult(TaskResult<Bool>)
    case updateFavoriteTeam(Bool)
    case delegate(DelegateAction)
    case gameList(GameListReducer.Action)
  }

  public var body: some Reducer<State, Action> {
    
    Scope(
      state: \.gameList,
      action: /Action.gameList)
    {
      GameListReducer()
    }
    
    Reduce { state, action in
      switch action {
      case .task:
        return .run { [id = state.team.id] send in
          for try await user in dbClient.userStream() {
            if user.favoriteTeams.contains(where: { $0.id == id }) {
              await send(.setIsFavorite(true))
            }
          }
        }
      case .setIsFavorite(let value):
        state.isFavorite = value
        return .none
      case .updateFavoriteTeam(let value):
        state.isUpdating = true
        return .run { [id = state.team.id] send in
          do {
            let userId = try await userIdStore.id()
            if value {
              // Adding a favorite
              try await addFavoriteTeam(id, for: userId)
            } else {
              // Removing
              try await removeFavoriteTeam(id, for: userId)
            }
            await send(.updateFavoriteTeamResult(.success(value)))
          } catch(let err) {
            await send(.updateFavoriteTeamResult(.failure(err)))
          }
        }
      case .updateFavoriteTeamResult(.success(let value)):
        state.isUpdating = false
        return .send(.setIsFavorite(value))
      case .updateFavoriteTeamResult(.failure(let error)):
        state.isUpdating = false
        print("Error updating favorite team \(error)")
        // TODO: Show error message
        return .none
      case .gameList(.tapped(let gameInfo)):
        return .send(.delegate(.showGameDetails(gameInfo)))
      default:
        return .none
      }
    }
  }
  @Dependency(\.databaseClient) var dbClient
  @Dependency(\.userIdentifier) var userIdStore
  @Dependency(\.ausClient) var ausClient
  
  private func addFavoriteTeam(_ teamId: Int64, for userId: String) async throws {
    try await ausClient.addFavoriteTeam(AddFavoriteTeamRequest(teamId: teamId), userId)
    try await dbClient.addFavoriteTeam(teamId, userId)
  }
  
  private func removeFavoriteTeam(_ teamId: Int64, for userId: String) async throws {
    try await ausClient.deleteFavoriteTeam(teamId, userId)
    let _ = try await dbClient.deleteFavoriteTeam(teamId, userId)
  }
}

public struct TeamContainerView: View {
 
  @ObservedObject var viewStore: ViewStoreOf<TeamContainerReducer>
  private let store: StoreOf<TeamContainerReducer>
  
  public init(store: StoreOf<TeamContainerReducer>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 12) {
        Group {
          if let url = viewStore.team.school.logo {
            LazyImage(url: url, resizingMode: .aspectFit)
          } else {
            Image(systemName: "sportscourt.circle")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.primary)
          }
        }.frame(width: 75, height: 75)
        VStack(alignment: .leading) {
          Text(viewStore.team.school.displayName)
            .fontWeight(.semibold)
            .font(.largeTitle)
          if let record = viewStore.team.record {
            Text(String(describing: record))
          }
          Text(self.viewStore.team.sport.name)
        }

        Spacer()
      }
      .padding()
      .background(Color(uiColor: .tertiarySystemBackground))
      GameListView(store: self.store.scope(state: \.gameList, action: TeamContainerReducer.Action.gameList))
    }
    .background(Color(uiColor: .secondarySystemBackground))
    .toolbarRole(.editor)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          viewStore.send(.updateFavoriteTeam(!viewStore.isFavorite))
        } label: {
          if viewStore.isFavorite {
            Image(systemName: "star.fill")
              .foregroundStyle(.yellow)
          } else {
            Image(systemName: viewStore.isUpdating ? "star.fill" : "star")
          }
        }
        .symbolEffect(.variableColor, value: viewStore.isUpdating)
      }
    }
    .onLoad {
      viewStore.send(.task)
    }
  }
}
