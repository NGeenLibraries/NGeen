//
//  StoreApiTests.swift
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

class ApiStoreTests: XCTestCase {
    
    let kConfigKey = "CONFIG_KEY"
    var apiConfiguration: ApiStoreConfiguration?
    var store: ApiStore?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.apiConfiguration = ApiStoreConfiguration()
        self.store = ApiStore(config: self.apiConfiguration!)
        self.store?.setConfiguration(self.apiConfiguration!, forKey: kConfigKey)
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "example"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.store = nil
        self.apiConfiguration = nil
    }
    
    func testThatCreateQuery() {
        XCTAssertTrue(self.store!.createQuery().isKindOfClass(ApiQuery.self), "Invalid api query class", file: __FILE__, line: __LINE__)
    }
    
    func testThatCreateQueryWithConfigurationKey() {
        self.store?.setConfiguration(self.apiConfiguration!, forKey: kConfigKey)
        XCTAssert(self.store!.createQuery().isKindOfClass(ApiQuery.self), "Invalid api query class", file: __FILE__, line: __LINE__)
    }
    
    func testThatCreateQueryForPath() {
        let endpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "example")
        let fooEndpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "foo")
        self.store?.setEndpoints([endpoint, fooEndpoint])
        XCTAssertTrue(self.store!.createQueryForPath(endpoint.path!, httpMethod: HttpMethod.get).isKindOfClass(ApiQuery.self), "Invalid api query class", file: __FILE__, line: __LINE__)
    }
    
    func testThatCreateQueryForPathAndServer() {
        let endpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "example")
        let fooEndpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "foo")
        self.store?.setEndpoints([endpoint, fooEndpoint], forServer: kConfigKey)
        XCTAssertTrue(self.store!.createQueryForPath(endpoint.path!, httpMethod: HttpMethod.get, server: kConfigKey).isKindOfClass(ApiQuery.self), "Invalid api query class", file: __FILE__, line: __LINE__)
    }
    
    func testThatConfiguration() {
        XCTAssert(self.store!.configuration().conformsToProtocol(ConfigurationStoreProtocol) , "Invalid configuration type", file: __FILE__, line: __LINE__)
    }
    
    func testThatConfigurationWithKey() {
        XCTAssert(self.store!.configuration().conformsToProtocol(ConfigurationStoreProtocol), "Invalid configuration type", file: __FILE__, line: __LINE__)
    }
    
    func testThatEndpointForPath() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "example"), forServer: kConfigKey)
        if let endPoint = self.store?.endpointForPath("example", httpMethod: HttpMethod.get) {
        } else {
            XCTFail("The Endpoint can't be null")
        }
    }
    
    func testThatEndpointForModelPathAndServer() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "example"), forServer: kConfigKey)
        if let endPoint = self.store?.endpointForPath("example", httpMethod: HttpMethod.get, serverName: kConfigKey) {
        } else {
            XCTFail("The Endpoint can't be null")
        }
    }

    func testThatSetAuthenticationCredentials() {
        self.store!.setAuthenticationCredentials("test", password: "test")
        XCTAssertEqual(self.store!.getAuthenticationCredentials(), "test:test", "The authentication string should be equal to test:test", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetAuthenticationCredentialsForServer() {
        self.store!.setAuthenticationCredentials("test", password: "test", forServer: kConfigKey)
        XCTAssertEqual(self.store!.getAuthenticationCredentialsForServer(kConfigKey), "test:test", "The authentication string should be equal to test:test", file: __FUNCTION__, line: __LINE__)
    }
    
    func testTharSetCachePolicy() {
        self.store!.setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad)
        XCTAssertEqual(self.store!.getCachePolicy()!, NSURLRequestCachePolicy.ReturnCacheDataElseLoad, "The cache policy should be equal to ReturnCacheDataElseLoad", file: __FUNCTION__, line: __LINE__)
    }
    
    func testTharSetCachePolicyForServer() {
        self.store!.setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad, forServer: kConfigKey)
        XCTAssertEqual(self.store!.getCachePolicyForServer(kConfigKey)!, NSURLRequestCachePolicy.ReturnCacheDataElseLoad, "The cache policy should be equal to ReturnCacheDataElseLoad", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetCacheStoragePolicy() {
        self.store!.setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed)
        XCTAssertEqual(self.store!.getCacheStoragePolicy()!, NSURLCacheStoragePolicy.Allowed, "The cache storage policy should be equal to allowed", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetCacheStoragePolicyForServer() {
        self.store!.setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed, forServer: kConfigKey)
        XCTAssertEqual(self.store!.getCacheStoragePolicyForServer(kConfigKey)!, NSURLCacheStoragePolicy.Allowed, "The cache storage policy should be equal to allowed", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetConfiguration() {
        self.store?.setConfiguration(self.apiConfiguration!)
        var configFromStore: ApiStoreConfiguration = self.store?.configuration() as ApiStoreConfiguration
        XCTAssertEqual(self.apiConfiguration!.host, configFromStore.host, "Default configuration is not correctly setted")
    }
    
    func testThatSetConfigurationWithKey() {
        let config: ApiStoreConfiguration = ApiStoreConfiguration()
        config.host = "www.google.com"
        self.store?.setConfiguration(config, forKey: kConfigKey)
        var configFromStore: ApiStoreConfiguration = self.store?.configurationForKey(kConfigKey) as ApiStoreConfiguration
        XCTAssertEqual(config.host, configFromStore.host, "Configuration with key is not correctly setted")
    }
    
    func testThatSetEndpoint() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: ""))
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetEndpointForServer() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: ""), forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetEndpoints() {
        let endpoints: Array<ApiEndpoint> = [ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: ""), ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "")]
        self.store?.setEndpoints(endpoints)
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetEndpointsForServer() {
        let endpoints: Array<ApiEndpoint> = [ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: ""), ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: "")]
        self.store?.setEndpoints(endpoints, forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeader() {
        self.store?.setHeader("test", forKey: "test")
        XCTAssertGreaterThan(self.store!.getHeaders().count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeaderForServer() {
        self.store?.setHeader("test", forKey: "test", serverName: kConfigKey)
        XCTAssertGreaterThan(self.store!.getHeadersForServer(kConfigKey).count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeaders() {
        self.store?.setHeaders(["test": "test"])
        XCTAssertGreaterThan(self.store!.getHeaders().count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeadersForServer() {
        self.store?.setHeaders(["test": "test"], forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.getHeadersForServer(kConfigKey).count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetModelsPath() {
        self.store?.setModelsPath("test.path")
        XCTAssertEqual(self.store!.getModelsPath(), "test.path", "The model path should be equal to test.path", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetModelsPathForServer() {
        self.store?.setModelsPath("test.path", forServer: kConfigKey)
        XCTAssertEqual(self.store!.getModelsPathForServer(kConfigKey), "test.path", "The model path should be equal to test.path", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseDisposition() {
        self.store?.setResponseDisposition(NSURLSessionResponseDisposition.Cancel)
        XCTAssertEqual(self.store!.getResponseDisposition()!, NSURLSessionResponseDisposition.Cancel, "The response disposition should be cancel", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseDispositionForServer() {
        self.store?.setResponseDisposition(NSURLSessionResponseDisposition.Cancel, forServer: kConfigKey)
        XCTAssertEqual(self.store!.getResponseDispositionForServer(kConfigKey)!, NSURLSessionResponseDisposition.Cancel, "The response disposition should be cancel", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseType() {
        self.store?.setResponseType(ResponseType.dictionary)
        XCTAssert(self.store!.getResponseType() != ResponseType.data, "The response type should be different than response type data", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseTypeForServer() {
        self.store?.setResponseType(ResponseType.dictionary, forServer: kConfigKey)
        XCTAssert(self.store!.getResponseType() != ResponseType.data, "The response type should be different than response type data", file: __FILE__, line: __LINE__)
    }
    
}
