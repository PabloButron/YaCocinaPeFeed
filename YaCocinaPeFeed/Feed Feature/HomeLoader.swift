//
//  HomeLoader.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 13/2/25.
//

import Foundation

public enum LoadHomeResult {
    case success ([HomeItem])
    case failure (Error)
}
public protocol HomeLoader {
    func load (completion: @escaping (LoadHomeResult) -> Void )
}
