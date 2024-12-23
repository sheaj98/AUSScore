// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import AUSClient
import AUSClientLive
import ComposableArchitecture
import Foundation
import Models
import SwiftUI

// MARK: - NewsFeature

@Reducer
public struct NewsFeature {
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
    case newsCategories(IdentifiedActionOf<NewsList>)
    case task
    case newsFeedResponse(TaskResult<[NewsList.State]>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .selected(let index):
        state.selectIndex = index
        return .none
      case .task:
        return .run { send in
          await send(.newsFeedResponse(TaskResult {
            let feeds = try await apiClient.newsFeeds()
            return feeds.enumerated().map { index, newsFeed -> NewsList.State in
              NewsList.State(id: newsFeed.id, index: index, url: newsFeed.url, displayName: newsFeed.displayName)
            }
          }))
        }
      case .newsFeedResponse(.success(let items)):
        state.newsCategories = IdentifiedArray(uniqueElements: items)
        return .none
      case .newsFeedResponse(.failure(let error)):
        print("Could not fetch news feeds \(error.localizedDescription)")
        return .none
      case .newsCategories:
        return .none
      }
    }
    .forEach(
      \.newsCategories,
       action: \.newsCategories)
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
    VStack(spacing: 0) {
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
            action: \.newsCategories),
          content: NewsListView.init(store:))
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
    }
    .background(Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground))
    .onLoad {
      viewStore.send(.task)
    }
  }

  // MARK: Internal

  @Environment(\.colorScheme) var colorScheme

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
    initialState: .init()) {
      NewsFeature()
    }
}
