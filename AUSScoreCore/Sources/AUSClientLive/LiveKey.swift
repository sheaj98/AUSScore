// Copyright © 2023 Shea Sullivan. All rights reserved.

import AUSClient
import Dependencies
import Foundation
import Get
import Models

// MARK: - AUSClient + DependencyKey

extension AUSClient: DependencyKey {
  // MARK: Public

  public static let liveValue = live()

  // MARK: Private

  private static func live() -> Self {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601TimeZone)

    let client = APIClient(baseURL: URL(string: "https://nhs80qwzwd.execute-api.us-east-1.amazonaws.com")) {
      $0.decoder = decoder
    }

    return Self(
      newsFeeds: {
        let request = Request<[NewsFeed]>(path: "newsfeeds")
        return try await client.send(request).value
      },
      newsItems: { newsFeedId in
        let request = Request<NewsItems>(path: "newsfeeds/\(newsFeedId)/items")
        return try await client.send(request).value.items
      },
      schools: {
        let request = Request<[School]>(path: "schools")
        return try await client.send(request).value
      },
      sports: {
        let request = Request<[Sport]>(path: "sports")
        return try await client.send(request).value
      },
      teams: {
        let request = Request<[Team]>(path: "teams")
        return try await client.send(request).value
      },
      allGames: {
        let request = Request<[Game]>(path: "games", query: [("includeCancelled", "true")])
        return try await client.send(request).value
      },
      gamesBySportId: { sportId in
        let request = Request<[Game]>(path: "sports/\(sportId)/games")
        return try await client.send(request).value
      },
      bulkFetchGames: { gamesBulkDTO in
        let request = Request<[Game]>(path: "games/bulk", body: gamesBulkDTO)
        return try await client.send(request).value
      },
      gameResults: {
        let request = Request<[GameResult]>(path: "game_results")
        return try await client.send(request).value
      },
      upsertUser: { userRequest in
        let request = Request<UserResponse>(path: "users", method: .post, body: userRequest)
        return try await client.send(request).value
      },
      addFavoriteSport: { body, userId in
        let request = Request(path: "users/\(userId)/favorite_sports", method: .post, body: body)
        try await client.send(request)
      },
      addFavoriteTeam: { body, userId in
        let request = Request(path: "users/\(userId)/favorite_teams", method: .post, body: body)
        try await client.send(request)
      },
      deleteFavoriteSport: { sportId, userId in
        let request = Request(path: "/users/\(userId)/favorite_sports/\(sportId)", method: .delete)
        try await client.send(request)
      },
      deleteFavoriteTeam: { teamId, userId in
        let request = Request(path: "/users/\(userId)/favorite_teams/\(teamId)", method: .delete)
        try await client.send(request)
      },
      getUser: { userId in
        let request = Request<UserResponse>(path: "/users/\(userId)", method: .get)
        return try await client.send(request).value
      }
    )
  }
}

extension DateFormatter {
  // 2021-04-25T11:00:00.0000000Z - includes milliseconds
  public static let iso8601TimeZone: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
