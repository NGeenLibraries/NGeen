//
// CacheTests.swift
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
