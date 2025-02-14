//
//  HomeFeedLoaderTests.swift
//  YaCocinaPeFeedTests
//
//  Created by Pablo Butron on 14/2/25.
//

import XCTest
import YaCocinaPeFeed

final class HomeFeedLoaderTests: XCTestCase {

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
    
    func testIdReturnsIdMeal() {
     
        let expectedMealID = "12345"
        let sampleMealName = "Test Meal"
        let sampleMealThumb = URL(string: "https://example.com/image.jpg")!
        let homeItem = HomeItem(idMeal: expectedMealID, strMeal: sampleMealName, strMealThumb: sampleMealThumb)
        
        let idValue = homeItem.id
        

        XCTAssertEqual(idValue, expectedMealID, "The computed property 'id' should return the value of 'idMeal'")
    }
    
    func test_load_deliversItemsOnValidJSONResponse() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(idMeal: "123", strMeal: "a meal", strMealThumb: URL(string: "https://any-meat-url.com")!)
        let item2 = makeItem(idMeal: "1234", strMeal: "another meal", strMealThumb: URL(string: "https://even-other-meat-url.com")!)
        
        expect(sut, toCompleteWith: .success([item1.model, item2.model]), when: {
            let json = makeJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
//MARK: Helpers
    
    private func makeSUT (url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteHomeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy ()
        let sut = RemoteHomeLoader (url: url, client: client)
        
        trackForMemoryLeaks(from: client)
        trackForMemoryLeaks(from: sut)
        
        return (sut, client)
    }
    
    private func makeJSON (_ items: [[String: Any]]) -> Data {
        let json = ["meals": items]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem (idMeal: String, strMeal: String, strMealThumb: URL) -> (model: HomeItem, json: [String: Any]){
        let item = HomeItem(idMeal: idMeal, strMeal: strMeal, strMealThumb: strMealThumb)
        let json = [
            "idMeal": idMeal,
            "strMeal": strMeal,
            "strMealThumb": strMealThumb.absoluteString
        ]
        return (item, json)
    }
    
    private func failure (_ error: RemoteHomeLoader.Error) -> RemoteHomeLoader.Result {
        return .failure(error)
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
    
    private func expect (_ sut: RemoteHomeLoader, toCompleteWith expectedResult: RemoteHomeLoader.Result, when action: () -> Void) {

          let exp = expectation(description: "wait for load completion")
          
          sut.load { receivedResult in
              switch (receivedResult, expectedResult) {
              case let (.success(receivedItems) , .success(expectedItems)):
                  XCTAssertEqual(receivedItems, expectedItems)
              case let (.failure(receivedError as RemoteHomeLoader.Error ), .failure(expectedError as RemoteHomeLoader.Error)):
                  XCTAssertEqual(receivedError, expectedError)
              default:
                  XCTFail("expected \(expectedResult), got \(receivedResult) instead")
              }
              exp.fulfill()
          }

          action ()

          wait(for: [exp], timeout: 1.0)
      }
    
}
