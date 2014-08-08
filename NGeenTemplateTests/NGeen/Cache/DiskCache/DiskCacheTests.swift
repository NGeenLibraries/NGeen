//
//  DiskCacheTests.swift
//  NGeenTemplate
//
//  Created by NGeen on 7/10/14.
//  Copyright (c) 2014 NGeen. All rights reserved.
//

import XCTest

class DiskCacheTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testThatCurrentUsage() {
        let data: NSPurgeableData = NSPurgeableData(base64Encoding: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum")
        DiskCache.defaultCache().storeData(data, forUrl: kTestUrl, completionHandler: {
            XCTAssertGreaterThan(DiskCache.defaultCache().currentUsage(), 0, "The current memory usage should be greater than 0", file: __FUNCTION__, line: __LINE__)
        })
    }
    
    func testThatStoreForUrl() {
        let data: NSPurgeableData = NSPurgeableData(base64Encoding: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum")
        DiskCache.defaultCache().storeData(data, forUrl: kTestUrl, completionHandler: {
            XCTAssertGreaterThan(DiskCache.defaultCache().dataForUrl(kTestUrl).length, 0, "The data length for the url should be greater than 0", file: __FUNCTION__, line: __LINE__)
        })
    }
    
}
