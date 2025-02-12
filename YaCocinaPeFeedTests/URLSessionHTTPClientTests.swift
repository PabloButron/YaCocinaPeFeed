//
//  URLSessionHTTPClientTests.swift
//  YaCocinaPeFeedTests
//
//  Created by Pablo Butron on 12/2/25.
//

import XCTest
import YaCocinaPeFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
}
final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_failsOnRequestError () {
        
        URLProtocolStub.startInterceptingRequest()
        let url = URL (string: "https://a-url.com")!
        let requestError = NSError(domain: "Any domain", code: 1)
        
        URLProtocolStub.stub(url: url, error: requestError)
        let sut = URLSessionHTTPClient ()
        
        let exp = expectation(description: "Wait for request completion")
        
        sut.get(from: url) { result in
            switch result {
            case .failure (let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, requestError.domain)
                XCTAssertEqual(receivedError.code, requestError.code)
            default:
                XCTFail(" expected \(requestError), but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        URLProtocolStub.stopInterceptingRequest()
    }
    
    
    //MARK: Helpers
    
    class URLProtocolStub: URLProtocol {
        
        static var stubs = [URL: Stub] ()
        
        struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        
        static func startInterceptingRequest () {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest () {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
        
    }
}
