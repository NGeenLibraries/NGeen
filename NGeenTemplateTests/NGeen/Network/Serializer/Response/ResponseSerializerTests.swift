//
// ResponseSerializerTests.swift
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

import UIKit
import XCTest

class Test: Model {
    var foo: String = ""
    var foo1: String = ""
}

class ResponseSerializerTests: XCTestCase {

    var responseSerializer: ResponseSerializer?
    
    override func setUp() {
        super.setUp()
        self.responseSerializer = ResponseSerializer()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.responseSerializer = nil
    }
    
    func testThatResponseInJsonFormat() {
        let data: NSData = NSJSONSerialization.dataWithJSONObject(["foo": "bar", "foo1": "bar1"], options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        let validJson: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let response: NSDictionary = self.responseSerializer!.responseInJSONFormatForData(data, error: nil) as NSDictionary
        XCTAssert(response.isEqual(validJson) , "The json response is not valid", file: __FILE__, line: __LINE__)
    }
    
    func testThatResponseInModelsFormat() {
        let expectation: XCTestExpectation = self.expectationWithDescription("model serialization block")
        let data: NSData = NSJSONSerialization.dataWithJSONObject(["foo": "bar", "foo1": "bar1", "models": [["foo": "bar", "foo1": "bar1"]]], options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        let response = self.responseSerializer!.responseInModelsForData(data, modelClass: Test.self, modelsPath: "models", error: nil)
        let models: Array<Test> = response["models"]! as Array
        let test: Test = models.first!
        XCTAssertEqual(test.foo, "bar", "the foo var value should be equal to bar", file: __FILE__, line: __LINE__)
        XCTAssertEqual(test.foo1, "bar1", "the foo1 var value should be equal to bar1", file: __FILE__, line: __LINE__)
        expectation.fulfill()
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testThatResponseInStringFormat() {
        let data: NSData = NSJSONSerialization.dataWithJSONObject(["foo": "bar", "foo1": "bar1"], options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        let validString: NSString = NSString(data: data, encoding: NSUTF8StringEncoding)
        let response: NSString = self.responseSerializer!.responseInStringFormatForData(data, error: nil)
        XCTAssert(response.isKindOfClass(NSString.self), "The response should be string class", file: __FILE__, line: __LINE__)
        XCTAssertEqual(response, validString, "The response should be equal to \(validString)", file: __FILE__, line: __LINE__)
    }
}
