//
//  HomeItemsMapper.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 13/2/25.
//

import Foundation

public final class HomeItemsMapper {
    
    struct Root: Decodable {
        let meals: [Item]
        
        struct Item: Decodable {
            let idMeal: String
            let strMeal: String
            let strMealThumb: URL
            
            var item: HomeItem {
                return HomeItem(idMeal: idMeal, strMeal: strMeal, strMealThumb: strMealThumb)
            }
        }
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) -> RemoteHomeLoader.Result {
        
        guard response.statusCode == 200 else {
            return .failure(RemoteHomeLoader.Error.invalidData)
        }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return .success(root.meals.map({ $0.item }))
        } catch{
            return .failure(RemoteHomeLoader.Error.invalidData)
        }
    }
    
}

