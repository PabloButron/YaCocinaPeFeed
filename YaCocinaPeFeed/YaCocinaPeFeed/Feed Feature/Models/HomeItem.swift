//
//  HomeItem.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 13/2/25.
//

import Foundation

public struct HomeItem: Identifiable, Equatable {
    public let idMeal: String
    public let strMeal: String
    public let strMealThumb: URL

    public var id: String { 
        return idMeal
    }
    
    public init(idMeal: String, strMeal: String, strMealThumb: URL) {
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strMealThumb = strMealThumb
    }
    
}
