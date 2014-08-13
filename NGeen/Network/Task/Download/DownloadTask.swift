//
// DownloadTask.swift
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
//

import UIKit

class DownloadTask: NSObject, NSURLSessionDownloadDelegate {
   
    private var closure: ((NSError!) -> Void)?
    private var credential: NSURLCredential?
    private var destination: NSURL?
    private var operationQueue: NSOperationQueue = NSOperationQueue()
    private var progress: ((Int64!, Int64!, Int64!) -> Void)?
    private var session: NSURLSession?
    private var sessionConfiguration: NSURLSessionConfiguration
    
    var url: NSURL?
    
// MARK: Constructor
    
    override init() {
        self.sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        super.init()
        self.session = NSURLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: self.operationQueue)
    }
    
// MARK: Instance methods
    
    /**
    * The function download a file from url
    *
    * @param destination The destination to store the file.
    * @params handler The closure to track the download progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func download(destination: NSURL, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSError!) -> Void)?) {
        assert(destination != nil, "The destination should have a value", file: __FUNCTION__, line: __LINE__)
        assert(self.url != nil, "The url should have a value", file: __FUNCTION__, line: __LINE__)
        self.destination = destination
        self.progress = handler
        let downloadTask: NSURLSessionDownloadTask = self.session!.downloadTaskWithURL(self.url)
        downloadTask.resume()
    }
    
    /**
    * The function set the authentication credentials for the session
    *
    * @param credential The credential for the session.
    * @param protectionSpace The protectionSpace for the session.
    *
    */
    
    func setAuthenticationCredential(credential: NSURLCredential, forProtectionSpace protectionSpace: NSURLProtectionSpace) {
        self.credential = credential
        self.session!.configuration.URLCredentialStorage.setCredential(credential, forProtectionSpace: protectionSpace)
    }
    
//MARK: NSURLSession delegate
    
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didReceiveChallenge challenge: NSURLAuthenticationChallenge!, completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)!) {
        var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
        var credential: NSURLCredential?
        if self.credential != nil {
            credential = self.credential!
        } else {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                // TODO: Incorporate Trust Evaluation & TLS Chain Validation
                credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
                disposition = .UseCredential
            }
        }
        completionHandler(disposition, credential)
    }
    
//MARK: NSURLSessionDownloadTask delegate
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didFinishDownloadingToURL location: NSURL!) {
        var error: NSError?
        NSFileManager.defaultManager().moveItemAtURL(location, toURL: self.destination, error: &error)
        self.closure?(error)
    }
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progress?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }
}
