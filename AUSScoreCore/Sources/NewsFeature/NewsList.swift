// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import AUSClient
import ComposableArchitecture
import DatabaseClient
import Models
import SwiftUI

// MARK: - NewsList
@Reducer
public struct NewsList {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable, Identifiable {
    // MARK: Lifecycle

    public init(from newsFeed: NewsFeed, index: Int) {
      self.id = newsFeed.id
      self.index = index
      self.displayName = newsFeed.displayName
      self.newsItems = []
      self.loadingState = .loading
      self.articleView = nil
      self.toggleScrollToTop = false
    }

    public init(
      id: Int64,
      index: Int,
      url: String,
      displayName: String,
      newsItems: IdentifiedArrayOf<News.State> = [],
      loadingState: LoadingState = .loading,
      articleView: ArticleFeature.State? = nil)
    {
      self.id = id
      self.index = index
      self.displayName = displayName
      self.newsItems = newsItems
      self.loadingState = loadingState
      self.articleView = articleView
      self.toggleScrollToTop = false
    }

    // MARK: Public

    public var id: Int64
    public var index: Int
    public var displayName: String
    public var newsItems: IdentifiedArrayOf<News.State>
    public var loadingState: LoadingState
    public var toggleScrollToTop: Bool
    @PresentationState public var articleView: ArticleFeature.State?
  }

  public enum Action: Equatable {
    case task
    case newsItemResponse(TaskResult<[News.State]>)
    case newsItems(IdentifiedActionOf<News>)
    case refresh
    case article(PresentationAction<ArticleFeature.Action>)
    case dismissArticle
    case scrollToTop
  }

  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .task:
        state.loadingState = .loading
        state.newsItems = IdentifiedArray(uniqueElements: NewsItem.placeholderItems.map({ News.State(newsItem: $0) }))
        return .merge(
          .run { [id = state.id] _ in
            try await syncNewsItems(id: id)
          } catch: { error, _ in
            print("Error syncing news items \(error)")
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
        state.loadingState = .loading
        return .run { [id = state.id] _ in
          try await syncNewsItems(id: id)
        }
      case .newsItemResponse(.success(let items)):
        if (!items.isEmpty) {
          state.newsItems = IdentifiedArray(uniqueElements: items)
          state.loadingState = .loaded
        }
        return .none
      case .newsItemResponse(.failure(let error)):
        print("Could not fetch news items \(error.localizedDescription)")
        state.loadingState = .empty("Something unexpected occured")
        return .none
      case .newsItems(.element(let id, action: .tapped)):
        guard let news = state.newsItems[id: id] else { return .none }
        state.articleView = ArticleFeature.State(url: news.link)
        return .none
      case .dismissArticle:
        state.articleView = nil
        return .none
      case .scrollToTop:
        state.toggleScrollToTop.toggle()
        return .none
      default:
        return .none
      }
    }
    .ifLet(\.$articleView, action: \.article) {
      ArticleFeature()
    }._printChanges()
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
    public let toggleScrolltoTop: Bool
    public let firstNewsItem: News.State.ID?

    public init(state: NewsList.State) {
      self.loadingState = state.loadingState
      self.index = state.index
      self.toggleScrolltoTop = state.toggleScrollToTop
      self.firstNewsItem = state.newsItems.first?.id
    }
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStore<ViewState, NewsList.Action>
  @Environment(\.colorScheme) var colorScheme

  public var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 15) {
          ForEachStore(self.store.scope(state: \.newsItems, action: \.newsItems)) {
            NewsView(store: $0)
              .redacted(reason: viewStore.loadingState == .loading ? .placeholder : [])
          }
        }
        .padding()
      }
      .refreshable(action: {
        await viewStore.send(.refresh).finish()
      })
      .dynamicTypeSize(...DynamicTypeSize.xLarge)
      .background(Color(uiColor: .systemGroupedBackground))
      .onChange(of: viewStore.toggleScrolltoTop) { oldValue, newValue in
        withAnimation {
          proxy.scrollTo(viewStore.firstNewsItem, anchor: .bottom)
        }
      }
    }

    .onAppear {
      viewStore.send(.task)
    }
    .tag(viewStore.index)
    .sheet(
      store: self.store.scope(state: \.$articleView, action: \.article)
    ) { store in
      NavigationStack {
        ArticleView(store: store)
          .toolbar {
            ToolbarItem {
              Button("Done") {
                viewStore.send(.dismissArticle)
              }
            }
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
      id: Int64(1),
      index: 0,
      url: "https://www.atlanticuniversitysport.com/landing/headlines-featured?feed=rss_2.0",
      displayName: "Featured"))
  {
    NewsList()
  }
}
