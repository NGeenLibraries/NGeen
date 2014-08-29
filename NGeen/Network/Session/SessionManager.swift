//
// SessionManager.swift
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

class SessionManager: NSObject, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate {

    private(set) var becomeDownloadTaskClosure: ((NSURLSession!, NSURLSessionDataTask!, NSURLSessionDownloadTask!) -> Void)?
    private var credential: NSURLCredential?
    private var dataTasksDelegates: [Int: SessionTaskDelegate]
    private var operationQueue: NSOperationQueue = NSOperationQueue()
    private var queue: dispatch_queue_t?
    private var session: NSURLSession?
    private var sessionConfiguration: NSURLSessionConfiguration
    
    var options: NGeenOptions
    var redirection: NSURLRequest?
    var responseDisposition: NSURLSessionResponseDisposition?
    var securityPolicy: SecurityPolicy
    
// MARK: Constructor
    
    init(sessionConfiguration: NSURLSessionConfiguration) {
        self.dataTasksDelegates = Dictionary()
        self.options = NGeenOptions.none
        self.queue = dispatch_queue_create("com.ngeen.sessionmanagerqueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_set_target_queue(self.queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        self.securityPolicy = SecurityPolicy()
        self.sessionConfiguration = sessionConfiguration
        super.init()
        self.session = NSURLSession(configuration: self.sessionConfiguration, delegate: self, delegateQueue: self.operationQueue)
        self.session!.getTasksWithCompletionHandler({(dataTasks, uploadTasks, downloadTasks) in
            for (task: NSURLSessionDataTask) in dataTasks as Array {
                self.setDelegateForTask(task, completionHandler: nil)
            }
            for (task: NSURLSessionDownloadTask) in downloadTasks as Array {
                self.setDelegateForDownloadTask(task, destination: nil, progress: nil, completionHandler: nil)
            }
            for (task: NSURLSessionUploadTask) in uploadTasks as Array {
                self.setDelegateForUploadTask(task, stream: nil, progress: nil, completionHandler: nil)
            }
        })
    }

    deinit {
        self.session!.invalidateAndCancel()
    }
    
// MARK: Intance methods
    
    /**
    * The create a new data task and also set a delegate to handle responses
    *
    * @param request The request for the data task.
    * @param completionHandler The closure to be called when the task end.
    *
    * @return NSURLSessionDataTask
    */

    func dataTaskWithRequest(request: NSURLRequest, completionHandler closure: NGeenTaskClosure) -> NSURLSessionDataTask {
        let dataTask: NSURLSessionDataTask = self.session!.dataTaskWithRequest(request)
        self.setDelegateForTask(dataTask, completionHandler: closure)
        return dataTask
    }

    /**
    * The function create a new data task and also set a delegate to handle responses
    *
    * @param request The request for the data task.
    * @param destination The url to store the download.
    * @param completionHandler The closure to be called when the task end.
    *
    * @return NSURLSessionDownloadTask
    */

    func downloadTaskWithRequest(request: NSURLRequest, destination url: NSURL, progress handler: NGeenProgressTaskClosure,  completionHandler closure: NGeenTaskClosure) -> NSURLSessionDownloadTask {
        let dataTask: NSURLSessionDownloadTask = self.session!.downloadTaskWithRequest(request)
        self.setDelegateForDownloadTask(dataTask, destination: url, progress: handler, completionHandler: closure)
        return dataTask
    }

    /**
    * The function create a new data task and also set a delegate to handle responses
    *
    * @param data The data to start the download.
    * @param destination The url to store the download.
    * @param completionHandler The closure to be called when the task end.
    *
    * @return NSURLSessionDownloadTask
    */

    func downloadTaskWithResumeData(data: NSData, destination url: NSURL, progress handler: NGeenProgressTaskClosure, completionHandler closure: NGeenTaskClosure) -> NSURLSessionDownloadTask {
        let dataTask: NSURLSessionDownloadTask = self.session!.downloadTaskWithResumeData(data)
        self.setDelegateForDownloadTask(dataTask, destination: url, progress: handler, completionHandler: closure)
        return dataTask
    }
    
    /**
    * The function get the progress for the given task
    *
    * @param task The task to get the current progress.
    *
    * return NSProgress
    */

    func getDownloadProgressForTask(task: NSURLSessionUploadTask) -> NSProgress? {
        return self.delegateForTask(task)?.progress
    }

    /**
    * The function get the progress for the given task
    *
    * @param task The task to get the current progress.
    *
    * return NSProgress
    */

    func getUploadProgressForTask(task: NSURLSessionUploadTask) -> NSProgress? {
        return self.delegateForTask(task)?.progress
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
    
    /**
    * The function set the closure to call when the task become in download task
    *
    * @param closure The closure to call when the task become in download task.
    *
    */
    
    func setBecomeDownloadTaskClosure(closure: ((NSURLSession!, NSURLSessionDataTask!, NSURLSessionDownloadTask!) -> Void)) {
        self.becomeDownloadTaskClosure = closure
    }
    
    /**
    * The function set the request redirection for the session
    *
    * @param redirection The request for the redirection.
    *
    */
    
    func setRedirection(redirection: NSURLRequest) {
        self.redirection = redirection
    }

    /**
    * The function set the authentication credentials for the session
    *
    * @param credential The credential for the session.
    * @param protectionSpace The protectionSpace for the session.
    *
    */
    
    func setResponseDisposition(disposition: NSURLSessionResponseDisposition) {
        self.responseDisposition = disposition
    }

    /**
    * The function create a new data task and also set a delegate to handle responses
    *
    * @param request The request for the data task.
    * @param file The url of the file to upload.
    * @param completionHandler The closure to be called when the task end.
    *
    * @return NSURLSessionUploadTask
    */

    func uploadTaskWithRequest(request: NSURLRequest, file fileURL: NSURL, progress handler: NGeenProgressTaskClosure, completionHandler closure: NGeenTaskClosure) -> NSURLSessionUploadTask {
        var dataTask: NSURLSessionUploadTask = self.session!.uploadTaskWithRequest(request, fromFile: fileURL)
        if dataTask == nil && !self.session!.configuration.identifier.isEmpty {
            for _ in 1...5 {
                dataTask = self.session!.uploadTaskWithRequest(request, fromFile: fileURL)
            }
        }
        self.setDelegateForUploadTask(dataTask, stream: nil, progress: handler, completionHandler: closure)
        return dataTask
    }

    /**
    * The function create a new data task and also set a delegate to handle responses
    *
    * @param request The request for the data task.
    * @param data The data to start the upload.
    * @param completionHandler The closure to be called when the task end.
    *
    * @return NSURLSessionUploadTask
    */

    func uploadTaskWithRequest(request: NSURLRequest, data bodyData: NSData, progress handler: NGeenProgressTaskClosure, completionHandler closure: NGeenTaskClosure) -> NSURLSessionUploadTask {
        var dataTask: NSURLSessionUploadTask = self.session!.uploadTaskWithRequest(request, fromData: bodyData)
        self.setDelegateForUploadTask(dataTask, stream: nil, progress: handler, completionHandler: closure)
        return dataTask
    }

    /**
    * The function create a new data task and also set a delegate to handle responses
    *
    * @param request The streamed request for the data task.
    * @param completionHandler The closure to be called when the task end.
    *
    * @return NSURLSessionUploadTask
    */

    func uploadTaskWithStreamedRequest(request: NSURLRequest, stream streamHandler: NGeenTaskStreamClosure, progress handler: NGeenProgressTaskClosure, completionHandler closure: NGeenTaskClosure) -> NSURLSessionUploadTask {
        var dataTask: NSURLSessionUploadTask = self.session!.uploadTaskWithStreamedRequest(request)
        self.setDelegateForUploadTask(dataTask, stream: streamHandler, progress: handler, completionHandler: closure)
        return dataTask
    }

    // MARK: NSURLSessionDataTask delegate
    
    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask!) {
        let delegate: SessionTaskDelegate? = self.delegateForTask(dataTask)
        if delegate != nil {
            self.removeDelegateForTask(dataTask)
            self.setDelegate(delegate!, ForTask: dataTask)
        }
        self.becomeDownloadTaskClosure?(session, dataTask, downloadTask)
    }
    
    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveData data: NSData!) {
        if let sessionTaskDelegate: SessionTaskDelegate = self.delegateForTask(dataTask) {
            sessionTaskDelegate.URLSession(session, dataTask: dataTask, didReceiveData: data)
        }
    }
    
    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveResponse response: NSURLResponse!, completionHandler: ((NSURLSessionResponseDisposition) -> Void)!) {
        completionHandler(self.responseDisposition!)
    }
    
    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, willCacheResponse proposedResponse: NSCachedURLResponse!, completionHandler: ((NSCachedURLResponse!) -> Void)!) {
        if NGeenOptions.useURLCache & self.options {
            completionHandler(proposedResponse)
        }
    }

    // MARK: NSURLSessionDownloadTask delegate
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didFinishDownloadingToURL location: NSURL!) {
        if let sessionTaskDelegate: SessionTaskDelegate = self.delegateForTask(downloadTask) {
            sessionTaskDelegate.URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
        }
    }
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let delegate: SessionTaskDelegate = self.delegateForTask(downloadTask) {
            delegate.URLSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
    }
    
    // MARK: NSURLSessiontask delegate
    
    func URLSession(session: NSURLSession!, didBecomeInvalidWithError error: NSError!) {
        dispatch_barrier_async(self.queue, {
            self.dataTasksDelegates.removeAll(keepCapacity: false)
        })
    }

    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didCompleteWithError error: NSError!) {
        if let delegate: SessionTaskDelegate = self.delegateForTask(task) {
            switch task.currentRequest.HTTPMethod {
                case HttpMethod.head.toRaw(), HttpMethod.options.toRaw(), HttpMethod.get.toRaw():
                    if self.options != nil && !(NGeenOptions.ignoreCache & self.options) && !(NGeenOptions.useURLCache & self.options) && !error  {
                        DiskCache.defaultCache().storeData(NSPurgeableData(data: delegate.data), forUrl: task.currentRequest.URL, completionHandler: nil)
                    }
                default:
                    ""
            }
            delegate.URLSession(session, task: task, didCompleteWithError: error)
            self.removeDelegateForTask(task)
        }
    }
    
    func URLSession(session: NSURLSession!, didReceiveChallenge challenge: NSURLAuthenticationChallenge!, completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)!) {
        var disposition: NSURLSessionAuthChallengeDisposition = NSURLSessionAuthChallengeDisposition.PerformDefaultHandling
        var credential: NSURLCredential? = self.credential
        if credential == nil {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                if self.securityPolicy.trustedServer(challenge.protectionSpace.serverTrust, forDomain: challenge.protectionSpace.host) {
                    disposition = NSURLSessionAuthChallengeDisposition.UseCredential
                    credential =  NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
                } else {
                    disposition = NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge
                }
            }
        }
        completionHandler(disposition, credential)
    }

    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, needNewBodyStream completionHandler: ((NSInputStream!) -> Void)!) {
        if let delegate: SessionTaskDelegate = self.delegateForTask(task) {
            delegate.URLSession(session, task: task, needNewBodyStream: completionHandler)
        }
    }

    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, willPerformHTTPRedirection response: NSHTTPURLResponse!, newRequest request: NSURLRequest!, completionHandler: ((NSURLRequest!) -> Void)!) {
        var redirection: NSURLRequest = request
        if self.redirection != nil {
            redirection = self.redirection!
        }
        completionHandler(redirection)
    }

    // MARK: NSURLSessionUploadTask delegate
    
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let delegate: SessionTaskDelegate = self.delegateForTask(task) {
            delegate.URLSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
        }
    }

    // MARK: Private methods

    /**
    * The function lock and get the delegate for the given task
    *
    * @param task The task to get the identifier.
    *
    */

    private func delegateForTask(task: NSURLSessionTask) -> SessionTaskDelegate? {
        var delegate: SessionTaskDelegate?
        dispatch_barrier_sync(self.queue, {
            delegate = self.dataTasksDelegates[task.taskIdentifier]
        })
        return delegate
    }

    /**
    * The function lock and delete the delegate for the given task
    *
    * @param task The task to get the identifier.
    *
    */

    private func removeDelegateForTask(task: NSURLSessionTask) {
        dispatch_barrier_async(self.queue, {
            self.dataTasksDelegates[task.taskIdentifier] = nil
        })
    }

    /**
    * The function set the delegate for the given task
    *
    * @Param delegate The instance of the delegate.
    * @param task The task to set the delegate.
    *
    */
    
    private func setDelegate(delegate: SessionTaskDelegate, ForTask task: NSURLSessionTask) {
        let sessionTaskDelegate: SessionTaskDelegate = SessionTaskDelegate()
        dispatch_barrier_async(self.queue, {
            self.dataTasksDelegates[task.taskIdentifier] = sessionTaskDelegate
        })
    }
    
    /**
    * The function add a new delegate for the given task
    *
    * @param task The task to get the identifier.
    *
    */

    private func setDelegateForTask(task: NSURLSessionTask, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)!) {
        let sessionTaskDelegate: SessionTaskDelegate = SessionTaskDelegate()
        sessionTaskDelegate.closure = closure
        dispatch_barrier_async(self.queue, {
            self.dataTasksDelegates[task.taskIdentifier] = sessionTaskDelegate
        })
    }
    
    /**
    * The function add a new delegate for the given task
    *
    * @param task The task to get the identifier.
    *
    */

    private func setDelegateForDownloadTask(task: NSURLSessionDownloadTask, destination: NSURL?, progress handler: NGeenProgressTaskClosure, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)!) {
        let sessionTaskDelegate: SessionTaskDelegate = SessionTaskDelegate()
        sessionTaskDelegate.closure = closure
        sessionTaskDelegate.destinationURL = destination
        sessionTaskDelegate.downloadProgressHandler = handler
        dispatch_barrier_async(self.queue, {
            self.dataTasksDelegates[task.taskIdentifier] = sessionTaskDelegate
        })
    }

    /**
    * The function add a new delegate for the given task
    *
    * @param task The task to get the identifier.
    *
    */

    private func setDelegateForUploadTask(task: NSURLSessionUploadTask, stream streamHandler: ((NSURLSession!, NSURLSessionTask!) -> NSInputStream)?, progress handler: NGeenProgressTaskClosure, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)!) {
        let sessionTaskDelegate: SessionTaskDelegate = SessionTaskDelegate()
        sessionTaskDelegate.closure = closure
        sessionTaskDelegate.streamHandler = streamHandler
        sessionTaskDelegate.uploadProgressHandler = handler
        var totalCount: Int64 = task.countOfBytesSent
        if totalCount == NSURLSessionTransferSizeUnknown {
            let contentLength: NSString = task.originalRequest.valueForHTTPHeaderField("Content-Length")
            if contentLength.length > 0 {
                totalCount = contentLength.longLongValue as Int64
            }
        }
        sessionTaskDelegate.setTotalUnitCount(totalCount)
        sessionTaskDelegate.progress.cancellationHandler = ({
            task.cancel()
        })
        sessionTaskDelegate.progress.pausingHandler = ({
            task.suspend()
        })
        dispatch_barrier_async(self.queue, {
            self.dataTasksDelegates[task.taskIdentifier] = sessionTaskDelegate
        })
    }

}
