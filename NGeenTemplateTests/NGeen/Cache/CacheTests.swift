//
//  CacheTests.swift
//  NGeenTemplate
//
//  Created by NGeen on 7/7/14.
//  Copyright (c) 2014 NGeen. All rights reserved.
//

import XCTest

class CacheTests: XCTestCase {

    let kTestKey: String = "fromTests"
    let cacheMock: CacheTestMockup = CacheTestMockup()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatInit() {
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath("\(self.cacheMock.path)/\(kCacheFileName)"), "The database should exist", file: __FUNCTION__, line: __LINE__)
    }
    
    func testThatCurrentUsage() {
        self.cacheMock.storeFileForKey(kTestKey, {(path) in
            XCTAssertGreaterThan(self.cacheMock.cache.currentUsage(), 0, "The current disk usage should be greater than 0", file: __FUNCTION__, line: __LINE__)
        })
    }
    
    func testThatStoreFileForKey() {
       self.cacheMock.storeFileForKey(kTestKey, {(path) in
            var isDirectory: UnsafeMutablePointer<ObjCBool> = nil
            NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: isDirectory)
            XCTAssert(isDirectory == nil, "The file should exist", file: __FUNCTION__, line: __LINE__)
        })
    }
    
    func testThatFileNameForKey() {
        self.cacheMock.storeFileForKey(kTestKey, {(path) in
            if let fileName = self.cacheMock.fileNameForKey(self.kTestKey) {
            } else {
                XCTAssert(false, "The file name can't be nil", file: __FUNCTION__, line: __LINE__)
            }
        })
    }
    
}
