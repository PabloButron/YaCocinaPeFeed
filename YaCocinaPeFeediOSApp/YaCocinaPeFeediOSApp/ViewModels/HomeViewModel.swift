//
//  HomeViewModel.swift
//  YaCocinaPeFeediOSApp
//
//  Created by Pablo Butron on 14/2/25.
//

import Foundation
import YaCocinaPeFeed

enum SearchType {
    case ingredient
    case recipeName
}

class HomeViewModel: ObservableObject {
    @Published var meals = [HomeItem]()
    @Published var searchQuery: String = ""
    @Published var searchType: SearchType = .ingredient
    @Published var isNotFound: Bool = false


    func loadMeals() async {
        await fetchMeals(from: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood")
    }
    
    func searchMeals() async {
        guard !searchQuery.isEmpty else { return }
        let endpoint = searchType == .ingredient ?
        "https://www.themealdb.com/api/json/v1/1/filter.php?i=\(searchQuery)" :
        "https://www.themealdb.com/api/json/v1/1/search.php?s=\(searchQuery)"
        
        await fetchMeals(from: endpoint)
    }
    
    private func fetchMeals(from urlString: String) async {
        do {
            guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
            
            let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
            let loader = RemoteHomeLoader(url: url, client: client)
            
            let items = try await withCheckedThrowingContinuation { continuation in
                loader.load { result in
                    switch result {
                    case .success(let items):
                        continuation.resume(returning: items)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    @unknown default:
                        print("Default case hit")
                    }
                }
            }
            DispatchQueue.main.sync {
                if items.isEmpty {
                    self.meals = []
                    self.isNotFound = true
                } else {
                    self.meals = items
                    self.isNotFound = false
                }
            }
        } catch {
            DispatchQueue.main.sync {
                self.meals = []
                self.isNotFound = true
            }
        }
    }
    
}

