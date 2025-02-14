//
//  FeedItem.swift
//  YaCocinaPeFeed
//
//  Created by Pablo Butron on 12/2/25.
//

import Foundation

public struct FeedItem: Equatable {
   public let idMeal: String
   public let strMeal: String
   public let strArea: String
   public let strDescription: String
   public let imageURL: URL
   public let strIngredient1: String
   public let strIngredient2: String
   public let strIngredient3: String
   public let strIngredient4: String
   public let strIngredient5: String
   public let strIngredient6: String
   public let strIngredient7: String
   public let strIngredient8: String
   public let strIngredient9: String
   public let strIngredient10: String
   public let strIngredient11: String
   public let strIngredient12: String
   public let strIngredient13: String
   public let strIngredient14: String
   public let strIngredient15: String
    
    public var ingredients: [String] {
           [strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
            strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
            strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15]
               .filter { !$0.isEmpty } 
       }
    
   public init(idMeal: String, strMeal: String, strArea: String, strDescription: String, imageURL: URL, strIngredient1: String, strIngredient2: String, strIngredient3: String, strIngredient4: String, strIngredient5: String, strIngredient6: String, strIngredient7: String, strIngredient8: String, strIngredient9: String, strIngredient10: String, strIngredient11: String, strIngredient12: String, strIngredient13: String, strIngredient14: String, strIngredient15: String) {
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strArea = strArea
        self.strDescription = strDescription
        self.imageURL = imageURL
        self.strIngredient1 = strIngredient1
        self.strIngredient2 = strIngredient2
        self.strIngredient3 = strIngredient3
        self.strIngredient4 = strIngredient4
        self.strIngredient5 = strIngredient5
        self.strIngredient6 = strIngredient6
        self.strIngredient7 = strIngredient7
        self.strIngredient8 = strIngredient8
        self.strIngredient9 = strIngredient9
        self.strIngredient10 = strIngredient10
        self.strIngredient11 = strIngredient11
        self.strIngredient12 = strIngredient12
        self.strIngredient13 = strIngredient13
        self.strIngredient14 = strIngredient14
        self.strIngredient15 = strIngredient15
    }
    
}
