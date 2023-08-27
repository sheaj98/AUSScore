// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import AUSClient
import ComposableArchitecture
import DatabaseClient
import Models
import SwiftUI

// MARK: - NewsList

public struct NewsList: ReducerProtocol {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable, Identifiable {
    // MARK: Lifecycle

    public init(from newsFeed: NewsFeed, index: Int) {
      self.id = newsFeed.id
      self.index = index
      self.displayName = newsFeed.displayName
      self.destination = nil
      self.newsItems = []
      self.loadingState = .loaded
    }

    public init(
      id: Int64,
      index: Int,
      url: String,
      displayName: String,
      destination: Destination? = nil,
      newsItems: IdentifiedArrayOf<News.State> = [],
      loadingState: LoadingState = .loaded)
    {
      self.id = id
      self.index = index
      self.displayName = displayName
      self.destination = destination
      self.newsItems = newsItems
      self.loadingState = loadingState
    }

    // MARK: Public

    public enum Destination: Equatable {
      case article(ArticleFeature.State)
    }

    public var id: Int64
    public var index: Int
    public var displayName: String
    public var destination: Destination?
    public var newsItems: IdentifiedArrayOf<News.State>
    public var loadingState: LoadingState
  }

  public enum Action: Equatable {
    case task
    case newsItemResponse(TaskResult<[News.State]>)
    case newsItem(id: News.State.ID, action: News.Action)
    case articleDismissed
    case destination(Destination)
    case refresh

    public enum Destination: Equatable {
      case article(ArticleFeature.Action)
      // Crash workaround (CasePath Library doesn't seem to handle a nested enum with only one case)
      // Likely related to https://github.com/pointfreeco/swift-case-paths/issues/71
      case noop
    }
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .task:
        return .merge(
          .run { [id = state.id] _ in
            try await syncNewsItems(id: id)
          } catch: { error, send in
            print(error)
          },

          .run { [id = state.id] send in
            for try await newsItems in databaseClient.newsItemStream(id) {
              let news = newsItems.map { News.State(newsItem: $0) }
              await send(.newsItemResponse(.success(news)))
            }
          } catch: { error, send in
            await send(.newsItemResponse(.failure(error)))
          })
      case .refresh:
        return .run { [id = state.id] _ in
          try await syncNewsItems(id: id)
        }
      case .newsItemResponse(.success(let items)):
        state.newsItems = IdentifiedArray(uniqueElements: items)
        return .none
      case .newsItemResponse(.failure(let error)):
        print("Could not fetch news items \(error.localizedDescription)")
        state.loadingState = .empty("Something unexpected occured")
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
  
  func syncNewsItems(id: Int64) async throws {
    let remoteNewsItems = try await apiClient.newsItems(id)
    try await databaseClient.syncNewsFeed(id, remoteNewsItems)
  }

  // MARK: Internal

  @Dependency(\.ausClient) var apiClient
  @Dependency(\.databaseClient) var databaseClient
}

// MARK: - NewsListView

public struct NewsListView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<NewsList>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { ViewState(state: $0) })
  
  }
  
  public struct ViewState: Equatable {
    public let loadingState: LoadingState
    public let index: Int
    public let destination: NewsList.State.Destination?
    
    public init(state: NewsList.State) {
      self.loadingState = state.loadingState
      self.index = state.index
      self.destination = state.destination
    }
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStore<ViewState, NewsList.Action>
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
      await viewStore.send(.refresh).finish()
    })
    .dynamicTypeSize(...DynamicTypeSize.xLarge)
    .background(Color(uiColor: .systemGroupedBackground))
    .task {
      viewStore.send(.task)
    }
    .tag(viewStore.index)
    .emptyPlaceholder(loadingState: viewStore.loadingState)
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
