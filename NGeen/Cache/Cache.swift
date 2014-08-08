//
// Cache.swift
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

let kSchema: String = "CREATE TABLE IF NOT EXISTS cache_index (uid TEXT, key TEXT PRIMARY KEY, last_access REAL, size INTEGER)"
let kSelectByKeyQuery: String = "SELECT uid, key,last_access, size FROM cache_index WHERE key = "
let kStorageSizeQuery: String = "SELECT SUM(size) FROM cache_index"
let kTrimQuery: String = "CREATE TABLE trimmed AS SELECT uid, key, last_access, size, running_total FROM (SELECT a1.uid, a1.key, a1.last_access, a1.size, SUM(a2.size) running_total FROM cache_index a1, cache_index a2 WHERE a1.last_access > a2.last_access OR (a1.last_access = a2.last_access AND a1.uid = a2.uid)  GROUP BY a1.uid ORDER BY a1.last_access) rt WHERE rt.running_total <= "

class Cache: NSObject, NSCacheDelegate {
    
    private var cache: NSCache = NSCache()
    private var currentDiskUsage: Int = 0
    private var dataBase: COpaquePointer = nil
    private var queue: dispatch_queue_t?
    
    var diskCapacity: Int = 0
    weak var delegate: CacheDelegate?
    
//MARK: Constructor
    
    init(var cachePath: String) {
        super.init()
        cachePath = "\(cachePath)/\(kCacheFileName)"
        self.cache.countLimit = 500
        self.cache.delegate = self
        self.queue = dispatch_queue_create("com.ngeen.databasequeue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_set_target_queue(self.queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        dispatch_barrier_sync(self.queue, {
            //sqlite3_config(SQLITE_CONFIG_MULTITHREAD)
            var success = sqlite3_open_v2(cachePath.cStringUsingEncoding(NSUTF8StringEncoding)!, &self.dataBase, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK
            if success {
                var statement: COpaquePointer = nil
                if sqlite3_prepare_v2(self.dataBase, kSchema.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
                    success = sqlite3_step(statement) == SQLITE_DONE
                    sqlite3_finalize(statement)
                }
            }
            if !success {
                println("Error opening the database ---> ", sqlite3_errmsg(self.dataBase))
                return
            }
            self.fetchDiskUsage()
        })
    }

//MARK: Instance methods
    
    /**
    * The function return the current memory usage for the data
    *
    * @param no need params.
    *
    * @return Int
    */
    
    func currentUsage() -> Int {
        return self.currentDiskUsage
    }
    
    /**
    * The function return the file name in the disk for the given key
    *
    * @param key The key of the object
    *
    * @return String
    */
    
    func fileNameForKey(key: String) -> String? {
        assert(self.dataBase != nil, "The database should exists", file: __FUNCTION__, line: __LINE__)
        let entity: CacheEntity? = self.readEntityForKey(key)
        if entity != nil {
            entity!.dirty = true
            entity!.lastAccess = CFAbsoluteTimeGetCurrent()
            return entity!.uid
        }
        return nil
    }
    
    /**
    * The function save the data with the given key in the database and the disk
    *
    * @param key The key of the object
    * @param data The data of the object to store
    * @param closure The closure to call when the operation ends
    */
    
    func storeFileForKey(key: String, withData data: NSPurgeableData, completionHandler closure:((String!) -> Void)!) {
        assert(self.dataBase != nil, "The database should exists", file: __FUNCTION__, line: __LINE__)
        dispatch_barrier_sync(self.queue, {
            data.beginContentAccess()
            let uuidRef = CFUUIDCreate(kCFAllocatorDefault)
            let uuid: String = CFUUIDCreateString(kCFAllocatorDefault, uuidRef).__conversion()
            let entity: CacheEntity = CacheEntity(key: key, uid:uuid, accessTime: CFAbsoluteTimeGetCurrent(), size: data.length)
            self.saveEntity(entity)
            self.currentDiskUsage += data.length
            if self.currentDiskUsage > self.diskCapacity {
                self.removeOldEntities()
            }
            self.cache.setObject(entity, forKey: uuid, cost: data.length)
            self.delegate?.cache(self, writeFileWithName: uuid, data: data)
            if closure {
                closure(uuid)
            }
            data.endContentAccess()
        })
    }
    
//MARK: NSCache delegate

    //================================================================================
    // TODO: check or search for new way to implement this delegate is giving a deadlock
    // UPDATE: apparently is fixed by apple
    //================================================================================
    
    func cache(cache: NSCache!, willEvictObject obj: AnyObject!) {
        var entity: CacheEntity = obj as CacheEntity
        if entity.dirty {
            dispatch_async(self.queue, {
                self.saveEntity(entity)
            })
        }
    }
    
//MARK: Private methods
    
    /**
    * The function drop the temporal table with the old data
    *
    * @param no need params.
    *
    */
    
