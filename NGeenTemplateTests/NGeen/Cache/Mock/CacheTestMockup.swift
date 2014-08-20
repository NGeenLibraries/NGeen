//
// CacheTestMockup.swift
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

class CacheTestMockup: NSObject, CacheDelegate {
   
    var cache: Cache
    var path: String
    
    // MARK: Constructor
    
    override init() {
        let paths: Array = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true);
        self.path = "\(paths[0])/\(kCacheFolder)"
        NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: true, attributes: nil, error: nil)
        self.cache = Cache(cachePath: self.path)
        self.cache.diskCapacity = kMaxDiskCacheCapacity
        super.init()
        self.cache.delegate = self
    }
    
    // MARK: Cache delegate
    
    func cache(cache: Cache, deleteFileWithName name: String, andKey key: String)  {
        
    }
    
    func cache(cache: Cache, writeFileWithName name: String, data: NSPurgeableData) {
        let path: String = "\(self.path)/\(name)"
        data.beginContentAccess()
        data.writeToFile(path, atomically: true)
        data.endContentAccess()
    }
    
    //MARK : Instance methods
    
    func fileNameForKey(key: String) -> String? {
        if let fileName = cache.fileNameForKey(key) {
            return fileName
        }
        return nil
    }
    
    func storeFileForKey(key: String, completionHandler closure: ((String!) -> Void)!) {
        let data: NSPurgeableData = NSPurgeableData(base64Encoding: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum")
        cache.storeFileForKey(key, withData: data, completionHandler: {(uuid) in
            if closure {
                closure("\(self.path)/\(uuid)")
            }
        })
    }
    
}
