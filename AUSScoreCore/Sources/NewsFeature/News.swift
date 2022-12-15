// Copyright © 2022 Solbits Software Inc. All rights reserved.

import APIClient
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
    public var newItems: IdentifiedArrayOf<NewsItem>

    public init(newItems: IdentifiedArrayOf<NewsItem> = []) {
      self.newItems = newItems
    }
  }

  public enum Action: Equatable {
    case tapped
    case task
    case topNewsResponse(TaskResult<[NewsItem]>)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .tapped:
        return .none
      case .task:
        return .task {
          await .topNewsResponse(TaskResult { try await apiClient.topNews() })
        }
      case .topNewsResponse(.success(let items)):
        state.newItems = IdentifiedArray(uniqueElements: items)
        return .none
      case .topNewsResponse(.failure(let error)):
        print("Could not fetch news Items \(error.localizedDescription)")
        return .none
      }
    }
  }

  // MARK: Internal

  @Dependency(\.apiClient) var apiClient
}

// MARK: - NewsView

public struct NewsView: View {
  private let store: StoreOf<NewsFeature>
  @ObservedObject var viewStore: ViewStoreOf<NewsFeature>

  public init(store: StoreOf<NewsFeature>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  public var body: some View {
    List {
      ForEach(viewStore.newItems, content: { item in
        Text(item.title)
        AsyncImage(url: item.imageUrl, scale: 2.0)
      })
    }
    .task {
      viewStore.send(.task)
    }
  }
}

#if DEBUG
struct NewsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      NewsView(store: .items)
    }
  }
}

extension Store where State == NewsFeature.State, Action == NewsFeature.Action {
  static let items = Store(
    initialState: .init(),
    reducer: NewsFeature())
}
#endif
