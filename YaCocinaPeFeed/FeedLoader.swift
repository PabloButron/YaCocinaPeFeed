//
//  FeedLoader.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 12/2/25.
//

import Foundation
enum LoadFeedResult {
    case success ([FeedItem])
    case failure (Error)
}
protocol FeedLoader {
    func load (completion: @escaping (LoadFeedResult) -> Void )
}
