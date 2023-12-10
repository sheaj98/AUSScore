// Copyright © 2023 Shea Sullivan. All rights reserved.

import AppCommon
import ComposableArchitecture
import Foundation
import SwiftUI
import WebKit

// MARK: - ArticleFeature

// This is a known issue with WKWebView
// Error: [Security] This method should not be called on the main thread as it may lead to UI unresponsiveness.
// See:https://developer.apple.com/forums/thread/714467?answerId=734799022#734799022

public struct ArticleFeature: Reducer {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public struct State: Equatable {
    public init(url: URL, isLoading: Bool = true) {
      self.url = url
      self.isLoading = isLoading
      loadingState = .loading
    }

    public var url: URL
    public var loadingState: LoadingState
    @BindingState public var isLoading: Bool
  }

  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()
      .onChange(of: \.isLoading) { oldValue, newValue in
        Reduce { state, _ in
          if oldValue == true && newValue == false {
            state.loadingState = .loaded
          }
          return .none
        }
      }
  }
}

// MARK: - ArticleView

struct ArticleView: UIViewRepresentable {
  // MARK: Lifecycle

  public init(store: StoreOf<ArticleFeature>) {
    self.store = store
    viewStore = ViewStore(store, observe: { $0 })
  }

  // MARK: Internal
  func makeCoordinator() -> Coordinator {
    Coordinator(isLoading: viewStore.$isLoading)
  }
  // MARK: - Inject additional properties

  func createStyleScript(
    size: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize,
    fontFamily: String = "-apple-system")
    -> WKUserScript
  {
    let cssString = """
    :root {
      color-scheme: light dark;
      --link-color: blue;
    }
    @media screen and (prefers-color-scheme: dark) {
      :root {
        --link-color: #93d5ff;
      }
    }
    body {
      font-family: \(fontFamily);
      font-size: \(size)px;
      padding: 16px;
    }
    img {
      width: 100%;
    }
    a {
      color: var(--link-color);
    }
    """.components(separatedBy: .newlines).joined()

    let source = """
    var style = document.createElement('style');
    style.innerHTML = '\(cssString)';
    document.head.appendChild(style);
    """

    return WKUserScript(
      source: source,
      injectionTime: .atDocumentEnd,
      forMainFrameOnly: true)
  }

  func createMetaScript() -> WKUserScript {
    let viewportScriptString =
      "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"

    return WKUserScript(
      source: viewportScriptString,
      injectionTime: .atDocumentEnd,
      forMainFrameOnly: true)
  }

  func makeUIView(context: Context) -> WKWebView {
    let userScript = createStyleScript()
    let metaScript = createMetaScript()

    let preferences = WKPreferences()
    preferences.setValue(true, forKey: "developerExtrasEnabled")

    let userContentController = WKUserContentController()
    userContentController.addUserScript(userScript)
    userContentController.addUserScript(metaScript)

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = userContentController
    configuration.preferences = preferences

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    
    webView.isOpaque = false
    webView.backgroundColor = UIColor(named: "secondarySystemBackground")
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
