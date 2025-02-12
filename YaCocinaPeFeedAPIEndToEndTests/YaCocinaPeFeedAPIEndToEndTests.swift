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
        let serverURL = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=Arrabiata")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: serverURL, client: client)
        var receivedResult: LoadFeedResult?
        
        let exp = expectation(description: "Wait for completion")
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)
        
        switch receivedResult {
        case .success(let feed):
            XCTAssertEqual(feed.count, 1, "expected 8 items in the test accound feed")
        case .failure(let error):
            XCTFail("expected success got \(error) instead")
        default:
            XCTFail("expected success got no result instead")
        }
    }
}
