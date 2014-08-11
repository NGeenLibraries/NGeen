//
// Request.swift
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

import Foundation
import UIKit

class Request: NSObject, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate {
    
    private var closure: ((NSError!) -> Void)?
    private var destination: NSURL?
    private var headers: Dictionary<String, AnyObject>
    private var progress: NSProgress?
    private var progressClosure: ((Int64!, Int64!, Int64!) -> Void)?
    private var queue: dispatch_queue_t?
    private var request: NSMutableURLRequest?
    private var session: NSURLSession?
    private var sessionConfiguration: NSURLSessionConfiguration
    
    var body: NSData = NSData()
    var cachePolicy: NSURLRequestCachePolicy
    var cacheStoragePolicy: NSURLCacheStoragePolicy
    var httpMethod: String?
    var url: NSURL! {
        get {
            return self.request?.URL
        }
        set(url) {
            self.request = NSMutableURLRequest(URL: url)
        }
    }
    var timeout: NSTimeInterval {
        get {
            return self.sessionConfiguration.timeoutIntervalForRequest
        }
        set(timeout) {
            self.sessionConfiguration.timeoutIntervalForResource = timeout
            self.sessionConfiguration.timeoutIntervalForRequest = timeout
        }
    }
    weak var delegate: RequestDelegate?
    
// MARK: Constructor
    
    override init() {
        self.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        self.cacheStoragePolicy = NSURLCacheStoragePolicy.NotAllowed
        self.headers = Dictionary()
        self.queue = dispatch_queue_create("com.ngeen.requestqueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_set_target_queue(self.queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        self.sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.sessionConfiguration.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        self.sessionConfiguration.timeoutIntervalForRequest = 30
        self.sessionConfiguration.timeoutIntervalForResource = 30
        super.init()
        self.session = NSURLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    convenience init(httpMethod: String, url: NSURL)  {
        self.init()
        self.httpMethod = httpMethod
        self.url = url
    }

    deinit {
        self.session!.invalidateAndCancel()
    }
    
// MARK: Intance methods
    
    /**
    * The function download a file from url
    *
    * @param destination The destination to store the file.
    * @params progress The closure to track the download progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func download(destination: NSURL, progress: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSError!) -> Void)?) {
        assert(destination != nil, "The destination should have a value", file: __FUNCTION__, line: __LINE__)
        self.closure = closure
        self.destination = destination
        self.progressClosure = progress
        let downloadTask: NSURLSessionDownloadTask = self.session!.downloadTaskWithURL(self.url)
        downloadTask.resume()
    }
    
    /**
    * The function return the http headers setted to the request
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func httpHeaders() -> Dictionary<String, AnyObject> {
        return self.headers
    }
    
    /**
    * The function execute the current request also manage the current cache policy criteria
    *
    * @param completionHandler The closure to be called when the request end.
    *
    */
    
    func sendAsynchronous(completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)!) {
        dispatch_async(self.queue, {
            assert(self.url != nil, "the url can't be nil", file: __FUNCTION__, line: __LINE__)
            var data: NSPurgeableData = NSPurgeableData()
            if self.cachePolicy != NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData {
                data = DiskCache.defaultCache().dataForUrl(self.url)
                if self.delegate != nil && self.delegate!.respondsToSelector("cachedResponseForUrl:cachedData:") {
                    self.delegate!.cachedResponseForUrl!(self.url, cachedData: data)
                }
                if data.length > 0 && (self.cachePolicy == NSURLRequestCachePolicy.ReturnCacheDataDontLoad || self.cachePolicy == NSURLRequestCachePolicy.ReturnCacheDataElseLoad) {
                    return
                }
            }
            self.request!.HTTPBody = self.body
            self.request!.HTTPMethod = self.httpMethod
            let sessionDataTask: NSURLSessionDataTask = self.session!.dataTaskWithRequest(self.request, completionHandler: {(data, urlResponse, error) in
                if !error && self.cacheStoragePolicy != NSURLCacheStoragePolicy.NotAllowed {
                    DiskCache.defaultCache().storeData(NSPurgeableData(data: data), forUrl: self.url, completionHandler: nil)
                }
                if closure {
                    closure(data, urlResponse ,error)
                }
            })
            sessionDataTask.resume()
        })
    }

    /**
    * The function set the authentication credentials for the session
    *
    * @param credential The credential for the session.
    * @param protectionSpace The protectionSpace for the session.
    *
    */
    
    func setAuthenticationCredential(credential: NSURLCredential, forProtectionSpace protectionSpace: NSURLProtectionSpace) {
        self.session!.configuration.URLCredentialStorage.setCredential(credential, forProtectionSpace: protectionSpace)
    }
    
    /**
    * The function set a value in the headers for the request also save this value in 
    * a local dictionary
    *
    * @param value The value for the http header.
    * @param field The http header field.
    *
    */
    
    func setValue(value: String, forHTTPHeaderField field: String) {
        self.request!.setValue(value, forHTTPHeaderField: field)
        self.headers[field] = value
    }
    
//MARK: NSURLSessionDownloadTask delegate
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didFinishDownloadingToURL location: NSURL!) {
        var error: NSError?
        NSFileManager.defaultManager().moveItemAtURL(location, toURL: self.destination, error: &error)
        self.closure?(error)
    }

    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progressClosure?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        self.progress?.totalUnitCount = totalBytesExpectedToWrite
        self.progress?.completedUnitCount = totalBytesWritten
    }
    
}
