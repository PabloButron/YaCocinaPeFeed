//
//  RemoteFeedLoaderTests.swift
//  YaCocinaPeFeedTests
//
//  Created by Pablo Butron on 12/2/25.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL)
}
class RemoteFeedLoader {

    let url: URL
    let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load () {
        client.get(from: url)
    }
}



final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataUponInitialization () {
        let (_, client) = makeSUT ()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_doesRequestDataFromURL () {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT (url: url)
        
        sut.load ()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    //MARK: Helpers
    
    private func makeSUT (url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy ()
        let sut = RemoteFeedLoader (url: url, client: client)
        
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []

        func get(from url: URL) {
            requestedURLs.append(url)
        }
        
        
    }
}
