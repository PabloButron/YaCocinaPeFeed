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
    
    struct UnexpectedValuesRepresentation: Error {    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
    
}


final class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
   func test_getFromURL_failsOnRequestError () {
       let requestError = anyNSError()
       let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
       
       XCTAssertEqual(receivedError?.domain, requestError.domain)
       XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidCasesRepresentation () {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithEmtyData () {
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        let exp = expectation(description: "Wait for request completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .success(let receivedData, let receivedReponse):
                let emptyData = Data()
                XCTAssertEqual(receivedData, emptyData)
                XCTAssertEqual(receivedReponse.statusCode, response.statusCode)
                XCTAssertEqual(receivedReponse.url, response.url)
            default:
                XCTFail("Expected success, but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData () {
        let data = anyData()
        let response = anyHTTPURLResponse()
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "Wait for request completion")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .success(let receivedData, let receivedReponse):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedReponse.statusCode, response.statusCode)
                XCTAssertEqual(receivedReponse.url, response.url)
            default:
                XCTFail("Expected success, but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: Helpers
    
    private func makeSUT () -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient ()
        trackForMemoryLeaks(from: sut)
        return sut
    }
    
    private func resultErrorFor (data: Data?, response: URLResponse?, error: Error?) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for request completion")
        var receivedError: Error?
       makeSUT().get(from: anyURL()) { result in
            switch result {
            case .failure (let error):
                receivedError = error
            default:
                XCTFail(" expected failure, but got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func anyURL () -> URL {
        return URL (string: "https://a-url.com")!
    }
    
    private func anyData () -> Data {
        return Data("any data".utf8)
    }
    
    private func anyNSError () -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func anyHTTPURLResponse () -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse () -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    class URLProtocolStub: URLProtocol {
        
        static var stub: Stub?
        static var requestObserver: ((URLRequest) -> Void)?
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
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
