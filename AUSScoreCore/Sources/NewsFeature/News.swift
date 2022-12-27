// Copyright © 2022 Solbits Software Inc. All rights reserved.

import AUSClient
import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import UIKit

// MARK: - NewsView

public struct NewsView: View {
  var newsItem: NewsItem

  public var body: some View {
    VStack {
      VStack {
        Text(newsItem.title).fontWeight(.bold)
        
        
      }.padding(.top)
      
      AsyncImage(url: newsItem.imageUrl, scale: 2.0)
    }
    .background(Color(uiColor: .secondarySystemFill))
      .cornerRadius(12)

  }
}

#if DEBUG
struct NewsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      NewsView(newsItem: .mock)
    }
  }
}

//extension Store where State == NewsFeature.State, Action == NewsFeature.Action {
//  static let items = Store(
//    initialState: .init(),
//    reducer: NewsFeature())
//}
#endif
