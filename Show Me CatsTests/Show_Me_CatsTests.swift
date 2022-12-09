//
//  Show_Me_CatsTests.swift
//  Show Me CatsTests
//
//  Created by Jason Stelzel on 12/9/22.
//

import XCTest
@testable import Show_Me_Cats

final class Show_Me_CatsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    func test_init_doesNotRequestDataFromURL() {
        let sut = makeSUT()
                
        XCTAssertTrue(sut.requestedURLs.isEmpty)
    }
    
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let sut = makeSUT(url: url)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(sut.requestedURLs, [url])
    }

    
    
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> HTTPClientSpy {
        let sut = HTTPClientSpy()
        trackForMemoryLeaks(sut, file: #filePath, line: #line)
        trackForMemoryLeaks(sut, file: #filePath, line: #line)
        return sut
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
    
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
        
        
    }


}



extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
         }
    }
    
    
}
