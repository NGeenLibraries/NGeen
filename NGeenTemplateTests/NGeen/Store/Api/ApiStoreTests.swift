//
//  StoreApiTests.swift
//  NGeenTemplate
//
//  Created by NGeen on 7/7/14.
//  Copyright (c) 2014 NGeen. All rights reserved.
//

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
        self.store?.setEndpoint(ApiEndpoint())
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
    
    func testThatConfiguration() {
        XCTAssert(self.store!.configuration().conformsToProtocol(ConfigurationStoreProtocol) , "Invalid configuration type", file: __FILE__, line: __LINE__)
    }
    
    func testThatConfigurationWithKey() {
        XCTAssert(self.store!.configuration().conformsToProtocol(ConfigurationStoreProtocol), "Invalid configuration type", file: __FILE__, line: __LINE__)
    }
    
    func testThatEndpointForModelClass() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: ""), forServer: kDefaultServerName)
        if let endPoint = self.store?.endpointForModelClass(AnyClass.self, httpMethod: HttpMethod.get) {
        } else {
            XCTFail("The Endpoint can't be null")
        }
    }
    
    func testThatEndpointForModelClassAndServer() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: ""), forServer: kDefaultServerName)
        if let endPoint = self.store?.endpointForModelClass(AnyClass.self, httpMethod: HttpMethod.get, serverName: kDefaultServerName) {
        } else {
            XCTFail("The Endpoint can't be null")
        }
    }

    func testThatSetBodyItems() {
        var bodies: Dictionary<String, String> = ["Application-Id": "m6vrBwIgDFAARtVqXn", "API-Key": "L8sHTFXm0HxNUiiBvR03ug"]
        self.store?.setBodyItems(bodies)
        XCTAssertGreaterThan(self.store!.getBodyItems().count, 0, "The body items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetBodyItemsForServer() {
        var bodies: Dictionary<String, String> = ["Application-Id": "m6vrBwIgDFAARtVqXn", "API-Key": "L8sHTFXm0HxNUiiBvR03ug"]
        self.store?.setBodyItems(bodies, forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.getBodyItemsForServer(kConfigKey).count, 0, "The body items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testTharSetCachePolicy() {
        self.store!.setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad)
        XCTAssertEqual(self.store!.getCachePolicy(), NSURLRequestCachePolicy.ReturnCacheDataElseLoad, "The cache policy should be equal to ReturnCacheDataElseLoad", file: __FUNCTION__, line: __LINE__)
    }
    
    func testTharSetCachePolicyForServer() {
        self.store!.setCachePolicy(NSURLRequestCachePolicy.ReturnCacheDataElseLoad, forServer: kConfigKey)
        XCTAssertEqual(self.store!.getCachePolicyForServer(kConfigKey), NSURLRequestCachePolicy.ReturnCacheDataElseLoad, "The cache policy should be equal to ReturnCacheDataElseLoad", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetCacheStoragePolicy() {
        self.store!.setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed)
        XCTAssertEqual(self.store!.getCacheStoragePolicy(), NSURLCacheStoragePolicy.Allowed, "The cache storage policy should be equal to allowed", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatSetCacheStoragePolicyForServer() {
        self.store!.setCacheStoragePolicy(NSURLCacheStoragePolicy.Allowed, forServer: kConfigKey)
        XCTAssertEqual(self.store!.getCacheStoragePolicyForServer(kConfigKey), NSURLCacheStoragePolicy.Allowed, "The cache storage policy should be equal to allowed", file: __FUNCTION__, line: __LINE__)
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
    
    func testThatSetEndpointForServerName() {
        self.store?.setEndpoint(ApiEndpoint(contentType: ContentType.json, httpMethod: HttpMethod.get, modelClass: Model.self, path: ""), forServer: kDefaultServerName)
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
    
    func testThatSetPathItem() {
        self.store?.setPathItem("test", forKey: "test")
        XCTAssertGreaterThan(self.store!.getPathItems().count, 0, "The path items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetPathItemForServer() {
        self.store?.setPathItem("test", forKey: "test", serverName: kConfigKey)
        XCTAssertGreaterThan(self.store!.getPathItemsForServer(kConfigKey).count, 0, "The path items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetPathItems() {
        self.store?.setPathItems(["test": "test"])
        XCTAssertGreaterThan(self.store!.getPathItems().count, 0, "The path items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetPathItemsForServer() {
        self.store?.setPathItems(["test": "test"], forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.getPathItemsForServer(kConfigKey).count, 0, "The path items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetQueryItem() {
        self.store?.setQueryItem("test", forKey: "test")
        XCTAssertGreaterThan(self.store!.getQueryItems().count, 0, "The query items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetQueryItemForServer() {
        self.store?.setQueryItem("test", forKey: "test", serverName: kConfigKey)
        XCTAssertGreaterThan(self.store!.getQueryItemsForServer(kConfigKey).count, 0, "The query items should be greater than 0", file: __FILE__, line: __LINE__)
    }

    func testThatSetQueryItems() {
        self.store?.setQueryItems(["test": "test"])
        XCTAssertGreaterThan(self.store!.getQueryItems().count, 0, "The query items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetQueryItemsForServer() {
        self.store?.setQueryItems(["test": "test"], forServer: kConfigKey)
        XCTAssertGreaterThan(self.store!.getQueryItemsForServer(kConfigKey).count, 0, "The query items should be greater than 0", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseType() {
        self.store?.setResponseType(ResponseType.dictionary)
        XCTAssert(self.store!.getResponseType() != ResponseType.data, "The response type should be different than response type data", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetResponseTypeForServer() {
        self.store?.setResponseType(ResponseType.dictionary, forServer: kConfigKey)
        XCTAssert(self.store!.getResponseType() != ResponseType.data, "The response type should be different than response type data", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetTextFileData() {
        self.store?.setTextData("")
        XCTAssertGreaterThan(self.store!.getBodyItems().count, 0, "The file data should have 1 item", file: __FILE__, line: __LINE__)
    }
    
    func testThatSetTextFileDataForServerName() {
        self.store?.setTextData("", forServerName: kConfigKey)
        XCTAssertGreaterThan(self.store!.getBodyItems().count, 0, "The file data should have 1 item", file: __FILE__, line: __LINE__)
    }

}
