//
//  File.swift
//  
//
//  Created by Shea Sullivan on 2022-12-29.
//

import Foundation

extension URL {
    /// Replaces queryItems
    /// - Parameter queryItems: The queryItems to append
    /// - Returns: The `URL` with the queryItems.
    func append(_ queryItems: [String: String]?) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let items = queryItems?.map { name, value in
            URLQueryItem(name: name, value: value)
        }
        components?.queryItems = items
        if let url = components?.url {
            return url
        }
        return self
    }
}
