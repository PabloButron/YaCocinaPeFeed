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

    func test_getFromURL_performsGETRequestWithURL() {
        URLProtocolStub.startInterceptingRequest()
        
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
        
        URLProtocolStub.stopInterceptingRequest()
    }
    
   func test_getFromURL_failsOnRequestError () {
        
        URLProtocolStub.startInterceptingRequest()
        let url = URL (string: "https://a-url.com")!
        let requestError = NSError(domain: "Any domain", code: 1)
        
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: requestError)
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
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    
    //MARK: Helpers
    
    class URLProtocolStub: URLProtocol {
        
        static var stub: Stub?
        static var requestObserver: ((URLRequest) -> Void)?
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest (observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequest () {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest () {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLSessionHTTPClientTests.URLProtocolStub.stub?.data{
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLSessionHTTPClientTests.URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLSessionHTTPClientTests.URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
        
    }
}
