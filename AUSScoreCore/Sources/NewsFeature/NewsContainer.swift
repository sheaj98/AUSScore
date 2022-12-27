//
//  SwiftUIView.swift
//  
//
//  Created by Shea Sullivan on 2022-12-19.
//

import SwiftUI
import AUSClient
import ComposableArchitecture
import Foundation
import Models
import SwiftUI

// MARK: NewsFeature

public struct NewsFeature: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable {
    public var newsFeeds: IdentifiedArrayOf<NewsFeed>

    public init(newsFeeds: IdentifiedArrayOf<NewsFeed> = []) {
      self.newsFeeds = newsFeeds
    }
  }

  public enum Action: Equatable {
    case tapped
    case task
    case newsFeedReponse(TaskResult<[NewsFeed]>)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .tapped:
        return .none
      case .task:
        return .task {
          await .newsFeedReponse(TaskResult { try await apiClient.newsFeeds() })
        }
      case .newsFeedReponse(.success(let items)):
        state.newsFeeds = IdentifiedArray(uniqueElements: items)
        return .none
      case .newsFeedReponse(.failure(let error)):
        print("Could not fetch news feeds \(error.localizedDescription)")
        return .none
      }
    }._printChanges()
  }

  // MARK: Internal

  @Dependency(\.ausClient) var apiClient
}


struct NewsContainer: View {
  
  private let store: StoreOf<NewsFeature>
  @ObservedObject var viewStore: ViewStoreOf<NewsFeature>

  public init(store: StoreOf<NewsFeature>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }
  
  var body: some View {
    VStack {
      Text("Hello World")
    }
      .task {
        viewStore.send(.task)
      }
  }
}

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
 
