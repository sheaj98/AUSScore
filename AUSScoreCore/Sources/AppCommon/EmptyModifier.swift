import SwiftUI

// MARK: - LoadingState
public enum LoadingState: Equatable {
  case empty(String)
  case loading
  case loaded
}

// MARK: - EmptyPlaceholderModifier
public struct EmptyPlaceholderModifier: ViewModifier {
  public let loadingState: LoadingState

  @ViewBuilder
  public func body(content: Content) -> some View {
    if loadingState == .loaded {
      content
    } else {
      content
        .overlay(
          Group {
            switch loadingState {
            case .loading:
              ProgressView()
            case .empty(let text):
              Text(text)
                .foregroundColor(.gray)
                .font(.body)
                .fontWeight(.semibold)
            case .loaded:
              EmptyView()
            }
          })
    }
  }
}

extension View {
  public func emptyPlaceholder(
    loadingState: LoadingState)
    -> some View
  {
    modifier(EmptyPlaceholderModifier(loadingState: loadingState))
  }
}
