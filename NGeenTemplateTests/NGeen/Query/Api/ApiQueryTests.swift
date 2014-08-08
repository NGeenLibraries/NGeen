//
//  ApiQuery.swift
//  NGeenTemplate
//
//  Created by NGeen on 6/27/14.
//  Copyright (c) 2014 NGeen. All rights reserved.
//

import XCTest

class ApiQueryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
        XCTAssertEqual(apiQuery.body(), validJson, "The body should be {\"key\" : \"value\"}", file: __FUNCTION__, line: __LINE__)
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
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint(contentType: ContentType.urlEnconded, httpMethod: HttpMethod.post, path: ""))
        apiQuery.setBodyItem("foo1", forKey: "key1")
        XCTAssertEqual(apiQuery.body(), "key1=foo1", "The body should be key1=foo1", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatPathWithEndPoint() {
        let endPoint: ApiEndpoint =  ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.post, path: "/get")
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: endPoint)
        apiQuery.setPathItem("1", forKey: "key1")
        apiQuery.setPathItem("2", forKey: "key2")
        XCTAssertEqual(apiQuery.path(), "/get/1/2", "The path should be /get/1/2", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatPathWithEmptyEndPointPath() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setPathItem("1", forKey: "key1")
        apiQuery.setPathItem("2", forKey: "key2")
        XCTAssertEqual(apiQuery.path(), "/1/2", "The path should be 1/2", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatQuery() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setQueryItem("value1", forKey: "key1")
        apiQuery.setQueryItem("value2", forKey: "key2")
        XCTAssertEqual(apiQuery.query(), "key1=value1&key2=value2", "The query should be value=key", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetCachePolicy() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad)
        XCTAssertEqual(apiQuery.cachePolicy(), NSURLRequestCachePolicy.ReturnCacheDataElseLoad, "The cache policy should be equal to ReturnCacheDataElseLoad", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetCacheStoragePolicy() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed)
        XCTAssertEqual(apiQuery.cacheStoragePolicy(), NSURLCacheStoragePolicy.Allowed, "The cache storage policy should be equal to Allowed", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetBodyItem() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setBodyItem("", forKey: "")
        XCTAssert(apiQuery.bodyItems().count > 0, "The body items should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetHeader() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setHeader("", forKey: "")
        XCTAssert(apiQuery.httpHeaders().count > 0, "The headers should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetHeaders() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setHeaders(["": ""])
        XCTAssert(apiQuery.httpHeaders().count > 0, "The headers should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetModelsPath() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setModelsPath("model.test")
        XCTAssertEqual(apiQuery.modelsPath(), "model.test", "The models path should be equal to model.test", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetPathItem() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setPathItem("", forKey: "")
        XCTAssert(apiQuery.pathItems().count > 0, "The path items should have 1 more item", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetPathItems() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setPathItem("1", forKey: "key1")
        apiQuery.setPathItem("2", forKey: "key2")
        apiQuery.setPathItems(["key3": "3"])
        XCTAssertEqual(apiQuery.path(), "/1/2/3", "The path should be /1/2/3", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetQueryItems() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setQueryItem("value1", forKey: "key1")
        apiQuery.setQueryItem("value2", forKey: "key2")
        apiQuery.setQueryItems(["key3": "value3"])
        XCTAssertEqual(apiQuery.query(), "key1=value1&key2=value2&key3=value3", "The query should be value=key", file: __FUNCTION__, line: __LINE__)
    }

    func testThatSetResponseType() {
        let apiQuery: ApiQuery = ApiQuery(configuration: ApiStoreConfiguration(), endPoint: ApiEndpoint())
        apiQuery.setResponseType(ResponseType.dictionary)
        XCTAssert(apiQuery.response() != ResponseType.data, "The response type should be different than response type data", file: __FILE__, line: __LINE__)
    }
    
}
