import Foundation

// MARK: - Team

public struct NewsFeedCategory: Identifiable, Codable, Equatable {
  public let newsFeedId: Int64
  public let newsItemId: String

  public init(newsFeedId: Int64, newsItemId: String) {
    self.newsFeedId = newsFeedId
    self.newsItemId = newsItemId
  }
  
  enum CodingKeys: String, CodingKey {
    case newsFeedId = "newsfeed_id"
    case newsItemId = "news_item_id"
  }
  
  public var id: String {
    return "\(newsFeedId)+\(newsItemId)"
  }
}

extension NewsFeedCategory {
  public static func mock() -> Self {
    .init(newsFeedId: 1, newsItemId: "news-item")
  }
}
