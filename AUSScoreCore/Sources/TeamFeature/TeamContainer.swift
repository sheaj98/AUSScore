//
//  SwiftUIView.swift
//
//
//  Created by Shea Sullivan on 2023-10-08.
//

import ComposableArchitecture
import Models
import NukeUI
import SwiftUI

public struct TeamContainerReducer: Reducer {
  public init() {}

  public struct State: Equatable {
    public let team: TeamInfo
    public var gameList: GameListReducer.State

    public init(team: TeamInfo) {
      self.team = team
      self.gameList = GameListReducer.State(teamId: team.id)
    }
  }

  public enum Action: Equatable {
    public enum DelegateAction: Equatable {
      case showGameDetails(GameInfo)
    }
    
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
    
    Reduce { _, action in
      switch action {
      case .gameList(.tapped(let gameInfo)):
        return .send(.delegate(.showGameDetails(gameInfo)))
      default:
        return .none
      }
    }
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
  }
}
