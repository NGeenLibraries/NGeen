//
// ApiQuery.swift
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

class ApiQueryTests: XCTestCase {

    var apiQuery: ApiQuery?
    
    override func setUp() {
        super.setUp()
        let endPoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "example")
        self.apiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: endPoint)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.apiQuery = nil
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testThatBodyInJsonFormat() {
        let validJson: String = NSString(data: NSJSONSerialization.dataWithJSONObject(["key1": "foo1"], options: NSJSONWritingOptions.PrettyPrinted, error: nil), encoding: NSUTF8StringEncoding)
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.post, path: ""))
        apiQuery.setBodyItem("foo1", forKey: "key1")
        XCTAssertEqual(apiQuery.getBody(), validJson, "The body should be {\"key\" : \"value\"}", file: __FUNCTION__, line: __LINE__)
    }
    
    /*func testThatBodyInMultipartFormat() {
        let data: NSData = "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint(contentType: ContentType.multiPartForm, httpMethod: HttpMethod.post, path: ""))
        apiQuery.setBodyItem("test", forKey: "name")
        apiQuery.setFileData(data, forName: "icon", fileName: "icon.png", mimeType: "image/png")
        let validMultipartForm: String = "--Boundary+\(apiQuery.currentTime)\r\nContent-Disposition: form-data; name=\"icon\"; filename=\"icon.png\"\r\n Content-Type: image/png\r\n\r\n <6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d20 6c6f7265 6d206970 73756d>\r\n--Boundary+\(apiQuery.currentTime)\r\n Content-Disposition: form-data; name=\"name\"\r\n\r\n test\r\n--Boundary+\(apiQuery.currentTime)\r\n--"
        XCTAssertEqual(apiQuery.body().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), validMultipartForm.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), "The body should be \(validMultipartForm)", file: __FUNCTION__, line: __LINE__)
    }*/
    
    func testThatBodyInUrlFormFormat() {
        let endPoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.get, path: "example")
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: endPoint)
        apiQuery.setBodyItem("foo1", forKey: "key1")
        XCTAssertEqual(apiQuery.getBody(), "key1=foo1", "The body should be key1=foo1", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatPathWithEndPoint() {
        let endPoint: ApiEndpoint =  ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.post, path: "/get")
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: endPoint)
        apiQuery.setPathItem("1", forKey: "key1")
        apiQuery.setPathItem("2", forKey: "key2")
        XCTAssertEqual(apiQuery.getPath(), "/get/1/2", "The path should be /get/1/2", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatPathWithEmptyEndPointPath() {
        let endPoint: ApiEndpoint =  ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.post, path: "")
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: endPoint)
        apiQuery.setPathItem("1", forKey: "key1")
        apiQuery.setPathItem("2", forKey: "key2")
        XCTAssertEqual(apiQuery.getPath(), "/1/2", "The path should be 1/2", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatQuery() {
        self.apiQuery!.setQueryItem("value1", forKey: "key1")
        self.apiQuery!.setQueryItem("value2", forKey: "key2")
        if let query: String = self.apiQuery!.getQuery() {
            XCTAssertEqual(query, "key1=value1&key2=value2", "The query should be key1=value1&key2=value2", file: __FUNCTION__, line: __LINE__)
        } else {
            XCTFail("The query should not be nil", file: __FUNCTION__, line: __LINE__)
        }
    }
    
    func testThatSetCachePolicy() {
        self.apiQuery!.setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad)
        XCTAssertEqual(self.apiQuery!.getCachePolicy(), NSURLRequestCachePolicy.ReturnCacheDataElseLoad, "The cache policy should be equal to ReturnCacheDataElseLoad", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetCacheStoragePolicy() {
        self.apiQuery!.setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed)
        XCTAssertEqual(self.apiQuery!.getCacheStoragePolicy(), NSURLCacheStoragePolicy.Allowed, "The cache storage policy should be equal to Allowed", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetBodyItem() {
        self.apiQuery!.setBodyItem("", forKey: "")
        XCTAssert(self.apiQuery!.getBodyItems().count > 0, "The body items should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetHeader() {
        self.apiQuery!.setHeader("", forKey: "")
        XCTAssert(self.apiQuery!.getHttpHeaders().count > 0, "The headers should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetHeaders() {
        self.apiQuery!.setHeaders(["": ""])
        XCTAssert(self.apiQuery!.getHttpHeaders().count > 0, "The headers should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetModelsPath() {
        self.apiQuery!.setModelsPath("model.test")
        XCTAssertEqual(self.apiQuery!.getModelsPath(), "model.test", "The models path should be equal to model.test", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetPathItem() {
        self.apiQuery!.setPathItem("", forKey: "")
        XCTAssert(self.apiQuery!.getPathItems().count > 0, "The path items should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetPathItems() {
        self.apiQuery!.setPathItem("1", forKey: "key1")
        self.apiQuery!.setPathItem("2", forKey: "key2")
        self.apiQuery!.setPathItems(["key3": "3"])
        XCTAssertEqual(self.apiQuery!.getPath(), "example/1/2/3", "The path should be example/1/2/3", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetQueryItems() {
        self.apiQuery!.setQueryItem("value1", forKey: "key1")
        self.apiQuery!.setQueryItem("value2", forKey: "key2")
        self.apiQuery!.setQueryItems(["key3": "value3"])
        if let query: String = self.apiQuery!.getQuery() {
            XCTAssertEqual(query, "key1=value1&key2=value2&key3=value3", "The query should be key1=value1&key2=value2&key3=value3", file: __FUNCTION__, line: __LINE__)
        } else {
            XCTFail("The query should not be nil", file: __FUNCTION__, line: __LINE__)
        }
    }
    
    func testThatSetQueryItemsWithAnyObjects() {
        let parameters: Dictionary<String, AnyObject> = ["foo": "bar", "baz": ["a", 1], "qux": ["x": 1, "y": 2, "z": 3]]
        self.apiQuery!.setQueryItems(parameters)
        if let query: String = self.apiQuery!.getQuery() {
            XCTAssertEqual(query, "baz[0]=a&baz[1]=1&foo=bar&qux[z]=3&qux[x]=1&qux[y]=2", "The query should be baz[0]=a&baz[1]=1&foo=bar&qux[z]=3&qux[x]=1&qux[y]=2", file: __FUNCTION__, line: __LINE__)
        } else {
            XCTFail("The query should not be nil", file: __FUNCTION__, line: __LINE__)
        }
    }

    func testThatSetResponseDisposition() {
        self.apiQuery!.setResponseDisposition(NSURLSessionResponseDisposition.Cancel)
        XCTAssertEqual(self.apiQuery!.getResponseDisposition(), NSURLSessionResponseDisposition.Cancel, "The response disposition should be cancel", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseType() {
        self.apiQuery!.setResponseType(ResponseType.dictionary)
        XCTAssert(self.apiQuery!.getResponseType() != ResponseType.data, "The response type should be different than response type data", file: __FILE__, line: __LINE__)
    }
    
}
