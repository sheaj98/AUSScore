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

  public init() {}

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

  // MARK: - Reading contents of files

  func readFileBy(name: String, type: String) -> String {
    guard let path = Bundle.main.path(forResource: name, ofType: type) else {
      return "Failed to find path"
    }

    do {
      return try String(contentsOfFile: path, encoding: .utf8)
    } catch {
      return "Unkown Error"
    }
  }

  func makeUIView(context: Context) -> WKWebView {
    guard let path = Bundle.main.path(forResource: "article", ofType: "css"),
          let cssString = try? String(contentsOfFile: path).components(separatedBy: .newlines).joined()
    else {
      let webView = WKWebView()
      webView.navigationDelegate = context.coordinator
      return webView
    }

    let source = """
    var style = document.createElement('style');
    style.innerHTML = '\(cssString)';
    document.head.appendChild(style);
    """

    let preferences = WKPreferences()
    preferences.setValue(true, forKey: "developerExtrasEnabled")
    let userScript = WKUserScript(source: source,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: true)

    let userContentController = WKUserContentController()
    userContentController.addUserScript(userScript)

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = userContentController
    configuration.preferences = preferences

    let webView = WKWebView(frame: .zero, configuration: configuration)
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
  func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
    // If the user taps a link in the article we would like to open up the link in the users default browser
    guard let url = navigationAction.request.url else { return .allow }
    switch navigationAction.navigationType {
    case .linkActivated:
      _ = await UIApplication.shared.open(url)
      return .cancel
    default:
      return .allow
    }
  }

  func webView(_: WKWebView, didFinish _: WKNavigation!) {
    isLoading.wrappedValue = false
  }

  // MARK: Private

  private let isLoading: Binding<Bool>
}
