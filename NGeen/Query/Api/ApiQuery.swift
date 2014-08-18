//
// ApiQuery.swift
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


/*TODO: 1. return the query
*/

import UIKit

class ApiQuery: NSObject, QueryProtocol {
    
    internal var config: ConfigurationStoreProtocol {
        get {
            return configuration
        }
        set(config) {
            configuration = config as ApiStoreConfiguration
        }
    }
    private var configuration: ApiStoreConfiguration
    private var endPoint: ApiEndpoint
    private var queue: dispatch_queue_t?
    private var requestSerializer: RequestSerializer
    private var responseSerializer: ResponseSerializer
    private var sessionManager: SessionManager?
    
    weak var delegate: ApiQueryDelegate?
    
//MARK: Constructor
    
    init(configuration: ConfigurationStoreProtocol, endPoint: ApiEndpoint) {
        self.endPoint = endPoint
        self.configuration = ApiStoreConfiguration()
        self.requestSerializer = RequestSerializer()
        self.responseSerializer = ResponseSerializer()
        super.init()
        self.config = configuration
        self.queue = dispatch_queue_create("com.ngeen.requestqueue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_set_target_queue(self.queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        self.sessionManager = SessionManager(sessionConfiguration: self.configuration.sessionConfiguration)
        self.sessionManager!.securityPolicy = self.configuration.securityPolicy
        if let credential: NSURLCredential = self.configuration.credential {
            self.sessionManager!.setAuthenticationCredential(self.configuration.credential!, forProtectionSpace: self.configuration.protectionSpace!)
        }
        self.sessionManager!.responseDisposition = self.configuration.responseDisposition
    }
    
// MARK: Instance methods    
    
    /**
    * The function set to the request the parameters to download a object
    *
    * @param destination The destination to store the file.
    * @params handler The closure to track the download progress.
    * @param completionHandler The closure to be called when the function end.
    *
    * return NSURLSessionDownloadTask
    */
    
    func download(destination: NSURL, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDownloadTask {
        let request: NSURLRequest = self.requestSerializer.requestWithConfiguration(configuration, endPoint: self.endPoint)
        let downloadTask: NSURLSessionDownloadTask = self.sessionManager!.downloadTaskWithRequest(request, destination: destination, progress: handler, completionHandler: closure)
        downloadTask.resume()
        return downloadTask
    }
    
    /**
    * The function set to the request the parameters to download a object
    *
    * @param data The partial data.
    * @param destination The destination to store the file.
    * @params handler The closure to track the download progress.
    * @param completionHandler The closure to be called when the function end.
    *
    * return NSURLSessionDownloadTask
    */
    
    func downloadWithResumeData(data: NSData, destination url: NSURL, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDownloadTask {
        let downloadTask: NSURLSessionDownloadTask = self.sessionManager!.downloadTaskWithResumeData(data, destination: url, progress: handler, completionHandler: closure)
        downloadTask.resume()
        return downloadTask
    }
    
    /**
    * The function execute the task
    *
    * @param completionHandler The closure to be called when the function end.
    *
    */
    
    func execute(#completionHandler: NGeenClosure) {
        let request: NSURLRequest = self.requestSerializer.requestSerializingWithConfiguration(self.configuration, endPoint: self.endPoint, error: nil)
        let sessionDataTask: NSURLSessionDataTask = self.sessionManager!.dataTaskWithRequest(request, completionHandler: {(data, urlResponse, error) in
            var response: AnyObject!
            if !error {
                response = self.responseSerializer.responseWithConfiguration(self.configuration, endPoint: self.endPoint, data: data, error: nil)
            }
            completionHandler?(object: response, error: error)
        })
        self.cachedResponseForTask(sessionDataTask)
        sessionDataTask.resume()
    }
    
    /**
    * The function execute the request
    *
    * @params parameters The parameters for the request.
    * @param completionHandler The closure to be called when the function end.
    *
    */
    
    func execute(parameters: [String: String], completionHandler closure: NGeenClosure) {
        switch self.endPoint.httpMethod {
        case .delete, .get, .head:
            self.setQueryItems(parameters)
        case .patch, .post, .put:
            self.configuration.bodyItems += parameters
        default:
            assert(false, "Invalid http method", file: __FILE__, line: __LINE__)
        }
        self.execute(completionHandler: closure)
    }
    
    /**
    * The function return the body items
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func getBodyItems() -> [String: AnyObject] {
        return self.configuration.bodyItems
    }
    
    /**
    * The function return the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLRequestCachePolicy
    */
    
    func getCachePolicy() -> NSURLRequestCachePolicy {
        return self.configuration.sessionConfiguration.requestCachePolicy
    }
    
    /**
    * The function return the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    *
    * @return NSURLRequestCachePolicy
    */
    
    func getCacheStoragePolicy() -> NSURLCacheStoragePolicy {
        return self.configuration.cacheStoragePolicy
    }
    
    /**
    *  The function return the configuration for the api query
    *
    *  @return ApiStoreConfig
    */
    
    func getConfiguration() -> ApiStoreConfiguration {
        return self.configuration
    }
    
    /**
    * The function get the progress for the given task
    *
    * @param task The task to get the current progress.
    *
    * return NSProgress
    */
    
    func getDownloadProgressForTask(task: NSURLSessionUploadTask) -> NSProgress {
        return self.sessionManager!.getDownloadProgressForTask(task)!
    }
    
    /**
    * The function get the progress for the given task
    *
    * @param task The task to get the current progress.
    *
    * return NSProgress
    */
    
    func getUploadProgressForTask(task: NSURLSessionUploadTask) -> NSProgress? {
        return self.sessionManager!.getUploadProgressForTask(task)!
    }
    
    /**
    * The function return the http headers
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func getHttpHeaders() -> [String: String] {
        return self.configuration.headers
    }
    
    /**
    * The function return model path
    *
    * @param no need params.
    *
    * @return String
    */
    
    func getModelsPath() -> String {
        return self.configuration.modelsPath
    }
    
    /**
    * The function return the path items
    *
    * @param no need params.
    *
    * @return Dictionary
    */
    
    func getPathItems() -> [String: String] {
        return self.configuration.pathItems
    }
    
    /**
    * The function return the full path for the components
    *
    * @param no need params.
    *
    * @return String
    */
    
    func getPath() -> String {
        return self.endPoint.path
    }
    
    /**
    * The function return the response disposition for the request
    *
    * @param no need params.
    *
    * @return NSURLSessionResponseDisposition
    */
    
    func getResponseDisposition() -> NSURLSessionResponseDisposition {
        return self.configuration.responseDisposition
    }
    
    /**
    * The function return the response type for the session
    *
    * @param no need params.
    *
    * @return ResponseType
    */
    
    func getResponseType() -> ResponseType {
        return self.configuration.responseType
    }
    
    /**
    * The function return the security policy for the session
    *
    * no need params.
    *
    * return Policy
    */
    
    func getSecurityPolicy() -> Policy {
        return self.configuration.securityPolicy.policy
    }
    
    /**
    * The function store the body item in a local dictionary
    *
    * @param item The body item.
    * param key The key for the given item.
    *
    */
    
    func setBodyItem(item: AnyObject, forKey key: String) {
        self.configuration.bodyItems[key] = item
    }
    
    /**
    * The function store the body the items in a local dictionary
    *
    * @param items The body items for the request.
    *
    */
    
    func setBodyItems(items: [String: AnyObject]) {
        self.configuration.bodyItems += items
    }
    
    /**
    * The function set the cache request policy for a server configuration
    *
    * @param policy The cache policy.
    *
    */
    
    func setCachePolicy(policy: NSURLRequestCachePolicy) {
        self.configuration.sessionConfiguration.requestCachePolicy = policy
    }
    
    /**
    * The function set the cache storage policy for a server configuration
    *
    * @param policy The cache policy.
    *
    */
    
    func setCacheStoragePolicy(policy: NSURLCacheStoragePolicy) {
        self.configuration.cacheStoragePolicy = policy
    }
    
    /**
    * The function set the data for a given image
    *
    * @param closure The closure to call when the serializer need the image data.
    *
    */
    
    func setConstructingBodyClosure(closure: () -> (data: NSData!, name: String!, fileName: String!, mimeType: String!)) {
        self.requestSerializer.constructingBodyClosure = closure
    }
    
    /**
    * The function set a value for the local headers
    *
    * @param header The value for the header.
    * @param key The value for the header field.
    *
    */
    
    func setHeader(header: String, forKey key: String) {
        self.configuration.headers[key] = header
    }
    
    /**
    * The function set the headers in a local dictionary
    *
    * @param headers The headers for the request.
    *
    */
    
    func setHeaders(headers: [String: String]) {
        self.configuration.headers += headers
    }

    /**
    * The function set the model path for the api response
    *
    * @param path The path of the models in the api response.
    *
    */
    
    func setModelsPath(path: String) {
        self.configuration.modelsPath = path
    }
   
    /**
    * The function store a path item in a local dictionary
    *
    * @param item The path item.
    * @param key The key for the given item.
    *
    */
    
    func setPathItem(item: String, forKey key: String) {
        self.configuration.pathItems[key] = item
        self.endPoint.path += "/\(item)"
    }
    
    /**
    * The function store the path items in a local dictionary
    *
    * @param items The path items.
    *
    */
    
    func setPathItems(items: [String: String]) {
        self.configuration.pathItems += items
        for (key, value) in items {
            self.setPathItem(value, forKey: key)
        }
    }
    
    /**
    * The function store a query item in a local dictionary
    *
    * @param item The query item.
    * @param key The key for the given query item.
    *
    */
    
    func setQueryItem(item: AnyObject, forKey key: String) {
        self.configuration.queryItems[key] = item
    }
    
    /**
    * The function store the query items in a local dictionary
    *
    * @param items The query items.
    *
    */
    
    func setQueryItems(items: [String: AnyObject]) {
        self.configuration.queryItems += items
    }
    
    /**
    * The function set the response disposition to the API Store
    *
    * @param disposition The disposition for the request.
    *
    */
    
    func setResponseDisposition(disposition: NSURLSessionResponseDisposition) {
        self.configuration.responseDisposition = disposition
    }
    
    /**
    * The function set the response type for the query
    *
    * @param type The response type.
    *
    */
    
    func setResponseType(type: ResponseType) {
        self.configuration.responseType = type
    }
    
    /**
    * The function set the security policy for the session
    *
    * @param policy The security policy for the session.
    *
    */
    
    func setSecurityPolicy(policy: Policy) {
        self.configuration.securityPolicy.policy = policy
    }
    
    /**
    * The function set the session configuration
    *
    * @param sessionConfiguration The session Configuration.
    *
    */
    
    func setSessionConfiguration(sessionConfiguration: NSURLSessionConfiguration) {
        self.configuration.sessionConfiguration = sessionConfiguration
    }
    
    /**
    * The function set to the request the parameters to upload a file
    *
    * @param data The data to upload.
    * @params handler The closure to track the upload progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func upload(data: NSData, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?) ->  NSURLSessionUploadTask {
        let request: NSURLRequest = self.requestSerializer.requestWithConfiguration(configuration, endPoint: self.endPoint)
        let uploadTask: NSURLSessionUploadTask = self.sessionManager!.uploadTaskWithRequest(request, data: data, progress: handler, completionHandler: closure)
        uploadTask.resume()
        return uploadTask
    }
    
    /**
    * The function set to the request the parameters to upload a file
    *
    * @param file The url of the file to upload.
    * @params handler The handler to track the upload progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func upload(file: NSURL, progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionUploadTask {
        let request: NSURLRequest = self.requestSerializer.requestWithConfiguration(configuration, endPoint: self.endPoint)
        let uploadTask: NSURLSessionUploadTask = self.sessionManager!.uploadTaskWithRequest(request, file: file, progress: handler, completionHandler: closure)
        uploadTask.resume()
        return uploadTask
    }
    
    /**
    * The function set to the request the parameters to upload a stream
    *
    * @param stream The closure to handle the stream needed for the request.
    * @params handler The handler to track the upload progress.
    * @param completionHandler The closure to be called when the function end.
    */
    
    func upload(stream: ((NSURLSession!, NSURLSessionTask!) -> NSInputStream), progress handler: ((Int64!, Int64!, Int64!) -> Void)?, completionHandler closure: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionUploadTask {
        let request: NSMutableURLRequest = self.requestSerializer.requestWithConfiguration(configuration, endPoint: self.endPoint).mutableCopy() as NSMutableURLRequest
        request.HTTPBodyStream = NSInputStream(data: request.HTTPBody)
        let uploadTask: NSURLSessionUploadTask = self.sessionManager!.uploadTaskWithStreamedRequest(request, stream: stream, progress: handler, completionHandler: closure)
        uploadTask.resume()
        return uploadTask
    }
    
// MARK: Private methods
    
    /**
    * The function search for the cache data
    *
    * @param task The Task with the url key to search de cached data.
    *
    */
    
    private func cachedResponseForTask(task: NSURLSessionDataTask) {
        dispatch_async(self.queue, {
            var data: NSPurgeableData = NSPurgeableData()
            if self.configuration.sessionConfiguration.requestCachePolicy != NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData {
                data = DiskCache.defaultCache().dataForUrl(task.currentRequest.URL)
                if self.delegate != nil && self.delegate!.respondsToSelector("cachedResponseForUrl:cachedData:") {
                    let response: AnyObject = self.responseSerializer.responseWithConfiguration(self.configuration, endPoint: self.endPoint, data: data, error: nil)
                    self.delegate!.cachedResponseForUrl!(task.currentRequest.URL, cachedData: response)
                }
                if data.length > 0 && (self.configuration.sessionConfiguration.requestCachePolicy == NSURLRequestCachePolicy.ReturnCacheDataDontLoad ||
                    self.configuration.sessionConfiguration.requestCachePolicy == NSURLRequestCachePolicy.ReturnCacheDataElseLoad) {
                    task.cancel()
                }
            }
        })
    }
    
}
