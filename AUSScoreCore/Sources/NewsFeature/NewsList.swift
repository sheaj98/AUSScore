// Copyright © 2022 Solbits Software Inc. All rights reserved.

import AUSClient
import ComposableArchitecture
import Foundation
import Models
import SwiftUI

// MARK: - NewsList

public struct NewsList: ReducerProtocol {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable, Identifiable {
    public var id: String
    public var index: Int
    public var url: String
    public var displayName: String
    //    public var destination: Destination?

    public var newsItems: IdentifiedArrayOf<News.State>

    public init(id: String, index: Int, url: String, displayName: String, newsItems: IdentifiedArrayOf<News.State> = []) {
      self.id = id
      self.index = index
      self.url = url
      self.displayName = displayName
      self.newsItems = newsItems
    }
  }

  public enum Destination {
    case art(URL)
  }

  public enum Action: Equatable {
    case task
    case newsItemResponse(TaskResult<[News.State]>)
    case newsItem(id: News.State.ID, action: News.Action)
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
      case .newsItem:
        print("Tapped")
        return .none
      }
    }
  }

  // MARK: Internal

  @Dependency(\.ausClient) var apiClient
}

// MARK: - NewsListView

struct NewsListView: View {
  private let store: StoreOf<NewsList>
  @ObservedObject var viewStore: ViewStoreOf<NewsList>
  @Environment(\.colorScheme) var colorScheme

  public init(store: StoreOf<NewsList>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 15) {
        ForEachStore(self.store.scope(state: \.newsItems, action: NewsList.Action.newsItem(id:action:))) {
          NewsView(store: $0)
        }
      }
      .padding()
    }
    .background(Color(uiColor: colorScheme == .dark ? .systemBackground : .secondarySystemBackground))
    .task {
      await viewStore.send(.task).finish()
    }
    .tag(viewStore.index)
  }
}

struct NewsListView_Preview: PreviewProvider {
  static var previews: some View {
    NewsListView(store: .items)
  }
}

extension Store where State == NewsList.State, Action == NewsList.Action {
  static let items = Store(
    initialState: .init(id: "TestId", index: 0, url: "https://www.atlanticuniversitysport.com/landing/headlines-featured?feed=rss_2.0", displayName: "Featured"),
    reducer: NewsList())
}
