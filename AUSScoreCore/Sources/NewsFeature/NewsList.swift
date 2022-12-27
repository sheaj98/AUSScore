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


public struct NewsList: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable {
    
    public var id: String
    public var url: String
    public var displayName: String
    
    public var newsItems: IdentifiedArrayOf<NewsItem>

    public init(id: String, url: String, displayName: String, newsItems: IdentifiedArrayOf<NewsItem>) {
      self.id = id
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
        return .task {
          await .newsItemResponse(TaskResult { try await apiClient.newsItems() })
        }
      case .newsItemResponse(.success(let items)):
        state.newsItems = IdentifiedArray(uniqueElements: items)
        return .none
      case .newsItemResponse(.failure(let error)):
        print("Could not fetch news feeds \(error.localizedDescription)")
        return .none
      }
    }._printChanges()
  }

  // MARK: Internal

  @Dependency(\.ausClient) var apiClient
}

struct NewsListView: View {
  private let store: StoreOf<NewsList>
  init(store: StoreOf<NewsList>) {
    self.store = store
  }
    var body: some View {
        Text("Hello, World!")
    }
}

//struct NewsListView_Preview: PreviewProvider {
//    static var previews: some View {
//      NewsListView()
//    }
//}