    private func dropTrimTable() {
        assert(NSThread.mainThread(), "The method should be called in background", file: __FUNCTION__, line: __LINE__)
        let deleteQuery: String = "DROP TABLE IF EXISTS trimmed"
        var statement: COpaquePointer = nil
        if sqlite3_prepare_v2(self.dataBase, deleteQuery.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                println("Error droping the trimmed table ---> ", sqlite3_errmsg(self.dataBase))
            }
            sqlite3_finalize(statement)
        }  else {
            println("Error droping the trimmed table ---> ", sqlite3_errmsg(self.dataBase))
        }
    }
    
    /**
    * The function fetch the current disk usage of the cache data
    *
    * @param no need params.
    *
    */
    
    private func fetchDiskUsage() {
        assert(NSThread.mainThread(), "The method should be called in background", file: __FUNCTION__, line: __LINE__)
        var statement: COpaquePointer = nil
        if sqlite3_prepare_v2(self.dataBase, kStorageSizeQuery.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                self.currentDiskUsage += Int(sqlite3_column_int(statement, 0))
            }
            sqlite3_finalize(statement)
        }
    }
    
    /**
    * The function return the entity for the given key
    *
    * @param key The key of the object to search
    *
    * @return CacheEntity
    */
    
    private func readEntityForKey(key: String) -> CacheEntity? {
        assert(NSThread.mainThread(), "The method should be called in background", file: __FUNCTION__, line: __LINE__)
        var entity: CacheEntity?
        var statement: COpaquePointer = nil
        if sqlite3_prepare_v2(self.dataBase, ("\(kSelectByKeyQuery) '\(key)'").cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                entity = CacheEntity(statement: statement)
            }
            sqlite3_finalize(statement)
        } else {
            println("Error consulting the data ---> ", sqlite3_errmsg(self.dataBase))
        }
        return entity
    }
    
    /**
    * The function remove the old entities in the database if the entity lenght is higher than the allowed
    *
    * @param no need params.
    *
    */
    
    private func removeOldEntities() {
        assert(NSThread.mainThread(), "The method should be called in background", file: __FUNCTION__, line: __LINE__)
        self.dropTrimTable()
        var statement: COpaquePointer = nil
        let capacity = Double(self.currentDiskUsage - self.diskCapacity) * 0.8
        if sqlite3_prepare_v2(self.dataBase, ("\(kTrimQuery)\(capacity)").cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                var spaceCleaned: Int = 0
                let trimSelectQuery: String = "SELECT uid, key, size FROM trimmed"
                if sqlite3_prepare_v2(self.dataBase, trimSelectQuery.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
                    while sqlite3_step(statement) == SQLITE_ROW {
                        spaceCleaned += Int(sqlite3_column_int(statement, 2))
                        let key: String = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 1)))!
                        let uuid: String = String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(statement, 0)))!
                        self.cache.removeObjectForKey(key)
                        self.delegate?.cache(self, deleteFileWithName: uuid, andKey: key)
                    }
                } else {
                    println("Error removing the old data ---> ", sqlite3_errmsg(self.dataBase))
                }
                sqlite3_finalize(statement)
                let trimCleanQuery: String = "DELETE FROM cache_index WHERE key IN (SELECT key from trimmed)"
                if sqlite3_prepare_v2(self.dataBase, trimCleanQuery.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_step(statement)
                    sqlite3_finalize(statement)
                    self.currentDiskUsage -= spaceCleaned
                    self.dropTrimTable()
                } else {
                    println("Error removing the old data ---> ", sqlite3_errmsg(self.dataBase))
                }
            } else {
                println("Error removing the old data ---> ", sqlite3_errmsg(self.dataBase))
            }
        } else {
            println("Error removing the old data ---> ", sqlite3_errmsg(self.dataBase))
        }
    }
    
    /**
    * The function save in the database the given entity
    *
    * @param entity The current entity to store
    *
    */
    
    private func saveEntity(entity: CacheEntity) {
        assert(NSThread.mainThread(), "The method should be called in background", file: __FUNCTION__, line: __LINE__)
        let existing: CacheEntity? = self.readEntityForKey(entity.key!)
        if existing != nil {
            self.updateEntity(existing!)
            if existing!.uid != entity.uid {
                self.delegate?.cache(self, deleteFileWithName: existing!.uid!, andKey: existing!.key!)
            }
            return
        }
        let insertQuery: String = "INSERT INTO cache_index VALUES ('\(entity.uid!)', '\(entity.key!)', \(entity.lastAccess!), \(entity.size!))"
        var statement: COpaquePointer = nil
        if sqlite3_prepare(self.dataBase, insertQuery.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE  {
                println("Error inserting the data ---> ", sqlite3_errmsg(self.dataBase))
            }
            sqlite3_finalize(statement)
        } else {
            println("Error inserting the data ---> ", sqlite3_errmsg(self.dataBase))
        }
    }
    
    /**
    * The function update the given entity in the database
    *
    * @param entity The current entity to store.
    *
    */
    
    private func updateEntity(entity: CacheEntity) {
        assert(NSThread.mainThread(), "The method should be called in background", file: __FUNCTION__, line: __LINE__)
        let updateQuery: String = "UPDATE cache_index SET uid='\(entity.uid!)', last_access=\(entity.lastAccess!), size=\(entity.size!) WHERE key='\(entity.key!)'"
        var statement: COpaquePointer = nil
        if sqlite3_prepare(self.dataBase, updateQuery.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE  {
                println("Error updating the data ---> ", sqlite3_errmsg(self.dataBase))
            }
            sqlite3_finalize(statement)
        } else {
            println("Error updating the data ---> ", sqlite3_errmsg(self.dataBase))
        }
    }
    
}
