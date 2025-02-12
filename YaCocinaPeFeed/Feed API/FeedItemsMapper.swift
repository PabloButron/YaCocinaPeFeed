//
//  FeedItemsMapper.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 12/2/25.
//

import Foundation


class FeedItemsMapper {

    struct Root: Decodable {
        let meals: [Item]

        struct Item: Decodable {
            let idMeal: String
            let strMeal: String
            let strArea: String
            let strInstructions: String
            let strMealThumb: URL
            let strIngredient1: String
            let strIngredient2: String
            let strIngredient3: String
            let strIngredient4: String
            let strIngredient5: String
            let strIngredient6: String
            let strIngredient7: String
            let strIngredient8: String
            let strIngredient9: String
            let strIngredient10: String
            let strIngredient11: String
            let strIngredient12: String
            let strIngredient13: String
            let strIngredient14: String
            let strIngredient15: String

            var item: FeedItem {
                return FeedItem(
                    idMeal: idMeal,
                    strMeal: strMeal,
                    strArea: strArea,
                    strDescription: strInstructions,
                    imageURL: strMealThumb,
                    strIngredient1: strIngredient1,
                    strIngredient2: strIngredient2,
                    strIngredient3: strIngredient3,
                    strIngredient4: strIngredient4,
                    strIngredient5: strIngredient5,
                    strIngredient6: strIngredient6,
                    strIngredient7: strIngredient7,
                    strIngredient8: strIngredient8,
                    strIngredient9: strIngredient9,
                    strIngredient10: strIngredient10,
                    strIngredient11: strIngredient11,
                    strIngredient12: strIngredient12,
                    strIngredient13: strIngredient13,
                    strIngredient14: strIngredient14,
                    strIngredient15: strIngredient15)
            }
        }
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200 else {
            return .failure(.invalidData)
        }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return .success(root.meals.map({ $0.item }))
        } catch  {
            return .failure(.invalidData)
        }
    }
}

