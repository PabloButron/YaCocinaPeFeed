//
//  FeedLoader.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 12/2/25.
//

import Foundation
public enum LoadFeedResult {
    case success ([FeedItem])
    case failure (Error)
}
public protocol FeedLoader {
    func load (completion: @escaping (LoadFeedResult) -> Void )
}
