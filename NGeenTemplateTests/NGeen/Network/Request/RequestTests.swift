//
// RequestTests.swift
// Copyright (c) 2014 NGeen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import XCTest

class RequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatHttpHeaders() {
        let request: Request = Request(httpMethod: HttpMethod.get.toRaw(), url: kTestUrl)
        request.setValue("", forHTTPHeaderField: "")
        XCTAssertNotNil(request.httpHeaders(), "The expected value should be a dictionary", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSendAsynchronous() {
        let expectation: XCTestExpectation = self.expectationWithDescription("request end")
        let request: Request = Request(httpMethod: HttpMethod.get.toRaw(), url: NSURL(string: "get", relativeToURL: kTestUrl))
        request.setValue(ContentType.json.toRaw(), forHTTPHeaderField: "Content-Type")
        request.sendAsynchronous({(data, urlResponse, error) in
            let httpUrlResponse: NSHTTPURLResponse = urlResponse as NSHTTPURLResponse
            XCTAssertEqual(httpUrlResponse.statusCode, 200, "Expected a status completed", file: __FUNCTION__, line: __LINE__)
            expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testThatSendAsynchronousWithBasicAuthentication() {
        let credential: NSURLCredential = NSURLCredential(user: "user", password: "passwd", persistence: NSURLCredentialPersistence.ForSession)
        let protectionSpace: NSURLProtectionSpace = NSURLProtectionSpace(host: "httpbin.org", port: 0, `protocol`: "https", realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
        let expectation: XCTestExpectation = self.expectationWithDescription("request end")
        let request: Request = Request(httpMethod: HttpMethod.get.toRaw(), url: NSURL(string: "get", relativeToURL: kTestUrl))
        request.setAuthenticationCredential(credential, forProtectionSpace: protectionSpace)
        request.setValue(ContentType.json.toRaw(), forHTTPHeaderField: "Content-Type")
        request.sendAsynchronous({(data, urlResponse, error) in
            let httpUrlResponse: NSHTTPURLResponse = urlResponse as NSHTTPURLResponse
            XCTAssertEqual(httpUrlResponse.statusCode, 200, "Expected a status completed", file: __FUNCTION__, line: __LINE__)
            expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testThatSendAsynchronousWithInvalidBasicAuthentication() {
        let expectation: XCTestExpectation = self.expectationWithDescription("request end")
        let request: Request = Request(httpMethod: HttpMethod.get.toRaw(), url: NSURL(string: "\(kTestUrl)/basic-auth/:user/:passwd"))
        request.setValue(ContentType.json.toRaw(), forHTTPHeaderField: "Content-Type")
        request.sendAsynchronous({(data, urlResponse, error) in
            let httpUrlResponse: NSHTTPURLResponse = urlResponse as NSHTTPURLResponse
            XCTAssertEqual(httpUrlResponse.statusCode, 401, "Expected a 401 response code", file: __FUNCTION__, line: __LINE__)
            expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testThatSetValueForHTTPHeaderField() {
        let request: Request = Request(httpMethod: HttpMethod.get.toRaw(), url: NSURL(string: "http://test:test@kbcore-api.herokuapp.com/api/v1/items"))
        request.setValue("", forHTTPHeaderField: "")
        XCTAssert(request.httpHeaders().count > 0, "The headers should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }

}
