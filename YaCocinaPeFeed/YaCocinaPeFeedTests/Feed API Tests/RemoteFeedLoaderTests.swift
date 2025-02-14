//
//  RemoteFeedLoaderTests.swift
//  YaCocinaPeFeedTests
//
//  Created by Pablo Butron on 12/2/25.
//

import XCTest
import YaCocinaPeFeed


final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataUponInitialization () {
        let (_, client) = makeSUT ()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_doesRequestDataFromURL () {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT (url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func testIngredientsPropertyFiltersOutEmptyIngredients() {
           let feedItem = FeedItem(
               idMeal: "1",
               strMeal: "Test Meal",
               strArea: "Test Area",
               strDescription: "A test description",
               imageURL: URL(string: "https://example.com/image.jpg")!,
               strIngredient1: "Chicken",
               strIngredient2: "",
               strIngredient3: "Salt",
               strIngredient4: "Pepper",
               strIngredient5: "",
               strIngredient6: "",
               strIngredient7: "",
               strIngredient8: "",
               strIngredient9: "",
               strIngredient10: "",
               strIngredient11: "",
               strIngredient12: "",
               strIngredient13: "",
               strIngredient14: "",
               strIngredient15: ""
           )
           
           let ingredients = feedItem.ingredients
           
           XCTAssertEqual(ingredients, ["Chicken", "Salt", "Pepper"], "The ingredients property should filter out empty strings and return only non-empty ingredients.")
       }
    
    func test_load_doesRequestDataFromURLTwice () {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT (url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "tests", code: 0)
            client.complete(withError: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let codes = [199, 201, 300, 400]
        
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index, data: makeJSON([]))
            })
        }
    }
    
    func test_load_deliversErrorOnInvalidJSONResponse() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid data".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversEmptyListOnEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSON = makeJSON([])
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
    }
    
    func test_load_deliversItemsOnValidJSONResponse() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(idMeal: "123",
                             strMeal: "A title of meal",
                             strArea: "a country",
                             strDescription: "A description",
                             imageURL: URL(string: "https://any-meat-url.com")!,
                             strIngredient1: "Ingredient1",
                             strIngredient2: "Ingredient2",
                             strIngredient3: "Ingredient3",
                             strIngredient4: "Ingredient4",
                             strIngredient5: "Ingredient5",
                             strIngredient6: "Ingredient6",
                             strIngredient7: "Ingredient7",
                             strIngredient8: "Ingredient8",
                             strIngredient9: "Ingredient9",
                             strIngredient10: "Ingredient10",
                             strIngredient11: "Ingredient11",
                             strIngredient12: "Ingredient12",
                             strIngredient13: "Ingredient13",
                             strIngredient14: "Ingredient14",
                             strIngredient15: "Ingredient15")
        
        let item2 = makeItem(idMeal: "1234",
                             strMeal: "Another title of meal",
                             strArea: "Another country",
                             strDescription: "Another description",
                             imageURL: URL(string: "https://another-meat-url.com")!,
                             strIngredient1: "Another Ingredient1",
                             strIngredient2: "Another Ingredient2",
                             strIngredient3: "Another Ingredient3",
                             strIngredient4: "Another Ingredient4",
                             strIngredient5: "Another Ingredient5",
                             strIngredient6: "Another Ingredient6",
                             strIngredient7: "Another Ingredient7",
                             strIngredient8: "Another Ingredient8",
                             strIngredient9: "Another Ingredient9",
                             strIngredient10: "Another Ingredient10",
                             strIngredient11: "Another Ingredient11",
                             strIngredient12: "Another Ingredient12",
                             strIngredient13: "Another Ingredient13",
                             strIngredient14: "Another Ingredient14",
                             strIngredient15: "Another Ingredient15")
        
        
        expect(sut, toCompleteWith: .success([item1.model, item2.model]), when: {
            let json = makeJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader (url: url, client: client)
        
        
        var receivedResults = [RemoteFeedLoader.Result]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeJSON([]))
        
        XCTAssertTrue(receivedResults.isEmpty )
        
    }
    
    //MARK: Helpers
    
    private func makeSUT (url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy ()
        let sut = RemoteFeedLoader (url: url, client: client)
        
        trackForMemoryLeaks(from: client)
        trackForMemoryLeaks(from: sut)
        
        return (sut, client)
    }
    
    private func failure (_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(idMeal: String,
                          strMeal: String,
                          strArea: String,
                          strDescription: String,
                          imageURL: URL,
                          strIngredient1: String,
                          strIngredient2: String,
                          strIngredient3: String,
                          strIngredient4: String,
                          strIngredient5: String,
                          strIngredient6: String,
                          strIngredient7: String,
                          strIngredient8: String,
                          strIngredient9: String,
                          strIngredient10: String,
                          strIngredient11: String,
                          strIngredient12: String,
                          strIngredient13: String,
                          strIngredient14: String,
                          strIngredient15: String) -> (model: FeedItem, json: [String: Any]){
        
        let item = FeedItem(idMeal: idMeal,
                            strMeal: strMeal,
                            strArea: strArea,
                            strDescription: strDescription,
                            imageURL: imageURL,
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
        
        
        let json = [
            "idMeal": idMeal,
            "strMeal": strMeal,
            "strArea": strArea,
            "strInstructions":strDescription,
            "strMealThumb": imageURL.absoluteString,
            "strIngredient1":strIngredient1,
            "strIngredient2": strIngredient2,
            "strIngredient3": strIngredient3,
            "strIngredient4": strIngredient4,
            "strIngredient5": strIngredient5,
            "strIngredient6": strIngredient6,
            "strIngredient7": strIngredient7,
            "strIngredient8": strIngredient8,
            "strIngredient9": strIngredient9,
            "strIngredient10": strIngredient10,
            "strIngredient11": strIngredient11,
            "strIngredient12": strIngredient12,
            "strIngredient13": strIngredient13,
            "strIngredient14": strIngredient14,
            "strIngredient15": strIngredient15
        ]
        
        return (item, json)
        
    }
    
    private func makeJSON (_ items: [[String: Any]]) -> Data {
        let json = ["meals": items]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect (_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void) {

          let exp = expectation(description: "wait for load completion")
          
          sut.load { receivedResult in
              switch (receivedResult, expectedResult) {
              case let (.success(receivedItems) , .success(expectedItems)):
                  XCTAssertEqual(receivedItems, expectedItems)
              case let (.failure(receivedError as RemoteFeedLoader.Error ), .failure(expectedError as RemoteFeedLoader.Error)):
                  XCTAssertEqual(receivedError, expectedError)
              default:
                  XCTFail("expected \(expectedResult), got \(receivedResult) instead")
              }
              exp.fulfill()
          }

          action ()

          wait(for: [exp], timeout: 1.0)
      }

    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0, data: Data) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
    
    
}
