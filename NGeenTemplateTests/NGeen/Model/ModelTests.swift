//
// ModelTests.swift
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

class ModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
   
    func testThatFillWithoutChildsModels() {
        let model = ModelMockup()
        model.fill(["lastName": "bar", "name": "bar1"])
        XCTAssertEqual(model.lastName, "bar", "the last name var value should be equal to bar", file: __FILE__, line: __LINE__)
        XCTAssertEqual(model.name, "bar1", "the name var value should be equal to bar1", file: __FILE__, line: __LINE__)
    }
    
    func testThatFillWithChildsModels() {
        let model = ModelMockup()
        model.fill(["lastName": "bar", "name": "bar1", "childs": [["foo": "bar", "foo1": "bar1"]]])
        XCTAssertEqual(model.lastName, "bar", "the last name var value should be equal to bar", file: __FILE__, line: __LINE__)
        XCTAssertEqual(model.name, "bar1", "the name var value should be equal to bar1", file: __FILE__, line: __LINE__)
        let child: Child = model.childs.first!
        XCTAssertEqual(child.foo, "bar", "the foo var value should be equal to bar", file: __FILE__, line: __LINE__)
        XCTAssertEqual(child.foo1, "bar1", "the foo1 var value should be equal to bar1", file: __FILE__, line: __LINE__)
    }
    
    func testThatHashPropertyFalse() {
        let model = ModelMockup()
        XCTAssertFalse(model.hasProperty("second"), "The method should return false", file: __FILE__, line: __LINE__)
    }
    
    func testThatHashPropertyTrue() {
        let model = ModelMockup()
        XCTAssertTrue(model.hasProperty("name"), "The method should return true", file: __FILE__, line: __LINE__)
    }
    
    func testThatProperties() {
        let model = ModelMockup()
        XCTAssertGreaterThan(model.properties().count, 0, "The method properties should return a value", file: __FILE__, line: __LINE__)
    }
    
}
