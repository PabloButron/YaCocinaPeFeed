//
//  DetailViewModel.swift
//  YaCocinaPeFeediOSApp
//
//  Created by Pablo Butron on 14/2/25.
//

import Foundation
@preconcurrency import YaCocinaPeFeed

class DetailViewModel: ObservableObject {
    @Published var meal: FeedItem?
    
    @MainActor
    func loadMealDetails(id: String) {
        Task {
            let serverURL = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)")!
            let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
            let loader = RemoteFeedLoader(url: serverURL, client: client)
            
            do {
                let result: [FeedItem] = try await withCheckedThrowingContinuation { continuation in
                    loader.load { response in
                        switch response {
                        case .success(let items):
                            continuation.resume(returning: items)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        default:
                            print("nil value found")
                        }
                    }
                }
                meal = result.first
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
