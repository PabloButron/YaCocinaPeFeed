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
    func test_load_doesRequestDataFromURLTwice () {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT (url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var receivedResponses = [RemoteFeedLoader.Error]()
        
        sut.load { receivedResponses.append($0) }
        let clientError = NSError(domain: "tests", code: 0)
        client.complete(withError: clientError)
        
        XCTAssertEqual(receivedResponses, [.connectivity])
    }
    
    //MARK: Helpers
    
    private func makeSUT (url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy ()
        let sut = RemoteFeedLoader (url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (Error) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}
