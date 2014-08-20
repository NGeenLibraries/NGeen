//
// DiskCache.swift
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

class DiskCache: NSObject, CacheDelegate {
   
    private var cache: Cache
    private var memoryCache: NSCache
    private var memoryUsage: Int = 0
    private var path: String
    private var queue: dispatch_queue_t
    private struct Static {
        static var instance: DiskCache? = nil
        static var token: dispatch_once_t = 0
    }
    
    // MARK: Constructor
    
    required override init() {
        let paths: Array = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true);
        self.path = "\(paths[0])/\(kCacheFolder)"
        NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: true, attributes: nil, error: nil)
        self.cache = Cache(cachePath: self.path)
        self.memoryCache = NSCache()
        self.queue = dispatch_queue_create("com.ngeen.diskcachequeue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_set_target_queue(self.queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        super.init()
        self.cache.delegate = self
        self.cache.diskCapacity = kMaxDiskCacheCapacity
        self.memoryCache.totalCostLimit = kMaxMemoryCacheCapacity
    }

    // MARK: Cache delegate
    
    func cache(cache: Cache, deleteFileWithName name: String, andKey key: String) {
        dispatch_async(self.queue, {
            self.memoryCache.removeObjectForKey(key)
            NSFileManager.defaultManager().removeItemAtPath("\(self.path)/\(name)", error: nil)
        })
    }
    
    func cache(cache: Cache, writeFileWithName name: String, data: NSPurgeableData) {
        dispatch_sync(self.queue, {
            data.beginContentAccess()
            data.writeToFile("\(self.path)/\(name)", atomically: true)
            data.endContentAccess()
            self.memoryCache.setObject(data, forKey: name)
        })
    }
    
    // MARK: Instance methods
    
    /**
    * The function return the current memory usage for the data
    *
    * @param no need params.
    *
    * @return Int
    */
    
    func currentUsage() -> Int {
        return self.memoryUsage
    }
    
    /**
    * The function return the data for the given url
    *
    * @param The url key to search the data in the local cache.
    *
    * @return NSPurgeableData
    */
    
    func dataForUrl(url: NSURL) -> NSPurgeableData {
        var data: NSPurgeableData = NSPurgeableData()
        if self.memoryCache.objectForKey(url) {
           data = self.memoryCache.objectForKey(url) as NSPurgeableData
        } else if let fileName = self.cache.fileNameForKey(url.absoluteString) {
            var path: String = "\(self.path)/\(fileName)"
            var isDirectory: UnsafeMutablePointer<ObjCBool> = nil
            if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: isDirectory) {
                if isDirectory == nil {
                    if let purgeableData = NSPurgeableData.dataWithContentsOfFile(path, options: NSDataReadingOptions.DataReadingMapped | NSDataReadingOptions.DataReadingUncached, error: nil) {
                        data = purgeableData
                        self.memoryCache.setObject(data, forKey: url)
                    }
                }
            }
        }
        return data
    }
    
    /**
    * The function store the data in the local cache and also in the cache class
    *
    * @param data The data given to store in the cache.
    * @param url The url key to store the data.
    *
    */
    
    func storeData(data: NSPurgeableData, forUrl url: NSURL, completionHandler block: (() -> Void)!) {
        data.beginContentAccess()
        self.cache.storeFileForKey(url.description, withData: data, completionHandler: {(uuid) in
            self.memoryUsage += data.length
            if self.memoryUsage > kMaxMemoryCacheCapacity {
                self.memoryCache.setObject(uuid, forKey: url)
            } else {
                self.memoryCache.setObject(data, forKey: url)
            }
            data.endContentAccess()
            if block {
                block()
            }
        })
    }
    
    // MARK: Singleton method
    
    class func defaultCache() -> DiskCache {
        dispatch_once(&Static.token, {
            Static.instance = DiskCache()
        })
        return Static.instance!
    }
    
}
