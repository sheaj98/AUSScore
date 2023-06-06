// Copyright © 2023 Shea Sullivan. All rights reserved.

import AUSClient
import ComposableArchitecture
import Foundation
import Models
import SwiftUI

// MARK: - NewsList

public struct NewsList: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable, Identifiable {
    // MARK: Lifecycle
    
    public init(from newsFeed: NewsFeed, index: Int) {
      self.id = newsFeed.id
      self.index = index
      self.url = newsFeed.url
      self.displayName = newsFeed.displayName
      self.destination = nil
      self.newsItems = []
    }

    public init(
      id: Int64,
      index: Int,
      url: String,
      displayName: String,
      destination: Destination? = nil,
      newsItems: IdentifiedArrayOf<News.State> = [])
    {
      self.id = id
      self.index = index
      self.url = url
      self.displayName = displayName
      self.destination = destination
      self.newsItems = newsItems
    }

    // MARK: Public

    public enum Destination: Equatable {
      case article(ArticleFeature.State)
    }

    public var id: Int64
    public var index: Int
    public var url: String
    public var displayName: String
    public var destination: Destination?
    public var newsItems: IdentifiedArrayOf<News.State>
  }

  public enum Action: Equatable {
    case task
    case newsItemResponse(TaskResult<[News.State]>)
    case newsItem(id: News.State.ID, action: News.Action)
    case articleDismissed
    case destination(Destination)

    public enum Destination: Equatable {
      case article(ArticleFeature.Action)
      // Crash workaround (CasePath Library doesn't seem to handle a nested enum with only one case)
      // Likely related to https://github.com/pointfreeco/swift-case-paths/issues/71
      case noop
    }
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .task { [url = state.url] in
          await .newsItemResponse(TaskResult {
            let newsItems = try await apiClient.newsItems(url)
            return newsItems.map {
              News.State(newsItem: $0)
            }
          })
        }
      case .newsItemResponse(.success(let items)):
        state.newsItems = IdentifiedArray(uniqueElements: items)
        return .none
      case .newsItemResponse(.failure(let error)):
        print("Could not fetch news items \(error.localizedDescription)")
        return .none
      case .newsItem(let id, action: .tapped):
        guard let news = state.newsItems[id: id] else { return .none }
        state.destination = .article(.init(url: news.link))
        return .none
      case .articleDismissed:
        state.destination = nil
        return .none
      case .destination:
        return .none
      }
    }
    .ifLet(\.destination, action: /Action.destination) {
      EmptyReducer()
        .ifCaseLet(/State.Destination.article, action: /Action.Destination.article) {
          ArticleFeature()
        }
    }
  }

  // MARK: Internal

  @Dependency(\.ausClient) var apiClient
}

// MARK: - NewsListView

public struct NewsListView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<NewsList>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<NewsList>
  @Environment(\.colorScheme) var colorScheme

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 15) {
        ForEachStore(self.store.scope(state: \.newsItems, action: NewsList.Action.newsItem(id:action:))) {
          NewsView(store: $0)
        }
      }
      .padding()
    }
    .refreshable(action: {
      await viewStore.send(.task).finish()
    })
    .dynamicTypeSize(...DynamicTypeSize.xLarge)
    .background(Color(uiColor: .systemGroupedBackground))
    .task {
      await viewStore.send(.task).finish()
    }
    .tag(viewStore.index)
    .sheet(isPresented: viewStore.binding(get: { _ in
      viewStore.destination.flatMap(/NewsList.State.Destination.article) != nil
    }, send: .articleDismissed)) {
      IfLetStore(self.store.scope(
        state: { $0.destination.flatMap(/NewsList.State.Destination.article) },
        action: { NewsList.Action.destination(.article($0)) }))
      { articleStore in
        NavigationStack {
          ArticleView(store: articleStore)
            .toolbar(content: {
              ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                  viewStore.send(.articleDismissed)
                }
              }
            })
        }
      }
    }
  }

  // MARK: Private

  private let store: StoreOf<NewsList>
}

// MARK: - NewsListView_Preview

struct NewsListView_Preview: PreviewProvider {
  static var previews: some View {
    NewsListView(store: .items)
  }
}

extension Store where State == NewsList.State, Action == NewsList.Action {
  static let items = Store(
    initialState: .init(
      id: 1,
      index: 0,
      url: "https://www.atlanticuniversitysport.com/landing/headlines-featured?feed=rss_2.0",
      displayName: "Featured"),
    reducer: NewsList())
}
