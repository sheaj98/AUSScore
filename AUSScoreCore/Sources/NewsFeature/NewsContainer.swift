// Copyright © 2022 Solbits Software Inc. All rights reserved.

import AUSClient
import AUSClientLive
import ComposableArchitecture
import Foundation
import Models
import SwiftUI

// MARK: - NewsFeature

public struct NewsFeature: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable {
    public var newsCategories: IdentifiedArrayOf<NewsList.State>
    public var selectIndex: Int

    public init(
      newsCategories: IdentifiedArrayOf<NewsList.State> = [],
      selectIndex: Int = 0)
    {
      self.newsCategories = newsCategories
      self.selectIndex = selectIndex
    }
  }

  public enum Destination: Equatable {
    case category(NewsList.State)
  }

  public enum Action: Equatable {
    case selected(Int)
    case newsCategory(id: NewsList.State.ID, action: NewsList.Action)
    case task
    case newsFeedResponse(TaskResult<[NewsList.State]>)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .selected(let index):
        state.selectIndex = index
        return .none
      case .task:
        return .task {
          await .newsFeedResponse(TaskResult {
            let feeds = try await apiClient.newsFeeds()
            return feeds.enumerated().map { index, newsFeed -> NewsList.State in
              NewsList.State(id: newsFeed.id, index: index, url: newsFeed.url, displayName: newsFeed.displayName)
            }
          })
        }
      case .newsFeedResponse(.success(let items)):
        state.newsCategories = IdentifiedArray(uniqueElements: items)
        return .none
      case .newsFeedResponse(.failure(let error)):
        print("Could not fetch news feeds \(error.localizedDescription)")
        return .none
      case .newsCategory(let id, let action):
        return .none
      }
    }
    .forEach(
      \.newsCategories,
      action: /Action.newsCategory(id:action:))
    {
      NewsList()
    }
  }

  // MARK: Internal

  @Dependency(\.ausClient) var apiClient
}

// MARK: - NewsContainer

public struct NewsContainer: View {
  // MARK: Lifecycle

  public init(store: StoreOf<NewsFeature>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Public

  public var body: some View {
    VStack {
      Text("News").font(.title2)

      PageHeader(
        selected: viewStore.binding(
          get: \.selectIndex,
          send: NewsFeature.Action.selected),
        labels: viewStore.newsCategories.map(\.displayName))

      TabView(selection: viewStore.binding(
        get: \.selectIndex,
        send: NewsFeature.Action.selected))
      {
        ForEachStore(
          self.store.scope(
            state: \.newsCategories,
            action: NewsFeature.Action.newsCategory(id:action:)),
          content: NewsListView.init(store:))
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
    }
    .task {
      await viewStore.send(.task).finish()
    }
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<NewsFeature>

  // MARK: Private

  private let store: StoreOf<NewsFeature>
}

// MARK: - NewsContainer_Preview

struct NewsContainer_Preview: PreviewProvider {
  static var previews: some View {
    NewsContainer(store: .items)
  }
}

extension Store where State == NewsFeature.State, Action == NewsFeature.Action {
  static let items = Store(
    initialState: .init(),
    reducer: NewsFeature())
}
