//
// SessionTaskDelegate.swift
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

class SessionTaskDelegate: NSObject, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate {
    
    private(set) var progress: NSProgress
    private var data: NSMutableData
    
    var closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?
    var downloadProgressHandler: ((Int64!, Int64!, Int64!) -> Void)?
    var destinationURL: NSURL?
    var streamHandler: ((NSURLSession!, NSURLSessionTask!) -> NSInputStream)?
    var uploadProgressHandler: ((Int64!, Int64!, Int64!) -> Void)?
    
    override init() {
        self.data = NSMutableData()
        self.progress = NSProgress(totalUnitCount: 0)
    }
    
//MARK: Instance methods
    
    /**
    * The function set the unit count to the progress
    *
    * @param totalUnitCount The unit count for the progress.
    *
    */
    
    func setTotalUnitCount(totalUnitCount: Int64) {
        self.progress = NSProgress(totalUnitCount: totalUnitCount)
    }
    
//MARK: NSURLSessionData delegate
    
    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!, didReceiveData data: NSData!) {
        self.data.appendData(data)
    }
    
//MARK: NSURLSessionDownloadTask delegate
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didFinishDownloadingToURL location: NSURL!) {
        if self.destinationURL != nil {
            var error: NSError?
            NSFileManager.defaultManager().moveItemAtURL(location, toURL: self.destinationURL, error: &error)
            //TODO: Handle error
        }
    }
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        self.progress.totalUnitCount = expectedTotalBytes
        self.progress.completedUnitCount = fileOffset
    }
    
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progress.totalUnitCount = totalBytesExpectedToWrite
        self.progress.completedUnitCount = totalBytesWritten
        self.downloadProgressHandler?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }
    
//MARK: NSURLSessionTask delegate
    
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didCompleteWithError error: NSError!) {
        self.closure?(self.data, task.response, error)
    }
    
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, needNewBodyStream completionHandler: ((NSInputStream!) -> Void)!) {
        var inputStream: NSInputStream? = nil
        if let stream: NSInputStream = self.streamHandler?(session, task) {
            inputStream = stream
        } else {
            inputStream = task.originalRequest.HTTPBodyStream
        }
        completionHandler(inputStream)
    }
    
//MARK: NSURLSessionUploadTask delegate
    
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.progress.totalUnitCount = totalBytesExpectedToSend
        self.progress.completedUnitCount = totalBytesSent
        self.uploadProgressHandler?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
    }
    
}
