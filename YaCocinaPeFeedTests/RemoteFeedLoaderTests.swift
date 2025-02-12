//
//  RemoteFeedLoaderTests.swift
//  YaCocinaPeFeedTests
//
//  Created by Pablo Butron on 12/2/25.
//

import XCTest

protocol HTTPClient {
    
}
class RemoteFeedLoader {
    
}



final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataUponInitialization () {
        let (sut, client) = makeSUT ()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT () -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let sut = RemoteFeedLoader ()
        let client = HTTPClientSpy ()
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        
    }
}
