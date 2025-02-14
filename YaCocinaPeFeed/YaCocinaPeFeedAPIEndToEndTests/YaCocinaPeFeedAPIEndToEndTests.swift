//
//  YaCocinaPeFeedAPIEndToEndTests.swift
//  YaCocinaPeFeedAPIEndToEndTests
//
//  Created by Pablo Butron on 12/2/25.
//

import XCTest
import YaCocinaPeFeed

final class YaCocinaPeFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData (){
        
        switch getFeedResult () {
        case .success(let items):
            XCTAssertEqual(items.count, 1, "expected 1 item in the test accound feed")
            XCTAssertEqual(items[0], expectedItem(at: 0))
            
        case .failure(let error):
            XCTFail("expected success got \(error) instead")
            
        default:
            XCTFail("expected success got no result instead")
        }
    }
    //MARK: Helpers
    
    private func getFeedResult () -> LoadFeedResult? {
        let serverURL = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=Arrabiata")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: serverURL, client: client)
        
        trackForMemoryLeaks(from: client)
        trackForMemoryLeaks(from: loader)
        var receivedResult: LoadFeedResult?
        
        let exp = expectation(description: "Wait for completion")
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        return receivedResult
    }
    
    
    private func expectedItem(at index: Int) -> FeedItem {
        return FeedItem(idMeal: "52771",
                        strMeal: "Spicy Arrabiata Penne",
                        strArea: "Italian",
                        strDescription: "Bring a large pot of water to a boil. Add kosher salt to the boiling water, then add the pasta. Cook according to the package instructions, about 9 minutes.\r\nIn a large skillet over medium-high heat, add the olive oil and heat until the oil starts to shimmer. Add the garlic and cook, stirring, until fragrant, 1 to 2 minutes. Add the chopped tomatoes, red chile flakes, Italian seasoning and salt and pepper to taste. Bring to a boil and cook for 5 minutes. Remove from the heat and add the chopped basil.\r\nDrain the pasta and add it to the sauce. Garnish with Parmigiano-Reggiano flakes and more basil and serve warm.",
                        imageURL: URL(string: "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg")!,
                        strIngredient1: "penne rigate",
                        strIngredient2: "olive oil",
                        strIngredient3: "garlic",
                        strIngredient4: "chopped tomatoes",
                        strIngredient5:  "red chilli flakes",
                        strIngredient6: "italian seasoning",
                        strIngredient7: "basil",
                        strIngredient8: "Parmigiano-Reggiano",
                        strIngredient9: "",
                        strIngredient10: "",
                        strIngredient11: "",
                        strIngredient12: "",
                        strIngredient13: "",
                        strIngredient14: "",
                        strIngredient15: "")
    }
    
    
    
}
