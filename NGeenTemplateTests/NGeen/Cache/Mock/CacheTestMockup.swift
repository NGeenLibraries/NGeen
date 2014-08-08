//
//  CacheTestMockup.swift
//  NGeenTemplate
//
//  Created by NGeen on 7/9/14.
//  Copyright (c) 2014 NGeen. All rights reserved.
//

import UIKit

class CacheTestMockup: NSObject, CacheDelegate {
   
    var cache: Cache
    var path: String
    
//MARK: Constructor
    
    override init() {
        let paths: Array = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true);
        self.path = "\(paths[0])/\(kCacheFolder)"
        NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: true, attributes: nil, error: nil)
        self.cache = Cache(cachePath: self.path)
        self.cache.diskCapacity = kMaxDiskCacheCapacity
        super.init()
        self.cache.delegate = self
    }
    
//MARK: Cache delegate
    
    func cache(cache: Cache, deleteFileWithName name: String, andKey key: String)  {
        
    }
    
    func cache(cache: Cache, writeFileWithName name: String, data: NSPurgeableData) {
        let path: String = "\(self.path)/\(name)"
        data.beginContentAccess()
        data.writeToFile(path, atomically: true)
        data.endContentAccess()
    }
    
//MARK: Instance methods
    
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
