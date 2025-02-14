//
//  RemoteHomeLoader.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 13/2/25.
//

import Foundation

public final class RemoteHomeLoader: HomeLoader {
    private let url: URL
    private let client: HTTPClient

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = LoadHomeResult

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data, let response):
                completion(HomeItemsMapper.map(data, response: response))
            case .failure:
                completion(.failure(RemoteHomeLoader.Error.connectivity))
            }
        }
    }
}

