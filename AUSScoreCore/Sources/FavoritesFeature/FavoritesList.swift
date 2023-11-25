//
//  File.swift
//
//
//  Created by Shea Sullivan on 2023-11-19.
//

import AppCommon
import AUSClient
import ComposableArchitecture
import DatabaseClient
import Dependencies
import Models
import SwiftUI
import UserIdentifier

public struct FavoritesList: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var favoriteTeams: IdentifiedArrayOf<TeamInfo>
    public var favoriteSports: IdentifiedArrayOf<SportInfo>
    public var schools: IdentifiedArrayOf<SchoolInfo>
    
    public init(favoriteTeams: IdentifiedArrayOf<TeamInfo> = [], favoriteSports: IdentifiedArrayOf<SportInfo> = [], schools: IdentifiedArrayOf<SchoolInfo> = []) {
      self.favoriteTeams = favoriteTeams
      self.favoriteSports = favoriteSports
      self.schools = schools
    }
  }
  
  public enum Action {
    case task
    case userResponse(UserInfo)
    case schools(TaskResult<[SchoolInfo]>)
    case addFavoriteTeam(TeamInfo)
    case removeFavoriteTeam(TeamInfo)
    case addFavoriteSchool(SchoolInfo)
    case removeFavoriteSchool(SchoolInfo)
    case favoritesError(Error)
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .run { send in
          
          await send(.schools(TaskResult {
            try await dbClient.conferenceSchools()
          }))
          
          for try await user in dbClient.userStream() {
            await send(.userResponse(user))
          }
        }
      case .addFavoriteTeam(let team):
        return .run { send in
          do {
            let userId = try await userIdStore.id()
            try await addFavoriteTeam(team.id, for: userId)
          } catch (let err) {
            await send(.favoritesError(err))
          }
        }
      case .removeFavoriteTeam(let team):
        return .run { send in
          do {
            let userId = try await userIdStore.id()
            try await removeFavoriteTeam(team.id, for: userId)
          } catch (let err) {
            await send(.favoritesError(err))
          }
        }
      case .addFavoriteSchool(let school):
        return .run { [favoriteTeams = state.favoriteTeams] send in
          do {
            let userId = try await userIdStore.id()
            try await withThrowingTaskGroup(of: Void.self, body: { group in
              for team in school.teams {
                if !favoriteTeams.contains(team) {
                  group.addTask {
                    try await addFavoriteTeam(team.id, for: userId)
                  }
                }
              }
              
              try await group.waitForAll()
            })
          } catch (let err) {
            await send(.favoritesError(err))
          }
        }
      case .removeFavoriteSchool(let school):
        return .run { send in
          do {
            let userId = try await userIdStore.id()
            try await withThrowingTaskGroup(of: Void.self, body: { group in
              for team in school.teams {
                group.addTask {
                  try await removeFavoriteTeam(team.id, for: userId)
                }
              }
              
              try await group.waitForAll()
            })
          } catch (let err) {
            await send(.favoritesError(err))
          }
        }
      case .favoritesError(let err):
        print("Error updating favorites \(err.localizedDescription)")
        // TODO: Show toast
        return .none
      case .userResponse(let user):
        state.favoriteSports = IdentifiedArray(uniqueElements: user.favoriteSports)
        state.favoriteTeams = IdentifiedArray(uniqueElements: user.favoriteTeams)
        return .none
      case .schools(.success(let schools)):
        state.schools = IdentifiedArray(uniqueElements: schools)
        return .none
      case .schools(.failure(let err)):
        // TODO: Add error toast
        print("error getting schools \(err.localizedDescription)")
        return .none
      }
    }
  }
  
  private func addFavoriteTeam(_ teamId: Int64, for userId: String) async throws {
    try await ausClient.addFavoriteTeam(AddFavoriteTeamRequest(teamId: teamId), userId)
    try await dbClient.addFavoriteTeam(teamId, userId)
  }
  
  private func removeFavoriteTeam(_ teamId: Int64, for userId: String) async throws {
    try await ausClient.deleteFavoriteTeam(teamId, userId)
    let _ = try await dbClient.deleteFavoriteTeam(teamId, userId)
  }
  
  @Dependency(\.userIdentifier) var userIdStore
  @Dependency(\.databaseClient) var dbClient
  @Dependency(\.ausClient) var ausClient
}

public struct FavoritesListCell: View {
  let isFavorite: Bool
  let displayName: String
  let callback: () -> Void
  
  public var body: some View {
    HStack {
      FavoritesButton(isFavorite: isFavorite, action: { _ in
        callback()
      }, isUpdating: false)
      Text(displayName)
    }
  }
}

public struct FavoritesListView: View {
  private let store: StoreOf<FavoritesList>
  @ObservedObject var viewStore: ViewStoreOf<FavoritesList>
  
  public init(store: StoreOf<FavoritesList>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  public var body: some View {
    List {
      Section {
        ForEach(viewStore.schools) { school in
          DisclosureGroup(
            content: {
              ForEach(school.teams) { team in
                let isFavorite = viewStore.favoriteTeams.contains(team)
                FavoritesListCell(isFavorite: isFavorite, displayName: team.sport.name) {
                  if (!isFavorite) {
                    viewStore.send(.addFavoriteTeam(team))
                  } else {
                    viewStore.send(.removeFavoriteTeam(team))
                  }
                }
              }
            },
            label: {
              let isFavorite = school.teams.allSatisfy(viewStore.favoriteTeams.contains)
              FavoritesListCell(isFavorite: isFavorite , displayName: school.displayName) {
                if !isFavorite {
                  viewStore.send(.addFavoriteSchool(school))
                } else {
                  viewStore.send(.removeFavoriteSchool(school))
                }
            } }
          )
        }
      } header: {
        Text("Schools")
      }
    }
    .headerProminence(.increased)
    .listStyle(.insetGrouped)
    .task {
      viewStore.send(.task)
    }
  }
}

struct FavoritesList_Preview: PreviewProvider {
  static var previews: some View {
    FavoritesListView(store: .items)
  }
}

extension Store where State == FavoritesList.State, Action == FavoritesList.Action {
  static let items = Store(initialState: FavoritesList.State(schools: IdentifiedArray(uniqueElements: [.stfxMock(), .unbMock()])), reducer: {
    FavoritesList()
  })
}
