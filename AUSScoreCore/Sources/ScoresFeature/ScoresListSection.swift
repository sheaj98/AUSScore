// Copyright © 2023 Shea Sullivan. All rights reserved.

import ComposableArchitecture
import Models
import SwiftUI

// MARK: - ScoresListSection

public struct ScoresListSection: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable, Identifiable {
    public var id: String {
      name
    }

    public var name: String

    public var scoreRows: IdentifiedArrayOf<ScoresRow.State>

    public init(name: String, scoreRows: IdentifiedArrayOf<ScoresRow.State>) {
      self.name = name
      self.scoreRows = scoreRows
    }
  }

  public enum Action: Equatable {
    case gamesRow(id: ScoresRow.State.ID, action: ScoresRow.Action)
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { _, action in
      switch action {
      case .gamesRow(let id, action: .tapped):
        print("Tapped scoresrow with id: \(id)")
        return .none
      }
    }
  }
}

// MARK: - ScoresListSectionView

struct ScoresListSectionView: View {
  // MARK: Lifecycle

  public init(store: StoreOf<ScoresListSection>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal

  @ObservedObject var viewStore: ViewStoreOf<ScoresListSection>

  var body: some View {
    Section {
      ForEachStore(self.store.scope(state: \.scoreRows, action: ScoresListSection.Action.gamesRow(id:action:))) {
        ScoresRowView(store: $0)
      }
    } header: {
      Text(viewStore.name)
        .font(.title2)
        .textCase(.none)
        .foregroundColor(.primary)
    }
  }

  // MARK: Private

  private let store: StoreOf<ScoresListSection>
}
