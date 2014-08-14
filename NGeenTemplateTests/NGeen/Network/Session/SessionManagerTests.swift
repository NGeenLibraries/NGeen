//
// SessionManagerTests.swift
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

import XCTest

class SessionManagerTests: XCTestCase {
    
    var session: SessionManager?
    
    override func setUp() {
        super.setUp()
        self.session = SessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
        self.session!.responseDisposition = NSURLSessionResponseDisposition.Allow
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.session = nil
    }
    
    func testThatDownloadTask() {
        let expectation: XCTestExpectation = expectationWithDescription("download task")
        let docsDir: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let destination: NSURL = NSURL(fileURLWithPath: "\(docsDir)/download.txt")
        let request: NSURLRequest = NSURLRequest(URL: NSURL.URLWithString("/stream/\(100)", relativeToURL: kTestUrl))
        let task = self.session!.downloadTaskWithRequest(request, destination: destination, progress: nil, completionHandler: {(data, urlResponse, error) in
            var isDirectory: UnsafeMutablePointer<ObjCBool> = nil
            NSFileManager.defaultManager().fileExistsAtPath(destination.description, isDirectory: isDirectory)
            XCTAssert(isDirectory == nil, "The file should exists", file: __FUNCTION__, line: __LINE__)
            expectation.fulfill()
        })
        task.resume()
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testThatTaskInvokeBlock() {
        let expectation: XCTestExpectation = self.expectationWithDescription("invoke block")
        let request: NSURLRequest = NSURLRequest(URL: NSURL.URLWithString("/get", relativeToURL: kTestUrl))
        let task = self.session!.dataTaskWithRequest(request, completionHandler: {(data, urlResponse, error) in
            XCTAssertNil(error, "The error should be nil", file: __FILE__, line: __LINE__)
            expectation.fulfill()
        })
        task.resume()
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testThatUploadTask() {
        let expectation: XCTestExpectation = expectationWithDescription("upload task")
        let request: NSURLRequest = NSURLRequest(URL: NSURL.URLWithString("/post", relativeToURL: kTestUrl))
        let URL: NSURL = NSURL(string: "http://httpbin.org/post")
        let data: NSData = "Lorem ipsum dolor sit amet".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let task = self.session!.uploadTaskWithRequest(request, data: data, progress: nil, completionHandler: {(data, urlResponse, error) in
            XCTAssertNil(error, "error should be nil", file: __FUNCTION__, line: __LINE__)
            expectation.fulfill()
        })
        task.resume()
        waitForExpectationsWithTimeout(10, handler: nil)
    }

}
