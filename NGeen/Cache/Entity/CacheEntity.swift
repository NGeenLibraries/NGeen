//
// CacheEntity.swift
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

class CacheEntity: NSObject {
    
    var dirty: Bool = false
    var key: String?
    var lastAccess: CFTimeInterval?
    var size: Int?
    var uid: String?
    
//MARK: Constructor 
    
    override init() {
        super.init()
    }
    
    convenience init(key: String, uid: String, accessTime: CFTimeInterval, size: Int) {
        self.init()
        self.key = key
        self.lastAccess = accessTime
        self.size = size
        self.uid = uid
    }
    
    convenience init(statement: COpaquePointer) {
        self.init()
        self.key = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 1)))
        self.uid = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 0)))
        self.lastAccess = sqlite3_column_double(statement, 2)
        self.size = Int(sqlite3_column_int(statement, 3))
    }
    
}
