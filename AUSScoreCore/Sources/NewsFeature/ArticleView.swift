// Copyright © 2022 Solbits Software Inc. All rights reserved.

import ComposableArchitecture
import Foundation
import SwiftUI
import WebKit

// MARK: - ArticleFeature
// This is a known issue with WKWebView
// Error: [Security] This method should not be called on the main thread as it may lead to UI unresponsiveness.
// See:https://developer.apple.com/forums/thread/714467?answerId=734799022#734799022

public struct ArticleFeature: ReducerProtocol {
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct State: Equatable {
    public init(url: URL, isLoading: Bool = true) {
      self.url = url
      self.isLoading = isLoading
    }

    public var url: URL
    @BindableState public var isLoading: Bool
  }

  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
  }
}

// MARK: - ArticleView

struct ArticleView: UIViewRepresentable {
  // MARK: Lifecycle

  public init(store: StoreOf<ArticleFeature>) {
    self.store = store
    viewStore = ViewStore(store)
  }

  // MARK: Internal

  func makeCoordinator() -> Coordinator {
    Coordinator(
      isLoading: viewStore.binding(\.$isLoading))
  }

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    return webView
  }

  func updateUIView(_ webView: WKWebView, context _: Context) {
    let request = URLRequest(url: viewStore.url)
    webView.load(request)
  }

  // MARK: Private

  private let store: StoreOf<ArticleFeature>
  private let viewStore: ViewStoreOf<ArticleFeature>
}

// MARK: - Coordinator

final class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
  // MARK: Lifecycle

  init(isLoading: Binding<Bool>) {
    self.isLoading = isLoading
  }

  // MARK: Internal

  // MARK: WKNavigationDelegate

  @MainActor
  func webView(_: WKWebView, decidePolicyFor _: WKNavigationAction) async -> WKNavigationActionPolicy {
    // The first request returns a URL of "about:blank", indicating a blank page probably because we are loading this from an HTML
    // string.
    // Therefore if the scheme is "about" we will allow this request. Otherwise, open safari to view other links.
//    guard let url = navigationAction.request.url else { return .allow }
//    guard url.scheme != "about" else { return .allow }
//    _ = await UIApplication.shared.open(url)
//    return .cancel
    .allow
  }

  func webView(_: WKWebView, didFinish _: WKNavigation!) {
    isLoading.wrappedValue = false
  }

  // MARK: Private

  private let isLoading: Binding<Bool>
}
