// Copyright © 2022 Solbits Software Inc. All rights reserved.

import AUSClient
import ComposableArchitecture
import Foundation
import Models
import NukeUI
import SwiftUI
import UIKit
import Utilities

// MARK: - News

public struct News: ReducerProtocol {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable, Identifiable {
    public var id: String {
      title
    }

    public let title: String
    public let link: URL
    public let content: String
    public var imageUrl: URL?
    public let date: Date

    public init(title: String, link: URL, content: String, imageUrl: URL?, date: Date) {
      self.title = title
      self.link = link
      self.content = content
      self.imageUrl = imageUrl
      self.date = date
    }

    public init(newsItem: NewsItem) {
      self.title = newsItem.title
      self.link = newsItem.link
      self.content = newsItem.content
      self.imageUrl = newsItem.imageUrl
      self.date = newsItem.date
    }
  }

  public enum Action: Equatable {
    case tapped
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, _ in
      .none
    }
  }

  // MARK: Internal

  @Dependency(\.ausClient) var apiClient
}

// MARK: - NewsView

public struct NewsView: View {
  private let store: StoreOf<News>
  @ObservedObject var viewStore: ViewStoreOf<News>
  @Environment(\.colorScheme) var colorScheme

  public init(store: StoreOf<News>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }

  public var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading, spacing: 10) {
          Text(viewStore.title)
            .font(.headline)
            .frame(alignment: .leading)
          Text(viewStore.date.formatted(date: .abbreviated, time: .omitted))
            .font(.caption)
            .frame(alignment: .leading)
        }
        Spacer()
      }
      .padding()

      if let url = viewStore.imageUrl {
        LazyImage(url: url)
          .aspectRatio(639 / 470, contentMode: .fit)
      }
    }

    .background(Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground))
    .cornerRadius(8)
    .contentShape(RoundedRectangle(cornerRadius: 8))
    .onTapGesture {
      self.viewStore.send(.tapped)
    }
  }
}

#if DEBUG
struct NewsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      NewsView(store: .newsItem)
    }
  }
}

extension Store where State == News.State, Action == News.Action {
  static let newsItem = Store(
    initialState: .init(title: "Canada ready to chase gold at Lake Placid 2023", link: URL(string: "http://www.atlanticuniversitysport.com/sports/mice/2022-23/releases/20221214i5csbw")!, content: "Eleven AUS players named as U SPORTS announces men's hockey roster for 2023 FISU Winter World University Games", imageUrl: URL(string: "http://www.atlanticuniversitysport.com/sports/mice/2022-23/photos/FISU_MHCK_1040x680-1040x_mp.jpg")!, date: Date()),
    reducer: News())
}
#endif
