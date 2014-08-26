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
        self.store?.setConfiguration(self.apiConfiguration!, forServer: kConfigKey)
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
        self.store?.setConfiguration(self.apiConfiguration!, forServer: kConfigKey)
        XCTAssert(self.store!.createQuery().isKindOfClass(ApiQuery.self), "Invalid api query class", file: __FILE__, line: __LINE__)
    }
    
    func testThatCreateQueryForPath() {
        let endpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "example")
        let fooEndpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "foo")
        self.store?.setEndpoints([endpoint, fooEndpoint])
        XCTAssertTrue(self.store!.createQueryForPath(endpoint.path, httpMethod: HttpMethod.get).isKindOfClass(ApiQuery.self), "Invalid api query class", file: __FILE__, line: __LINE__)
    }
    
    func testThatCreateQueryForPathAndServer() {
        let endpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "example")
        let fooEndpoint: ApiEndpoint = ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "foo")
        self.store?.setEndpoints([endpoint, fooEndpoint], forServer: kConfigKey)
        XCTAssertTrue(self.store!.createQueryForPath(endpoint.path, httpMethod: HttpMethod.get, server: kConfigKey).isKindOfClass(ApiQuery.self), "Invalid api query class", file: __FILE__, line: __LINE__)
    }
    
    func testThatConfiguration() {
        XCTAssert(self.store!.configuration().conformsToProtocol(ConfigurationStoreProtocol) , "Invalid configuration type", file: __FILE__, line: __LINE__)
    }
    
    func testThatConfigurationWithKey() {
        XCTAssert(self.store!.configuration().conformsToProtocol(ConfigurationStoreProtocol), "Invalid configuration type", file: __FILE__, line: __LINE__)
    }
    
    func testThatEndpointForPath() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "example"), forServer: kConfigKey)
        if let endPoint = self.store?.endpointForPath("example", httpMethod: HttpMethod.get) {
        } else {
            XCTFail("The Endpoint can't be null")
        }
    }
    
    func testThatEndpointForModelPathAndServer() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "example"), forServer: kConfigKey)
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
        XCTAssertEqual(self.store!.getAuthenticationCredentials(forServer: kConfigKey), "test:test", "The authentication string should be equal to test:test", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetConfiguration() {
        self.store?.setConfiguration(self.apiConfiguration!)
        var configFromStore: ApiStoreConfiguration = self.store?.configuration() as ApiStoreConfiguration
        XCTAssertEqual(self.apiConfiguration!.host, configFromStore.host, "Default configuration is not correctly setted")
    }
    
    func testThatSetConfigurationWithKey() {
        let config = ApiStoreConfiguration()
        config.host = "www.google.com"
        self.store?.setConfiguration(config, forServer: kConfigKey)
        var configFromStore: ApiStoreConfiguration = self.store?.configuration(forServer: kConfigKey) as ApiStoreConfiguration
        XCTAssertEqual(config.host, configFromStore.host, "Configuration with key is not correctly setted")
    }
    
    func testThatSetEndpoint() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: ""))
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetEndpointForServer() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: ""), forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetEndpoints() {
        let endpoints = [ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: ""), ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "")]
        self.store?.setEndpoints(endpoints)
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetEndpointsForServer() {
        let endpoints = [ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: ""), ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, path: "")]
        self.store?.setEndpoints(endpoints, forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.endPoints.count, 0, "The endpoints should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeader() {
        self.store?.setHeader("test", forKey: "test")
        XCTAssertGreaterThan(self.store!.getHeaders().count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeaderForServer() {
        self.store?.setHeader("test", forKey: "test", forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.getHeaders(forServer: kConfigKey).count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeaders() {
        self.store?.setHeaders(["test": "test"])
        XCTAssertGreaterThan(self.store!.getHeaders().count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetHeadersForServer() {
        self.store?.setHeaders(["test": "test"], forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.getHeaders(forServer: kConfigKey).count, 0, "The headers should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetPinnedCertificates() {
        self.store?.setPinnedCertificates(["test.path".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)])
        XCTAssertGreaterThan(self.store!.getPinnedCertificates().count, 0, "The pinned certificates should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetPinnedCertificatesForServer() {
        self.store?.setPinnedCertificates(["test.path".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)], forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.getPinnedCertificates(forServer: kConfigKey).count, 0, "The pinned certificates should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseDisposition() {
        self.store?.setResponseDisposition(NSURLSessionResponseDisposition.Cancel)
        XCTAssertEqual(self.store!.getResponseDisposition()!, NSURLSessionResponseDisposition.Cancel, "The response disposition should be cancel", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseDispositionForServer() {
        self.store?.setResponseDisposition(NSURLSessionResponseDisposition.Cancel, forServer: kConfigKey)
        XCTAssertEqual(self.store!.getResponseDisposition(forServer: kConfigKey)!, NSURLSessionResponseDisposition.Cancel, "The response disposition should be cancel", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetSecurityPolicy() {
        self.store?.setSecurityPolicy(Policy.certificate)
        XCTAssert(self.store!.getSecurityPolicy() != Policy.none, "The security policy should be different than security policy none", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetSecurityPolicyForServer() {
        self.store?.setSecurityPolicy(Policy.certificate, forServer: kConfigKey)
        XCTAssert(self.store!.getSecurityPolicy(forServer: kConfigKey) != Policy.none, "The security policy should be different than security policy none", file: __FILE__, line: __LINE__)
    }
    
}
