//
//  SwiftUIView.swift
//  
//
//  Created by Shea Sullivan on 2023-03-25.
//

import SwiftUI
import ComposableArchitecture
import Models
import AppCommon
import NewsFeature
import ScoresFeature

public struct League: Reducer {
  public init() {}
  
  public enum Tab: Int {
    case news = 0
    case scores = 1
    case standings = 2
  }
  
  public struct State: Equatable, Identifiable {
    public var sport: SportInfo
    public var selectedView: Int
    public var news: NewsList.State
    public var scores: ScoresFeature.State
    
    public init(sport: SportInfo, selectedView: Int = 0) {
      self.sport = sport
      self.selectedView = selectedView
      self.news = .init(from: sport.newsFeed, index: 0)
      self.scores = ScoresFeature.State.init(sportId: sport.id)
    }
    
    public var id: Sport.ID { self.sport.id }
  }
  
  public enum Action: Equatable {
    case task
    case selected(tab: Int)
    case news(NewsList.Action)
    case scores(ScoresFeature.Action)
  }
  
  public var body: some Reducer<State, Action> {
    
    Scope(state: \.news, action: /Action.news) {
      NewsList()
    }
    
    Scope(state: \.scores, action: /Action.scores) {
      ScoresFeature()
    }
    
    Reduce { state, action in
      switch(action) {
      case .task:
        return .none
      case .selected(let tab):
        state.selectedView = tab
        return .none
      case .news:
        return .none
      default:
        return .none
      }
    }
  }
}

public struct LeagueView: View {
  private let store: StoreOf<League>
  
  @Environment(\.dismiss) var dismiss
  
  public init(store: StoreOf<League>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<League>
  
    public var body: some View {
      SimplePageHeader(
        selected: viewStore.binding(
          get: \.selectedView,
          send: League.Action.selected),
        labels: ["NEWS", "SCORES", "STANDINGS"])
      .padding(.bottom, -8)

      TabView(selection: viewStore.binding(
        get: \.selectedView,
        send: League.Action.selected))
      {
        NewsListView(store: self.store.scope(state: \.news, action: League.Action.news))
          .tag(0)
        
        ScoresContainer(store: self.store.scope(state: \.scores, action: League.Action.scores))
          .tag(1)
          .padding(.top, -16)
        Text("Standings")
          .tag(2)
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .navigationTitle(viewStore.sport.name)
      .toolbarRole(.editor)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
      LeagueView(store: .item)
    }
}

extension Store where State == League.State, Action == League.Action {
  static let item = Store(
    initialState: .init(sport: .mock()),
    reducer: {
      League()
    })
}
