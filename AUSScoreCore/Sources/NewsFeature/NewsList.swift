// Copyright © 2022 Solbits Software Inc. All rights reserved.

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
    public var id: String
    public var index: Int
    public var url: String
    public var displayName: String

    public var newsItems: IdentifiedArrayOf<NewsItem>

    public init(id: String, index: Int, url: String, displayName: String, newsItems: IdentifiedArrayOf<NewsItem> = []) {
      self.id = id
      self.index = index
      self.url = url
      self.displayName = displayName
      self.newsItems = newsItems
    }
  }

  public enum Action: Equatable {
    case task
    case newsItemResponse(TaskResult<[NewsItem]>)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .task:
        return .task { [url = state.url] in
          await .newsItemResponse(TaskResult {
            try await apiClient.newsItems(url)
          })
        }
      case .newsItemResponse(.success(let items)):
        state.newsItems = IdentifiedArray(uniqueElements: items)
        return .none
      case .newsItemResponse(.failure(let error)):
        print("Could not fetch news feeds \(error.localizedDescription)")
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

  public init(store: StoreOf<NewsList>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  var body: some View {
    List {
      ForEach(viewStore.newsItems) { newsItem in
        Text(newsItem.title)
      }
    }
    .task {
      await viewStore.send(.task).finish()
    }
    .tag(viewStore.index)
  }
}

// struct NewsListView_Preview: PreviewProvider {
//    static var previews: some View {
//      NewsListView()
//    }
// }
