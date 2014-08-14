//
// RequestSerializerTests.swift
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

class RequestSerializerTests: XCTestCase {

    var apiConfiguration: ApiStoreConfiguration?
    var requestSerializer: RequestSerializer?
    
    override func setUp() {
        super.setUp()
        self.apiConfiguration = ApiStoreConfiguration()
        self.apiConfiguration!.bodyItems = ["foo": "bar", "foo1": "bar1"]
        self.requestSerializer = RequestSerializer()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.apiConfiguration = nil
        self.requestSerializer = nil
    }
    
    func testThatSerializationInUrlFormFormat() {
        let endPoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.post, path: "example")
        let request: NSURLRequest = self.requestSerializer!.requestSerializingInUrlencodedWithConfiguration(self.apiConfiguration!, endPoint: endPoint)
        let body: String = NSString(data: request.HTTPBody, encoding: NSUTF8StringEncoding)
        XCTAssertEqual(body, "foo=bar&foo1=bar1", "The serialization should be foo=bar&foo1=bar1", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSerializationInUrlFormFormatWithAnyObjects() {
        self.apiConfiguration!.bodyItems = ["foo": "bar", "baz": ["a", 1], "qux": ["x": 1, "y": 2, "z": 3]]
        let endPoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.post, path: "example")
        let request: NSURLRequest = self.requestSerializer!.requestSerializingInUrlencodedWithConfiguration(self.apiConfiguration!, endPoint: endPoint)
        let body: String = NSString(data: request.HTTPBody, encoding: NSUTF8StringEncoding)
        XCTAssertEqual(body, "baz[0]=a&baz[1]=1&foo=bar&qux[z]=3&qux[x]=1&qux[y]=2", "The serialization should be baz[0]=a&baz[1]=1&foo=bar&qux[z]=3&qux[x]=1&qux[y]=2", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSerializationInJSONFormat() {
        let endPoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.post, path: "example")
        let validJson: String = NSString(data: NSJSONSerialization.dataWithJSONObject(["foo": "bar", "foo1": "bar1"], options: NSJSONWritingOptions.PrettyPrinted, error: nil), encoding: NSUTF8StringEncoding)
        let request: NSURLRequest = self.requestSerializer!.requestSerializingInJSONFormatWithConfiguration(self.apiConfiguration!, endPoint: endPoint, error: nil)
        let body: String = NSString(data: request.HTTPBody, encoding: NSUTF8StringEncoding)
        XCTAssertEqual(body, validJson, "The serialization should be {\"key\" : \"value\"}", file: __FUNCTION__, line: __LINE__)
    }
}
